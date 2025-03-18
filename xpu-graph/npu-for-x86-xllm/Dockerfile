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
ARG ARCH=x86_64
ARG http_proxy
ARG ftp_proxy
ARG https_proxy
ENV HTTP_PROXY=${http_proxy} \
    HTTPS_PROXY=${http_proxy} \
    FTP_PROXY=${http_proxy}

RUN apt-get update && \
    apt-get install -y adduser sudo vim  tmux net-tools iputils-ping && \
    apt-get install -y wget gdb tree bash-completion curl sshpass locales openssh-server \
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

# install conda, 并创建一个python 3.12.4的虚拟环境
ARG CONDA_PATH=${APPS_PATH}/miniconda3
RUN mkdir -p ${CONDA_PATH} && cd ${CONDA_PATH} && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${CONDA_PATH}/miniconda.sh && \
    bash ${CONDA_PATH}/miniconda.sh -b -u -p ${CONDA_PATH} && \
    rm ${CONDA_PATH}/miniconda.sh && \
    ${CONDA_PATH}/bin/conda create -n py310 python=3.10

# install cmake
RUN mkdir /tmp/cmake && cd /tmp/cmake && \
	wget https://cmake.org/files/v3.22/cmake-3.22.1.tar.gz && \
	tar -zxvf cmake-3.22.1.tar.gz && \
	cd cmake-3.22.1 && \
    ./configure && make -j$(nproc) && make install && \
    rm -rf /tmp/cmake

# install gcc
RUN apt update && apt-get install -y build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libmpc-dev libmpfr-dev libgmp-dev libisl-dev autoconf automake libncurses5-dev libelf-dev > /dev/null && \
    apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists && \
    mkdir -p /opt/apps/ && cd /opt/apps && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-9.5.0/gcc-9.5.0.tar.gz && \
    tar xvf gcc-9.5.0.tar.gz && \
    cd gcc-9.5.0 && \
    mkdir build && cd build && \
    ../configure --prefix=/usr/local/gcc-9.5.0 --enable-languages=c,c++ --disable-multilib && \
    make -j$(nproc) && \
    make install && \
    rm -rf /opt/apps/gcc-9.5.0
# RUN update-alternatives --install /usr/bin/gcc gcc /usr/local/gcc-9.5.0/bin/gcc 60 && \
    # update-alternatives --install /usr/bin/g++ g++ /usr/local/gcc-9.5.0/bin/g++ 60 && \
    # update-alternatives --config gcc && \
    # update-alternatives --config g++

ENV PATH="/usr/local/bin:$PATH"

# create python venv for xllm
ARG PY3_XLLM=${VENV_PATH}/xllm
RUN python -m venv ${PY3_XLLM} && \
    . ${PY3_XLLM}/bin/activate && \
    pip3 install --upgrade pip && \
    pip3 install wheel setuptools ninja wheel pybind11
# install torch and torch_npu
RUN mkdir -p /tmp/torch && cd /tmp/torch && \
    # . ${PY3_XLLM}/bin/activate && \
    pip3 uninstall -y torch torch_npu && \
    wget --no-check-certificate https://download.pytorch.org/whl/cpu/torch-2.3.1%2Bcpu-cp39-cp39-linux_x86_64.whl#sha256=a3cb8e61ba311cee1bb7463cbdcf3ebdfd071e2091e74c5785e3687eb02819f9 && \
    pip3 install torch-2.3.1+cpu-cp39-cp39-linux_x86_64.whl && \
    wget --no-check-certificate https://gitee.com/ascend/pytorch/releases/download/v6.0.0-pytorch2.3.1/torch_npu-2.3.1.post4-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl && \
    pip3 install torch_npu-2.3.1.post4-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl && \
    pip3 install triton==2.0.0 xgrammar==0.1.11 openai==1.44.1 && \
    rm /tmp/torch -rf

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

# config ascend env
RUN echo "source $ASCEND_BASE/ascend-toolkit/set_env.sh\n\
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$ASCEND_BASE/driver/lib64/driver:$ASCEND_BASE/driver/lib64/common\n\
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/gcc-9.5.0/lib64 \n\
export NPU_COMPILER_ROOT=$ASCEND_BASE/npu_compiler_aarch64\n\
export HTTP_PROXY=http://sys-proxy-rd-relay.byted.org:8118\n\
export HTTPS_PROXY=http://sys-proxy-rd-relay.byted.org:8118\n\
export FTP_PROXY=http://sys-proxy-rd-relay.byted.org:8118\n\
export LD_LIBRARY_PATH=/usr/local/gcc-9.5.0/lib64:\$LD_LIBRARY_PATH \n\
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib/python3.9/site-packages/torch/lib \n\
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib/python3.9/site-packages/torch_npu/lib \n\
" >> ~/.bashrc_ascend && \
echo ". ~/.bashrc_ascend" >> ~/.bashrc

