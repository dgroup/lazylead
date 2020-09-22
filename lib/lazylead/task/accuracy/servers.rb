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
  # Check that ticket has expected links to failed entities on dedicated
  #  servers.
  class Servers < Lazylead::Requirement
    #
    # @param envs regexp expressions to match servers in description.
    #
    def initialize(score: 2, envs: [], desc: "Internal reproducing results")
      super desc, score, "Description/Environment"
      @envs = envs
    end

    def passed(issue)
      return true if @envs.empty?
      lines = issue["environment"].to_s + "\n" + issue.description
      lines.split("\n")
           .reject(&:blank?)
           .map(&:strip)
           .flat_map { |l| l.split(" ").map(&:strip) }
           .select { |w| w.start_with?("http://", "https://") }
           .any? { |u| @envs.any? { |e| u.match? e } }
    end
  end
end
