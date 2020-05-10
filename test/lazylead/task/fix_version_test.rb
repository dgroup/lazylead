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

require "mail"

require_relative "../../test"
require_relative "../../../lib/lazylead/smtp"
require_relative "../../../lib/lazylead/postman"
require_relative "../../../lib/lazylead/task/fix_version"

module Lazylead
  class FixVersionTest < Lazylead::Test
    test "alert in case fixvesion changed by not authorized person" do
      Lazylead::Smtp.new.enable
      Task::FixVersion.new.run(
        NoAuthJira.new("https://jira.spring.io"),
        Postman.new,
        "to" => "lead@company.com",
        "from" => "ll@company.com",
        "jql" => "key in ('DATAJDBC-480') and fixVersion is not empty",
        "allowed" => "tom,mike,bob",
        "subject" => "FixVersion: How dare you?",
        "template" => "lib/messages/illegal_fixversion_change.erb"
      )
      assert_words %w[DATAJDBC-480 01-Apr-2020 Minor Mark\ Paluch tom,mike,bob EntityInstantiators],
                   Mail::TestMailer.deliveries
                                   .filter { |m| m.subject.eql? "FixVersion: How dare you?" }
                                   .first.body.parts.first.body
    end
  end
end
