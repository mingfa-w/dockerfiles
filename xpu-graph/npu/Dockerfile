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
    apt-get install -y wget gdb tree bash-completion curl sshpass locales openssh-server \
    #clang lld lldb ninja-build ccache libssl-dev clang-format build-essential jq \
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

# COPY torch_mlu-1.23.1+torch2.1.0-cp310-cp310-linux_x86_64.whl /tmp/
# COPY torch-2.1.0-cp310-cp310-linux_x86_64.whl /tmp/
# # create python venv for py3-xpu_graph
# ARG PY3_XPU_GRAPH=${VENV_PATH}/xpu-graph
# RUN python -m venv ${PY3_XPU_GRAPH} && \
#     ${PY3_XPU_GRAPH}/bin/pip install --upgrade pip && \
#     ${PY3_XPU_GRAPH}/bin/pip3 install wheel setuptools ninja wheel pybind11 attrs==24.2.0 numpy==1.26.4 scipy==1.13.1 decorator==5.1.1 psutil==6.0.0 pytest==8.3.2 pytest-xdist==3.6.1 lit pandas matplotlib pyyaml dataclasses pydot lintrunner && \
#     ${PY3_XPU_GRAPH}/bin/pip3 install /tmp/torch_mlu-1.23.1+torch2.1.0-cp310-cp310-linux_x86_64.whl && \
#     ${PY3_XPU_GRAPH}/bin/pip3 install /tmp/torch-2.1.0-cp310-cp310-linux_x86_64.whl && \
#     chmod 777 -R ${PY3_XPU_GRAPH} && \
#     rm -rf /tmp/torch_mlu-1.23.1+torch2.1.0-cp310-cp310-linux_x86_64.whl && \
#     rm -rf /tmp/torch-2.1.0-cp310-cp310-linux_x86_64.whl

# == 配置ssh private key ==
# Copy over private key, and set permissions
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

# RUN echo "source $APPS_PATH/venv/xpu-graph/bin/activate\n\
# " >> ~/.bashrc_ascend && \
# echo ". ~/.bashrc_ascend" >> ~/.bashrc

# RUN source /torch/venv3/pytorch/bin/activate && which python && pip install expecttest pytest

# 设置sshd自启动
CMD ["/usr/sbin/sshd", "-D"]
WORKDIR /host
# ENTRYPOINT ["/bin/bash"]
