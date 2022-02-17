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

require_relative "attachment"

module Lazylead
  # Check that ticket has video record(s) with reproducing results.
  class Records < Lazylead::Attachment
    # @param ext
    #        The list of video records file extensions.
    # @param size
    #        The minimum size of video records in bytes.
    #        Default value is 5KB.
    def initialize(ext = [], size = 5 * 1024)
      super("Internal reproducing results (video)", 5, "Attachments")
      @ext = ext
      @size = size
      return unless @ext.empty?
      @ext = %w[.webm .mkv .flv .flv .vob .ogv .ogg .drc .gif .gifv .mng .avi
                .mts .m2ts .ts .mov .qt .wmv .yuv .rm .rmvb .viv .asf .amv .mp4
                .m4p .m4v .mpg .mp2 .mpeg .mpe .mpv .mpg .mpeg .m2v .m4v .svi
                .3gp .3g2 .mxf .roq .nsv .flv .f4v .f4p .f4a .f4b .wrf]
    end

    # Ensure that ticket has an attachment with video-file extension
    def matches?(attach)
      return false if attach.attrs["size"].to_i < @size
      return true if @ext.any? { |e| e.eql? File.extname(attach.attrs["filename"]).downcase }
      return false if attach.attrs["mimeType"].nil?
      @ext.any? { |e| attach.attrs["mimeType"].end_with? "/#{e[1..]}" }
    end
  end
end
