FROM ruby:2.6.5-alpine

ARG version
ARG BUILD_DATE
ARG VCS_REF

LABEL ll.docker.issues="https://github.com/dgroup/lazylead/issues?utf8=✓&q=label%3Adocker" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="lazylead" \
      org.label-schema.description="Eliminate the annoying work within ticketing systems (Jira, GitHub, Trello). Allows automating (without admin access) daily actions like tickets fields verification, email notifications by JQL/GQL, meeting requests to your (or teammates) calendar." \
      org.label-schema.url="https://lazylead.org/" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url="https://github.com/dgroup/lazylead" \
      org.label-schema.vendor="Yurii Dubinka" \
      org.label-schema.version=${version} \
      org.label-schema.schema-version="1.0"

ENV APP_HOME=/lazylead
ENV VERSION=${version}
ENV VCS_REF=${VCS_REF}
ENV COMMIT_URL="https://github.com/dgroup/lazylead/commit/${VCS_REF}"
ENV BUILD_DATE=${BUILD_DATE}

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
