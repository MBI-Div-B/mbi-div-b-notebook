# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
# uses ubuntu:22.04 as the root container.
ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER

LABEL maintainer="@lrlunin"
LABEL description="Docker image for the MBI div B JupyterHub"
# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
COPY data/Fira_Sans.zip /tmp/Fira_Sans.zip
COPY scripts /tmp/scripts
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # for cython: https://cython.readthedocs.io/en/latest/src/quickstart/install.html
    build-essential \
    # for latex labels
    cm-super \
    dvipng \
    fontconfig \
    # for slsdetectorlib
    cmake \
    libzmq5-dev \
    libtiff5-dev \
    # for cuda installation
    apt-utils \
    # user requests
    imagemagick \
    # for matplotlib anim
    ffmpeg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN /tmp/scripts/install-mbistyles-fonts.sh
RUN /tmp/scripts/install-slsdetector-package.sh

# cuda installation like https://hub.docker.com/layers/nvidia/cuda/11.7.0-cudnn8-devel-ubuntu22.04/images/sha256-cf262ed40aa17b168184fd9a8d0ac2ae932e2c6d0fe4f08e0598ab50db08a07d?context=explore
# took instructions from its installation steps 

ENV TARGETARCH=amd64
ENV NVARCH=x86_64
ENV NVIDIA_REQUIRE_CUDA=cuda>=11.7 brand=tesla,driver>=450,driver<451 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471 brand=tesla,driver>=510,driver<511 brand=unknown,driver>=510,driver<511 brand=nvidia,driver>=510,driver<511 brand=nvidiartx,driver>=510,driver<511 brand=quadro,driver>=510,driver<511 brand=quadrortx,driver>=510,driver<511 brand=titan,driver>=510,driver<511 brand=titanrtx,driver>=510,driver<511 brand=geforce,driver>=510,driver<511 brand=geforcertx,driver>=510,driver<511
ENV NV_CUDA_CUDART_VERSION=11.7.60-1
ENV NV_CUDA_LIB_VERSION=11.7.0-1
ENV NV_CUDA_COMPAT_PACKAGE=cuda-compat-11-7

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSLO https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    rm cuda-keyring_1.0-1_all.deb

ENV CUDA_VERSION=11.7.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11-7=${NV_CUDA_CUDART_VERSION} \
    ${NV_CUDA_COMPAT_PACKAGE}

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
ENV PATH=$PATH:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NV_CUDA_LIB_VERSION=11.7.0-1
ENV NV_NVTX_VERSION=11.7.50-1
ENV NV_LIBNPP_VERSION=11.7.3.21-1
ENV NV_LIBNPP_PACKAGE=libnpp-11-7=11.7.3.21-1
ENV NV_LIBCUSPARSE_VERSION=11.7.3.50-1
ENV NV_LIBCUBLAS_PACKAGE_NAME=libcublas-11-7
ENV NV_LIBCUBLAS_VERSION=11.10.1.25-1
ENV NV_LIBCUBLAS_PACKAGE=libcublas-11-7=11.10.1.25-1
ENV NV_LIBNCCL_PACKAGE_NAME=libnccl2
ENV NV_LIBNCCL_PACKAGE_VERSION=2.13.4-1
ENV NCCL_VERSION=2.13.4-1
ENV NV_LIBNCCL_PACKAGE=libnccl2=2.13.4-1+cuda11.7
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-11-7=${NV_CUDA_LIB_VERSION} \
    ${NV_LIBNPP_PACKAGE} \
    cuda-nvtx-11-7=${NV_NVTX_VERSION} \
    libcusparse-11-7=${NV_LIBCUSPARSE_VERSION} \
    ${NV_LIBCUBLAS_PACKAGE} \
    ${NV_LIBNCCL_PACKAGE}

RUN apt-mark hold ${NV_LIBCUBLAS_PACKAGE_NAME} \
    ${NV_LIBNCCL_PACKAGE_NAME}

