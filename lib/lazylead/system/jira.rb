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

module Lazylead
  # Jira system for manipulation with issues.
  class Jira
    def initialize(opts)
      @opts = opts
    end

    def issues(jql)
      client.Issue.jql(jql).map { |i| Lazylead::Issue.new(i) }
    end

    # @todo #/DEV Group by function the issues found by jql
    def group_by(fnc, jql)
      raise "unsupported operation for #{fnc} and #{jql}"
    end

    def group_by_assignee(jql)
      issues = issues(jql)
      assigned = issues.group_by { |i| i.assignee.id }
      assignee = issues.map(&:assignee)
                       .uniq(&:id)
                       .group_by(&:id)
      target = {}
      assigned.each do |id, i|
        target[assignee[id].first] = i
      end
      target
    end

    # @todo #/DEV Filter the issues found by jql on app side.
    #  Required for cases when filtration can't be done on jira side.
    def filtered(fnc, jql)
      raise "unsupported operation for #{fnc} and #{jql}"
    end

    private

    def client
      return @client if defined? @client

      @opts[:auth_type] = :basic if @opts[:auth_type].nil?
      cp("site", :site)
      cp("username", :username)
      cp("password", :password)
      cp("context_path", :context_path)
      @client = JIRA::Client.new(@opts)
    end

    # Copy the required/mandatory parameter(s) for Jira client which can't
    #  be specified/defined at database level.
    def cp(act, exp)
      @opts[exp] = @opts[act] if @opts.key? act
    end
  end

  #
  # An issue assignee from Jira
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Assignee
    def initialize(usr)
      @usr = usr
    end

    def id
      @usr.name
    end

    def name
      @usr.attrs["displayName"]
    end

    def email
      @usr.attrs["emailAddress"]
    end

    def ==(other)
      eql? other
    end

    def ===(other)
      eql? other
    end

    def eql?(other)
      equal? other
    end

    def equal?(other)
      id == other.id
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
      @issue.id
    end

    def summary
      fields["summary"]
    end

    def assignee
      Lazylead::Assignee.new(@issue.assignee)
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
