#!/bin/bash                                                                                                                                                                                [1/282]

########### put stuff here ################
# Source and destination details
SRC_DIR=""
DEST_USER=""
DEST_HOST=""
DEST_DIR=""

# Email recipient for summary
EMAIL_RECIPIENT=""
###########################################

# Log file setup
LOG_FILE="/tmp/rsync_transfer.log"
ERROR_LOG="/tmp/rsync_transfer_errors.log"
SUMMARY_LOG="/tmp/rsync_transfer_summary.log"
START_TIME=$(date +%s)

# Clear previous logs
> "$LOG_FILE"
> "$ERROR_LOG"
> "$SUMMARY_LOG"

echo "Starting transfer at $(date)" | tee -a "$LOG_FILE"

# Rsync options:
# -a: archive mode (preserves permissions, timestamps, symbolic links, etc.)
# -v: verbose output
# -h: human-readable sizes
# -P: show progress
# --stats: print transfer statistics
# --log-file: write output to log
rsync -ahvP --stats --log-file="$LOG_FILE" "$SRC_DIR" "$DEST_USER@$DEST_HOST:$DEST_DIR" 2> "$ERROR_LOG"

# Record the total size transferred
TOTAL_SIZE=$(grep "Total transferred file size" "$LOG_FILE" | awk -F ': ' '{print $2}')
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

# Check for errors
if [[ -s "$ERROR_LOG" ]]; then
    ERROR_MSG="Errors occurred during transfer. Check the log: $ERROR_LOG"
else
    ERROR_MSG="No errors detected."
fi

# Generate summary
echo "Electron Microscopy Data Transfer Summary" > "$SUMMARY_LOG"
echo "--------------------------------------" >> "$SUMMARY_LOG"
echo "Start Time   : $(date -d @$START_TIME)" >> "$SUMMARY_LOG"
echo "End Time     : $(date -d @$END_TIME)" >> "$SUMMARY_LOG"
echo "Total Time   : ${TOTAL_TIME} seconds" >> "$SUMMARY_LOG"
echo "Total Size   : ${TOTAL_SIZE}" >> "$SUMMARY_LOG"
echo "Source Dir   : $SRC_DIR" >> "$SUMMARY_LOG"
echo "Destination  : $DEST_USER@$DEST_HOST:$DEST_DIR" >> "$SUMMARY_LOG"
echo "Error Status : $ERROR_MSG" >> "$SUMMARY_LOG"

# Send email with the summary
mail -s "Data Transfer Summary" "$EMAIL_RECIPIENT" < "$SUMMARY_LOG"

echo "Transfer completed. Summary sent to $EMAIL_RECIPIENT. Have a wonderful day."
