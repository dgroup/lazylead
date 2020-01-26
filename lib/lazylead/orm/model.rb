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

require "active_record"
require "require_all"
require_rel "../task"
require_rel "verbosed"

# @todo #/DEV Setup the relations between classes has_many, has_one, etc, more
#  here https://www.rubydoc.info/gems/activerecord/5.0.0.1.
module Lazylead
  # @todo #/DEV Add validations to the columns. More details described here
  #  https://www.rubydoc.info/gems/activerecord/5.0.0.1.
  module ORM
    class Task < ActiveRecord::Base
      include Verbosed
      belongs_to :team, foreign_key: "team_id"

      def exec
        action.constantize.new.run team
      end
    end
    class Team < ActiveRecord::Base
      include Verbosed
    end
    class Person < ActiveRecord::Base
      include Verbosed
    end
    class CC < ActiveRecord::Base
      include Verbosed
    end
    class System < ActiveRecord::Base
      include Verbosed
    end
    class Properties < ActiveRecord::Base
      include Verbosed
    end
  end
end
