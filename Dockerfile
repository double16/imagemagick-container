FROM ubuntu:22.04 as build

ARG IMAGEMAGICK_VERSION=7.1.0-47
ENV DEBIAN_FRONTEND=noninteractive

ADD https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGEMAGICK_VERSION}.tar.gz /opt/

RUN mkdir /tmp/root

RUN apt-get -q update &&\
  apt-get install -qy software-properties-common apt-transport-https ca-certificates gnupg-agent &&\
  sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list &&\
  cat /etc/apt/sources.list &&\
  add-apt-repository ppa:strukturag/libheif -y &&\
  add-apt-repository ppa:strukturag/libde265 -y &&\
  apt-get build-dep imagemagick -y &&\
  apt-get install -qy libheif-dev libde265-dev
RUN cd /opt &&\
  tar x --gzip -f ${IMAGEMAGICK_VERSION}.tar.gz &&\
  cd $(find -type d -name "ImageMagick*" | head -n 1) &&\
  ./configure --prefix=/tmp/root --with-heic=yes | grep -q "HEIC.*yes.*yes" &&\
  make -j 2 &&\
  make install-strip

FROM ubuntu:22.04

RUN apt-get -q update && \
  apt-get install -qy fontconfig fontconfig-config fonts-dejavu-core \
                        fonts-droid-fallback fonts-noto-mono fonts-urw-base35 ghostscript gsfonts \
                        hicolor-icon-theme libwebpdemux2 krb5-locales \
                        libapparmor1 libasn1-8-heimdal libavahi-client3 libavahi-common-data \
                        libavahi-common3 libbrotli1 libbsd0 libcairo2 libcups2 libcurl3-gnutls \
                        libdatrie1 libdbus-1-3 libdjvulibre-text libdjvulibre21 libexpat1 \
                        libfftw3-double3 libfontconfig1 libfreetype6 libfribidi0 libglib2.0-0 \
                        libglib2.0-data libgomp1 libgraphite2-3 libgs9 libgs9-common \
                        libgssapi-krb5-2 libgssapi3-heimdal libharfbuzz0b libhcrypto4-heimdal \
                        libheimbase1-heimdal libheimntlm0-heimdal libhx509-5-heimdal libicu70 \
                        libidn12 libijs-0.35 libilmbase25 libjbig0 libjbig2dec0 libjpeg-turbo8 \
                        libjpeg8 libk5crypto3 libkeyutils1 libkrb5-26-heimdal libkrb5-3 \
                        libkrb5support0 liblcms2-2 libldap-2.5-0 libldap-common liblqr-1-0 libltdl7 \
                        libmagickcore-6.q16-6 libmagickcore-6.q16-6-extra libmagickwand-6.q16-6 \
                        libmediainfo0v5 libmms0 libnetpbm10 libnghttp2-14 libnuma1 libopenexr25 \
                        libopenjp2-7 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 \
                        libpaper-utils libpaper1 libpixman-1-0 libpng16-16 libpsl5 \
                        libroken18-heimdal librtmp1 libsasl2-2 libsasl2-modules libsasl2-modules-db \
                        libsqlite3-0 libssh-4 libssl3 libthai-data libthai0 libtiff5 \
                        libtinyxml2-9 libwebp7 libwebpmux3 libwind0-heimdal libwmf0.2-7 libx11-6 \
                        libx11-data libx265-199 libxau6 libxcb-render0 libxcb-shm0 libxcb1 libxdmcp6 \
                        libxext6 libxml2 libxrender1 libzen0v5 netpbm openssl poppler-data \
                        publicsuffix shared-mime-info tzdata ucf xdg-user-dirs \
                        libheif1 libde265-0 exifprobe mediainfo && \
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* &&\
  rm -rf /tmp/*

COPY --from=build /tmp/root/ /usr/
