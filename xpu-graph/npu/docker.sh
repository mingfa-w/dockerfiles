#!/bin/bash
# export MY_CONTAINER="`whoami`_$1"
export MY_CONTAINER="`whoami`"
num=`docker ps -a | grep -w "$MY_CONTAINER$" | wc -l`
echo $num
echo $MY_CONTAINER
DOCKER_IAMGE=hub.byted.org/base/data.aml.mlu-base:latest
if [ 0 -eq $num ];then    
  docker run -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=$DISPLAY -e GDK_SCALE -e GDK_DPI_SCALE \
    --privileged=true -v /dev:/dev -v /usr/bin/cnmon:/usr/bin/cnmon \
    --net=host --ipc=host --pid=host -it -d --name $MY_CONTAINER \
    -v /data00:/data00 -v /data01:/data01 -v /data02:/data02 \
    -v /data03:/data03 -w /data00/ \
    $DOCKER_IAMGE \
    /bin/bash
else
  docker start $MY_CONTAINER
  docker exec -ti $MY_CONTAINER /bin/bash
fi