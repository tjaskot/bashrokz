#!/bin/bash
# with HISTCONTROL=ignoreboth on, if you add space in front of 'nvm' command like ' nvm', it will remove 2 items in history since terminal execution doesn't get added to history
seqEnd=$1
if [[ $seqEnd == "" ]]; then
	# Need a second item because history incremented with "nvm" from terminal execution, and need to delete this plus one line back
	seqEnd=2
fi
# mac os
for i in $(seq 1 $seqEnd); do sed -i '' -e '$d' $HISTFILE; done
# linux
# for i in $(seq 1 $seqEnd); do sed -i -e '$d' $HISTFILE; done
