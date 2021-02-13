#!/bin/bash

source .venv/bin/activate

pylint -E trickler/*.py
