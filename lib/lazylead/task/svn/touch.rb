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

module Lazylead
  module Task
    module Svn
      #
      # Send notification about modification of critical files in svn repo.
      #
      class Touch
        def initialize(log = Log.new)
          @log = log
        end

        # @todo #567:DEV Add flag with branch prefixes that could be used for future filtration
        #  Right now method .locations returns all branches, potentially that won't be needed.
        def run(_, postman, opts)
          files = opts.slice("files", ",")
          commits = touch(files, opts)
          postman.send(opts.merge(entries: commits)) unless commits.empty?
        end

        # Return all svn commits for a particular date range, which are touching
        #  somehow the critical files within the svn repo.
        # @todo #567:DEV Add more tests to ensure that changes in particular branch are visible
        def touch(files, opts)
          svn_log(opts).uniq.each do |e|
            e.paths.path.delete_if { |p| files.none? { |f| p.include? f } } if e.paths.path.respond_to? :delete_if
          end
        end

        # Return svn commits history for file(s) within particular date range in repo
        def svn_log(opts)
          now = if opts.key? "now"
                  DateTime.parse(opts["now"])
                else
                  DateTime.now
                end
          start = (now.to_time - opts["period"].to_i).to_datetime
          locations(opts).flat_map do |file|
            raw = OS.new.run "svn log --no-auth-cache",
                             "--username #{opts.decrypt('svn_user', 'svn_salt')}",
                             "--password #{opts.decrypt('svn_password', 'svn_salt')}",
                             "--xml -v -r {#{start}}:{#{now}} #{opts['svn_url']}/#{file}"
            Nokogiri.XML(raw, nil, "UTF-8")
                    .xpath("//logentry[paths/path]")
                    .map { |xml| to_entry(xml) }
          end
        end

        # Convert single revision(XML text) to entry object.
        # Entry object is a simple ruby struct object.
        def to_entry(xml)
          e = to_struct(Hash.from_xml(xml.to_s.strip)).logentry
          if e.paths.path.respond_to? :each
            e.paths.path.each(&:strip!)
          else
            e.paths.path.strip!
          end
          e
        end

        # Make a simple ruby struct object from hash hierarchically,
        #  considering nested hash(es) (if applicable)
        def to_struct(hsh)
          OpenStruct.new(
            hsh.transform_values { |v| v.is_a?(Hash) ? to_struct(v) : v }
          )
        end

        # Return for each file all his locations considering branches
        #   > locations('readme.md')
        #   branches/0.13.x/readme.md
        #   trunk/readme.md
        #
        # @todo #567/DEV Performance: improve the glob pattern to support multiple files.
        #  Right now in order to find all branches for a particular file we are using glob pattern
        #  - https://en.wikipedia.org/wiki/Glob_(programming)
        #  - https://stackoverflow.com/a/70950401/6916890
        #  - https://globster.xyz
        #  Right now for each file we initiate a separate search request, thus we need to think
        #  how to avoid this and send only one search request
        def locations(opts)
          opts.slice("files", ",").flat_map do |file|
            raw = OS.new.run "svn ls --no-auth-cache ",
                             "--username #{opts.decrypt('svn_user', 'svn_salt')}",
                             "--password #{opts.decrypt('svn_password', 'svn_salt')}",
                             "--xml -R --search \"#{file}\" #{opts['svn_url']}"
            Nokogiri.XML(raw, nil, "UTF-8")
                    .xpath("/lists/list/entry/name/text()")
                    .map { |f| f.to_s.strip }
          end
        end
      end
    end
  end
end
