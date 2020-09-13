#!/usr/bin/env python3
import argparse
from pathlib import Path


def main(binary_paths, cuda_string):
    for binary_path in binary_paths:
        parent = binary_path.parent
        split_name = binary_path.name.split("-")
        split_name[1] += f"+{cuda_string}"
        new_name = "-".join(split_name)
        new_path = parent / new_name
        print(f"Renaming {binary_path} to {new_path}")
        binary_path.rename(new_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description=("Renames built PyTorch binaries to add CUDA information. "
                     "Expected format is "
                     "torch-<version>-<python>-<python>-<platform>.whl , "
                     "e.g., torch-1.3.1-cp35-cp35m-linux_x86_64.whl ."
                     "The binaries are renamed to "
                     "torch-<version>%2B<cuda_string>-<python>-<python>-<platform>.whl "
                     "e.g., torch-1.3.1%2Bcu92-cp35-cp35m-linux_x86_64.whl")
    )
    parser.add_argument(
        "binary_paths",
        type=Path,
        nargs="+",
        help="Paths to binaries to rename, adding CUDA information.",
    )
    parser.add_argument(
        "cuda_string",
        type=str,
        help="CUDA string (e.g., 'cu92') to use when renaming binaries.",
    )
    args = parser.parse_args()
    main(args.binary_paths, args.cuda_string)
