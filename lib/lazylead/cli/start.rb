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

require_relative "../schedule"
require_relative "../../../../vcs4sql/lib/vcs4sql/sqlite/migration"

module Lazylead
  module CLI
    class Start
      def initialize(log, schedule = Lazylead::Schedule.new)
        @log = log
        @schedule = schedule
      end

      # @todo #/DEV Use vcs4sql from rubygems.org instead of local build.
      #  For now vcs4sql wasn't released yet.
      #  Also, the vcs4sql should be removed from ./Gemfile.
      def run(opts)
        @opts = opts
        apply_vcs_migration
        enable_active_record
        schedule_tasks
      end

      private

      def apply_vcs_migration
        @db = File.expand_path(@opts[:home]) + "/" + @opts[:sqlite]
        vcs = File.expand_path(@opts[:home]) + "/" + @opts[:vcs4sql]
        Vcs4sql::Sqlite::Migration.new(@db).upgrade vcs, @opts[:testdata]
      end

      def enable_active_record
        ActiveRecord::Base.establish_connection(
          adapter: "sqlite3",
          database: @db
        )
      end

      def schedule_tasks
        Lazylead::ORM::Task.where(enabled: "true").find_each do |task|
          @schedule.register task
        end
        @schedule.join
      end
    end
  end
end
