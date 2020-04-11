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

require "mail"

module Lazylead
  #
  # The emails configuration over SMTP protocol.
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Smtp
    def initialize(log = Log::NOTHING, salt = NoSalt.new)
      @log = log
      @salt = salt
    end

    def enable(opts = {})
      if opts.empty? || opts[:test_mode]
        Mail.defaults do
          delivery_method :test
        end
        @log.debug("SMTP connection enabled in test mode.")
      else
        setup_smtp opts
      end
    end

    private

    def setup_smtp(opts)
      opts[:smtp_user] = @salt.decrypt(opts[:smtp_user]) if @salt.specified?
      opts[:smtp_pass] = @salt.decrypt(opts[:smtp_pass]) if @salt.specified?
      Mail.defaults do
        delivery_method :smtp,
                        address: opts[:smtp_host],
                        port: opts[:smtp_port],
                        user_name: opts[:smtp_user],
                        password: opts[:smtp_pass],
                        authentication: "plain",
                        enable_starttls_auto: true
      end
      @log.debug("SMTP connection established with #{opts[:smtp_host]}")
    end
  end
end
