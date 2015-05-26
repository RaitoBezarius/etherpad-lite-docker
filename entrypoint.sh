#!/bin/bash

set -e

if [ -z $POSTGRES_PORT_5432_TCP_ADDR ]; then
	echo >&2 'error: missing POSTGRES_PORT_5432_TCP_ADDR environnement variable'
	echo >&2 ' Did you forget to --link some_pg_container:postgres ?'
	exit 1
fi

: ${ETHERPAD_DB_USER:=postgres}
if [ "$ETHERPAD_DB_USER" = 'postgres' ]; then
	: {$ETHERPAD_DB_PASSWORD:=$POSTGRES_ENV_POSTGRES_PASSWORD}
fi
: ${ETHERPAD_DB_NAME:=etherpad}

ETHERPAD_DB_NAME=$(echo $ETHERPAD_DB_NAME | sed 's/\./_/g')

if [ -z "$ETHERPAD_DB_PASSWORD" ]; then
	echo >&2 'error: missing required ETHERPAD_DB_PASSWORD environnement variable'
	echo >&2 ' Did you forget to -e ETHERPAD_DB_PASSWORD=... ?'
	echo >&2
	echo >&2 '  (Do not forget ETHERPAD_DB_USER and ETHERPAD_DB_NAME)'
	exit 1
fi

: ${ETHERPAD_TITLE:=Etherpad}


export PGHOST=${POSTGRES_PORT_5432_TCP_ADDR}
export PGPORT=${POSTGRES_PORT_5432_TCP_PORT}
export PGUSER=${ETHERPAD_DB_USER}
export PGPASSWORD=${ETHERPAD_DB_PASSWORD}

if [ ! "psql -lqt | cut -d \| -f 1 | grep -w ${ETHERPAD_DB_NAME}" ]; then
	echo "Creating database ${ETHERPAD_DB_NAME}"
	
	createdb -O ${ETHERPAD_DB_USER} -E UTF8 ${ETHERPAD_DB_NAME}
fi

if [ ! -f settings.json ]; then
	cat <<- EOF > settings.json
	{
		"title": "${ETHERPAD_TITLE}",
		"ip": "0.0.0.0",
		"port": 9001,
		"dbType": "postgres",
		"dbSettings": {
			"user": "${ETHERPAD_DB_USER}",
			"host": "${POSTGRES_PORT_5432_TCP_ADDR}",
			"password": "${ETHERPAD_DB_PASSWORD}",
			"database": "${ETHERPAD_DB_NAME}"
		},
	EOF

	if [ $ETHERPAD_ADMIN_PASSWORD ]; then
		: ${ETHERPAD_ADMIN_USER:=admin}

		cat <<- EOF >> settings.json
			"users": {
			 "${ETHERPAD_ADMIN_USER}": {
			 	"password": "${ETHERPAD_ADMIN_PASSWORD}",
				"is_admin": true
			}
		EOF
	fi

	cat <<- EOF >> settings.json
	}
	EOF
fi

exec "$@"
