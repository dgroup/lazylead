# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2022 Yurii Dubinka
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

require_relative "../../opts"

module Lazylead
  #
  # Gives true when ticket status changed to expected status(es).
  #
  class ChangedTo
    def initialize(field, expected)
      @field = field
      @expected = expected
    end

    def passed(issue, opts)
      return false if issue.nil? || opts.nil? || opts[@expected].nil? || @field.nil?
      last = last_change(issue)
      opts.slice(@expected, ",").any? { |s| s.eql? last }
    end

    # Detect the last change of expected field in issue history
    def last_change(issue)
      issue.history
           .reverse
           .find { |h| h["items"].any? { |i| i["field"] == @field } }["items"]
           .find { |h| h["field"] == @field }["toString"]
    end
  end

  # Check that last status change has expected value.
  class ToStatus < Lazylead::ChangedTo
    def initialize
      super "status", "to_status"
    end
  end
end
