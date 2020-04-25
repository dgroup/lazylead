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
require_relative "../../lib/lazylead/exchange"
require_relative "../../lib/lazylead/system/jira"

module Lazylead
  class ExchangeTest < Lazylead::Test
    test "email notification to outlook exchange" do
      skip "No MS Exchange credentials provided" unless env? "EXCHANGE_URL",
                                                             "EXCHANGE_USER",
                                                             "EXCHANGE_PASS",
                                                             "EXCHANGE_TO"
      Exchange.new(
        "endpoint" => ENV["EXCHANGE_URL"],
        "user" => ENV["EXCHANGE_USER"],
        "password" => ENV["EXCHANGE_PASS"]
      ).send(
        to: ENV["EXCHANGE_TO"],
        binds: {
          tickets: NoAuthJira.new("https://jira.spring.io")
                             .issues("key = DATAJDBC-480")
        },
        "subject" => "[DD] PDTN!",
        "template" => "lib/messages/due_date_expired.erb"
      )
    end
  end
end
