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
  # Check that ticket has log file(s) in attachment.
  class Logs < Lazylead::Attachment
    def initialize(files = %w[log.zip logs.zip log.gz logs.gz log.tar.gz
                              logs.tar.gz log.7z logs.7z log.tar logs.tar])
      super("Log files", 2, "Attachments")
      @files = files
    end

    # Ensure that ticket has a '*.log' file more '5KB'
    def matches?(attachment)
      name = attachment.attrs["filename"].downcase
      return false unless attachment.attrs["size"].to_i > 5120
      return true if File.extname(name).start_with? ".log", ".txt", ".out"
      return true if @files.any? { |l| name.end_with? l }
      %w[.zip .7z .gz tar.gz].any? do |l|
        name.end_with?(l) && name.split(/(?:[^a-zA-Z0-9](?<![^\x00-\x7F]))+/).include?("logs")
      end
    end
  end
end
