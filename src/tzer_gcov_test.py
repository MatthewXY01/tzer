import os
import sys
from argparse import Namespace, ArgumentParser
from subprocess import run, CalledProcessError, TimeoutExpired

from tqdm import tqdm


_JSON_DUMP_ = 'tir_json_dump'
_FUNC_BY_ITER_PREFIX_ = 'func_by_iter_'
_PASS_BY_ITER_PREFIX_ = 'pass_by_iter_'


args = Namespace()


def parse_args():
    global args
    p = ArgumentParser()
    p.add_argument('--tvm-home', type=str, help='Root directory of TVM source code.')
    p.add_argument('--report-folder', type=str, help='Path to the report folder')
    args = p.parse_args()


class TzerGcovTest:
    def compile_all(self, dump_folder: str):
        env = os.environ.copy()
        env['PYTHONPATH'] = os.path.join(args.tvm_home, 'python')

        pbar = tqdm(file=sys.stdout)
        while True:
            it = pbar.n
            func_path = ''.join(
                [os.path.join(dump_folder, _FUNC_BY_ITER_PREFIX_), str(it), ".json"])
            passes_path = ''.join(
                [os.path.join(dump_folder, _PASS_BY_ITER_PREFIX_), str(it), ".json"])
            if not os.path.exists(func_path):  # no func left
                break

            cmd = ['python3', os.path.join(os.path.dirname(__file__), '_tzer_gcov_ps.py'), '-f', func_path, '-p', passes_path]
            try:
                run(cmd, env=env, check=True, timeout=10, stderr=open(os.devnull, 'w'))
            except CalledProcessError:
                pass
            except TimeoutExpired:
                pass

            pbar.update()


if __name__ == '__main__':
    parse_args()
    tvm_test = TzerGcovTest()
    print(args.tvm_home)
    tvm_test.compile_all(os.path.join(args.report_folder, _JSON_DUMP_))
