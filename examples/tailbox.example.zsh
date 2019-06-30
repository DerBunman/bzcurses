#!/usr/bin/env zsh
debug=${debug:-false}

mkfifo /tmp/fifo.$$
trap 'rm -f /tmp/fifo.$$' TERM INT


#       _      _
#   ___| |_ __| |___  ___ _ __
#  / __| __/ _` / __|/ __| '__|
#  \__ \ || (_| \__ \ (__| |
#  |___/\__\__,_|___/\___|_|
title_stdscr="tailbox example"

# set default theme or from env variable
# for example, start this script like this
# $ theme=nerdfonts ./example.zsh
theme=${theme:-default}


# include and initialize bzcurses
. ${0:h}/../bzcurses.zsh

# this will redirect stdout and stderr
# from the loop into the named pipe
# /tmp/fifo.$$
for i in $( seq 1 100 ); do
	echo "This is a very nice number: $i"
	sleep 1
done 1>/tmp/fifo.$$ 2>&1 &|

_draw_tailbox /tmp/fifo.$$ "Tailbox demo"
