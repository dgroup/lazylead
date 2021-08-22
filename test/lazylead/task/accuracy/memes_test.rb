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
require_relative "../../../../lib/lazylead/task/accuracy/memes"

module Lazylead
  class MemesTest < Lazylead::Test
    test "detect range" do
      assert_array(
        [
          [0.0, 9.9, %w[https://meme.com?id=awful1.gif https://meme.com?id=awful2.gif]],
          [70.0, 89.9, ["https://meme.com?id=nice.gif"]],
          [90.0, 100.0, ["https://meme.com?id=wow.gif"]]
        ],
        Lazylead::Memes.new(
          {
            "0-9.9" => "https://meme.com?id=awful1.gif,https://meme.com?id=awful2.gif",
            "70-89.9" => "https://meme.com?id=nice.gif",
            "90-100" => "https://meme.com?id=wow.gif"
          }.to_json.to_s
        ).range
      )
    end

    test "find by score" do
      assert_equal "https://meme.com?id=nice.gif",
                   Lazylead::Memes.new(
                     {
                       "0-9.9" => "https://meme.com?id=awful1.gif,https://meme.com?id=awful2.gif",
                       "70-89.9" => "https://meme.com?id=nice.gif",
                       "90-100" => "https://meme.com?id=wow.gif"
                     }.to_json.to_s
                   ).find(80)
    end

    test "not found" do
      assert_blank Lazylead::Memes.new(
        {
          "0-9.9" => "https://meme.com?id=awful1.gif,https://meme.com?id=awful2.gif",
          "70-89.9" => "https://meme.com?id=nice.gif"
        }.to_json.to_s
      ).find(40)
    end

    test "positive_assert_array" do
      assert_array [[1, 2, %w[a b]]],
                   [[1, 2, %w[a b]]]
    end

    test "negative_assert_array" do
      refute array? [[1, 2, %w[a b]]],
                    [[1, 2, %w[c d]]]
    end
  end
end
