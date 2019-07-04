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
	ok   "SAVE"
	exit "CANCEL"
)
dirselect_checkboxes_buttons_order=( "ok" "exit" )
dirselect_checkboxes_buttons_active=1

#--- END OF CONFIGURATION ---#

# wrapped in an anonymous function so we don't
# pollute the rest of the script with our traps and stuff
function() {
	# include and initialize bzcurses
	. "$1"

	# draw the choices window from the main choices
	_draw_checkboxes dirselect "Directory Select"

} "${0:h}/../bzcurses.zsh"

echo "$dirselect_checkboxes_checked"
