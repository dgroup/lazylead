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
  # Entry point for email CC detection.
  # The email may need CC email addresses, thus, there are various strategies
  #  how it can be done.
  class CC
    # Build an CC in order to detect email addresses by different conditions.
    #
    # Supported conditions(types):
    #  - PlainCC
    #  - PredefinedCC
    #  - ComponentCC
    #  - Empty
    #
    def detect(emails, sys)
      return PlainCC.new(emails) if plain?(emails)
      return EmptyCC unless emails.key? "type"
      return EmptyCC if emails["type"].blank? || emails["type"].nil?
      type = emails["type"].constantize
      return ComponentCC.new(emails["project"], sys) if type.is_a? ComponentCC
      type.new(emails["opts"])
    end

    private

    # Detect that raw CC is a string which may has plain email addresses
    def plain?(text)
      (text.is_a? String) &&
        (text.to_s.include?(",") || text.to_s.include?("@"))
    end
  end

  # Array of CC addresses from text for email notification.
  #
  #   PlainCC.new("a@f.com, , -,b@f.com").cc    # ==> ["a@f.com", "b@f.com"]
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class PlainCC
    include Enumerable
    extend Forwardable
    def_delegators :@cc, :each

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

    def each(&block)
      cc.each(&block)
    end
  end

  # Empty CC email addresses.
  class EmptyCC
    def cc
      []
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

    def cc(*names)
      return to_h.values.flatten.uniq.compact if names.count.zero?
      return self[names.first] if names.count == 1
      to_h.values_at(names.first, *names.drop(1)).flatten.uniq.compact
    end

    def to_h
      @to_h ||= begin
                  if @orig.is_a? Hash
                    @orig.each_with_object({}) do |i, o|
                      o[i.first] = Lazylead::PlainCC.new(i.last).cc
                    end
                  else
                    {}
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
  class ComponentCC < Lazylead::PredefinedCC
    def initialize(prj, jira)
      @prj = prj
      @jira = jira
    end

    def to_h
      @to_h ||= begin
                  components.each_with_object({}) do |c, h|
                    email = lead(c.attrs["id"])
                    next if email.nil? || email.blank?
                    h[c.attrs["name"]] = email
                  end
                end
    end

    private

    def lead(component_id)
      @jira.raw do |j|
        lead = j.Component
                .find(component_id, expand: "", fields: "")
                .attrs["lead"]
        next if lead.nil? || lead.empty?
        j.User.find(lead["key"]).attrs["emailAddress"]
      end
    end

    def components
      @jira.raw do |j|
        j.Project.find(@prj, expand: "components", fields: "").components
      end
    end
  end
end
