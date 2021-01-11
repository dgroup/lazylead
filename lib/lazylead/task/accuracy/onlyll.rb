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

module Lazylead
  module Task
    #
    # Ensure that ticket accuracy evaluation labels are set only by LL, not by
    #  some person.
    #
    # The task supports the following features:
    #  - fetch issues from remote ticketing system by query
    #  - check the history of labels modification
    #  - remove evaluation labels if they set not by LL
    class OnlyLL
      def initialize(log = Log.new)
        @log = log
      end

      def run(sys, postman, opts)
        found = sys.issues(opts["jql"],
                           opts.jira_defaults.merge(expand: "changelog"))
                   .map { |i| Labels.new(i, opts) }
                   .select(&:exists?)
                   .reject(&:valid?)
                   .each(&:remove)
        postman.send opts.merge(tickets: found) unless found.empty?
      end
    end
  end

  # The ticket with grid labels
  class Labels
    attr_reader :issue

    def initialize(issue, opts)
      @issue = issue
      @opts = opts
    end

    # Ensure that issue has evaluation labels for accuracy rules
    def exists?
      return false if @issue.labels.nil? || @issue.labels.empty?
      return false unless @issue.labels.is_a? Array
      grid.any? { |g| @issue.labels.any? { |l| g.eql? l } }
    end

    # Compare the score evaluated by LL and current ticket score.
    # @return true if current score equal to LL evaluation
    def valid?
      score.eql?(@issue.labels.sort.find { |l| grid.any? { |g| l.eql? g } })
    end

    # Find expected ticket score evaluated by LL.
    # If LL evaluated the same ticket several times (no matter why),
    #  then the last score would be returned.
    def score
      to_l(
        @issue.history
              .select { |h| h["author"]["key"].eql? @opts["author"] }
              .select { |h| to_l(h) }
              .reverse
              .first
      ).fetch("toString", "").split(" ").find { |l| grid.any? { |g| l.eql? g } }
    end

    # Find history record with labels changes.
    def to_l(history)
      return {} if history.nil? || history.empty?
      history["items"].find { |f| f["field"].eql? "labels" }
    end

    # Detect the percentage grid for tickets, by default its 0%, 10%, 20%, etc.
    def grid
      @grid ||= begin
                  return @opts.slice("grid", ",") if @opts.key? "grid"
                  %w[0% 10% 20% 30% 40% 50% 60% 70% 80% 90% 100%]
                end
    end

    # Remove score labels from the ticket.
    def remove
      @issue.labels!(@issue.labels - grid)
    end

    # Detect the violators with their changes.
    #   .violators  => ["Tom Hhhh set 40%", "Bob Mmmm set 50%"]
    def violators
      @issue.history
            .reject { |h| h["author"]["key"].eql? @opts["author"] }
            .select { |h| grid?(h) }
            .group_by { |h| h["author"]["key"] }
            .map do |a|
        "#{a.last.first['author']['displayName']} set #{hacked(a.last)}"
      end
    end

    # Ensure that history record has label change related to LL grid labels.
    # @return true if LL grid labels added
    def grid?(record)
      diff(record).any? { |d| d.find { |l| grid.any? { |g| l.eql? g } } }
    end

    # Detect label diff in single history record from ticket's history.
    def diff(record)
      record["items"].select { |f| f["field"].eql? "labels" }
                     .reject { |f| f["toString"].nil? || f["toString"].blank? }
                     .map do |f|
        from = []
        from = f["fromString"].split(" ") unless f["fromString"].nil?
        f["toString"].split(" ") - from
      end
    end

    # Hacked score by violator in ticket's history.
    def hacked(record)
      diff(record.first)
        .first
        .find { |l| grid.any? { |g| l.eql? g } }
    end
  end
end
