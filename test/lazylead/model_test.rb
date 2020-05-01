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

require_relative "../sqlite_test"
require_relative "../../lib/lazylead/model"
require_relative "../../lib/lazylead/cli/app"

module Lazylead
  class OrmTest < Lazylead::SqliteTest
    test "convert column to json" do
      CLI::App.new(Log::NOTHING).run(
        home: ".",
        sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
        vcs4sql: "upgrades/sqlite",
        testdata: true
      )
      assert_equal "${usr}", ORM::Team.find(1).to_j["usr"]
    end

    test "env properties injected" do
      ENV["usr"] = "Mike"
      CLI::App.new(Log::NOTHING).run(
        home: ".",
        sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
        vcs4sql: "upgrades/sqlite",
        testdata: true
      )
      assert_equal "Mike", ORM::Team.find(1).env(ORM::Team.find(1).to_j)["usr"]
    end
  end
end