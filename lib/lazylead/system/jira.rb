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
require_relative "../salt"

module Lazylead
  # Jira system for manipulation with issues.
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Jira
    def initialize(opts, salt = NoSalt.new)
      @opts = opts
      @salt = salt
    end

    def issues(jql)
      client.Issue.jql(jql).map { |i| Lazylead::Issue.new(i) }
    end

    private

    def client
      return @client if defined? @client
      @opts[:auth_type] = :basic if @opts[:auth_type].nil?
      cp("site", :site)
      cp("username", :username)
      cp("password", :password)
      cp("context_path", :context_path)
      @opts["username"] = @salt.decrypt(@opts["username"]) if @salt.specified?
      @opts["password"] = @salt.decrypt(@opts["password"]) if @salt.specified?
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
      id.to_s
    end

    def inspect
      to_s
    end
  end

  #
  # An issue from Jira
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Issue
    def initialize(issue)
      @issue = issue
    end

    def id
      @issue.key
    end

    def summary
      fields["summary"]
    end

    def url
      @issue.attrs["self"].split("/rest/api/").first + "/browse/" + id
    end

    # @todo #/DEV Due date implementation is required based on custom field
    def duedate
      Date.today
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
      @issue.fields
    end

    def to_s
      "#{id} #{summary}"
    end

    def inspect
      to_s
    end
  end
end
