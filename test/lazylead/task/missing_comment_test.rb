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
require_relative "../../../lib/lazylead/postman"
require_relative "../../../lib/lazylead/system/jira"
require_relative "../../../lib/lazylead/task/missing_comment"

module Lazylead
  class MissingCommentTest < Lazylead::Test
    test "alert in case missing comment" do
      Lazylead::Smtp.new.enable
      Task::MissingComment.new.run(
        NoAuthJira.new("https://jira.mongodb.org"),
        Postman.new,
        Opts.new(
          "to" => "lead@company.com",
          "addressee" => "Tom",
          "from" => "ll@company.com",
          "jql" => "key=JAVA-65",
          "text" => "ftp.com/demo.avi",
          "details" => "reference to <code>ftp.com/demo.avi</code>",
          "subject" => "Expected ftp link is missing",
          "template" => "lib/messages/missing_comment.erb",
          "template_details" => "reference to <a href='file://ftp/path'>ftp</a>"
        )
      )

      assert_email "Expected ftp link is missing",
                   "JAVA-65", "Minor - P4", "http://github.com/mongodb/mongo-java-driver/commit/729fc494e5305d362eea95b01c381f2a7daf2652"
    end
  end
end
