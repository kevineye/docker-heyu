FROM alpine
MAINTAINER Kevin Eye <kevineye@gmail.com>

RUN apk -U add curl build-base \
 && curl -fsSL -o /usr/local/bin/forego https://github.com/russmckendrick/forego-docker/releases/download/0.1/forego \
 && chmod 775 /usr/local/bin/forego \
 && mkdir /build \
 && cd /build \
 && curl -fsSL -O http://github.com/msoap/shell2http/releases/download/1.4/shell2http-1.4.amd64.linux.zip \
 && unzip shell2http-1.4.amd64.linux.zip shell2http \
 && mv shell2http /usr/local/bin \
 && curl -s http://www.heyu.org/download/heyu-2.11-rc1.tar.gz | tar xzf - \
 && cd heyu-2.11-rc1 \
 && ./configure --sysconfdir=/etc \
 && make \
 && make install \
 && cd / \
 && apk --purge del curl build-base \
 && rm -rf /build /etc/ssl /var/cache/apk/* /lib/apk/db/*

RUN cp -r /etc/heyu /etc/heyu.default \
 && mkdir -p /usr/local/var/tmp/heyu \
 && mkdir -p /usr/local/var/lock \
 && chmod 777 /usr/local/var/tmp/heyu \
 && chmod 777 /usr/local/var/lock

VOLUME /etc/heyu
EXPOSE 80

COPY heyu-run.sh /usr/local/bin/heyu-run
CMD heyu-run
