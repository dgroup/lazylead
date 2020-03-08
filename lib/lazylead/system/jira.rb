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
      client.Issue.jql(jql)
    end

    # @todo #/DEV Group by function the issues found by jql
    def group_by(fnc, jql)
      raise "unsupported operation for #{fnc} and #{jql}"
    end

    # @todo #/DEV Group by assignee the issues found by jql
    def group_by_assignee(jql)
      raise "unsupported operation for #{jql}"
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
      mv("site", :site)
      mv("username", :username)
      mv("password", :password)
      mv("context_path", :context_path)
      @client = JIRA::Client.new(@opts)
    end

    # Move the values for non-string variables.
    def mv(act, exp)
      return if @opts[act].nil?

      @opts[exp] = @opts[act]
      @opts.delete act
    end
  end
end
