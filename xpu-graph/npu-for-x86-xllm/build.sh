#!/bin/bash -xe
script_dir=$(cd $(dirname $0); pwd)
cur_dir=`pwd`
cd ${script_dir}
. ./common.sh
cp ~/.ssh/id_rsa ${script_dir}
cp ~/.ssh/id_rsa.pub ${script_dir}
sudo cp /usr/local/Ascend/driver/lib64/driver/libascend_hal.so .
rm xpu_ops -rf
cp ~/code/seed/xpu_ops/ . -rf

# if [ ! -f torch_mlu-1.23.1+torch2.1.0-cp310-cp310-linux_x86_64.whl ]; then
#   curl -u bytedance:Bytedance123\!\@\# -O ftp://download.cambricon.com:8821/product/MLU500/0.21.0/pytorch_v1.23.1_torch2.1/wheel/torch_mlu-1.23.1+torch2.1.0-cp310-cp310-linux_x86_64.whl
# fi

# if [ ! -f torch-2.1.0-cp310-cp310-linux_x86_64.whl ]; then
#   curl -u bytedance:Bytedance123\!\@\# -O ftp://download.cambricon.com:8821/product/MLU500/0.22.0/pytorch2.1.0_v1.24.1/wheel/torch-2.1.0-cp310-cp310-linux_x86_64.whl
# fi

DOCKER_BUILDKIT=1 docker build --progress=plain $proxy_param $base_image_param -t $image . -f Dockerfile
cd ${cur_dir}
rm ${script_dir}/id_rsa*
# docker push $image

