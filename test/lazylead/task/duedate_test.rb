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
require_relative "../../../lib/lazylead/log"
require_relative "../../../lib/lazylead/smtp"
require_relative "../../../lib/lazylead/postman"
require_relative "../../../lib/lazylead/schedule"
require_relative "../../../lib/lazylead/model"
require_relative "../../../lib/lazylead/cli/app"
require_relative "../../../lib/lazylead/system/jira"
require_relative "../../../lib/lazylead/task/alert"

module Lazylead
  class DuedateTest < Lazylead::Test
    # @todo #/DEV Print to logger the details about emails which were sent
    #  Mail::TestMailer.deliveries.each { |m| p m.html_part.body.raw_source }
    test "issues were fetched" do
      Smtp.new.enable
      Task::AssigneeAlert.new.run(
        NoAuthJira.new("https://jira.spring.io"),
        Postman.new,
        "from" => "fake@email.com",
        "sql" => "filter=16743",
        "subject" => "[DD] PDTN!",
        "template" => "lib/messages/due_date_expired.erb"
      )
      assert_equal 2,
                   Mail::TestMailer.deliveries
                                   .filter { |m| m.subject.eql? "[DD] PDTN!" }
                                   .length
    end

    test "configuration properties merged successfully" do
      CLI::App.new(Log::NOTHING, NoSchedule.new).run(
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
        NoAuthJira.new("https://jira.spring.io"),
        Postman.new,
        "from" => "fake@email.com",
        "sql" => "key in ('STS-3599')",
        "subject" => "[DD] HMCHT!",
        "template" => "lib/messages/due_date_expired.erb"
      )
      assert_email "[DD] HMCHT!",
                   %w[STS-3599 2013-11-08 Major Miles\ Parker Use JavaFX WebView]
    end

    test "send notification about bunch of tickets" do
      Smtp.new.enable
      Task::Alert.new.run(
        NoAuthJira.new("https://jira.spring.io"),
        Postman.new,
        "from" => "fake@email.com",
        "sql" => "key in ('STS-3599')",
        "subject" => "ALRT: Frozen",
        "template" => "lib/messages/due_date_expired.erb",
        "to" => "big.boss@example.com",
        "addressee" => "Boss"
      )
      assert_email "ALRT: Frozen",
                   %w[Hi Boss STS-3599 2013-11-08 Major Miles\ Parker Use JavaFX WebView]
    end

    test "cc got notification" do
      Smtp.new.enable
      Task::Alert.new.run(
        NoAuthJira.new("https://jira.spring.io"),
        Postman.new,
        "from" => "fake@email.com",
        "sql" => "key in ('STS-3599')",
        "subject" => "CC: Watching",
        "template" => "lib/messages/due_date_expired.erb",
        "to" => "big.boss@example.com",
        "addressee" => "Boss",
        "cc" => "another.boss@example.com,mom@home.com"
      )
      assert_equal %w[another.boss@example.com mom@home.com],
                   Mail::TestMailer.deliveries
                                   .filter { |m| m.subject.eql? "CC: Watching" }
                                   .first.cc
    end
  end
end
