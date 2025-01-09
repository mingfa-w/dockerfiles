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

RUN sed -i 's/ports.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && \
    yes | unminimize && \
    apt-get install -y apt-utils adduser sudo vim  tmux openssh-server net-tools iputils-ping && \
    apt-get install -y python3.9  python3-dbg python3-pip libmpich-dev \
        git python3-pip python3-distutils python3-wheel python3-yaml python3-setuptools \
        libssl-dev ninja-build libzstd-dev python3.9-dev python3.9-venv \
        wget gdb tree bash-completion curl sshpass locales \
        clang lld lldb clangd-12 ninja-build ccache libssl-dev clang-format build-essential apt-utils jq \
        > /dev/null && \
    apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists && \
    ln -sf /usr/bin/python3.9 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.9 /usr/bin/python && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-12 100 && \
    locale-gen en_US.UTF-8 && \
    mkdir -p /var/run/sshd && \
    echo "if [ -f /etc/bash_completion.d/git ]; then\n\
    . /etc/bash_completion.d/git\n\
fi\n\
" >> /etc/profile

# config language
ENV LANG=C.UTF-8

# install cmake
RUN mkdir /tmp/cmake && cd /tmp/cmake && \
	wget https://cmake.org/files/v3.22/cmake-3.22.1.tar.gz && \
	tar -zxvf cmake-3.22.1.tar.gz && \
	cd cmake-3.22.1 && \
    ./configure && make -j$(nproc) && make install && \
    rm -rf /tmp/cmake

# install llvm for triton-x
ARG LLVM_CODE_NAME=llvm_20.0.0
ARG LLVM_INSTALL_PATH_RELEASE=${APPS_PATH}/${LLVM_CODE_NAME}_release
ARG LLVM_INSTALL_PATH_DEBUG=${APPS_PATH}/${LLVM_CODE_NAME}_debug
RUN git clone -b mingfa-w/b5cc222 https://github.com/mingfa-w/llvm-project.git ${CODE_PATH}/${LLVM_CODE_NAME} && \
    bash ${CODE_PATH}/${LLVM_CODE_NAME}/mingfa-w/build.sh -t Debug -p ${LLVM_INSTALL_PATH_DEBUG} -r && \
    bash ${CODE_PATH}/${LLVM_CODE_NAME}/mingfa-w/build.sh -t Release -p ${LLVM_INSTALL_PATH_RELEASE} -r

# install conda, 并创建一个python 3.12.4的虚拟环境
ARG CONDA_PATH=${APPS_PATH}/miniconda3
RUN mkdir -p ${CONDA_PATH} && cd ${CONDA_PATH} && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O ${CONDA_PATH}/miniconda.sh
RUN bash ${CONDA_PATH}/miniconda.sh -b -u -p ${CONDA_PATH} && \
    rm ${CONDA_PATH}/miniconda.sh && \
    ${CONDA_PATH}/bin/conda create -n triton-py3124 python=3.12.4

# create python venv for py3-triton-x
ARG PY3_TRITON_X=${VENV_PATH}/triton-x
RUN python -m venv ${PY3_TRITON_X} && \
    ${PY3_TRITON_X}/bin/pip install --upgrade pip && \
    ${PY3_TRITON_X}/bin/pip3 install wheel setuptools ninja wheel pybind11 torch  attrs==24.2.0 numpy==1.26.4 scipy==1.13.1 decorator==5.1.1 psutil==6.0.0 pytest==8.3.2 pytest-xdist==3.6.1 lit pandas matplotlib pyyaml && \
    mkdir /tmp/torch_npu && cd /tmp/torch_npu && \
    wget --no-check-certificate https://download.pytorch.org/whl/cpu/torch-2.3.1-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl && \
    ${PY3_TRITON_X}/bin/pip3 install torch-2.3.1-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl && \
    wget --no-check-certificate https://gitee.com/ascend/pytorch/releases/download/v6.0.rc3-pytorch2.3.1/torch_npu-2.3.1.post2-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl && \
    ${PY3_TRITON_X}/bin/pip3 install torch_npu-2.3.1.post2-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl einops && \
    rm /tmp/torch_npu -rf && \
    chmod 777 -R ${PY3_TRITON_X}

