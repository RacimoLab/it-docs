# Introduction

The Racimo Lab has a dedicated compute node for machine learning tasks.
This node has:

 * 80 CPU cores.
 * 768 Gb RAM.
 * 5 x NVIDIA Tesla T4 GPUs (16 Gb RAM each).

# Logging in

Ssh to the head node of the willerslev cluster, and from there ssh to
`gpu01-snm-willerslev`. The rest of this document assumes you're logged
into the gpu01 node.

# Status

Use the `nvidia-smi` command to view the current GPU usage. This command
provides similar information to `top`, but for the GPUs.

```
$ nvidia-smi 
Mon May 17 10:13:53 2021       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 418.87.00    Driver Version: 418.87.00    CUDA Version: 10.1     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla T4            Off  | 00000000:06:00.0 Off |                    0 |
| N/A   68C    P8    15W /  70W |     10MiB / 15079MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   1  Tesla T4            Off  | 00000000:2F:00.0 Off |                    0 |
| N/A   71C    P8    12W /  70W |     10MiB / 15079MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   2  Tesla T4            Off  | 00000000:30:00.0 Off |                    0 |
| N/A   65C    P8    12W /  70W |     10MiB / 15079MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   3  Tesla T4            Off  | 00000000:86:00.0 Off |                    0 |
| N/A   50C    P8    10W /  70W |     10MiB / 15079MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   4  Tesla T4            Off  | 00000000:AF:00.0 Off |                    0 |
| N/A   51C    P8    11W /  70W |     10MiB / 15079MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```


# Setup/Installation

There are many ways to use the GPUs, but they will all invariably use CUDA,
which is NVIDIA's software interface for using their GPUs. It's unlikely
that you'll use CUDA directly, and this document assumes you'll be using
Python and the `tensorflow` machine learning library.

## Conda

Because tensorflow has non-Python dependencies (ie., CUDA), we're going to
use `conda` to install packages and manage dependencies.

### Getting miniconda
If you don't already have miniconda installed, then:

1. Navigate to https://docs.conda.io/en/latest/miniconda.html and download
the Linux installer link labelled “Miniconda3 Linux 64-bit”. E.g.

```
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh
```

2. Run the miniconda installer file you’ve downloaded.

```
sh Miniconda3-py39_4.9.2-Linux-x86_64.sh -b -p $HOME/miniconda3
```

This will install miniconda into the `miniconda3` folder inside your
home directory. You can choose an alternative location if you like.

3. Run "conda init".

```
$HOME/miniconda3/bin/conda init
```

This will insert a conda section in your `~/.bashrc` file which adds conda
to your `$PATH`. You will need to log out and log in again to use conda.

4. Disable autoactivation of the base environment.

```
conda config --set auto_activate_base false
```

The "base" environment has various quirks, and should be avoided if possible.
This means you should never run "conda activate", you should always use
a specific named conda environment (which can be activated with
"conda activate my-env" once the environment "my-env" has been created).

### Creating a conda environment for tensorflow

We'll now create a new conda environment that has tensorflow installed.
The command below will create a new environment named `tf` (you could call
it anything though), and will install the `tensorflow-gpu` conda package,
(which pulls in the `cudnn` and `cudatoolkit` dependencis automatically).
Conda *should* take care of choosing appropriately recent versions,
including the Python and tensorflow versions. However, if things go wrong,
it may be necessary to explicitly specify version numbers (or additional
package names, to specify the version of a dependency).

In addition, we specify `blas=*=mkl`. This will install the mkl variant
of blas, which uses the Intel math kernel and markedly improves the speed
of matrix operations on Intel CPUs. Even though we're planning to use the
GPUs, many operations still happen on the CPUs.

**Warning: cudnn, cudatoolkit, and tensorflow are all large, so this command
may take a long time to run. If your current terminal session is not inside
`tmux` or `screen`, now would be a good time to open a new tmux/screen.**

```
conda create -n tf tensorflow-gpu "blas=*=mkl"
```

### Activate and test the conda environment

Activate the conda environment with
```
conda activate tf
```
and try importing tensorflow using Python.

```
(tf) [srx907@gpu01-snm-willerslev ~]$ python
Python 3.9.4 | packaged by conda-forge | (default, May 10 2021, 22:13:33) 
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import tensorflow as tf
2021-05-17 10:19:53.266476: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcudart.so.10.1
```

