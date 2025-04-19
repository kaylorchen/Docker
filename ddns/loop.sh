#!/bin/bash
while true; do
  /app/cloudflare_ddns.sh
  sleep $SLEEP
done