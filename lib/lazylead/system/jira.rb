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

require "jira-ruby"
require "forwardable"
require_relative "../salt"

module Lazylead
  # Jira system for manipulation with issues.
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Jira
    # @todo #57/DEV The debug method should be moved outside of ctor.
    #  This was moved here from 'client' method because Rubocop failed the build
    #  due to 'Metrics/AbcSize' violation.
    def initialize(opts, salt = NoSalt.new, log = Log.new)
      @opts = opts
      @salt = salt
      @log = log
      @log.debug "Initiate a Jira client using following opts: " \
                 "#{@opts.except 'password', :password} " \
                 " and salt #{@salt.id} (found=#{@salt.specified?})"
    end

    def issues(jql, opts = {})
      raw do |jira|
        jira.Issue.jql(jql, opts).map { |i| Lazylead::Issue.new(i, jira) }
      end
    end

    # Execute request to the ticketing system using raw client.
    # For Jira the raw client is 'jira-ruby' gem.
    def raw
      raise "ll-06: No block given to method" unless block_given?
      yield client
    end

    private

    def client
      return @client if defined? @client
      @opts[:auth_type] = :basic if @opts[:auth_type].nil?
      @opts["username"] = @salt.decrypt(@opts["username"]) if @salt.specified?
      @opts["password"] = @salt.decrypt(@opts["password"]) if @salt.specified?
      cp("site", :site)
      cp("username", :username)
      cp("password", :password)
      cp("context_path", :context_path)
      @client = JIRA::Client.new(@opts)
    end

    # Copy the required/mandatory parameter(s) for Jira client which can't
    #  be specified/defined at database level.
    #
    # @todo #/DEV Jira.cp - find a way how to avoid this method.
    #  Potentially, hash with indifferent access might be used.
    #  http://jocellyn.cz/2014/05/03/hash-with-indifferent-access.html
    #  key.kind_of?(Symbol) ? key.to_s : key
    def cp(act, exp)
      @opts[exp] = @opts[act] if @opts.key? act
    end
  end

  #
  # An user from Jira which might be reporter, assignee, etc.
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class User
    def initialize(usr)
      @usr = usr
    end

    def id
      @usr["name"]
    end

    def name
      @usr["displayName"]
    end

    def email
      @usr["emailAddress"]
    end

    def ==(other)
      if other.respond_to?(:id)
        other.id == id
      else
        false
      end
    end

    alias eql? ==

    def hash
      id.hash
    end

    def to_s
      inspect
    end

    def inspect
      "#{@opts['site']} (#{@opts['username']})"
    end
  end

  #
  # An issue from Jira
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Issue
    def initialize(issue, jira)
      @issue = issue
      @jira = jira
    end

    def id
      @issue.id
    end

    def key
      @issue.key
    end

    def description
      return "" if @issue.description.nil?
      @issue.description
    end

    def summary
      fields["summary"]
    end

    def url
      @issue.attrs["self"].split("/rest/api/").first + "/browse/" + key
    end

    def duedate
      @issue.fields["duedate"]
    end

    def priority
      fields["priority"]["name"]
    end

    def reporter
      Lazylead::User.new(fields["reporter"])
    end

    def assignee
      Lazylead::User.new(@issue.assignee.attrs)
    end

    def fields
      return {} if @issue.nil?
      return {} unless @issue.respond_to? :fields
      return {} if @issue.fields.nil?
      return {} unless @issue.fields.respond_to? :[]
      @issue.fields
    end

    def [](name)
      return "" if fields[name].nil? || fields[name].blank?
      fields[name]
    end

    def components
      return [] unless @issue.respond_to? :components
      return [] if @issue.components.nil?
      @issue.components.map(&:name)
    end

    def history
      return [] unless @issue.respond_to? :changelog
      return [] if @issue.changelog == nil? || @issue.changelog.empty?
      @issue.changelog["histories"]
    end

    def comments
      return @comments if defined? @comments
      @comments = @jira.Issue.find(@issue.id, expand: "comments", fields: "")
                       .comments
                       .map { |c| Comment.new(c) }
    end

    def to_s
      "#{key} #{summary}"
    end

    def inspect
      to_s
    end

    def status
      @issue.status.attrs["name"]
    end

    def post(markdown)
      @issue.comments.build.save!(body: markdown)
    end
  end

  # The jira issue comments
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Comments
    attr_reader :issue

    def initialize(issue, sys)
      @issue = issue
      @sys = sys
    end

    def body?(text)
      comments.any? { |c| c.attrs["body"].include? text }
    end

    def comments
      @comments ||= @sys.raw do |conn|
        conn.Issue.find(@issue.id, expand: "comments,changelog", fields: "")
            .comments
      end
    end

    def last(quantity)
      comments.last(quantity).map { |c| c.attrs["body"] }
    end
  end

  # Comment in jira ticket
  class Comment
    def initialize(comment)
      @comment = comment
    end

    # Check that comment has expected text
    def include?(text)
      @comment.attrs["body"].include? text
    end
  end

  # Jira instance without authentication in order to access public filters
  #  or dashboards.
  class NoAuthJira
    extend Forwardable
    def_delegators :@jira, :issues, :raw

    def initialize(url, path = "", log = Log.new)
      @jira = Jira.new(
        {
          username: nil,
          password: nil,
          site: url,
          context_path: path
        },
        NoSalt.new,
        log
      )
    end
  end

  # A fake jira system which allows to work with sub-tasks.
  class Fake
    def initialize(issues)
      @issues = issues
    end

    def issues(*)
      @issues
    end

    # Execute request to the ticketing system using raw client.
    def raw
      raise "ll-08: No block given to method" unless block_given?
      yield(OpenStruct.new(Issue: self))
    end

    def find(id)
      @issues.detect { |i| i.id.eql? id }
    end
  end
end
