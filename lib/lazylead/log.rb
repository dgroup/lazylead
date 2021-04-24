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

require "logging"
require "colorize"
require "forwardable"

module Lazylead
  # The main application logger
  class Log
    extend Forwardable
    def_delegators :@log, :debug, :info, :warn, :error

    def initialize(log = Lazylead::Level::ERRORS)
      @log = log
      @log = Lazylead::Level::DEBUG if ARGV.include? "--trace"
    end

    def nothing
      @log = Lazylead::Level::NOTHING
      self
    end

    def verbose
      @log = Lazylead::Level::DEBUG
      self
    end
  end

  # Predefined logging levels.
  #
  # There are 3 colored loggers so far:
  #  NOTHING - for cases when logging isn't required
  #  VERBOSE - all logging levels including debug
  #  ERRORS - for errors only which are critical for app.
  #
  module Level
    # Coloring configuration for appender(s).
    Logging.color_scheme("bright",
                         levels: {
                           info: :green,
                           warn: :yellow,
                           error: :red,
                           fatal: %i[white on_red]
                         },
                         date: :blue,
                         logger: :cyan)
    Logging.appenders.stdout(
      "stdout",
      layout: Logging.layouts.pattern(
        pattern: "[%d] %-5l #{'[%X{tid}]'.colorize(:light_green)} %m\n",
        color_scheme: "bright"
      )
    )

    if ARGV.include? "--log-file"
      name = ARGV[ARGV.find_index("--log-file") + 1]
      age = "daily"
      age = ARGV[ARGV.find_index("--rolling-age") + 1] if ARGV.include? "--rolling-age"
      files = 7
      files = ARGV[ARGV.find_index("--rolling-files") + 1] if ARGV.include? "--rolling-files"
      FILE_APPENDER = Logging.appenders.rolling_file("file", filename: name, age: age, keep: files)
    end

    # Nothing to log
    NOTHING = Logging.logger["nothing"]
    NOTHING.level = :off
    NOTHING.freeze

    # All levels including debug
    DEBUG = Logging.logger["debug"]
    DEBUG.level = :debug
    DEBUG.add_appenders "stdout"
    DEBUG.add_appenders(FILE_APPENDER) if ARGV.include? "--log-file"
    DEBUG.freeze

    # Alerts/errors
    ERRORS = Logging.logger["errors"]
    ERRORS.level = :error
    ERRORS.add_appenders "stdout"
    ERRORS.add_appenders(FILE_APPENDER) if ARGV.include? "--log-file"
    ERRORS.freeze
  end
end
