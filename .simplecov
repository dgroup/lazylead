# frozen_string_literal: true

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter]
)
SimpleCov.start do
  add_filter "/test/"
  add_filter "/features/"
  minimum_coverage 75
end
