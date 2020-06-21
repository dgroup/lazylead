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

require_relative "../log"
require_relative "../version"
require_relative "../system/jira"

module Lazylead
  module Task
    #
    # Propagate particular JIRA fields from parent ticket to sub-tasks.
    #
    # The task algorithm:
    #  - fetch parent issues from remote ticketing system by JQL
    #  - reject issues without sub-tasks
    #  - fetch sub-tasks details
    #  - make a diff for pre-defined fields provided by the user
    #  - apply diff to sub-tasks
    #  - make a comment to sub-task with clarification.
    class PropagateDown
      def initialize(log = Log::NOTHING)
        @log = log
      end

      # @todo #/DEV Define a new module Lazylead::Task with basic methods like
      #  split, groupBy(assignee, reporter, etc), blank?
      def run(sys, _, opts)
        fields = opts["fields"].split(",").map(&:strip).reject(&:blank?)
        sys.issues(opts["jql"], fields: ["subtasks"] + fields)
           .map { |i| Parent.new(i, sys, fields) }
           .select(&:subtasks?)
           .each(&:fetch)
           .each(&:propagate)
      end
    end

    # The parent ticket as a source for propagation to children.
    class Parent
      def initialize(issue, sys, fields)
        @issue = issue
        @sys = sys
        @fields = fields
      end

      # Ensure that parent ticket has sub-tasks.
      def subtasks?
        !@issue.fields["subtasks"].empty?
      end

      # Take sub-tasks with their fields from external JIRA system.
      def fetch
        @subtasks = @issue.fields["subtasks"]
                          .map do |sub|
          @sys.raw { |j| j.Issue.find(sub["id"]) }
        end
      end

      # Fill pre-defined fields for sub-tasks from parent ticket
      #  and post comment to ticket with clarification.
      def propagate
        expected = Hash[@fields.collect { |f| [f, @issue.fields[f]] }]
        @subtasks.each do |subtask|
          actual = Hash[@fields.collect { |f| [f, subtask.fields[f]] }]
          diff = diff(expected, actual)
          next if diff.empty?
          subtask.save(fields: diff)
          subtask.comments.build.save!(body: comment(diff))
        end
      end

      # Detect difference between fields in parent ticket and sub-task.
      # The sub-tasks expected be updated by this diff.
      def diff(expected, actual)
        diff = {}
        actual.each_with_object(diff) do |a, d|
          k = a.first
          v = a.last
          d[k] = expected[k] if v.nil? || v.blank?
          next if v.nil?
          d[k] = v + "," + expected[k] unless v.to_s.include? expected[k]
        end
      end

      # Build a jira comment in markdown(*.md) format with diff table.
      def comment(diff)
        markdown = [
          "The following fields were propagated from #{@issue.key}:",
          "||Field||Value||"
        ]
        diff.each { |k, v| markdown << "|#{k}|#{v}|" }
        markdown << "Posted by [lazylead v#{Lazylead::VERSION}|" \
                    "https://bit.ly/2NjdndS]"
        markdown.join("\r\n")
      end
    end
  end
end
