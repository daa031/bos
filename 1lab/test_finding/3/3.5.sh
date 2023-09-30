#!/bin/bash

text="$1"
file="$2"
lines="$3"

grep -n "$text" "$file" | sort | head -n "$lines"
