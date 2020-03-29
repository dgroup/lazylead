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
require_relative "../../lib/lazylead/group_by"

module Lazylead
  class GroupByTest < Lazylead::Test
    test "group by enumeration by external function" do
      class Usr
        attr_reader :id, :name

        def initialize(id, name)
          @id = id
          @name = name
        end

        def ==(other)
          self.class === other and other.id == @id
        end

        alias eql? ==

        def hash
          id.hash
        end
      end

      assert_equal 3,
                   GroupBy.new(
                     [
                       OpenStruct.new(smr: "NPE", assignee: Usr.new(1, "Tom")),
                       OpenStruct.new(smr: "IAE", assignee: Usr.new(2, "Tim")),
                       OpenStruct.new(smr: "MNF", assignee: Usr.new(3, "Zane")),
                       OpenStruct.new(smr: "IAE", assignee: Usr.new(3, "Zane")),
                       OpenStruct.new(smr: "NPE", assignee: Usr.new(3, "Zane"))
                     ]
                   ).to_h(&:assignee)[Usr.new(3, "Zane")].size
    end
  end
end

