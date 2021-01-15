FROM ruby:2.6.5-alpine

ARG release_tags
ARG version

LABEL about="https://github.com/dgroup/lazylead" \
      ci.contact="yurii.dubinka@gmail.com" \
      ci.release.tag="${release_tags}" \
      ll.docker.issues="https://github.com/dgroup/lazylead/issues?utf8=✓&q=label%3Adocker"

ENV APP_HOME=/lazylead
ENV VERSION=${version}

WORKDIR $APP_HOME

# @todo #/DEV Original size of lazylead was 350 MB.
#  After removing of unnecessary libraries it took 250 MB.
#  The original alpine image is ~20MB.
#  Image cleanup is required.
RUN echo "Install 3rd-party libraries." \
  && apk add --no-cache libc-dev gcc git make sqlite sqlite-dev sqlite-libs tree

COPY Gemfile lazylead.gemspec ./

RUN bundler install --without development

COPY bin/lazylead ./bin/lazylead
COPY lib ./lib
COPY upgrades ./upgrades

RUN sed -i "s/0\.0\.0/${version}/g" lib/lazylead/version.rb

CMD ["bin/lazylead", "--trace", "--verbose"]
