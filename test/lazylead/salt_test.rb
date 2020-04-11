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
require_relative "../../lib/lazylead/salt"

module Lazylead
  class SaltTest < Lazylead::Test
    test "e2e encryption/decryption is successful" do
      ENV["salt"] = "E1F53135E559C2530000000000000000"
      assert_equal "the-best-password",
                   Salt.new.decrypt(Salt.new.encrypt("the-best-password"))
    end

    test "decryption is successful" do
      ENV["salt.5"] = "E1F53135E559C2530000000000000000"
      assert_equal "the-best-password",
                   Salt.new(5)
                       .decrypt("VUxpSk83d3VGOHZMVTBvWmZ5eGlEOWdPZFhJN0tYMXhwaDd0MVg0L01PST0tLUc0bEhIVTBNRDFzdDdTSkNoeVAyckE9PQ==--4a0206700a28b69aaca65a88af09d211f4251f02")
    end
  end
end
