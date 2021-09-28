#!/bin/sh

# command to run this script:
# $ bash raju.sh [servernumber] [kill]
# - servernumber: it is a two digit number from 1 to 7 (01, 02, ..., 07). If you don't set this number, it will be set automatically as the variable "def_c" 
# - kill: it will kill all tmux sessions started by this script 


#A. Defining variables
ku_user="XXXXXX"        #Set your KU USER in this variable
envname="ENVENV"        #Set your conda enviroment in this variable
cp=9999                 #Set your port id for the jupyter notebook here (be creative)
lp=7777                 #Set your port id for the ssh tunel here (be creative)
m1="jupyter_notebook_c" #This will be the name of the tmux session started on the RacimoLab server. You can change it if you want or leave it as is.
m2="jupyter_notebook_l" #This will be the name of the tmux session started on your local machine. You can change it if you want or leave it as is.
c_def="04"              #Default server number. You can change it to be which ever default to want to set


c=$1
k=$2

#A.1 
if [ "${c}" != "01" ] && [ "${c}" != "02" ] && [ "${c}" != "03" ] && [ "${c}" != "04" ] && [ "${c}" != "05" ] && [ "${c}" != "06" ] && [ "${c}" != "07" ]
then
	c="${c_def}"
fi
if [ "$1" == "kill" ]
then
	c="${c_def}" 
	k="kill"
fi

if [ "${k}" != "kill" ]
then
	#B. Step by  step
	#B.1 Step 1 - Running jupyter notebook on a computing node 
	if [ "`ssh ${ku_user}@racimocomp${c}fl 'tmux ls | egrep '${m1}''`" = "" ]
	then
		echo "1) Starting jupyter notebook at racimocomp${c}fl in a tmux session named ${m1} with port ${cp}"
		ssh ${ku_user}@racimocomp${c}fl 'tmux new-session -s '${m1}' -d'
		ssh ${ku_user}@racimocomp${c}fl 'tmux send-keys -t '${m1}' "conda activate '${envname}'" C-m "jupyter-lab --no-browser --port='${cp}'" C-m'
	else
		echo "1) racimocomp${c}fl already has a tmux session named ${m1}"
	fi

	#B.2 Step 2 - Open a ssh tunnel from your local machine to the RacimoLab server 
	if [ "`tmux ls | egrep ${m2}`" = "" ]
	then
		echo "2) Starting a ssh tunnel from Local computer (port ${lp}) to RacimoLab server racimocomp${c}fl in a tmux session named ${m2}"
		tmux new-session -s ${m2} -d
		tmux send-keys -t ${m2}  "ssh ${ku_user}@racimocomp${c}fl -L '${lp}':localhost:'${cp}' -N" C-m

		                                                                                                                                            
	else
		echo "2) Local computer already has a tmux session named ${m2}"
	fi

	#B.3 Step 3 - Jupyter notebook in your local machine browser
	echo "3) Opening Google Chrome to access jupyter notebook on your local computer"
	open --new -a "Google Chrome" --args "http://localhost:${lp}/"
else
	#C. If killing option, kill the tmux sessions
	echo "Killing tmux server running in racimocomp${c}fl"
	ssh ${ku_user}@racimocomp${c}fl 'tmux kill-session -t '${m1}'' 
	echo "Killing tmux server from local computer"
	tmux kill-session -t ${m2}
fi