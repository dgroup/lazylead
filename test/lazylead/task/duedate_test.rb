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
require_relative "../../../lib/lazylead/log"
require_relative "../../../lib/lazylead/smtp"
require_relative "../../../lib/lazylead/postman"
require_relative "../../../lib/lazylead/schedule"
require_relative "../../../lib/lazylead/model"
require_relative "../../../lib/lazylead/cli/app"
require_relative "../../../lib/lazylead/system/jira"
require_relative "../../../lib/lazylead/task/alert/alert"

module Lazylead
  class DuedateTest < Lazylead::Test
    # @todo #/DEV Print to logger the details about emails which were sent
    #  Mail::TestMailer.deliveries.each { |m| p m.html_part.body.raw_source }
    test "issues were fetched" do
      Smtp.new.enable
      Task::AssigneeAlert.new.run(
        NoAuthJira.new("https://jira.mongodb.org"),
        Postman.new,
        Opts.new(
          "from" => "fake@email.com",
          "sql" => "key in (JAVA-151,JAVA-469,JAVA-468,JAVA-500)",
          "subject" => "[DD] PDTN!",
          "template" => "lib/messages/due_date_expired.erb"
        )
      )
      greater_or_eq(1, Mail::TestMailer.deliveries.count { |m| m.subject.eql? "[DD] PDTN!" })
    end

    test "configuration properties merged successfully" do
      CLI::App.new(Log.new, NoSchedule.new).run(
        home: ".",
        sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
        vcs4sql: "upgrades/sqlite",
        testdata: true
      )

      assert_entries(
        {
          "sql" => "filter=100500",
          "subject" => "[DD] PDTN!",
          "from" => "basquad@fake.com",
          "template" => "lib/messages/due_date_expired.erb"
        },
        ORM::Task.find(2).props
      )
    end

    test "html msg has ticket details" do
      Smtp.new.enable
      Task::AssigneeAlert.new.run(
        NoAuthJira.new("https://jira.mongodb.org"),
        Postman.new,
        Opts.new(
          "from" => "fake@email.com",
          "sql" => "key=VSCODE-333",
          "subject" => "[DD] HMCHT!",
          "template" => "lib/messages/due_date_expired.erb"
        )
      )

      assert_email "[DD] HMCHT!",
                   "VSCODE-333", "2023-06-28", "Major - P3", "Rhys Howell", "Renew VSCODE automated publishing token"
    end

    test "send notification about bunch of tickets" do
      Smtp.new.enable
      Task::Alert.new.run(
        NoAuthJira.new("https://jira.mongodb.org"),
        Postman.new,
        Opts.new(
          "from" => "fake@email.com",
          "sql" => "key=DOCS-19",
          "subject" => "ALRT: Frozen",
          "template" => "lib/messages/due_date_expired.erb",
          "to" => "big.boss@example.com",
          "addressee" => "Boss"
        )
      )

      assert_email "ALRT: Frozen",
                   "Hi Boss", "DOCS-19", "2012-09-28", "Major - P3", "Michael Conigliaro", "MongoDB exit code reference"
    end

    test "cc got notification" do
      Smtp.new.enable
      Task::Alert.new.run(
        NoAuthJira.new("https://jira.mongodb.org"),
        Postman.new,
        Opts.new(
          "from" => "fake@email.com",
          "sql" => "key=JAVA-295",
          "subject" => "CC: Watching",
          "template" => "lib/messages/due_date_expired.erb",
          "to" => "big.boss@example.com",
          "addressee" => "Boss",
          "cc" => "another.boss@example.com,mom@home.com"
        )
      )

      assert_equal %w[another.boss@example.com mom@home.com],
                   Mail::TestMailer.deliveries
                                   .find { |m| m.subject.eql? "CC: Watching" }.cc
    end

    test "reporter got alert about his/her tickets with expired DD" do
      Smtp.new.enable
      Task::ReporterAlert.new.run(
        NoAuthJira.new("https://jira.mongodb.org"),
        Postman.new,
        Opts.new(
          "from" => "fake@email.com",
          "sql" => "key in (JAVA-151,JAVA-469,JAVA-468,JAVA-500)",
          "subject" => "DD Expired!",
          "template" => "lib/messages/due_date_expired.erb"
        )
      )

      assert_equal(2, Mail::TestMailer.deliveries.count { |m| m.subject.eql? "DD Expired!" })
    end
  end
end
