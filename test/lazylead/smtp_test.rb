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

require_relative "../test"
require_relative "../../lib/lazylead/smtp"
require_relative "../../lib/lazylead/allocated"

module Lazylead
  # @todo #43/DEV Minitest+integration test - define approach like maven profile
  #  for java-based applications.
  class SmtpTest < Lazylead::Test
    test "email has been sent to the fake server" do
      Smtp.new.enable
      Mail.deliver do
        from "mike@fake.com"
        to "tom@fake.com"
        subject "The fake!"
        body "Fake body"
      end
      assert_equal(1, Mail::TestMailer.deliveries.count { |m| m.subject.eql? "The fake!" })
    end

    # @todo #43/DEV email-related properties should be exported to the CI env
    test "email has been sent to the remote server" do
      skip "Not implemented yet" unless env? "LL_SMTP_HOST", "LL_SMTP_USER"
      Smtp.new(
        Log.new, NoSalt.new,
        smtp_host: ENV["LL_SMTP_HOST"],
        smtp_port: ENV["LL_SMTP_PORT"],
        smtp_user: ENV["LL_SMTP_USER"],
        smtp_pass: ENV["LL_SMTP_PASS"]
      ).enable
      Mail.deliver do
        from ENV["LL_SMTP_FROM"]
        to ENV["LL_SMTP_TO"]
        subject "Testing"
        body "Good, it works"
      end
    end
  end
end
