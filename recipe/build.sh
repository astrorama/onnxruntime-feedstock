set -xe

if [ -z "$STRIP" ]; then
    STRIP=strip
fi

declare -a CMAKE_PLATFORM_FLAGS
if [[ -n "${OSX_ARCH}" ]]; then
    CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}" -DCLANG_C_COMPILER="$(which ${CC})" -DCLANG_CXX_COMPILER="$(which ${CXX})")
    PLATFORM="darwin"
    COMPILER=llvm

    # Apply the patch here, after the submodules have been initialized
    patch -p1 < "${RECIPE_DIR}/osx-re2.patch"
else
    CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
    PLATFORM="linux"
    COMPILER=gcc
fi

BUILD_DIR="${SRC_DIR}/release"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -Donnxruntime_DEV_MODE=OFF \
    -Donnxruntime_BUILD_UNIT_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -Donnxruntime_USE_PREINSTALLED_EIGEN=OFF \
    -Donnxruntime_BUILD_SHARED_LIB=ON \
    ${CMAKE_ARGS} \
    ${CMAKE_PLATFORM_FLAGS[@]} \
    "${SRC_DIR}/cmake"

make install ${MAKEFLAGS}
