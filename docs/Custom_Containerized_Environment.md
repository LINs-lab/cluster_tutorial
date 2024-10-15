<h1 align="center">Custom Containerized Deep Learning Environment<br>
with Docker and Harbor </h1>

- [For Beginners: build FROM a base image](#for-beginners-build-from-a-base-image)
  - [Set up the CA certificate to use our Harbor registry](#set-up-the-ca-certificate-to-use-our-harbor-registry)
  - [Example](#example)
- [Upload the custom image](#upload-the-custom-image)
- [Use the custom image](#use-the-custom-image)
- [Advanced: build an image from scratch](#advanced-build-an-image-from-scratch)
- [Proxy](#proxy)
  - [Set up proxy for the docker daemon](#set-up-proxy-for-the-docker-daemon)
  - [Set up proxy in the temporary building container](#set-up-proxy-in-the-temporary-building-container)

# For Beginners: build FROM a base image

*Determined AI* provides [*Docker* images](https://hub.docker.com/r/determinedai/environments/tags) that include common deep-learning libraries and frameworks. You can also [develop your custom image](https://gpu.lins.lab/docs/prepare-environment/custom-env.html) based on your project dependency.

For beginners, it is recommended that custom images use one of the Determined AI's official images as a base image, using the `FROM` instruction.

## Set up the CA certificate to use our Harbor registry

**You can skip this part if you only build your custom docker image on the log-in node.**

Instead of pulling determinedai's images from Docker Hub (which requires setting up proxy now), you can pull them from our Harbor registry.

Make sure you have configured your `hosts` file with the following settings:

```text
10.0.2.169 lins.lab
10.0.2.169 harbor.lins.lab
```

Check out [here](https://harbor.lins.lab/harbor/projects) to see the available images.

We have mirrored some of the determined ai's environments in `harbor`. [Here is the link](https://harbor.lins.lab/harbor/projects/3/repositories/environments).

You can also ask the system admin to add or update the images.

If you want to use the images from the docker hub, you will need to [use the proxy service](#proxy).

To use our Harbor registry, you need to complete the following setup:

```bash
sudo mkdir -p /etc/docker/certs.d/harbor.lins.lab
cd /etc/docker/certs.d/harbor.lins.lab
sudo wget https://lins.lab/lins-lab.crt --no-check-certificate
sudo systemctl restart docker
```

This configures the CA certificate for Docker.

Then log in to our Harbor registry:

```bash
docker login -u <username> -p <password> harbor.lins.lab    # You only need to login once
```

Now edit the first `FROM` line in the `Dockerfile`, and change the base image to some existing image in the Harbor registry, for example:

```dockerfile
FROM harbor.lins.lab/determinedai/environments:cuda-11.8-pytorch-2.0-gpu-mpi-0.31.1
```

## Example

Suppose you have `environment.yaml` for creating the `conda` environment, `pip_requirements.txt` for `pip` requirements and some `apt` packages that need to be installed.

Put these files in a folder, and create a `Dockerfile` with the following contents:

```dockerfile
# Determined AI's base image
FROM harbor.lins.lab/determinedai/environments:cuda-11.8-pytorch-2.0-gpu-mpi-0.31.1
# Another one of their base images, with newer CUDA and pytorch
# FROM determinedai/environments:cuda-11.8-pytorch-2.0-gpu-mpi-0.27.1
# You can check out their images here: https://hub.docker.com/r/determinedai/environments/

# Some important environment variables in Dockerfile
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai LANG=C.UTF-8 LC_ALL=C.UTF-8 PIP_NO_CACHE_DIR=1
# Custom Configuration
RUN sed -i  "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list && \
    sed -i  "s/security.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list && \
    rm -f /etc/apt/sources.list.d/* && \
    apt-get update && \
    apt-get -y install tzdata && \
    apt-get install -y unzip python-opencv graphviz && \
    apt-get clean
COPY environment.yml /tmp/environment.yml
COPY pip_requirements.txt /tmp/pip_requirements.txt
RUN conda env update --name base --file /tmp/environment.yml
RUN conda clean --all --force-pkgs-dirs --yes
RUN eval "$(conda shell.bash hook)" && \
    conda activate base && \
    pip config set global.index-url https://mirrors.bfsu.edu.cn/pypi/web/simple &&\
    pip install --requirement /tmp/pip_requirements.txt
```

If you want to adapt your custom containerized environment for NVIDIA RTX 4090, `CUDA version >= 11.8` is required.

Some other Dockerfile examples:
* [svox2](../examples/svox2/)
* [lietorch-opencv](../examples/lietorch-opencv/)

Notice that we are using the `apt` mirror by `ustc.edu.cn` and the `pip` mirror by `bfsu.edu.cn`. They are currently fast and thus recommended by the system admin.

To build the image, use the following command:

```bash
DOCKER_BUILDKIT=0 docker build -t my_image:v1.0 .
```

where `my_image` is your image name, and `v1.0` is the image tag that usually contains descriptions and version information. `DOCKER_BUILDKIT=0` is needed if you are using private Docker registry (i.e. our Harbor) [[Reference]](https://stackoverflow.com/questions/75766469/docker-build-cannot-pull-base-image-from-private-docker-registry-that-requires).

Don't forget the dot "." at the end of the command!

# Upload the custom image

Instead of pushing the image to Docker Hub, it is recommended to use the private Harbor registry: `harbor.lins.lab`.

You need to ask the system admin to create your Harbor user account. Once you have logged in, you can check out the [public library](https://harbor.lins.lab/harbor/projects/1/repositories):

<img src="./Custom_Containerized_Environment/harbor-library.png" alt="Harbor library" style="width:40vw;"/>

Note that instead of using the default `library`, you can also create your own *project* in Harbor.

Also, you need to complete the CA certificate configuration in the [previous section](#accelerating-the-pulling-stage).

Now you can create your custom docker image on the login node or your PC following the instructions above, and then push the image to the Harbor registry. For instance:

```bash
docker login -u <username> -p <password> harbor.lins.lab    # You only need to login once
docker tag my_image:v1.0  harbor.lins.lab/library/my_image:v1.0
docker push harbor.lins.lab/library/my_image:v1.0
```

In the first line, replace `<username>` with your username and `<password>` with your password.

In the second line, add the prefix `harbor.lins.lab/library/` to your image. Don't worry, this process does not occupy additional storage.

In the third line, push your new tagged image.

# Use the custom image

In the Determined AI configuration `.yaml` file (as mentioned in [the previous tutorial](./Determined_AI_User_Guide.md#task-configuration-template)), use the newly tagged image (like `harbor.lins.lab/library/my_image:v1.0` above) to tell the system to use your new image as the task environment.

Also note that every time you update an image, you need to change the image name, otherwise the system will not be able to detect the image update (probably because it only uses the image name as detection, not its checksum).

# Advanced: build an image from scratch

To make our life easier, we will build our custom image FROM NVIDIA's base image. You can use the minimum template we provide: [determined-minimum](../examples/determined-minimum/)

Note that for RTX 4090, we need `CUDA` version >= `11.8`, thus you need to use the base image from [NGC/CUDA](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda) with tags >= 11.8, or [NGC/Pytorch](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/pytorch) with tags >= 22.09.

Here are some examples tested on RTX 4090:

1. [torch-ngp](../examples/torch-ngp/)
2. [[NEW] nerfstudio](../examples/nerfstudio/)

# Proxy

**You can skip this part if you only build your custom docker image on the log-in node.**

## Set up proxy for the docker daemon

You need to set up proxy for the docker daemon in order to pull images from the docker hub (i.e. `docker pull <image>` command or `FROM <image>` in the first line of your `Dockerfile`) since it has been blocked.

The status of our public proxies can be monitored here: [Grafana - v2ray-dashboard](https://grafana.lins.lab/d/CCSvIIEZz/v2ray-dashboard)

1) To proceed, recursively create the folder:

    ```sh
    sudo mkdir -p /etc/systemd/system/docker.service.d
    ```

2) Add environment variables to the configuration file `/etc/systemd/system/docker.service.d/proxy.conf`:

    ```conf
    [Service]
    Environment="HTTP_PROXY=http://10.0.2.169:18889"
    Environment="HTTPS_PROXY=http://10.0.2.169:18889"
    Environment="NO_PROXY=localhost,127.0.0.1,nvcr.io,aliyuncs.com,edu.cn,lins.lab"
    ```

    You can change `10.0.2.169` and `18889` to the other proxy address and port respectively.

    Note that the `http` is intentionally used in `HTTPS_PROXY` - this is how most HTTP proxies work.

3) Update configuration and restart `Docker`:

    ```sh
    systemctl daemon-reload
    systemctl restart docker
    ```

4) Check the proxy:

    ```sh
    docker info
    ```

## Set up proxy in the temporary building container

If you also need international internet access during the Dockerfile building process, you can add build arguments to use the public proxy services:

```bash
DOCKER_BUILDKIT=0 docker build -t my_image:v1.0 --build-arg http_proxy=http://10.0.2.169:18889 --build-arg https_proxy=http://10.0.2.169:18889 .
```