# ascend tools
ARG ASCEND_CANN_TOOLKIT_PACKETS=https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C19SPC703/Ascend-cann-toolkit_8.0.RC3.alpha003_linux-aarch64.run?response-content-type=application/octet-stream
ARG ASCEND_CANN_KERNELS_PACKETS=https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C19SPC703/Ascend-cann-kernels-910b_8.0.RC3.alpha003_linux-aarch64.run?response-content-type=application/octet-stream
RUN mkdir /tmp/ascend_tool && cd /tmp/ascend_tool && \
    wget -O toolkit.run ${ASCEND_CANN_TOOLKIT_PACKETS} && \
    bash toolkit.run --quiet --install --install-path=$ASCEND_BASE --install-for-all --force && \
    wget -O kernels.run ${ASCEND_CANN_KERNELS_PACKETS} && \
    bash kernels.run --quiet --install --install-path=$ASCEND_BASE --install-for-all --force && \
    rm -rf /tmp/ascend_tool
ARG GITEE_TOKEN=xxxxx
RUN cd ${ASCEND_BASE} && \
    #sshpass -p Triton0912*%$ scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r bytedance@60.204.158.119:/home/bytedance/triton_downloads/aarch64/npu_compiler_dir_1225.tar.gz . && \
    wget --header "Authorization: Bearer ${GITEE_TOKEN}" -O npu_compiler_aarch64.tar.gz "https://gitee.com/ascend/triton-ascend/releases/download/2024/12/30/npu_compiler_aarch64.tar.gz" && \
    tar xvfz npu_compiler_aarch64.tar.gz && \
    chmod -R 777 npu_compiler_aarch64 && \
    rm npu_compiler_aarch64.tar.gz

# == 配置ssh private key ==
# Copy over private key, and set permissions
ADD id_rsa /root/.ssh/id_rsa
ADD id_rsa.pub /root/.ssh/id_rsa.pub
RUN chmod 700 /root/.ssh/id_rsa && \
    chmod 700 /root/.ssh/id_rsa.pub && \
    chown -R root:root /root/.ssh && \
    echo "Host code.byted.org\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config && \
    git config --global url.ssh://git@code.byted.org/.insteadOf https://code.byted.org/ && \
    touch /root/.ssh/known_hosts && \
    # 设置SSH无密码登录（如果需要）
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    mkdir -p /var/run/sshd

# download triton deps nvidia package
ARG GITHUB_TOKEN=xxxx
ARG REPO=BD-Seed-HHW/triton-x
ARG FILE=triton-x-deps-nvidia.tar.gz
ARG VERSION=v0.1.0-alpha
RUN mkdir -p /root/.triton && cd /root/.triton && \
    curl -L \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -o ${FILE} \
  https://api.github.com/repos/${REPO}/releases/assets/`curl -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3.raw"  -s https://api.github.com/repos/${REPO}/releases | jq ". | map(select(.tag_name == \"${VERSION}\"))[0].assets | map(select(.name == \"${FILE}\"))[0].id"` && \
  tar zxvf ${FILE} && \
  cp -r triton-x-deps-nvidia/* . && \
  rm ${FILE} -rf && rm triton-x-deps-nvidia -rf

# build triton-x
RUN . ${PY3_TRITON_X}/bin/activate && \
   mkdir -p ${CODE_PATH} && cd ${CODE_PATH} && \
   git clone --recurse-submodules --branch develop git@code.byted.org:seed/triton-x.git && \
   cd triton-x && \
   bash tools/script/build-triton-x.sh -t release -r && \
   rm ../triton-x -rf

RUN echo "source $ASCEND_BASE/ascend-toolkit/set_env.sh\n\
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$ASCEND_BASE/driver/lib64/driver:$ASCEND_BASE/driver/lib64/common\n\
export NPU_COMPILER_ROOT=$ASCEND_BASE/npu_compiler_aarch64\n\
source $APPS_PATH/venv/triton-x/bin/activate\n\
export HTTP_PROXY=http://sys-proxy-rd-relay.byted.org:8118\n\
export HTTPS_PROXY=http://sys-proxy-rd-relay.byted.org:8118\n\
export FTP_PROXY=http://sys-proxy-rd-relay.byted.org:8118\n\
" >> ~/.bashrc_ascend && \
echo ". ~/.bashrc_ascend" >> ~/.bashrc && \
mv /bin/sh /bin/sh-bak && ln -s /bin/bash /bin/sh

# 设置sshd自启动
CMD ["/usr/sbin/sshd", "-D"]
WORKDIR /host
# ENTRYPOINT ["/bin/bash"]
