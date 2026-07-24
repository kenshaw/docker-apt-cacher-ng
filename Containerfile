FROM docker.io/library/debian:stable-slim

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
   apt-get install \
     --no-install-recommends -y apt-cacher-ng ca-certificates wget \
 && echo "ForeGround: 0" >> /etc/apt-cacher-ng/zzz_override.conf \
 && echo "PassThroughPattern: .*" >> /etc/apt-cacher-ng/zzz_override.conf \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3142/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/apt-cacher-ng"]
