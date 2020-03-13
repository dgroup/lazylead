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

require "premailer"

module Lazylead
  module Task
    # Lazylead task which sent notification about missing/expired due date.
    #
    # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
    # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
    # License:: MIT
    # @todo #/DEV Duedate: Find a way how to generate a pretty email message.
    #  Potentially https://github.com/alexdunae/premailer might be used.
    class Duedate
      def run(team, sys)
        sys.group_by_assignee(team["duedate-sql"]).each do |a, _|
          Mail.deliver do
            to a.email
            from team["from"]
            subject team["duedate-subject"]

            html_part do
              content_type "text/html; charset=UTF-8"
              body <<~MSG
                <p>Hi #{a.name},</p>
                <p>The due date for these tasks has expired.
              MSG
            end
          end
        end
      end
    end
  end
end
