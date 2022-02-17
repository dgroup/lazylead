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

require "faraday"
require "jira-ruby"

module Lazylead
  # Represents single Confluence instance.
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Confluence
    def initialize(conf)
      @conf = conf
      @http = Faraday.new(url: @conf.url) do |conn|
        conn.request :authorization, :basic, @conf.user, @conf.pass
      end
    end

    # Confluence instance url like
    #  http://confluence.com
    #  https://confluence.com
    def url
      @conf.url
    end

    # Construct the remote link from Jira ticket to Confluence page.
    # Read more:
    #  - https://bit.ly/2zkfTwB
    #  - https://bit.ly/2zk8iOB
    #  - https://bit.ly/3bkGkiU
    def make_link(url, type = "Wiki Page")
      {
        globalId: "appId=#{@conf.app}&pageId=#{url[/pageId=(?<id>\d+)/, 1]}",
        application: { type: @conf.type, name: @conf.name },
        relationship: type,
        object: { url: url, title: type }
      }
    end

    # Fetch the page url with pageId (Atlassian global id)
    #  using confluence space name and page title.
    #
    # @return url with following format
    #  http://host/pages/viewpage.action?pageId=xxxxx or blank string in case of
    #  errors
    #
    # @todo #/DEV Unable to find confluence pages where title has ":" symbol.
    #  The symbol ":" might be replaced by "%3A". The search needs to consider
    #  this case as well.
    def fetch_page_id(space, title)
      resp = @http.get(
        "/rest/api/content", limit: 1, spaceKey: space, title: title
      ).body
      return "" if resp.blank?
      pages = JSON.parse(resp)
      return "" if pages["results"].empty?
      "#{@conf.url}/pages/viewpage.action?pageId=#{pages['results'].first['id']}"
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
      @confl = cnfl
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
    # @todo #/DEV Refactor this method in order to make it more human-readable and remove the
    #  suppresion below
    #
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def mentioned_links(ticket)
      ticket.comments
            .map { |cmnt| cmnt.attrs["body"] }
            .select { |cmnt| @confl.any? { |c| cmnt.include? c.url } }
            .flat_map(&:split)
            .select { |cmnt| @confl.any? { |c| cmnt.start_with? c.url } }
            .map { |url| to_page_id(url) }
            .reject(&:blank?)
            .uniq
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    # Convert confluence page url to the following format:
    #  http://confluence.com/pages/viewpage.action?pageId=xxxxx
    #
    # Sometimes links to confluence pages have the following formats:
    #  http://confluence.com/pages/spaceKey=THESPACE&title=THETITLE
    #  http://confluence.com/display/THESPACE/THETITLE
    # and can't be linked though the "remote link" Jira functionality.
    def to_page_id(url)
      return url if url.include? "pageId="
      if url.include? "&title="
        space = url[/spaceKey=(?<space>[A-Z0-9+.]+)/, 1]
        title = url[/&title=(?<title>[A-Za-z0-9+.]+)/, 1]
      else
        space, title = url.split("/").last(2)
      end
      @confl.find { |c| url.start_with? c.url }
            .fetch_page_id(space, title.tr("+", " "))
    end

    # Detect existing links from the ticket
    def existing_links(ticket, type = "Wiki Page")
      ticket.remotelink
            .all
            .select { |l| l.attrs["relationship"] == type }
            .map { |e| e.attrs["object"]["url"] }
    end

    def need_link?
      !@diff.empty?
    end

    # Add reference to Confluence page from current issue
    def add_link
      @diff.each do |url|
        cnf = @confl.find { |c| url.start_with? c.url }
        @issue.remotelink.build.save cnf.make_link(url)
      end
    end
  end
end
