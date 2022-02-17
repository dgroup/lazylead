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

require "json"
require "faraday"
require_relative "../system/jira"
require_relative "../log"
require_relative "../opts"
require_relative "../confluence"

module Lazylead
  module Task
    # The lazylead task which adds reference to Confluence page
    #  in case if Confluence page was mentioned in issue comments.
    # @todo #/DEV Support sub-task for link search. Potentially, the issue
    #  might have sub-tasks where discussion ongoing.
    class ConfluenceRef
      def initialize(log = Log.new)
        @log = log
      end

      def run(sys, _, opts)
        confluences = confluences(opts)
        return if confluences.empty?
        sys.issues(opts["jql"], opts.jira_defaults)
           .map { |i| Link.new(i, sys, confluences) }
           .each(&:fetch_links)
           .select(&:need_link?)
           .each(&:add_link)
      end

      def confluences(opts)
        return [] if opts.blank? "confluences"
        JSON.parse(opts["confluences"], object_class: OpenStruct)
            .map { |c| Confluence.new(c) }
      end
    end
  end
end
