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

require "zip"
require "tempfile"
require "nokogiri"
require "backtrace"
require "active_support/core_ext/hash/conversions"
require_relative "../../salt"
require_relative "../../opts"

module Lazylead
  module Task
    module Svn
      #
      # Send notification about modification of svn files since particular
      #  revision.
      #
      class Diff
        def initialize(log = Log.new)
          @log = log
        end

        def run(_, postman, opts)
          cmd = [
            "svn log --diff --no-auth-cache",
            "--username #{opts.decrypt('svn_user', 'svn_salt')}",
            "--password #{opts.decrypt('svn_password', 'svn_salt')}",
            "-r#{opts['since_rev']}:HEAD #{opts['svn_url']}"
          ]
          stdout = `#{cmd.join(" ")}`
          stdout.scrub!
          send_email postman, opts.merge(stdout: stdout) unless stdout.blank?
        end

        # Send email with svn log as an attachment.
        # The attachment won't be stored locally and we'll be removed once
        #  mail sent.
        def send_email(postman, opts)
          Dir.mktmpdir do |dir|
            name = "svn-log-#{Date.today.strftime('%d-%b-%Y')}.html"
            begin
              postman.send opts.merge(attachments: [to_f(File.join(dir, name), opts)])
            ensure
              FileUtils.rm_rf("#{dir}/*")
            end
          rescue StandardError => e
            @log.error "ll-010: Can't send an email '#{opts['subject']}' to #{opts['to']} due to " \
                       "#{Backtrace.new(e)}'"
          end
        end

        # Wrap attachment content to a *.zip file and archive.
        #   to_f('my-content.html', opts)   => my-content.html.zip
        #
        # You may disable archiving option by passing option *no_archive*
        #   to_f('my-content.html', "no_archive" => true)
        def to_f(path, opts)
          if opts.key? "no_archive"
            f = File.open(path, "w")
            body = opts.msg_body("template-attachment")
          else
            f = File.new("#{path}.zip", "wb")
            bytes = Zip::OutputStream.write_buffer do |zio|
              zio.put_next_entry(File.basename(path))
              zio.write opts.msg_body("template-attachment")
            end
            bytes.rewind # reposition buffer pointer to the beginning
            body = bytes.sysread
          end
          f.write body
          f.close
          f.path
        end
      end
    end
  end
end
