#!/bin/bash

### BEGIN INIT INFO
# Provides:          hornetq
# Default-Start:     3 5
# Default-Stop:      0 1 2 6
# Short-Description: Hornetq
# Description:       Start the Hornetq message broker
### END INIT INFO

# Check for existence of needed config file and read it
CONFIG=/etc/hornetq

HORNETQ_HOME=/usr/lib/hornetq

PID_FILE=/var/run/hornetq.pid

USER=hornetq

CLASSPATH="$HORNETQ_HOME/schemas:$CONFIG"

if [ ! -e $CONFIG ] then
    echo "$CONFIG does not exists";
    exit 6;
fi;

if [ ! -r $CONFIG ] then
    echo "$CONFIG is not readable";
    exit 6;
fi;

for i in "ls $HORNETQ_HOME/lib/*.jar"; do
    CLASSPATH=$i:$CLASSPATH
done

JVM_ARGS=cat "$CONFIG/jvm.properties"

HORNETQ_ARGS=cat "$CONFIG/hornetq.properties"

BOOSTRAP_CLASS="org.hornetq.integration.bootstrap.HornetQBootstrapServer"

RETVAL = 0

start() {
    echo -n "Starting HornetQ "
    /bin/sh "$USER" -c "java $JVM_ARGS $HORNETQ_ARGS -classpath $CLASSPATH $BOOSTRAP_CLASS hornetq-beans.xml" > /dev/null 2>&1 &
    PID=$!
    RETVAL=$?
    if [ $RETVAL = 0 ]; then
        echo "$PID" > $PID_FILE
        success
    else
        failure
    fi
    echo
}

stop() {
    echo -n "Shutting down HornetQ "
    killproc -p "$PID_FILE" -d 20 hornetq
    RETVAL=$?
    echo
}

case "$1" in
    start)
    start
    ;;
    stop)
    stop
    ;;
    restart)
    stop
    start
    ;;
    status)
    status -p $PID_FILE HornetQ
    RETVAL=$?    
    ;;
    *)
    echo "Usage: $0 {start|stop|status|try-restart|restart|force-reload|reload|probe}"
    exit 1
    ;;
esac
exit $RETVAL