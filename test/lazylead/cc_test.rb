# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2022 Yurii Dubinka
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

require_relative "../test"
require_relative "../../lib/lazylead/log"
require_relative "../../lib/lazylead/cli/app"
require_relative "../../lib/lazylead/cc"
require_relative "../../lib/lazylead/system/jira"

module Lazylead
  class CcTest < Lazylead::Test
    test "plain cc detected as text" do
      assert Lazylead::CC.new.plain? "a@fake.com,b@fake.com"
    end
    test "plain cc not found in text" do
      refute Lazylead::CC.new.plain? "justatext.com,eeeee.com"
    end
    test "plain cc detected as object" do
      assert Lazylead::CC.new.recognized? Lazylead::PlainCC.new("a@fake.com")
    end
    test "cc is incorrect" do
      refute Lazylead::CC.new.recognized? key: "value"
    end
    test "cc is not found in hash" do
      assert Lazylead::CC.new.undefined? key: "value"
    end
    test "cc type is blank" do
      assert Lazylead::CC.new.undefined? "type" => "    "
    end
  end

  class PlainCcTest < Lazylead::Test
    test "cc has valid email" do
      assert_equal "a@fake.com", Lazylead::PlainCC.new("a@fake.com").cc.first
    end

    test "cc has valid email despite on additional spaces" do
      assert_equal "a@fake.com", Lazylead::PlainCC.new("a@fake.com ").cc.first
    end

    test "cc has valid email despite on unexpected symbols" do
      assert_equal "a@f.com", Lazylead::PlainCC.new("a@f.com, , -").cc.first
    end

    test "cc has valid emails" do
      assert_equal %w[a@fake.com b@fake.com c@fake.com],
                   Lazylead::PlainCC.new("a@fake.com,b@fake.com,c@fake.com").cc
    end

    test "cc count is correct" do
      assert_equal 3, Lazylead::PlainCC.new("a@f.com,b@f.com,c@f.com").count
    end

    test "cc behaves as array" do
      assert_equal %w[A@f.com B@f.com C@f.com],
                   Lazylead::PlainCC.new("a@f.com,b@f.com,c@f.com")
                                    .map(&:capitalize)
    end
  end

  class PredefinedCcTest < Lazylead::Test
    test "predefined cc has valid emails" do
      assert_entries(
        {
          "jdbc" => %w[j@fake.com],
          "jvm" => %w[j@fake.com v@fake.com]
        },
        PredefinedCC.new(
          "jdbc" => "j@fake.com ",
          "jvm" => "j@fake.com,,v@fake.com"
        ).to_h
      )
    end

    test "all predefined cc are valid emails" do
      assert_equal %w[j@fake.com v@fake.com m@fake.com],
                   PredefinedCC.new(
                     "jdbc" => "j@fake.com ",
                     "jvm" => "j@fake.com,,v@fake.com,-, ,m@fake.com"
                   ).cc
    end

    test "cc by key is found" do
      assert_equal %w[j@fake.com],
                   PredefinedCC.new(
                     "jdbc" => "j@fake.com ",
                     "jvm" => "j@fake.com,,v@fake.com,-, ,m@fake.com"
                   )["jdbc"]
    end

    # @todo #/DEV The test has performance issue. Jira has no way how to take
    #  the emails for leads quickly due to https://bit.ly/2ZRZlWc.
    #  Thus, for each component we need to find a lead, and only then detect
    #  lead's email, thus, its took few minutes for huge projects.
    test "cc by component is found" do
      skip "Disabled due to performance issue with Jira API"
      assert_equal ENV.fetch("cc_email", nil),
                   ComponentCC.new(
                     ENV.fetch("cc_project", nil),
                     Jira.new(
                       {
                         username: ENV.fetch("JIRA_USER", nil),
                         password: ENV.fetch("JIRA_PASS", nil),
                         site: ENV.fetch("JIRA_URL", nil),
                         context_path: ""
                       }
                     )
                   ).cc(ENV.fetch("cc_component", nil))
    end

    test "detect plain cc" do
      CLI::App.new(Log.new, NoSchedule.new).run(
        home: ".",
        sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
        vcs4sql: "upgrades/sqlite",
        testdata: true
      )
      assert_equal %w[leelakenny@mail.com maciecrane@mail.com],
                   ORM::Task.find(3).detect_cc(nil)["cc"].cc
    end

    test "detect complex cc by predefined component" do
      CLI::App.new(Log.new, NoSchedule.new).run(
        home: ".",
        sqlite: "test/resources/#{no_ext(__FILE__)}.#{__method__}.db",
        vcs4sql: "upgrades/sqlite",
        testdata: true
      )
      assert_equal %w[tom@fake.com mike@fake.com],
                   ORM::Task.find(165).detect_cc(nil)["cc"].cc("jvm", "jdbc")
    end
  end
end