# install xpu_gpt
RUN cd /tmp && \
    # . ${PY3_XLLM}/bin/activate && \
    git clone --recurse-submodules git@code.byted.org:data/xpu_gpt.git xpu_gpt && \
    cd xpu_gpt && \
    git checkout ec1a165c7f45df93f553ea79ba06ad30ba1d8680 && \
    pip3 install -r requirements-npu-x64.txt --index-url https://bytedpypi.byted.org/simple && \
    pip3 install . && \
    rm /tmp/xpu_gpt -rf

# install xpu_graph
RUN cd /tmp && \
    # . ${PY3_XLLM}/bin/activate && \
    git clone --recurse-submodules --branch master https://github.com/BD-Seed-HHW/xpu_graph.git xpu_graph && \
    cd xpu_graph && \
    pip3 install . && \
    rm /tmp/xpu_graph -rf

#install xLLM
RUN mkdir -p ${CODE_PATH} && \
    # . ${PY3_XLLM}/bin/activate && \
    cd ${CODE_PATH} && \
    git clone --recurse-submodules --branch feat/xpu-support git@code.byted.org:data/xLLM.git xLLM && \
    cd xLLM && \
    pip3 install -r requirements/requirements_npu.txt  --index-url https://bytedpypi.byted.org/simple

# install xpu_ops, PS: 要先在容器中把libxpu_ops编译出来
# CC="/usr/local/gcc-9.5.0/bin/gcc" LD_LIBRARY_PATH="/usr/local/gcc-9.5.0/lib64":$LD_LIBRARY_PATH LDFLAG="-Wl,-rpath=/usr/local/gcc-9.5.0/lib64":$LDFLAG bash scripts/build_ascend.sh
# cp build_out/lib/* ../publish/
# COPY xpu_ops /tmp/xpu_ops
# RUN mkdir -p ${CODE_PATH} && \
#     # . ${PY3_XLLM}/bin/activate && \
#     pip3 uninstall -y bytedxpu_ops && \
#     cd /tmp/xpu_ops/publish && \
#     bash custom_opp_debian_x86_64.run && \
#     pip3 install .

# ascend tools
ARG ASCEND_CANN=8.0.0.alpha003
RUN mkdir /tmp/ascend_tool && cd /tmp/ascend_tool && \
    wget -O toolkit.run https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C20SPC703/Ascend-cann-toolkit_${ASCEND_CANN}_linux-${ARCH}.run?response-content-type=application/octet-stream && \
    bash toolkit.run --quiet --install --install-path=$ASCEND_BASE --install-for-all --force && \
    wget -O kernels.run https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C20SPC703/Ascend-cann-kernels-910b_${ASCEND_CANN}_linux-${ARCH}.run?response-content-type=application/octet-stream && \
    bash kernels.run --quiet --install --install-path=$ASCEND_BASE --install-for-all --force && \
    rm -rf /tmp/ascend_tool

COPY libascend_hal.so /tmp/
RUN . ~/.bashrc && cd /tmp && \
    # . ${PY3_XLLM}/bin/activate && \
    pip3 uninstall -y bytedxpu_ops && \
    git clone --recurse-submodules --branch master git@code.byted.org:data/xpu_ops.git xpu_ops && \
    cd xpu_ops/src && \
    CC="/usr/local/gcc-9.5.0/bin/gcc" LD_LIBRARY_PATH="/usr/local/gcc-9.5.0/lib64:/tmp":$LD_LIBRARY_PATH LDFLAG="-Wl,-rpath=/usr/local/gcc-9.5.0/lib64":$LDFLAG bash scripts/build_ascend.sh && \
    bash build_out/lib/custom_opp_debian_x86_64.run && \
    cp build_out/lib/libxpu_ops.so ../publish && \
    pip3 install ../publish && \
    rm /tmp/xpu_ops -rf

RUN chmod 777 -R ${PY3_XLLM} && \
    chmod -R 777 /usr/local/Ascend/ascend-toolkit

# 设置sshd自启动
CMD ["/usr/sbin/sshd", "-D"]
WORKDIR /host
# ENTRYPOINT ["/bin/bash"]

