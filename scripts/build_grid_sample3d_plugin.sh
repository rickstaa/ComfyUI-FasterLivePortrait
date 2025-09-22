#!/bin/bash
set -e

PLUGIN_DIR="$1"
BUILD_DIR="$PLUGIN_DIR/build"

export TensorRT_ROOT=/opt/TensorRT-10.12.0.36/targets/x86_64-linux-gnu
export LD_LIBRARY_PATH=$TensorRT_ROOT/lib:$LD_LIBRARY_PATH

echo "🔵 Building grid-sample3d TensorRT plugin..."

rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DTensorRT_ROOT="$TensorRT_ROOT" \
  -DCMAKE_PREFIX_PATH="$TensorRT_ROOT" \
  -DCMAKE_LIBRARY_PATH="$TensorRT_ROOT/lib" \
  -DCMAKE_CXX_FLAGS="-I$TensorRT_ROOT/include" \
  -DCMAKE_CUDA_FLAGS="-I$TensorRT_ROOT/include" \
  -DCMAKE_SHARED_LINKER_FLAGS="-L$TensorRT_ROOT/lib"

make -j"$(nproc)"

echo "✅ Build complete."
ls -lh "$BUILD_DIR/libgrid_sample_3d_plugin.so"
