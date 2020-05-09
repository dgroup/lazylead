# encoding: utf-8

# @todo #/DEV Increase code coverage from 75% to 80%+.
#  Right now it was decreased to 75% due to long manual setup of
#  dev. instances of Atlassian Jira and Confluence.
#  It was configured locally and there is no automation for now how
#  it can be included quickly into CI process. This need to be done later.

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter]
)
SimpleCov.start do
  add_filter "/test/"
  add_filter "/features/"
  minimum_coverage 75
end
