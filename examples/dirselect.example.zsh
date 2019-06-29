#!/usr/bin/env zsh
debug=${debug:-false}

if [ "$1" = "" ]; then
	echo "please provide path"
	exit 1
fi

title_stdscr="dirselect example"

trap 'echo $0 $LINENO;' INT TERM

# the _checkboxes is an associative array that defines
# the name and the title of the checkboxes
typeset -A dirselect_checkboxes
dirselect_checkbox_order=()
dirpath=

for dir in ${1}/**/*(/); do
	# since associative arrays in zsh are unordered and
	# arrays are ordered we define _checkbox_order as an
	# array containing the keys of _checkboxes.
	dirselect_checkboxes+=( "$dir" "$dir" )
	dirselect_checkbox_order+=( "$dir" )
done

# the _checkboxes_checked array contains the names of all checked boxes
dirselect_checkboxes_checked=( )

dirselect_checkboxes_intro_text=$(cat <<EOF
This is a intro text.
Not the best intro text, but the one we have here....
EOF
)
dirselect_checkboxes_title="dirselects Menu"

# overwrite default buttons for dirselect checkboxes
typeset -A dirselect_checkboxes_buttons=(
	ok   "[SAVE]"
	exit "[CANCEL]"
)
dirselect_checkboxes_buttons_order=( "ok" "exit" )
dirselect_checkboxes_buttons_active=1

#--- END OF CONFIGURATION ---#

# include and initialize bzcurses
. ${0:h}/../bzcurses.zsh

# draw the coices window from the main choices
_draw_checkboxes dirselect "Directory Select"
[ $? -ne 0 ] && {
	exit 1
} || {
	if [ ! -f "$REPLY_FILE" ]; then
		echo $dirselect_checkboxes_checked >"$REPLY_FILE"
	elif [ -f "$REPLY_FILE" ]; then
		echo "ERROR: REPLY_FILE $REPLY_FILE already exists. Aborting." >&2
		false # trigger the ERR trap
	else
		echo $dirselect_checkboxes_checked >&3
	fi
	exit 0
}
