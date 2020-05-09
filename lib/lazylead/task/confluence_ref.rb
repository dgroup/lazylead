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

require "json"
require_relative "../system/jira"
require_relative "../log"

module Lazylead
  module Task
    #
    # The lazylead task which adds reference to Confluence
    #  in case if Confluence page was mentioned in comments.
    # @todo #/DEV Support sub-task for link search. Potentially, the issue
    #  might have sub-tasks where discussion ongoing.
    class ConfluenceRef
      def initialize(log = Log::NOTHING)
        @log = log
      end

      def run(sys, _, opts)
        conf = confluences(opts)
        return if conf.empty?
        sys.issues(opts["jql"])
           .map { |i| Link.new(i, sys, conf) }
           .each(&:fetch_links)
           .select(&:need_link)
           .each(&:add_link)
      end

      def confluences(opts)
        return [] if opts["confluences"].nil? || opts["confluences"].blank?
        JSON.parse(opts["confluences"], object_class: OpenStruct)
      end
    end

    # The reference from Jira issue to Confluence system.
    class Link
      # :issue  :: The issue from external system
      # :sys    :: The jira ticketing system
      # :cnfl   :: The Confluence instances details (host, appId)
      #            which expected within the comments
      def initialize(issue, sys, cnfl)
        @issue = issue
        @sys = sys
        @cnfl = cnfl
      end

      # Fetch ticket links from comments
      def fetch_links
        ticket = @sys.raw do |conn|
          conn.Issue.find(@issue.id, expand: "comments,changelog", fields: "")
        end
        @mentioned = mentioned_links(ticket)
        @existing = existing_links(ticket)
        @diff = @mentioned.reject { |url| @existing.include? url }
      end

      # Detect links mentioned in ticket comments
      # @todo #/DEV Detect pageId in case if page was mentioned in comments
      #  using spacename+pagename.
      def mentioned_links(ticket)
        ticket.comments
              .map { |c| c.attrs["body"] }
              .select { |c| @cnfl.any? { |h| c.include? h.url } }
              .flat_map { |c| c.split " " }
              .select { |c| @cnfl.any? { |h| c.start_with? h.url } }
              .select { |c| c.include? "pageId=" }
      end

      # Detect existing links from the ticket
      def existing_links(ticket, type = "Wiki Page")
        ticket.remotelink
              .all
              .select { |l| l.attrs["relationship"] == type }
              .map { |e| e.attrs["object"]["url"] }
      end

      def need_link
        !@diff.empty?
      end

      # Add reference to Confluence page from current issue
      def add_link(type = "Wiki Page")
        @diff.each do |url|
          cnf = @cnfl.find { |c| url.start_with? c.url }
          @issue.add_link(
            globalId: "appId=#{cnf.app}&pageId=#{url[/pageId=(?<id>\d+)/, 1]}",
            application: { type: cnf.type, name: cnf.name },
            relationship: type,
            object: { url: url, title: type }
          )
        end
      end
    end
  end
end
