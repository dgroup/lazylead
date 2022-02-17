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

require_relative "../../../test"
require_relative "../../../../lib/lazylead/task/accuracy/logs"

module Lazylead
  class LogsTest < Lazylead::Test
    test "log file is present" do
      assert Logs.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(
              attrs: { "size" => 10_241, "filename" => "catalina.log" }
            )
          ]
        )
      )
    end

    test "log file is present but name in uppercase" do
      assert Logs.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(
              attrs: { "size" => 10_241, "filename" => "catalina.LOG" }
            )
          ]
        )
      )
    end

    test "attachment isn't a log file" do
      refute Logs.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(
              attrs: { "size" => 10_001, "filename" => "readme.md" }
            )
          ]
        )
      )
    end

    test "log file size less than 5KB" do
      refute Logs.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(
              attrs: { "size" => 5000, "filename" => "catalina.log" }
            )
          ]
        )
      )
    end

    test "rotated log file is present" do
      assert Logs.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(
              attrs: { "size" => 10_241, "filename" => "catalina.log111" }
            )
          ]
        )
      )
    end

    test "log txt file is present" do
      assert Logs.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(
              attrs: { "size" => 10_241, "filename" => "catalina.txt" }
            )
          ]
        )
      )
    end

    test "zip log file is present" do
      assert Logs.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(
              attrs: { "size" => 10_241, "filename" => "catalina.log.zip" }
            )
          ]
        )
      )
    end

    test "gz log file is present" do
      assert Logs.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(
              attrs: { "size" => 10_241, "filename" => "catalina.log.gz" }
            )
          ]
        )
      )
    end

    test "tar gz log file is present" do
      assert Logs.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(
              attrs: { "size" => 10_241, "filename" => "catalina.log.tar.gz" }
            )
          ]
        )
      )
    end

    test "filename contain word logs" do
      assert Logs.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(
              attrs: { "size" => 10_241, "filename" => "the some logs]here.gz" }
            )
          ]
        )
      )
    end
  end
end
