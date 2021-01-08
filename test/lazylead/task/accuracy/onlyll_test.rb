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

require_relative "../../../test"
require_relative "../../../../lib/lazylead/opts"
require_relative "../../../../lib/lazylead/smtp"
require_relative "../../../../lib/lazylead/postman"
require_relative "../../../../lib/lazylead/system/jira"
require_relative "../../../../lib/lazylead/task/accuracy/onlyll"

module Lazylead
  class OnlyLLTest < Lazylead::Test
    # In current tests the grid label is 'PullRequest'.
    # The default grid labels are 0%, 10%, 20%, etc., the reason why
    # 'PullRequest' label is used here as we don't have 0%, 10%, etc.
    # on https://jira.spring.io.
    test "grid label found" do
      assert Labels.new(
        NoAuthJira.new("https://jira.spring.io").issues("key=XD-3725").first,
        Opts.new("grid" => "PullRequest,  ,")
      ).exists?
    end

    test "grid label set by ll" do
      assert Labels.new(
        NoAuthJira.new("https://jira.spring.io")
                  .issues("key=XD-3725", expand: "changelog")
                  .first,
        Opts.new("grid" => "PullRequest", "author" => "grussell")
      ).valid?
    end

    test "email notification" do
      Lazylead::Smtp.new.enable
      Lazylead::Task::OnlyLL.new.run(
        NoAuthJira.new("https://jira.spring.io"),
        Postman.new,
        Opts.new(
          "from" => "ll@fake.com",
          "to" => "lead@fake.com",
          "grid" => "PullRequest",
          "author" => "LL",
          "jql" => "key=XD-3725",
          "max_results" => 200,
          "subject" => "[LL] Only",
          "fields" => "priority,summary,reporter,labels",
          "template" => "lib/messages/only_ll.erb"
        )
      )
      assert_email "[LL] Only",
                   %w[XD-3725 Blocker EmbeddedHeadersMessageConverter]
    end

    test "detect score" do
      assert_equal "PullRequest",
                   Labels.new(
                     NoAuthJira.new("https://jira.spring.io")
                               .issues("key=XD-3725", expand: "changelog")
                               .first,
                     Opts.new(
                       "grid" => "PullRequest",
                       "author" => "grussell"
                     )
                   ).score
    end

    test "multiple scores in the same ticket" do
      assert_equal "10%",
                   Labels.new(
                     Struct.new(:key) do
                       def history
                         [{ "id" => "287906", "author" => { "self" => "https://jira.spring.io/rest/api/2/user?username=sy", "name" => "sy", "key" => "sy", "emailAddress" => "san at pivotal dot io", "avatarUrls" => { "48x48" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=48", "24x24" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=24", "16x16" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=16", "32x32" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=32" }, "displayName" => "sy an", "active" => true, "timeZone" => "America/Los_Angeles" }, "created" => "2015-12-17T18:12:35.853+0000", "items" => [{ "field" => "Fix Version", "fieldtype" => "jira", "from" => nil, "fromString" => nil, "to" => "15424", "toString" => "1.3.1" }] }, { "id" => "287913", "author" => { "self" => "https://jira.spring.io/rest/api/2/user?username=ll", "name" => "ll", "key" => "ll", "emailAddress" => "ll at pivotal dot io", "avatarUrls" => { "48x48" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=48", "24x24" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=24", "16x16" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=16", "32x32" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=32" }, "displayName" => "Y LL", "active" => true, "timeZone" => "America/New_York" }, "created" => "2015-12-17T18:14:34.085+0000", "items" => [{ "field" => "assignee", "fieldtype" => "jira", "from" => nil, "fromString" => nil, "to" => "ll", "toString" => "Y LL" }] }, { "id" => "287915", "author" => { "self" => "https://jira.spring.io/rest/api/2/user?username=sy", "name" => "sy", "key" => "sy", "emailAddress" => "san at pivotal dot io", "avatarUrls" => { "48x48" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=48", "24x24" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=24", "16x16" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=16", "32x32" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=32" }, "displayName" => "sy an", "active" => true, "timeZone" => "America/Los_Angeles" }, "created" => "2015-12-17T18:19:36.118+0000", "items" => [{ "field" => "Sprint", "fieldtype" => "custom", "from" => nil, "fromString" => nil, "to" => "106", "toString" => "Sprint 64" }] }, { "id" => "287916", "author" => { "self" => "https://jira.spring.io/rest/api/2/user?username=sy", "name" => "sy", "key" => "sy", "emailAddress" => "san at pivotal dot io", "avatarUrls" => { "48x48" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=48", "24x24" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=24", "16x16" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=16", "32x32" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=32" }, "displayName" => "sy an", "active" => true, "timeZone" => "America/Los_Angeles" }, "created" => "2015-12-17T18:19:36.162+0000", "items" => [{ "field" => "Rank", "fieldtype" => "custom", "from" => "", "fromString" => "", "to" => "", "toString" => "Ranked higher" }] }, { "id" => "287921", "author" => { "self" => "https://jira.spring.io/rest/api/2/user?username=ll", "name" => "ll", "key" => "ll", "emailAddress" => "ll at pivotal dot io", "avatarUrls" => { "48x48" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=48", "24x24" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=24", "16x16" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=16", "32x32" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=32" }, "displayName" => "Y LL", "active" => true, "timeZone" => "America/New_York" }, "created" => "2015-12-17T18:30:47.508+0000", "items" => [{ "field" => "status", "fieldtype" => "jira", "from" => "10000", "fromString" => "To Do", "to" => "3", "toString" => "In Progress" }] }, { "id" => "287922", "author" => { "self" => "https://jira.spring.io/rest/api/2/user?username=ll", "name" => "ll", "key" => "ll", "emailAddress" => "ll at pivotal dot io", "avatarUrls" => { "48x48" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=48", "24x24" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=24", "16x16" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=16", "32x32" => "https://www.gravatar.com/avatar/0037f772e271b0d90bd62361768cb820?d=mm&s=32" }, "displayName" => "Y LL", "active" => true, "timeZone" => "America/New_York" }, "created" => "2015-12-17T18:31:54.137+0000", "items" => [{ "field" => "Pull Request URL", "fieldtype" => "custom", "from" => nil, "fromString" => nil, "to" => nil, "toString" => "https://github.com/spring-projects/spring-xd/pull/1872" }, { "field" => "labels", "fieldtype" => "jira", "from" => nil, "fromString" => "", "to" => nil, "toString" => "10% 20%" }] }, { "id" => "288214", "author" => { "self" => "https://jira.spring.io/rest/api/2/user?username=sy", "name" => "sy", "key" => "sy", "emailAddress" => "san at pivotal dot io", "avatarUrls" => { "48x48" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=48", "24x24" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=24", "16x16" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=16", "32x32" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=32" }, "displayName" => "sy an", "active" => true, "timeZone" => "America/Los_Angeles" }, "created" => "2015-12-25T00:16:09.649+0000", "items" => [{ "field" => "status", "fieldtype" => "jira", "from" => "3", "fromString" => "In Progress", "to" => "10006", "toString" => "In PR" }] }, { "id" => "288215", "author" => { "self" => "https://jira.spring.io/rest/api/2/user?username=sy", "name" => "sy", "key" => "sy", "emailAddress" => "san at pivotal dot io", "avatarUrls" => { "48x48" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=48", "24x24" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=24", "16x16" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=16", "32x32" => "https://www.gravatar.com/avatar/f0373ebca801ca4b2746732b451f497c?d=mm&s=32" }, "displayName" => "sy an", "active" => true, "timeZone" => "America/Los_Angeles" }, "created" => "2015-12-25T00:16:17.499+0000", "items" => [{ "field" => "Actual Story Points", "fieldtype" => "custom", "from" => nil, "fromString" => nil, "to" => nil, "toString" => "1" }, { "field" => "resolution", "fieldtype" => "jira", "from" => nil, "fromString" => nil, "to" => "8", "toString" => "Complete" }, { "field" => "status", "fieldtype" => "jira", "from" => "10006", "fromString" => "In PR", "to" => "10001", "toString" => "Done" }] }]
                       end
                     end.new("XD-3725"),
                     Opts.new("grid" => "10%,20%,30%", "author" => "ll")
                   ).score
    end

    test "sort of percents" do
      assert_equal %w[10% 20% 30%], %w[30% 10% 20%].sort
    end

    test "ensure that violators found" do
      assert_equal "Aron set 40%",
                   Labels.new(
                     Struct.new(:key) do
                       def history
                         [
                           { "author" => { "name" => "sy", "key" => "sy", "displayName" => "S N" }, "items" => [{ "field" => "Fix Version", "fieldtype" => "jira", "from" => nil, "fromString" => nil, "to" => "15424", "toString" => "1.3.1" }] },
                           { "author" => { "name" => "ll", "key" => "ll", "displayName" => "L L" }, "items" => [{ "field" => "assignee", "fieldtype" => "jira", "from" => nil, "fromString" => nil, "to" => "ll", "toString" => "ll" }] },
                           { "author" => { "name" => "sy", "key" => "sy", "displayName" => "S N" }, "items" => [{ "field" => "Sprint", "fieldtype" => "custom", "from" => nil, "fromString" => nil, "to" => "106", "toString" => "Sprint 64" }] },
                           { "author" => { "name" => "sy", "key" => "sy", "displayName" => "S N" }, "items" => [{ "field" => "Rank", "fieldtype" => "custom", "from" => "", "fromString" => "", "to" => "", "toString" => "Ranked higher" }] },
                           { "author" => { "name" => "ll", "key" => "ll", "displayName" => "L L" }, "items" => [{ "field" => "status", "fieldtype" => "jira", "from" => "10000", "fromString" => "To Do", "to" => "3", "toString" => "In Progress" }] },
                           { "author" => { "name" => "ll", "key" => "ll", "displayName" => "L L" }, "items" => [{ "field" => "assignee", "fieldtype" => "jira", "from" => nil, "fromString" => nil, "to" => "ll", "toString" => "ll" }, { "field" => "labels", "fieldtype" => "jira", "from" => nil, "fromString" => "", "to" => nil, "toString" => "20%" }] },
                           { "author" => { "name" => "sy", "key" => "sy", "displayName" => "S N" }, "items" => [{ "field" => "Actual Story Points", "fieldtype" => "custom", "from" => nil, "fromString" => nil, "to" => nil, "toString" => "1" }, { "field" => "resolution", "fieldtype" => "jira", "from" => nil, "fromString" => nil, "to" => "8", "toString" => "Complete" }, { "field" => "status", "fieldtype" => "jira", "from" => "10006", "fromString" => "In PR", "to" => "10001", "toString" => "Done" }] },
                           { "author" => { "name" => "ap", "key" => "ap", "displayName" => "Aron" }, "items" => [{ "field" => "labels", "fieldtype" => "jira", "from" => nil, "fromString" => "", "to" => nil, "toString" => "abc 40%" }] },
                           { "author" => { "name" => "sy", "key" => "sy", "displayName" => "S N" }, "items" => [{ "field" => "status", "fieldtype" => "jira", "from" => "3", "fromString" => "In Progress", "to" => "10006", "toString" => "In PR" }] }
                         ]
                       end
                     end.new("XD-3725"),
                     Opts.new("grid" => "10%,20%,30%,40%", "author" => "ll")
                   ).violators.first
    end
  end
end
