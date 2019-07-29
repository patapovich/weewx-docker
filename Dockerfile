FROM project42/syslog-alpine:3.8

ENV WEEWX_VERSION=3.9.2
ENV INIGO_VERSION=0.7.1
ENV BELCHERTOWN_VERSION=1.0.1

# imperial or metric
ENV INIGO_UNITS=metric
    
ENV WEEWX_URL=http://weewx.com/downloads/weewx-$WEEWX_VERSION.tar.gz
ENV INTERCEPTOR_URL=https://github.com/matthewwall/weewx-interceptor/archive/master.zip
ENV INIGO_URL=https://github.com/evilbunny2008/weeWXWeatherApp/releases/download/$INIGO_VERSION/inigo-$INIGO_UNITS.tar.gz
ENV BELCHERTOWN_URL=https://github.com/poblabs/weewx-belchertown/releases/download/weewx-belchertown-$BELCHERTOWN_VERSION/weewx-belchertown-release-$BELCHERTOWN_VERSION.tar.gz

RUN set -ex; \
    apk --no-cache --update upgrade; \
    apk add --no-cache \
        py2-pillow \
        py2-configobj \
        mariadb-client \
        rsync \
        py-mysqldb; \
    apk add --no-cache --virtual .build-deps \
        py2-pip \
        python2-dev \
        build-base; \
    pip install --no-cache-dir \
        Cheetah \
        pyephem \
        six; \
    cd /tmp; \
    wget $WEEWX_URL -O weewx.tar.gz; \
    tar xvf weewx.tar.gz; \
    cd weewx-$WEEWX_VERSION; \
    ./setup.py install --no-prompt -O2; \
    wget -O /tmp/weewx-interceptor.zip $INTERCEPTOR_URL; \
    wget -O /tmp/weewx-inigo.tgz $INIGO_URL; \
    wget -O /tmp/weewx-belchertown.tgz $BELCHERTOWN_URL; \
    cd /home/weewx; \
    bin/wee_extension --install /tmp/weewx-interceptor.zip; \
    bin/wee_extension --install /tmp/weewx-inigo.tgz; \
    bin/wee_extension --install /tmp/weewx-belchertown.tgz; \
    rm -rf /tmp/* ; \
    apk del --no-cache .build-deps; \
    mkdir -p /home/weewx/config; \
    cp /home/weewx/weewx.conf /home/weewx/config/
    
VOLUME ["/home/weewx/public_html", "/home/weewx/config"]

CMD ["/home/weewx/bin/weewxd", "-x", "/home/weewx/config/weewx.conf"]
