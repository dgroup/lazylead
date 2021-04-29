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
  #
  # Check that ticket has screenshot(s).
  # The screenshots should
  #  1. present as attachments
  #  2. has extension .jpg .jpeg .exif .tiff .tff .bmp .png .svg
  #  3. mentioned in description with !<name>.<extension>|thumbnail! (read more https://bit.ly/3rusNgW)
  #
  class Screenshots < Lazylead::Requirement
    # @param minimum The number of expected screenshots
    def initialize(minimum: 1, score: 2, ext: %w[.jpg .jpeg .exif .tiff .tff .bmp .png .svg])
      super "Screenshots", score, "Description,Attachments"
      @minimum = minimum
      @ext = ext
    end

    def passed(issue)
      return false if issue.attachments.nil? || blank?(issue, "description")
      ref = references(issue)
      ref.size < @minimum ? false : ref.all? { |r| pictures(issue).any? { |file| r.include? file } }
    end

    # Detect all references in ticket description to attachments (including web links).
    def references(issue)
      issue.description
           .to_enum(:scan, /!.+!/)
           .map { Regexp.last_match }
           .map(&:to_s)
           .reject { |r| r.match?(%r{(http|https)://.*/images/icons/link_attachment.*.gif}) }
    end

    # Detect all pictures in ticket attachments and returns an array with file names.
    def pictures(issue)
      @pictures ||= issue.attachments
                         .select { |a| @ext.include? File.extname(a.filename).downcase }
                         .map(&:filename)
    end
  end
end
