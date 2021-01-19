# pytorch-manylinux-binaries

This repository hosts PyTorch binaries (manylinux wheels) for versions since
v1.3.1 (up to v.1.6.0), rebuilt to include support for K40 GPUs (NVIDIA compute
capability 3.5). You can see the modified logic for setting
`TORCH_CUDA_ARCH_LIST`
[here](https://github.com/nelson-liu/builder/blob/stanfordnlp/manywheel/build.sh#L49-L72).

If you're in a hurry, you can find the download links at https://nelsonliu.me/files/pytorch/whl/torch_stable.html , or in [the GitHub Releases for this repo](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases):

- [v1.3.1](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.3.1)
- [v1.4.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.4.0)
- [v1.5.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.5.0)
- [v1.5.1](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.5.1)
- [v1.6.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.6.0)

These wheels are pip-installable with (change the desired PyTorch / CUDA version, as necessary):

```bash
pip install torch==1.3.1+cu92 -f https://nelsonliu.me/files/pytorch/whl/torch_stable.html
```

## Background

Lots of places still use NVIDIA K40 GPUs, but versions of PyTorch since 1.3.1
don't support them anymore in the pre-built binaries
(https://github.com/pytorch/pytorch/issues/30532). I compiled PyTorch binaries
that add back compute capability 3.5 support.

Specifically, I reverted commits
https://github.com/pytorch/builder/commit/8d064bfcfe2e73d89a067dd5f9311828c1792f90
and
https://github.com/pytorch/builder/commit/2aac90bd723dfbb3dc7728152bf0e6877ec4da16
, to make the `TORCH_CUDA_ARCH_LIST` environment variable more inclusive. The
specific value of this variable depends on the CUDA version that PyTorch is
being compiled against, you can check for yourself at
https://github.com/nelson-liu/builder/blob/stanfordnlp/manywheel/build.sh#L49-L74

These wheels are lightly tested. There are some trivial checks that happen
during the build process (e.g., checking that CUDA is properly linked), but I
also ran the PyTorch word-level language modeling example on each binary to
ensure that binaries within each major-version yield the same result /
reasonable results. You can see the logs of these runs in the
[test_logs](./test_logs) directory.

## Disclaimer

The modifications for the repo have only been tested for manylinux wheels---I
haven't tried building for Windows nor OSX, nor have I tried buildiing conda
binaries. I'm pretty sure you'd need to make more modifications to get these to
work.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Maintenance Instructions

If you're just interested in using these wheels, the information below should
not be useful to you. If you're interested in building wheels for a new version
of PyTorch or rerunning builds, the process is documented below.

## Building new wheels

The builds are done off of
[nelson-liu/builder@stanfordnlp](https://github.com/nelson-liu/builder/tree/stanfordnlp).
See the [README of that
repo](https://github.com/nelson-liu/builder/tree/stanfordnlp#commands-to-build)
for commands to build wheels. You can find the build logs for each wheel in the [build_logs folder](https://github.com/nelson-liu/pytorch-manylinux-binaries/tree/master/build_logs)

## Uploading new wheels to GitHub Releases

To make a new release, we'll use [`hub`](https://hub.github.com/).

``` bash
hub release create $(for i in <path/to/version/build/directory>/manywheel/*/* ; do echo "-a ${i}"; done) -m "PyTorch v<version>" v<version>

```

## Testing the binaries 

**Note: these instructions are Stanford NLP-cluster specific, and are mostly
recorded here for use of maintenance.**

### One-time setup:

Clone the PyTorch examples repo:

```bash
cd ~/git/
hub clone pytorch/examples
```

### Testing a set of binaries

Start by making a separate conda environment for each (torch version, CUDA
version, Python version) setting to test:

``` bash
for torchver in 1.3.1; do 
    for cuversion in 92 100 101; do 
        for pyversion in 3.5 3.6 3.7; do 
            conda env remove -n torch${torchver}_${cuversion}_py${pyversion} ; 
            conda create -n torch${torchver}_${cuversion}_py${pyversion} python=${pyversion} --yes ; 
            conda activate torch${torchver}_${cuversion}_py${pyversion} ;
            pip install -U pip
            pip install torch==${torchver}+cu${cuversion} -f https://nelsonliu.me/files/pytorch/whl/torch_stable.html ;
            pip install numpy ;
            conda deactivate ; 
        done; 
    done; 
done
conda clean --all --yes
```

Navigate to the PyTorch examples repo, and open the word-level LM example:

``` bash
cd ~/git/examples/word_language_model/
```

Run the word-level LM example for each (torch version, CUDA version, Python version) setting, in turn. Below are loops for each of the PyTorch versions from 1.3.1 ... 1.6.0 .

``` bash
for torchver in 1.3.1; do 
    for cuversion in 92 100 101; do
        for pyversion in 3.5 3.6 3.7; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p jag-lo --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
``` 

```bash
for torchver in 1.4.0; do 
    for cuversion in 92 100 101; do
        for pyversion in 3.5 3.6 3.7 3.8; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p jag-lo --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
``` 

```bash
for torchver in 1.5.0; do 
    for cuversion in 92 101 102; do
        for pyversion in 3.5 3.6 3.7 3.8; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p jag-lo --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
``` 

```bash
for torchver in 1.5.1; do 
    for cuversion in 92 101 102; do
        for pyversion in 3.5 3.6 3.7 3.8; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p jag-lo --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
``` 

```bash
for torchver in 1.6.0; do 
    for cuversion in 101 102 92; do
        for pyversion in 3.6 3.7 3.8; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p jag-lo --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```
