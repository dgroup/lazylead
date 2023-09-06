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

require "English"

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.required_ruby_version = ">=2.6.5"
  s.name = "lazylead"
  s.version = "0.0.0"
  s.license = "MIT"
  s.summary = "Eliminate the annoying work within bug-trackers."
  s.description = "Ticketing systems (Github, Jira, etc.) are strongly
integrated into our processes and everyone understands their necessity. As soon
as a developer becomes a lead/technical manager, he or she faces a set of
routine tasks that are related to ticketing work. On large projects this becomes
 a problem, more and more you spend time running around on dashboards and
tickets, looking for incorrect deviations in tickets and performing routine
tasks instead of solving technical problems."
  s.authors = ["Yurii Dubinka"]
  s.email = "yurii.dubinka@gmail.com"
  s.homepage = "http://github.com/dgroup/lazylead"
  s.post_install_message = "Thanks for installing Lazylead v0.0.0!
  Read our blog posts: https://lazylead.org
  Stay in touch with the community in Telegram: https://t.me/lazylead
  Follow us on Twitter: https://twitter.com/lazylead
  If you have any issues, report to our GitHub repo: https://github.com/dgroup/lazylead"
  s.files = `git ls-files`.split($RS)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[readme.md license.txt]
  s.add_runtime_dependency "activerecord", "6.1.3"
  s.add_runtime_dependency "backtrace", "0.4.0"
  s.add_runtime_dependency "colorize", "1.1.0"
  s.add_runtime_dependency "faraday", "2.3.0"
  s.add_runtime_dependency "get_process_mem", "0.2.7"
  s.add_runtime_dependency "inifile", "3.0.0"
  s.add_runtime_dependency "jira-ruby", "2.3.0"
  s.add_runtime_dependency "json", "2.6.3"
  s.add_runtime_dependency "logging", "2.3.1"
  s.add_runtime_dependency "mail", "2.8.1"
  s.add_runtime_dependency "memory_profiler", "1.0.1"
  s.add_runtime_dependency "nokogiri", "1.11.3"
  s.add_runtime_dependency "openssl", "2.1.2"
  s.add_runtime_dependency "railties", "6.1.3"
  s.add_runtime_dependency "require_all", "3.0.0"
  s.add_runtime_dependency "rubyzip", "2.3.2"
  s.add_runtime_dependency "rufus-scheduler", "3.9.1"
  s.add_runtime_dependency "slop", "4.10.1"
  s.add_runtime_dependency "sqlite3", "1.4.4"
  s.add_runtime_dependency "tempfile", "0.1.3"
  s.add_runtime_dependency "tilt", "2.0.10"
  s.add_runtime_dependency "tzinfo", "2.0.4"
  s.add_runtime_dependency "tzinfo-data", "1.2023.3"
  s.add_runtime_dependency "vcs4sql", "0.1.1"
  s.add_runtime_dependency "viewpoint", "1.1.1"
  s.add_runtime_dependency "zaru", "0.3.0"
  s.add_development_dependency "codecov", "0.6.0"
  s.add_development_dependency "guard", "2.18.0"
  s.add_development_dependency "guard-minitest", "2.4.6"
  s.add_development_dependency "minitest", "5.19.0"
  s.add_development_dependency "minitest-fail-fast", "0.1.0"
  s.add_development_dependency "minitest-hooks", "1.5.1"
  s.add_development_dependency "minitest-reporters", "1.6.1"
  s.add_development_dependency "net-ping", "2.0.8"
  s.add_development_dependency "rake", "13.0.6"
  s.add_development_dependency "rdoc", "6.5.0"
  s.add_development_dependency "rubocop", "1.50.2"
  s.add_development_dependency "rubocop-minitest", "0.30.0"
  s.add_development_dependency "rubocop-performance", "1.17.1"
  s.add_development_dependency "rubocop-rake", "0.6.0"
  s.add_development_dependency "rubocop-rspec", "2.20.0"
  s.add_development_dependency "ruby-prof", "1.4.3"
  s.add_development_dependency "sqlint", "0.2.1"
  s.add_development_dependency "tempfile", "0.1.3"
  s.metadata = { "rubygems_mfa_required" => "false" }
end
