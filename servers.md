# willerslev cluster

The "willerslev" cluster is located in the "science" domain.
To access these compute nodes, first ssh to the head node
`ssh-snm-willerslev.science.ku.dk` with your kuid and then ssh to
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
* `gpu01-snm-willerslev`

## gpu01-snm-willerslev

This node has 5x Tesla T4 GPUs, and has different access restrictions
to the other compute nodes in the willerslev cluster.
Contact Fernando or Graham to get access.

# racimo cluster

The "racimo" cluster is located in the "unicph" domain.
To access these compute nodes, first vpn to the university's
Cisco AnyConnect server `vpn.ku.dk`, authenticated using your kuid
(and multi-factor authentication).
On Windows or Mac, use the Cisco AnyConnect client, which is (apparently)
downloadable after logging into https://vnp.ku.dk with a web browser.
On Linux, you can use `openconnect` to create a vpn connection
(`openconnect -u <kuid> vpn.ku.dk`).

Available nodes are `racimocomp<NN>fl`, where `<NN>` is in the range 01--07.

# Installing software

## conda

Software required to run a bioinformatics or analysis pipeline should
be installed under your $HOME in a conda environment.

## RHEL packages (rpm/yum)

While the racimocomp systems are still new, it is likely that there are
missing software packages that ought to be installed from the RedHat
repositories; e.g. editors, compilers, and some `*-devel` packages.
This should not be neccessary for the willerslev systems.

**NOTE:** sudo privileges required.

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
in this case. The pcakge can then be installed with `sudo yum install emacs`.
However, this would mean the package is only available on that specific
compute node. For everyone's sanity, it is best to keep the installed
packages synchronised across all the racimocomp nodes.
So, [simultaneous installation on all nodes](https://github.com/RacimoLab/it-docs/blob/main/ssh.md#running-a-command-on-multiple-hosts)
should be preferred. E.g.

```
pssh -h ~/.ssh/racimocomp.txt -i sudo yum install -y emacs
```
