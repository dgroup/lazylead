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

require "date"
require_relative "../log"
require_relative "../opts"
require_relative "../system/jira"

module Lazylead
  module Task
    # Notification about team loading
    class Loading
      def initialize(log = Log.new)
        @log = log
      end

      def run(sys, postman, opts)
        assignments = sys.issues(opts["jql"])
                         .group_by(&:assignee)
                         .map { |user, tasks| [user.id, Assignment.new(user, tasks)] }
                         .to_h
        opts.slice("team", ",")
            .map { |m| m.split(":") }
            .each { |id, name| assignments[id] = Free.new(id, name) unless assignments.key? id }
        return if assignments.empty?
        postman.send opts.merge(assignments: assignments)
      end
    end

    # The teammate's tickets.
    class Assignment
      extend Forwardable
      def_delegators :@user, :id, :name
      def_delegators :@tasks, :size

      def initialize(user, tasks = [])
        @user = user
        @tasks = tasks
      end

      def free?
        return true if @tasks.nil?
        @tasks.empty?
      end

      def next
        @tasks.reject { |t| t.duedate.nil? }.map { |t| t.duedate.to_date }.min
      end

      def to_s
        "#{id} has #{total} tasks"
      end
    end

    # The teammate without tasks.
    class Free
      attr_reader :id, :name

      def initialize(id, name)
        @id = id
        @name = name
      end

      def free?
        true
      end

      def next
        ""
      end
    end
  end
end
