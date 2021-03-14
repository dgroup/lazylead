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

require_relative "../../../test"
require_relative "../../../../lib/lazylead/task/accuracy/accuracy"
require_relative "../../../../lib/lazylead/task/accuracy/affected_build"

module Lazylead
  class ScoreTest < Lazylead::Test
    test "grade is detected" do
      {
        "7": "0",
        "5.5": "0",
        "12": "10",
        "21.5": "20",
        "25.5": "20",
        "57": "50",
        "98": "90",
        "100": "100"
      }.each do |k, v|
        assert_equal v.to_f,
                     Lazylead::Score.new({}, {}).grade(k.to_s.to_f)
      end
    end

    test "comment has proper structure" do
      assert_words %w[triage accuracy is 100.0%],
                   Score.new(
                     Struct.new(:key) do
                       def reporter
                         OpenStruct.new(id: "userid")
                       end

                       def fields
                         { "versions" => ["0.1.0"] }
                       end
                     end.new("DATAJDBC-493"),
                     Opts.new(
                       rules: [Lazylead::AffectedBuild.new],
                       total: 0.5,
                       "colors" => {
                         "0" => "#FF4F33",
                         "35" => "#FF9F33",
                         "57" => "#19DD1E",
                         "90" => "#0FA81A"
                       }.to_json.to_s,
                       "docs" => "https://github.com/dgroup/lazylead/blob/master/.github/ISSUE_TEMPLATE/bug_report.md"
                     )
                   ).evaluate.comment
    end
  end
end
