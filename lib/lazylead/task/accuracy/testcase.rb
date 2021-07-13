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

require_relative "requirement"

module Lazylead
  # Check the 'Description' field that ticket has mandatory details like
  #  - test case (TC)
  #  - actual result (AR)
  #  - expected result (ER)
  class Testcase < Lazylead::Requirement
    def initialize(score = 4)
      super "Test case with AR/ER", score, "Description"
    end

    def passed(issue)
      return false if issue.description.nil?
      @tc = @ar = @er = -1
      issue.description.split("\n").reject(&:blank?).map(&:downcase).each_with_index do |l, i|
        line = escape l.gsub(/(\s+|\*|\+)/, "")
        detect_tc i, l, line
        detect_ar i, l, line
        detect_er i, l, line
        break if with_tc_ar_er?
      end
      with_tc_ar_er?
    end

    def escape(line)
      if line.include?("{color")
        line.gsub(
          /({color:(#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})|[A-Za-z]+)})|{color}/, ""
        )
      else
        line.gsub(/[^a-zA-Z(:|=)]/, "")
      end
    end

    # @return true if description has test case, AR and ER
    def with_tc_ar_er?
      (@tc.zero? || @tc.positive?) && @ar.positive? && @er.positive?
    end

    # Detect index of line with test case
    # @param index The line number in description
    # @param src The whole line in lower case from description
    # @param strip The escaped line in lower case from description without special symbol(s)
    def detect_tc(index, src, strip)
      return unless @tc.negative?
      keywords = %w[testcase: tc: teststeps: teststeps steps: tcsteps: tc testcases steps usecase
                    pre-requisitesandsteps:]
      @tc = index if keywords.any? { |k| strip.eql? k }
      @tc = index if keywords.any? { |k| src.include? k }
    end

    # Detect index of line with actual result
    # @param index The line number in description
    # @param src The whole line in lower case from description
    # @param strip The escaped line in lower case from description without special symbol(s)
    def detect_ar(index, src, strip)
      return unless @ar.negative? && index > @tc
      keywords = %w[ar: actualresult: ar= [ar] actualresult]
      @ar = index if keywords.any? { |k| strip.start_with? k }
      @ar = index if keywords.any? { |k| src.include? k }
    end

    # Detect index of line with expected result
    # @param index The line number in description
    # @param src The whole line in lower case from description
    # @param strip The escaped line in lower case from description without special symbol(s)
    def detect_er(index, src, strip)
      return unless @er.negative? && index > @tc
      keywords = %w[er: expectedresult: er= [er] expectedresult]
      @er = index if keywords.any? { |k| strip.start_with? k }
      @er = index if keywords.any? { |k| src.include? k }
    end
  end
end
