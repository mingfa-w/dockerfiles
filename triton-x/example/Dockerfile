ARG BASE_IMAGE=ubuntu:20.04
ARG ssh_prv_key
ARG ssh_pub_key
FROM ${BASE_IMAGE}

RUN echo "root:8uhb9ijn" | chpasswd
EXPOSE 22

ARG APPS_PATH=/opt/apps
ARG CODE_PATH=${APPS_PATH}/code
ARG VENV_PATH=${APPS_PATH}/venv
ARG http_proxy
ARG ftp_proxy
ARG https_proxy
ENV http_proxy=${http_proxy}
ENV https_proxy=${http_proxy}
ENV ftp_proxy=${http_proxy}

RUN sed -i 's/ports.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && \
    yes | unminimize && \
    apt-get install -y apt-utils adduser sudo vim  tmux openssh-server net-tools iputils-ping && \
    apt-get install -y python3.9  python3-dbg python3-pip libmpich-dev \
        git python3-pip python3-distutils python3-wheel python3-yaml python3-setuptools \
        libssl-dev ninja-build libzstd-dev python3.9-dev python3.9-venv \
        wget gdb tree \
        clang lld ninja-build ccache libssl-dev clang-format build-essential apt-utils \
        > /dev/null && \
    apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists && \
    ln -sf /usr/bin/python3.9 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.9 /usr/bin/python

# install cmake
RUN mkdir /tmp/cmake && cd /tmp/cmake && \
	wget https://cmake.org/files/v3.22/cmake-3.22.1.tar.gz && \
	tar -zxvf cmake-3.22.1.tar.gz && \
	cd cmake-3.22.1 && \
    ./configure && make -j$(nproc) && make install && \
    rm -rf /tmp/cmake

RUN mkdir -p /var/run/sshd
# 设置sshd自启动
CMD ["/usr/sbin/sshd", "-D"]
WORKDIR /host
# ENTRYPOINT ["/bin/bash"]
