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

require_relative "../../test"
require_relative "../../sqlite_test"
require_relative "../../../lib/lazylead/cli/start"

module Lazylead
  module CLI
    class StartTest < Lazylead::SqliteTest
      test "LL database structure installed successfully" do
        file = "test/resources/#{no_ext(__FILE__)}.#{__method__}.db"
        Lazylead::CLI::Start.new(log).run(
          home: ".",
          sqlite: file,
          vcs4sql: "upgrades/sqlite"
        )
        assert_tables(
          {
            person: %w[id name email],
            team: %w[id name lead properties],
            cc: %w[id team_id person_id],
            system: %w[id name properties],
            task: %w[id name cron system action team_id description],
            properties: %w[key value type]
          },
          file
        )
        assert_fk(
          %w[cc team_id team id],
          %w[cc person_id person id],
          %w[task system system id],
          %w[task team_id team id],
          %w[team lead person id],
          file
        )
      end
    end
  end
end
