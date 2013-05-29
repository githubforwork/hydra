#!/bin/bash
cd `dirname $0`
source ./env.sh

MAINCLASSNAMES= \
"\
com.jd.bdp.hydra.benchmark.exp2.StartServiceA \
com.jd.bdp.hydra.benchmark.exp2.StartServiceB \
com.jd.bdp.hydra.benchmark.exp2.StartServiceC1 \
com.jd.bdp.hydra.benchmark.exp2.StartServiceC2 \
com.jd.bdp.hydra.benchmark.exp2.StartServiceD1 \
com.jd.bdp.hydra.benchmark.exp2.StartServiceD2 \
com.jd.bdp.hydra.benchmark.exp2.StartServiceE \
"
PID_FILE="$PID_DIR/.run.pid"

#function lists
PIDS=`ps -f | grep java | grep "$BASE_DIR" | awk '{print $2}'`
function running(){
	if [ -f "$PID_FILE" ]; then
		pid=$(cat "$PID_FILE")
		process=`ps aux | grep " $pid " | grep -v grep`;
		if [ "$process" == "" ]; then
	    	return 1;
		else
			return 0;
		fi
	else
		return 1
	fi
}

function start_server() {
	if running; then
		echo "is running."
		exit 1
	fi

    mkdir -p $PID_DIR
    mkdir -p $LOG_DIR
    chown -R $AS_USER $PID_DIR
    chown -R $AS_USER $LOG_DIR

    sleep 1
    nohup $JAVA $SERVER_ARGS $MAINCLASSNAME $CONFIG_FILE >$TAIL_FILE &
    echo $! > $PID_FILE
    chmod 755 $PID_FILE
	sleep 1;
	tail -F $TAIL_FILE
}

function stop_server() {
	if ! running; then
		echo "service is not running."
		exit 1
	fi
	count=0
	pid=$(cat $PID_FILE)
	while running;
	do
	  let count=$count+1
	  echo "Stopping $count times"
	  if [ $count -gt 5 ]; then
	  	  echo "kill -9 $pid"
	      kill -9 $pid
	  else
	      kill $pid
	  fi
	  sleep 3;
	done
	echo "Stop service successfully."
	rm $PID_FILE
}

function help() {
    echo "Usage: startup.sh {start|stop}" >&2
    echo "       start:             start the server"
    echo "       stop:              stop the server"
}

command=$1
shift 1
case $command in
    start)
        start_server $@;
        ;;
    stop)
        stop_server $@;
        ;;
    *)
        help;
        exit 1;
        ;;
esac
