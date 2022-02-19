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

require "rubygems"
require "rake"
require "date"
require "rdoc"
require "colorize"
require "rake/clean"
require "concurrent"

# @todo #/DEV Investigate the possibility of using migrations from active_record
#  - Rake tasks https://gist.github.com/schickling/6762581
#  - Gem for rake tasks https://github.com/thuss/standalone-migrations
#  - basic example of active_record https://gist.github.com/unnitallman/944011
#  For now standalone-migrations looks complex and needs
#  - complex files structure
#  - manual specification of version(?) thus no auto-apply available

def name
  @name ||= File.basename(Dir["*.gemspec"].first, ".*")
end

def version
  Gem::Specification.load(Dir["*.gemspec"].first).version
end

task default: %i[init_hooks clean rubocop test sqlint copyright docker]

task :init_hooks do
  next if File.file?(".git/hooks/commit-msg")
  FileUtils.copy(".githooks/commit-msg", ".git/hooks/commit-msg")
  FileUtils.chmod("+x", ".git/hooks/commit-msg")
end

require "rake/testtask"
desc "Run all unit tests"
Rake::TestTask.new(:test) do |t|
  ENV["MT_CPU"] = Concurrent.processor_count.to_s
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

task :copyright do
  # @todo #/DEV Update copyright to 2022 for sql files as current changes of structure may lead
  #  to manual actions during installation.
  sh "grep -q -r \"2019-#{Date.today.strftime('%Y')}\" \
    --include \"*.rb\" \
    --include \"*.txt\" \
    --include \"Rakefile\" \
    ."
end

# @todo #/DEV Enable xcop when xml/html files will be added to the project. So far there is no
#  profit.
# require "xcop/rake_task"
# desc "Validate all XML/XSL/XSD/HTML files for formatting"
# Xcop::RakeTask.new :xcop do |task|
#   task.license = "license.txt"
#   task.includes = %w[**/*.xml **/*.xsl **/*.xsd **/*.html]
#   task.excludes = %w[target/**/* coverage/**/* wp/**/* test/resources/*]
# end

# @todo #/DEV Enable rule "Checks SQL against the ANSI syntax" fully.
#  Right now all violations related to PRAGMA https://www.sqlite.org/pragma.html
#  are suppressed as PRAGMA is sqlite specific option.
#  Potential fix is to move this option into vcs4sql lib and remove from our
#  sql files.
task :sqlint do
  puts "Running sqlint..."
  require "sqlint"
  src = Dir.glob("upgrades/**/*.sql")
  puts "Inspecting #{src.size} files"
  total = 0
  src.each do |f|
    violations = SQLint::Linter.new(f, File.open(f, "r"))
                               .run
                               .first(1000)
                               .reject { |v| v.message.include? '"PRAGMA"' }
    violations.each do |v|
      msg_lines = v.message.split("\n")
      p [v.filename, v.line, v.column, "#{v.type} #{msg_lines.shift}"].join ":"
    end
    total += violations.count { |lint| lint.type == :error }
  end
  if total.positive?
    abort "#{total.colorize(:red)} SQL violations found."
  else
    puts "#{src.size} files inspected, #{'no offenses'.colorize(:green)} detected"
  end
end

task :clean do
  Dir.glob("test/resources/**/*.db").each { |f| File.delete(f) }
end

task :docker do
  puts "Building docker image..."
  system <<~CMD
    docker-compose -f .docker/docker-compose.yml build \
          --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
          --build-arg VCS_REF=`git rev-parse --short HEAD` \
          --build-arg version=1.0
  CMD
  system "docker-compose -f .docker/docker-compose.yml rm --force -s lazylead"
  system "docker-compose -f .docker/docker-compose.yml up"
end
