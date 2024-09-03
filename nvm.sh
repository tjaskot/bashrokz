#!/bin/bash
seqEnd=$1
if [[ $seqEnd == "" ]]; then
	# Need a second item because history incremented with "nvm" from terminal execution, and need to delete this plus one line back
	seqEnd=2
fi
# mac os
for i in $(seq 1 $seqEnd); do sed -i '' -e '$d' $HISTFILE; done
# linux
# for i in $(seq 1 $seqEnd); do sed -i -e '$d' $HISTFILE; done
