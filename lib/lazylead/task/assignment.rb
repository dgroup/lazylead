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

require "date"
require_relative "../log"
require_relative "../opts"
require_relative "../system/jira"

module Lazylead
  module Task
    #
    # Email alerts about illegal issue assignment(s).
    #
    # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
    # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
    # License:: MIT
    class Assignment
      def initialize(log = Log.new)
        @log = log
      end

      def run(sys, postman, opts)
        allowed = opts.slice "allowed", ","
        silent = opts.key? "silent"
        issues = sys.issues opts["jql"],
                            opts.jira_defaults.merge(expand: "changelog")
        return if issues.empty?
        postman.send opts.merge(
          assignees: issues.map { |i| Assignee.new(i, allowed, silent) }
                           .select(&:illegal?)
                           .each(&:add_label)
        )
      end
    end

    # Instance of "Assignee" history item for the particular ticket.
    class Assignee
      attr_reader :issue

      def initialize(issue, allowed, silent)
        @issue = issue
        @allowed = allowed
        @silent = silent
      end

      # Gives true when last change of "Assignee" field was done
      #  by not authorized person.
      def illegal?
        @allowed.none? do |a|
          return false if last.nil?
          a == last["author"]["name"]
        end
      end

      # Detect details about last change of "Assignee" to non-null value
      def last
        @last ||= issue.history.reverse.find do |h|
          h["items"].any? do |i|
            i["field"] == "assignee"
          end
        end
      end

      # Mark ticket with particular label
      def add_label(name = "LL.IllegalChangeOfAssignee")
        @issue.add_label(name) unless @silent
      end

      # The name of current assignee for ticket
      def to
        @issue.fields["assignee"]["name"]
      end
    end
  end
end
