FROM mongo

# File Author / Maintainer
MAINTAINER Gabriel Malet

COPY mongod.conf /usr/local/etc/mongod/mongod.conf
COPY ./scripts/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]