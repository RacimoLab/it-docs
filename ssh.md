
# SSH Keys

It's recommended to use SSH keys for authentication to the [servers](servers.md).
Keys are more convenient, because typing a password when logging
in can be avoided.

SSH keys come as a pair: by convention these are known as the "private" key
and the "public" key. The private key file should remain on your workstation
and be carefully protected like you would protect a password. The public key
file can be copied to many remote systems, and need not be protected.
The holder of the private key can then authenticate with remote systems that
carry the corresponding public key. E.g. you can use a single public/private
key pair to authenticate with the willerslev cluster, the racimo cluster,
and your github account.

## Creating a public/private key pair

On your (Mac or Linux) workstation, create the public/private key pair.
There are several types of keys and by default you will get an RSA pair.
When prompted for a passphrase, just hit enter so that you
won't need a password when logging in.

```
ssh-keygen
```

## Using an existing public/private key pair

If you have previously created a public/private key pair, you should be
able to just use this instead of creating a new set. If you have
forgotten how the key was created, you can use `ssh-keygen` to
show the key's fingerprint. `DSA` keys should be avoided. An `RSA` key
with at least 2048 bits should provide sufficient security.
Finally, `ecdsa` and `ed25519` keys are also fine (don't worry about
the number of bits for these keys).

```
$ ssh-keygen -l -f ~/.ssh/id_rsa
2048 SHA256:7l0HauYJVRaQhuzmti8XEZImnRbzipu3NKGnE6tDFRk grg@t430s (RSA)
```

## Transferring the key to the server

Transfer the public part of your key pair to the remote server.
This can be done manually, but the easiest way is:

```
ssh-copy-id -i ~/.ssh/mykey.pub <userid>@ssh-snm-willerslev.science.ku.dk
```

This will prompt for a password to authenticate with the remote
server in order to copy the file. Once successful though,
future logins will use the key pair for authentication, and will
not prompt for a password (assuming you login from your workstation,
which has the private part of your key pair).

## Racimocomp systems

You will need to also copy your public key to (one of) the `racimocomp`
compute nodes, as these do not share a `$HOME` with the willerslev cluster.

**NOTE:** The `racimocomp<NN>fl` compute nodes are configured to only
accept keys located in the file `/etc/ssh/authorized_keys/<userid>`,
such that the filename matches the user. However this folder
can only be written to by users with `sudo` privileges. Contact an admin
to do this on your behalf after you've copied the public key across.

The admin will have to type the following:
```
sudo cp ~/.ssh/authorized_keys /etc/ssh/authorized_keys/<userid>
sudo chmod 600 /etc/ssh/authorized_keys/<userid>
sudo chown <userid>:users /etc/ssh/authorized_keys/<userid>
```
where `<userid>` is your KU user ID.

Or, if the user has copied the key with `ssh-copy-id` such that it
already has correct ownership and permissions, the following will suffice
to copy the key to all racimocomp nodes
([see section below about pssh](#running-a-command-on-multiple-hosts)).

```
pssh -h ~/.ssh/racimocomp.txt -i sudo cp -a /home/<userid>/.ssh/authorized_keys /etc/ssh/authorized_keys/<userid>
```

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

## Logging into a willerslev compute node directly

To login to a willerslev compute node, usually one needs to first ssh into the
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
	ServerAliveInterval 60
```

## Handy host aliases for racimocomp nodes

Typing `racimocomp01fl` is way too many keypresses. You should add
some aliases for these nodes, to avoid a repetitive strain injury.

```
Host r01
	Hostname racimocomp01fl

Host r02
	Hostname racimocomp02fl
...
```

## Putting it all together

Here's a complete example `~/.ssh/config` file.

```
Match all
	# Send a "keep-alive" signal every 60 seconds
	# so the connection doesn't get dropped when
	# you're not typing.
	ServerAliveInterval 60

Host r0? racimocomp0?fl gpu snm
	User abc123
	# Run graphical programs on the remote system.
	#ForwardX11 yes
	#ForwardX11Trusted yes

Host r01
	Hostname racimocomp01fl

Host r02
	Hostname racimocomp02fl

Host r03
	Hostname racimocomp03fl

Host r04
	Hostname racimocomp04fl

Host r05
	Hostname racimocomp05fl

Host r06
	Hostname racimocomp06fl

Host r07
	Hostname racimocomp07fl

Host snm
	Hostname ssh-snm-willerslev.science.ku.dk

Host gpu
	Hostname gpu01-snm-willerslev
	ProxyJump snm
```

# SSH port forwarding

Sometimes it's useful to run a server application on a compute node,
and use your workstation as a client. E.g. running a `jupyter` notebook
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

# Running a command on multiple hosts

Sometimes it can be useful to run the same command on multiple nodes
simultaneously. E.g., to install software using the systems' native
package manager, or to identify a node that is not being utilised.

There are [many ways to achieve this](https://unix.stackexchange.com/questions/19008/automatically-run-commands-over-ssh-on-many-servers),
but we'll provide an example using [`pssh`](https://github.com/lilydjwg/pssh).

First, install pssh on your workstation.
```
pip install git+https://github.com/lilydjwg/pssh
```

Then create a hosts list. E.g.
```
$ cat ~/.ssh/racimocomp.txt
racimocomp01fl
racimocomp02fl
racimocomp03fl
racimocomp04fl
racimocomp05fl
racimocomp06fl
racimocomp07fl
```

Pssh will use the settings in your `~/.ssh/config` to login to each
remote system. The following command assumes you have an appropriate
config entry that sets the correct username for the racimocomp nodes.

```
$ pssh -h ~/.ssh/racimocomp.txt -i uptime
[1] 12:17:37 [SUCCESS] racimocomp01fl
 12:17:37 up 53 days, 21:15,  2 users,  load average: 0.00, 0.00, 0.00
[2] 12:17:37 [SUCCESS] racimocomp04fl
 12:17:37 up 53 days, 20:05,  0 users,  load average: 0.00, 0.00, 0.00
[3] 12:17:37 [SUCCESS] racimocomp06fl
 12:17:37 up 53 days, 18:53,  0 users,  load average: 0.08, 0.02, 0.01
[4] 12:17:37 [SUCCESS] racimocomp07fl
 12:17:37 up 53 days, 12 min,  0 users,  load average: 0.07, 0.03, 0.00
[5] 12:17:37 [SUCCESS] racimocomp03fl
 12:17:37 up 53 days, 20:07,  0 users,  load average: 0.00, 0.01, 0.00
[6] 12:17:37 [SUCCESS] racimocomp02fl
 12:17:37 up 53 days, 21:01,  0 users,  load average: 0.00, 0.00, 0.00
[7] 12:17:37 [SUCCESS] racimocomp05fl
 12:17:37 up 53 days, 18:09,  0 users,  load average: 0.23, 0.06, 0.02
```
