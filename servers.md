Users gain access to a given cluster after starting a project in the Racimo group.
Contact Fernando to obtain access.

# racimo cluster

The "racimo" cluster is located in the "unicph" domain.
To access these compute nodes,
[connect to the university's Cisco AnyConnect VPN](vpn.md).

Once you are connected to the vpn, you can [`ssh`](ssh.md) directly to
a racimo cluster compute node.
Available nodes are `racimocomp<NN>fl`, where `<NN>` is in the range 01--07,
and `racimogpu01fl`.

## racimogpu01fl

This node has 5x Tesla T4 GPUs, and in general should be used only
for jobs that (also) need GPU resources.
See [gpu01.md](gpu01.md)
for additional details about using the GPUs on this system.

## cluster nodes

hostname | CPU | cores | RAM | GPU | notes
--- | --- | --- | --- | --- | ---
`racimocomp01fl` | Xeon 6248R @ 3 Ghz | 96 | 768 Gb | |
`racimocomp02fl` | Xeon 6248R @ 3 Ghz | 96 | 768 Gb | |
`racimocomp03fl` | Xeon 6248R @ 3 Ghz | 96 | 768 Gb | |
`racimocomp04fl` | Xeon 6248R @ 3 Ghz | 96 | 768 Gb | |
`racimocomp05fl` | Xeon 6248R @ 3 Ghz | 96 | 768 Gb | |
`racimocomp06fl` | Xeon 6248R @ 3 Ghz | 96 | 768 Gb | |
`racimocomp07fl` | Xeon 6248R @ 3 Ghz | 96 | 768 Gb | |
`racimogpu01fl` | Xeon 6248 @ 2.5 Ghz | 80 | 768 Gb | 5x Tesla T4 | See [gpu01.md](gpu01.md). No `/scratch` folder.

## filesystems

Users have 10 Gb of storage under `$HOME`, which is enough for only small items.
Temporary folders are not shared between cluster nodes and are not backed up.
In general, other folders are both shared between cluster nodes and backed up.

path | available space | type | shared between nodes | description
--- | --- | --- | --- | ---
`$HOME` | 10 Gb | network | yes | Personal directory.
`/tmp` | 30 Gb | local | no | Temporary storage. 
`/scratch` | 1 Tb | local | no | Temporary storage.
`/projects/racimolab/scratch` | 50 Tb | network | no | Temporary storage.
`/projects/racimolab/people/<kuid>` | 100 Tb | network | yes | Create your own folder and use it for your projects.
`/projects/racimolab/data` | 50 Tb | network | yes | Use for your data.

# dandy cluster

**Racimo group members should use the racimo cluster, not the dandy cluster.**

The "dandy" cluster is located in the "unicph" domain
and nodes are accessed via the VPN just as for the "racimo" cluster.

Available nodes are `dandycomp01fl` and `dandycomp02fl`.


# willerslev cluster

The willerslev cluster is shared with the GeoGenetics group, and should
only be used for collaborative projects with that group. This
cluster is accessed differently from the racimo cluster, and does
not share filesystems in general (e.g. `$HOME` folders are shared
within nodes of a cluster, but not shared *between* the two clusters).
Using the racimo cluster should be preferred.

The "willerslev" cluster is located in the "science" domain, and
it should not be necessary to connect to the VPN before logging in to this cluster.
To access these compute nodes, first [`ssh`](ssh.md) to the head node
`ssh-snm-willerslev.science.ku.dk` with your kuid and then [`ssh`](ssh.md) to
the desired compute node (listed below).
The latter step should not prompt for a password, and a password prompt
at this step may indicate a transient problem or lack of access.

* `candy-snm`
* `wonton-snm`
* `dimsum-snm`
* `taco-snm`
* `biceps-snm`
* `triceps-snm`
* `compute<NN>-snm-willerslev`, where `<NN>` is in the range 07--12.

# Installing software

## conda / mamba

**Note**: conda sucks. Use [`mamba`](https://mamba.readthedocs.io/en/latest/) instead. It sucks slightly less.

Software required to run a bioinformatics or analysis pipeline should
be installed in a [`conda` environment](conda.md).
It is likely that `$HOME` has insufficient space, so you should install conda somewhere else (e.g. `/projects/racimolab/people/<kuid>/conda`).

## RHEL packages (rpm/yum)

**NOTE:** sudo privileges required. Ignore this section if you don't have sudo rights.

Suppose we wish to install `emacs`. Using the `yum` package manager,
search for the package to be installed using `yum list` or `yum search`.
```
[srx907@racimocomp01fl ~]$ sudo yum list emacs\*
Updating Subscription Management repositories.
Red Hat Enterprise Linux 8 for x86_64 - Supplementary (RPMs)                                                     26 kB/s | 2.1 kB     00:00
EPEL 8                                                                                                           33 kB/s | 2.4 kB     00:00
Red Hat Enterprise Linux 8 for x86_64 - BaseOS (RPMs)                                                            31 kB/s | 2.4 kB     00:00
Red Hat Enterprise Linux 8 for x86_64 - AppStream (RPMs)                                                         40 kB/s | 2.8 kB     00:00
Red Hat CodeReady Linux Builder for RHEL 8 x86_64 (RPMs)                                                         37 kB/s | 2.8 kB     00:00
Red Hat Satellite Tools 6.9 for RHEL 8 x86_64 (RPMs)                                                             29 kB/s | 2.1 kB     00:00
Zabbix 5.2 RHEL 8                                                                                                27 kB/s | 2.1 kB     00:00
Installed Packages
emacs.x86_64                                                 1:26.1-5.el8                                      @rhel-8-for-x86_64-appstream-rpms
emacs-common.x86_64                                          1:26.1-5.el8                                      @rhel-8-for-x86_64-appstream-rpms
emacs-filesystem.noarch                                      1:26.1-5.el8                                      @anaconda
Available Packages
emacs-lucid.x86_64                                           1:26.1-5.el8                                      rhel-8-for-x86_64-appstream-rpms
emacs-nox.x86_64                                             1:26.1-5.el8                                      rhel-8-for-x86_64-appstream-rpms
emacs-terminal.noarch                                        1:26.1-5.el8                                      rhel-8-for-x86_64-appstream-rpms
emacs-yaml-mode.noarch                                       0.0.14-1.el8                                      Default_Organization_EPEL_EPEL_8
```

```
[srx907@racimocomp01fl ~]$ sudo yum search emacs
Updating Subscription Management repositories.
Last metadata expiration check: 0:00:08 ago on Wed 01 Sep 2021 02:16:12 PM CEST.
======================================================== Name & Summary Matched: emacs =========================================================
emacs.x86_64 : GNU Emacs text editor
emacs-common.x86_64 : Emacs common files
emacs-filesystem.noarch : Emacs filesystem layout
emacs-lucid.x86_64 : GNU Emacs text editor with LUCID toolkit X support
emacs-nox.x86_64 : GNU Emacs text editor without X support
emacs-terminal.noarch : A desktop menu item for GNU Emacs terminal.
emacs-yaml-mode.noarch : Major mode to edit YAML files for emacs
pinentry-emacs.x86_64 : Passphrase/PIN entry dialog based on emacs
xemacs.x86_64 : Different version of Emacs
xemacs-common.x86_64 : Lisp files and other common files for XEmacs
xemacs-devel.x86_64 : Development files for XEmacs
xemacs-filesystem.noarch : XEmacs filesystem layout
xemacs-info.noarch : XEmacs documentation in GNU texinfo format
xemacs-nox.x86_64 : Different version of Emacs built without X Windows support
xemacs-packages-base.noarch : Base lisp packages for XEmacs
xemacs-packages-base-el.noarch : Emacs lisp source files for the base lisp packages for XEmacs
xemacs-packages-extra.noarch : Collection of XEmacs lisp packages
xemacs-packages-extra-el.noarch : Emacs lisp source files for XEmacs packages collection
xemacs-packages-extra-info.noarch : XEmacs packages documentation in GNU texinfo format
xemacs-xft.x86_64 : Different version of Emacs built with Xft/fontconfig support
============================================================ Summary Matched: emacs ============================================================
ctags-etags.x86_64 : Exuberant Ctags for emacs tag format
e3.x86_64 : Text editor with key bindings similar to WordStar, Emacs, pico, nedit, or vi
mg.x86_64 : Tiny Emacs-like editor
vile.x86_64 : VI Like Emacs
xvile.x86_64 : VI Like Emacs
```

We can see from the above that the package name `emacs` is appropriate
in this case. The package can then be installed with `sudo yum install emacs`.
However, this would mean the package is only available on that specific
compute node. For everyone's sanity, it is best to keep the installed
packages synchronised across all the racimocomp nodes.
So, [simultaneous installation on all nodes](ssh.md#running-a-command-on-multiple-hosts)
should be preferred. E.g.

```
pssh -h ~/.ssh/racimocomp.txt -i sudo yum install -y emacs
```

### Synchronising packages between redhat systems

Create a list of packages from a source node where the packages are
already installed.
```
[srx907@racimocomp01fl ~]$ sudo yum list --installed > yum-list
[srx907@racimocomp01fl ~]$ head yum-list
Updating Subscription Management repositories.
Installed Packages
ImageMagick.x86_64                                  6.9.10.86-1.el8                                   @Default_Organization_EPEL_EPEL_8
ImageMagick-c++.x86_64                              6.9.10.86-1.el8                                   @Default_Organization_EPEL_EPEL_8
ImageMagick-c++-devel.x86_64                        6.9.10.86-1.el8                                   @Default_Organization_EPEL_EPEL_8
ImageMagick-devel.x86_64                            6.9.10.86-1.el8                                   @Default_Organization_EPEL_EPEL_8
ImageMagick-libs.x86_64                             6.9.10.86-1.el8                                   @Default_Organization_EPEL_EPEL_8
LibRaw.x86_64                                       0.19.5-3.el8                                      @rhel-8-for-x86_64-appstream-rpms
ModemManager-glib.x86_64                            1.10.8-4.el8                                      @rhel-8-for-x86_64-baseos-rpms
NetworkManager.x86_64                               1:1.32.10-4.el8                                   @rhel-8-for-x86_64-baseos-rpms
```

Double check the awk command to get the list of packages to install.
```
[srx907@racimogpu01fl ~]$ awk 'NR>2 {print $1}' yum-list | head
ImageMagick.x86_64
ImageMagick-c++.x86_64
ImageMagick-c++-devel.x86_64
ImageMagick-devel.x86_64
ImageMagick-libs.x86_64
LibRaw.x86_64
ModemManager-glib.x86_64
NetworkManager.x86_64
NetworkManager-config-server.noarch
NetworkManager-libnm.x86_64
```

Install those packages on the destination node where the packages need
to be installed. It's possible that some packages won't be available on
the destination node, e.g. due to differences in available repositories
between the GPU and CPU nodes. These packages can be skipped by passing
the `--skip-broken` flag to `yum install`.

```
[srx907@racimogpu01fl ~]$ awk 'NR>2 {print $1}' yum-list | xargs sudo yum install --skip-broken -y
...
```
