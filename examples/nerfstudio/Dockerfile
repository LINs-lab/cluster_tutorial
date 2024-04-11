FROM nvcr.io/nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 AS base

ARG MAX_JOBS 32
ARG DEBIAN_FRONTEND=noninteractive
ARG CUDA_ARCHITECTURES=89;86
ENV TORCH_CUDA_ARCH_LIST="8.9;8.6" TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV TCNN_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
ENV TZ=Asia/Shanghai LANG=C.UTF-8 LC_ALL=C.UTF-8 PIP_NO_CACHE_DIR=1 PIP_CACHE_DIR=/tmp/

RUN sed -i "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list &&\
    sed -i "s/security.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list &&\
    rm -f /etc/apt/sources.list.d/* &&\
    rm -rf /opt/hpcx/ &&\
    apt-get update && apt-get upgrade -y &&\
    apt-get install -y --no-install-recommends \
        # Determined requirements and common tools / libs
        autoconf automake autotools-dev build-essential ca-certificates gnupg2 \
        make cmake yasm pkg-config gdb gcovr binutils-dev libiberty-dev \
        ninja-build ccache cppcheck doxygen graphviz plantuml \
        cimg-dev \
        clang-format \
        dh-autoreconf \
        libatlas-base-dev \
        libboost-all-dev \
        liblog4cplus-dev \
        libssh2-1-dev \
        libreadline-dev \
        libcereal-dev \
        libcgal-dev \
        libblas-dev libcxsparse3 libceres-dev libeigen3-dev libfftw3-dev liblapack-dev liblapacke-dev libnlopt-dev \
        libflann-dev metis libmetis-dev libopenblas-dev libsuitesparse-dev \
        libgtk2.0-dev libglew-dev libglm-dev libglu1-mesa-dev mesa-utils \
        freeglut3-dev libassimp-dev libglfw3-dev libproj-dev libqt5opengl5-dev \
        libxrandr-dev libxxf86vm-dev \
        libgflags-dev libgoogle-glog-dev libgtest-dev \
        libfreeimage-dev libjpeg-dev libpng-dev libtiff-dev libtiff5-dev \
        libavcodec-dev libavformat-dev libavutil-dev libavdevice-dev libv4l-dev v4l-utils \
        libpcap-dev libpostproc-dev libpq-dev libswscale-dev libxine2-dev \
        intel-mkl libopenmpi-dev libtbb2 libtbb-dev  \
        daemontools krb5-user libkrb5-dev \
        ibverbs-providers libibverbs1 libnuma1 libnuma-dev libpmi2-0-dev \
        libhdf5-dev protobuf-compiler libprotobuf-dev librdmacm1 libsqlite3-dev libssl-dev libtool \
        libyaml-dev libyaml-cpp-dev libicu-dev libsimpleini-dev \
        libpcl-dev \
        libopencv-dev libopenexr-dev \
        ffmpeg zlib1g-dev \
        ## Useful tools
        git curl wget unzip xz-utils nano vim-tiny \
        net-tools sudo htop iotop iputils-ping \
        cloc rsync screen tmux \
        daemontools nfs-common rsync proxychains \
        openssh-server openssh-client \
        software-properties-common \
        # Python
        python-is-python3 python3.10-dev python3-pip python3-numpy \
        # VTK
        libvtk9-dev \
        # OSMesa build dependencies
        libosmesa6-dev \
        # EGL build dependencies
        libopengl-dev \
        libglvnd-dev \
        libgl-dev \
        libglx-dev \
        libegl-dev \
        # X11 utils
        mesa-utils \
        x11-apps \
        xorg-dev \
        # QT
        qtbase5-dev \
    && apt-get purge unattended-upgrades \
    && rm /etc/ssh/ssh_host_ecdsa_key \
    && rm /etc/ssh/ssh_host_ed25519_key \
    && rm /etc/ssh/ssh_host_rsa_key \
    && cp /etc/ssh/sshd_config /etc/ssh/sshd_config_bak \
    && sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config \
    && sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config \
    && grep "^X11UseLocalhost" /etc/ssh/sshd_config || echo "X11UseLocalhost no" >> /etc/ssh/sshd_config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Install Determined AI and python deps
ENV PYTHONUNBUFFERED=1 PYTHONFAULTHANDLER=1 PYTHONHASHSEED=0
ENV JUPYTER_CONFIG_DIR=/run/determined/jupyter/config
ENV JUPYTER_DATA_DIR=/run/determined/jupyter/data
ENV JUPYTER_RUNTIME_DIR=/run/determined/jupyter/runtime
RUN git clone https://github.com/LingzheZhao/determinedai-container-scripts &&\
    cd determinedai-container-scripts &&\
    git checkout v0.2.1 &&\
    pip config set global.index-url https://mirrors.bfsu.edu.cn/pypi/web/simple &&\
    pip install -U pip setuptools pathtools promise pybind11 &&\
    pip install determined && pip uninstall -y determined &&\
    pip install -r notebook-requirements.txt &&\
    ./add_det_nobody_user.sh &&\
    ./install_libnss_determined.sh &&\
    rm -rf /tmp/*

# Install GLOG (required by ceres).
RUN git clone --branch v0.6.0 https://github.com/google/glog --single-branch &&\
    cd glog &&\
    mkdir build &&\
    cd build &&\
    cmake .. &&\
    make -j `nproc` &&\
    make install &&\
    rm -rf /tmp/*
# Add glog path to LD_LIBRARY_PATH.
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib"

# Install Ceres-solver (required by colmap).
RUN git clone --branch 2.1.0 https://ceres-solver.googlesource.com/ceres-solver --single-branch &&\
    cd ceres-solver &&\
    git checkout $(git describe --tags) &&\
    mkdir build &&\
    cd build &&\
    cmake .. -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF &&\
    make -j `nproc` &&\
    make install &&\
    rm -rf /tmp/*

ARG OPENEXR_VERSION=3.2.1
RUN wget https://github.com/AcademySoftwareFoundation/openexr/archive/refs/tags/v${OPENEXR_VERSION}.tar.gz &&\
    tar -xvzf v${OPENEXR_VERSION}.tar.gz &&\
    cd openexr-${OPENEXR_VERSION} &&\
    cmake -B build -GNinja &&\
    cmake --build build -t install &&\
    ldconfig && rm -rf /tmp/*

# Install OpenCV from source.
ARG OPENCV_VERSION="4.8.1"
RUN wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip &&\
    unzip $OPENCV_VERSION.zip &&\
    rm $OPENCV_VERSION.zip &&\
    wget https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip &&\
    unzip ${OPENCV_VERSION}.zip &&\
    cd opencv-${OPENCV_VERSION} &&\
    cmake \
        -B /tmp/opencv-${OPENCV_VERSION}/build \
        -GNinja \
        -DCMAKE_CXX_STANDARD=17 \
        -DOPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib-${OPENCV_VERSION}/modules \
        -DOPENCV_ENABLE_NONFREE=ON \
        -DWITH_TBB=ON \
        -DWITH_QT=ON \
        -DWITH_OPENGL=ON \
        -DWITH_VTK=ON \
        -DWITH_CUDA=ON \
        -DCUDA_ARCH_BIN=${TORCH_CUDA_ARCH_LIST} \
        -DHAVE_FFMPEG=ON \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DCMAKE_INSTALL_PREFIX=/usr/local &&\
    cmake --build build -t install &&\
    ldconfig && rm -rf /tmp/*

# Install colmap.
RUN git clone https://github.com/colmap/colmap &&\
    cd colmap &&\
    # Fix CUDA 12.x compile for tag/3.8
    git checkout 1f80118456f4b587a44f288ce5874099fbfebc36 &&\
    mkdir build &&\
    cd build &&\
    cmake .. -DCUDA_ENABLED=ON \
             -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} &&\
    make -j `nproc` &&\
    make install &&\
    rm -rf /tmp/*

# Install pycolmap, required by hloc.
RUN git clone --branch v0.4.0 --recursive https://github.com/colmap/pycolmap &&\
    cd pycolmap &&\
    pip install . &&\
    rm -rf /tmp/*

# Install pyceres from source
RUN git clone --branch v1.0 --recursive https://github.com/cvg/pyceres &&\
    cd pyceres &&\
    pip install -e . &&\
    rm -rf /tmp/*

# # Install pytorch and torchvision from source
# # Use CXX11 ABI to work with our custom pybind11 extensions
# # ARG TORCH_CXX_FLAGS="-D_GLIBCXX_USE_CXX11_ABI=1"
# RUN git clone --recursive https://github.com/pytorch/pytorch &&\
#     cd pytorch &&\
#     git checkout v2.1.2 &&\
#     git submodule sync &&\
#     git submodule update --init --recursive --jobs 0 &&\
#     TORCH_USE_CUDA_DSA=1 USE_NUMPY=1 USE_CUDNN=1 USE_OPENCV=1 USE_BLAS=1 USE_LAPACK=1 USE_MKL=1 \
#         python setup.py install &&\
#     rm -rf /tmp/*
# RUN pip install sympy &&\
#     git clone --branch v0.16.2 https://github.com/pytorch/vision torchvision --single-branch &&\
#     cd torchvision &&\
#     python setup.py install &&\
#     rm -rf /tmp/*

# Install pre-built pytorch and torchvision
RUN pip install torch==2.1.2+cu118 torchvision==0.16.2+cu118 --extra-index-url https://download.pytorch.org/whl/cu118 &&\
    rm -rf /tmp/*

ARG FORCE_CUDA="1"
ARG CPATH="/usr/local/include:/usr/local/cuda/include:$CPATH"
RUN pip install torch-sparse torch-scatter &&\
    pip install git+https://github.com/cvg/Hierarchical-Localization@master &&\
    pip install git+https://github.com/cvg/pixel-perfect-sfm@main &&\
    pip install git+https://github.com/NVlabs/tiny-cuda-nn@master#subdirectory=bindings/torch &&\
    pip install open3d>=0.16.0 --ignore-installed &&\
    rm -rf /tmp/*

FROM base AS nerfstudio
ARG NS_VER=1.0.3
RUN pip install open3d>=0.16.0 --ignore-installed &&\
    # Stable version
    pip install "nerfstudio[dev,doc,gen]==${NS_VER}" -i https://pypi.org/simple/ &&\
    # Nightly version
    # pip install git+https://github.com/nerfstudio-project/nerfstudio@main -i https://pypi.org/simple/ &&\
    pip install coverage einops torchtyping>=0.1.4 &&\
    rm -rf /tmp/*

CMD ns-install-cli --mode install && /bin/bash
