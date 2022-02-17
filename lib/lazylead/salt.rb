# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2022 Yurii Dubinka
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

require "active_support"

module Lazylead
  #
  # A cryptography salt defined in environment variables.
  #
  # Salt is random data that is used as an additional input to a one-way
  # function that hashes data, a password or passphrase. Salts are used to
  # safeguard passwords in storage. Historically a password was stored in
  # plaintext on a system, but over time additional safeguards developed to
  # protect a user's password against being read from the system. A salt is one
  # of those methods.
  #
  # Read more: https://en.wikipedia.org/wiki/Salt_(cryptography).
  #
  class Salt
    attr_reader :id

    #
    # Each salt should be defined as a environment variable with id, like
    #  salt1=E1F53135E559C253
    #  salt2=84B03D034B409D4E
    #  ...
    #  saltN=xxxxxxxxx
    #
    def initialize(id, env = ENV.to_h)
      @id = id
      @env = env
    end

    def encrypt(password)
      ActiveSupport::MessageEncryptor.new(@env[@id]).encrypt_and_sign password
    end

    def decrypt(password)
      ActiveSupport::MessageEncryptor.new(@env[@id]).decrypt_and_verify password
    end

    def specified?
      @env.key?(@id) && !@env[@id].blank?
    end
  end

  #
  # No cryptography salt defined within environment variables.
  #
  class NoSalt
    def id
      "No salt"
    end

    def encrypt(_)
      raise "ll-003: Unsupported operation: 'encrypt'"
    end

    def decrypt(_)
      raise "ll-004: Unsupported operation: 'decrypt'"
    end

    def specified?
      false
    end

    def key
      raise "ll-005: Unsupported operation: 'key'"
    end
  end
end
