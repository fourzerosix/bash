#!/bin/bash
# Author: Dolphin Whisperer
# Created: 2025-09-03
# Description: This script debugs the current user's conda configuration
#
# "May you live in interesting times."
#
echo "=== Conda Info ===" && conda info && \
echo -e "\n=== Conda Config (list) ===" && conda config list && \
echo -e "\n=== Conda Config (sources) ===" && conda config --show-sources && \
echo -e "\n=== Environment Vars ===" && env | grep -E 'CONDA|MAMBA' && \
echo -e "\n=== CPU Info ===" && lscpu | egrep 'Model name|Architecture|Flags'
