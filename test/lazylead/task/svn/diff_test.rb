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
require_relative "../../../test"
require_relative "../../../../lib/lazylead/smtp"
require_relative "../../../../lib/lazylead/opts"
require_relative "../../../../lib/lazylead/postman"
require_relative "../../../../lib/lazylead/task/svn/diff"

module Lazylead
  # @todo #/DEV Svn::Diff Add test to check engine structure without email sending
  class DiffTest < Lazylead::Test
    # @todo #/DEV Right now its impossible to check that attachment is present in email as we
    #  removing the directory with attachments once SVN::Diff is sent the email through the postman.
    #  Think about how to test this case in automatically, because for now we are doing it manually
    #  during the development.
    test "changes since revision" do
      skip "No svn credentials provided" unless env? "svn_log_user", "svn_log_password"
      skip "No internet connection to riouxsvn.com" unless ping? "riouxsvn.com"
      Lazylead::Smtp.new.enable
      Task::Svn::Diff.new.run(
        [],
        Postman.new,
        Opts.new(
          "from" => "svnlog@test.com",
          "svn_url" => "https://svn.riouxsvn.com/touch4ll",
          "svn_user" => ENV.fetch("svn_log_user", nil),
          "svn_password" => ENV.fetch("svn_log_password", nil),
          "commit_url" => "https://view.commit.com?rev=",
          "user" => "https://user.com?id=",
          "to" => "lead@fake.com",
          "since_rev" => "1",
          "subject" => "[SVN] Changed since rev1",
          "template" => "lib/messages/svn_diff.erb",
          "template-attachment" => "lib/messages/svn_diff_attachment.erb"
        )
      )
      assert_email_line "[SVN] Changed since rev1", %w[r2 by dgroup at 16-08-2020]
      # assert_attachment "[SVN] Changed since rev1", /^.*svn-log-.*.html.zip$/
    end

    test "changes since revision with attachment" do
      skip "No svn credentials provided" unless env? "svn_log_user", "svn_log_password"
      skip "No internet connection to riouxsvn.com" unless ping? "riouxsvn.com"
      skip "No postman credentials provided" unless env? "LL_SMTP_HOST",
                                                         "LL_SMTP_PORT",
                                                         "LL_SMTP_USER",
                                                         "LL_SMTP_PASS",
                                                         "LL_SMTP_TO",
                                                         "LL_SMTP_FROM"
      Lazylead::Smtp.new(
        Log.new.verbose,
        NoSalt.new,
        smtp_host: ENV.fetch("LL_SMTP_HOST", nil),
        smtp_port: ENV.fetch("LL_SMTP_PORT", nil),
        smtp_user: ENV.fetch("LL_SMTP_USER", nil),
        smtp_pass: ENV.fetch("LL_SMTP_PASS", nil)
      ).enable
      Task::Svn::Diff.new.run(
        [],
        Postman.new,
        Opts.new(
          "from" => ENV.fetch("LL_SMTP_FROM", nil),
          "svn_url" => "https://svn.riouxsvn.com/touch4ll",
          "svn_user" => ENV.fetch("svn_log_user", nil),
          "svn_password" => ENV.fetch("svn_log_password", nil),
          "commit_url" => "https://view.commit.com?rev=",
          "user" => "https://user.com?id=",
          "to" => ENV.fetch("LL_SMTP_TO", nil),
          "since_rev" => "1",
          "subject" => "[SVN] Changed since rev1",
          "template" => "lib/messages/svn_diff.erb",
          "template-attachment" => "lib/messages/svn_diff_attachment.erb"
        )
      )
    end
  end
end
