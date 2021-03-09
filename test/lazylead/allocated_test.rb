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

require_relative "../test"
require_relative "../../lib/lazylead/allocated"

module Lazylead
  class AllocatedTest < Lazylead::Test
    test "bytes transformed to string have labels (B, KB, MB, etc)" do
      {
        "1B": 1,
        "1KB": 1024,
        "1MB": 1024 * 1024,
        "1GB": 1024 * 1024 * 1024,
        "1024GB": 1024 * 1024 * 1024 * 1024
      }.each do |label, bytes|
        assert_equal label.to_s,
                     Allocated.new(bytes).to_s
      end
    end

    test "default ctor evaluates a memory" do
      greater_then Allocated.new.to_i, 0
    end

    test "pass a nil (null) value" do
      assert_equal "?", Allocated.new(nil).to_s
    end
  end
end
