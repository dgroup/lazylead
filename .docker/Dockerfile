FROM openjdk:12-alpine

ARG release_tags

LABEL about="https://github.com/dgroup/lazylead" \
      ci.contact="yurii.dubinka@gmail.com" \
      ci.release.tag="${release_tags}" \
      ll.docker.issues="https://github.com/dgroup/lazylead/issues?utf8=✓&q=label%3Adocker"

ENV APP_NAME=application.jar \
    APP_HOME=/lazylead \
    version=${release_tags}

EXPOSE 8080
WORKDIR $APP_HOME

RUN echo "Install 3rd-party libraries." \
  && apk add --no-cache tree less vim man bash unzip

COPY .docker/jobs.cron /etc/crontabs/root

RUN echo "Assembling..." \
  && chmod -v 777 $APP_HOME  \
  && chmod -v 777 /etc/crontabs/root \
  && mkdir logs && echo "Logs (app/GC) placed here." > ${APP_HOME}/logs/readme.txt \
  && mkdir dumps && echo "Dumps (heap/threads) placed here." > ${APP_HOME}/dumps/readme.txt \
  && echo "Display image structure" \
  && echo "" && pwd && ls -lah && echo "" \
  && ls -lah /etc/crontabs/root && cat /etc/crontabs/root && echo "" \
  && echo "Cleanup..." \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY lazylead-cli/target/*app*.jar ${APP_NAME}

ENTRYPOINT crond \
  && printf "JVM options:\n${JVM_OPTS}" \
  && tree && unzip -l ${APP_NAME} \
  && java ${JVM_OPTS} -jar ${APP_NAME}

MAINTAINER 'Yurii Dubinka (yurii.dubinka@gmail.com)'