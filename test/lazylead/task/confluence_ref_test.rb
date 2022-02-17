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

require "mail"

require_relative "../../test"
require_relative "../../../lib/lazylead/task/confluence_ref"

module Lazylead
  # @todo #/DEV Test took ~5s+ and should be optimized.
  #  Potentially, a confluence HTTP client is a first candidate.
  class ConfluenceRefTest < Lazylead::Test
    # @todo #/DEV Test fully depends on external system.
    #  Before test the external system should be cleaned up.
    #  Moreover, the test itself just creates a reference,
    #  but didn't check that the link is exist.
    #  Developer have to open the ticket and check.
    test "link issue and confluence page from comments" do
      skip "No Confluence details provided" unless env? "CONFLUENCE_URL",
                                                        "CONFLUENCE_APP_ID",
                                                        "CONFLUENCE_NAME",
                                                        "CONFLUENCE_USER",
                                                        "CONFLUENCE_PASS",
                                                        "CONFLUENCE_JQL"
      skip "No JIRA credentials provided" unless env? "JIRA_URL", "JIRA_USER",
                                                      "JIRA_PASS"
      Task::ConfluenceRef.new.run(
        Jira.new(
          username: ENV["JIRA_USER"],
          password: ENV["JIRA_PASS"],
          site: ENV["JIRA_URL"],
          context_path: ""
        ), "",
        "jql" => ENV["CONFLUENCE_JQL"],
        "confluences" => [
          {
            "url" => ENV["CONFLUENCE_URL"], "app" => ENV["CONFLUENCE_APP_ID"],
            "name" => ENV["CONFLUENCE_NAME"], "type" => "com.atlassian.confluence",
            "user" => ENV["CONFLUENCE_USER"], "pass" => ENV["CONFLUENCE_PASS"]
          }
        ].to_json
      )
    end
  end
end
