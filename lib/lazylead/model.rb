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
require_rel "task"

#
# ORM domain model entities.
#
# Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
# Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
# License:: MIT
module Lazylead
  # Makes ORM objects verbose using object's fields.
  module Verbose
    def to_s
      attributes.map { |k, v| "#{k}='#{v}'" }.join(", ")
    end

    def inspect
      to_s
    end
  end

  module ORM
    # General lazylead task.
    class Task < ActiveRecord::Base
      include Verbose
      belongs_to :team, foreign_key: "team_id"
      has_one :system, foreign_key: "id"

      def exec
        action.constantize.new.run(system.connect, props)
      end

      def props
        team.to_h.merge JSON.parse(properties)
      end
    end

    # A team for lazylead task.
    # Each team may have several tasks.
    class Team < ActiveRecord::Base
      include Verbose

      def to_h
        return @prop if defined? @prop
        @prop = JSON.parse(properties)
      end
    end

    # Ticketing systems to monitor.
    class System < ActiveRecord::Base
      include Verbose

      # Make an instance of ticketing system for future interaction.
      def connect
        cfg = JSON.parse(properties)
        if cfg["type"].empty?
          Empty.new
        else
          cfg["type"].constantize.new cfg.except("type"), Salt.new(id)
        end
      end
    end

    # Details about each team members.
    class Person < ActiveRecord::Base
      include Verbose
    end

    # Application properties across all ticketing systems.
    class Properties < ActiveRecord::Base
      include Verbose
    end
  end
end
