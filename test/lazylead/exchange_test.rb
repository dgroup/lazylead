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
require_relative "../../lib/lazylead/log"
require_relative "../../lib/lazylead/salt"
require_relative "../../lib/lazylead/home"
require_relative "../../lib/lazylead/exchange"
require_relative "../../lib/lazylead/system/jira"

module Lazylead
  class ExchangeTest < Lazylead::Test
    test "email notification to outlook exchange" do
      skip "No MS Exchange credentials provided" unless env? "exchange_url",
                                                             "exchange_user",
                                                             "exchange_password",
                                                             "exchange_to"
      Exchange.new(Log.new, NoSalt.new).send(
        to: ENV["exchange_to"],
        tickets: NoAuthJira.new("https://jira.spring.io")
                           .issues("key = DATAJDBC-480"),
        "subject" => "[DD] PDTN!",
        "template" => "lib/messages/due_date_expired.erb"
      )
    end

    test "exchange email notification using decrypted credentials" do
      skip "No cryptography salt provided" unless env? "exchange_salt"
      skip "No MS Exchange credentials provided" unless env? "exchange_url",
                                                             "enc_exchange_usr",
                                                             "enc_exchange_psw",
                                                             "enc_exchange_to"
      Exchange.new(
        Log.new,
        Salt.new("exchange_salt"),
        "exchange_url" => ENV["exchange_url"],
        "exchange_user" => ENV["enc_exchange_usr"],
        "exchange_password" => ENV["enc_exchange_psw"]
      ).send(
        to: ENV["exchange_to"],
        tickets: NoAuthJira.new("https://jira.spring.io")
                           .issues("key = DATAJDBC-480"),
        "subject" => "[DD] Enc PDTN!",
        "template" => "lib/messages/due_date_expired.erb"
      )
    end

    test "exchange email with attachment" do
      skip "No MS Exchange credentials provided" unless env? "exchange_url",
                                                             "exchange_user",
                                                             "exchange_password",
                                                             "exchange_to"
      Exchange.new(
        Log.new,
        Salt.new("exchange_salt"),
        "exchange_url" => ENV["exchange_url"],
        "exchange_user" => ENV["enc_exchange_usr"],
        "exchange_password" => ENV["enc_exchange_psw"]
      ).send(
        to: ENV["exchange_to"],
        "attachments" => "readme.md",
        "subject" => "[LL] Attachments",
        "template" => "lib/messages/savepoint.erb"
      )
    end
  end
end
