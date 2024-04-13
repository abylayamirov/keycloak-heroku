#!/bin/bash

# Set database config from Heroku DATABASE_URL
if [ "$DATABASE_URL" != "" ]; then
    echo "Found database configuration in DATABASE_URL=$DATABASE_URL"

    regex='^postgres://([a-zA-Z0-9_-]+):([a-zA-Z0-9]+)@([a-z0-9.-]+):([[:digit:]]+)/([a-zA-Z0-9_-]+)$'
    if [[ $DATABASE_URL =~ $regex ]]; then
        export KC_DB_URL=$DATABASE_URL
        export KC_DB=postgres
        export KC_DB_USERNAME=${BASH_REMATCH[1]}
        export KC_DB_PASSWORD=${BASH_REMATCH[2]}

        echo "DB_ADDR=$KC_DB_URL, DB_DATABASE=$KC_DB, DB_USER=$KC_DB_USERNAME, DB_PASSWORD=$KC_DB_PASSWORD"
    fi

fi

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

file_env 'KEYCLOAK_USER'
file_env 'KEYCLOAK_PASSWORD'

############
# Hostname #
############

export KC_HOSTNAME=$KEYCLOAK_HOSTNAME

# Configure DB

echo "========================================================================="
echo ""
echo "  Using $DB_NAME database"
echo ""
echo "========================================================================="
echo ""

/opt/tools/x509.sh
/opt/tools/jgroups.sh $JGROUPS_DISCOVERY_PROTOCOL $JGROUPS_DISCOVERY_PROPERTIES
/opt/tools/autorun.sh

##################
# Start Keycloak #
##################
export KEYCLOAK_ADMIN=$KEYCLOAK_USER
export KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_PASSWORD
exec /opt/keycloak/bin/kc.sh start --optimized --hostname-port=$PORT
exit $?
