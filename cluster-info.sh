#!/bin/bash
# Author: Dolphin Whisperer
# Created: 2025-01-17
# Description: This script provides users with all the gory details
#
# "May you live in interesting times."
#
# create dem vars boi
WIKI="myillyvanillysite.com"
GROUP=`id -nG $LOGNAME | sed 's/ /\n/g'`
DISK=`du -sch ~/* | grep total | sed 's/\s/ of /g'`
JOBS=`squeue --me | sed 1d | wc -l`
SLURM=`squeue --me --format="%8i %14j %22S %10M %6D %6C %12m %10T %R"`
TMUX=`tmux list-sessions | wc -l`
TMUX_SESSIONS=`tmux ls -F "#{session_name}"`
EMAIL=superwildemail@yikes.mil
# 
# ready, set, go
#
# MIB
#clear
#
echo ""
echo "> Welcome, ${LOGNAME}!"
echo ""
echo "> To launch an interactive session on the cluster, run this command:"
echo ""
echo "$"" ""srun --pty bash"
echo ""
echo "> You're currently using ${DISK} disk space, and you belong to these groups:"
echo ""
echo "${GROUP}"
echo ""
echo "> You have ${JOBS} running Slurm job(s):"
echo ""
echo "${SLURM}"
echo ""
echo "> You have ${TMUX} tmux session(s) open:"
echo ""
echo "${TMUX_SESSIONS}"
echo ""
echo "> To attach to a running session, run this command:"
echo ""
echo "$"" ""tmux attach-session -t your_session_name"
echo ""
echo "> Here's our user-wiki: ${WIKI}"
echo ""
echo "> To input a ticket, run this command, replace <your_subject> and <your_email_body> with your own values:"
echo ""
echo "$"" ""mail -s "your_subject" ${EMAIL} <<< "your_email_body""
echo ""
