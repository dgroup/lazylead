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

require_relative "../../test"
require_relative "../../../lib/lazylead/model"
require_relative "../../../lib/lazylead/schedule"
require_relative "../../../lib/lazylead/cli/app"
require_relative "../../../lib/lazylead/system/jira"

module Lazylead
  class JiraTest < Lazylead::Test
    test "found issue by id" do
      assert_equal "JAVA-150",
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key in ('JAVA-150')")
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

      assert_equal "JAVA-150",
                   ORM::Task.find(4)
                            .system
                            .connect
                            .issues("key in ('JAVA-150')")
                            .first
                            .key,
                   "Id mismatch for https://jira.mongodb.org/browse/JAVA-150"
    end

    test "group by assignee" do
      assert_equal 2,
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("filter=46202")
                             .group_by(&:assignee)
                             .min_by { |a| a.first.id }
                             .length,
                   "Two issues found on remote Jira instance using filter"
    end

    test "issue reporter fetched successfully" do
      assert_equal "Joseph Wang",
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key in ('JAVA-150')")
                             .first
                             .reporter
                             .name
    end

    test "issue url fetched successfully" do
      assert_equal "https://jira.mongodb.org/browse/JAVA-150",
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key in ('JAVA-150')")
                             .first
                             .url
    end

    test "issue history found" do
      greater_or_eq 10,
                    NoAuthJira.new("https://jira.mongodb.org")
                              .issues("key='JAVA-150'", expand: "changelog")
                              .first
                              .history
                              .size
    end

    test "issue history not found" do
      assert_empty NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key='JAVA-150'")
                             .first
                             .history
    end

    test "2nd issue history item is correct" do
      assert_equal "24893",
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key='JAVA-150'", expand: "changelog")
                             .first
                             .history[2]["id"]
    end

    test "issue has expected status" do
      assert_equal "Closed",
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key='JAVA-150'")
                             .first
                             .status
    end

    test "issue has 1 field" do
      assert_equal 1,
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key='JAVA-150'", fields: ["summary"])
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
      assert_words ["We've multiple colos"],
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key=JAVA-150")
                             .first
                             .description
    end

    test "component is correct" do
      assert_equal ["GridFS"],
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key=JAVA-192")
                             .first
                             .components
    end

    test "description available as field" do
      assert_includes NoAuthJira.new("https://jira.mongodb.org")
                                .issues("key=JAVA-192")
                                .first["description"],
                      ".files.drop() + .chunks.drop()"
    end

    test "field not found" do
      assert_predicate NoAuthJira.new("https://jira.mongodb.org")
                                 .issues("key=JAVA-150")
                                 .first["absent field"], :blank?
    end

    test "labels found" do
      assert_includes NoAuthJira.new("https://jira.mongodb.org")
                                .issues("key=JAVA-295")
                                .first
                                .labels,
                      "android"
    end

    test "bulk search in few iterations" do
      assert_equal 3,
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key>JAVA-150 and key < JAVA-154", max_results: 1)
                             .size
    end

    test "connected based on string properties" do
      refute_empty Jira.new(
        "username" => nil,
        "password" => nil,
        "site" => "https://jira.mongodb.org",
        "context_path" => ""
      ).issues("key=JAVA-150")
    end

    test "sprint is found" do
      assert_equal "Java Sprint 25",
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key=JAVA-192", fields: ["customfield_10557"])
                             .first
                             .sprint("customfield_10557")
    end

    test "bulk search in few iterations with limit" do
      assert_equal 3,
                   NoAuthJira.new("https://jira.mongodb.org")
                             .issues("key > JAVA-150", max_results: 1, "limit" => 3)
                             .size
    end
  end
end
