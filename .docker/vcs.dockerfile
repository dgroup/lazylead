FROM dgroup/lazylead:0.0.0

LABEL about="https://github.com/dgroup/lazylead" \
      ci.contact="yurii.dubinka@gmail.com" \
      ci.release.tag="${release_tags}" \
      ll.docker.issues="https://github.com/dgroup/lazylead/issues?utf8=✓&q=label%3Adocker"

RUN apk add --no-cache subversion git mercurial

CMD ["bin/lazylead", "--trace", "--verbose"]
