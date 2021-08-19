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
require_relative "../../../../lib/lazylead/task/accuracy/records"
require_relative "../../../../lib/lazylead/system/jira"

module Lazylead
  class RecordsTest < Lazylead::Test
    test "file has .mp4 extension" do
      assert Records.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(attrs: { "filename" => "failed case 1.mp4" })
          ]
        )
      )
    end

    test "file has .avi extension" do
      assert Records.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(attrs: { "filename" => "failed case 2.avi" })
          ]
        )
      )
    end

    test "file has .txt extension" do
      refute Records.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(attrs: { "filename" => "failed case 2.txt" })
          ]
        )
      )
    end

    test "mime type has .gif despite on ext" do
      assert Records.new.passed(
        OpenStruct.new(
          attachments: [
            OpenStruct.new(
              attrs: {
                "filename" => "snapshot.png",
                "mimeType" => "image/gif"
              }
            )
          ]
        )
      )
    end
  end
end
