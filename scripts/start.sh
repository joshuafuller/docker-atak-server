#!/usr/bin/env -S /bin/bash
set -e
TR=/opt/tak
CONFIG=${TR}/data/CoreConfig.xml

# Clean shutdowns
MESSAGING_PID=null
API_PID=null
PM_PID=null
kill() {
  if [ $MESSAGING_PID != null ];then
    kill $MESSAGING_PID
    MESSAGING_PID=null
  fi
  if [ $API_PID != null ];then
    kill $API_PID
    API_PID=null
  fi
  if [ $PM_PID != null ];then
    kill $PM_PID
    PM_PID=null
  fi
}
trap kill SIGINT
trap kill SIGTERM

# (re-)Create config
echo "(Re-)Creating config"
cat /opt/templates/CoreConfig.tpl | gomplate >${CONFIG}
# make sure it's in tak root too
cp ${CONFIG} /opt/tak/

# Change to workdir
cd ${TR}

# This will set bunch of variables
. ./setenv.sh

# Start the processes
echo "Starting processes"
java -jar -Xmx${MESSAGING_MAX_HEAP}m -Dspring.profiles.active=messaging takserver.war &
MESSAGING_PID=$!
java -jar -Xmx${API_MAX_HEAP}m -Dspring.profiles.active=api -Dkeystore.pkcs12.legacy takserver.war &
API_PID=$!
java -jar -Xmx${RETENTION_MAX_HEAP}m takserver-retention.jar &
RET_PID=$!
java -jar -Xmx${PLUGIN_MANAGER_MAX_HEAP}m takserver-pm.jar &
PM_PID=$!

# fire-and-forget admin enable
echo "Spawning admin creator"
/opt/scripts/enable_admin.sh &

# Wait for the java processes to exit
while [ $MESSAGING_PID != null ]
do
  sleep 1
done
