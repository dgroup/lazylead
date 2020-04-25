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

require "tilt"

module Lazylead
  # Email notifications utilities.
  module Emailing
    # Construct html document from template and binds.
    def make_body(opts)
      Email.new(
        opts["template"],
        opts[:binds].merge(version: Lazylead::VERSION)
      ).render
    end

    # Split text with email addresses by ',' and trim all elements if needed.
    def split(type, opts)
      opts[type].split(",").map(&:strip).reject(&:empty?) if opts.key? "cc"
    end
  end

  # An email regarding tickets based on file with markup.
  #
  # The 'tilt' gem was used as a template engine.
  # Read more about 'tilt':
  #  - https://github.com/rtomayko/tilt
  #  - https://github.com/rtomayko/tilt/blob/master/docs/TEMPLATES.md
  #  - https://www.rubyguides.com/2018/11/ruby-erb-haml-slim/
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class Email
    # :file   :: the file with html template
    # :binds  :: the template variables for substitution.
    def initialize(file, binds)
      @file = file
      @binds = binds
    end

    # Construct the email body from html template based on variables (binds).
    def render
      Tilt.new(@file)
          .render(OpenStruct.new(@binds))
          .delete!("\n")
    end
  end
end
