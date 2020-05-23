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
require_relative "../system/jira"
require_relative "../log"

module Lazylead
  module Task
    # @todo #/DEV Each task should verify input arguments.
    #  The common API should be provided for each task.
    class FixVersion
      def initialize(log = Log::NOTHING)
        @log = log
      end

      def run(sys, postman, opts)
        allowed = opts["allowed"].split(",").map(&:strip).reject(&:blank?)
        postman.send opts.merge(
          versions: sys.issues(opts["jql"], expand: "changelog")
                       .map { |i| Version.new(i, allowed) }
                       .select(&:changed?)
        )
      end
    end

    # Instance of "Fix Version" field for the particular task.
    class Version
      attr_reader :issue

      def initialize(issue, allowed)
        @issue = issue
        @allowed = allowed
      end

      # Gives true when last change of "Fix Version" field was done
      #  by not authorized person.
      def changed?
        @allowed.none? do |a|
          return false if last.nil?
          a == last["author"]["name"]
        end
      end

      # Detect details about last change of "Fix Version" to non-null value
      def last
        return @last if defined? @last
        @last = issue.history
                     .reverse
                     .find do |h|
          h["items"].any? do |i|
            i["field"] == "Fix Version" && !i["to"].nil?
          end
        end
      end
    end
  end
end