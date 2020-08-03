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
    include Emailing

    def initialize(log = Log.new)
      @log = log
    end

    # Send an email.
    # :opts   :: the mail configuration like to, from, cc, subject, template.
    def send(opts)
      html = make_body(opts)
      mail = Mail.new
      mail.to opts[:to] || opts["to"]
      mail.from opts["from"]
      mail.cc opts["cc"] if opts.key? "cc"
      mail.subject opts["subject"]
      mail.html_part do
        content_type "text/html; charset=UTF-8"
        body html
      end
      add_attachments mail, opts
      mail.deliver
      @log.debug "Email was generated from #{opts} and send by #{__FILE__}. " \
                 "Here is the body: #{html}"
    end

    def add_attachments(mail, opts)
      return unless opts.key? "attachments"
      opts["attachments"].select { |a| File.file? a }
                         .each { |a| mail.add_file a }
    end
  end
end
