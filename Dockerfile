FROM ruby:2.6

ENV APP_HOME=/lazylead

RUN gem install lazylead && mkdir $APP_HOME

WORKDIR APP_HOME

CMD lazylead start --trace --pretty full --verbose
