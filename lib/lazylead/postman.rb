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
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Postman
    include Emailing

    def initialize(log = Log::NOTHING)
      @log = log
    end

    # Send an email.
    # :opts   :: the mail configuration like to, from, cc, subject, template.
    def send(opts)
      html = make_body(opts)
      cc = cc(opts)
      Mail.deliver do
        to opts[:to] || opts["to"]
        from opts["from"]
        cc cc if opts.key? "cc"
        subject opts["subject"]
        html_part do
          content_type "text/html; charset=UTF-8"
          body html
        end
      end
      @log.debug "Email was generated from #{opts} and send by #{__FILE__}. " \
                 "Here is the body: #{html}"
    end

    def cc(opts)
      cc = opts["cc"]
      cc = split("cc", opts) if !cc.nil? && cc.include?(",")
      cc
    end
  end
end
