#!/bin/bash -xe
script_dir=$(cd $(dirname $0); pwd)
cur_dir=`pwd`
cd ${script_dir}

type=devel # or runtime

# 处理参数
while getopts "t:" opt
do
    case $opt in
        t)
            echo "选项 -t(build type) 的值是 $OPTARG"
            type=$OPTARG
            ;;
        \?)
            echo "无效选项: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
echo ===== build $type type =======
. ./common.sh $type
cp ~/.ssh/id_rsa ${script_dir}
cp ~/.ssh/id_rsa.pub ${script_dir}
src_dir=${script_dir}/../../..
npuc_version=`jq '.npu_compiler' $src_dir/backend/npu/npu-toolchain-version.json`
npuc_version=${npuc_version//\"/}
arch=`arch`

torch_and_npu_param=" --build-arg TORCH_PACKAGE=$TORCH_PACKAGE --build-arg TORCH_NPU_PACKAGE=$TORCH_NPU_PACKAGE " 

DOCKER_BUILDKIT=1 docker build --progress=plain --build-arg ARCH=$arch --build-arg NPUC_VERSION=$npuc_version  $proxy_param $base_image_param $ascend_param $torch_and_npu_param -t $image . -f Dockerfile.$type
cd ${cur_dir}
rm ${script_dir}/id_rsa*
# docker push $image