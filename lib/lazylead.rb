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

require_relative "lazylead/allocated"
require_relative "lazylead/confluence"
require_relative "lazylead/email"
require_relative "lazylead/exchange"
require_relative "lazylead/log"
require_relative "lazylead/model"
require_relative "lazylead/postman"
require_relative "lazylead/salt"
require_relative "lazylead/schedule"
require_relative "lazylead/smtp"
require_relative "lazylead/cli/app"
require_relative "lazylead/system/jira"
require_relative "lazylead/system/empty"
require_relative "lazylead/system/fake"
require_relative "lazylead/system/synced"
require_relative "lazylead/task/alert"
require_relative "lazylead/task/confluence_ref"
require_relative "lazylead/task/echo"
require_relative "lazylead/task/fix_version"
require_relative "lazylead/task/missing_comment"
require_relative "lazylead/version"

# Lazylead main module.
# Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
# Copyright:: Copyright (c) 2020 Yurii Dubinka
# License:: MIT
module Lazylead
end
