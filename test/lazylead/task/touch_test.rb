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
require_relative "../../../lib/lazylead/opts"
require_relative "../../../lib/lazylead/postman"
require_relative "../../../lib/lazylead/task/touch"

module Lazylead
  class SvnTouchTest < Lazylead::Test
    test "important files changed in svn repo" do
      skip "No svn credentials provided" unless env? "svn_touch_user",
                                                     "svn_touch_password"
      skip "No internet connection to riouxsvn.com" unless ping? "riouxsvn.com"
      Lazylead::Smtp.new.enable
      Task::SvnTouch.new.run(
        [],
        Postman.new,
        Opts.new(
          "svn_url" => "https://svn.riouxsvn.com/touch4ll",
          "svn_user" => ENV["svn_touch_user"],
          "svn_password" => ENV["svn_touch_password"],
          "commit_url" => "https://view.commit.com?rev=",
          "user" => "https://user.com?id=",
          "to" => "lead@fake.com",
          "from" => "ll@fake.com",
          "now" => "2020-08-17T00:00:00+01:00",
          "period" => "864000",
          "files" => "189.md,absent.txt",
          "subject" => "[SVN] Important files have been changed!",
          "template" => "lib/messages/svn_touch.erb"
        )
      )
      assert_email "[SVN] Important files have been changed!",
                   %w[3 dgroup /189.md Add\ description\ for\ 189\ issue]
    end
  end

  class SvnLogTest < Lazylead::Test
    test "changes since revision" do
      skip "No svn credentials provided" unless env? "svn_log_user",
                                                     "svn_log_password"
      skip "No internet connection to riouxsvn.com" unless ping? "riouxsvn.com"
      Lazylead::Smtp.new.enable
      Task::SvnLog.new.run(
        [],
        Postman.new,
        Opts.new(
          "from" => "svnlog@test.com",
          "svn_url" => "https://svn.riouxsvn.com/touch4ll",
          "svn_user" => ENV["svn_log_user"],
          "svn_password" => ENV["svn_log_password"],
          "commit_url" => "https://view.commit.com?rev=",
          "user" => "https://user.com?id=",
          "to" => "lead@fake.com",
          "since_rev" => "1",
          "subject" => "[SVN] Changed since rev1",
          "template" => "lib/messages/svn_log.erb",
          "template-attachment" => "lib/messages/svn_log_attachment.erb"
        )
      )
      assert_email_line "[SVN] Changed since rev1",
                        %w[r2 by dgroup at 2020-08-16]
    end

    test "changes since revision with attachment" do
      skip "No svn credentials provided" unless env? "svn_log_user",
                                                     "svn_log_password"
      skip "No internet connection to riouxsvn.com" unless ping? "riouxsvn.com"
      skip "No postman credentials provided" unless env? "LL_SMTP_HOST",
                                                         "LL_SMTP_PORT",
                                                         "LL_SMTP_USER",
                                                         "LL_SMTP_PASS",
                                                         "LL_SMTP_TO",
                                                         "LL_SMTP_FROM"
      Lazylead::Smtp.new(
        Log.new,
        NoSalt.new,
        smtp_host: ENV["LL_SMTP_HOST"],
        smtp_port: ENV["LL_SMTP_PORT"],
        smtp_user: ENV["LL_SMTP_USER"],
        smtp_pass: ENV["LL_SMTP_PASS"]
      ).enable
      Task::SvnLog.new.run(
        [],
        Postman.new,
        Opts.new(
          "from" => ENV["LL_SMTP_FROM"],
          "svn_url" => "https://svn.riouxsvn.com/touch4ll",
          "svn_user" => ENV["svn_log_user"],
          "svn_password" => ENV["svn_log_password"],
          "commit_url" => "https://view.commit.com?rev=",
          "user" => "https://user.com?id=",
          "to" => ENV["LL_SMTP_TO"],
          "since_rev" => "1",
          "subject" => "[SVN] Changed since rev1",
          "template" => "lib/messages/svn_log.erb",
          "template-attachment" => "lib/messages/svn_log_attachment.erb"
        )
      )
    end
  end
end
