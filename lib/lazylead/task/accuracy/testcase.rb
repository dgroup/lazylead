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
      issue.description.split("\n").reject(&:blank?).each_with_index do |l, i|
        line = l.gsub(/[^a-zA-Z(:|=)]/, "").downcase
        detect_tc line, i
        detect_ar line, i
        detect_er line, i
        break if with_tc_ar_er?
      end
      with_tc_ar_er?
    end

    # @return true if description has test case, AR and ER
    def with_tc_ar_er?
      (@tc.zero? || @tc.positive?) && @ar.positive? && @er.positive?
    end

    # Detect index of line with test case
    def detect_tc(line, index)
      return unless @tc.negative?
      @tc = index if %w[testcase: tc: teststeps: teststeps].any? do |e|
        e.eql? line
      end
    end

    # Detect index of line with actual result
    def detect_ar(line, index)
      return unless @ar.negative? && index > @tc
      @ar = index if %w[ar: actualresult: ar=].any? { |e| line.start_with? e }
    end

    # Detect index of line with expected result
    def detect_er(line, index)
      return unless @er.negative? && index > @tc
      @er = index if %w[er: expectedresult: er=].any? { |e| line.start_with? e }
    end
  end
end
