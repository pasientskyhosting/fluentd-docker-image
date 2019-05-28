FROM alpine:3.9
LABEL maintainer "Lasse Kirkegaard <lk@patientsky.com>"
LABEL Description="Fluentd docker image" Version="1.4.2"

# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
# therefore an 'apk delete' has no effect
RUN apk update \
 && apk add --no-cache \
        ca-certificates \
        ruby ruby-irb ruby-etc ruby-webrick \
        tini \
 && apk add --no-cache --virtual .build-deps \
        build-base \
        ruby-dev gnupg \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 3.3.10 \
 && gem install json -v 2.2.0 \
 && gem install fluentd -v 1.4.2 \
 && gem install bigdecimal -v 1.3.5 \
 && gem install fluent-plugin-docker_metadata_filter -v 0.1.3 \
 && gem install fluent-plugin-throttle -v 0.0.3 \
 && gem install gelf:3.1.0 \
 && gem install fluent-plugin-gelf-hs:1.0.8 \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY entrypoint.sh /bin/

ENV FLUENTD_CONF="fluent.conf"

ENV LD_PRELOAD=""
# EXPOSE 24224 5140

USER root
ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
CMD ["fluentd"]
