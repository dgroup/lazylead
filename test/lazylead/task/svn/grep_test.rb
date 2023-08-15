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
require_relative "../../../../lib/lazylead/task/svn/grep"
require_relative "../../../../lib/lazylead/task/svn/svn"

module Lazylead
  # @todo #/DEV Svn::Grep Add test to check engine structure without email sending
  class GrepTest < Lazylead::Test
    test "changes with text" do
      skip "No svn credentials provided" unless env? "svn_log_user", "svn_log_password"
      skip "No internet connection to riouxsvn.com" unless ping? "riouxsvn.com"
      Lazylead::Smtp.new.enable
      Task::Svn::Grep.new.run(
        [],
        Postman.new,
        Opts.new(
          "from" => "svnlog@test.com",
          "text" => "ping",
          "svn_url" => "https://svn.riouxsvn.com/touch4ll",
          "svn_user" => ENV.fetch("svn_log_user", nil),
          "svn_password" => ENV.fetch("svn_log_password", nil),
          "commit_url" => "https://view.commit.com?rev=",
          "user" => "https://user.com?id=",
          "to" => "lead@fake.com",
          "now" => "2020-08-17T00:00:00+01:00",
          "period" => "864000",
          "subject" => "[SVN] Changes with text",
          "template" => "lib/messages/svn_grep.erb"
        )
      )

      assert_email_line "[SVN] Changes with text",
                        %w[r2 by dgroup at 2020-08-16]
    end

    test "test" do
      diff = <<~MSG

        r3 | dgroup | 2020-08-16 11:27:01 +0300 (Sun, 16 Aug 2020) | 1 line

        Add description for 189 issue

        Index: 189.md
        ===================================================================
        --- 189.md	(nonexistent)
        +++ 189.md	(revision 3)
        @@ -0,0 +1,9 @@
        +*Issue 189*
        +https://github.com/dgroup/lazylead/issues/189
        +
        +Find stable svn repo which can be used for stable test, for
        +now only floating repo used for testing locally. Also, create a new
        +method "ping" which can be used during tests like
        +```ruby
        +skip "No connection available to svn repo" unless ping("https://riouxsvn.com")
        +```
        \ No newline at end of file
        Index: readme.md
        ===================================================================
        --- readme.md	(revision 2)
        +++ readme.md	(revision 3)
        @@ -3,4 +3,5 @@
         More
          - https://github.com/dgroup/lazylead
          - https://github.com/dgroup/lazylead/blob/master/lib/lazylead/task/touch.rb
        - - https://github.com/dgroup/lazylead/blob/master/test/lazylead/task/touch_test.rb
        \ No newline at end of file
        + - https://github.com/dgroup/lazylead/blob/master/test/lazylead/task/touch_test.rb
        +
        \ No newline at end of file


      MSG
      assert_equal 15, Lazylead::Svn::Commit.new(diff).diff(%w[ping]).size,
                   "There is one commit with 'ping' word where diff has 14 lines"
    end
  end
end
