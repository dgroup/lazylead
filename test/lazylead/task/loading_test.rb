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
require_relative "../../../lib/lazylead/opts"
require_relative "../../../lib/lazylead/postman"
require_relative "../../../lib/lazylead/task/loading"

module Lazylead
  class LoadingTest < Lazylead::Test
    test "notify about team loading" do
      Lazylead::Smtp.new.enable
      Task::Loading.new.run(
        NoAuthJira.new("https://jira.spring.io"),
        Postman.new,
        Opts.new(
          "to" => "lead@company.com",
          "from" => "ll@company.com",
          "jql" => "key in (STS-3599, XD-3739, XD-3744)",
          "team" => "mclaren:Tom McLaren,milesparker:Mi Pa,grussell:Gary Ru",
          "user_link" => "https://user.com?id=",
          "search_link" => "https://jira.spring.io/issues/?jql=",
          "fields" => "assignee,duedate,customfield_10480",
          "sprint" => "customfield_10480",
          "subject" => "[LL] Team loading",
          "template" => "lib/messages/loading.erb"
        )
      )
      assert_email "[LL] Team loading",
                   "grussell", "Gary Ru", "Sprint 68", "1",
                   "Miles Parker", "No sprint: 1", "2013-11-08",
                   "Tom McLaren", "0"
    end
  end
end
