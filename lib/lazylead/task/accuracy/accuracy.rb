# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2020 Yurii Dubinka
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom
# the Software is  furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
# OR OTHER DEALINGS IN THE SOFTWARE.

require_relative "../../log"
require_relative "../../opts"
require_relative "../../email"
require_relative "../../version"
require_relative "../../postman"

module Lazylead
  module Task
    #
    # Evaluate ticket format and accuracy
    #
    # The task supports the following features:
    #  - fetch issues from remote ticketing system by query
    #  - evaluate each field within the ticket
    #  - post the score to the ticket
    class Accuracy
      def initialize(log = Log.new)
        @log = log
      end

      def run(sys, postman, opts)
        require_rules
        rules = opts.slice("rules", ",")
                    .map(&:constantize)
                    .map(&:new)
        raised = sys.issues(opts["jql"], opts.jira_defaults)
                    .map { |i| Score.new(i, opts, rules) }
                    .each(&:evaluate)
                    .each(&:post)
        postman.send opts.merge(tickets: raised) unless raised.empty?
      end

      # Load all ticket accuracy rules for future verification
      def require_rules
        rules = File.dirname(__FILE__)
        $LOAD_PATH.unshift(rules) unless $LOAD_PATH.include?(rules)
      end
    end
  end

  # The ticket score based on fields content.
  class Score
    attr_reader :issue, :total, :score, :accuracy

    def initialize(issue, opts, rules)
      @issue = issue
      @link = opts["docs"]
      @opts = opts
      @rules = rules
    end

    # Estimate the ticket score and accuracy.
    # Accuracy is a percentage between current score and maximum possible value.
    def evaluate(digits = 2)
      @total = @rules.map(&:score).sum
      @score = @rules.select { |r| r.passed(@issue) }
                     .map(&:score)
                     .sum
      @accuracy = (score / @total * 100).round(digits)
    end

    # Post the comment with score and accuracy to the ticket.
    def post
      @issue.post(comment) unless @opts.key? "silent"
    end

    # The jira comment in markdown format
    def comment
      comment = [
        "Hi [~#{@issue.reporter.id}],",
        "",
        "The triage accuracy is '{color:#{color}}#{@score}{color}'" \
          " (~{color:#{color}}#{@accuracy}%{color}), here are the reasons why:",
        "|| Ticket requirement || Status || Field ||"
      ]
      @rules.each do |r|
        comment << "|#{r.desc}|#{r.passed(@issue) ? '(/)' : '(-)'}|#{r.field}|"
      end
      comment << docs_link
      comment << ""
      comment << "Posted by [lazylead v#{Lazylead::VERSION}|" \
                    "https://bit.ly/2NjdndS]."
      comment.join("\r\n")
    end

    # Link to ticket formatting rules
    def docs_link
      if @link.nil? || @link.blank?
        ""
      else
        "The requirements/examples of ticket formatting rules you may find " \
          "[here|#{@link}]."
      end
    end

    def color
      if colors.nil? || !defined?(@score) || !@score.is_a?(Numeric)
        return "#061306"
      end
      colors.reverse_each do |color|
        return color.last if @accuracy >= color.first
      end
      "#061306"
    end

    def colors
      @colors ||= begin
                    JSON.parse(@opts["colors"])
                        .to_h
                        .to_a
                        .each { |e| e[0] = e[0].to_i }
                        .sort_by { |e| e[0] }
                  end
    end
  end
end