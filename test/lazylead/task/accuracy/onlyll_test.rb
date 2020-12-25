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

require_relative "../../../test"
require_relative "../../../../lib/lazylead/opts"
require_relative "../../../../lib/lazylead/system/jira"
require_relative "../../../../lib/lazylead/task/accuracy/onlyll"

module Lazylead
  class OnlyLLTest < Lazylead::Test
    # In current tests the grid label is 'PullRequest'.
    # The default grid labels are 0%, 10%, 20%, etc., the reason why
    # 'PullRequest' label is used here as we don't have 0%, 10%, etc.
    # on https://jira.spring.io.
    test "grid label found" do
      assert Grid.new(
        NoAuthJira.new("https://jira.spring.io").issues("key=XD-3725").first,
        Opts.new("grid" => "PullRequest,  ,")
      ).labels?
    end

    test "grid label set by ll" do
      assert Grid.new(
        NoAuthJira.new("https://jira.spring.io")
                  .issues("key=XD-3725", expand: "changelog")
                  .first,
        Opts.new("grid" => "PullRequest", "author" => "grussell")
      ).changed?
    end
  end
end
