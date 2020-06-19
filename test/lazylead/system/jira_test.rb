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
require_relative "../../../lib/lazylead/schedule"
require_relative "../../../lib/lazylead/cli/app"
require_relative "../../../lib/lazylead/system/jira"

module Lazylead
  class JiraTest < Lazylead::Test
    test "found issue by id" do
      assert_equal "DATAJDBC-480",
                   NoAuthJira.new("https://jira.spring.io")
                             .issues("key in ('DATAJDBC-480')")
                             .first
                             .key
    end

    test "found issue by jira (ORM)" do
      skip "No Jira credentials provided" unless env? "jsi_usr", "jsi_psw"
      CLI::App.new(Log::NOTHING, NoSchedule.new).run(
        home: ".",
        sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
        vcs4sql: "upgrades/sqlite",
        testdata: true
      )
      assert_equal "DATAJDBC-500",
                   ORM::Task.find(4)
                            .system
                            .connect
                            .issues("key in ('DATAJDBC-500')")
                            .first
                            .key,
                   "Id mismatch for https://jira.spring.io/browse/DATAJDBC-500"
    end

    test "group by assignee" do
      assert_equal 2,
                   NoAuthJira.new("https://jira.spring.io")
                             .issues("filter=16743")
                             .group_by(&:assignee)
                             .min_by { |a| a.first.id }
                             .length,
                   "Two issues found on remote Jira instance using filter"
    end

    test "issue reporter fetched successfully" do
      assert_equal "Mark Paluch",
                   NoAuthJira.new("https://jira.spring.io")
                             .issues("key in ('DATAJDBC-480')")
                             .first
                             .reporter
                             .name
    end

    test "issue url fetched successfully" do
      assert_equal "https://jira.spring.io/browse/DATAJDBC-480",
                   NoAuthJira.new("https://jira.spring.io")
                             .issues("key in ('DATAJDBC-480')")
                             .first
                             .url
    end

    test "issue history found" do
      greater_or_eq 8,
                    NoAuthJira.new("https://jira.spring.io")
                              .issues("key='DATAJDBC-480'", expand: "changelog")
                              .first
                              .history
                              .size
    end

    test "issue history not found" do
      assert_empty NoAuthJira.new("https://jira.spring.io")
                             .issues("key='DATAJDBC-480'")
                             .first
                             .history
    end

    test "2nd issue history item is correct" do
      assert_equal "396918",
                   NoAuthJira.new("https://jira.spring.io")
                             .issues("key='DATAJDBC-480'", expand: "changelog")
                             .first
                             .history[2]["id"]
    end

    test "issue has expected status" do
      assert_equal "Closed",
                   NoAuthJira.new("https://jira.spring.io")
                             .issues("key='DATAJDBC-480'")
                             .first
                             .status
    end
  end
end
