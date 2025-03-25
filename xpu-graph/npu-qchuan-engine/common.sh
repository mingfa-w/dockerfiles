#!/bin/bash
# common var
# type=$1
type=runtime
target_arch=`arch`

# image param
version="0.1.0"
domain="hub.byted.org"
namespace="tritonx"
name="$type-ascend8.0.0.rc3-ubuntu20.04-${target_arch}-for-engine"
tag="$version"
image="$domain/$namespace/$name:$tag"
APPS_PATH="/opt/apps"
base_image="hub.byted.org/base/lagrange.torch.base:latest"
if [ $type == "devel" ]; then
  name_devel=runtime-${name#*-}
  base_image=$domain/$namespace/$name_devel:$tag
fi
echo ======= $base_image =======
base_image_param=" --build-arg APPS_PATH=$APPS_PATH --build-arg ARCH=$target_arch --build-arg BASE_IMAGE=$base_image "

# ascend param
ASCEND_CANN="8.0.0.RC3.alpha003"
ASCEND_BASE="/usr/local/Ascend"
ascend_param=" --build-arg ASCEND_CANN=$ASCEND_CANN --build-arg ASCEND_BASE=$ASCEND_BASE "

# proxy param
http_proxy="http://sys-proxy-rd-relay.byted.org:8118"
proxy_param=" --build-arg ftp_proxy=$http_proxy --build-arg http_proxy=$http_proxy --build-arg https_proxy=$http_proxy "

# torch and torch_npu param
# TORCH_PACKAGE="https://download.pytorch.org/whl/cpu/torch-2.3.1-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
TORCH_PACKAGE=2.3.1
TORCH_NPU_PACKAGE="https://gitee.com/ascend/pytorch/releases/download/v6.0.rc3-pytorch2.3.1/torch_npu-2.3.1.post2-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
if [ $target_arch == 'x86_64' ]; then
  # TORCH_PACKAGE='https://download.pytorch.org/whl/cpu/torch-2.3.1%2Bcpu-cp39-cp39-linux_x86_64.whl#sha256=a3cb8e61ba311cee1bb7463cbdcf3ebdfd071e2091e74c5785e3687eb02819f9'
  TORCH_NPU_PACKAGE='https://gitee.com/ascend/pytorch/releases/download/v6.0.0-pytorch2.3.1/torch_npu-2.3.1.post4-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl'
fi

torch_and_npu_param=" --build-arg TORCH_PACKAGE=$TORCH_PACKAGE --build-arg TORCH_NPU_PACKAGE=$TORCH_NPU_PACKAGE " 
