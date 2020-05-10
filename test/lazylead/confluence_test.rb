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

require_relative "../test"
require_relative "../../lib/lazylead/confluence"

module Lazylead
  class ConfluenceTest < Lazylead::Test
    test "make link from jira to confluence" do
      assert_entries(
        {
          globalId: "appId=dddd&pageId=0000",
          application: {
            type: "com.atlassian.confluence",
            name: "Knowledge System"
          },
          relationship: "Wiki Page",
          object: {
            url: "https://conf.com/pages/viewpage.action?pageId=0000",
            title: "Wiki Page"
          }
        },
        Confluence.new(
          OpenStruct.new(
            app: "dddd",
            url: "https://conf.com",
            name: "Knowledge System",
            type: "com.atlassian.confluence"
          )
        ).make_link("https://conf.com/pages/viewpage.action?pageId=0000")
      )
    end

    test "jira comment is a confluence link" do
      assert Link.new(
        "", "", [Confluence.new(OpenStruct.new(url: "https://confluence.com"))]
      ).confluence_link? "https://confluence.com/pages/viewpage.action?pageId=1"
    end
  end
end