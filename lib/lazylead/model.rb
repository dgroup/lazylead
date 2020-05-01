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
require_relative "log"
require_relative "postman"
require_relative "exchange"

#
# ORM domain model entities.
#
# Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
# Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
# License:: MIT
module Lazylead
  # ORM-related methods
  module ORM
    # Tables from database may have configuration in json column.
    # Some of those properties might be configured/overridden by environment
    # variable using macros "${...}"
    #   {
    #      ...
    #      "user" = "${my_user}",
    #      "pass" = "${my_pass}"
    #      "url" = "https://url.com"
    #      ...
    #   }
    # next, we need to configure following environment variables(ENV)
    #   my_user=XXXXX
    #   my_pass=YYYYY
    # thus, the result of this method is
    #   {
    #      ...
    #      "user" = "XXXXXX",
    #      "pass" = "YYYYYY"
    #      "url" = "https://url.com"
    #      ...
    #   }
    def env(opts)
      opts.each_with_object({}) do |e, o|
        k = e[0]
        v = e[1]
        v = ENV[v.slice(2, v.length - 3)] if v.start_with? "${"
        o[k] = v
      end
    end

    # Convert json-based database column to hash.
    def to_j
      JSON.parse(properties)
    end

    def to_s
      attributes.map { |k, v| "#{k}='#{v}'" }.join(", ")
    end

    def inspect
      to_s
    end

    # General lazylead task.
    class Task < ActiveRecord::Base
      include ORM
      belongs_to :team, foreign_key: "team_id"
      belongs_to :system, foreign_key: "system"

      def exec(log = Log::NOTHING)
        log.debug("Task ##{id} '#{name}' is started")
        action.constantize
              .new(log)
              .run(system.connect, postman, props)
        log.debug("Task ##{id} '#{name}' is completed")
      end

      def props
        return @prop if defined? @prop
        @prop = team.to_j.merge(to_j)
      end

      private

      def postman
        if props.key? "postman"
          props["postman"].constantize.new
        else
          Postman.new
        end
      end
    end

    # Ticketing systems to monitor.
    class System < ActiveRecord::Base
      include ORM

      # Make an instance of ticketing system for future interaction.
      def connect
        opts = JSON.parse(properties)
        if opts["type"].empty?
          Empty.new
        else
          opts["type"].constantize.new(
            env(opts.except("type", "salt")),
            opts["salt"].empty? ? NoSalt.new : Salt.new(opts["salt"])
          )
        end
      end
    end

    # A team for lazylead task.
    # Each team may have several tasks.
    class Team < ActiveRecord::Base
      include ORM
    end
  end
end
