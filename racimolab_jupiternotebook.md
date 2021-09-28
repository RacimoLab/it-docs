# Jupyter Notebook on RacimoLab servers

###### Moisès Coll Macià - 28/09/21

## Contents

1. [Step by step pipeline](#stepbystep)
    - 1.1. Running jupyter notebook on the cluster
    - 1.2. Open the ssh tunnel in your local machine
    - 1.3. Jupyter notebook in your local machine browser
2. [Caveats and considerations](#caveats)
    - 2.1. Port uniqueness
    - 2.2. Close shh tunnels
    - 2.3. ssh termination
3. [Automating script](#script)
    - 3.1. Script potential issues and important details
4. [Acknowledgements](#ackn)

In this tutorial I'm going to explain the solution I found to run jupyter notebook in the RacimoLab servers remotely from a personal computer. I'm mainly based on [this](https://medium.com/@sankarshan7/how-to-run-jupyter-notebook-in-server-which-is-at-multi-hop-distance-a02bc8e78314) blog post which explains a similar problem. The different steps are summarized in **Figure 1** and explained below. The idea is to create an *ssh tunnel* from a computing node, where your jupyther notebook will be running (Step 1), to the your working station (Step 2), to finally open jupyter notebook in your computer browser (Step 3). I assume you've already installed jupyter notebook and all it's dependences and you know how to login to the Willerslev servers. 

Finally, I provide a bash script which automates the whole process. You might ask... Why not provinding just the script? Well, I decided to post the whole explanation in case someone is interested on what the script does or in case someone else tries to use my script, gets errors and tries to find out what I hard coded on the script. 

Notation summary:

- Computer (C):
    - C -> Computing node in one of the RacimoLab servers. In Figure 1 denoted as `SSSSSS`
    - L -> Your local machine.
- Ports (P):
    - Cp -> C's port. Here denoted as `9999`.
    - Lp -> L's port. Here denoted as `7777`.
    
It's important to notice that ports (P) must be 1024 >= P <= 65535. More info about ports can be found [here](https://www.ssh.com/ssh/port) and [here](https://linuxhint.com/change_default_ssh_port/).

![](Figure1.png)

**Figure 1.** Schematic representation to run Jupyter Notebook in RacimoLab servers. Highlighted are:
- Yellow : KU username
- Blue: two digit number out of the 6 possible servers (01, 02, ..., 06)
- Red : C
- Green : Cp
- Purple : Lp

<a name="stepbystep"></a>
## 1. Step by step pipeline

### 1.1. Running jupyter notebook on C

- Log into the RacimoLab servers in which you want to run your Jupyter Notebook on (on Figure 1.1, you should replace the Xs highlighted in yellow for your user and the Ys highlighted in blue for the server you want to connect to).
- Activate your desired environment where you have installed jupyter notebook
- Run jupyter notebook in `--no-browser` mode. You must also specify Cp, which must be unique to your connection (so be creative :) ), otherwise it gives problems. 


```bash
ssh XXXXXX@racimocompYYfl
conda activate env
jupyter lab --no-browser --port=9999
```

### 1.2. Open the ssh tunnel on your local machine

- On a new terminal, create a shh tunnel with the command shown in Figure 1.3. Xs highlighted in yellow represent your user to connect to Willerslev servers. Again, you must decide a new port Lp (on Figure 1.3, represented as 7s highlighted in green) and indicate Cp (on Figure 1.3, represented as 9s highlighted in purple)

```bash
ssh XXXXXX@racimocompYYfl -L 7777:localhost:9999 -N
```

### 1.3. Jupyter notebook in your local machine browser

- Open your favourite browser and type `localhost:7777`
- TADAAAA!

<a name="caveats"></a>
## 2. Caveats and considerations

### 2.1. Port uniqueness

While Cp and Lp can be the same number (1024 >= P <= 65535), if there are multiple users using the same ports in the same "computer" it's going to create some conflicts and errors. 

### 2.2. Close shh tunnels

Sometimes, when I close the shh tunnels (Cntl+C), the process keeps running on the background, meaning that the port is still in use. Then, if I try to open again the tunnels, I get the error that... Surprise! the port is on use. To solve that, I kill the process that it's running that particular port with the following command

```bash
for job in `ps aux | egrep 9999 | egrep "ssh" | egrep XXXXXX | awk '{print $2}'`; do kill -9 ${job}; done
```

This selects from all processes running, the ones that have the "9999" (port-id), "ssh" and "XXXXXX" (username) and kill them. 

### 2.3. ssh termination

Sometimes, when the ssh doesn't receive orders, it automatically closes down. This kills the ssh tunnel. To prevent that, I first run `tmux` or `screen` so that even when my session is killed, the process goes on and it does not stop my jupyter notebook while working. 

Let me know if you find more problems while using these to run jupyter notebook that are not reported here and if you have improvements and suggestions!

<a name="script"></a>
## 3. Automating script

I wrote the [raju.sh](raju.sh) (yes... not feeling creative to give it a better name :) ) bash script which automates all steps expained in **1. Step by step pipeline**. At the begining of the script, you will find variables which will need to be manually configured (e.g. `ra_us` variable is your KU username, the environment name `envname` or the port numbers `cp`, `lp`). After that, the only manual work left is to figure out which computing node you want to run jupyter notebook on (e.g., 02). Once you've decided for one you can run the following command:

```bash
bash raju.sh 02
```

Because the tunnels and the jupyter notebook are running in different tmux sessions, I also incorporated a way to kill those tmux sessions to finish all processes. You can do that by running the following:

```bash
bash raju.sh 02 kill
```

It's important that you also indicate the computing node.

### 3.1. Script potential issues and important details

1. I use `tmux` in order to open a terminal from which I can log out both in the RacimoLab servers and in my local computer. Make sure you have installed `tmux` in both. I installed `tmux` in my local computer using `brew` as shown in [here](https://linuxize.com/post/getting-started-with-tmux/).

2. The pipeline checks if there is already a tmux session running with the defined name. If there is not, `tmux` returns a warning like `failed to connect to server` or `no server running on /private/tmp/tmux-1349466776/default`. This will be printed in your terminal but is not a sign of things going wrong, it's just me not knowing how to avoid it to be printed on the terminal :) .

3. Try to be creative and change the ports. As I say before, it is important that your port is unique!

4. Make sure you can access the RacimoLab servers without typing your password manually. If you want to generate your ssh key, check this [link](https://github.com/RacimoLab/it-docs/blob/main/ssh.md). In my case, the pipeline was getting stuck because to access a server for the first time my script was required to type a password, which was not prepared for.

5. The last command opens Google chrome to access to jupyter notebook. If you don't have the browser installed, it might lead to a problem.

6. I'm a Mac user, which might imply that my solutions and script works fine for other mac users, but not Windows or Linux OS.

Please, let me know if you encounter problems when you run my pipeline on your computer and also if you find solutions for your problems; I will post them on this github page so that other users can also benefit from your effort!

<a name="ackn"></a>
## 4. Acknowledgements

I would like to thank Graham Gower for his techical comments on ports and the proper way to kill a process (Cntrl-C) instead of suspending it (Cntrl-Z) when stopping shh tunnels. He's also giving me input for how atutomatize this whole process which I hope to achieve soon and update this instructions with it. 

I thank Antonio Fernandez Guerra for his tricks on how to connect directly to one computing node by customizing `.ssh/config` file. 
