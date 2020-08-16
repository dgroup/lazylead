# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2020 Yurii Dubinka
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"],
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

require_relative "../../sqlite_test"
require_relative "../../../lib/lazylead/log"
require_relative "../../../lib/lazylead/cli/app"
require_relative "../../../lib/lazylead/model"

module Lazylead
  module CLI
    class AppTest < Lazylead::SqliteTest
      test "LL database structure installed successfully" do
        CLI::App.new(Log.new, NoSchedule.new).run(
          home: ".",
          sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
          vcs4sql: "upgrades/sqlite"
        )
        assert_tables "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
                      systems: %w[id properties],
                      teams: %w[id name properties],
                      tasks: %w[id name schedule system action team_id enabled properties]
        assert_fk "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
                  %w[tasks team_id teams id],
                  %w[tasks system systems id]
      end

      test "activesupport is activated for access to domain entities" do
        CLI::App.new(Log.new, NoSchedule.new).run(
          home: ".",
          sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
          vcs4sql: "upgrades/sqlite",
          testdata: true
        )
        assert_equal "BA squad",
                     ORM::Team.find(1).name,
                     "Required team record wasn't found in the database"
      end

      test "scheduled task was triggered successfully" do
        CLI::App.new(Log.new, Schedule.new(cling: false)).run(
          home: ".",
          sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
          vcs4sql: "upgrades/sqlite",
          testdata: true
        )
        sleep 0.4
        assert (Time.now - 5.seconds) < Time.parse(File.open("test/resources/echo.txt").first),
               "Scheduled task wasn't executed few seconds ago"
      end
    end
  end
end
