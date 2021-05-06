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

require "tmpdir"
require "nokogiri"
require "active_support/core_ext/hash/conversions"
require_relative "../../os"
require_relative "../../salt"
require_relative "../../opts"
require_relative "svn"

module Lazylead
  module Task
    module Svn
      #
      # Detect particular text in diff commit.
      #
      class Grep
        def initialize(log = Log.new)
          @log = log
        end

        def run(_, postman, opts)
          text = opts.slice("text", ",")
          commits = svn_log(opts).select { |c| c.includes? text }
          postman.send(opts.merge(entries: commits)) unless commits.empty?
        end

        # Return all svn commits for particular date range in repo
        def svn_log(opts)
          stdout = OS.new.run "svn log --diff --no-auth-cache",
                              "--username #{opts.decrypt('svn_user', 'svn_salt')}",
                              "--password #{opts.decrypt('svn_password', 'svn_salt')}",
                              "-r {#{from(opts)}}:{#{now(opts)}} #{opts['svn_url']}"
          return [] if stdout.blank?
          Lazylead::Svn::Commits.new(stdout)
        end

        # The start date & time for search range
        def from(opts)
          (now(opts).to_time - opts["period"].to_i).to_datetime
        end

        # The current date & time for search range
        def now(opts)
          if opts.key? "now"
            DateTime.parse(opts["now"])
          else
            DateTime.now
          end
        end
      end
    end
  end
end
