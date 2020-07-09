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

require_relative "../test"
require_relative "../../lib/lazylead/cc"
require_relative "../../lib/lazylead/log"
require_relative "../../lib/lazylead/system/jira"

module Lazylead
  class CcTest < Lazylead::Test
    test "cc has valid email" do
      assert_equal "a@fake.com", Lazylead::CC.new("a@fake.com").cc.first
    end

    test "cc has valid email despite on additional spaces" do
      assert_equal "a@fake.com", Lazylead::CC.new("a@fake.com ").cc.first
    end

    test "cc has valid email despite on unexpected symbols" do
      assert_equal "a@fake.com", Lazylead::CC.new("a@fake.com, , -").cc.first
    end

    test "cc has valid emails" do
      assert_equal %w[a@fake.com b@fake.com c@fake.com],
                   Lazylead::CC.new("a@fake.com,b@fake.com,c@fake.com").cc
    end
  end

  class PredefinedCcTest < Lazylead::Test
    test "predefined cc has valid emails" do
      assert_entries(
        {
          "jdbc" => %w[j@fake.com],
          "jvm" => %w[j@fake.com v@fake.com]
        },
        PredefinedCC.new(
          "jdbc" => "j@fake.com ",
          "jvm" => "j@fake.com,,v@fake.com"
        ).to_h
      )
    end

    test "all predefined cc are valid emails" do
      assert_equal %w[j@fake.com v@fake.com m@fake.com],
                   PredefinedCC.new(
                     "jdbc" => "j@fake.com ",
                     "jvm" => "j@fake.com,,v@fake.com,-, ,m@fake.com"
                   ).cc
    end

    test "cc by key is found" do
      assert_equal %w[j@fake.com],
                   PredefinedCC.new(
                     "jdbc" => "j@fake.com ",
                     "jvm" => "j@fake.com,,v@fake.com,-, ,m@fake.com"
                   )["jdbc"]
    end
  end
end
