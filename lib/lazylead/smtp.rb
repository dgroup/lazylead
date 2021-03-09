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

require "mail"
require "colorize"
require_relative "log"
require_relative "salt"

module Lazylead
  #
  # The emails configuration over SMTP protocol.
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Smtp
    def initialize(log = Log.new, salt = NoSalt.new, opts = {})
      @log = log
      @salt = salt
      @opts = opts
    end

    def enable
      if @opts.empty? || @opts[:test_mode] || @opts[:smtp_host].blank?
        Mail.defaults do
          delivery_method :test
        end
        @log.warn "SMTP connection enabled in " \
                  "#{'test'.colorize(:light_yellow)} mode."
      else
        setup_smtp
      end
    end

    private

    def setup_smtp
      host = @opts[:smtp_host]
      port = @opts[:smtp_port]
      user = decrypted(:smtp_user)
      pass = decrypted(:smtp_pass)
      Mail.defaults do
        delivery_method :smtp,
                        address: host,
                        port: port,
                        user_name: user,
                        password: pass,
                        authentication: "plain",
                        enable_starttls_auto: true
      end
      @log.debug "SMTP connection established with #{host} as #{user}."
    end

    # Decrypt the value of configuration property using cryptography salt.
    def decrypted(key)
      if @salt.specified?
        @salt.decrypt(@opts[key])
      else
        @opts[key]
      end
    end
  end
end
