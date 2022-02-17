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
require_relative "../../../../lib/lazylead/task/accuracy/wiki_url"

module Lazylead
  class WikiUrlTest < Lazylead::Test
    test "wiki reference is present as url" do
      assert WikiUrl.new("https://wiki.com/page=").passed(
        OpenStruct.new(
          remote_links: [
            OpenStruct.new(
              attrs: { "object" => { "url" => "https://wiki.com/page=5" } }
            )
          ]
        )
      )
    end

    test "wiki reference is absent as url" do
      refute WikiUrl.new("https://wiki.com/page=").passed(
        OpenStruct.new(
          remote_links: [
            OpenStruct.new(
              attrs: {}
            )
          ]
        )
      )
    end

    test "wiki score" do
      greater_then WikiUrl.new("https://wiki.com/page=").score, 0
    end
  end
end
