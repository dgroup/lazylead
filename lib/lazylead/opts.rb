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

require "forwardable"

module Lazylead
  #
  # Default options for all lazylead tasks.
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Opts
    extend Forwardable
    def_delegators :@origin, :[], :[]=, :to_s, :key?, :fetch, :merge

    def initialize(origin = {})
      @origin = origin
    end

    # Split text value by delimiter, trim all spaces and reject blank items
    def slice(key, delim)
      to_h[key].split(delim).map(&:chomp).map(&:strip).reject(&:blank?)
    end

    def blank?(key)
      to_h[key].nil? || @origin[key].blank?
    end

    def to_h
      @origin
    end

    # Default Jira options to use during search for all Jira-based tasks.
    def jira_defaults
      {
        max_results: fetch("max_results", 50),
        fields: jira_fields
      }
    end

    # Default fields which to fetch within the Jira issue
    def jira_fields
      to_h.fetch("fields", "").split(",").map(&:to_sym)
    end
  end
end
