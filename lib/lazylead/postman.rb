# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2022 Yurii Dubinka
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

require "zaru"
require "colorize"
require_relative "log"
require_relative "email"
require_relative "version"

module Lazylead
  #
  # A postman to send emails.
  #
  # @todo #/DEV Merge Smtp and Postman objects. There might be different
  #  postman's based on different mail servers, thus its better to keep together
  #  the instantiation and sending. For each type of mail servers we should have
  #  separate object.
  #
  # @todo #/DEV TestMail.deliveries -> store all emails to the files in
  #  /test/resources/testmailer/*.html. Right now after each test with email
  #  sending we taking the body and test it content. Quite ofter we need to
  #  check visual style in mails, etc, thus its better to store them on disk.
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Postman
    def initialize(log = Log.new)
      @log = log
    end

    # Send an email.
    # :opts   :: the mail configuration like to, from, cc, subject, template.
    def send(opts)
      if opts.msg_to.empty?
        @log.warn "ll-013: Email can't be sent to '#{opts.msg_to}," \
                  " more: '#{opts}'"
      else
        mail = make_email(opts)
        mail.deliver
        @log.debug "#{__FILE__} sent '#{mail.subject}' to '#{mail.to}'."
      end
    end

    # Construct an email based on input arguments
    def make_email(opts)
      mail = Mail.new
      mail.to opts.msg_to
      mail.from opts.msg_from
      mail.cc opts.msg_cc if opts.key? "cc"
      mail.subject opts["subject"]
      mail.html_part do
        content_type "text/html; charset=UTF-8"
        body opts.msg_body
      end
      opts.msg_attachments.each { |f| mail.add_file f }
      mail
    end
  end

  #
  # A postman that sends emails to the std out.
  #
  class StdoutPostman
    def initialize(log = Log.new)
      @log = log
    end

    # Send an email.
    # :opts   :: the mail configuration like to, from, cc, subject, template.
    def send(opts)
      if opts.msg_to.empty?
        p "Email can't be sent as 'to' is empty, more: '#{opts}'"
      else
        p "to=#{opts.msg_to}, from=#{opts.msg_from}, cc=#{opts.msg_cc}, " \
          "subject=#{opts['subject']}, attachments=#{opts.msg_attachments}, body=#{opts.msg_body}"
      end
    end
  end

  #
  # A postman that sends emails to the html file.
  # Use ENV['file_postman_dir'] to set a root directory.
  # By default
  #  ENV['file_postman_dir'] = "."
  #
  class FilePostman
    def initialize(log = Log.new, env = ENV.to_h)
      @log = log
      @env = env
    end

    # Send an email.
    # :opts   :: the mail configuration like to, from, cc, subject, template.
    def send(opts)
      if opts.msg_to.empty?
        @log.warn "ll-015: Email can't be sent as 'to' is empty, more: '#{opts}'"
        ""
      else
        file = filename(opts)
        File.open(file, "w") do |f|
          f.write "<!-- to=#{opts.msg_to}, from=#{opts.msg_from}, cc=#{opts.msg_cc}, " \
                  "subject=#{opts['subject']}, attachments=#{opts.msg_attachments} -->"
          f.write opts.msg_body
        end
        @log.debug "Mail '#{opts['subject']}' for #{opts.msg_to} sent to " \
                   "'#{file.to_s.colorize(:light_blue)}'"
        file
      end
    end

    # Assemble file name where email to be print
    def filename(opts)
      dir = @env.fetch("file_postman_dir", ".")
      FileUtils.mkdir_p(dir) unless File.exist?(dir)
      File.join(dir, Zaru.sanitize!("#{Time.now.nsec}-#{opts['subject']}.html"))
    end
  end
end
