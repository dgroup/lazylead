FROM ruby:2.7.1-alpine

ARG release_tags

LABEL about="https://github.com/dgroup/lazylead" \
      ci.contact="yurii.dubinka@gmail.com" \
      ci.release.tag="${release_tags}" \
      ll.docker.issues="https://github.com/dgroup/lazylead/issues?utf8=✓&q=label%3Adocker"

ENV APP_HOME=/lazylead \
    version=${release_tags} \
    RUBYOPT='-W:no-deprecated'

WORKDIR $APP_HOME

RUN echo "Install 3rd-party libraries." \
  && apk add libc-dev gcc make git sqlite sqlite-dev sqlite-libs tree less vim man bash unzip

COPY Gemfile lazylead.gemspec ./

# @todo #/DEV Avoid hardcode of minor versions for gems.
#  Potentialy, they might be changed to something like '>=2.2.0'.
RUN gem install json:2.2.0 \
  && bundler install

COPY bin/lazylead ./bin/lazylead
ADD lib ./lib
ADD upgrades ./upgrades

CMD ["bin/lazylead", "--trace", "--verbose", "--memory-dump"]

MAINTAINER 'Yurii Dubinka (yurii.dubinka@gmail.com)'