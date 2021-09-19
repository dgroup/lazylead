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

require "active_support"
require "rufus-scheduler"
require_relative "log"
require_relative "model"

module Lazylead
  # The tasks schedule
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Schedule
    def initialize(log: Log.new, cling: true, trigger: Rufus::Scheduler.new)
      @log = log
      @cling = cling
      @trigger = trigger
    end

    # @todo #/DEV error code is required for each 'raise' statement within the
    #  application. Align the naming of existing one, the error code should be
    #  like ll-xxx.
    def register(task)
      raise "ll-002: task can't be a null" if task.nil?
      @trigger.method(task.type).call(task.unit) do
        ActiveRecord::Base.connection_pool.with_connection do
          if task.props.key? "no_logs"
            ORM::Retry.new(task, @log).exec
          else
            ORM::Retry.new(
              ORM::Verbose.new(task, @log),
              @log
            ).exec
          end
        end
      end
      @log.debug "Task scheduled: #{task}"
    end

    # @todo #/DEV inspect the current execution status. This method should
    #  support several format for output, by default is `json`.
    def ps
      @log.debug "#{self}#ps"
    end

    def join
      @trigger.join if @cling
    end

    # @todo #/DEV stop the execution of current jobs (shutdown?).
    #  The test is required.
    def stop
      @trigger.shutdown(:kill)
    end
  end

  # Fake application schedule for unit testing purposes
  class NoSchedule
    def initialize(log = Log.new)
      @log = log
    end

    def register(task)
      @log.debug "Task registered: #{task}"
    end

    def ps
      @log.debug "#{self}#ps"
    end

    def join
      @log.debug "#{self}#join"
    end
  end
end
