#!/bin/sh

echo "Building latest image (tail -f /tmp/debug.log for details)"
docker build . -t pwntainer:`cat version` 2>&1 > /tmp/pwntainer_debug.log &
pid=$! ; i=0
while ps -a | awk '{print $1}' | grep -q "${pid}"
do
    c=`expr ${i} % 4`
    case ${c} in
       0) echo "/\c" ;;
       1) echo "-\c" ;;
       2) echo "\\ \b\c" ;;
       3) echo "|\c" ;;
    esac
    i=`expr ${i} + 1`
    # change the speed of the spinner by altering the 1 below
    sleep 0.5
    echo "\b\c"
done

wait ${pid}
if $?; then
  echo 'Failed to build pwntainer... see output above...'
  exit 1
fi

if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
  echo "Detected MacOS; starting Xquartz..."
  X11RUNNING=`ps -ef | grep -v grep | grep Xquartz | wc -l`
  if [ $X11RUNNING -le 0 ]; then
    if which Xquartz 2>&1 > /dev/null; then
      Xquartz &
    else
      echo 'Unable to start pwntainer... no X windows!'
      exit 1
    fi
  else
    echo "Xquartz already running!"
  fi

  echo "Setup socat to bend traffic to Xquartz..."
  if which socat 2>&1 > /dev/null; then
    SOCATRUNNING=`ps -ef | grep -v grep | egrep 'socat tcp-listen:6000.*UNIX' | wc -l`
    if [ $SOCATRUNNING -le 0 ]; then
      xhost +localhost
      socat tcp-listen:6000,fork,reuseaddr UNIX:\"$DISPLAY\" &
    fi
    DISPLAY=$HOSTNAME:0
  else
    echo 'Unable to start pwntainer... I need socat (brew install socat)'
  fi
fi

if [ `docker ps -a -q --filter 'name=pwntainer' 2> /dev/null | wc -l` -gt 0 ]; then
  if [ `docker ps -q --filter 'name=pwntainer' 2> /dev/null | wc -l` -gt 0 ]; then
    echo "Pwntainer already running!  Exec in..."
    docker exec -tiu root pwntainer terminator 2>&1 >> /tmp/pwntainer_debug.log
  else
    echo "Pwntainer exists, but isn't running... restarting..."
    docker start -ai pwntainer
  fi
else
  echo "Starting pwntainer!"
  docker run -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -h pwntainer --name pwntainer -v $HOME:/home/hacker -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY pwntainer:`cat version` 2>&1 >> /tmp/pwntainer_debug.log
fi

