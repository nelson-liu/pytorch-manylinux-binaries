# pytorch-manylinux-binaries

This repository hosts PyTorch binaries (manylinux wheels) for versions since
v1.3.1, rebuilt to include support for K40 GPUs (NVIDIA compute capability 3.5).

If you're in a hurry, you can find the download links at https://nelsonliu.me/files/pytorch/whl/torch_stable.html , or in [the GitHub Releases for this repo](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases):

- [v1.3.1](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.3.1)
- [v1.4.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.4.0)
- [v1.5.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.5.0)
- [v1.5.1](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.5.1)
- [v1.6.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.6.0)
- [v1.7.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.7.0)
- [v1.7.1](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.7.1)
- [v1.8.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.8.0)
- [v1.8.1](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.8.1)
- [v1.9.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.9.0)
- [v1.9.1](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.9.1)
- [v1.10.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.10.0)
- [v1.10.1](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.10.1)
- [v1.10.2](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.10.2)
- [v1.11.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.11.0)
- [v1.12.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.12.0)
- [v1.12.1](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.12.1)
- [v1.13.0](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.13.0)
- [v1.13.1](https://github.com/nelson-liu/pytorch-manylinux-binaries/releases/tag/v1.13.1)

These wheels are pip-installable with (change the desired PyTorch / CUDA version, as necessary):

```bash
pip install torch==1.3.1+cu92 -f https://nelsonliu.me/files/pytorch/whl/torch_stable.html
```

## Background

Lots of places still use NVIDIA K40 GPUs, but versions of PyTorch since 1.3.1
don't support them anymore in the pre-built binaries
(https://github.com/pytorch/pytorch/issues/30532). I compiled PyTorch binaries
that add back compute capability 3.5 support.

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

### PyTorch 1.3.1 to 1.7.1

The builds are done off of
[nelson-liu/builder@stanfordnlp](https://github.com/nelson-liu/builder/tree/stanfordnlp).
See the [README of that
repo](https://github.com/nelson-liu/builder/tree/stanfordnlp#commands-to-build)
for commands to build wheels. You can find the build logs for each wheel in the [build_logs folder](https://github.com/nelson-liu/pytorch-manylinux-binaries/tree/master/build_logs).

These builds were only compiled for CUDA 9.x and 10.x, with `TORCH_CUDA_ARCH_LIST=3.5;5.0;6.0;7.0`.

### PyTorch 1.8.0 and onwards

Starting from PyTorch 1.8.0, I've been using the script in `./build_scripts/` to
create the binaries.

- For the CUDA 10.x builds, `TORCH_CUDA_ARCH_LIST=3.5;3.7;5.0;6.0;7.0`.
- For the CUDA 11.1 build, `TORCH_CUDA_ARCH_LIST=3.5;3.7;5.0;6.0;7.0;7.5;8.0;8.6`.

#### PyTorch 1.8.0

``` bash
for torchver in 1.8.0; do 
    for cuversion in 11.1 10.2 10.1; do
        for pyversion in 3.6m 3.7m 3.8 3.9; do
            for builderver in 4b78fd0f5bb0a2601146584239e377098cdc1ed9; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

#### PyTorch 1.8.1

``` bash
for torchver in 1.8.1; do 
    for cuversion in 11.1 10.2 10.1; do
        for pyversion in 3.6m 3.7m 3.8 3.9; do
            for builderver in 52c2f25f20164f1d4d36c620c451a6577353637c; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

#### PyTorch 1.9.0

``` bash
for torchver in 1.9.0; do 
    for cuversion in 11.1 10.2 ; do
        for pyversion in 3.6m 3.7m 3.8 3.9; do
            for builderver in 71a2b9aaf0b4d56a2b6048b92ba71858f3717dbb; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

#### PyTorch 1.9.1

``` bash
for torchver in 1.9.1; do 
    for cuversion in 11.1 10.2 ; do
        for pyversion in 3.6m 3.7m 3.8 3.9; do
            if [ "${pyversion}" = "3.6m" ]; then
                if [ "${cuversion}" = "11.1" ]; then
                    export dockerimage='pytorch/manylinux-cuda111@sha256:90f34492d543a6db7484cfd0951112aeb9bbeac34c8d99cbad8e0f49bd3ccd17'
                else
                    export dockerimage='pytorch/manylinux-cuda102@sha256:6d7e78cac22ba2525d14b0c7e285348ced7c73c0eda2e2298ae8247c7d3adbc4'
fi
            fi
            for builderver in 53c44fc32989aed041e3e9ca99647f20a75e2199; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} \
                ${dockerimage} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

#### PyTorch 1.10.0

``` bash
for torchver in 1.10.0; do 
    for cuversion in 11.3 11.1 10.2 ; do
        for pyversion in 3.6m 3.7m 3.8 3.9; do
            if [ "${pyversion}" = "3.6m" ]; then
                if [ "${cuversion}" = "11.1" ]; then
                    export dockerimage='pytorch/manylinux-cuda111@sha256:e2df9a62cfed436048e48ddaed2a86c48ff9e0807de51bbce19224ebcf9485db'
                elif [ "${cuversion}" = "11.3" ]; then
                    export dockerimage='pytorch/manylinux-cuda113@sha256:c6faecb741a949bcba9e9849f0e14ce122ff336df95a4775b97055032aef3310'
                else
                    export dockerimage='pytorch/manylinux-cuda102@sha256:1c13940c4c933010528285930ce21f048a496aa1761b5245ac50d0ff6ae1da1c'
fi
            fi
            for builderver in 8bb2f032de4a9ef0dd82d39a702256c097e693ec; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} \
                ${dockerimage} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

#### PyTorch 1.10.1

``` bash
for torchver in 1.10.1; do 
    for cuversion in 11.3 11.1 10.2 ; do
        for pyversion in 3.6m 3.7m 3.8 3.9; do
            if [ "${pyversion}" = "3.6m" ]; then
                if [ "${cuversion}" = "11.1" ]; then
                    export dockerimage='pytorch/manylinux-cuda111@sha256:e2df9a62cfed436048e48ddaed2a86c48ff9e0807de51bbce19224ebcf9485db'
                elif [ "${cuversion}" = "11.3" ]; then
                    export dockerimage='pytorch/manylinux-cuda113@sha256:c6faecb741a949bcba9e9849f0e14ce122ff336df95a4775b97055032aef3310'
                else
                    export dockerimage='pytorch/manylinux-cuda102@sha256:1c13940c4c933010528285930ce21f048a496aa1761b5245ac50d0ff6ae1da1c'
fi
            fi
            for builderver in c644abdd8dbe353272cb5d143f51c0db2414e264; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} \
                ${dockerimage} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

#### PyTorch 1.10.2

``` bash
for torchver in 1.10.2; do 
    for cuversion in 11.3 11.1 10.2 ; do
        for pyversion in 3.6m 3.7m 3.8 3.9; do
            if [ "${pyversion}" = "3.6m" ]; then
                if [ "${cuversion}" = "11.1" ]; then
                    export dockerimage='pytorch/manylinux-cuda111@sha256:e2df9a62cfed436048e48ddaed2a86c48ff9e0807de51bbce19224ebcf9485db'
                elif [ "${cuversion}" = "11.3" ]; then
                    export dockerimage='pytorch/manylinux-cuda113@sha256:c6faecb741a949bcba9e9849f0e14ce122ff336df95a4775b97055032aef3310'
                else
                    export dockerimage='pytorch/manylinux-cuda102@sha256:1c13940c4c933010528285930ce21f048a496aa1761b5245ac50d0ff6ae1da1c'
fi
            fi
            for builderver in b575f116248ab366db3026194749c21338475f79; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} \
                ${dockerimage} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

#### PyTorch 1.11.0

``` bash
for torchver in 1.11.0; do 
    for cuversion in 11.5 11.3 10.2 ; do
        for pyversion in 3.7m 3.8 3.9 3.10; do
            for builderver in f5c0510435a6aed0527e4c06f150b26ec8ab1d41; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

#### PyTorch 1.12.0

``` bash
for torchver in 1.12.0; do 
    for cuversion in 11.6 11.3 10.2 ; do
        for pyversion in 3.7m 3.8 3.9 3.10; do
            for builderver in c137372844036bb8fdcd99772cf495766f6ca356; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

#### PyTorch 1.12.1

``` bash
for torchver in 1.12.1; do 
    for cuversion in 11.6 11.3; do
        for pyversion in 3.7 3.8 3.9 3.10; do
            for builderver in f1e7064a8c1842581ff7606872104dcc16427be1; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

#### PyTorch 1.13.0

``` bash
for torchver in 1.13.0; do 
    for cuversion in 11.7 11.6; do
        for pyversion in 3.7 3.8 3.9 3.10 3.11; do
            for builderver in a6e6da06c44d4a3c3a754b898723d370f243dd2f; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

#### PyTorch 1.13.1

``` bash
for torchver in 1.13.1; do 
    for cuversion in 11.7 11.6; do
        for pyversion in 3.7 3.8 3.9 3.10 3.11; do
            for builderver in 65190f8226ff28ede8caf270dc4370a0ae39cbc2; do
                cuversion_nodot="$(echo $cuversion | tr -d '.')"
                ./build_pytorch_wheel.sh \
                ${pyversion} \
                ${cuversion} \
                ${torchver} \
                ${builderver} |& tee ${torchver}.${pyversion}.cu${cuversion_nodot}.txt
            done
        done; 
    done; 
done
```

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
for torchver in 1.12.1; do 
    for cuversion in 116 113; do
        for pyversion in 3.7 3.8 3.9 3.10; do 
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

Run the word-level LM example for each (torch version, CUDA version, Python version) setting, in turn:

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

```bash
for torchver in 1.7.0; do 
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

```bash
for torchver in 1.7.1; do 
    for cuversion in 101 102 92; do
        for pyversion in 3.6 3.7 3.8 3.9; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p jag-lo --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.8.0; do 
    for cuversion in 111 101 102; do
        for pyversion in 3.6 3.7 3.8 3.9; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p jag-lo --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.8.1; do 
    for cuversion in 111 101 102; do
        for pyversion in 3.6 3.7 3.8 3.9; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p john --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.9.0; do 
    for cuversion in 111 102; do
        for pyversion in 3.6 3.7 3.8 3.9; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p john --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.9.1; do 
    for cuversion in 111 102; do
        for pyversion in 3.6 3.7 3.8 3.9; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p john --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.10.0; do 
    for cuversion in 113 111 102; do
        for pyversion in 3.6 3.7 3.8 3.9; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p john --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.10.1; do 
    for cuversion in 113 111 102; do
        for pyversion in 3.6 3.7 3.8 3.9; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p john --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.10.2; do 
    for cuversion in 113 111 102; do
        for pyversion in 3.6 3.7 3.8 3.9; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p john --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.11.0; do 
    for cuversion in 115 113 102; do
        for pyversion in 3.7 3.8 3.9 3.10; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'unset LD_LIBRARY_PATH; python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p john --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.12.0; do 
    for cuversion in 116 113 102; do
        for pyversion in 3.7 3.8 3.9 3.10; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'unset LD_LIBRARY_PATH; python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p john --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.12.1; do 
    for cuversion in 116 113; do
        for pyversion in 3.7 3.8 3.9 3.10; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'unset LD_LIBRARY_PATH; python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p john --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.13.0; do 
    for cuversion in 117 116; do
        for pyversion in 3.7 3.8 3.9 3.10 3.11; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'unset LD_LIBRARY_PATH; python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p john --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```

```bash
for torchver in 1.13.1; do 
    for cuversion in 117 116; do
        for pyversion in 3.7 3.8 3.9 3.10 3.11; do
            echo "starting run for torch${torchver}_${cuversion}_py${pyversion}"
            conda activate torch${torchver}_${cuversion}_py${pyversion} ; 
            nlprun 'unset LD_LIBRARY_PATH; python -c "import torch; print(torch.cuda.is_available()); print(torch.version.cuda)" ; '"python -u main.py --cuda --emsize 650 --nhid 650 --dropout 0.5 --epochs 40 --save wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.pt --tied 2>&1 | tee wt2_lm_torch${torchver}_${cuversion}_py${pyversion}.log" -p john --gpu-count 1 --memory 16g --gpu-type k40 --cpu-count 3 -n wt2_lm_torch${torchver}_${cuversion}_py${pyversion}
            conda deactivate ; 
        done; 
    done; 
done
```
