# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "qlopt"
version = v"0.1.0"

# Collection of sources required to build qlopt
sources = [
    "https://github.com/jgoldfar/qlopt.git" =>
    "87c839112d76a7957dfcbdc09491acdce92cdba4",

    "https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.gz" =>
    "9a2c2819310839ea373f42d69e733c339b4e9a19deab6bfec448281554aa4dbb",

    "http://bitbucket.org/eigen/eigen/get/3.3.7.tar.gz" =>
    "7e84ef87a07702b54ab3306e77cea474f56a40afa1c0ab245bb11725d006d0da",

]

# Bash recipe for building across all platforms
script = raw"""
# Boost build
cd $WORKSPACE/srcdir/boost_1_69_0/
./bootstrap.sh --with-libraries="system,math,test" --prefix=$prefix
./b2 -d0 -q --with-math --with-test --with-system install

# Eigen build
cd $WORKSPACE/srcdir/eigen-eigen-323c052e1731/
mkdir build && cd build/
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain ..
make install

# QLopt build
cd $WORKSPACE/srcdir/qlopt/
make all CXXFLAGS_EXTRA="-I${prefix}/include"
# Install script. TODO: Add install target
mkdir -p $prefix/bin
mv bin/* $prefix/bin
mkdir -p $prefix/lib
mv build/*.a $prefix/lib/
exit

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:x86_64, libc=:musl)
]

# The products that we will ensure are always built
products(prefix) = [
    ExecutableProduct(prefix, "lotkaVolterraExample", :lotkaVolterraExample),
    LibraryProduct(prefix, "libboost_prg_exec_monitor", Symbol("libboost_prg_exec_monitor.so")),
    LibraryProduct(prefix, "libboost_math_c99l", Symbol("libboost_math_c99l.so")),
    LibraryProduct(prefix, "libboost_math_tr1f", Symbol("libboost_math_tr1f.so")),
    LibraryProduct(prefix, "libboost_math_tr1l", Symbol("libboost_math_tr1l.so")),
    LibraryProduct(prefix, "libboost_math_tr1", Symbol("libboost_math_tr1.so")),
    LibraryProduct(prefix, "libboost_math_c99f", Symbol("libboost_math_c99f.so")),
    LibraryProduct(prefix, "libboost_chrono", Symbol("libboost_chrono.so")),
    ExecutableProduct(prefix, "lotkaVolterraWithType2RegsExample", :lotkaVolterraWithType2RegsExample),
    LibraryProduct(prefix, "libboost_math_c99", Symbol("ibboost_math_c99.so")),
    LibraryProduct(prefix, "libboost_timer", Symbol("libboost_timer.so")),
    LibraryProduct(prefix, "libboost_unit_test_framework", Symbol("libboost_unit_test_framework.so")),
    LibraryProduct(prefix, "libboost_system", Symbol("libboost_system.so")),
    ExecutableProduct(prefix, "ThreeStepMetabolicNetworkExample", :ThreeStepMetabolicNetworkExample)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

