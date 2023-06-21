#!/bin/bash

poetry export -f requirements.txt --output requirements.txt

rm -fR artifacts greeting.zip
pip install -r requirements.txt -t artifacts

cd artifacts
zip -r ../../../greeting.zip .

cd - || exit

cd src
zip ../../../greeting.zip greeting.py