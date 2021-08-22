# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2021 Yurii Dubinka
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
      CLI::App.new(Log.new, NoSchedule.new).run(
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

    test "issue has 1 field" do
      assert_equal 1,
                   NoAuthJira.new("https://jira.spring.io")
                             .issues("key='DATAJDBC-480'", fields: ["summary"])
                             .first
                             .fields
                             .size
    end

    test "make an jira comment" do
      issue = Struct.new(:comment) do
        def comments
          self
        end

        def build
          self
        end

        def save!(body)
          self[:comment] = body
        end
      end.new
      Issue.new(issue, Fake.new).post("Hi there!")
      assert_equal "Hi there!", issue.comment[:body]
    end

    test "description is correct" do
      assert_words ["DATACMNS-1639 moved entity instantiators"],
                   NoAuthJira.new("https://jira.spring.io")
                             .issues("key=DATAJDBC-480")
                             .first
                             .description
    end

    test "component is correct" do
      assert_equal ["Stream Module"],
                   NoAuthJira.new("https://jira.spring.io")
                             .issues("key=XD-3766")
                             .first
                             .components
    end

    test "field found" do
      assert_includes NoAuthJira.new("https://jira.spring.io")
                                .issues("key=DATAJDBC-480")
                                .first["description"],
                      "DATACMNS-1639 moved "
    end

    test "field not found" do
      assert NoAuthJira.new("https://jira.spring.io")
                       .issues("key=DATAJDBC-480")
                       .first["absent field"]
                       .blank?
    end

    test "labels found" do
      assert_includes NoAuthJira.new("https://jira.spring.io")
                                .issues("key=XD-3766")
                                .first
                                .labels,
                      "Spring"
    end

    # @todo #/DEV The test took too much time and should be limited by 3 tickets per transaction.
    #  Use option :max_results to limit each iteration.
    #  The JQL query should be like "key>DATAJDBC-500 and key<DATAJDBC-510"
    test "bulk search in few iterations" do
      assert NoAuthJira.new("https://jira.spring.io")
                       .issues("key>DATAJDBC-500")
                       .size >= 118
    end

    test "connected based on string properties" do
      refute_empty Jira.new(
        "username" => nil,
        "password" => nil,
        "site" => "https://jira.spring.io",
        "context_path" => ""
      ).issues("key=DATAJDBC-480")
    end

    test "sprint is found" do
      assert_equal "Sprint 68",
                   NoAuthJira.new("https://jira.spring.io")
                             .issues("key=XD-3744", fields: ["customfield_10480"])
                             .first
                             .sprint("customfield_10480")
    end
  end
end
