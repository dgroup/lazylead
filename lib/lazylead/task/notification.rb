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

require_relative "../email"
require_relative "../version"
require_relative "../postman"

module Lazylead
  module Task
    #
    # A task that sends notifications about issues to their assignees.
    #
    # The task supports the following features:
    #  - fetch issues from remote ticketing system by query
    #  - group all issues by assignee
    #  - prepare email based on predefined template (*.erb)
    #  - send the required notifications to each assignee
    #
    # The email message is sending to the assignee regarding all his/her issues,
    #  not like one email per each issue.
    #
    # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
    # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
    # License:: MIT
    #
    class Notification

      def initialize(postman = Postman.new)
        @postman = postman
      end

      def run(sys, cfg)
        sys.issues(cfg["sql"]).group_by(&:assignee).each do |assignee, t|
          @postman.send assignee.email, cfg, assignee: assignee, tickets: t
        end
      end
    end
  end
end
