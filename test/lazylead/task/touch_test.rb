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
require_relative "../../../lib/lazylead/task/touch"

module Lazylead
  class SvnTouchTest < Lazylead::Test
    # @todo #/DEV Find stable svn repo which can be used for stable test, for
    #  now only floating repo used for testing locally. Also, create a new
    #  method "ping" which can be used during tests like
    #  skip "No connection available to svn repo" unless ping("https://svn.com")
    test "important files changed in svn repo" do
      skip "No svn credentials provided" unless env? "svn_url",
                                                     "svn_user",
                                                     "svn_password"
      Lazylead::Smtp.new.enable
      Task::Touch.new.run(
        nil,
        Postman.new,
        "svn_url" => ENV["svn_url"],
        "svn_user" => ENV["svn_user"],
        "svn_password" => ENV["svn_password"],
        "commit_url" => "https://view.commit.com?rev=",
        "user" => "https://user.com?id=",
        "to" => "lead@fake.com",
        "from" => "ll@fake.com",
        "now" => "2020-07-12T17:24:45+01:00",
        "period" => "864000",
        "files" => "checkstyle.xml,checkstyle_suppressions.xml",
        "subject" => "[SVN] Static analysis configuration has been changed!",
        "template" => "lib/messages/svn_touch.erb"
      )
      assert_email "[SVN] Static analysis configuration has been changed!",
                   %w[revision user ticket]
    end
  end
end
