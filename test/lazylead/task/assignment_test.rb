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
require_relative "../../../lib/lazylead/task/assignment"

module Lazylead
  class AssignmentTest < Lazylead::Test
    test "alert in case assignee changed by not authorized person" do
      Lazylead::Smtp.new.enable
      Task::Assignment.new.run(
        NoAuthJira.new("https://jira.spring.io"),
        Postman.new,
        Opts.new(
          "to" => "lead@company.com",
          "from" => "ll@company.com",
          "jql" => "key in ('DATAJDBC-480') and assignee is not empty",
          "allowed" => "tom,mike,bob",
          "subject" => "Assignment: How dare you?",
          "template" => "lib/messages/illegal_assignee_change.erb"
        )
      )
      assert_email "Assignment: How dare you?",
                   "DATAJDBC-480", "01-Apr", "Minor", "Mark Paluch", "tom,mike,bob",
                   "EntityInstantiators"
    end
  end
end
