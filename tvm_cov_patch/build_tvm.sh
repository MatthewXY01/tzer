set -e

echo "Installing latest TVM... If it fails you may want to use earlier versions."
git clone https://github.com/apache/tvm.git --recursive
# tvm-v0.8-release
cd tvm && git reset --hard 7b3a22e465dd6aca4729504a19beb4bc23312755 && cd ..
cp -r tvm tvm-gcov
echo "Start building TVM with Gcov"
cd tvm-gcov
mkdir -p build
cp cmake/config.cmake build/
patch -p1 < ../gcov4tvm.patch
cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug -DENABLE_GCOV=1
make -j$(nproc)
cd ..
echo "Successfully installed TVM-gcov!"
echo "To use TVM-gcov, copy and paste the following shell statements:"
echo "export TVM_HOME=$(pwd)"
echo "export PYTHONPATH=$TVM_HOME/python"

cd ..
cp -r tvm tvm-memcov

echo "Start building TVM with coverage instrumentation"
cd tvm-memcov
patch -p1 < ../memcov4tvm.patch # cmake/config.make is directly patched, which is then copied to build/
mkdir -p build && cd build
echo "We use LLVM Sanitizers. Please ensure you have clang & compiler-rt installed."
cp ../cmake/config.cmake .
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_CXX_COMPILER=$(which clang++) \
         -DCMAKE_C_COMPILER=$(which clang) \
         -DFETCHCONTENT_QUIET=0
make -j$(nproc)
cd ..
echo "Successfully installed TVM-memcov!"
echo "To use TVM-memcov, copy and paste the following shell statements:"
echo "export TVM_HOME=$(pwd)"
echo "export PYTHONPATH=$TVM_HOME/python"

#echo "Start building TVM without coverage instrumentation"
#cd ../tvm-no-cov
#mkdir -p build && cd build
#cp ../../tvm/cmake/config.cmake . # Sync cmake file with coverage version.
#cmake .. -DCMAKE_BUILD_TYPE=Release \
#         -DCMAKE_CXX_COMPILER=$(which clang++) \
#         -DCMAKE_C_COMPILER=$(which clang) \
#         -DFETCHCONTENT_QUIET=0
#make -j$(nproc)
#cd ..
#echo "Successfully installed TVM w/o coverage!"
#echo "To use TVM-cov, copy and paste the following shell statements:"
#echo "export TVM_HOME=$(pwd)"
#echo "export PYTHONPATH=$TVM_HOME/python"

#echo "Start building LibFuzzer for TVM"
#cd ..
#cp -r tvm tvm-libfuzz
#cd tvm-libfuzz
#rm -rf build
#patch -p1 < ../libfuzz.patch
#mkdir -p build && cd build
#cp ../../tvm/cmake/config.cmake . # Sync cmake file with coverage version.
#cmake .. -DCMAKE_BUILD_TYPE=Release \
#         -DCMAKE_CXX_COMPILER=$(which clang++) \
#         -DCMAKE_C_COMPILER=$(which clang) \
#         -DFETCHCONTENT_QUIET=0
#make -j$(nproc)
#cd ..
#echo "Successfully installed LibFuzzer for TVM"
#echo "To run the libfuzzer driver, simply run ./build/fuzz_me"
#echo "You need to manually stop fuzz_me otherwise it will run forever."
