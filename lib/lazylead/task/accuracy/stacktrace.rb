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
  # Java stacktrace or Oracle errors in {noformat} section
  class Stacktrace < Lazylead::Requirement
    def initialize(score = 3)
      super "Stacktrace/errors in *\\{noformat\\}* for JIRA indexing", score,
            "Description"
    end

    def passed(issue)
      return false if issue.description.nil?
      frames(issue.description).any? { |f| oracle?(f) || java?(f) }
    end

    # Detect all {noformat}, {code} frames in ticket description
    def frames(description)
      noformat(description).concat(code(description))
    end

    # Detect all noformat blocks and give all text snippets in array
    # @param desc The jira ticket description
    def noformat(desc)
      return [] unless desc.match?(/{(n|N)(o|O)(f|F)(o|O)(r|R)(m|M)(a|A)(t|T)}/)
      desc.enum_for(:scan, /(?=\{(n|N)(o|O)(f|F)(o|O)(r|R)(m|M)(a|A)(t|T)})/)
          .map { Regexp.last_match.offset(0).first }
          .each_slice(2).map do |f|
        desc[f.first, f.last - f.first + "{noformat}".size]
      end
    end

    # Detect all {code:*} blocks and give all text snippets in array
    # @param desc The jira ticket description
    def code(desc)
      return [] unless desc.match?(/{(c|C)(o|O)(d|D)(e|E)(:\S+)?}/)
      words = desc.gsub(/{(c|C)(o|O)(d|D)(e|E)/, " {code")
                  .gsub("}", "} ")
                  .gsub("Caused by:", "Caused_by:")
                  .split
                  .map(&:strip)
                  .reject(&:blank?)
      pairs(words, "{code").map { |s| words[s.first..s.last].join("\n") }
    end

    # Detect indexes of pairs  which are starting from particular text
    # @param words is array of words
    # @param text is a label for pairs
    #
    #  paris([aa,tag,bb,cc,tag,dd], "tag")        => [[1, 4]]
    #  paris([aa,tag,bb,cc,tag,dd,tag,ee], "tag") => [[1, 4]]    # non closed
    #
    def pairs(words, text)
      snippets = [[]]
      words.each_with_index do |e, i|
        next unless e.start_with? text
        pair = snippets.last
        pair << i if pair.size.zero? || pair.size == 1
        snippets[-1] = pair
        snippets << [] if pair.size == 2
      end
      snippets.select { |s| s.size == 2 }
    end

    # @return true if frame has few lines with java stack frames
    def java?(frame)
      allowed = ["at", "Caused by:", "Caused_by:"]
      frame.match?(/\s\S+\.\S+Exception:\s/) ||
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
