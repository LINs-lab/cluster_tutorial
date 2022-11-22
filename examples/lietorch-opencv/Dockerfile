FROM determinedai/environments:cuda-11.3-pytorch-1.10-tf-2.8-gpu-0.19.4
ARG DEBIAN_FRONTEND=noninteractive
ARG OPENCV_VERSION=4.6.0
ENV TZ=Asia/Shanghai LANG=C.UTF-8 LC_ALL=C.UTF-8 PIP_NO_CACHE_DIR=1 MAX_JOBS=48

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
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
        python3-dev python3-pip python3-numpy python3-testresources &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

COPY .condarc /opt/conda/.condarc

# Install OpenCV
RUN cd /tmp/ &&\
    wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip &&\
    unzip $OPENCV_VERSION.zip &&\
    rm $OPENCV_VERSION.zip &&\
    wget https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip &&\
    unzip ${OPENCV_VERSION}.zip &&\
    cd opencv-${OPENCV_VERSION} &&\
    mkdir build && cd build &&\
    cmake \
        -DCMAKE_CXX_STANDARD=17 \
        -DENABLE_CCACHE=ON \
        -DOPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib-${OPENCV_VERSION}/modules \
        -DWITH_CUDA=ON \
        -DWITH_TBB=ON \
        -DWITH_V4L=ON \
        -DWITH_QT=OFF \
        -DWITH_GSTREAMER=ON \
        -DOPENCV_ENABLE_NONFREE=ON \
        -DOPENCV_PYTHON3_INSTALL_PATH=/opt/conda/lib/python3.8/site-packages \
        -DPYTHON3_EXECUTABLE=/opt/conda/bin/python \
        -DINSTALL_PYTHON_EXAMPLES=OFF \
        -DINSTALL_C_EXAMPLES=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_opencv_python2=OFF \
        -DBUILD_opencv_python3=ON \
        -DBUILD_JAVA=OFF \
        -DCUDA_ARCH_BIN=8.6 \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        .. &&\
    make -j &&\
    make install &&\
    ldconfig && rm -rf /tmp/*

COPY lietorch-sm86.diff /tmp
RUN cd /tmp &&\
    git clone --recursive https://github.com/princeton-vl/lietorch &&\
    cd /tmp/lietorch &&\
    git apply /tmp/lietorch-sm86.diff &&\
    /opt/conda/bin/pip install -U \
        numpy scikit-learn &&\
    /opt/conda/bin/python setup.py install &&\
    rm -rf /tmp/*
