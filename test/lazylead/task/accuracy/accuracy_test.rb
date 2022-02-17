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

require_relative "../../../test"
require_relative "../../../../lib/lazylead/smtp"
require_relative "../../../../lib/lazylead/task/accuracy/accuracy"
require_relative "../../../../lib/lazylead/opts"
require_relative "../../../../lib/lazylead/postman"
require_relative "../../../../lib/lazylead/cli/app"
require_relative "../../../../lib/lazylead/system/jira"

module Lazylead
  class AccuracyTest < Lazylead::Test
    test "detect affected build" do
      Lazylead::Smtp.new.enable
      Task::Accuracy.new.run(
        NoAuthJira.new("https://jira.spring.io"),
        Postman.new,
        Opts.new(
          "from" => "ll@fake.com",
          "to" => "lead@fake.com",
          "rules" => "Lazylead::AffectedBuild",
          "silent" => "true",
          "colors" => {
            "0" => "#FF4F33",
            "35" => "#FF9F33",
            "57" => "#19DD1E",
            "90" => "#0FA81A"
          }.to_json.to_s,
          "memes" => {
            "0-9.9" => "https://meme.com?id=awful1.gif,https://meme.com?id=awful2.gif",
            "70-89.9" => "https://meme.com?id=nice.gif",
            "90-100" => "https://meme.com?id=wow.gif"
          }.to_json.to_s,
          "docs" => "https://github.com/dgroup/lazylead/blob/master/.github/ISSUE_TEMPLATE/bug_report.md",
          "jql" => "key in (DATAJDBC-490, DATAJDBC-492, DATAJDBC-493)",
          "max_results" => 200,
          "subject" => "[LL] Raised tickets",
          "template" => "lib/messages/accuracy.erb"
        )
      )
      assert_email "[LL] Raised tickets",
                   "DATAJDBC-493", "0.5", "100%", "MyeongHyeonLee", "Deadlock occurs"
    end

    test "construct accuracy from orm" do
      CLI::App.new(Log.new, NoSchedule.new).run(
        home: ".",
        sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
        vcs4sql: "upgrades/sqlite",
        testdata: true
      )
      assert_kind_of Lazylead::Task::Accuracy,
                     ORM::Task.find(195).action.constantize.new
    end

    test "one ticket found" do
      Lazylead::Smtp.new.enable
      assert_equal 1,
                   Task::Accuracy.new.run(
                     NoAuthJira.new("https://jira.spring.io"),
                     Postman.new,
                     Opts.new(
                       "from" => "ll@fake.com",
                       "to" => "lead@fake.com",
                       "rules" => "Lazylead::AffectedBuild",
                       "silent" => "true",
                       "colors" => {
                         "0" => "#FF4F33",
                         "57" => "#19DD1E"
                       }.to_json.to_s,
                       "jql" => "key > DATAJDBC-490",
                       "limit" => "1",
                       "subject" => "[LL] Raised tickets",
                       "template" => "lib/messages/accuracy.erb"
                     )
                   )[:tickets].size
    end

    test "score is correct" do
      Lazylead::Smtp.new.enable
      Task::Accuracy.new.run(
        NoAuthJira.new("https://jira.spring.io"),
        Postman.new,
        Opts.new(
          "from" => "ll@fake.com",
          "to" => "lead@fake.com",
          "rules" => "Lazylead::Stacktrace,Lazylead::Testcase",
          "fields" => "attachment,description,reporter,priority,duedate,summary",
          "colors" => {
            "0" => "#FF4F33",
            "30" => "#FEC15E",
            "50" => "#19DD1E"
          }.to_json.to_s,
          "jql" => "key=DATAMONGO-1532",
          "silent" => "true",
          "subject" => "[LL] Check DATAMONGO-1532",
          "template" => "lib/messages/accuracy.erb"
        )
      )
      assert_email "[LL] Check DATAMONGO-1532",
                   "DATAMONGO-1532", "3", "42.86%"
    end
  end
end
