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

require_relative "email"

module Lazylead
  # Array of CC addresses from text for email notification.
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class CC
    # The regexp expression for email notification is very simple, here is the
    # reason why https://bit.ly/38iLKeo
    def initialize(text, regxp = /[^\s]@[^\s]/)
      @text = text
      @regxp = regxp
    end

    def cc
      @cc ||= begin
                if @text.include? ","
                  @text.split(",").map(&:strip).select { |e| e[@regxp] }
                elsif @text[@regxp]
                  [@text.strip]
                end
              end
    end
  end

  # CC addresses based on Jira component owners for email notification.
  # Allows to detect the CC for particular ticket based on its component.
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class ComponentCC
    def initialize(prj, jira)
      @prj = prj
      @jira = jira
    end

    def [](key)
      to_h[key]
    end

    def cc(*names)
      return to_h.values.uniq.compact if names.count.zero?
      return to_h[names.first] if names.count == 1
      hash.values_at(names.first, names.drop(1)).uniq.compact
    end

    def to_h
      @to_h ||= begin
                  components.each_with_object({}) do |c, h|
                    h[c.attrs["name"]] = @jira.raw do |j|
                      lead = j.Component
                              .find(c.attrs["id"], expand: "", fields: "")
                              .attrs["lead"]
                      next if lead.nil? || lead.empty?
                      j.User.find(lead["key"]).attrs["emailAddress"]
                    end
                  end
                end
    end

    private

    def components
      @jira.raw do |j|
        j.Project.find(@prj, expand: "components", fields: "").components
      end
    end
  end

  # Predefined CC addresses for email notification.
  # You may define a hash where
  #  - key is Jira ticket component
  #  - value is CC email address(es)
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class PredefinedCC
    def initialize(orig)
      @orig = orig
    end

    def [](key)
      to_h[key]
    end

    def cc
      to_h.values.flatten.uniq
    end

    def to_h
      @to_h ||= begin
                  if @orig.is_a? Hash
                    @orig.each_with_object({}) do |i, o|
                      o[i.first] = Lazylead::CC.new(i.last).cc
                    end
                  else
                    {}
                  end
                end
    end
  end
end
