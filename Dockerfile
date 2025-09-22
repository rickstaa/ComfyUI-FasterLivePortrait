FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

ENV TensorRT_ROOT=/opt/TensorRT-10.12.0.36
# use distro Python3.10 so we get a matching TensorRT wheel
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3.10 \
        python3.10-venv \
        python3.10-dev \
        libpython3.10-dev \
        python3.10-distutils \
        python3-pip \
        libblas-dev \
        liblapack-dev \
        libopenblas-dev \
        wget ca-certificates git cmake build-essential swig \
        libprotobuf-dev protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Point python3 → python3.10, pip3 → pip3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
 && update-alternatives --install /usr/bin/pip3   pip3   /usr/bin/pip3.11 1

RUN pip3 install --no-cache-dir numpy onnx onnxruntime huggingface_hub
WORKDIR /opt
RUN wget --progress=dot:giga \
  https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.12.0/tars/TensorRT-10.12.0.36.Linux.x86_64-gnu.cuda-12.9.tar.gz \
 && tar -xzf TensorRT-10.12.0.36.Linux.x86_64-gnu.cuda-12.9.tar.gz \
 && rm TensorRT-10.12.0.36.Linux.x86_64-gnu.cuda-12.9.tar.gz

RUN echo "${TensorRT_ROOT}/lib" > /etc/ld.so.conf.d/tensorrt.conf \
&& ldconfig

RUN pip3 install --no-cache-dir \
      ${TensorRT_ROOT}/python/tensorrt-10.12.0.36-cp311-none-linux_x86_64.whl

RUN git clone https://github.com/SeanWangJS/grid-sample3d-trt-plugin.git /grid-sample3d-trt-plugin
RUN git clone --branch vbrealtime_upgrade https://github.com/varshith15/FasterLivePortrait.git /FasterLivePortrait

WORKDIR /FasterLivePortrait
RUN huggingface-cli download warmshao/FasterLivePortrait \
  --local-dir ./checkpoints \
  --exclude "*.git*" "README.md" "docs"

RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

COPY scripts/build_grid_sample3d_plugin.sh /build_grid_sample3d_plugin.sh
COPY scripts/build_fasterliveportrait_trt.sh /build_fasterliveportrait_trt.sh
COPY scripts/onnx_to_trt.py /onnx_to_trt.py

RUN chmod +x /build_fasterliveportrait_trt.sh
RUN chmod +x /build_grid_sample3d_plugin.sh
RUN chmod +x /onnx_to_trt.py

WORKDIR /FasterLivePortrait

CMD ["/bin/bash"]
