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
require_relative "../../../lib/lazylead/smtp"
require_relative "../../../lib/lazylead/log"
require_relative "../../../lib/lazylead/model"
require_relative "../../../lib/lazylead/cli/app"
require_relative "../../../lib/lazylead/system/jira"
require_relative "../../../lib/lazylead/task/notification"

module Lazylead
  class DuedateTest < Lazylead::Test
    # @todo #/DEV Print to logger the details about emails which were sent
    #  Mail::TestMailer.deliveries.each { |m| p m.html_part.body.raw_source }
    test "issues were fetched" do
      Smtp.new.enable
      Task::Notification.new.run(
        Jira.new(
          username: ENV["JIRA_USER"],
          password: ENV["JIRA_PASS"],
          site: "https://jira.spring.io",
          context_path: ""
        ),
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
      CLI::App.new(Log::NOTHING).run(
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
  end
end
