FROM docker.io/library/debian:stable-slim

ENV \
  APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
  APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
  APT_CACHER_NG_USER=apt-cacher-ng

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
   apt-get install \
     --no-install-recommends -y \
     apt-cacher-ng \
     ca-certificates \
     wget \
     dpkg \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /

RUN chmod 755 /entrypoint.sh

EXPOSE 3142/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/apt-cacher-ng"]
