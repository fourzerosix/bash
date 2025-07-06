#!/bin/bash
# Authors: Dolphin Whisperer
# Created: 2025-01-17
# Description: This script provides users with all the gory details, but presented in a timeless, minimalist fashion to be enjoyed by generations to come
#
# "May you live in interesting times."
#
# we like guys with fast vars
WIKI="yourwiki.stuff"
GROUP=`id -nG $LOGNAME | sed 's/ /\n/g'`
#
# storage (uncomment for disk usage. leave commented for improved loading speed).
#DISK=`du -sch ~/* | grep total | sed 's/\s/ of /g'| awk '{ print $1 }'`
DISK=`grep $LOGNAME ~/.storage-usage-$LOGNAME | awk '{ print $2 }'`
FILES=`grep $LOGNAME ~/.storage-usage-$LOGNAME | awk '{ print $3 }'`
#
# slurm
JOBS=`squeue --me | sed 1d | wc -l`
SLURM=`squeue --me --format="%8i %14j %22S %10M %6D %6C %12m %10T %R"`
#
# tmux
TMUX=`tmux list-sessions | wc -l`
if [[ ${TMUX} -lt 1 ]]; then
    TMUX="0"
fi
TMUX_SESSIONS=`tmux ls -F "#{session_name}"`
EMAIL=fancyemail@coolstuff.com
#
# do the thingy - - > thank you, shayne (aka johnsonshat, the legend)
#
clear
#
echo "Running Jobs: ${JOBS} | tmux sessions: ${TMUX} | Disk Usage: ${DISK} | Files: ${FILES} | Groups: `id -nG $LOGNAME` "
if [[ $TMUX -ge 1 ]]; then
    echo ""
    echo "You have ${TMUX} tmux session(s) open:"
    echo "${TMUX_SESSIONS}"
    echo ""
    echo "To attach to a running session, run this command:"
    echo "$"" ""tmux attach-session -t your_session_name"
fi
echo ""
echo "User documentation: ${WIKI}"
echo ""
echo "Need help? Send us an e-mail at ${EMAIL}"
echo ""
