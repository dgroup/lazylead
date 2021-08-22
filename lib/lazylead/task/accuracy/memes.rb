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

require "json"
require_relative "../../log"
require_relative "../../opts"

module Lazylead
  # Meme generator based on tickets accuracy.
  # For each range of scores there might be several available memes to be chosen randomly.
  # If no meme found for score, empty url should be provided.
  #
  # @todo #339/DEV Prepare the meme list and attach them to the github, section .docs/accuracy/memes
  #  As url they will be required for configuration of the each task.
  class Memes
    def initialize(memes, log: Log.new)
      @log = log
      @memes = memes
    end

    def enabled?
      !@memes.nil? && !range.empty?
    end

    # Detect meme url based on accuracy score.
    # @param score
    #        Accuracy score in percentage
    def find(score)
      r = range.find { |m| score >= m[0] && score <= m[1] }
      return "" if r.nil?
      r.last.sample
    end

    # Parse json-based memes configuration.
    # Expected format is
    #   "memes": {
    #     "0-9.9": "https://meme.com?id=awful1.gif,https://meme.com?id=awful2.gif",
    #     "70-89.9": "https://meme.com?id=nice.gif",
    #     "90-100": "https://meme.com?id=wow.gif"
    #   }
    def range
      @range ||= if @memes.nil?
                   []
                 else
                   rng = JSON.parse(@memes).to_h
                   return [] if rng.empty?
                   rng.map do |k, v|
                     next unless k.include? "-"
                     row = k.split("-").map(&:to_f)
                     row << v.split(",")
                     row
                   end
                 end
    end
  end
end
