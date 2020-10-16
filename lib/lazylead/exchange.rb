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

require "viewpoint"
require_relative "log"
require_relative "salt"
require_relative "email"
require_relative "version"

module Lazylead
  #
  # A postman to send emails to the Microsoft Exchange server.
  #
  # @todo #/DEV Add support of symbols for options in order to use both
  #  notations like opts[:endpoint] or opts["endpoint"].
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Exchange
    include Emailing

    def initialize(
      log = Log.new, salt = Salt.new("exchange_salt"), opts = ENV.to_h
    )
      @log = log
      @salt = salt
      @opts = opts
    end

    # Send an email.
    # :opts   :: the mail configuration like from, cc, subject, template.
    def send(opts)
      to = opts["to"] || opts[:to]
      to = [to] unless to.is_a? Array
      if to.reject { |e| e.nil? || e.blank? }.empty?
        @log.warn "Email can't be sent to '#{to}, more: '#{opts}'"
        return
      end
      msg = make_msg(to, opts)
      msg.update(cc_recipients: opts["cc"]) if opts.key? "cc"
      add_attachments(msg, opts)
      cli.send_message msg
      close_attachments msg
      @log.debug "#{__FILE__} sent '#{opts['subject']}' to '#{to}'."
    end

    def make_msg(to, opts)
      {
        subject: opts["subject"],
        body: make_body(opts),
        body_type: "HTML",
        to_recipients: to
      }
    end

    def add_attachments(msg, opts)
      return unless opts.key? "attachments"
      files = split("attachments", opts).map { |f| File.open(f, "r") }
      msg[:file_attachments] = files
    end

    def close_attachments(msg)
      return if msg[:file_attachments].nil? || msg[:file_attachments].empty?
      msg[:file_attachments].each(&:close)
    end

    private

    def cli
      return @cli if defined? @cli
      url = @opts["exchange_url"]
      usr = @opts["exchange_user"]
      psw = @opts["exchange_password"]
      usr = @salt.decrypt(usr) if @salt.specified?
      psw = @salt.decrypt(psw) if @salt.specified?
      @log.debug "Connect to MS Exchange server #{url} as '#{usr}'"
      @cli = Viewpoint::EWSClient.new url, usr, psw
    end
  end
end
