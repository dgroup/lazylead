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

require "json"
require "rufus-scheduler"
require_relative "orm/model"

module Lazylead
  # The tasks schedule
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Schedule
    def initialize(log: FakeLog.new, trgr: Rufus::Scheduler.new, cling: true)
      @log = log
      @cling = cling
      @trigger = trgr
    end

    # @todo #/DEV error code is required for reach 'raise' statement within the
    #  application.
    def register(task)
      raise "task can't be a null" if task.nil?

      @trigger.cron task.cron do
        task.exec
      end
    end

    # @todo #/DEV inspect the current execution status. This method should
    #  support several format for output, by default is `json`.
    def ps
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
end
