FROM ruby:2.6.5

ARG release_tags

LABEL about="https://github.com/dgroup/lazylead" \
      ci.contact="yurii.dubinka@gmail.com" \
      ci.release.tag="${release_tags}" \
      ll.docker.issues="https://github.com/dgroup/lazylead/issues?utf8=✓&q=label%3Adocker"

ENV APP_HOME=/lazylead \
    version=${release_tags}

WORKDIR $APP_HOME

RUN echo "Install 3rd-party libraries." \
  && apt-get update \
  && apt-get install -y tree less vim man bash unzip

COPY Gemfile lazylead.gemspec ./
RUN bundler install && bundler update

COPY bin/lazylead ./bin/lazylead
ADD lib ./lib
ADD upgrades ./upgrades

CMD ["bin/lazylead", "--trace", "--verbose", "--memory-dump"]

MAINTAINER 'Yurii Dubinka (yurii.dubinka@gmail.com)'