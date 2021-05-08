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

require_relative "../../../test"
require_relative "../../../../lib/lazylead/log"
require_relative "../../../../lib/lazylead/opts"
require_relative "../../../../lib/lazylead/smtp"
require_relative "../../../../lib/lazylead/postman"
require_relative "../../../../lib/lazylead/system/jira"
require_relative "../../../../lib/lazylead/task/alert/alertif"
require_relative "../../../../lib/lazylead/task/alert/changed_to"

module Lazylead
  class AlertIfTest < Lazylead::Test
    test "last change to Done" do
      Smtp.new.enable
      Lazylead::Task::AlertIf.new.run(
        NoAuthJira.new("https://jira.spring.io"),
        Postman.new,
        Opts.new(
          "to_status" => "Done",
          "to" => "lead@company.com",
          "from" => "ll@company.com",
          "rules" => "Lazylead::ToStatus",
          "jql" => "key=XD-3064",
          "subject" => "[LL] alert if",
          "template" => "lib/messages/alertif.erb"
        )
      )
      assert_email "[LL] alert if",
                   "XD-3064", "Critical", "Done", "Glenn Renfro", "Thomas Risberg", "HdfsMongoDB"
    end
  end
end
