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
  # Java stacktrace or Oracle errors in {noformat} section
  class Stacktrace < Lazylead::Requirement
    def initialize(score = 3)
      super "Stacktrace/errors in *\\{noformat\\}* for JIRA indexing", score,
            "Description"
    end

    def passed(issue)
      return false if issue.description.nil?
      !frames(issue.description).select { |f| oracle?(f) || java?(f) }.empty?
    end

    # Detect all {noformat} frames in description field
    def frames(description)
      description.enum_for(:scan, /(?={noformat})/)
                 .map { Regexp.last_match.offset(0).first }
                 .each_slice(2).map do |f|
        description[f.first, f.last - f.first + "{noformat}".size]
      end
    end

    # @return true if frame has few lines with java stack frames
    def java?(frame)
      allowed = ["at ", "Caused by:"]
      frame.split("\n")
           .map(&:strip)
           .count { |l| allowed.any? { |a| l.start_with? a } } > 3
    end

    # @return true if frame has Oracle error
    # @see https://docs.oracle.com/pls/db92/db92.error_search
    def oracle?(frame)
      frame.match?(/\WORA-\d{5}:/)
    end
  end
end
