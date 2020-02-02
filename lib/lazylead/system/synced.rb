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

module Lazylead
  # Thread-save ticketing system.
  class Synced
    def initialize(sys)
      @mutex = Mutex.new
      @sys = sys
    end

    # @todo #/DEV Unit tests for 'issues' function the issues found by jql
    def issues(jql)
      @mutex.synchronize do
        @sys.issues jql
      end
    end

    # @todo #/DEV Unit tests for 'group_by' function the issues found by jql
    def group_by(fnc, jql)
      @mutex.synchronize do
        @sys.group_by fnc, jql
      end
    end

    # @todo #/DEV Unit tests for 'group_by_assignee' the issues found by jql
    def group_by_assignee(jql)
      @mutex.synchronize do
        @sys.group_by_assignee jql
      end
    end

    # @todo #/DEV Unit tests for 'filtered' function
    #  Filter the issues found by jql on app side.
    # Required for cases when filtration can't be done on ticketing system side.
    def filtered(fnc, jql)
      @mutex.synchronize do
        @sys.filtered fnc, jql
      end
    end
  end
end
