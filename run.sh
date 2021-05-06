#!/bin/bash

export PYTHONPATH=$PWD
cd relay
while true
do
echo "Starting..."
pipenv run python ./header_forwarder/h.py .config.env  || true
echo "Sleeping..."
sleep 60
done
