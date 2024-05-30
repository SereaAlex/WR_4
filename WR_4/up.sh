#!/bin/bash

logger -t up.sh "Script started."

pgrep -l up.sh

pgrep_output=$?

if [ $pgrep_output -eq 0 ]
then
	logger -t up.sh "An instance of this script is already running."
	logger -t up.sh "Script exited."
	exit 1
fi

ping -c 15 8.8.8.8

ping_output=$?

if [ $ping_output -ne 0 ]
then
	logger -t up.sh "Network connectivity has issues. Canceling the update."
	logger -t up.sh "Script stopped."
	exit 1
else
	logger -t up.sh "Network connectivity is functional."
fi

sudo apt update

sudo apt -y upgrade

logger -t up.sh "Updated the Linux system."

find_output_linux=$(find -name "linux.git")

if [ $find_output_linux -z ]
then
	logger -t up.sh "Missing linux kernel local mirror."
	git clone "https://github.com/torvalds/linux.git" --mirror
	logger -t up.sh "Linux kernel local mirror created."
fi

find_output_glibc=$(find -name "glibc.git")

if [ $find_output_glibc -z ]
then
	logger -t up.sh "Missing glibc local mirror."
	git clone "https://github.com/bminor/glibc.git" --mirror
	logger -t up.sh "glibc local mirror created."
fi

cd linux.git

git remote update --prune

logger -t up.sh "Updated the local mirror of the linux kernel."

cd ..

cd glibc.git

git remote update --prune

logger -t up.sh "Updated the local mirror of glibc."

cd ..

logger -t up.sh "Script ended."