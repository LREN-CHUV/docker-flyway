FROM openjdk:8u131-jre-alpine
MAINTAINER Ludovic Claude <ludovic.claude@chuv.ch>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ENV FLYWAY_VERSION=4.2.0 \
    DOCKERIZE_VERSION=v0.5.0

RUN apk update && apk add bash wget \
    && wget -O /tmp/dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz \
    && rm -rf /var/cache/apk/* /tmp/*

RUN wget -O /tmp/flyway.zip https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.zip \
     && unzip /tmp/flyway.zip \
     && rm /tmp/flyway.zip \
     && mv /flyway-${FLYWAY_VERSION} /flyway \
     && ln -s /flyway/flyway /usr/local/bin/flyway

COPY docker/flyway.conf.tmpl /flyway/conf/
COPY docker/run.sh /

# A simple test
RUN flyway 2>&1 | grep "Flyway ${FLYWAY_VERSION}"

ENV PATH /flyway:$PATH
WORKDIR /flyway
VOLUME /flyway/jars
VOLUME /flyway/sql


# Force the use of standard DNS resolver, Go re-implementation causes sometimes problems within Docker
# See https://golang.org/pkg/net/#hdr-Name_Resolution
ENV GODEBUG=netdns=cgo

ENTRYPOINT ["/run.sh"]
CMD ["--help"]

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="hbpmip/flyway" \
      org.label-schema.description="Flyway tool to manage database migrations" \
      org.label-schema.url="https://github.com/LREN-CHUV/docker-flyway" \
      org.label-schema.vcs-type="git" \
      org.label-schema.vcs-url="https://github.com/LREN-CHUV/docker-flyway.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version="$VERSION" \
      org.label-schema.vendor="LREN CHUV" \
      org.label-schema.license="Apache2.0" \
      org.label-schema.docker.dockerfile="Dockerfile" \
      org.label-schema.schema-version="1.0"
