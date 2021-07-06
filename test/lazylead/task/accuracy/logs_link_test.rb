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
require_relative "../../../../lib/lazylead/task/accuracy/logs_link"

module Lazylead
  class LogsLinkTest < Lazylead::Test
    test "log file is present" do
      assert LogsLink.new("https://mygraylog.com/log#5").passed(
        OpenStruct.new(
          attachments: [OpenStruct.new(attrs: { "size" => 10_241, "filename" => "catalina.log" })]
        )
      )
    end

    test "log file is absent but description has log reference" do
      assert LogsLink.new("https://mygraylog.com").passed(
        OpenStruct.new(description: "Here is the log for current ticket https://mygraylog.com/log#5")
      )
    end

    test "log file is absent and link is absent" do
      refute LogsLink.new("https://mygraylog.com").passed(
        OpenStruct.new(attachments: [])
      )
    end
  end
end
