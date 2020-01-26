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
require_relative "../../../lib/lazylead/cli/start"
require_relative "../../../lib/lazylead/orm/model"

module Lazylead
  module CLI
    class StartTest < Lazylead::SqliteTest
      test "LL database structure installed successfully" do
        file = "test/resources/#{no_ext(__FILE__)}.#{__method__}.db"
        stdout = capture_io do
          Lazylead::CLI::Start.new(log).run(
            home: ".",
            sqlite: file,
            vcs4sql: "upgrades/sqlite",
            testdata: true
          )
        end
        assert_tables(
          {
            persons: %w[id name email],
            teams: %w[id name lead properties],
            cc: %w[id team_id person_id],
            systems: %w[id name properties],
            tasks: %w[id name cron system action team_id description enabled],
            properties: %w[key value type]
          },
          file
        )
        assert_fk %w[cc team_id team id],
                  %w[cc person_id person id],
                  %w[tasks system system id],
                  %w[tasks team_id team id],
                  %w[teams lead person id],
                  file
        assert_equal "https://jira.spring.io",
                     Lazylead::ORM::System.find(1).name,
                     "Required system record wasn't found in the database"
        assert_match "Lazylead::Task::Echo id='1', name='BA squad', lead='4'",
                     stdout.join,
                     "App stdout has required record about executed task"
      end
    end
  end
end
