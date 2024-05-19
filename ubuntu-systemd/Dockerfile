FROM kaylor/ubuntu:22.04

STOPSIGNAL SIGRTMIN+3

# Enable systemd.
RUN apt-get update ; \
    apt-get install -y systemd systemd-sysv; \
    apt-get clean ; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ;\ 
    printf '#!/bin/sh\nexit 0\n' > /usr/sbin/policy-rc.d

COPY ubuntu-systemd/init.aarch64 /
COPY ubuntu-systemd/init.x86_64 /

RUN bash -c 'if [[ $(uname -m) == "x86_64" ]]; then cp /init.x86_64 /init; elif [[ $(uname -m) == "aarch64" ]]; then cp /init.aarch64 /init; else echo "Unknown Architecture"; fi' && \
    rm /init.aarch64 /init.x86_64

CMD ["/init"]
