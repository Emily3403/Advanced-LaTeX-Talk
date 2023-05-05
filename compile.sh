#!/usr/bin/env bash

# This script compiles the file "main.tex" living in the same directory as the script.
# Any additional arguments passed to this script are passed verbatim to `latexmk`

# TODO: Make eprint function

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if [ ! "$(command -v latexmk)" ]; then
    printf "\n[1;91mError! Failed to detect a LaTeX compiler. Please make sure you have \`latexmk\` installed before executing this script[0m\n"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/main.tex" ]; then
    printf "\n[1;91mError! I could not find the main file to compile.\nLooking for %s/main.tex" "$SCRIPT_DIR"
    exit 1
fi

# We might need a separate output dir in `out` due to tikz-externalize.
mkdir -p target/target/

# First only compile the preamble producing a raw memory image of the compiler state.
# This can be used in consecutive runs to have a head-start instead of re-compiling the preamble every time.
if [ ! -f "$SCRIPT_DIR/target/template.fmt" ]; then
    pdflatex -shell-escape -ini -jobname="$SCRIPT_DIR/target/template" "&pdflatex" mylatexformat.ltx "$SCRIPT_DIR/main.tex"
fi

# Invoke latexmk to compile the document. It does the heavy lifting in terms of checking if the document has to be compiled twice etc.
# The `printf "x\n"` stops pdflatex after an interrupt signal has been received.
if printf "x\n" | latexmk -shell-escape -pdf -f -interaction=nonstopmode "$SCRIPT_DIR/main.tex" -output-directory="$SCRIPT_DIR/target" "$@"; then
    printf "\n[1;92mCompiled successfully![0m\n"
else
    printf "\n[1;91mError! The LaTeX compilation failed.\n\nFor further details check out the log, located at %s[0m\n" "$SCRIPT_DIR/target/main.log"
fi
