FROM determinedai/environments:cuda-11.3-pytorch-1.10-lightning-1.5-tf-2.8-gpu-0.18.5
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai LANG=C.UTF-8 LC_ALL=C.UTF-8 PIP_NO_CACHE_DIR=1
ENV TORCH_CUDA_ARCH_LIST="8.6"
ENV MAX_JOBS=48

RUN sed -i  "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list &&\
    sed -i  "s/security.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list &&\
    rm -f /etc/apt/sources.list.d/* &&\
    apt-get update && apt-get upgrade -y &&\
    apt-get install -y --no-install-recommends \
        autoconf automake autotools-dev build-essential ca-certificates \
        make cmake ninja-build yasm pkg-config checkinstall doxygen gdb \
        gcc gcc-multilib g++ g++-multilib gfortran \
        git nano curl wget unzip p7zip-full net-tools cloc htop iftop iotop ffmpeg \
        libatlas-base-dev libboost-all-dev libcereal-dev libcgal-dev \
        libcxsparse3 libeigen3-dev liblapack-dev liblapacke-dev \
        metis libmetis-dev libopenblas-dev libsuitesparse-dev \
        libgtk2.0-dev libgtk-3-dev libglew-dev libgl1-mesa-dev libgl1-mesa-glx mesa-utils \
        libgflags-dev libgoogle-glog-dev libgtest-dev libprotobuf-dev protobuf-compiler \
        libgphoto2-dev libhdf5-dev libjpeg-dev libpng-dev libtiff-dev libtiff-dev \
        libavcodec-dev libavformat-dev libavutil-dev libavdevice-dev libavresample-dev \
        libpostproc-dev libpq-dev libswscale-dev ffmpeg \
        libtbb2 libtbb-dev libxine2-dev zlib1g-dev \
        libkrb5-dev libssl-dev libtool libyaml-dev libyaml-cpp-dev \
        libxvidcore-dev x264 libx264-dev libfaac-dev libmp3lame-dev libtheora-dev \
        libfaac-dev libmp3lame-dev libvorbis-dev \
        libopencore-amrnb-dev libopencore-amrwb-dev \
        libv4l-dev v4l-utils \
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev &&\
    pip config set global.index-url https://mirrors.bfsu.edu.cn/pypi/web/simple &&\
    pip install -U pip &&\
    apt-get clean

COPY .condarc /opt/conda/.condarc
COPY ./environment.yml /tmp/environment.yml
RUN conda env update -n base -f /tmp/environment.yml
RUN cd /tmp &&\
    git clone https://github.com/sxyu/svox2 &&\
    cd svox2 &&\
    python setup.py install &&\
    rm -rf /tmp/*
