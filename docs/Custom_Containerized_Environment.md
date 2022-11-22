<h1 align="center">Custom Containerized Deep Learning Environment<br>
with Docker and Harbor </h1>
<p align="center">
2022-10-21 v0.4
</p>

# For Beginners: build FROM a base image

*Determined AI* provides [*Docker* images](https://hub.docker.com/r/determinedai/environments/tags) that includes common deep learning libraries and frameworks. You can also [develop your custom image](https://gpu.lins.lab/docs/prepare-environment/custom-env.html) based on your project dependency. For beginners, it is recommended that custom images use one of the official Determined images as a base image, using the `FROM` instruction.

Here is an example: Suppose you have `environment.yaml` for creating the `conda` environment, `pip_requirements.txt` for `pip` requirements and some `apt` packages that needs to be installed. Put these files in a folder, and create a `Dockerfile` with the following contents:

```dockerfile
# Determined Image
FROM determinedai/environments:cuda-11.3-pytorch-1.10-tf-2.8-gpu-0.19.4
# Some important environment variables in Dockerfile
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai LANG=C.UTF-8 LC_ALL=C.UTF-8 PIP_NO_CACHE_DIR=1

# Custom Configuration
RUN sed -i  "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list && \
    sed -i  "s/security.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list && \
    rm -f /etc/apt/sources.list.d/* && \
    apt-get update && \
    apt-get -y install tzdata && \
    apt-get install -y unzip python-opencv graphviz
COPY environment.yml /tmp/environment.yml
COPY pip_requirements.txt /tmp/pip_requirements.txt
RUN conda env update --name base --file /tmp/environment.yml
RUN conda clean --all --force-pkgs-dirs --yes
RUN eval "$(conda shell.bash hook)" && \
    conda activate base && \
    pip config set global.index-url https://mirrors.bfsu.edu.cn/pypi/web/simple &&\
    pip install --requirement /tmp/pip_requirements.txt
```

Here are some other examples:

[svox2](../examples/svox2/)

[lietorch-opencv](../examples/lietorch-opencv/)

Notice that we are using the `apt` mirror by `ustc.edu.cn` and the `pip` mirror by `bfsu.edu.cn`. They are currently fast and thus recommended by the system admin.

To build the image, use the following command:

```bash
docker build -t my_image:v1.0 .
```

where `my_image` is your image name, and `v1.0` is the image tag that usually contains discription and version information. Don't forget the dot "." at the end of the command!

if the Dockerfile building process needs international internet access, you can add build arguements to use the public proxy services:

```bash
docker build -t my_image:v1.0 --build-arg http_proxy=http://192.168.123.62:18889 --build-arg https_proxy=http://192.168.123.62:18889 .
```

The status of our public proxies can be monitored here: [Grafana - vray-dashboard](https://grafana.lins.lab/d/CCSvIIEZz/v2ray-dashboard?orgId=1)

# Upload the custom image

Instead of pushing the image to Docker Hub, it is recommended to use the private Harbor registry: `harbor.lins.lab`.

You need to ask the system admin to create your Harbor user account. Once you have logged in, you can check out the [public library](https://harbor.lins.lab/harbor/projects/1/repositories):

<img src="./Custom_Containerized_Environment/harbor-library.png" alt="Harbor library" style="width:40vw;"/>

Instead of using the default `library`, you can also create your own *project* in Harbor.

You can create your custom docker images on the login node or on your own PC following the instructions above, and then push it to the Harbor registry. For instance:

```bash
    docker login -u <username> -p <password> harbor.lins.lab    # You only need to login once
    docker tag my_image:v1.0  harbor.lins.lab/library/my_image:v1.0
    docker push harbor.lins.lab/library/my_image:v1.0
```

In the first line, replace `<username>` with your username and `<password>` with your password.

In the second line, add the prefix `harbor.lins.lab/library/` to your image. Don't worry, this process does not occupy additional storage.

In the third line, push your new tagged image.

# Use the custom image

In the Determined AI configuration `.yaml` file (as mentioned in [the previous tutorial](./Determined_AI_User_Guide.md#task-configuration-template)), use the newly tagged image (like `harbor.lins.lab/library/my_image:v1.0` above) to tell the system to use your new image as the task environment. Also note that every time you update an image, you need to change the image name, otherwise the system will not be able to detect the image update (probably because it only uses the image name as detection, not its checksum).

# Advanced: build image from scratch

Technically, we will be building FROM an NVIDIA's base image, which is based on an Ubuntu image. You can use the minimum template we provide: [here](./../examples/determined-minimum/)
