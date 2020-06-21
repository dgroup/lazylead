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

require_relative "../../test"
require_relative "../../../lib/lazylead/system/jira"
require_relative "../../../lib/lazylead/task/propagate_down"

module Lazylead
  class PropagateDownTest < Lazylead::Test
    test "propagate fields from parent ticket to sub-tasks" do
      parent = OpenStruct.new(
        id: 1,
        key: "PRJ-1",
        fields: {
          subtasks: [{ id: 2 }.stringify_keys],
          customfield_101: "Tomorrow",
          customfield_102: "Yesterday"
        }.stringify_keys
      )
      Child = Struct.new(:id, :key, :fields, :comment) do
        def save(diff)
          fields.merge! diff[:fields]
        end

        def comments
          self
        end

        def build
          self
        end

        def save!(body)
          self[:comment] = body[:body]
        end
      end
      child = Child.new(
        2, "PRJ-2",
        {
          subtasks: [],
          customfield_101: nil,
          customfield_102: nil
        }.stringify_keys
      )
      Task::PropagateDown.new.run(
        Fake.new([parent, child]),
        [],
        "jql" => "type=Defect and updated>-1h and has subtasks without fields",
        "fields" => "customfield_101,customfield_102"
      )
      assert_entries(
        {
          "customfield_101" => "Tomorrow",
          "customfield_102" => "Yesterday"
        },
        child.fields
      )
      assert_words %w[The following fields were propagated from PRJ-1:
                      ||Field||Value||
                      |customfield_101|Tomorrow|
                      |customfield_102|Yesterday|
                      Posted by [lazylead v0.0.0|https://bit.ly/2NjdndS]],
                   child.comment
    end
  end
end
