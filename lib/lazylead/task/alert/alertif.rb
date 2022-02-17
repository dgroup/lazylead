# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2022 Yurii Dubinka
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
require_relative "../../postman"
require_relative "../../requires"

module Lazylead
  module Task
    #
    # Send an alert if expected conditions are met.
    #
    # The task supports the following features:
    #  - fetch issues from remote ticketing system by query
    #  - evaluate set of rules for each ticket
    #  - send an email
    # @todo #334:DEV AlertIf should support rules for bulk issues. For now each rule works per issue
    class AlertIf
      def run(sys, postman, opts)
        Requires.new(__dir__).load
        opts[:rules] = opts.construct("rules")
        sys.issues(opts["jql"], opts.jira_defaults.merge(expand: "changelog"))
           .map { |i| When.new(i, opts) }
           .select(&:matches)
           .group_by(&:assignee)
           .each { |a, t| postman.send opts.merge(to: a.email, addressee: a.name, tickets: t) }
      end
    end

    # The conditions for the issue inspection.
    class When
      extend Forwardable
      def_delegators :@issue, :key, :url, :fields, :status, :duedate, :priority, :reporter,
                     :assignee, :summary, :comments

      def initialize(issue, opts)
        @issue = issue
        @opts = opts
      end

      def matches
        return false if @opts[:rules].nil?
        @opts[:rules].all? { |r| r.passed(@issue, @opts) }
      end

      # The last comment in ticket
      def last
        @last ||= @issue.comments.last
      end
    end
  end
end
