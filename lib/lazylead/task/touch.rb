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

require "nokogiri"
require "active_support/core_ext/hash/conversions"
require_relative "../salt"
require_relative "../opts"

module Lazylead
  module Task
    #
    # Send notification about modification of critical files in svn repo.
    #
    class SvnTouch
      def initialize(log = Log.new)
        @log = log
      end

      def run(_, postman, opts)
        files = opts.slice("files", ",")
        commits = touch(files, opts)
        postman.send(opts.merge(entries: commits)) unless commits.empty?
      end

      # Return all svn commits for a particular date range, which are touching
      #  somehow the critical files within the svn repo.
      def touch(files, opts)
        xpath = files.map { |f| "contains(text(),\"#{f}\")" }.join(" or ")
        svn_log(opts).xpath("//logentry[paths/path[#{xpath}]]")
                     .map(&method(:to_entry))
                     .each do |e|
          if e.paths.path.respond_to? :delete_if
            e.paths.path.delete_if { |p| files.none? { |f| p.include? f } }
          end
        end
      end

      # Return all svn commits for particular date range in repo
      def svn_log(opts)
        now = if opts.key? "now"
                DateTime.parse(opts["now"])
              else
                DateTime.now
              end
        start = (now.to_time - opts["period"].to_i).to_datetime
        cmd = [
          "svn log --no-auth-cache",
          "--username #{decrypt(opts['svn_user'])}",
          "--password #{decrypt(opts['svn_password'])}",
          "--xml -v -r {#{start}}:{#{now}} #{opts['svn_url']}"
        ]
        raw = `#{cmd.join(" ")}`
        Nokogiri.XML(raw, nil, "UTF-8")
      end

      # Decrypt text using cryptography salt
      def decrypt(text, sid = "svn_salt")
        return Salt.new(sid).decrypt(text) if ENV.key? sid
        text
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
    end
  end
end
