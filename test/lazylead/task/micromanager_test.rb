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

require "mail"

require_relative "../../test"
require_relative "../../../lib/lazylead/smtp"
require_relative "../../../lib/lazylead/opts"
require_relative "../../../lib/lazylead/postman"
require_relative "../../../lib/lazylead/task/micromanager"

module Lazylead
  class MicromanagerTest < Lazylead::Test
    test "alert in case duedate changed by not authorized person" do
      Lazylead::Smtp.new.enable
      Task::Micromanager.new.run(
        NoAuthJira.new("https://jira.mongodb.org"),
        Postman.new,
        Opts.new(
          "to" => "lead@company.com",
          "from" => "ll@company.com",
          "jql" => "duedate is not EMPTY and key in (DOCS-194, DOCS-144, DOCS-143)",
          "fields" => "assignee,duedate,priority,created,summary,reporter",
          "allowed" => "matulef,mike,bob",
          "period" => "86400",
          "now" => "2009-12-10T00:04:00.000+0000",
          "subject" => "DD: How dare you?",
          "template" => "lib/messages/illegal_duedate_change.erb"
        )
      )
      assert_email "DD: How dare you?",
                   "DOCS-144", "Major - P3", "2012-03-01", "New Documentation Review: Glossary", "matulef,mike,bob"
    end

    test "since for past 1 min" do
      greater_or_eq Task::Micromanager.new.since("period" => 60).to_i,
                    (Time.now - 60).to_i
    end
  end
end
