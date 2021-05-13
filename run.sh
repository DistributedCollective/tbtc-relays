#!/bin/bash

export PYTHONPATH=$PWD
cd relay
pipenv run python ./header_forwarder/h.py .config.env
