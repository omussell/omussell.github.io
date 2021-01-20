#! /bin/bash -

cd site
zola build --output-dir ../docs

for mdfile in `ls content/`; do cp content/$mdfile ../gemini/$mdfile.gmi; done
