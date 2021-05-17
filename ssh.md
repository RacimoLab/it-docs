
# SSH Keys

It's recommended to use SSH keys for authentication to the servers.
Keys are more convenient, because typing a password when logging
in can be avoided.

1. On your (Mac or Linux) workstation, create the public/private key pair.
When prompted for a passphrase, just hit enter so that you
won't need a password when logging in.

```
ssh-keygen
```

2. Transfer the public part of your key pair to the remote server.
This can be done manually, but the easiest way is:

```
ssh-copy-id <username>@ssh-snm-willerslev.science.ku.dk
```

This will prompt for a password to authenticate with the remote
server in order to copy the file. Once successful though,
future logins will use the key pair for authentication, and will
not prompt for a password (assuming you login from your workstation,
which has the private part of your key pair).


# SSH config file

Create and use a `~/.ssh/config` file on your workstation. E.g., using a
password-less ssh key for authentication and the following `~/.ssh/config`,
user abc123 can login with the `ssh snm` command.

```
Host snm
        Hostname ssh-snm-willerslev.science.ku.dk
        User abc123
        ServerAliveInterval 60
```     

## Logging into a compute node directly

To login to a compute node, usually one needs to first ssh into the
`ssh-snm-willerslev.science.ku.dk` node (known as the "head node",
the "login node", or the "bastion node"), and then ssh to one of the
compute nodes. This can be inconvenient if you're always logging in
to the same compute node. With the following addition to the
`~/.ssh/config` file, user abc123 can login to the `gpu01` compute
node from their workstation using one command (`ssh gpu`).
The `ProxyJump snm` line assumes a correctly setup `Host snm` block
as above.

```
Host gpu
	Hostname gpu01-snm-willerslev
	User abc123
	ProxyJump snm
```

# SSH port forwarding

Sometimes it's useful to run a server application on a compute node,
and your your workstation as a client. E.g. running a `jupyter` notebook
on the compute node and connecting from your workstation's web browser,
or running `tensorboard` on the compute node and connecting from your
workstation's web browser.

Suppose you started a jupyter notebook server on the gpu01 node like so:
```
$ jupyter notebook
[I 12:30:20.311 NotebookApp] Serving notebooks from local directory: /home/srx907/nb
[I 12:30:20.311 NotebookApp] Jupyter Notebook 6.3.0 is running at:
[I 12:30:20.311 NotebookApp] http://localhost:8888/?token=347d4aac1750407b8709847054ec7c76afe521405fa740b6
[I 12:30:20.311 NotebookApp]  or http://127.0.0.1:8888/?token=347d4aac1750407b8709847054ec7c76afe521405fa740b6
[I 12:30:20.312 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[W 12:30:20.342 NotebookApp] No web browser found: could not locate runnable browser.
[C 12:30:20.342 NotebookApp] 
    
    To access the notebook, open this file in a browser:
        file:///home/srx907/.local/share/jupyter/runtime/nbserver-139411-open.html
    Or copy and paste one of these URLs:
        http://localhost:8888/?token=347d4aac1750407b8709847054ec7c76afe521405fa740b6
     or http://127.0.0.1:8888/?token=347d4aac1750407b8709847054ec7c76afe521405fa740b6
```

Then assuming you have the `ProxyJump` setup in your `.ssh/config` as outlined in
the section above, you can forward port 8888 on gpu01 to port 8888 on your
workstation by running the following command on your workstation:
```
ssh -L 8888:localhost:8888 gpu
```

And then open the localhost:8888/?token=blah url on your workstation.

A more detailed discussion of ssh tunnelling can be found at:
https://github.com/RacimoLab/JupyterNotebook_in_Willerslev_servers
