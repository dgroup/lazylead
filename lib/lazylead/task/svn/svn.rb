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

require "forwardable"

module Lazylead
  module Svn
    #
    # SVN commit built from command-line stdout (OS#run).
    #
    class Commit
      def initialize(raw)
        @raw = raw
      end

      def to_s
        "#{rev} #{msg}"
      end

      def rev
        header.first[1..]
      end

      def author
        header[1]
      end

      def time
        DateTime.parse(header[2]).strftime("%d-%m-%Y %H:%M:%S")
      end

      def msg
        lines[1]
      end

      def lines
        @lines ||= @raw.split("\n").reject(&:blank?)
      end

      def header
        @header ||= lines.first.split(" | ").reject(&:blank?)
      end

      # The modified lines contains expected text
      def includes?(text)
        text = [text] unless text.respond_to? :each
        lines[4..].select { |l| l.start_with? "+" }.any? { |l| text.any? { |t| l.include? t } }
      end

      # Detect SVN diff lines with particular text
      def diff(text)
        @diff ||= begin
          files = affected(text).uniq
          @raw.split("Index: ")
              .select { |i| files.any? { |f| i.start_with? f } }
              .map { |i| i.split "\n" }
              .flatten
        end
      end

      # Detect affected files with particular text
      def affected(text)
        occurrences = lines.each_index.select do |i|
          lines[i].start_with?("+") && text.any? { |t| lines[i].include? t }
        end
        occurrences.map do |occ|
          lines[2..occ].reverse.find { |l| l.start_with? "Index: " }[7..]
        end
      end
    end

    #
    # SVN commits built from command-line stdout (OS#run).
    #
    class Commits
      extend Forwardable
      def_delegators :@all, :each, :map, :select, :empty?

      # @todo #/DEV Find a way how to avoid @all initialization directly in constructor.
      #  There should be a way how to make lazy initialization of @all with 'forwardable'.
      def initialize(stdout)
        @all = stdout.split("-" * 72).reject(&:blank?).reverse.map { |e| Commit.new(e) }
      end
    end
  end
end
