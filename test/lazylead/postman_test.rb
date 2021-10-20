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

require_relative "../test"
require_relative "../../lib/lazylead/log"
require_relative "../../lib/lazylead/opts"
require_relative "../../lib/lazylead/salt"
require_relative "../../lib/lazylead/smtp"
require_relative "../../lib/lazylead/postman"

module Lazylead
  class PostmanTest < Lazylead::Test
    test "email with attachment" do
      skip "No postman credentials provided" unless env? "LL_SMTP_HOST",
                                                         "LL_SMTP_PORT",
                                                         "LL_SMTP_USER",
                                                         "LL_SMTP_PASS",
                                                         "LL_SMTP_TO",
                                                         "LL_SMTP_FROM"
      Smtp.new(
        Log.new,
        NoSalt.new,
        smtp_host: ENV["LL_SMTP_HOST"],
        smtp_port: ENV["LL_SMTP_PORT"],
        smtp_user: ENV["LL_SMTP_USER"],
        smtp_pass: ENV["LL_SMTP_PASS"]
      ).enable
      Postman.new.send(
        Opts.new(
          "to" => ENV["LL_SMTP_TO"],
          "from" => ENV["LL_SMTP_FROM"],
          "attachments" => ["readme.md"],
          "subject" => "[LL] Attachments",
          "template" => "lib/messages/savepoint.erb"
        )
      )
    end
  end

  class StdoutPostmanTest < Lazylead::Test
    # @todo #495/DEV Find way to capture the STDOUT in order to test the email sending.
    #  Right now its just visual verification.
    test "send email to stdout" do
      StdoutPostman.new.send(
        Opts.new(
          "to" => "to@email.com",
          "from" => "from@email.com",
          "attachments" => ["readme.md"],
          "subject" => "[LL] Attachments",
          "template" => "lib/messages/savepoint.erb"
        )
      )
    end
  end

  class FilePostmanTest < Lazylead::Test
    test "send email to html file" do
      assert_path_exists FilePostman.new(Log.new, "file_postman_dir" => "test/resources")
                                    .send(
                                      Opts.new(
                                        "to" => "to@email.com",
                                        "from" => "from@email.com",
                                        "attachments" => ["readme.md"],
                                        "subject" => "[LL] Attachments",
                                        "template" => "lib/messages/savepoint.erb"
                                      )
                                    )
    end
  end
end
