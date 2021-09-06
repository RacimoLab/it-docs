# Access your cluster files from your local machine

##### This documentation is based on [GenomeDK cluster documentaion](https://genome.au.dk/docs/working-with-data/#accessing-your-files-locally) and another [website](https://www.digitalocean.com/community/tutorials/how-to-use-sshfs-to-mount-remote-file-systems-over-ssh).

The cluster can be *mounted* in your local machine. This means that you are going to create a directory in your computer that is going to access your folder in the cluster. I use this method, for example, to edit scripts using my preferred text editor from my local machine (sublime) or to transfer small files back and forth from my local computer to the cluster. This documentation is for macOS and Linux users, although there are also similar methods to do the same on Windows (read this [link](https://www.digitalocean.com/community/tutorials/how-to-use-sshfs-to-mount-remote-file-systems-over-ssh)).

### 1. Install `sshfs`

#### A. For Ubuntu, Mint, etc. users :

In your local machine run:

```
$ apt-get install sshfs
```

#### B. For Fedora, CentOS etc. users : 

In your local machine run:

```
$ yum install sshfs
```

#### C. For macOS users:

Download and install the SSHFS and FUSE from the [OSX FUSE website](https://osxfuse.github.io/).

### 2. Create your mirror directory

In your local machine, create a directory where the filesystem will be mounted: 

```
$ mkdir ~/Cluster
```

Of course, you can place it wherever you prefer and name it with another name; you only need to be consistent.

### 3. Mount the cluster

Now, you can easily mount the filesystem by running this command in your terminal:

```
$ sshfs -o allow_other,default_permissions KUID@racimocomp01fl:/home/KUID ~/Cluster
```

Note that `KUID` needs to be changed to your id and that you can change the directory mounted to your machine (`/home/KUID` in this case) or the server you are connecting to (instead of `racimocomp01fl`, you can connect to `racimocomp02fl`).


Congratulations! You can now easily and conveniently access your files from your local machine!

If you want to unmount the cluster form your computer, you can just simply run:

```
$ umount ~/Cluster
```
