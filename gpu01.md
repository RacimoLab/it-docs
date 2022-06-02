# Introduction

The Racimo Lab has a dedicated compute node for machine learning tasks.
This node has:

 * 80 CPU cores.
 * 768 Gb RAM.
 * 5 x NVIDIA Tesla T4 GPUs (16 Gb RAM each).

# Logging in

Ssh to `racimogpu01fl` just like for the
[racimocomp nodes](servers.md#racimo-cluster).
The rest of this document assumes you're logged into the gpu01 node.

# Status

Use the `nvidia-smi` command to view the current GPU usage. This command
provides similar information to `top`, but for the GPUs.
Note the "CUDA Version" near the top of the output. Software that you use with
the GPUs must be compatible with the CUDA drivers. In general, the drivers
are backwards compatible, so older versions of cudnn/cudatoolkit should
work with newer drivers. But newer cudnn/cudatoolkit versions may
impose a minimum version requirement for the drivers.

```
[srx907@racimogpu01fl ~]$ nvidia-smi 
Thu Jun  2 12:09:50 2022       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 515.43.04    Driver Version: 515.43.04    CUDA Version: 11.7     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla T4            Off  | 00000000:06:00.0 Off |                    0 |
| N/A   70C    P8    21W /  70W |      2MiB / 15360MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
|   1  Tesla T4            Off  | 00000000:2F:00.0 Off |                    0 |
| N/A   73C    P8    21W /  70W |      2MiB / 15360MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
|   2  Tesla T4            Off  | 00000000:30:00.0 Off |                    0 |
| N/A   65C    P8    20W /  70W |      2MiB / 15360MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
|   3  Tesla T4            Off  | 00000000:86:00.0 Off |                    0 |
| N/A   49C    P8    16W /  70W |      2MiB / 15360MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
|   4  Tesla T4            Off  | 00000000:AF:00.0 Off |                    0 |
| N/A   51C    P8    17W /  70W |      2MiB / 15360MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
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

See also [conda.md](conda.md).

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

5. Add bioconda and conda-forge channels.

Conda can be configured to look for packages from various sources (known
as a channel). Conda's own "default" channel includes a variety of packages,
but we almost always need to supplement this channel to obtain additional
software. E.g. tensorflow and msprime exist on the conda-forge channel.

```
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
```

6. Look at your conda config file

Finally, lets take a look a the conda config file. It should resemble
the output below. Note that the channels should appear in the reverse
order to the order in which they were added. This gives the highest
installation priority to packages from conda-forge.

```
$ cat ~/.condarc 
auto_activate_base: false
channels:
  - conda-forge
  - bioconda
  - defaults
```

### Creating a conda environment for tensorflow

**Warning: as of June 2022 we now have CUDA drivers 11.7, so the paragraph
below is out of date. It should now be possible to use newer versions of
cudatoolkit and tensorflow than indicated below, which is probably
preferred (and simpler!).

We'll now create a new conda environment that has tensorflow installed.
The command below will create a new environment named `tf` (you could call
it anything though), and will install a build of `tensorflow` that supports
GPUs via NVIDIA's cudatoolkit. The GPU01 server has CUDA 10.1 (see nvidia-smi
output as above), so the version of the cudatoolkit must match this.
And the tensorflow build itself must then work with this specific version
of the cudatoolkit.
The build specified below is for tensorflow 2.4.1. At the time of writing
(October 2021), there were limited version options for appropriate
tensorflow gpu builds. Note that pip tensorflow packages support gpus,
but not for our (now old) version of the cuda drivers.
Welcome to hell.

**Warning: cudnn, cudatoolkit, and tensorflow are all large, so this command
may take a long time to run. If your current terminal session is not inside
`tmux` or `screen`, now would be a good time to open a new tmux/screen.**

```
conda create -n tf cudatoolkit=10.1 cudnn "tensorflow=*=gpu_py39h8236f22_0"
```

### Activate and test the conda environment

Activate the conda environment with
```
conda activate tf
```
and try importing tensorflow using Python.

```
$ python
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
environment variable. If the variable is not set, all GPU devices will
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


# Jupyter notebooks

It's also possible to use the GPUs from within a jupyter notebook.
The easiest way to do this is to install the `jupyter` conda package
in the same conda environment where you installed tensorflow. E.g.

```
conda install -n tf jupyter
```

See [ssh.md](ssh.md#ssh-port-forwarding)
for information about using ssh port forwarding to connect your web browser to
the notebook running on the gpu01 node.

**Note: the environment variables that are set when you start your
notebook will reflect which GPUs are visible to tensorflow.**
To be kind to other users of the gpu01 system, please close your
jupyter server when you're not using it, to ensure that other lab
members can use the GPU resources.
