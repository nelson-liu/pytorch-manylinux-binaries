# pytorch-manylinux-binaries

This repository hosts PyTorch binaries (manylinux wheels) for versions since
v1.3.1 (up to v.1.6.0), rebuilt to include support for K40 GPUs (NVIDIA compute
capability 3.5). You can see the modified logic for setting
`TORCH_CUDA_ARCH_LIST`
[here](https://github.com/nelson-liu/builder/blob/stanfordnlp/manywheel/build.sh#L49-L72).

If you're in a hurry, you can find the download links at https://nelsonliu.me/files/pytorch/whl/torch_stable.html , or in [the GitHub Releases for this repo](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases).

These wheels are pip-installable with (change the desired PyTorch / CUDA version, as necessary):

```bash
pip install torch==1.3.1+cu92 -f https://nelsonliu.me/files/pytorch/whl/torch_stable.html
```

## Background

Lots of places still use NVIDIA K40 GPUs, but versions of PyTorch since 1.3.1
don't support them anymore in the pre-built binaries
(https://github.com/pytorch/pytorch/issues/30532). I compiled PyTorch binaries
that add back compute capability 3.5 support.

Specifically, I reverted commits https://github.com/pytorch/builder/commit/8d064bfcfe2e73d89a067dd5f9311828c1792f90 and https://github.com/pytorch/builder/commit/2aac90bd723dfbb3dc7728152bf0e6877ec4da16 , to make the `TORCH_CUDA_ARCH_LIST` environment variable more inclusive. The specific value of this variable depends on the CUDA version that PyTorch is being compiled against, you can check for yourself at https://github.com/nelson-liu/builder/blob/stanfordnlp/manywheel/build.sh#L49-L74

## Building new wheels

The builds are done off of
[nelson-liu/builder@stanfordnlp](https://github.com/nelson-liu/builder/tree/stanfordnlp).
See the [README of that
repo](https://github.com/nelson-liu/builder/tree/stanfordnlp#commands-to-build)
for commands to build wheels. You can find the build logs for each wheel in the [build_logs folder](https://github.com/nelson-liu/pytorch-manylinux-binaries/tree/master/build_logs)

## Uploading new wheels to GitHub Releases

First, start off by renaming the files to match the PyTorch standard.

``` bash
python3 rename_binaries.py <path/to/version/build/directory>/manywheel/cu<version>/* cu<version>
```

Then, make a new release. We'll use [`hub`](https://hub.github.com/).

``` bash
hub release create $(for i in <path/to/version/build/directory>/manywheel/*/* ; do echo "-a ${i}"; done) -m "PyTorch v<version>" v<version>
```

## Disclaimer

The modifications for the repo have only been tested for manylinux wheels---I
haven't tried building for Windows nor OSX, nor have I tried buildiing conda
binaries. I'm pretty sure you'd need to make more modifications to get these to
work.
