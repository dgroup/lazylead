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

require "inifile"
require "tempfile"
require_relative "../test"

module Lazylead
  class EnvTest < Lazylead::Test
    test "ENV has keys" do
      ENV["a"] = "aaa"
      ENV["b"] = "bbb"
      assert env? "a", "b"
    end
    test "ENV has no key" do
      refute env? "c"
    end
    test "ini file found" do
      Tempfile.create do |f|
        f << "EnvTest=value"
        f.flush
        IniFile.new(filename: f).each { |_, k, v| ENV[k] = v }
        assert_equal "value", ENV.fetch("EnvTest", nil)
      end
    end
    test "ini file not found" do
      assert_empty IniFile.new(filename: "absent.ini").to_h
    end
  end
end
