#!/bin/bash

#1. Defining default variables
u="XXXXXX"             #Set your KU USER in this variable
e="ENVENV"             #Set your conda enviroment in this variable
c=1111                 #Set your port id for the jupyter notebook here (be creative)
l=2222                 #Set your port id for the ssh tunel here (be creative)
m="jupyter_notebook_c" #This will be the name of the tmux session started on the RacimoLab server. You can change it if you want or leave it as is.
n="jupyter_notebook_l" #This will be the name of the tmux session started on your local machine. You can change it if you want or leave it as is.
s="01"                 #Default server number. You can change it to be which ever default to want to set
k=""                   #Do not modify this variable
r=""                   #Do not modify this variable
             
#2. help function
help()
{
    echo "Usage: bash $0 [-u,-e,-c,-l,-m,-n,-s,-k,-r,-h]

  Command                     Explanation                         Default                
  -------                     -----------                         -------                 
  -u, --user <string>         KU user                             ${u}
  -e, --env <string>          conda environment                   ${e}
  -c, --clusterport <int>     cluster port                        ${c}
  -l, --localport <int>       local port                          ${l}
  -m, --clustertmux <string>  cluster tmux session name           ${m}
  -n, --localtmux <string>    local tmux session name             ${n}
  -s, --serverid <01-07>      RacimoServer ID                     ${s}
  -k, --kill                  Kill the tmux sessions which will    
                              stop the ssh tunnels and jupyter      
                              notebook
  -r, --reconnect             reestablishes the local tunnel to 
                              reconnect with the cluster
  -h, --help                  prints this help message
  "
    exit 1
}

#3. parssing variables
while getopts "u:e:c:l:m:n:s:krh:" o; do
    case "${o}" in
        u)
            u=${OPTARG}
            ;;
        e)
            e=${OPTARG}
            ;;
        c)
            c=${OPTARG}
            ;;
        l)
            l=${OPTARG}
            ;;
        m)
            m=${OPTARG}
            ;;
        n)
            n=${OPTARG}
            ;;
        s)
            [[ $s == "01" || $s == "02" || $s == "03" || $s == "04" || $s == "05" || $s == "06" || $s == "07" ]] || help
            s=${OPTARG}
            ;;
        k)
            k="kill"
            ;;
        r)
            r="reconnect"
            ;;
        h)
            help
            ;;                      
        *)
            help
            ;;
    esac
done
shift $((OPTIND-1))

#4. SCRIPT
#A. If killing option enabled, kill the tmux sessions
if [[ ${k} = "kill" ]]
then
    echo "Killing tmux server running in racimocomp${s}fl"
    ssh ${u}@racimocomp${s}fl 'tmux kill-session -t '${m}''
    tmux kill-session -t ${n}
    exit 0
#B. If reconnect option enabled
elif [[ ${r} = "reconnect" ]]
then
    #B.1 Create again the tmux session in case it does not exist and restart the ssh tunnel
    if [ "`tmux ls | egrep ${n}`" = "" ]
    then
        echo "1) Retarting a ssh tunnel from Local computer (port ${l}) to RacimoLab server racimocomp${s}fl in a newly created tmux session named ${n}"
        tmux new-session -s ${n} -d
        tmux send-keys -t ${n}  "ssh ${u}@racimocomp${s}fl -L '${l}':localhost:'${c}' -N" C-m
    #B.2 Restart the ssh tunnel
    else
        echo "1) Restarting a ssh tunnel from Local computer (port ${l}) to RacimoLab server racimocomp${s}fl in an existing tmux session named ${n}"
        tmux send-keys -t ${n}  "ssh ${u}@racimocomp${s}fl -L '${l}':localhost:'${c}' -N" C-m
    fi
    exit 0
#Automate all the GitHub steps
else
    ##C.1 Step 1 - Running jupyter notebook on a computing node 
    if [ "`ssh ${u}@racimocomp${s}fl 'tmux ls | egrep '${m}''`" = "" ]
    then
        echo "1) Starting jupyter notebook at racimocomp${s}fl in a tmux session named ${m} with port ${c}"
        ssh ${u}@racimocomp${s}fl 'tmux new-session -s '${m}' -d'
        ssh ${u}@racimocomp${s}fl 'tmux send-keys -t '${m}' "conda activate '${e}'" C-m "jupyter-lab --no-browser --port='${c}'" C-m'
    else
        echo "1) racimocomp${s}fl already has a tmux session named ${m}"
    fi


    #C.2 Step 2 - Open a ssh tunnel from your local machine to the RacimoLab server 
    if [ "`tmux ls | egrep ${n}`" = "" ]
    then
        echo "2) Starting a ssh tunnel from Local computer (port ${l}) to RacimoLab server racimocomp${s}fl in a tmux session named ${n}"
        tmux new-session -s ${n} -d
        tmux send-keys -t ${n}  "ssh ${u}@racimocomp${s}fl -L '${l}':localhost:'${c}' -N" C-m
    else
        echo "2) Local computer already has a tmux session named ${n}"
    fi
fi

#D. Step 3 - Jupyter notebook in your local machine browser
echo "3) Opening Google Chrome to access jupyter notebook on your local computer"
open --new -a "Google Chrome" --args "http://localhost:${l}/"
