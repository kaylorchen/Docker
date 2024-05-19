ARG PLATFORM
FROM kaylor/ubuntu:22.04

STOPSIGNAL SIGRTMIN+3

# Enable systemd.
RUN apt-get update ; \
    apt-get install -y systemd systemd-sysv; \
    apt-get clean ; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ;\ 
    printf '#!/bin/sh\nexit 0\n' > /usr/sbin/policy-rc.d

COPY ubuntu-systemd/init.{PLATFORM} /init
CMD ["/init"]
