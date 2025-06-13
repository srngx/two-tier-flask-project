#!/bin/sh
# wait-for-db.sh

# This script waits for the MySQL database to be available before
# executing the main application command.

set -e # Exit immediately if a command exits with a non-zero status

# MySQL host is passed as the first argument to the script
MYSQL_HOST="$1"
# The rest of the arguments form the command to be executed after MySQL is ready
cmd="${@:2}"

echo "Waiting for MySQL at $MYSQL_HOST..."

# Loop until mysqladmin ping succeeds.
# It uses the environment variables MYSQL_USER and MYSQL_PASSWORD,
# which are passed to the Flask container via docker-compose.yml.
until mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  >&2 echo "MySQL is unavailable or not ready - sleeping"
  sleep 2 # Wait for 2 seconds before retrying
done

>&2 echo "MySQL is up - executing command: $cmd"
# Execute the main application command
exec $cmd
