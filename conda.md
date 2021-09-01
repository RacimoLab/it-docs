# TODO

Please help!

# Evan's notes from slack
```
# install `miniconda`
# https://docs.conda.io/en/latest/miniconda.html

# turn off auto-activation of the base environment (recommended)
conda config --set auto_activate_base false

# list all the current channels
conda config --show channels

# add new channels to the front of the priority list (you only need to do this once)
conda config --prepend channels bioconda
conda config --prepend channels conda-forge

# list the available environments
conda env list

# create an empty new environment
conda create --name testenv

# activate the environment
conda activate testenv

# find latest version of a package
conda search snakemake
conda search r-base

# install a specific version of a package
conda install r-base=3.6.3

# export the environment file
conda env export --from-history --no-builds > environment.yaml

# deactivate an environemnt
conda deactivate

# delete environment
conda env remove --name testenv

# now lets recreate the whole environment from a file
conda env create --name testenv --file environment.yaml

# search for packages here before trying to install them
# https://anaconda.org/

# install some packages with conda
conda install r-tidyverse
conda install r-bedr
conda install bedtools
conda install bedops

# now we can remake the environment file
conda env export --from-history > environment.yaml

# once you have your environment.yaml file committed to your github repository, all you
# need to do on the server is pull the latest changes from git, then run:
conda env create --name testenv --file environment.yaml
conda activate testenv
```