ENV NV_CUDA_CUDART_DEV_VERSION=11.7.60-1
ENV NV_NVML_DEV_VERSION=11.7.50-1
ENV NV_LIBCUSPARSE_DEV_VERSION=11.7.3.50-1
ENV NV_LIBNPP_DEV_VERSION=11.7.3.21-1
ENV NV_LIBNPP_DEV_PACKAGE=libnpp-dev-11-7=11.7.3.21-1
ENV NV_LIBCUBLAS_DEV_VERSION=11.10.1.25-1
ENV NV_LIBCUBLAS_DEV_PACKAGE_NAME=libcublas-dev-11-7
ENV NV_LIBCUBLAS_DEV_PACKAGE=libcublas-dev-11-7=11.10.1.25-1
ENV NV_NSIGHT_COMPUTE_VERSION=11.7.0-1
ENV NV_NSIGHT_COMPUTE_DEV_PACKAGE=cuda-nsight-compute-11-7=11.7.0-1
ENV NV_NVPROF_VERSION=11.7.50-1
ENV NV_NVPROF_DEV_PACKAGE=cuda-nvprof-11-7=11.7.50-1
ENV NV_LIBNCCL_DEV_PACKAGE_NAME=libnccl-dev
ENV NV_LIBNCCL_DEV_PACKAGE_VERSION=2.13.4-1
ENV NCCL_VERSION=2.13.4-1
ENV NV_LIBNCCL_DEV_PACKAGE=libnccl-dev=2.13.4-1+cuda11.7

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-dev-11-7=${NV_CUDA_CUDART_DEV_VERSION} \
    cuda-command-line-tools-11-7=${NV_CUDA_LIB_VERSION} \
    cuda-minimal-build-11-7=${NV_CUDA_LIB_VERSION} \
    cuda-libraries-dev-11-7=${NV_CUDA_LIB_VERSION} \
    cuda-nvml-dev-11-7=${NV_NVML_DEV_VERSION} \
    ${NV_NVPROF_DEV_PACKAGE} \
    ${NV_LIBNPP_DEV_PACKAGE} \
    libcusparse-dev-11-7=${NV_LIBCUSPARSE_DEV_VERSION} \
    ${NV_LIBCUBLAS_DEV_PACKAGE} \
    ${NV_LIBNCCL_DEV_PACKAGE} \
    ${NV_NSIGHT_COMPUTE_DEV_PACKAGE}
RUN apt-mark hold ${NV_LIBCUBLAS_DEV_PACKAGE_NAME} \
    ${NV_LIBNCCL_DEV_PACKAGE_NAME}
ENV LIBRARY_PATH=$LIBRARY_PATH:/usr/local/cuda/lib64/stubs
ENV NV_CUDNN_VERSION=8.5.0.96
ENV NV_CUDNN_PACKAGE_NAME=libcudnn8
ENV NV_CUDNN_PACKAGE=libcudnn8=8.5.0.96-1+cuda11.7
ENV NV_CUDNN_PACKAGE_DEV=libcudnn8-dev=8.5.0.96-1+cuda11.7
RUN apt-get update && apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} \
    ${NV_CUDNN_PACKAGE_DEV} && \
    apt-mark hold ${NV_CUDNN_PACKAGE_NAME}

# mumax installation to test if it works
# since the cuda version is 11.7 maybe we will need to build it from sources
RUN mkdir /opt/mumax3 && cd /opt/mumax3 && \
    wget https://mumax.ugent.be/mumax3-binaries/mumax3.10_linux_cuda11.0.tar.gz && \
    tar -xzf mumax3.10_linux_cuda11.0.tar.gz
    # && \
    #rm mumax3-2020.10.01-Linux.tar.gz && \
    #ln -s /opt/mumax3/mumax3 /usr/local/bin/mumax3


USER ${NB_UID}

#Install Python 3 packages
RUN mamba install --yes \
    'altair' \
    'beautifulsoup4' \
    'bokeh' \
    'bottleneck' \
    'cloudpickle' \
    'conda-forge::blas=*=openblas' \
    'cython' \
    'dask' \
    'dill' \
    'h5py' \
    'ipympl=0.9.3' \
    'ipywidgets=8.0.6' \
    'jupyterlab-git' \
    'matplotlib-base=3.7.1' \
    'numba' \
    'numexpr' \
    'openpyxl' \
    'pandas' \
    'patsy' \
    'protobuf' \
    'pytables' \
    'scikit-image' \
    'scikit-learn' \
    'scipy' \
    'seaborn' \
    'sqlalchemy' \
    'statsmodels' \
    'sympy' \
    'widgetsnbextension' \
    'xlrd' \
    'conda-forge::pyfai' \
    'jupyterlab-h5web' \
    'xarray' \
    'netCDF4' \
    'conda-forge::dask-labextension' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install packages missing in mamba with pip
# ultrafastfitfunctions need to be installed from git and commit after accepting the pull request
# https://github.com/EmCeBeh/ultrafastFitFunctions/pull/2
RUN pip install --no-cache-dir udkm1Dsim \
    pyEvalData \
    git+https://github.com/lrlunin/ultrafastFitFunctions@5bd30901b405dab1b161f59c7c1d5238c2f12991 \
    git+https://github.com/MBI-Div-B/mbistyles.git \ 
    nbdime \
    jupyterlab-fasta \
    jupyterlab-geojson \
    jupyterlab-katex \
    jupyterlab-mathjax2 \
    jupyterlab-vega3 \
    jupyterlab-code-formatter \
    black && \ 
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# jupyterlab-code-formatter needs to be configured
# https://jupyterlab-code-formatter.readthedocs.io/configuration.html
# see more for jupyterhub https://jupyterlab-code-formatter.readthedocs.io/jupyterhub.html
# potentially:
# RUN jupyter serverextension enable --py jupyterlab_code_formatter --sys-prefix

# Install facets which does not have a pip or conda package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"

# copying "new default" settings like black code formatter
COPY data/user-settings /home/${NB_USER}/.jupyter/lab/user-settings

USER ${NB_UID}

WORKDIR "${HOME}"