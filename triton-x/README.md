```
说明：这是一个容器镜像构建和运行脚本
1. common.sh: 用于配置镜像参数，如：基础镜像，目标镜像domain/namespace/name:tag参数。
2. Dockerfile: 里面有构建triton-x及其依赖的llvm, python, python, torch等环境
3. build.sh: 编译生成容器镜像的脚本
  bash build.sh
4. run.sh: 容器运行脚本，-u是镜像名前缀名，-p是映射端口用于ssh连接容器，-s是停止并删除容器(PS:要与-u一起使用)
  bash run.sh -u xxx -p 9000
  PS: 1.如果要删除容器：bash run.sh -u xxx -s
      2.如果进入容器后执行npu-smi info报错：dcmi model initialized failed, because the device is used. ret is -8020
        则修改run.sh里面的device后面数字，不要和其它人使用同一个ascend device，因为910b设备不支持多容器共享

```
