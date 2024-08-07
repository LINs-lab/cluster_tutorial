#! ----EDIT HERE TO CHANGE BASE IMAGE----
FROM nvcr.io/nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04
# COMMENT ABOVE & UNCOMMENT BELOW TO USE BASE IMAGE WITH PYTORCH:
# FROM nvcr.io/nvidia/pytorch:22.12-py3

# Environment variables
ARG PYTHON_VERSION=3.8.12
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai LANG=C.UTF-8 LC_ALL=C.UTF-8 PIP_NO_CACHE_DIR=1

# Install apt packages
RUN sed -i "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list &&\
    sed -i "s/security.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list &&\
    rm -f /etc/apt/sources.list.d/* &&\
    apt-get update && apt-get upgrade -y &&\
    apt-get install -y --no-install-recommends \
        # Determined requirements and common tools
        autoconf automake autotools-dev build-essential ca-certificates \
        make cmake ninja-build pkg-config g++ ccache yasm \
        ccache doxygen graphviz plantuml \
        daemontools krb5-user ibverbs-providers libibverbs1 \
        libkrb5-dev librdmacm1 libssl-dev libtool \
        libnuma1 libnuma-dev libpmi2-0-dev \
        openssh-server openssh-client pkg-config nfs-common \
        ## Tools
        git curl wget unzip nano net-tools sudo htop iotop \
        cloc rsync xz-utils software-properties-common \
    && rm /etc/ssh/ssh_host_ecdsa_key \
    && rm /etc/ssh/ssh_host_ed25519_key \
    && rm /etc/ssh/ssh_host_rsa_key \
    && cp /etc/ssh/sshd_config /etc/ssh/sshd_config_bak \
    && sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config \
    && sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config \
    && grep "^X11UseLocalhost" /etc/ssh/sshd_config || echo "X11UseLocalhost no" >> /etc/ssh/sshd_config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Conda and Determined AI stuff
#! ---EDIT notebook-requirements.txt TO ADD PYPI PACKAGES----
WORKDIR /tmp
ENV PATH="/opt/conda/bin:${PATH}"
ENV PYTHONUNBUFFERED=1 PYTHONFAULTHANDLER=1 PYTHONHASHSEED=0
ENV JUPYTER_CONFIG_DIR=/run/determined/jupyter/config
ENV JUPYTER_DATA_DIR=/run/determined/jupyter/data
ENV JUPYTER_RUNTIME_DIR=/run/determined/jupyter/runtime
RUN git clone https://github.com/LingzheZhao/determinedai-container-scripts &&\
    cd determinedai-container-scripts &&\
    git checkout v0.2.2 &&\
    ./install_python.sh ${PYTHON_VERSION} &&\
    cp .condarc /opt/conda/.condarc &&\
    pip config set global.index-url https://mirrors.bfsu.edu.cn/pypi/web/simple &&\
    pip install determined && pip uninstall -y determined &&\
    pip install -r notebook-requirements.txt &&\
    pip install -r additional-requirements.txt &&\
    jupyter labextension disable "@jupyterlab/apputils-extension:announcements" &&\
    ./add_det_nobody_user.sh &&\
    ./install_libnss_determined.sh &&\
    rm -rf /tmp/*

#! ----EDIT HERE TO INSTALL CONDA PACKAGES----
# Example: PyTorch w/ cuda 11.6
# RUN conda install pytorch torchvision torchaudio cudatoolkit=11.6 -c pytorch -c conda-forge
# Example: Jax
# RUN conda install -c conda-forge jax
# Example: OpenCV
# RUN conda install -c conda-forge opencv
