#!/usr/bin/env zsh
debug=${debug:-false}

mkfifo /tmp/fifo.$$
trap 'rm -f /tmp/fifo.$$' TERM INT

# title of the stdscr
title_stdscr="tailbox example"

# set default theme or from env variable
# for example, start this script like this
# $ theme=nerdfonts ./example.zsh
theme=${theme:-default}

# this will redirect stdout and stderr
# from the loop into the named pipe
# /tmp/fifo.$$
for i in $( seq 1 100 ); do
	echo "This is a very nice number: $i"
	sleep 1
done 1>/tmp/fifo.$$ 2>&1 &|

function(){
	# include and initialize bzcurses
	. "$1"
	_draw_tailbox /tmp/fifo.$$ "Listing nice numbers."

} "${0:h}/../bzcurses.zsh"
