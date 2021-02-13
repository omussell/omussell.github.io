#! /bin/bash -
export PATH="/home/oem/omussell.github.io/venv/bin:$PATH"

cd site

## Create HTML files
zola build --output-dir ../docs

## Create Gemini files
for mdfile in `ls content/`; do md2gemini -f -w content/$mdfile -d ../gemini; done
