# ============================
# Build stage
# ============================
FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    git \
    gperf \
    ca-certificates \
    libssl-dev \
    libglib2.0-dev \
    libevent-dev \
    libpcre2-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswresample-dev \
    libavfilter-dev \
    libopus-dev \
    libspandsp-dev \
    libcurl4-openssl-dev \
    libjson-glib-dev \
    libwebsockets-dev \
    libhiredis-dev \
    libpcap0.8-dev \
    libmnl-dev \
    libnftnl-dev \
    libmariadb-dev \
    libjwt-dev \
    zlib1g-dev \
    libncurses-dev \
    pandoc \
 && rm -rf /var/lib/apt/lists/*


# Clone rtpengine
RUN git clone --depth=1 --branch mr14.0.1.4 https://github.com/sipwise/rtpengine.git /build/rtpengine

WORKDIR /build/rtpengine


# Fix mysql header (older versions)
RUN sed -i 's|#include <mysql/errmsg.h>|#include <mariadb/errmsg.h>|' \
    daemon/media_player.c || true


# Build
RUN make -j$(nproc) \
 && strip daemon/rtpengine


# ============================
# Runtime stage
# ============================
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive


# Runtime deps + envsubst
RUN apt-get update && apt-get install -y --no-install-recommends \
    gettext-base \
    ca-certificates \
    iproute2 \
    iptables \
    libglib2.0-0 \
    libevent-2.1-7 \
    libevent-pthreads-2.1-7 \
    libpcre2-8-0 \
    libavcodec59 \
    libavformat59 \
    libavutil57 \
    libswresample4 \
    libavfilter8 \
    libopus0 \
    libspandsp2 \
    libcurl4 \
    libjson-glib-1.0-0 \
    libwebsockets17 \
    libhiredis0.14 \
    libpcap0.8 \
    libmnl0 \
    libnftnl11 \
    libmariadb3 \
    libjwt0 \
    zlib1g \
    procps \
 && rm -rf /var/lib/apt/lists/*


# User
RUN groupadd -r rtpengine \
 && useradd -r -g rtpengine -d /home/rtpengine rtpengine \
 && mkdir -p /rec /etc/rtpengine \
 && chown -R rtpengine:rtpengine /rec /etc/rtpengine


# Copy binary
COPY --from=builder /build/rtpengine/daemon/rtpengine /usr/local/bin/rtpengine


# Copy config + entrypoint
COPY entrypoint.sh /entrypoint.sh
COPY rtpengine.conf /etc/rtpengine/rtpengine.conf

RUN chmod +x /entrypoint.sh


USER rtpengine
WORKDIR /home/rtpengine


# Expose RTPengine ports
EXPOSE 22222/udp
EXPOSE 22222/tcp
EXPOSE 22221/tcp
EXPOSE 23000-32768/udp


ENTRYPOINT ["/entrypoint.sh"]
