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

require_relative "logs"
require_relative "attachment"

module Lazylead
  # Check that ticket has link/reference to log record(s) in another system like ELK, GrayLog, etc.
  #  or attachment with plain log file
  class LogsLink < Lazylead::Logs
    def initialize(link)
      super
      @link = link
    end

    def passed(issue)
      return false if @link.nil? || (@link.is_a?(Array) && @link.empty?)
      super(issue) || link?(issue)
    end

    # Ensure that ticket has a link to external logs system like ELK, GrayLog, etc.
    def link?(issue)
      return false if issue.description.nil?
      issue.description
           .split("\n")
           .reject(&:blank?)
           .flat_map(&:split)
           .reject(&:blank?)
           .any? do |word|
        @link.is_a?(Array) ? @link.any? { |l| word.start_with? l } : word.start_with?(@link)
      end
    end
  end
end
