#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Check remote DNS with dig and summary statistics

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Config
SERVER="8.8.8.8"
DOMAIN="google.com"
TIMEOUT=1
INTERVAL=0.2
LOG_FILE="dig-test-$(date +%Y%m%d-%H%M%S).log"
REQUESTS=${1:-3000}  # or pass with arg

echo "[INFO] Starting DNS test to $SERVER for $REQUESTS requests..." | tee -a "$LOG_FILE"

timeout_count=0
slow_count=0
total_rtt=0
ok_count=0

for ((i = 1; i <= REQUESTS; i++)); do
    START=$(date +%s%3N)

    OUTPUT=$(dig @"$SERVER" "$DOMAIN" +tries=1 +time=$TIMEOUT +stats +noquestion +nocomments +nocmd +noauthority +noadditional 2>/dev/null)
    STATUS=$?

    END=$(date +%s%3N)
    RTT=$((END - START))

    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    if [ $STATUS -ne 0 ]; then
        echo "[$TIMESTAMP] ❌ TIMEOUT (${RTT}ms)" | tee -a "$LOG_FILE"
        ((timeout_count++))
    elif [ $RTT -gt 1000 ]; then
        echo "[$TIMESTAMP] ⚠️  SLOW RESPONSE (${RTT}ms)" | tee -a "$LOG_FILE"
        ((slow_count++))
    else
        echo "[$TIMESTAMP] ✅ OK (${RTT}ms)"
        ((ok_count++))
        total_rtt=$((total_rtt + RTT))
    fi

    sleep $INTERVAL
done

# Final stats
echo "------------------------------------------" | tee -a "$LOG_FILE"
echo "[RESULT] Finished $REQUESTS requests:" | tee -a "$LOG_FILE"
echo "[RESULT] OK: $ok_count" | tee -a "$LOG_FILE"
echo "[RESULT] TIMEOUTS: $timeout_count" | tee -a "$LOG_FILE"
echo "[RESULT] SLOW RESPONSES: $slow_count" | tee -a "$LOG_FILE"

if [ "$ok_count" -gt 0 ]; then
    avg=$((total_rtt / ok_count))
    echo "[RESULT] Average RTT: ${avg}ms" | tee -a "$LOG_FILE"
fi

