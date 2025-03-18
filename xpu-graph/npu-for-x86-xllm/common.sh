#!/bin/bash
version="0.0.1"
domain="hub.byted.org"
# namespace="base"
namespace="tritonx"
name="devel-ubuntu20.04-x86-npu-for-xllm"
tag="$version"
image="$domain/$namespace/$name:$tag"
# image="hub.byted.org/tritonx/npu-devel-ubuntu20.04:ok0.0.0"
# image="hub.byted.org/base/data.aml.mlu-base:latest"
# base_image="hub.byted.org/base/data.aml.mlu-base:latest"
base_image="hub.byted.org/arnold/seed_tag_vllm_npu:6390cb804fa3c1f4721c9acb19483b11"
http_proxy="http://sys-proxy-rd-relay.byted.org:8118"
proxy_param=" --build-arg ftp_proxy=$http_proxy --build-arg http_proxy=$http_proxy --build-arg https_proxy=$http_proxy "
target_arch=`arch`
APPS_PATH="/opt/apps"
base_image_param=" --build-arg BASE_IMAGE=$base_image --build-arg ASCEND_BASE=$ASCEND_BASE --build-arg APPS_PATH=$APPS_PATH --build-arg ARCH=$target_arch  "

# ascend param
ASCEND_CANN="8.0.0.alpha003"
ASCEND_BASE="/usr/local/Ascend"
ascend_param=" --build-arg ASCEND_CANN=$ASCEND_CANN --build-arg ASCEND_BASE=$ASCEND_BASE "