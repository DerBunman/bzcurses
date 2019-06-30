#!/usr/bin/env zsh
debug=${debug:-false}


#       _      _
#   ___| |_ __| |___  ___ _ __
#  / __| __/ _` / __|/ __| '__|
#  \__ \ || (_| \__ \ (__| |
#  |___/\__\__,_|___/\___|_|
title_stdscr="bzcurses example"

# set default theme or from env variable
# for example, start this script like this
# $ theme=nerdfonts ./example.zsh
theme=${theme:-default}

#   _        _ _                     _
#  | |_ __ _(_) |__   _____  __   __| | ___ _ __ ___   ___
#  | __/ _` | | '_ \ / _ \ \/ /  / _` |/ _ \ '_ ` _ \ / _ \
#  | || (_| | | |_) | (_) >  <  | (_| |  __/ | | | | | (_) |
#   \__\__,_|_|_.__/ \___/_/\_\  \__,_|\___|_| |_| |_|\___/
tailbox_demo() {
	mkfifo /tmp/fifo.$$
	trap 'rm -f /tmp/fifo.$$' EXIT
	
	# this command lists all man pages and redirects
	# stdout and stderr into the named pipe /tmp/fifo.$$
	apropos . 1>/tmp/fifo.$$ 2>&1 &|

	_draw_tailbox /tmp/fifo.$$ "Installed man pages"
}

#                   _
#   _ __ ___   __ _(_)_ __    _ __ ___   ___ _ __  _   _
#  | '_ ` _ \ / _` | | '_ \  | '_ ` _ \ / _ \ '_ \| | | |
#  | | | | | | (_| | | | | | | | | | | |  __/ | | | |_| |
#  |_| |_| |_|\__,_|_|_| |_| |_| |_| |_|\___|_| |_|\__,_|

main_choices_title="Main Menu"

# main menu intro text (max 4 rows)
main_choices_intro_text="${$(cat <<EOF
Welcome to the main menu of the ${0:t} script.
Feel free to play around.
EOF
)}"

# main menu choices
typeset -A main_choices=(
	blah      "Radio select blah."
	fasel     "Checkboxes collection fasel (has some undefined variables)."
	undefined "Undefined checkboxes (will trigger error)."
	unknown   "Undefined function (will trigger error)."
	tailbox   "Launch Tailbox demo."
)
main_choice_order=(
	blah fasel undefined unknown tailbox
)
typeset -A main_choice_actions=(
	blah      "function::_draw_checkboxes::blah"
	fasel     "function::_draw_checkboxes::fasel"
	undefined "function::_draw_checkboxes::undefined"
	unknown   "function::unknown::unknown"
	tailbox   "function::tailbox_demo"
)

# overwrite the default button definitions
# button broken is an example for what will happen
# when you forget to define a function for a button
typeset -A main_choices_buttons=(
	ok     "SELECT"
	exit   "EXIT"
	help   "HELP"
	edit   "EDIT"
	broken "BROKEN"
)
main_choices_buttons_order=( "ok" "exit" "help" "edit" "broken" )
main_choices_buttons_active=1


main_choices_help_text="$(cat <<'EOF'
Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
 
Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.
 
Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.
EOF
)"

main_choices_buttons_actions.help() {
	_draw_textbox help "Help" "$main_choices_help_text"
}

#    __                _
#   / _| __ _ ___  ___| |
#  | |_ / _` / __|/ _ \ |
#  |  _| (_| \__ \  __/ |
#  |_|  \__,_|___/\___|_|
#        _               _    _
#    ___| |__   ___  ___| | _| |__   _____  _____  ___
#   / __| '_ \ / _ \/ __| |/ / '_ \ / _ \ \/ / _ \/ __|
#  | (__| | | |  __/ (__|   <| |_) | (_) >  <  __/\__ \
#   \___|_| |_|\___|\___|_|\_\_.__/ \___/_/\_\___||___/
# the _checkboxes is an associative array that defines
# the name and the title of the checkboxes
typeset -A fasel_checkboxes=(
	foo1 "Dies ist ein toller Text."
	bar1 "Und dies ist ein weiterer toller Text."
	baz1 "And another text."
	foo2 "Dies ist ein toller Text."
	bar2 "Und dies ist ein weiterer toller Text."
	baz2 "And another text."
)
# add 100 more checkboxes
for i in $( seq 1 100 ); do
	fasel_checkboxes+=( "key$i" "Text $i" )
done

# the _checkboxes_checked array contains the names of all checked boxes
fasel_checkboxes_checked=( foo1 baz2 bar1 )
# since associative arrays in zsh are unordered and
# arrays are ordered we define _checkbox_order as an
# array containing the keys of _checkboxes.
# if we use the ${(k)} we will get these in random order.
fasel_checkbox_order=( ${(k)fasel_checkboxes} )


#   _     _       _
#  | |__ | | __ _| |__
#  | '_ \| |/ _` | '_ \
#  | |_) | | (_| | | | |
#  |_.__/|_|\__,_|_| |_|
#        _               _    _
#    ___| |__   ___  ___| | _| |__   _____  _____  ___
#   / __| '_ \ / _ \/ __| |/ / '_ \ / _ \ \/ / _ \/ __|
#  | (__| | | |  __/ (__|   <| |_) | (_) >  <  __/\__ \
#   \___|_| |_|\___|\___|_|\_\_.__/ \___/_/\_\___||___/
# the _checkboxes is an associative array that defines
# the name and the title of the checkboxes
typeset -A blah_checkboxes=(
	blah01 "text01 blah blah"
	blah02 "text02 blah blah"
	blah03 "text03 blah blah"
	blah04 "text04 blah blah"
	blah05 "text05 blah blah"
	blah06 "text06 blah blah"
	blah07 "text07 blah blah"
	blah08 "text08 blah blah"
	blah09 "text09 blah blah"
	blah10 "text10 blah blah"
)
# the _checkboxes_checked array contains the names of all checked boxes
blah_checkboxes_checked=( blah01 )
# since associative arrays in zsh are unordered and
# arrays are ordered we define _checkbox_order as an
# array containing the keys of _checkboxes.
# if we use the ${(k)} we will get these in random order.
blah_checkbox_order=(
	blah01 blah02 blah03 blah04 blah05 blah06 blah07 blah08 blah09 blah10
)
blah_checkboxes_behavior="radio"

blah_checkboxes_intro_text=$(cat <<EOF
This is a intro text.
Not the best intro text, but the one we have here....
EOF
)
blah_checkboxes_title="blahs Menu"

# overwrite default buttons for blah checkboxes
typeset -A blah_checkboxes_buttons=(
	ok   "BACK"
	exit "EXIT"
)
blah_checkboxes_buttons_order=( "ok" "exit" )
blah_checkboxes_buttons_active=1

#--- END OF CONFIGURATION ---#

# include and initialize bzcurses
. ${0:h}/../bzcurses.zsh


# draw the choices window from the main choices
while true; do
	_draw_choices main
done

# everything redirected to fd3 will be displayed
# after zcurses has ended
echo BLAH:  $blah_checkboxes_checked[@] 1>&3
echo FASEL: $fasel_checkboxes_checked[@] 1>&3