We should also check that we managed to successfully install the GPU version
of tensorflow, and all its dependencies.
```
>>> tf.test.is_built_with_cuda()
True
>>> tf.config.list_physical_devices('GPU')
2021-05-17 10:21:06.525113: I tensorflow/compiler/jit/xla_cpu_device.cc:41] Not creating XLA devices, tf_xla_enable_xla_devices not set
2021-05-17 10:21:06.532159: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcuda.so.1
2021-05-17 10:21:10.484830: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1720] Found device 0 with properties: 
pciBusID: 0000:06:00.0 name: Tesla T4 computeCapability: 7.5
coreClock: 1.59GHz coreCount: 40 deviceMemorySize: 14.73GiB deviceMemoryBandwidth: 298.08GiB/s
2021-05-17 10:21:10.487648: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1720] Found device 1 with properties: 
pciBusID: 0000:2f:00.0 name: Tesla T4 computeCapability: 7.5
coreClock: 1.59GHz coreCount: 40 deviceMemorySize: 14.73GiB deviceMemoryBandwidth: 298.08GiB/s
2021-05-17 10:21:10.492866: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1720] Found device 2 with properties: 
pciBusID: 0000:30:00.0 name: Tesla T4 computeCapability: 7.5
coreClock: 1.59GHz coreCount: 40 deviceMemorySize: 14.73GiB deviceMemoryBandwidth: 298.08GiB/s
2021-05-17 10:21:10.496995: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1720] Found device 3 with properties: 
pciBusID: 0000:86:00.0 name: Tesla T4 computeCapability: 7.5
coreClock: 1.59GHz coreCount: 40 deviceMemorySize: 14.73GiB deviceMemoryBandwidth: 298.08GiB/s
2021-05-17 10:21:10.499848: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1720] Found device 4 with properties: 
pciBusID: 0000:af:00.0 name: Tesla T4 computeCapability: 7.5
coreClock: 1.59GHz coreCount: 40 deviceMemorySize: 14.73GiB deviceMemoryBandwidth: 298.08GiB/s
2021-05-17 10:21:10.499886: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcudart.so.10.1
2021-05-17 10:21:10.504160: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcublas.so.10
2021-05-17 10:21:10.504238: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcublasLt.so.10
2021-05-17 10:21:10.507295: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcufft.so.10
2021-05-17 10:21:10.508421: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcurand.so.10
2021-05-17 10:21:10.511254: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcusolver.so.10
2021-05-17 10:21:10.513047: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcusparse.so.10
2021-05-17 10:21:10.517912: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcudnn.so.7
2021-05-17 10:21:10.533240: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1862] Adding visible gpu devices: 0, 1, 2, 3, 4
[PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU'), PhysicalDevice(name='/physical_device:GPU:1', device_type='GPU'), PhysicalDevice(name='/physical_device:GPU:2', device_type='GPU'), PhysicalDevice(name='/physical_device:GPU:3', device_type='GPU'), PhysicalDevice(name='/physical_device:GPU:4', device_type='GPU')]
```

Whoa! The output is very verbose! Don't worry too much about this,
just note the final two lines, which show that we have 5 visible gpu
devices. Compare this to the output of an equivalent
CPU-based tensorflow installation:
```
>>> import tensorflow as tf
>>> tf.test.is_built_with_cuda()
False
>>> tf.config.list_physical_devices('GPU')
2021-05-17 10:23:29.424070: I tensorflow/compiler/jit/xla_cpu_device.cc:41] Not creating XLA devices, tf_xla_enable_xla_devices not set
[]
```

Remember to deactivate your conda environment when you don’t need it.

```
conda deactivate
```


# Configuration

## Limiting resource usage.

By default, tensorflow is very greedy, and will try to use all the GPUs
on the system. Even when you write your code to just use one GPU,
tensorflow will lock all the GPUs, preventing other users from being able
to use them! (See `nvidia-smi` output to see which processes/users are using
which GPUs).

To avoid this, we must set the
[`CUDA_VISIBLE_DEVICES`](https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#env-vars)
environment variable. If the variable is not set), all GPU devices will
be visible to tensorflow. We can set this to the numerical ID (or IDs) of
the GPUs that we want to allow tensorflow to use.

E.g., to use GPUs 3 and 4, we can set

```
export CUDA_VISIBLE_DEVICES=3,4
```

And we note that the output has changed when listing the GPU devices
with tensorflow.

```
$ python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
2021-05-17 10:32:40.248379: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcudart.so.10.1
2021-05-17 10:32:43.187191: I tensorflow/compiler/jit/xla_cpu_device.cc:41] Not creating XLA devices, tf_xla_enable_xla_devices not set
2021-05-17 10:32:43.189552: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcuda.so.1
2021-05-17 10:32:47.729749: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1720] Found device 0 with properties: 
pciBusID: 0000:86:00.0 name: Tesla T4 computeCapability: 7.5
coreClock: 1.59GHz coreCount: 40 deviceMemorySize: 14.73GiB deviceMemoryBandwidth: 298.08GiB/s
2021-05-17 10:32:47.732678: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1720] Found device 1 with properties: 
pciBusID: 0000:af:00.0 name: Tesla T4 computeCapability: 7.5
coreClock: 1.59GHz coreCount: 40 deviceMemorySize: 14.73GiB deviceMemoryBandwidth: 298.08GiB/s
2021-05-17 10:32:47.732720: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcudart.so.10.1
2021-05-17 10:32:47.738098: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcublas.so.10
2021-05-17 10:32:47.738156: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcublasLt.so.10
2021-05-17 10:32:47.741772: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcufft.so.10
2021-05-17 10:32:47.743157: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcurand.so.10
2021-05-17 10:32:47.746210: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcusolver.so.10
2021-05-17 10:32:47.748154: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcusparse.so.10
2021-05-17 10:32:47.752901: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcudnn.so.7
2021-05-17 10:32:47.757789: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1862] Adding visible gpu devices: 0, 1
[PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU'), PhysicalDevice(name='/physical_device:GPU:1', device_type='GPU')]
```

Note that the IDs we set in `CUDA_VISIBLE_DEVICES` are not reflected in
the tensorflow output above, because tensorflow just labels the devices
it can see as 0, 1, 2, etc.

## Decreasing the verbosity.

To make tensorflow less noisy, we can use the `TF_CPP_MIN_LOG_LEVEL`
environment variable.

```
export TF_CPP_MIN_LOG_LEVEL=1
```

```
$ python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
[PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU'), PhysicalDevice(name='/physical_device:GPU:1', device_type='GPU')]
```

Ahhh... That's better. :)
