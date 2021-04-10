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
require_relative "../../../../lib/lazylead/task/accuracy/screenshots"
require_relative "../../../../lib/lazylead/system/jira"

module Lazylead
  class ScreenshotsTest < Lazylead::Test
    test "issue has two .png files with reference in description" do
      assert Screenshots.new.passed(
        OpenStruct.new(
          description: "Hi,\n here are snapshots !img1.jpg|thumbnail!\n!img2.jpg|thumbnail!\n",
          fields: {
            "description" => "Hi,\n here are snapshots !img1.jpg|thumbnail!\n!img2.jpg|thumbnail!\n"
          },
          attachments: [
            OpenStruct.new("filename" => "img1.jpg"),
            OpenStruct.new("filename" => "img2.jpg")
          ]
        )
      )
    end

    test "issue has several .png attachments mentioned using !xxx|thumbnail! option" do
      assert Screenshots.new.passed(
        NoAuthJira.new("https://jira.spring.io")
                  .issues("key=SPR-15729", fields: %w[attachment description])
                  .first
      )
    end

    test "issue has no .png file however minimum 1 are required" do
      refute Screenshots.new.passed(
        OpenStruct.new(
          description: "Hi,\n here are snapshots !img1.zip!\n",
          fields: { "description" => "Hi,\n here are snapshots !img1.zip!\n" },
          attachments: [
            OpenStruct.new("filename" => "img1.jpg"),
            OpenStruct.new("filename" => "img2.jpg")
          ]
        )
      )
    end

    test "issue has two .png files with reference in description but with extension mismatch" do
      refute Screenshots.new.passed(
        OpenStruct.new(
          description: "Hi,\n here are snapshots !img1.jpg|thumbnail!\n!img2.jpg|thumbnail!\n",
          fields: {
            "description" => "Hi,\n here are snapshots !img1.jpg|thumbnail!\n!img2.jpg|thumbnail!\n"
          },
          attachments: [
            OpenStruct.new("filename" => "img1.JPG"),
            OpenStruct.new("filename" => "img2.jpg")
          ]
        )
      )
    end

    test "issue has two .png file in description but three .png in attachments" do
      assert Screenshots.new.passed(
        OpenStruct.new(
          description: "Hi,\n here are snapshots !img1.JPG|thumbnail!\n!img2.jpg|thumbnail!\n",
          fields: {
            "description" => "Hi,\n here are snapshots !img1.JPG|thumbnail!\n!img2.jpg|thumbnail!\n"
          },
          attachments: [
            OpenStruct.new("filename" => "img1.JPG"),
            OpenStruct.new("filename" => "img2.jpg"),
            OpenStruct.new("filename" => "img3.jpg")
          ]
        )
      )
    end

    test "issue has two .png files with reference in description without thumbnail" do
      assert Screenshots.new.passed(
        OpenStruct.new(
          description: "Hi,\n here are snapshots !img1.jpg!\n!img2.jpg!\n",
          fields: { "description" => "Hi,\n here are snapshots !img1.jpg!\n!img2.jpg!\n" },
          attachments: [
            OpenStruct.new("filename" => "img1.jpg"),
            OpenStruct.new("filename" => "img2.jpg")
          ]
        )
      )
    end

    test "issue has two .png files with reference in description but absent in attachments" do
      refute Screenshots.new.passed(
        OpenStruct.new(
          description: "Hi,\n here are snapshots !img1.jpg!\n!img2.jpg!\n",
          fields: {
            "description" => "Hi,\n here are snapshots !img1.jpg!\n!img2.jpg!\n"
          },
          attachments: [
            OpenStruct.new("filename" => "img3.jpg"),
            OpenStruct.new("filename" => "img4.jpg")
          ]
        )
      )
    end
  end
end
