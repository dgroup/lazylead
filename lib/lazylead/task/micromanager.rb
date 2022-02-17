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

require "date"
require_relative "../log"
require_relative "../opts"
require_relative "../system/jira"

module Lazylead
  module Task
    #
    # Email alerts about due date modification by not-authorized persons.
    #
    # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
    # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
    # License:: MIT
    class Micromanager
      def initialize(log = Log.new)
        @log = log
      end

      def run(sys, postman, opts)
        allowed = opts.slice "allowed", ","
        dues = sys.issues(opts["jql"], opts.jira_defaults.merge(expand: "changelog"))
                  .map { |i| Due.new(i, allowed, since(opts)) }
                  .select(&:illegal?)
                  .reject(&:obsolete?)
        return if dues.empty?
        postman.send opts.merge(dues: dues)
      end

      # Detect history period where search should start.
      #
      # opts["period"] The default period for past is 1 day (86400 seconds).
      #                So, if now 2017-04-06 15:50:58.674+0000
      #                it returns 2017-04-05 15:50:58 +0000
      #
      # opts["now"]    The current time for unit tests.
      #                If absent the "Time.now" is used.
      #
      def since(opts)
        @since ||= if opts.key? "now"
                     Time.parse(opts["now"])
                   else
                     Time.now - opts.fetch("period", "86400").to_i
                   end
      end
    end

    # Instance of "Due" history item for the particular ticket.
    class Due
      attr_reader :issue, :when

      def initialize(issue, allowed, since)
        @issue = issue
        @allowed = allowed
        @since = since
      end

      # Gives true when last change of "Due Date" field was done
      #  by not authorized person.
      def illegal?
        return false if @issue.assignee.id.eql?(last.id)
        @allowed.none? { |a| a.eql? last.id }
      end

      # Give true when "Due Date" changes happens in past and its alert already sent.
      def obsolete?
        @when < @since
      end

      # Detect details about last change of "Due Date" to non-null value
      def last
        @last ||= begin
          dd = @issue.history
                     .reverse
                     .find { |h| h["items"].any? { |i| i["field"] == "duedate" } }
          if dd.nil? && !@issue.duedate.nil?
            @when = @issue["created"]
            dd = @issue.reporter
          else
            @when = dd["created"]
            dd = Lazylead::User.new(dd["author"])
          end
          dd
        end
      end
    end
  end
end
