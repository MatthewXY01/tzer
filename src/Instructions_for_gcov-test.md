# Instructions for gcov-test
After building the two versions of TVM (with memcov and with gcov) successfully.
We perform the tzer-fuzzing, dump TIRs of every step, and do the gcov-test by
```shell
# go back to the root directory of the repo.
cd ..
export TVM_MEMCOV_HOME=$(realpath tvm_cov_patch/tvm-memcov)
export TVM_GCOV_HOME=$(realpath tvm_cov_patch/tvm-gcov)
# (1): 240 minutes tzer-fuzzing and save TIRs (in json) of all iterations.
TVM_HOME=$TVM_MEMCOV_HOME PYTHONPATH=$TVM_HOME/python PASS=1 LOW=1 TIR_REC_JSON=1 python3 src/main_tir.py --fuzz-time 240 --report-folder log-240m-w-pass --tolerance 4

# (2): Compile dumped TIRs using TVM.
TVM_HOME=$TVM_GCOV_HOME python3 src/tzer_gcov_test.py --tvm-home ${TVM_HOME} --report-folder log-240m-w-pass

# (3): Get the coverage information using Gcov-tool.
cd $TVM_GCOV_HOME
gcovr -r . --html -o 240m.html
gcovr -r . --json-summary-pretty -o 240m.json
```