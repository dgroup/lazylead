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

require_relative "../log"
require_relative "../postman"

module Lazylead
  module Task
    # A task which fetch issues by particular ticketing system query language
    #  and find issues where comments has no expected text.
    #
    # Example:
    #  you have a sub-task for demo session for your story;
    #  demo session is recorded, placed to ftp;
    #  nobody mentioned in comment the ftp location for recorded session.
    # Such cases needs to be reported.
    class MissingComment
      def initialize(log = Log.new)
        @log = log
      end

      def run(sys, postman, opts)
        opts["details"] = "text '#{opts['text']}'" if opts["details"].blank?
        issues = sys.issues(
          opts["jql"],
          {
            max_results: opts.fetch("max_results", 50),
            fields: opts.fetch("fields", "").split(",").map(&:to_sym)
          }
        )
        return if issues.empty?
        postman.send opts.merge(
          comments: issues.map { |i| Comments.new(i, sys) }
                          .reject { |c| c.body? opts["text"] }
        )
      end
    end
  end
end
