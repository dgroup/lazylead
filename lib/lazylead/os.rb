# frozen_string_literal: true

# The MIT License
#
# Copyright (c) 2019-2021 Yurii Dubinka
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

module Lazylead
  #
  # Represents a native, operation system.
  #
  # Author:: Yurii Dubinka (yurii.dubinka@gmail.com)
  # Copyright:: Copyright (c) 2019-2020 Yurii Dubinka
  # License:: MIT
  class OS
    #
    # Run OS-oriented command
    # @param cmd
    #        The command could be a single string or array of strings.
    #        Examples                 Final command to OS
    #        run("ls")                "ls"                  => stdout
    #        run("ls", "-lah")        "ls -lah"             => stdout
    #        run()                    N/A                   => ""
    #        run("ls", nil, "-lah")   N/A                   => ""
    #        run("ls", "", "-lah")    "ls -lah"             => stdout
    #
    # @return stdout
    #         Please note, that this is not a raw stdout.
    #         The output will be modified by String#scrub! in order to avoid invalid byte sequence
    #         in UTF-8 (https://stackoverflow.com/a/24037885/6916890).
    # @todo #/DEV Add support of multiline string literals, not just array of commands
    def run(*cmd)
      return "" if cmd.empty? || cmd.any?(&:nil?)
      todo = cmd
      todo = [cmd.first] if cmd.size == 1
      `#{todo.join(" ")}`.scrub!
    end
  end
end
