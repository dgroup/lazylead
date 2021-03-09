# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2021 Yurii Dubinka
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
require_relative "../../../lib/lazylead/opts"
require_relative "../../../lib/lazylead/postman"
require_relative "../../../lib/lazylead/task/savepoint"

module Lazylead
  class SavepointTest < Lazylead::Test
    test "send lazylead config as a mail attachment" do
      Smtp.new.enable
      ARGV[2] = "--sqlite"
      ARGV[3] = "readme.md"
      Task::Savepoint.new.run(
        [],
        Postman.new,
        Opts.new(
          "from" => "fake@email.com",
          "subject" => "[LL] Configuration backup",
          "template" => "lib/messages/savepoint.erb",
          "to" => "big.boss@example.com"
        )
      )
      assert_equal 'text/markdown; filename="readme.md"',
                   Mail::TestMailer.deliveries
                                   .find { |m| m.subject.eql? "[LL] Configuration backup" }
                                   .attachments.first.header.fields[0]
                                   .unparsed_value
    end
  end
end
