FROM project42/syslog-alpine:3.8

ENV WEEWX_VERSION=3.8.2
ENV WEEWX_URL=http://weewx.com/downloads/weewx-$WEEWX_VERSION.tar.gz
ENV OWM_VERSION=0.7
ENV OWM_URL=http://lancet.mit.edu/mwall/projects/weather/releases/weewx-owm-$OWM_VERSION.tgz
ENV INTERCEPTOR_URL=https://github.com/matthewwall/weewx-interceptor/archive/master.zip
ENV INFLUX_URL=https://github.com/matthewwall/weewx-influx/archive/master.zip

RUN set -ex; \
    apk --no-cache --update upgrade; \
    apk add --no-cache \
        py2-pillow \
        py2-configobj \
        mariadb-client \
        rsync \
        py2-pip \
        py-mysqldb; \
    apk add --no-cache --virtual .build-deps \
        python2-dev \
        build-base; \
    pip install \
        Cheetah \
        pyephem \
        six; \
    cd /tmp; \
    wget $WEEWX_URL -O weewx.tar.gz; \
    tar xvf weewx.tar.gz; \
    cd weewx-$WEEWX_VERSION; \
    ./setup.py install --no-prompt -O2; \
    wget -O /tmp/weewx-interceptor.zip $INTERCEPTOR_URL; \
    wget -O /tmp/weewx-influx.zip $INFLUX_URL; \
    wget -O /tmp/weewx-owm.tgz $OWM_URL; \
    cd /home/weewx; \
    bin/wee_extension --install /tmp/weewx-interceptor.zip; \
    bin/wee_extension --install /tmp/weewx-owm.tgz; \
    bin/wee_extension --install /tmp/weewx-influx.zip; \
    rm -rf /tmp/* ; \
    apk del --no-cache .build-deps; \
    mkdir -p /home/weewx/config; \
    cp /home/weewx/weewx.conf /home/weewx/config/
    
VOLUME ["/home/weewx/public_html", "/home/weewx/config"]

EXPOSE 8080/tcp

CMD ["/home/weewx/bin/weewxd", "-x", "/home/weewx/config/weewx.conf"]
