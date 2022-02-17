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

require_relative "../test"
require_relative "../../lib/lazylead/opts"

module Lazylead
  class OptsTest < Lazylead::Test
    test "able to read by symbol" do
      assert_equal "1", Opts.new(one: "1", two: "2")[:one]
    end

    test "able to read by key" do
      assert_equal "1", Opts.new("one" => "1", two: "2")["one"]
    end

    test "able to write by key" do
      opts = Opts.new
      opts["key"] = "value"
      assert_equal "value", opts["key"]
    end

    test "has jira defaults" do
      assert_entries(
        {
          max_results: 50
        },
        Opts.new.jira_defaults
      )
    end

    test "split and trim" do
      assert_equal %w[one two three],
                   Opts.new("text" => " one,two ,three, ,\n").slice("text", ",")
    end

    test "blank for null value cases" do
      assert Opts.new("one" => "1", "two" => nil).blank? "two"
    end

    test "to hash" do
      assert_kind_of Hash, Opts.new("one" => "1", "two" => nil).to_h
    end

    test "except keys" do
      assert_equal 1, Opts.new("one" => "1", "two" => "2").except("one").size
    end

    test "attachment is blank" do
      assert_empty Opts.new("attachments" => "").msg_attachments
    end

    test "attachment is nil" do
      assert_empty Opts.new("attachments" => nil).msg_attachments
    end

    test "attachment is absent" do
      assert_empty Opts.new({}).msg_attachments
    end

    test "attachment is present" do
      assert_equal %w[readme.md],
                   Opts.new("attachments" => "readme.md").msg_attachments
    end

    test "attachments are present" do
      assert_equal %w[readme.md license.txt],
                   Opts.new("attachments" => "readme.md,license.txt")
                       .msg_attachments
    end

    test "attachments are present as symbol" do
      assert_equal %w[readme.md license.txt],
                   Opts.new(attachments: " readme.md , license.txt ")
                       .msg_attachments
    end

    test "attachments is present as array" do
      assert_equal %w[readme.md license.txt],
                   Opts.new(attachments: %w[readme.md license.txt])
                       .msg_attachments
    end

    test "value has numeric value" do
      assert Opts.new("key" => "1").numeric? "key"
    end

    test "text value is not a numeric" do
      refute Opts.new("key" => "val").numeric? "key"
    end

    test "nil is not a numeric" do
      refute Opts.new("key" => nil).numeric? "key"
    end

    test "find by text key" do
      assert_equal "val", Opts.new("key" => "val").find("key")
    end

    test "find by symbol key" do
      assert_equal "val", Opts.new(key: "val").find(:key)
    end

    test "find by symbol key but with text key" do
      assert_equal "val", Opts.new("key" => "val").find(:key)
    end

    test "find default" do
      assert_equal "val", Opts.new.find(:key, "val")
    end
  end
end
