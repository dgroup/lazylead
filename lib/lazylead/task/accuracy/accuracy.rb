# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2021 Yurii Dubinka
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

require_relative "memes"
require_relative "../../log"
require_relative "../../opts"
require_relative "../../email"
require_relative "../../version"
require_relative "../../postman"
require_relative "../../requires"

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
        init_rules(opts)
        tasks = sys.issues(opts["jql"], opts.jira_defaults.merge(expand: "changelog"))
                   .map { |i| Score.new(i, opts) }
                   .each do |s|
          s.evaluate
          s.post
        end
        unless tasks.empty? && tasks.size <= opts.fetch(:limit, 300).to_i
          opts[:tickets] = tasks
          postman.send(opts)
        end
        opts
      end

      # Initialize accuracy rules and configuration for tickets verification.
      def init_rules(opts)
        Requires.new(__dir__).load
        opts[:rules] = opts.construct("rules")
        opts[:total] = opts[:rules].sum(&:score)
        opts[:memes] = Memes.new(opts["memes"])
      end
    end
  end

  # The ticket score based on fields content.
  class Score
    attr_reader :issue, :score, :accuracy

    def initialize(issue, opts)
      @issue = issue
      @opts = opts
    end

    # Estimate the ticket score and accuracy.
    # Accuracy is a percentage between current score and maximum possible value.
    def evaluate(digits = 2)
      @score = @opts[:rules].select { |r| r.passed(@issue) }.sum(&:score)
      @accuracy = (@score.to_f / @opts[:total] * 100).round(digits)
      self
    end

    # Post the comment with score and accuracy to the ticket.
    def post
      return if @opts.key? "silent"
      @issue.post comment
      @issue.add_label "LL.accuracy", "#{grade(@accuracy)}%", "#{@accuracy}%"
    end

    # The jira comment in markdown format
    def comment
      comment = [
        "Hi [~#{reporter}],",
        "",
        "The triage accuracy is '{color:#{color}}#{@score}{color}'" \
        " (~{color:#{color}}#{@accuracy}%{color}), here are the reasons why:",
        "|| Ticket requirement || Status || Field ||"
      ]
      @opts[:rules].each do |r|
        comment << "|#{r.desc}|#{r.passed(@issue) ? '(/)' : '(-)'}|#{r.field}|"
      end
      comment << docs_link
      comment << reaction
      comment << "Posted by [lazylead v#{Lazylead::VERSION}|https://bit.ly/2NjdndS]."
      comment.join("\r\n")
    end

    # Link to ticket formatting rules
    def docs_link
      if @opts["docs"].nil? || @opts["docs"].blank?
        ""
      else
        "The requirements/examples of ticket formatting rules you may find " \
          "[here|#{@opts['docs']}]."
      end
    end

    def color
      return "#061306" if colors.nil? || !defined?(@score) || !@score.is_a?(Numeric)
      colors.reverse_each do |color|
        return color.last if @accuracy >= color.first
      end
      "#061306"
    end

    def colors
      @colors ||= JSON.parse(@opts["colors"])
                      .to_h
                      .to_a
                      .each { |e| e[0] = e[0].to_i }
                      .sort_by { |e| e[0] }
    end

    # Calculate grade for accuracy
    # For example,
    #  grade(7.5)   => 0
    #  grade(12)    => 10
    #  grade(25.5)  => 20
    def grade(value)
      (value / 10).floor * 10
    end

    # Detect the ticket reporter.
    #
    # If ticket created by some automatic/admin user account then reporter is the first non-system
    #  user account who modified the ticket.
    def reporter
      sys = @opts.slice("system-users", ",")
      return @issue.reporter.id if sys.empty? || sys.none? { |susr| susr.eql? @issue.reporter.id }
      first = @issue.history.find { |h| sys.none? { |susr| susr.eql? h["author"]["key"] } }
      return @issue.reporter.id if first.nil?
      first["author"]["key"]
    end

    # Add reaction meme to the ticket comment based on score.
    # The meme details are represented as array, where each element is a separate line in future
    #  comment in jira.
    #
    # @todo #339/DEV Seems jira doesn't support the rendering of external images by url, thus so far
    #  we might have several options:
    #  - attach meme to ticket and make rendering using [^attach.jpg!thumbnail] option
    #  - have a link to meme (like it implemented now)
    #  The 1st option with attachment might generate multiple events in jira and spam ticket
    #  watchers, thus, some research & UX testing needed how to make it better.
    def reaction
      return [] if @opts[:memes].nil? && !@opts[:memes].enabled?
      url = @opts[:memes].find(@accuracy)
      return [] if url.blank?
      [
        "",
        "Our reaction when we got the ticket with triage accuracy #{@accuracy}% is [here|#{url}].",
        ""
      ]
    end
  end
end
