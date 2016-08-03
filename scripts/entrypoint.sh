#! /bin/bash

set -m

ADMIN_USER=${MONGODB_ADMIN_USER:-"admin"}
ADMIN_PASS=${MONGODB_ADMIN_PASS:-"admin"}
USER=${MONGODB_USER:-"admin"}
DATABASE=${MONGODB_DATABASE:-"admin"}
PASSWORD=${MONGODB_PASS:-"admin"}
PASS_SET_FILE=/data/db/.mongo_pass_set

CMD="mongod --storageEngine wiredTiger --config /usr/local/etc/mongod/mongod.conf --auth"

exec $CMD &

if [[ ! -f $PASS_SET_FILE ]]; then

	RET=1
	while [[ RET -ne 0 ]]; do
		echo "=> Waiting for confirmation of MongoDB service startup"
		sleep 5
		mongo admin --eval "help" >/dev/null 2>&1
		RET=$?
	done

	echo "=> Creating an ${ADMIN_USER} user with a password ${ADMIN_PASS} in MongoDB"
	mongo admin --eval "db.createUser({user: '$ADMIN_USER', pwd: '$ADMIN_PASS', roles:[{role:'root',db:'admin'}]});"

	if [ "$DATABASE" != "admin" ]; then
		echo "=> Creating an ${USER} user with a password in MongoDB"
		mongo admin -u $USER -p $PASSWORD << EOF
			use $DATABASE;
			db.createUser({user: '$USER', pwd: '$PASSWORD', roles:[{role:'dbOwner',db:'$DATABASE'}]});
EOF
	fi

	echo "=> Done!"
	touch $PASS_SET_FILE

	echo "================================================================"
	echo " mongo $DATABASE -u $USER -p $PASSWORD --host <host> --port <port>"
	echo "================================================================"
fi

fg