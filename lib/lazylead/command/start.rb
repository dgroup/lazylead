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

require_relative "../../lazylead/schedule"
require "vcs4sql"

# Show particular task details
module Lazylead
  # Show particular task details
  class Start
    def initialize(conn:, log: FakeLog::NULL)
      @conn = conn
      @log = log
    end

    def run(args: [])
      opts = Slop.parse(args, help: true, suppress_errors: true) do |o|
        o.banner = "Usage: lazylead start [options]"
        o.string "--detach",
                 "Detached mode: Schedule all tasks in the background.",
                 require: true, default: true
        o.bool "--help", "Print instructions"
      end
      Vcs4sql::Migration.new(@conn).upgrade
      to_remove(opts)
    end

    # @todo #/DEV Remove this method as its for debug purpose only for quick
    #  development/debug
    def to_remove(opts)
      @conn.query("select * from changelog").each { |r| @log.debug(r) }
      puts opts
      # tasks = Lazylead::Tasks.new(@conn)
      # tasks.load
      # schedule = Lazylead::Schedule.new
      # puts "#{schedule.schedule(tasks)}"
    end
  end
end
