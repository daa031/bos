#!/bin/bash

if [ $# -ne 1 ]; then
  echo "bad"
  exit 1
fi

email="$1"

reg="^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+\.[A-Za-z]{1,}$"

if [[ $email =~ $reg ]]; then
  echo "ok"
  exit 0
else
  echo "bad"
  exit 1
fi
