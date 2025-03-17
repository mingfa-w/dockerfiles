#!/bin/bash -xe
script_dir=$(cd $(dirname $0); pwd)
cur_dir=`pwd`
cd ${script_dir}
USER=tiger
CONTAINER_NAME=$USER
STOP=0
PORT=8006
CORE_NUM=0
# TYPE=devel
TYPE=runtime
# 处理参数
while getopts "su:p:n:t:" opt
do
    case $opt in
        s)
            echo "选项 -s(stop) 被设置"
            STOP=1
            ;;
        u)
            echo "选项 -u(user) 的值是 $OPTARG"
            CONTAINER_NAME=$OPTARG
            ;;
        p)
            echo "选项 -p(port) 的值是 $OPTARG"
            PORT=$OPTARG
            ;;            
        n)
            echo "选项 -n(core number) 的值是 $OPTARG"
            CORE_NUM=$OPTARG
            ;;
        t)
            echo "选项 -t(type) 的值是 $OPTARG"
            TYPE=$OPTARG
            ;;
        \?)
            echo "无效选项: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
. ./common.sh $TYPE

# 防止容器名重复
CONTAINER_NAME=$CONTAINER_NAME.$tag.$PORT.$CORE_NUM

# docker_in_docker=" --net=host --privileged -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/bin/docker "
docker_in_docker=" -p $PORT:22 \
                --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v $(which docker):/bin/docker "
# echo $docker_in_docker ====; exit 0
# docker_run_flag=" --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all --cap-add=SYS_PTRACE --security-opt seccomp=unconfined "
docker_run_flag=" --shm-size=20gb --cap-add=SYS_PTRACE \
                -v /usr/local/dcmi:/usr/local/dcmi \
                -v /usr/local/bin/npu-smi:/usr/local/bin/npu-smi \
                -v /usr/local/Ascend/driver/lib64:/usr/local/Ascend/driver/lib64 \
                -v /usr/local/Ascend/driver/version.info:/usr/local/Ascend/driver/version.info \
                --device=/dev/davinci$CORE_NUM:/dev/davinci$CORE_NUM \
                --device=/dev/davinci_manager:/dev/davinci_manager \
                --device=/dev/devmm_svm:/dev/devmm_svm \
                --device=/dev/hisi_hdc:/dev/hisi_hdc "

MOUNT_DIR=$HOME
# MOUNT_DIR_ASCEND=" -v /data00:/data00 \
#                 -v /data01:/data01 \
#                 -v /data02:/data02 \
#                 -v /data03:/data03 \
#                 -v /data04:/data04 \
#                 -v /data05:/data05 \
#                 -v /data06:/data06 \
#                 -v /data07:/data07 "

GROUP=`id -g -n`
GROUPID=`id -g`
CMD="docker ps -aq -f name=^$CONTAINER_NAME\$ -f status=running"
echo CMD=$CMD
OLD_ID=`$CMD`
echo ==== container name: $CONTAINER_NAME, OLD_ID: $OLD_ID ===

if [[ $STOP == 1 ]]; then
    echo === stop $CONTAINER_NAME
    docker stop $CONTAINER_NAME
    exit 0
fi

if [ -z "$OLD_ID" ]; then
    CMD="docker run $docker_in_docker $docker_run_flag -t -d --name $CONTAINER_NAME $MOUNT_DIR_ASCEND -v $MOUNT_DIR:/host --tmpfs /tmp:exec --rm $image "
    echo CMD = $CMD
    ID=`$CMD`
    # docker exec --user root $ID groupadd -f -g $GROUPID $GROUP
    # docker exec --user root $ID adduser --shell /bin/bash --uid $UID --gecos '' --ingroup $GROUP --disabled-password --home /home/$USER --force-badname $USER
    # #docker exec --user root $ID bash -c " echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER && chmod 0440 /etc/sudoers.d/$USER"
    # userPasswd="8uhb9ijn"
    # echo -e "$userPasswd\n$userPasswd" | docker exec --user root -i $ID passwd $USER
    # docker exec --user root $ID usermod -aG sudo $USER
    # docker exec --user root $ID bash -c " echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers"
    # docker exec --user root $ID bash -c ' mkdir ~/.ssh; mkdir /tmp/ccache; ln -s /tmp/ccache ~/.ccache'

    docker exec --user $USER $ID bash -c "mkdir -p /home/$USER/.ssh"
    if [ -f ~/.ssh/authorized_keys ]; then
        docker cp ~/.ssh/authorized_keys $ID:/home/$USER/.ssh/
    fi

    if [ -f ~/.ssh/config ]; then
        docker cp ~/.ssh/config $ID:/home/$USER/.ssh/
    fi

    if [ -f ~/.ssh/id_rsa.pub ]; then
        docker cp ~/.ssh/id_rsa.pub $ID:/home/$USER/.ssh/
    fi

    if [ -f ~/.ssh/id_rsa ]; then
        docker cp ~/.ssh/id_rsa $ID:/home/$USER/.ssh/
    fi

    if [ -f ~/.ssh/known_hosts ]; then
        docker cp ~/.ssh/known_hosts $ID:/home/$USER/.ssh/
    fi
    
    GIT_USER=`git config --get user.name`
    GIT_EMAIL=`git config --get user.email`
    docker exec --user $USER $ID bash -c "git config --global user.name \"$GIT_NAME\""
    docker exec --user $USER $ID bash -c "git config --global user.email \"$GIT_EMAIL\""
    #docker cp ./gitconfig $ID:/home/$USER/.ssh

    # for ascend
    docker exec --user root $ID bash -c " cat /root/.bashrc_ascend >> /home/$USER/.bashrc"
    docker exec --user $USER $ID bash -c " mkdir -p /home/$USER/.triton"
    docker exec --user root $ID bash -c " sshpass -p $userPasswd scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r root@localhost:/root/.triton/json /home/$USER/.triton/"
    docker exec --user root $ID bash -c " sshpass -p $userPasswd scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r root@localhost:/root/.triton/nvidia /home/$USER/.triton/"

    # golang config
    if [ -f ~/.gitconfig ]; then
        docker cp $HOME/.gitconfig $ID:/home/$USER/
    fi
fi
cd ${cur_dir}
docker exec -it --user $USER $CONTAINER_NAME bash
# docker exec -it --user root $CONTAINER_NAME bash