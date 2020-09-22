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
require_relative "../../../../lib/lazylead/task/accuracy/servers"

module Lazylead
  class ServersTest < Lazylead::Test
    class Task
      def initialize(desc)
        @desc = desc
      end

      def [](_)
        ""
      end

      def description
        @desc
      end
    end

    test "url to failed entity found in description" do
      assert Servers.new(envs: [%r{(http|https):\/\/\w+\:\d+\/.{10,}}]).passed(
        Task.new(
          "1. Open the dedicated app
           2. Click on https://server:6900/object?id=2000
           ER: Object has no failed status
           AR: Object has failed status"
        )
      )
    end

    test "url to failed entity not present in description" do
      refute Servers.new(envs: [%r{(http|https):\/\/\w+\:\d+\/.{10,}}]).passed(
        Task.new(
          "1. Open the dedicated app
           2. Click on https://server:6900/
           ER: Object has no failed status
           AR: Object has failed status"
        )
      )
    end
  end
end
