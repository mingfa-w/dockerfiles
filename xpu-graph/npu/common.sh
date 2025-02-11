#!/bin/bash
version="0.0.0"
domain="hub.byted.org"
# namespace="base"
namespace="tritonx"
name="mlu-devel-ubuntu20.04"
tag="$version"
image="$domain/$namespace/$name:$tag"
# image="hub.byted.org/base/data.aml.mlu-base:latest"
# base_image="hub.byted.org/base/data.aml.mlu-base:latest"
base_image="hub.byted.org/arnold/seed_tag_vllm_npu:6390cb804fa3c1f4721c9acb19483b11"
http_proxy="http://sys-proxy-rd-relay.byted.org:8118"
proxy_param=" --build-arg ftp_proxy=$http_proxy --build-arg http_proxy=$http_proxy --build-arg https_proxy=$http_proxy "
ASCEND_BASE="/usr/local/Ascend"
APPS_PATH="/opt/apps"
base_image_param=" --build-arg BASE_IMAGE=$base_image --build-arg ASCEND_BASE=$ASCEND_BASE --build-arg APPS_PATH=$APPS_PATH "
