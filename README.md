# MRI Imaging and NODDI Analysis Docker Container

## Introduction

This Docker container serves as a comprehensive toolkit designed specifically to meet the needs of professionals and researchers working in the fields of MRI imaging analysis and Neurite Orientation Dispersion and Density Imaging (NODDI). It encapsulates all the necessary tools and libraries required for advanced MRI imaging processing, analysis, and NODDI model fitting, addressing the complexities and specific requirements of this specialized area. This container was developed in response to the outlined requirements for a dedicated environment capable of handling the intricacies of MRI data analysis, including Brain Image Data Structure (BIDS) compliance, multiple CUDA version support, and efficient license management for critical tools like FreeSurfer and FSL.

## Overview of Contents

- **OS**: `Linux 6.2.0-26-generic #26~22.04.1-Ubuntu x86_64`
- **GPU TOOLS**: `CUDA 12.1` and `OpenCL 3.0`, 
- **Image Conversion Tools**: `Chris Rorden's dcm2niiX v1.0.20211006 (JP2:OpenJPEG) GCC11.2.0 x86-64 (64-bit Linux) v1.0.20211006`
- **Neuroimaging Tools**: `FreeSurfer 7.4.1`, `FSL 6.0.7.7`, `cuDIMOT w/ Bingham and Watson Acceleration`, `dmri-amico` and `pybids`
- **Microstructure Modeling**: `Microstructure Optimization Toolbox (MOT) v0.8.1` and `Microstructure Diffusion Toolbox (MDT) v1.2.6`
- **Languages, Libraries and Environments**: `Python 3.11.7`, `conda 23.11.0`, `R 4.3.2`, `Julia 1.9.4`, `gcc 11.4.0` and `JupyterLab 3.6.7`


Additionally, this container is equipped with auxiliary scripts and configuration files to streamline the handling of BIDS-compliant data structures for both input (DICOM directories) and output (MDT data folder).

## Prerequisites
Before proceeding with the setup, ensure that the host machine is equipped with:
- NVIDIA GPU(s) with the latest drivers installed.
- NVIDIA Container Runtime to enable Docker containers to leverage NVIDIA GPUs.


### **NVIDIA Container Runtime Installation**:

To ensure that the Docker container can utilize NVIDIA GPUs, install the NVIDIA Container Runtime by executing the following commands on the host machine:

```sh
sudo apt install curl
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt update
sudo apt install nvidia-container-runtime
```
##  **Building the Docker Image**:

To build the Docker image, specify the base image using the `--build-arg` option. Example:

```sh
docker build --build-arg BASE_IMAGE=base-image-with-cuda -t my-custom-image .
```

### Important Files Explained

- **Dockerfile**: The main Dockerfile that outlines the image's base configuration, installations, and settings. It includes setting up the timezone, installing essential packages, Python libraries, FreeSurfer, and other tools.
  
- **bash.bashrc**: A script to customize the terminal prompt and display a banner upon container startup. It also includes a warning message about running the container as root and the potential implications on file ownership in mounted volumes.
  
- **entrypoint.sh**: The entry script for the container. It prepares the user's home directory, creates symbolic links to `/mnt` and `/media`, and starts the Jupyter notebook server. It can be edited to add more softlinks.
  
- **fslinstaller.py**: This script installs latest FSL. Users do not need to interact with this script directly, as it is executed within the Dockerfile.
  
- **license.txt**: Any users must fill at the [freesurfer registration form](https://surfer.nmr.mgh.harvard.edu/registration.html) to use FreeSurfer within this container. When you get the put it in a same level, alongside your Dockerfile.
  
- **requirements.txt**: Lists Python packages to be installed. Users can modify this file to include additional Python libraries as needed.
  
- **setup_user.sh**: Ensures that the `jovyan` user is correctly set up with UID 1000 and adds the user to the `sudo` group for executing commands as root without a password inside container.

## Usage
After building the image, you can run the container using Docker commands. Here's an example to start the container with GPU support:

```sh
docker run --gpus all -it --rm -p 8888:8888 my-custom-image
```

This command makes the Jupyter notebook server accessible through the host's port 8888. Adjust the port mappings and other Docker run options as needed for your setup. User can also connect to the container with vscode to benefit from GUI applications inside the container.