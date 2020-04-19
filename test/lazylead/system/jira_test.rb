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

require_relative "../../test"
require_relative "../../../lib/lazylead/model"
require_relative "../../../lib/lazylead/cli/app"
require_relative "../../../lib/lazylead/system/jira"

module Lazylead
  class JiraTest < Lazylead::Test
    # Build an instance of Jira client based on default parameters.
    def jira
      Lazylead::Jira.new(
        username: ENV["JIRA_USER"],
        password: ENV["JIRA_PASS"],
        site: "https://jira.spring.io",
        context_path: ""
      )
    end

    test "found issue by id" do
      assert_equal "DATAJDBC-480",
                   jira.issues("key in ('DATAJDBC-480')").first.id
    end

    #
    # @todo #/DEV Avoid hard-code of credentials. To be fixed later.
    #  For now in case if we need to check the code, we have to specify
    #  the required credentials within System.properties column in db.
    test "found issue by jira (ORM)" do
      skip "The test need personal credentials. Re-implementation is required"
      CLI::App.new(Log::NOTHING).run(
        home: ".",
        sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
        vcs4sql: "upgrades/sqlite",
        testdata: true
      )
      assert_equal 86_106,
                   ORM::Task.find(1)
                            .system
                            .connect
                            .issues("key in ('DATAJDBC-500')")
                            .first.id.to_i,
                   "Id mismatch for https://jira.spring.io/browse/DATAJDBC-500"
    end

    test "group by assignee" do
      assert_equal 2,
                   jira.issues("filter=16743")
                       .group_by(&:assignee)
                       .min_by { |a| a.first.id }
                       .length,
                   "Two issues found on remote Jira instance using filter"
    end

    test "issue reporter fetched successfully" do
      assert_equal "Mark Paluch",
                   jira.issues("key in ('DATAJDBC-480')").first.reporter.name
    end

    test "issue url fetched successfully" do
      assert_equal "https://jira.spring.io/browse/DATAJDBC-480",
                   jira.issues("key in ('DATAJDBC-480')").first.url
    end
  end
end
