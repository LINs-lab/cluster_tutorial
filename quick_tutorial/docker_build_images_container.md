# 背景
对于很多工程项目，在服务器现装环境太过于耗时麻烦，因此我们可以借助docker来创建镜像。之后每次运行的时候，只要拉取创建好的镜像，并将其实例化成容器，便可以在其中运行项目代码了。

# Step 1.  创建Dockerfile
我们可以在```/dockerfiles```这个目录下创建docker文件 ```Dockerfile.ngc.4```内容如下
```shell
FROM harbor.lins.lab/library/vlm_agent_research:v1.3

# 使用原始 PyPI 源安装 （对应 配置了proxy的时候使用）
# --index-url 用来制定源
RUN pip3 install --no-cache-dir --index-url=https://pypi.org/simple \
    vllm==0.8.2 \
    math-verify==0.6.0 \
    mathruler==0.1.0 \
    qwen-vl-utils==0.0.10 \
    latex2sympy2-extended==1.0.9 \
    levenshtein==0.27.1 \
    lighteval \
    liger-kernel \
    flash-attn \
    tensordict==0.7.2
```
# Step 2. Building image
```shell
# 一定要先进入dockerfiles这个文件夹下
cd /dockerfiles 
```

```shell
# -f 制定对应的dockerfile
DOCKER_BUILDKIT=0 docker build -t my_image:v1.0 --build-arg http_proxy=http://10.0.2.169:18889 --build-arg https_proxy=http://10.0.2.169:18889 -f Dockerfile.ngc.4 .

```

# Step 3. 把image推送到云端harbour
```shell
# 
docker login -u <username> -p <password> harbor.lins.lab    # You only need to login once

# 为images打上tag，harbor.lins.lab/library/my_image:v1.0 （增加了前缀 larbor.lins.lab/library/ ）
docker tag my_image:v1.0  harbor.lins.lab/library/my_image:v1.0

#  push your new tagged image.
docker push harbor.lins.lab/library/my_image:v1.0
```

# 检查本地镜像
```
docker images
```

# 参考
[Custom Containerized Deep Learning Environment with Docker and Harbor](https://github.com/LINs-lab/cluster_tutorial/blob/main/docs/Custom_Containerized_Environment.md)
