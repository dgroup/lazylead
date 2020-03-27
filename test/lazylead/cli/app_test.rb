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
require_relative "../../../lib/lazylead/orm/model"
require_relative "../../../lib/lazylead/orm/team"

module Lazylead
  module CLI
    class AppTest < Lazylead::SqliteTest
      test "LL database structure installed successfully" do
        file = "test/resources/#{no_ext(__FILE__)}.#{__method__}.db"
        CLI::App.new(Log::NOTHING, Schedule.new).run(
          home: ".",
          sqlite: file,
          vcs4sql: "upgrades/sqlite"
        )
        assert_tables(
          {
            persons: %w[id name email],
            teams: %w[id name lead properties],
            cc: %w[id team_id person_id],
            systems: %w[id properties],
            tasks: %w[id name cron system action team_id description enabled
                      properties],
            properties: %w[key value type]
          },
          file
        )
        assert_fk %w[cc team_id team id],
                  %w[cc person_id persons id],
                  %w[tasks system systems id],
                  %w[tasks team_id teams id],
                  %w[teams lead persons id],
                  file
      end

      test "activesupport is activated for access to domain entities" do
        CLI::App.new(Log::NOTHING, Schedule.new).run(
          home: ".",
          sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
          vcs4sql: "upgrades/sqlite",
          testdata: true
        )
        assert_equal "BA squad",
                     ORM::Team.find(1).name,
                     "Required team record wasn't found in the database"
      end

      # @todo #10/DEV Think about using "timecop" >v0.9.1 gem in order to make
      #  E2E application skeleton https://stackoverflow.com/questions/59955571.
      #  The depedency for gemspec should be after *thin* in .gemspec
      #  ..
      #  s.add_runtime_dependency "thin", "1.7.2"
      #  s.add_runtime_dependency "timecop", "0.9.1"
      #  ..
      #  More https://github.com/travisjeffery/timecop
      test "scheduled task was triggered successfully" do
        skip "Not implemented yet"
      end
    end
  end
end
