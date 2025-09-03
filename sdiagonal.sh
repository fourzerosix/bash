#!/bin/bash
# Author: Dolphin Whisperer
# Created: 2025-09-03
# Description: This script runs that sdiag like it owes it money.
#
# "May you live in interesting times."
#
#
# slurm_diag_report.sh - Collect and email SLURM diagnostic metrics
#

# ================================
# Config
# ================================
LOG_DIR="/data/scratch/belljs/slurm/sdiag-logs"
LOG_FILE="$LOG_DIR/sdiag_metrics_$(date +%Y%m%d).log"
EMAIL="jeremy.bell@nih.gov"
HOSTNAME=$(hostname -s)
TMP_REPORT=$(mktemp /tmp/sdiag_report.XXXXXX)

mkdir -p "$LOG_DIR"

# ================================
# Capture current stats
# ================================
SUBMITTED=$(sdiag | awk -F: '/Jobs submitted/ {print $2}' | xargs)
STARTED=$(sdiag | awk -F: '/Jobs started/ {print $2}' | xargs)
COMPLETED=$(sdiag | awk -F: '/Jobs completed/ {print $2}' | xargs)
CANCELED=$(sdiag | awk -F: '/Jobs canceled/ {print $2}' | xargs)
FAILED=$(sdiag | awk -F: '/Jobs failed/ {print $2}' | xargs)
AVG_WAIT=$(sdiag | awk -F: '/Average wait time/ {print $2}' | xargs)
AVG_QUEUED=$(sdiag | awk -F: '/Average queue time/ {print $2}' | xargs)

# ================================
# Load previous totals if available
# ================================
LAST_LOG=$(ls -1t "$LOG_DIR"/sdiag_metrics_*.log 2>/dev/null | grep -v "$(basename "$LOG_FILE")" | head -n1)

if [[ -n "$LAST_LOG" ]]; then
    PREV_SUBMITTED=$(awk '/Jobs submitted/ {print $3}' "$LAST_LOG" | tail -n1)
    PREV_STARTED=$(awk '/Jobs started/ {print $3}' "$LAST_LOG" | tail -n1)
    PREV_COMPLETED=$(awk '/Jobs completed/ {print $3}' "$LAST_LOG" | tail -n1)
    PREV_CANCELED=$(awk '/Jobs canceled/ {print $3}' "$LAST_LOG" | tail -n1)
    PREV_FAILED=$(awk '/Jobs failed/ {print $3}' "$LAST_LOG" | tail -n1)
else
    PREV_SUBMITTED=0
    PREV_STARTED=0
    PREV_COMPLETED=0
    PREV_CANCELED=0
    PREV_FAILED=0
fi

# ================================
# Compute deltas
# ================================
DELTA_SUBMITTED=$((SUBMITTED - PREV_SUBMITTED))
DELTA_STARTED=$((STARTED - PREV_STARTED))
DELTA_COMPLETED=$((COMPLETED - PREV_COMPLETED))
DELTA_CANCELED=$((CANCELED - PREV_CANCELED))
DELTA_FAILED=$((FAILED - PREV_FAILED))

# Percentages (for deltas, not totals)
if [[ "$DELTA_SUBMITTED" -gt 0 ]]; then
    PCT_COMPLETED=$(awk -v c="$DELTA_COMPLETED" -v s="$DELTA_SUBMITTED" 'BEGIN {printf "%.2f", (c/s)*100}')
    PCT_FAILED=$(awk -v f="$DELTA_FAILED" -v s="$DELTA_SUBMITTED" 'BEGIN {printf "%.2f", (f/s)*100}')
    PCT_CANCELED=$(awk -v x="$DELTA_CANCELED" -v s="$DELTA_SUBMITTED" 'BEGIN {printf "%.2f", (x/s)*100}')
else
    PCT_COMPLETED=0
    PCT_FAILED=0
    PCT_CANCELED=0
fi

# ================================
# Build report
# ================================
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
{
    echo "======================================"
    echo " SLURM Diagnostics Report"
    echo " Host: $HOSTNAME"
    echo " Time: $TIMESTAMP"
    echo "======================================"
    echo
    echo "[Cumulative Totals (since slurmctld start or last reset)]"
    echo "Jobs submitted : $SUBMITTED"
    echo "Jobs started   : $STARTED"
    echo "Jobs completed : $COMPLETED"
    echo "Jobs canceled  : $CANCELED"
    echo "Jobs failed    : $FAILED"
    echo "Average wait   : $AVG_WAIT"
    echo "Average queued : $AVG_QUEUED"
    echo
    echo "[This Interval (since last run)]"
    echo "Jobs submitted : $DELTA_SUBMITTED"
    echo "Jobs started   : $DELTA_STARTED"
    echo "Jobs completed : $DELTA_COMPLETED"
    echo "Jobs canceled  : $DELTA_CANCELED"
    echo "Jobs failed    : $DELTA_FAILED"
    echo
    echo "[Percentages of Submitted Jobs (this interval)]"
    echo "Completed : $PCT_COMPLETED%"
    echo "Failed    : $PCT_FAILED%"
    echo "Canceled  : $PCT_CANCELED%"
    echo
    echo "[Raw sdiag output]"
    sdiag --all
    echo
} | tee -a "$LOG_FILE" > "$TMP_REPORT"

# ================================
# Email the report
# ================================
mail -s "[SLURM] Diagnostics Report - $HOSTNAME - $TIMESTAMP" "$EMAIL" < "$TMP_REPORT"

# Cleanup tmp file (keep logs)
rm -f "$TMP_REPORT"
