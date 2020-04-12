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

require "English"

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# @todo #/DEV Use single approach for defining versions
#  in case of '~>xxx' vs '>=xxx'
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.rubygems_version = "2.2"
  s.required_ruby_version = ">=2.7.1"
  s.name = "lazylead"
  s.version = "0.0.0"
  s.license = "MIT"
  s.summary = "TBD Summary"
  s.description = "TBD"
  s.authors = ["Yurii Dubinka"]
  s.email = "yurii.dubinka@gmail.com"
  s.homepage = "http://github.com/dgroup/lazylead"
  s.post_install_message = "Thanks for installing Lazylead v0.0.0!
  Read our blog posts: https://blog.lazylead.io
  Stay in touch with the community in Telegram: https://t.me/lazylead
  Follow us on Twitter: https://twitter.com/lazylead
  If you have any issues, report to our GitHub repo: https://github.com/dgroup/lazylead"
  s.files = `git ls-files`.split($RS)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|features)/})
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = ["readme.md", "license.txt"]
  s.add_runtime_dependency "activerecord", ">=6.0"
  s.add_runtime_dependency "backtrace", ">=0.3"
  s.add_runtime_dependency "concurrent-ruby", "1.1.5"
  s.add_runtime_dependency "diffy", "3.3.0"
  s.add_runtime_dependency "futex", ">=0.8.5"
  s.add_runtime_dependency "get_process_mem", "~>0.2.5"
  s.add_runtime_dependency "haml", "5.0.4"
  s.add_runtime_dependency "jira-ruby", "1.7.1"
  s.add_runtime_dependency "json", "2.2.0"
  s.add_runtime_dependency "logging", ">=2.2.2"
  s.add_runtime_dependency "mail", "2.7.1"
  s.add_runtime_dependency "memory_profiler", "0.9.13"
  s.add_runtime_dependency "mimic", "0.4.4"
  s.add_runtime_dependency "openssl", "2.1.2"
  s.add_runtime_dependency "rainbow", "3.0.0"
  s.add_runtime_dependency "require_all", ">=3.0.0"
  s.add_runtime_dependency "rufus-scheduler", ">=3.6.0"
  s.add_runtime_dependency "semantic", "1.6.1"
  s.add_runtime_dependency "sinatra", "2.0.5"
  s.add_runtime_dependency "slop", "~> 4.4"
  s.add_runtime_dependency "sqlite3"
  s.add_runtime_dependency "sys-proctable", "1.2.1"
  s.add_runtime_dependency "thin", "1.7.2"
  s.add_runtime_dependency "threads", ">=0.3"
  s.add_runtime_dependency "tilt", ">=2.0.10"
  s.add_runtime_dependency "total", ">=0.3"
  s.add_runtime_dependency "typhoeus", "1.3.1"
  s.add_runtime_dependency "usagewatch_ext", "0.2.1"
  s.add_runtime_dependency "vcs4sql", "~> 0.1.0"
  s.add_runtime_dependency "zache", ">=0.12"
  s.add_development_dependency "codecov", "0.1.14"
  s.add_development_dependency "cucumber", "3.1.2"
  s.add_development_dependency "guard", "2.15.0"
  s.add_development_dependency "guard-minitest", "2.4.6"
  s.add_development_dependency "minitest", "5.11.3"
  s.add_development_dependency "minitest-fail-fast", "0.1.0"
  s.add_development_dependency "minitest-hooks", "1.5.0"
  s.add_development_dependency "minitest-reporters", "1.3.6"
  s.add_development_dependency "rake", "12.3.2"
  s.add_development_dependency "random-port", "0.3.1"
  s.add_development_dependency "rdoc", "6.1.1"
  s.add_development_dependency "rspec-rails", "3.8.2"
  s.add_development_dependency "rubocop", "0.78.0"
  s.add_development_dependency "rubocop-minitest", "0.5.1"
  s.add_development_dependency "rubocop-performance", "1.5.2"
  s.add_development_dependency "rubocop-rspec", "1.33.0"
  s.add_development_dependency "xcop", ">=0.6"
end
