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
    # user requests
    imagemagick \
    # for matplotlib anim
    ffmpeg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN chmod +x /tmp/scripts/install-mbistyles-fonts.sh && /tmp/scripts/install-mbistyles-fonts.sh
RUN chmod +x /tmp/scripts/install-slsdetector-package.sh && /tmp/scripts/install-slsdetector-package.sh



# RUN chmod -R 777 /home/${NB_USER}/.jupyter/

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

# copying "new default" settings like black code formatter
COPY --chown=${NB_UID}:${NB_UID} data/user-settings /home/${NB_USER}/.jupyter/lab/user-settings

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

USER ${NB_UID}

WORKDIR "${HOME}"