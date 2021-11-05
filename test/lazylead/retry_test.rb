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
require_relative "../../lib/lazylead/log"
require_relative "../../lib/lazylead/model"

module Lazylead
  # Fake lazylead task for unit testing purposes.
  class FakeTask
    attr_reader :attempts

    # Ctor.
    # @param proc
    #        The logic to be executed in task.
    #        The logic may successfully finished or fail due to the exception.
    # @param opts
    #        The task properties defined in the database by the user.
    #        @see Task#props
    def initialize(proc, opts)
      @proc = proc
      @opts = opts
      @attempts = 0
    end

    # Execute the fake task logic and count the attempt.
    def exec
      @attempts += 1
      @proc.call
    end

    # The task properties.
    def props
      @opts
    end
  end

  class RetryTest < Lazylead::Test
    test "retry 3 times if error" do
      assert_equal 3,
                   ORM::Retry.new(
                     FakeTask.new(
                       proc { raise "shit happens, you know..." },
                       "attempt" => "3"
                     )
                   ).exec.attempts
    end

    test "no retry if task successful" do
      assert_equal 1, ORM::Retry.new(FakeTask.new(proc { "ok" }, "attempt" => "3")).exec.attempts
    end

    test "retry and sleep if error" do
      assert_equal 2,
                   ORM::Retry.new(
                     FakeTask.new(
                       proc { raise "network issue" },
                       "attempt" => "2",
                       "attempt_wait" => "0.01" # => 0.01 second
                     )
                   ).exec.attempts
    end

    test "throw error" do
      assert_raises(RuntimeError, "network issue") do
        ORM::Retry.new(
          FakeTask.new(
            proc { raise "network issue" },
            { "rethrow" => "true" }
          )
        ).exec
      end
    end
  end
end
