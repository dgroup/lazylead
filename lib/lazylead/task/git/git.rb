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
  # @todo #533/DEV Git `grep` command is required like Lazylead::SVN::Grep
  #
  # @todo #533/DEV Git `touch` command is required like Lazylead::SVN::Touch
  #
  # @todo #533/DEV Git `diff` command is required like Lazylead::SVN::Diff
  module Git
    #
    # SVN commit built from command-line stdout (OS#run).
    #
    class Commit
      def initialize(raw)
        @raw = raw
      end

      def to_s
        "#{id} #{msg}"
      end

      # @todo #/DEV Git Commit#id implementation is required based on `git` ruby gem
      def id; end

      # @todo #/DEV Git Commit#author implementation is required based on `git` ruby gem
      def author; end

      # @todo #/DEV Git Commit#time implementation is required based on `git` ruby gem
      def time; end

      # @todo #/DEV Git Commit#msg implementation is required based on `git` ruby gem
      def msg; end

      # @todo #/DEV Git Commit#lines implementation is required based on `git` ruby gem
      def lines; end

      # @todo #/DEV Git Commit#header implementation is required based on `git` ruby gem
      def header; end

      # The modified lines contains expected text
      # @todo #/DEV Git Commit#includes? implementation is required based on `git` ruby gem
      def includes?(text); end
    end

    #
    # Git commits built from command-line stdout (OS#run).
    #
    # @todo #/DEV Git Commits implementation is required based on `git` ruby gem
    class Commits
      extend Forwardable
      def_delegators :@all, :each, :map, :select, :empty?

      def initialize(stdout)
        @stdout = stdout
      end
    end
  end
end
