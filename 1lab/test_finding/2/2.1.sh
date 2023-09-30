#!/bin/bash

log_file="run.log"
prev_runs=$(wc -l < "$log_file")
date >> "$log_file"
echo "Hello, world"
echo "Количество предыдущих запусков: $prev_runs" >&2
