ARG BASE_IMAGE=ubuntu:20.04
ARG ssh_prv_key
ARG ssh_pub_key
FROM ${BASE_IMAGE}
ARG ASCEND_BASE=/usr/local/Ascend

RUN echo "root:8uhb9ijn" | chpasswd
EXPOSE 22

ARG APPS_PATH=/opt/apps
ARG CODE_PATH=${APPS_PATH}/code
ARG VENV_PATH=${APPS_PATH}/venv
ARG http_proxy
ARG ftp_proxy
ARG https_proxy
ENV HTTP_PROXY=${http_proxy} \
    HTTPS_PROXY=${http_proxy} \
    FTP_PROXY=${http_proxy}

RUN apt-get update && \
    apt-get install -y adduser sudo vim  tmux net-tools iputils-ping && \
    apt-get install -y wget gdb tree bash-completion curl sshpass locales \
    clang lld lldb ninja-build ccache libssl-dev clang-format build-essential jq \
        > /dev/null && \
    apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists && \
    locale-gen en_US.UTF-8 && \
    mkdir -p /var/run/sshd && \
    echo "if [ -f /etc/bash_completion.d/git ]; then\n\
    . /etc/bash_completion.d/git\n\
fi\n\
" >> /etc/profile

# config language
ENV LANG=C.UTF-8

# # install conda, 并创建一个python 3.12.4的虚拟环境
# ARG CONDA_PATH=${APPS_PATH}/miniconda3
# RUN mkdir -p ${CONDA_PATH} && cd ${CONDA_PATH} && \
#     wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O ${CONDA_PATH}/miniconda.sh && \
#     bash ${CONDA_PATH}/miniconda.sh -b -u -p ${CONDA_PATH} && \
#     rm ${CONDA_PATH}/miniconda.sh && \
#     ${CONDA_PATH}/bin/conda create -n triton-py3124 python=3.12.4

# # == 配置ssh private key ==
# # Copy over private key, and set permissions
# ADD id_rsa /root/.ssh/id_rsa
# ADD id_rsa.pub /root/.ssh/id_rsa.pub
# RUN chmod 700 /root/.ssh/id_rsa && \
#     chmod 700 /root/.ssh/id_rsa.pub && \
#     chown -R root:root /root/.ssh && \
#     echo "Host code.byted.org\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config && \
#     git config --global url.ssh://git@code.byted.org/.insteadOf https://code.byted.org/ && \
#     touch /root/.ssh/known_hosts && \
#     # 设置SSH无密码登录（如果需要）
#     sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
#     mkdir -p /var/run/sshd

# RUN echo "source $ASCEND_BASE/ascend-toolkit/set_env.sh\n\
# export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$ASCEND_BASE/driver/lib64/driver:$ASCEND_BASE/driver/lib64/common\n\
# export NPU_COMPILER_ROOT=$ASCEND_BASE/npu_compiler_aarch64\n\
# source $APPS_PATH/venv/triton-x/bin/activate\n\
# export HTTP_PROXY=http://sys-proxy-rd-relay.byted.org:8118\n\
# export HTTPS_PROXY=http://sys-proxy-rd-relay.byted.org:8118\n\
# export FTP_PROXY=http://sys-proxy-rd-relay.byted.org:8118\n\
# " >> ~/.bashrc_ascend && \
# echo ". ~/.bashrc_ascend" >> ~/.bashrc
RUN apt-get update && \
    apt-get install -y openssh-server
# 设置sshd自启动
CMD ["/usr/sbin/sshd", "-D"]
WORKDIR /host
# ENTRYPOINT ["/bin/bash"]
