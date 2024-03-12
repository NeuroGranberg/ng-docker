ARG BASE_IMAGE="should be specified with --build-arg like: docker build --build-arg BASE_IMAGE=cschranz/gpu-jupyter:v1.6_cuda-12.0_ubuntu-22.04 -t my-custom-image ."

FROM $BASE_IMAGE

ENV SHELL=/bin/bash

USER root

# Add timezone info
ENV TZ=Europe/Stockholm
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# apt installs
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    build-essential \
    software-properties-common \
    gnupg \
    tmux \
    sudo \
    ssh \
    nano \
    mysql-client \
    libpq-dev \
    git \
    vim \
    wget \
    curl \
    ncdu \
    screen \
    less \
    rsync \
    unzip \
    iputils-ping \
    sqlite \
    sqlite3 \
    libgl1-mesa-glx \
    texlive-base \
    texlive-xetex \
    texlive-fonts-recommended \
    python3-rdkit \
    librdkit1 \
    rdkit-data \
    openjdk-17-jdk-headless \
    golang \
    gawk dcm2niix \
    python3 python3-pip python3-pyopencl \
    python3-numpy python3-nibabel python3-pyqt5 \
    python3-matplotlib python3-yaml python3-argcomplete \
    libpng-dev libfreetype6-dev libxft-dev

RUN apt-get update && apt-get -y upgrade \
    && apt-get install -y \
    apt-utils \
    unzip \
    tar \
    curl \
    xz-utils \
    ocl-icd-libopencl1 \
    opencl-headers \
    clinfo \
    ;

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility


# Custom bashrc
COPY bash.bashrc /etc/bash.bashrc

# pip installs
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir pip --upgrade
RUN python3 -m pip install --no-cache-dir -r requirements.txt
RUN python3 -m pip install --no-cache-dir -U "jupyter-server<2.0.0"
RUN python3 -m pip install --no-cache-dir pytorch_toolbelt
RUN rm requirements.txt

# Install FreeSurfer
RUN wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.4.1/freesurfer_ubuntu22-7.4.1_amd64.deb && \
    apt-get install -y --no-install-recommends ./freesurfer_ubuntu22-7.4.1_amd64.deb && \
    rm freesurfer_ubuntu22-7.4.1_amd64.deb

# COPY freesurfer_ubuntu22-7.4.1_amd64.deb .
# RUN  apt-get install -y --no-install-recommends ./freesurfer_ubuntu22-7.4.1_amd64.deb && \
#      rm freesurfer_ubuntu22-7.4.1_amd64.deb

ENV FREESURFER_HOME=/usr/local/freesurfer/7.4.1
COPY license.txt $FREESURFER_HOME
ENV FS_LICENSE=$FREESURFER_HOME/license.txt
ENV SUBJECTS_DIR=$FREESURFER_HOME/subjects
ENV FUNCTIONALS_DIR=$FREESURFER_HOME/sessions
ENV PATH=$FREESURFER_HOME/bin:$PATH
RUN source $FREESURFER_HOME/SetUpFreeSurfer.sh

# User name is hardcoded to jovyan for compatibility purposes
COPY setup_user.sh /tmp/setup_user.sh
RUN chmod +x /tmp/setup_user.sh && /tmp/setup_user.sh && rm /tmp/setup_user.sh

# Makeing sure jovyan can install in opt
RUN chown jovyan /opt/

# Fix user
USER jovyan
COPY entrypoint.sh /

# Install FSL
COPY fslinstaller.py .
RUN echo | python3 fslinstaller.py --skip_registration
RUN rm fslinstaller.py


# Download and setup cuDIMOT
ENV CUDIMOT=/opt/CUDIMOT
ENV SGE_ROOT=''
RUN mkdir -p ${CUDIMOT}/bin && \
    wget -qO /tmp/cudimot.zip http://users.fmrib.ox.ac.uk/~moisesf/cudimot/cudimot.zip && unzip -o -d /opt /tmp/cudimot.zip && \
    wget -qO /tmp/NODDI_Watson.zip http://users.fmrib.ox.ac.uk/~moisesf/cudimot/NODDI_Watson/CUDA_10.2/NODDI_Watson.zip && unzip -o -d /tmp /tmp/NODDI_Watson.zip && \
    cp -r /tmp/bin/* ${CUDIMOT}/bin/ && \
    wget -qO /tmp/NODDI_Bingham.zip http://users.fmrib.ox.ac.uk/~moisesf/cudimot/NODDI_Bingham/CUDA_10.2/NODDI_Bingham.zip && unzip -o -d /tmp /tmp/NODDI_Bingham.zip && \
    cp -r /tmp/bin/* ${CUDIMOT}/bin/

WORKDIR /home/jovyan

# Then the entrypoint will start jupyter notebook server
CMD /entrypoint.sh