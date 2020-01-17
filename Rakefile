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

require "rubygems"
require "rake"
require "date"
require "rdoc"
require "rake/clean"

def name
  @name ||= File.basename(Dir["*.gemspec"].first, ".*")
end

def version
  Gem::Specification.load(Dir["*.gemspec"].first).version
end

task default: %i[clean test features rubocop xcop copyright]

require "rake/testtask"
desc "Run all unit tests"
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
  t.warning = false
end

require "rdoc/task"
desc "Build RDoc documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "#{name} #{version}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

require "rubocop/rake_task"
desc "Run RuboCop on all directories"
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
  task.requires << "rubocop-rspec"
end

require "cucumber/rake/task"
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
  Rake::Cleaner.cleanup_files(["coverage"])
end
Cucumber::Rake::Task.new(:"features:html") do |t|
  t.profile = "html_report"
end

require "xcop/rake_task"
desc "Validate all XML/XSL/XSD/HTML files for formatting"
Xcop::RakeTask.new :xcop do |task|
  task.license = "license.txt"
  task.includes = ["**/*.xml", "**/*.xsl", "**/*.xsd", "**/*.html"]
  task.excludes = ["target/**/*", "coverage/**/*", "wp/**/*"]
end

task :copyright do
  sh "grep -q -r \"2019-#{Date.today.strftime('%Y')}\" \
    --include \"*.rb\" \
    --include \"*.txt\" \
    --include \"Rakefile\" \
    ."
end
