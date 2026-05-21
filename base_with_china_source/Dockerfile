ARG TAG=24.04
# Version 1.0
FROM ubuntu:${TAG}

ENV DEBIAN_FRONTEND=noninteractive
LABEL maintainer="kaylor.chen@qq.com"

RUN if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then \
        # Ubuntu 24.04+ uses DEB822 format, replace mirror and enable deb-src
        sed -i \
            -e 's|URIs: http://archive.ubuntu.com/ubuntu/|URIs: http://mirrors.huaweicloud.com/ubuntu/|g' \
            -e 's|URIs: http://security.ubuntu.com/ubuntu/|URIs: http://mirrors.huaweicloud.com/ubuntu/|g' \
            -e 's|URIs: http://ports.ubuntu.com/ubuntu-ports/|URIs: http://mirrors.huaweicloud.com/ubuntu-ports/|g' \
            -e 's/^Types: deb$/Types: deb deb-src/' \
            /etc/apt/sources.list.d/*.sources ; \
    else \
        # Ubuntu < 24.04 uses classic one-line format
        sed -i \
            -e 's/archive.ubuntu.com/mirrors.huaweicloud.com/g' \
            -e 's/security.ubuntu.com/mirrors.huaweicloud.com/g' \
            -e 's/ports.ubuntu.com/mirrors.huaweicloud.com/g' \
            /etc/apt/sources.list && \
        sed -i '/^deb-src /d' /etc/apt/sources.list && \
        grep '^deb ' /etc/apt/sources.list | sed 's/^deb /deb-src /' >> /etc/apt/sources.list ; \
    fi
