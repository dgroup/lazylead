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

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "simplecov"
SimpleCov.start
if ENV.fetch("CI", nil) == "true"
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "minitest/autorun"
require "minitest/hooks/test"
require "minitest/reporters"
require "concurrent"
require "timeout"
require "active_support"
require "mail"

$stdout.sync = true
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

module Lazylead
  # A basic lazylead test based on Minitest.
  # By default it defines
  #  - the timeout for each test
  #  - additional generic asserts
  class Test < ActiveSupport::TestCase
    include Minitest::Hooks

    make_my_diffs_pretty!
    parallelize(workers: ENV["MT_CPU"].to_i)

    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    parallelize_teardown do |_worker|
      SimpleCov.result
    end

    # @todo #/DEV Test timeout should fail the build instead of skipping
    def around
      Timeout.timeout(
        ENV["TEST_TIMEOUT"].nil? ? 10 : ENV["TEST_TIMEOUT"].to_i
      ) do
        Thread.current.name = "test"
        super
      end
    end

    def greater_then(fst, sec)
      assert fst > sec, "'#{fst}' is expected to be greater than '#{sec}'"
    end

    def greater_or_eq(fst, sec)
      assert fst >= sec,
             "'#{fst}' is expected to be greater or equal to '#{sec}'"
    end

    def assert_entries(exp, act)
      raise "Primary hash for comparing is empty" if exp.nil? || exp.empty?
      exp.each do |k, v|
        assert exp.key?(k), "The key '#{k}' is absent in #{act}"
        assert_equal v, act[k]
      end
    end

    # Assert that array has 1 hash object with necessary content
    def assert_single_entry(exp, act)
      assert_equal 1, act.size
      assert_entries exp, act.first
    end

    # Assert that text contains expected words
    def assert_words(*words, text)
      words = [words] unless words.respond_to? :each

      words.first.each do |w|
        assert_includes text, w
      end
    end

    # Gives file name without extension (.rb)
    def no_ext(path)
      File.basename(path, ".rb")
    end

    # Gives true if key(s) have non-blank values in ENV.
    # :key  :: The key(s) from ENV
    def env?(*keys)
      if keys.respond_to?(:all?)
        !keys.all? { |k| ENV[k].blank? }
      else
        !ENV[keys].blank?
      end
    end

    # Assert that email sent using 'mail' gem in test mode
    #  has expected subject and words
    def assert_email(subject, *words)
      refute_empty words, "No words provided to match"
      email = Mail::TestMailer.deliveries
                              .find { |m| m.subject.eql? subject }

      refute_nil email, "No email found with subject: #{subject}"
      assert_words words, email.body.parts.first.body.raw_source
    end

    # Assert that email sent using 'mail' gem in test mode
    #  has expected subject and line with expected words
    # @todo #/DEV Gem 'mail' sends email as a single line, find a way how to add
    #  symbol '\n' to each line for email during unit testing.
    def assert_email_line(subject, words)
      words = [words] unless words.respond_to? :each

      assert_email subject, words
      mail = Mail::TestMailer.deliveries
                             .find { |m| m.subject.eql? subject }
                             .body.parts.first.body.raw_source
                             .split("\n")
                             .reject(&:blank?)

      assert mail.any? { |line| words.all? { |w| line.include? w } },
             "Words '#{words.join(',')}' wasn't found in '#{mail.join('\n')}'"
    end

    def assert_attachment(subject, regexp)
      parts = Mail::TestMailer.deliveries
                              .find { |m| m.subject.eql? subject }
                              .body.parts.parts
                              .select do |p|
        p.header.fields.any? { |f| f.value.start_with? "attachment" }
      end

      refute_empty parts, "No attachments found within the email"
      assert parts.first.header.fields.any? { |f| f.value.match regexp },
             "No attachments found matches to '#{regexp}' in #{subject}"
    end

    # Ping remote host
    #  https://github.com/eitoball/net-ping
    #  https://stackoverflow.com/a/35508446/6916890
    #  https://rubygems.org/gems/net-ping/versions/2.0.8
    def ping?(host)
      require "net/ping"
      Net::Ping::External.new(host).ping?
    end

    # Ensure that actual array contain at least expected array.
    # @param exp
    #        The array with expected values
    # @param act
    #        The array with actual values
    def assert_array(exp, act)
      assert_equal exp.size, act.size, "Size mismatch between arrays"
      assert array?(exp, act), "No match between '#{exp}' and '#{act}'"
    end

    # Compare that actual array contain(not equal!) at least expected array.
    # @return true
    #         If array <exp> contain array <act>
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    def array?(exp, act)
      rows = []
      exp.each do |row|
        rows << if row.respond_to? :each
                  act.any? do |arow|
                    next unless arow.respond_to? :[]
                    row.each_with_index.map { |c, i| c.eql? arow[i] }.all? { |c| c }
                  end
                else
                  act.any? { |arow| row.eql? arow }
                end
      end
      rows.all? { |r| r }
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

    # Ensure that text is blank.
    def assert_blank(text)
      assert_respond_to text, :blank?, "Text has no method :blank?"
      assert_predicate text, :blank?, "Text isn't blank"
    end
  end
end
