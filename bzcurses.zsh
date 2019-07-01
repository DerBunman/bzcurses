#!/usr/bin/env zsh
setopt PIPEFAIL ERR_EXIT
debug=${debug:-false}

# redirect stderr so we can display the errors
# when the ERR trap is called
stderr_file=$(mktemp -t bzcurses.stderr.$$.XXXXX)
exec 2>$stderr_file

#       _       __             _ _
#    __| | ___ / _| __ _ _   _| | |_
#   / _` |/ _ \ |_ / _` | | | | | __|
#  | (_| |  __/  _| (_| | |_| | | |_
#   \__,_|\___|_|  \__,_|\__,_|_|\__|
#   _   _
#  | |_| |__   ___ _ __ ___   ___
#  | __| '_ \ / _ \ '_ ` _ \ / _ \
#  | |_| | | |  __/ | | | | |  __/
#   \__|_| |_|\___|_| |_| |_|\___|
default_fg="black"
default_bg="cyan"

error_fg="white"
error_bg="red"

scroll_indicator_fg="white"
scroll_indicator_bg="red"

row_active_fg="black"
row_active_bg="white"

button_active_fg="black"
button_active_bg="white"
button_inactive_fg="white"
button_inactive_bg="black"

button_active_prefix=" "
button_active_postfix=" "
button_inactive_prefix=" "
button_inactive_postfix=" "

checkbox_checked_chars="[X]"
checkbox_unchecked_chars="[ ]"

radio_checked_chars="(X)"
radio_unchecked_chars="( )"

scroll_up_indicator_char="↑"   # only 1 char allowed
scroll_down_indicator_char="↓" # only 1 char allowed

choices_choice_prefix="→ "

# the icons are added via theme and/or your script
# if you use a theme that provides icons, you can
# append icons to the button_icons or you can overwrite
# the complete array. whatever floats your boat.
typeset -A button_icons=()

button_prefix=" "
button_postfix=" "

#   _   _
#  | |_| |__   ___ _ __ ___   ___
#  | __| '_ \ / _ \ '_ ` _ \ / _ \
#  | |_| | | |  __/ | | | | |  __/
#   \__|_| |_|\___|_| |_| |_|\___|
#                  _
#    ___ _ __   __| |
#   / _ \ '_ \ / _` |
#  |  __/ | | | (_| |
#   \___|_| |_|\__,_|




#       _      _
#   ___| |_ __| |___  ___ _ __
#  / __| __/ _` / __|/ __| '__|
#  \__ \ || (_| \__ \ (__| |
#  |___/\__\__,_|___/\___|_|
title_stdscr="${title_stdscr:-bzcurses}"

#   _           _   _
#  | |__  _   _| |_| |_ ___  _ __  ___
#  | '_ \| | | | __| __/ _ \| '_ \/ __|
#  | |_) | |_| | |_| || (_) | | | \__ \
#  |_.__/ \__,_|\__|\__\___/|_| |_|___/

# default actions if there is nothing defined
buttons_actions.exit() {
	yesno_exit && return 100
	[ $? -eq 1 ] && exit
}

#        _           _
#    ___| |__   ___ (_) ___ ___  ___
#   / __| '_ \ / _ \| |/ __/ _ \/ __|
#  | (__| | | | (_) | | (_|  __/\__ \
#   \___|_| |_|\___/|_|\___\___||___/
#   _           _   _
#  | |__  _   _| |_| |_ ___  _ __  ___
#  | '_ \| | | | __| __/ _ \| '_ \/ __|
#  | |_) | |_| | |_| || (_) | | | \__ \
#  |_.__/ \__,_|\__|\__\___/|_| |_|___/
# buttons and actions for choices
typeset -A choices_buttons
choices_buttons=(
	ok     "SELECT"
	cancel "CANCEL"
	help   "HELP"
)
choices_buttons_order=( "ok" "cancel" "help" )

choices_buttons_actions.cancel() {
	debug_msg "Cancel pressed. Ending checkboxes dialog with error code 1."
	return 1
}

#        _               _    _
#    ___| |__   ___  ___| | _| |__   _____  _____  ___
#   / __| '_ \ / _ \/ __| |/ / '_ \ / _ \ \/ / _ \/ __|
#  | (__| | | |  __/ (__|   <| |_) | (_) >  <  __/\__ \
#   \___|_| |_|\___|\___|_|\_\_.__/ \___/_/\_\___||___/
#   _           _   _
#  | |__  _   _| |_| |_ ___  _ __  ___
#  | '_ \| | | | __| __/ _ \| '_ \/ __|
#  | |_) | |_| | |_| || (_) | | | \__ \
#  |_.__/ \__,_|\__|\__\___/|_| |_|___/
# buttons and actions for checkboxes
typeset -A checkboxes_buttons
checkboxes_buttons=(
	ok "OK"
)
checkboxes_buttons_order=( "ok" )

checkboxes_buttons_actions.ok() {
	debug_msg "Ok pressed. Ending checkboxes dialog."
	return
}

#   _            _   _
#  | |_ _____  _| |_| |__   _____  __
#  | __/ _ \ \/ / __| '_ \ / _ \ \/ /
#  | ||  __/>  <| |_| |_) | (_) >  <
#   \__\___/_/\_\\__|_.__/ \___/_/\_\
#   _           _   _
#  | |__  _   _| |_| |_ ___  _ __  ___
#  | '_ \| | | | __| __/ _ \| '_ \/ __|
#  | |_) | |_| | |_| || (_) | | | \__ \
#  |_.__/ \__,_|\__|\__\___/|_| |_|___/
#
# buttons and actions for textbox
typeset -A textbox_buttons
textbox_buttons=(
	ok "OK"
)
textbox_buttons_order=( "ok" )
textbox_buttons_active=1

textbox_buttons_actions.ok() {
	debug_msg "Ok pressed. Ending textbox dialog."
	return
}

#    ___ _ __ _ __ ___  _ __
#   / _ \ '__| '__/ _ \| '__|
#  |  __/ |  | | | (_) | |
#   \___|_|  |_|  \___/|_|
#   _            _   _
#  | |_ _____  _| |_| |__   _____  __
#  | __/ _ \ \/ / __| '_ \ / _ \ \/ /
#  | ||  __/>  <| |_| |_) | (_) >  <
#   \__\___/_/\_\\__|_.__/ \___/_/\_\
#   _           _   _
#  | |__  _   _| |_| |_ ___  _ __  ___
#  | '_ \| | | | __| __/ _ \| '_ \/ __|
#  | |_) | |_| | |_| || (_) | | | \__ \
#  |_.__/ \__,_|\__|\__\___/|_| |_|___/
#
# buttons and actions for error textbox
typeset -A error_textbox_buttons
error_textbox_buttons=(
	ok "OK"
)
error_textbox_buttons_order=( "ok" )
error_textbox_buttons_active=1

error_textbox_buttons_actions.ok() {
	debug_msg "Ok pressed. Ending textbox dialog."
	return
}

#                      __
#   _   _  ___  ___   / / __   ___
#  | | | |/ _ \/ __| / / '_ \ / _ \
#  | |_| |  __/\__ \/ /| | | | (_) |
#   \__, |\___||___/_/ |_| |_|\___/
#   |___/
#   _            _   _
#  | |_ _____  _| |_| |__   _____  __
#  | __/ _ \ \/ / __| '_ \ / _ \ \/ /
#  | ||  __/>  <| |_| |_) | (_) >  <
#   \__\___/_/\_\\__|_.__/ \___/_/\_\
#       _ _       _
#    __| (_) __ _| | ___   __ _
#   / _` | |/ _` | |/ _ \ / _` |
#  | (_| | | (_| | | (_) | (_| |
#   \__,_|_|\__,_|_|\___/ \__, |
#                         |___/
typeset -A yesno_textbox_buttons
yesno_textbox_buttons=(
	yes "YES"
	no  "NO"
)
yesno_textbox_buttons_order=( "no" "yes" )
yesno_textbox_buttons_active=1

yesno_textbox_buttons_actions.yes() {
	yesno_textbox_buttons_active=1
	debug_msg "Yes pressed. return 0."
	return 0
}

yesno_textbox_buttons_actions.no() {
	yesno_textbox_buttons_active=1
	debug_msg "No pressed. return 1."
	return 1
}




#  _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____
# |_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|
#                 _          __                   _       _     _
#   ___ _ __   __| |   ___  / _| __   ____ _ _ __(_) __ _| |__ | | ___
#  / _ \ '_ \ / _` |  / _ \| |_  \ \ / / _` | '__| |/ _` | '_ \| |/ _ \
# |  __/ | | | (_| | | (_) |  _|  \ V / (_| | |  | | (_| | |_) | |  __/
#  \___|_| |_|\__,_|  \___/|_|     \_/ \__,_|_|  |_|\__,_|_.__/|_|\___|
#      _       __ _       _ _   _
#   __| | ___ / _(_)_ __ (_) |_(_) ___  _ __  ___
#  / _` |/ _ \ |_| | '_ \| | __| |/ _ \| '_ \/ __|
# | (_| |  __/  _| | | | | | |_| | (_) | | | \__ \
#  \__,_|\___|_| |_|_| |_|_|\__|_|\___/|_| |_|___/
#  _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____
# |_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|



#                                           _ _
#   _   _  ___  ___ _ __   ___     _____  _(_) |_
#  | | | |/ _ \/ __| '_ \ / _ \   / _ \ \/ / | __|
#  | |_| |  __/\__ \ | | | (_) | |  __/>  <| | |_
#   \__, |\___||___/_| |_|\___/___\___/_/\_\_|\__|
#   |___/                    |_____|
yesno_exit() {
	debug_msg "YESNO EXIT: drawing dialog"
	_draw_yesno "Confirm exit" "Are you sure, that you want to exit?" || return 0
	[ $? -eq 0 ] && exit
}


#                   _ _   _
#   _ __   ___  ___(_) |_(_) ___  _ __
#  | '_ \ / _ \/ __| | __| |/ _ \| '_ \
#  | |_) | (_) \__ \ | |_| | (_) | | | |
#  | .__/ \___/|___/_|\__|_|\___/|_| |_|
#  |_|
# $1 = window
# $@ = parameters:
#   border increments x/y offset +1
#   offset_y increments y offset +1 per match (can be defined multiple times)
#   offset_x increments x offset +1 per match (can be defined multiple times)
# example: _set_position_array textbox border offset_y++
# the parameter border will calculate inner width
# and height without the border
_set_position_array() {
	local name=$1
	shift
	local params=( $@ )
	# read textbox postion into array textbox_position
	zcurses position ${name} tmp_position

	# first we'll write our resulting array
	# into an tmp array, because it seems like
	# we can't create a dynamic named array
	# without this hassle
	typeset -A tmp=(
		# offset top left
		stdscr_offset_y  ${tmp_position[3]}
		stdscr_offset_x  ${tmp_position[4]}
		# the width/height including the border if set
		outer_height     ${tmp_position[5]}
		outer_width      ${tmp_position[6]}
		# the border always substracts 2 lines/cols
		height           ${tmp_position[5]}
		width            ${tmp_position[6]}
		# top left offset (if border is set)
		offset_y         0
		offset_x         0
	)

	if (( ${+params[(r)border]} )); then
		#debug_msg "$name has border: height/width -2, offset_y/x +1"
		tmp[height]=$(( $tmp[height] -2 ))
		tmp[width]=$(( $tmp[width] -2 ))
		tmp[offset_y]=$(( $tmp[offset_y] +1 ))
		tmp[offset_x]=$(( $tmp[offset_x] +1 ))
		tmp[stdscr_offset_y]=$(( $tmp[stdscr_offset_y] +1 ))
		tmp[stdscr_offset_x]=$(( $tmp[stdscr_offset_x] +1 ))
	fi
	for param in $params; do
		case $param in
			offset_y)
				tmp[stdscr_offset_y]=$(( $tmp[stdscr_offset_y] +1 ))
				tmp[offset_y]=$(( $tmp[offset_y] +1 ))
				tmp[height]=$(( $tmp[height] -1 ))
				;;
			offset_x)
				tmp[stdscr_offset_x]=$(( $tmp[stdscr_offset_x] +1 ))
				tmp[offset_x]=$(( $tmp[offset_x] +1 ))
				tmp[width]=$(( $tmp[width] -1 ))
				;;
			border)
				# border is handled outside of the loop
				;;
			*)
				debug_msg "ERROR Unknown parameter: $param"
				;;
		esac
	done

	# ... then we create an empty array with
	# the desired name ...
	local array_name=${name}_position
	typeset -g -A $array_name
	# ... then we assign the tmp array to this
	# array usign the set command.
	set -g -A $array_name ${(kv)tmp}
}

#                               _                   _
#   _ __   __ _ _ __ ___  ___  (_)_ __  _ __  _   _| |_
#  | '_ \ / _` | '__/ __|/ _ \ | | '_ \| '_ \| | | | __|
#  | |_) | (_| | |  \__ \  __/ | | | | | |_) | |_| | |_
#  | .__/ \__,_|_|  |___/\___| |_|_| |_| .__/ \__,_|\__|
#  |_|                                 |_|
#
# this function parses the result from zcurses input
# into the global variable input_event
# TODO: handle mouse click positions
typeset -A input_event
_parse_input_event() {
	key=${${1/$'\n'/CR}:-${2:-none}}
	if [ "$1" = $'\n' ]; then
		key="CR"
	elif [ "$1" = $'\t' ]; then
		key="TAB"
	fi
	key=${key:-${2:-none}}
	local tmp=( $(echo $3) )
	input_event=(
		key "$key"
		mouse "$tmp"
	)
	if [ "$input_event[key]" = 'MOUSE' ]; then
		input_event[key]=$tmp[5]
	fi
	debug_msg "InputEvent: $input_event[key] M $input_event[mouse]"
}


#   _                     _ _        _           _   _
#  | |__   __ _ _ __   __| | | ___  | |__  _   _| |_| |_ ___  _ __
#  | '_ \ / _` | '_ \ / _` | |/ _ \ | '_ \| | | | __| __/ _ \| '_ \
#  | | | | (_| | | | | (_| | |  __/ | |_) | |_| | |_| || (_) | | | |
#  |_| |_|\__,_|_| |_|\__,_|_|\___| |_.__/ \__,_|\__|\__\___/|_| |_|
#                        _
#    _____   _____ _ __ | |_
#   / _ \ \ / / _ \ '_ \| __|
#  |  __/\ V /  __/ | | | |_
#   \___| \_/ \___|_| |_|\__|
#
# uses the input to switch the active button
# expects the prefix of the buttons variables/window
# example: _handle_button_event checkboxes
_handle_button_event() {
	active=${1}_active
	order=${1}_order

	case $input_event[key] in
		LEFT)
			if [ ${(P)active} -gt 1 ]; then
				let $active=$(( $active -1 ))
			fi
			;;
		RIGHT)
			if [ ${(P)active} -lt ${(P)#order[@]} ]; then
				let $active=$(( $active +1 ))
			fi
			;;
		TAB)
			if [ ${(P)active} -lt ${(P)#order[@]} ]; then
				let $active=$(( $active +1 ))
			else
				let $active=1
			fi
			;;
	esac
	debug_msg "Handle Buttons selected $1: ${${(P)order}[$active]}"
}


#   _           _   _                   __                  _   _
#  | |__  _   _| |_| |_ ___  _ __      / _|_   _ _ __   ___| |_(_) ___  _ __
#  | '_ \| | | | __| __/ _ \| '_ \    | |_| | | | '_ \ / __| __| |/ _ \| '_ \
#  | |_) | |_| | |_| || (_) | | | |   |  _| |_| | | | | (__| |_| | (_) | | | |
#  |_.__/ \__,_|\__|\__\___/|_| |_|___|_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|
#                                |_____|
# sets $button_function to the name of the function to be called on button activation
button_function=""
_set_button_function_name() {
	button_function=""
	# check if there is a function for button/$2 combination ...
	typeset -f ${2}_${1}_buttons_actions.${3} > /dev/null && {
		button_function=${2}_${1}_buttons_actions.${3}
	} || {
	# ... else check for a ${1}_button default action for $button ...
		typeset -f ${1}_buttons_actions.${3} > /dev/null && {
			button_function=${1}_buttons_actions.${3}
		} || {
			# ... and check for another higher definition
			typeset -f buttons_actions.${3} > /dev/null && {
				button_function=buttons_actions.${3}
			} || {
				# ... display error msg if neither is found
				debug_msg "BUTTON for $1::$2::$3 has NO FUNCTION"
				return
			}
		}
	}
	debug_msg "$3 has function $button_function"
	return
}


#   _           _   _
#  | |__  _   _| |_| |_ ___  _ __  ___
#  | '_ \| | | | __| __/ _ \| '_ \/ __|
#  | |_) | |_| | |_| || (_) | | | \__ \
#  |_.__/ \__,_|\__|\__\___/|_| |_|___/
#
# expects the name of the buttons array/buttons window as $1
# so the array and button window names have to match
# TODO: validate that the button variables are defined and correct
#
# example: _draw_buttons choices_buttons [alternate_variable_prefix]
_draw_buttons() {
	local buttons_var_prefix=${2:-$1}
	local index
	zcurses move ${1} 0 0
	local sort_order_key="${buttons_var_prefix}_order"
	zcurses attr ${1} "$button_inactive_fg/$button_inactive_bg"
	for ((index=1; index <= ${#${(P)sort_order_key}[@]}; ++index)); do
		if [ $index -gt 1 ]; then
			zcurses position "$1" pos
			zcurses move ${1} $pos[1] $(( $pos[2] +1 ))
		fi
		#zcurses attr ${1} "$window_color"
		local button_prefix=${button_inactive_prefix}
		local button_postfix=${button_inactive_postfix}
		local active_element_key="${buttons_var_prefix}_active"
		if [ $index -eq ${(P)active_element_key} ]; then
			local button_prefix=${button_active_prefix}
			local button_postfix=${button_active_postfix}
			zcurses attr ${1} "$button_active_fg/$button_active_bg"
			#zcurses attr ${1} standout
		fi

		local button_text="${${(P)buttons_var_prefix}[${${(P)sort_order_key}[$index]}]}"
		local icon_string=""
		if [ $+button_icons[$button_text] -gt 0 ]; then
			icon_string="${button_icons[$button_text:u]}"
		elif [ $+button_icons[UNDEFINED] -gt 0 ]; then
			icon_string="${button_icons[UNDEFINED]}"
		fi
		
		zcurses string ${1} "${button_prefix:-|}${icon_string}${button_text}${button_postfix:-|}"
		zcurses attr ${1} "$button_inactive_fg/$button_inactive_bg"
		#zcurses attr ${1} -standout
	done
}

#       _      _
#    __| | ___| |__  _   _  __ _     _ __ ___  ___  __ _
#   / _` |/ _ \ '_ \| | | |/ _` |   | '_ ` _ \/ __|/ _` |
#  | (_| |  __/ |_) | |_| | (_| |   | | | | | \__ \ (_| |
#   \__,_|\___|_.__/ \__,_|\__, |___|_| |_| |_|___/\__, |
#                          |___/_____|             |___/
debug_msg() {
	if [[ ${+zcurses_windows[(r)debug]} -ne 0 && $debug = true ]]; then
		local prefix="[$(date +%H:%M:%S)] "
		local row=""
		# iterate over $* and validate line length
		local tmp=( ${(@f)*} )
		for row in $tmp; do
			row="${prefix}${row}"
			while [ ${#row} -gt 0 ]; do
				# scroll
				zcurses scroll debug +1
				# overwrite the bottom border so it won't bleed into the previous msg
				zcurses move debug $(( ${debug_size[height]} -1)) 1
				zcurses string debug "${(r:${debug_size[width]}:: :)${}}"
				
				zcurses move debug $(( ${debug_size[height]} -1)) 1
				if [ $debug_size[width] -lt $(( ${#row}  )) ]; then
					# display error msg
					zcurses string debug "${row[1,$(( $debug_size[width] -1 ))]}"

					row="${${row[$(( $debug_size[width] -1 )),${#row}]}## }"
				else
					zcurses string debug "${row}"
					row=""
				fi
			done
		done
		# add border and refresh
		zcurses border debug
		zcurses refresh debug
	fi
}

#        _           _                        _   _
#    ___| |__   ___ (_) ___ ___     __ _  ___| |_(_) ___  _ __
#   / __| '_ \ / _ \| |/ __/ _ \   / _` |/ __| __| |/ _ \| '_ \
#  | (__| | | | (_) | | (_|  __/  | (_| | (__| |_| | (_) | | | |
#   \___|_| |_|\___/|_|\___\___|___\__,_|\___|\__|_|\___/|_| |_|
#                             |_____|
_parse_choice_action() {
	debug_msg "Choice Action: parsing $1"
	local splitted=( $(echo ${1//::/ } ) )
	local action=$splitted[1]
	shift splitted

	if [ "$action" = "function" ]; then
		local func="${splitted[1]}"
		shift splitted
		typeset -f "${func}" >/dev/null || {
			error_msg "ERROR: Function not found: $func."
			return 0
		}
		debug_msg "Calling: $func ${splitted}"
		"$func" "${splitted[@]}"

	elif [ "$action" = "command" ]; then
		if ! (( $+commands[$splitted[1]] )); then
			error_msg "Unknown command '${splitted[1]}' defined."
		else
			local cmd=$splitted[1]
			shift splitted
			"$cmd" "${splitted[@]}"

		fi
	else
		error_msg "Unknown action '${action}' defined."
	fi
}


#        _           _
#    ___| |__   ___ (_) ___ ___  ___
#   / __| '_ \ / _ \| |/ __/ _ \/ __|
#  | (__| | | | (_) | | (_|  __/\__ \
#   \___|_| |_|\___/|_|\___\___||___/
_draw_choices() {
	typeset -A choice_actions
	local choice_actions=( ${(kv)${(P)$(echo ${1}_choice_actions)}} )
	local choice_active_key="${1}_choice_active"
	local choices_key="${1}_choices"
	local choice_order=( ${(P)$(echo ${1}_choice_order)} )
	local help_text=${(P)$(echo "${1}_choices_help_text"):-no help}
	local title="${(P)$(echo "${1}_choices_title"):-no title}"
	local intro_text="${(P)$(echo "${1}_choices_intro_text"):-no text defined}"

	# overwrite default button definitons if there is a definition for this $1 name
	if [ ${(P)#$(echo ${1}_choices_buttons)[@]} -gt 0 ]; then
		local choices_buttons_key=${1}_choices_buttons
		local choices_buttons_order_key=${1}_choices_buttons_order
		local choices_buttons_active_key=${1}_choices_buttons_active
	else
		local choices_buttons_key=choices_buttons
		local choices_buttons_order_key=choices_buttons_order
		local choices_buttons_active_key=choices_buttons_active
	fi

	let ${choices_buttons_active_key}=1

	if [ "${(P)choice_active_key}" = "" ]; then
		let ${choice_active_key}=1
	fi

	zcurses addwin choices \
		$max_window_size[height] $max_window_size[width] \
		$stdscr_position[offset_y] $stdscr_position[offset_x] \
		stdscr
	_set_position_array choices border

	local choices_text_height=3
	local choices_buttons_height=1

	zcurses addwin choices_buttons \
		1 \
		$choices_position[width] \
		$(( $choices_position[height] + $choices_position[stdscr_offset_y] - $choices_buttons_height )) \
		$choices_position[stdscr_offset_x] \
		choices
	_set_position_array choices_buttons

	zcurses addwin choices_choices \
		$(( $choices_position[height] -$choices_buttons_position[height] - $choices_text_height )) \
		${choices_position[width]} \
		$(( $choices_position[stdscr_offset_y] + $choices_text_height )) \
		$choices_position[stdscr_offset_x] \
		choices
	_set_position_array choices_choices border

	# cleanup windows on exit
	trap '
	zcurses clear choices_buttons;
	zcurses clear choices_choices;
	zcurses clear choices;
	zcurses delwin choices_buttons;
	zcurses delwin choices_choices;
	zcurses delwin choices;
	' EXIT

	while true; do
		zcurses clear choices
		# draw borders
		zcurses border choices
		zcurses border choices_choices

		#zcurses bg choices_buttons white/cyan
		zcurses bg choices $default_fg/$default_bg

		# choices window title
		zcurses move choices 0 1
		zcurses string choices "[${title}]"

		# choices window intro text
		(( i = 1 ))
		local tmp=( ${(@f)intro_text} )
		for row in $tmp; do
			while [ ${#row} -gt 0 ]; do
				zcurses move choices $i 1
				if [ $choices_position[width] -lt ${#row} ]; then
					debug_msg "INFO: Text row is too long, wrapping. ${#row} (max=$choices_position[width])"
					zcurses string choices "${row[1,$(( $choices_position[width] -1 ))]}"
					row="${${row[$choices_position[width],${#row}]}## }"
				else
					zcurses string choices "$row"
					row=""
				fi
				(( i = i +1 ))
			done
		done

		# overwrite button definitions if there is a definition for this choices name
		if [ ${(P)#$(echo ${1}_choices_buttons)[@]} -gt 0 ]; then
			_draw_buttons choices_buttons ${1}_choices_buttons
		else
			_draw_buttons choices_buttons
		fi

		# handle scroll offset and set index for first choice
		local scroll_offset=0
		if [ ${(P)choice_active_key} -gt $choices_choices_position[height] ]; then
			let scroll_offset=$((
				$scroll_offset + (${(P)choice_active_key} - $choices_choices_position[height])));

			# add scroll up indicator
			zcurses move choices_choices 1 $(( $choices_choices_position[outer_width] -${#scroll_up_indicator_char} ))
			zcurses bg choices_choices $scroll_indicator_fg/$scroll_indicator_bg
			zcurses string choices_choices "$scroll_up_indicator_char"
			zcurses bg choices_choices $default_fg/$default_bg
		fi

		# set index number of first choice to display
		local index=$(( $scroll_offset +1 ))

		debug_msg "Choice Value: ${choice_order[${(P)${choice_active_key}}]}"

		# choices choice
		i=1
		for ((; index <= ${#choice_order[@]}; ++index)); do
			if [ $i -gt $choices_choices_position[height] ]; then
				zcurses bg choices_choices $scroll_indicator_fg/$scroll_indicator_bg
				# we are already at the bottom right
				zcurses move choices_choices \
					$choices_choices_position[height] $(( $choices_choices_position[width] +2 -${#scroll_down_indicator_char} ))
				zcurses string choices_choices "$scroll_down_indicator_char"
				zcurses bg choices_choices $default_fg/$default_bg
				break
			fi
			zcurses move choices_choices $i $choices_choices_position[offset_x]
			if [ $index -eq ${(P)${choice_active_key}} ]; then
				zcurses attr choices_choices $row_active_fg/$row_active_bg
				zcurses attr choices_choices bold
			else
				zcurses attr choices_choices $default_fg/$default_bg
			fi

			zcurses string choices_choices \
				"${choices_choice_prefix}${(r:${$(( ${choices_choices_position[width]} - ${#choices_choice_prefix} ))}:: :)${(P)choices_key}[${choice_order[${index}]}]}"
			zcurses attr choices_choices -bold
			zcurses attr choices_choices $default_fg/$default_bg
			(( i = i +1 ))
		done

		# redraw choices window with our changes
		zcurses refresh choices

		# evaluate input
		zcurses input stdscr raw key mouse
		_parse_input_event "$raw" "$key" "$mouse"
		if [ ${(P)#$(echo ${1}_choices_buttons)[@]} -gt 0 ]; then
			_handle_button_event ${1}_choices_buttons
		else
			_handle_button_event
		fi
		case "${input_event[key]}" in
			q)
				# TODO: handle globally and add confirm dialog
				exit
				;;
			CR)
				local button_value=${${(P)${(P)$(echo choices_buttons_order_key)}[@]}[${(P)$(echo $choices_buttons_active_key)}]}
				_set_button_function_name "choices" "$1" "$button_value"
				if [[ $button_value = "ok" && $button_function = "" ]]; then
					# if there is no function defined and the button is ok,
					# we check for a action definition for this choice
					local action="${choice_actions[${choice_order[${(P)${choice_active_key}}]}]:-undefined}"
					debug_msg "INFO: Selected: ${choice_order[${(P)${choice_active_key}}]} Action: ${action}"
					if [ "$action" = "undefined" ]; then
						error_msg \
							"There is no action defined for choice ${choice_order[${(P)${choice_active_key}}]}."
						return 0
					else
						_parse_choice_action "${action}"
						return
					fi
				elif [ "$button_function" != "" ]; then
					# if there is a button function defined call and handle it
					debug_msg "Button Function: $1::$button_value::$button_function"
					$button_function && {
						local retval=$?
					} || {
						local retval=$?
					}
					[ $retval -ne 100 ] && return $retval
				else
					# if there is no button_function defined we continue
					# shown an error_msg and continue
					error_msg "Button $1::$button_value has no function or action defined."
					continue
				fi
				;;
			PRESSED4|UP)
				if [ ${(P)${choice_active_key}} -gt 1 ]; then
					let ${choice_active_key}=$(( ${(P)${choice_active_key}} -1 ))
				fi
				;;
			PRESSED5|DOWN)
				if [ ${(P)${choice_active_key}} -lt ${#choice_order[@]} ]; then
					let ${choice_active_key}=$(( ${(P)${choice_active_key}} +1 ))
				fi
				;;
			PPAGE)
				if [ ${(P)${choice_active_key}} -gt 5 ]; then
					let ${choice_active_key}=$(( ${(P)${choice_active_key}} -5 ))
				else
					let ${choice_active_key}=1
				fi
				;;
			NPAGE)
				if [ ${(P)${choice_active_key}} -le ${#choice_order[@]} ]; then
					let ${choice_active_key}=$(( ${(P)${choice_active_key}} +5 ))
					if [ ${#choice_order[@]} -lt ${(P)${choice_active_key}} ]; then
						let ${choice_active_key}=${#choice_order[@]}
					fi
				fi
				;;
		esac

	done
}


#    ___ _ __ _ __ ___  _ __  _ __ ___  ___  __ _
#   / _ \ '__| '__/ _ \| '__|| '_ ` _ \/ __|/ _` |
#  |  __/ |  | | | (_) | |   | | | | | \__ \ (_| |
#   \___|_|  |_|  \___/|_|___|_| |_| |_|___/\__, |
#                       |_____|             |___/
error_msg() {
	_draw_textbox "error" "Error" "$@"
}

#   _   _  ___  ___ _ __   ___
#  | | | |/ _ \/ __| '_ \ / _ \
#  | |_| |  __/\__ \ | | | (_) |
#   \__, |\___||___/_| |_|\___/
#   |___/
_draw_yesno() {
	_draw_textbox "yesno" "$1" "$2"
	return $?
}

#   _            _   _
#  | |_ _____  _| |_| |__   _____  __
#  | __/ _ \ \/ / __| '_ \ / _ \ \/ /
#  | ||  __/>  <| |_| |_) | (_) >  <
#   \__\___/_/\_\\__|_.__/ \___/_/\_\
#
# expects:
#   $1 to the internal name
#   $2 to be the window title
#   $3 to be the text (newline = \n)
#
# example:
#   local text="fooo
#   bar"
#   _draw_textbox "name" "My Title" "$text"
_draw_textbox() {
	local textbox_current_text=()
	local textbox_scroll_offset=0

	# overwrite default button definitons if there is a definition for this $1 name
	if [ ${(P)#$(echo ${1}_textbox_buttons)[@]} -gt 0 ]; then
		local textbox_buttons_key=${1}_textbox_buttons
		local textbox_buttons_order_key=${1}_textbox_buttons_order
		local textbox_buttons_active_key=${1}_textbox_buttons_active
	else
		local textbox_buttons_key=textbox_buttons
		local textbox_buttons_order_key=textbox_buttons_order
		local textbox_buttons_active_key=textbox_buttons_active
	fi

	let ${textbox_buttons_active_key}=1

	debug_msg "drawing TEXTBOX for $1: '$2'"

	# add textbox window
	zcurses addwin textbox \
		$max_window_size[height] $max_window_size[width] \
		$stdscr_position[offset_y] $stdscr_position[offset_x] \
		stdscr
	_set_position_array textbox border

	# add textbox window
	local textbox_buttons_height=1
	zcurses addwin textbox_buttons \
		$textbox_buttons_height \
		$textbox_position[width] \
		$(( $textbox_position[height] + $textbox_position[stdscr_offset_y] - $textbox_position[offset_y] )) \
		$textbox_position[stdscr_offset_x] \
		textbox
	_set_position_array textbox_buttons

	# textbox text area
	zcurses addwin textbox_text \
		$(( $textbox_position[height] - $textbox_buttons_height )) \
		$textbox_position[width] \
		$textbox_position[stdscr_offset_y] \
		$textbox_position[stdscr_offset_x] \
		textbox
	_set_position_array textbox_text border

	# cleanup windows on exit
	trap '
	zcurses delwin textbox_text;
	zcurses delwin textbox_buttons;
	zcurses delwin textbox;
	' EXIT

	# iterate over $2 and validate line length
	if [ ${#textbox_current_text[@]} -eq 0 ]; then
		local tmp=( ${(@f)3} )
		for row in $tmp; do
			while [ ${#row} -gt 0 ]; do
				if [ $textbox_text_position[width] -lt ${#row} ]; then
					debug_msg "INFO: Textbox row is too long, wrapping. ${#row} (max=$textbox_text_position[width])"
					textbox_current_text+=( "${row[1,$textbox_text_position[width]]}" ) # -1 = optical space
					row="${${row[$textbox_text_position[width],${#row}]}## }"
				else
					textbox_current_text+=( "${row}" )
					row=""
				fi
			done
		done
	fi

	# red background if title = Error
	if [ "$1" = "error" ]; then
		local fg=$error_fg
		local bg=$error_bg
	else
		local fg=$default_fg
		local bg=$default_bg
	fi

	# textbox main loop
	while true; do
		# clear area containing textbox window
		zcurses clear textbox
		zcurses clear textbox_text
		zcurses clear textbox_buttons

		zcurses bg textbox $fg/$bg
		zcurses bg textbox_text $fg/$bg
		zcurses bg textbox_buttons $fg/$bg

		# draw border and colors
		zcurses border textbox
		zcurses border textbox_text

		# overwrite button definitions if there is a definition for this textbox name
		if [ ${(P)#$(echo ${1}_textbox_buttons)[@]} -gt 0 ]; then
			debug_msg "TEXTBOX Buttons: found button definition ${1}_textbox_buttons"
			_draw_buttons "textbox_buttons" "${1}_textbox_buttons"
		else
			debug_msg "TEXTBOX Buttons: using default button definition textbox_buttons"
			_draw_buttons "textbox_buttons" "textbox_buttons"
		fi

		# write title
		zcurses move textbox 0 1
		zcurses string textbox "[${2:-unset}]"

		# iterate over $textbox_current_text and draw the lines
		(( i = 1 ))
		index=$(( $textbox_scroll_offset +1 ))
		zcurses bg textbox_text $fg/$bg
		for ((; $index <= ${#textbox_current_text[@]}; ++index)); do
			# add scroll down indicator if there are still rows when
			# reaching the last line of the textbox
			if [ $textbox_text_position[height] -lt $i ]; then
				zcurses move textbox_text \
					$textbox_text_position[height] \
					$(( $textbox_text_position[width] + $textbox_text_position[offset_y] ))
				zcurses attr textbox_text $scroll_indicator_fg/$scroll_indicator_bg
				zcurses string textbox_text "$scroll_down_indicator_char"
				zcurses bg textbox_text $fg/$bg
				break
			fi
			zcurses move textbox_text $i 1
			zcurses string textbox_text "$textbox_current_text[$index]"
			(( i = i +1 ))
		done

		# add scroll up indicator if the scroll offset is >0
		if [ $textbox_scroll_offset -gt 0 ]; then
			zcurses move textbox_text \
				$textbox_text_position[offset_y] \
				$(( $textbox_text_position[width] + $textbox_text_position[offset_y] ))
			zcurses attr textbox_text $scroll_indicator_fg/$scroll_indicator_bg
			zcurses string textbox_text "$scroll_up_indicator_char"
			zcurses attr textbox_text $fg/$bg
		fi

		# draw the textbox
		zcurses refresh textbox

		# wait for user input
		zcurses input stdscr raw key mouse
		_parse_input_event "$raw" "$key" "$mouse"
		
		# handle input events for the button box
		if [ ${(P)#$(echo ${1}_textbox_buttons)[@]} -gt 0 ]; then
			_handle_button_event ${1}_textbox_buttons
		else
			_handle_button_event textbox_buttons
		fi

		case $input_event[key] in
			q)
				# TODO: handle gobally
				return 1
				;;
			CR)
				local button_value=${${(P)${(P)$(echo textbox_buttons_order_key)}[@]}[${(P)$(echo $textbox_buttons_active_key)}]}

				_set_button_function_name "textbox" "$1" "$button_value"
				if [ "$button_function" != "" ]; then
					$button_function && {
						local retval=$?
					} || {
						local retval=$?
					}
					[ $retval -ne 100 ] && return $retval
				else
					# if there is no button_function defined we continue
					# TODO: Error message
					continue
				fi
				;;
			PRESSED4|UP)
				if [ $textbox_scroll_offset -ge 1 ]; then
					textbox_scroll_offset=$(( $textbox_scroll_offset -1 ))
				fi
				;;
			PRESSED5|DOWN)
				if [ $(( ${#textbox_current_text[@]} -1 )) -gt $textbox_scroll_offset ]; then
					textbox_scroll_offset=$(( $textbox_scroll_offset +1 ))
				fi
				;;
			PPAGE)
				if [ $textbox_scroll_offset -ge 5 ]; then
					textbox_scroll_offset=$(( $textbox_scroll_offset -5 ))
				else
					textbox_scroll_offset=0
				fi
				;;
			NPAGE)
				if [ ${#textbox_current_text[@]} -gt $(( $textbox_scroll_offset +5 )) ]; then
					textbox_scroll_offset=$(( $textbox_scroll_offset +5 ))
				else
					textbox_scroll_offset=$(( ${#textbox_current_text[@]} -1 ))
				fi
				;;
		esac
	done
}


#        _               _    _
#    ___| |__   ___  ___| | _| |__   _____  _____  ___
#   / __| '_ \ / _ \/ __| |/ / '_ \ / _ \ \/ / _ \/ __|
#  | (__| | | |  __/ (__|   <| |_) | (_) >  <  __/\__ \
#   \___|_| |_|\___|\___|_|\_\_.__/ \___/_/\_\___||___/
_draw_checkboxes() {
	{ # validate and set variables
		local checkboxes_key=${1}_checkboxes
		local checkbox_order_key=${1}_checkbox_order
		local checkboxes_checked_key=${1}_checkboxes_checked
		local intro_text="${(P)$(echo ${1}_checkboxes_intro_text):-no text defined}"
		local title="${(P)$(echo ${1}_checkboxes_title):-no title defined}"
		local checkboxes_behavior=${(P)$(echo ${1}_checkboxes_behavior):-checkbox}

		# overwrite default button definitons if there is a definition for this $1 name
		if [ ${(P)#$(echo ${1}_checkboxes_buttons)[@]} -gt 0 ]; then
			local checkboxes_buttons_key=${1}_checkboxes_buttons
			local checkboxes_buttons_order_key=${1}_checkboxes_buttons_order
			local checkboxes_buttons_active_key=${1}_checkboxes_buttons_active
		else
			local checkboxes_buttons_key=checkboxes_buttons
			local checkboxes_buttons_order_key=checkboxes_buttons_order
			local checkboxes_buttons_active_key=checkboxes_buttons_active
		fi

		let ${checkboxes_buttons_active_key}=1

		# validate needed variables
		local errors=""
		
		typeset -a allowed_checkboxes_behaviors=( "checkbox" "radio" )
		if [ "$allowed_checkboxes_behaviors[(r)$checkboxes_behavior]" != "$checkboxes_behavior" ]; then
			errors+="-> The variable {1}_checkboxes_behavior is set to unknown value '${checkboxes_behavior}'."
			errors+="   Allowed: ${allowed_checkboxes_behaviors}"
			errors+=$'\n'
		fi

		if [ "${(t)${(P)checkboxes_buttons_key}}" != "association" ]; then
			errors+="-> The variable ${checkboxes_buttons_key} is not set or no associative array."
			errors+=$'\n'
		fi

		if [ "${(t)${(P)checkboxes_buttons_order_key}}" != "array" ]; then
			errors+="-> The variable ${checkboxes_buttons_order_key} is not set or no array."
			errors+=$'\n'
		fi

		if [ "${(t)${(P)$(echo ${1}_checkboxes)}}" != "association" ]; then
			errors+="-> The variable ${1}_checkboxes is not set or no associative array."
			errors+=$'\n'
		fi

		if [ "${(t)${(P)$(echo ${1}_checkbox_order)}}" != "array" ]; then
			errors+="-> The variable ${1}_checkbox_order is not set or no array."
			errors+=$'\n'
		fi

		if [ "${(t)${(P)$(echo ${1}_checkboxes_checked)}}" != "array" ]; then
			errors+="-> The variable ${1}_checkboxes_checked is not set or no array."
			errors+=$'\n'
		fi
		
		# only compare arrays if these are surely set
		if [[ ${#errors} -eq 0 \
			&& ${#${(P)$(echo ${1}_checkbox_order)}} -ne ${#${(P)$(echo ${1}_checkboxes)}} ]]; then
			errors+="$(cat <<-EOF
			The element count of ${checkbox_order_key} (${#${(P)checkbox_order_key}[@]}) and ${checkboxes_key} (${#${(P)checkboxes_key}[@]}) is not equal."
			 
			${checkbox_order_key}:
			${(r:$(( ${#checkbox_order_key} +1 ))::=:)${}}
			   ${"${(P)checkbox_order_key}"// /\n   }
			 
			${checkboxes_key}:
			${(r:$(( ${#checkboxes_key} +1 ))::=:)${}}
			   keys:
			   -----
			   ${(k)"${(P)checkboxes_key}"// /\n   }
			 
			   values:
			   -------
			$(printf '   %s\n' ${(v)${(P)checkboxes_key[@]}[@]})
			 
			 
			Make sure that these have a matching number of elements."
			EOF
			)"
			#${(r:${#${(P)checkbox_order_key}[@]}::=:)${}
		fi

		if [ "${(t)${(P)$(echo ${1}_checkbox_active)}}" != "integer" ]; then
			typeset -i $(echo ${1}_checkbox_active)
			eval $(echo ${1}_checkbox_active)=1
		fi

		if [ ${#errors} -gt 0 ]; then
			local error_intro="Errors occured while trying to generate the checkbox dialog '${1}':"
			error_intro+=$'\n'
			error_msg "${error_intro}$( echo $errors )"
			return
		fi
	}

	if [ "$checkboxes_behavior" = "radio" ]; then
		local checkbox_checked_chars=${radio_checked_chars}
		local checkbox_unchecked_chars=${radio_unchecked_chars}
	fi

	# height of the textarea above the checkboxes
	local checkboxes_text_height=3
	# height of the button window.
	local checkboxes_buttons_height=1

	# main checkboxes window
	zcurses addwin checkboxes \
		$max_window_size[height] $max_window_size[width] \
		$stdscr_position[offset_y] $stdscr_position[offset_x] \
		stdscr
	_set_position_array checkboxes border

	# control buttons for the checkboxes
	zcurses addwin checkboxes_buttons \
		1 \
		$checkboxes_position[width] \
		$(( $checkboxes_position[height] + $checkboxes_position[stdscr_offset_y] - $checkboxes_buttons_height )) \
		$checkboxes_position[stdscr_offset_x] \
		checkboxes
	_set_position_array checkboxes_buttons

	# the checkboxes window
	zcurses addwin checkboxes_checkboxes \
		$(( $checkboxes_position[height] -$checkboxes_buttons_position[height] - $checkboxes_text_height )) \
		${checkboxes_position[width]} \
		$(( $checkboxes_position[stdscr_offset_y] + $checkboxes_text_height )) \
		$checkboxes_position[stdscr_offset_x] \
		checkboxes
	_set_position_array checkboxes_checkboxes border

	# cleanup windows on exit
	trap '
	zcurses clear checkboxes_buttons;
	zcurses clear checkboxes_checkboxes;
	zcurses clear checkboxes;
	zcurses delwin checkboxes_buttons;
	zcurses delwin checkboxes_checkboxes;
	zcurses delwin checkboxes;
	' EXIT

	while true; do
		zcurses clear checkboxes
		zcurses clear checkboxes_checkboxes
		zcurses border checkboxes
		zcurses border checkboxes_checkboxes
		zcurses bg checkboxes $default_fg/$default_bg

		# buttons
		if [ ${(P)#$(echo ${1}_checkboxes_buttons)[@]} -gt 0 ]; then
			# if there is a definition for this checkboxes name ...
			_draw_buttons checkboxes_buttons ${1}_checkboxes_buttons
		else
			# ... else just use the default buttons for the checkboxes widget
			_draw_buttons checkboxes_buttons
		fi

		# set window title
		zcurses move checkboxes 0 1
		zcurses string checkboxes "[${title}]"

		# set intro text.
		(( i = 1 ))
		local tmp=( ${(@f)intro_text} )
		for row in $tmp; do
			while [ ${#row} -gt 0 ]; do
				zcurses move checkboxes $i 1
				if [ $checkboxes_position[width] -lt ${#row} ]; then
					debug_msg "INFO: Text row is too long, wrapping. ${#row} (max=$checkboxes_position[width])"
					zcurses string checkboxes "${row[1,$(( $checkboxes_position[width] - $checkboxes_position[offset_x] ))]}"
					row="${${row[$checkboxes_position[width],${#row}]}## }"
				else
					zcurses string checkboxes "$row"
					row=""
				fi
				(( i = i +1 ))
			done
		done

		# handle scroll offset and set index for first checkbox
		local scroll_offset=0
		if [ ${(P)$(echo ${1}_checkbox_active)} -gt $checkboxes_checkboxes_position[height] ]; then
			scroll_offset=$(( $scroll_offset + ( ${(P)$(echo ${1}_checkbox_active)} - $checkboxes_checkboxes_position[height] ) ))

			# add scroll up indicator if there are checkboxes above the visible area
			zcurses move checkboxes_checkboxes \
				1 $(( $checkboxes_checkboxes_position[width] + $checkboxes_checkboxes_position[offset_x] ))
			zcurses bg checkboxes_checkboxes $scroll_indicator_fg/$scroll_indicator_bg
			zcurses string checkboxes_checkboxes "$scroll_up_indicator_char"
			zcurses bg checkboxes_checkboxes $default_fg/$default_bg
		fi

		debug_msg "Checkbox Value:     ${${(P)checkbox_order_key}[${(P)$(echo ${1}_checkbox_active)}]}"
		debug_msg "Checkboxes Checked: ${(P)checkboxes_checked_key[@]}"

		# set index number of first checkbox to display
		local index=$(( $scroll_offset +1 ))

		# draw checkboxes
		i=1
		for ((; index <= ${(P)#checkbox_order_key[@]}; ++index)); do
			zcurses move checkboxes_checkboxes $i 1
			# highlight active checkbox
			if [ $index -eq ${(P)$(echo ${1}_checkbox_active)} ]; then
				zcurses attr checkboxes_checkboxes $row_active_fg/$row_active_bg
			fi
			# draw the checkbox
			if [ "${${(P)checkboxes_checked_key}[(r)${${(P)checkbox_order_key}[${index}]}]}" = "${${(P)checkbox_order_key}[${index}]}" ]; then
				zcurses string checkboxes_checkboxes "${checkbox_checked_chars}"
			else
				zcurses string checkboxes_checkboxes "${checkbox_unchecked_chars}"
			fi
			# append a space after the checkbox
			zcurses string checkboxes_checkboxes " "
			# append the text and pad right with spaces to fill the line
			zcurses string checkboxes_checkboxes \
				"${(r:${$(($checkboxes_checkboxes_position[width] - ${#checkbox_checked_chars} - ${checkboxes_checkboxes_position[offset_x]} ))}:: :)${(P)checkboxes_key}[${${(P)checkbox_order_key}[${index}]}]}"

			# set default colors
			zcurses attr checkboxes_checkboxes $default_fg/$default_bg

			# abort after the last checkbox
			if [ $index -ge ${(P)#checkbox_order_key[@]} ]; then
				# all checkboxes have been printed
				break
			fi

			# add scroll down indicator if there are more checkboxes below
			if [ $i -ge $checkboxes_checkboxes_position[height] ]; then
				# add scroll down
				zcurses move checkboxes_checkboxes \
					$checkboxes_checkboxes_position[height] \
					$(( $checkboxes_checkboxes_position[width] + $checkboxes_checkboxes_position[offset_x] ))
				zcurses bg checkboxes_checkboxes $scroll_indicator_fg/$scroll_indicator_bg
				zcurses string checkboxes_checkboxes "$scroll_down_indicator_char"
				zcurses bg checkboxes_checkboxes $default_fg/$default_bg
				break
			fi
			(( i = i +1 ))
		done

		# draw checkboxes window
		zcurses refresh checkboxes

		# wait for user input
		zcurses input stdscr raw key mouse
		# parses the input event into the global array input_event
		_parse_input_event "$raw" "$key" "$mouse"

		# handle input events for the button box
		_handle_button_event $checkboxes_buttons_key

		case $input_event[key] in
			q)
				# TODO: handle gobally
				return 1
				;;
			CR)
				local button_value=${${(P)${(P)$(echo checkboxes_buttons_order_key)}[@]}[${(P)$(echo $checkboxes_buttons_active_key)}]}

				_set_button_function_name "checkboxes" "$1" "$button_value"
				if [ "$button_function" != "" ]; then
					$button_function && {
						local retval=$?
					} || {
						local retval=$?
					}
					[ $retval -ne 100 ] && return $retval
				else
					# if there is no button_function defined we continue
					# because _set_button_function_name has already shown an error_msg
					continue
				fi
				;;
			PRESSED4|UP)
				if [ ${(P)$(echo ${1}_checkbox_active)} -gt 1 ]; then
					let ${1}_checkbox_active=$(( ${1}_checkbox_active -1 ))
				fi
				;;
			PRESSED5|DOWN)
				if [ ${(P)$(echo ${1}_checkbox_active)} -lt ${(P)#checkbox_order_key[@]} ]; then
					let ${1}_checkbox_active=$(( ${1}_checkbox_active +1 ))
				fi
				;;
			PPAGE)
				if [ ${(P)$(echo ${1}_checkbox_active)} -gt 5 ]; then
					let ${1}_checkbox_active=$(( ${(P)$(echo ${1}_checkbox_active)} -5 ))
				else
					let ${1}_checkbox_active=1
				fi
				;;
			NPAGE)
				if [ ${(P)$(echo ${1}_checkbox_active)} -le ${(P)#checkbox_order_key[@]} ]; then
					let ${1}_checkbox_active=$(( ${(P)$(echo ${1}_checkbox_active)} +5 ))

					if [ ${(P)#checkbox_order_key[@]} -le ${(P)$(echo ${1}_checkbox_active)} ]; then
						let ${1}_checkbox_active=${(P)#checkbox_order_key[@]}
					fi
				fi
				;;
			" ")
				# check or uncheck checkbox
				local checkbox_active_key=${${(P)checkbox_order_key}[${1}_checkbox_active]}
				if [ "$checkboxes_behavior" = "radio" ]; then
					# if the behavior type is radio we can only have one checked field
					eval "${1}_checkboxes_checked=( $checkbox_active_key )"
				else # checkboxes_behavior = checkbox
					if [ "${${(P)checkboxes_checked_key}[(r)${checkbox_active_key}]}" = "$checkbox_active_key" ]; then

						eval "${1}_checkboxes_checked=( ${(@)${(P)checkboxes_checked_key}:#$checkbox_active_key} )"
					else
						eval "${1}_checkboxes_checked=( ${(P)checkboxes_checked_key} $checkbox_active_key )"
					fi

					# scroll down after toggle
					if [ ${(P)$(echo ${1}_checkbox_active)} -lt ${(P)#checkbox_order_key[@]} ]; then
						let ${1}_checkbox_active=$(( ${1}_checkbox_active +1 ))
					fi
				fi
				;;
		esac
	done
}

#   _        _ _ _
#  | |_ __ _(_) | |__   _____  __
#  | __/ _` | | | '_ \ / _ \ \/ /
#  | || (_| | | | |_) | (_) >  <
#   \__\__,_|_|_|_.__/ \___/_/\_\
# expects a named pipe (see mkfifo) as $1
# and will tail the pipe until it ends
_draw_tailbox() {
	if [ ! -p "$1" ]; then
		echo "ERROR: '$1' is not a named pipe" 1>&2
		false
	fi
	# add tailbox window
	zcurses addwin tailbox \
		$max_window_size[height] $max_window_size[width] \
		$stdscr_position[offset_y] $stdscr_position[offset_x] \
		stdscr
	_set_position_array tailbox border

	# cleanup windows on exit
	trap '
	zcurses clear tailbox;
	zcurses delwin tailbox;
	' EXIT

	#trap 'exit 1' TERM INT
	
	zcurses clear tailbox
	zcurses bg tailbox $default_fg/$default_bg
	zcurses border tailbox

	zcurses move tailbox \
		$(( $tailbox_position[height] -1 )) \
		${tailbox_position[offset_x]}
	zcurses attr tailbox standout
	zcurses string tailbox "Waiting for output from named pipe '$1'."
	zcurses attr tailbox -standout
	zcurses refresh tailbox

	while read row; do
		# overwrite the bottom border so it won't bleed into the previous msg
		zcurses move tailbox $(( $tailbox_position[height] +1 )) 0
		zcurses string tailbox "${(r:${$(( $tailbox_position[width] + $tailbox_position[offset_x] ))}:: :)${}}"
		while [ ${#row} -gt 0 ]; do
			zcurses scroll tailbox +1
			zcurses move tailbox \
				$tailbox_position[height] \
				${tailbox_position[offset_x]}
			if [ $tailbox_position[width] -lt ${#row} ]; then
				debug_msg "INFO: Text row is too long, wrapping. ${#row} (max=$tailbox_position[width])"
				zcurses string tailbox "${row[1,$(( $tailbox_position[width] - $tailbox_position[offset_x] ))]}"
				row="${${row[$tailbox_position[width],${#row}]}## }"
			else
				zcurses string tailbox "$row"
				row=""
			fi
		done
		zcurses border tailbox
		# set window title
		zcurses move tailbox 0 1
		zcurses string tailbox "[${2:-title not set}]"
		
		zcurses refresh tailbox
		sleep .001
	done <"$1"

	# overwrite the bottom border so it won't bleed into the previous msg
	zcurses move tailbox $(( $tailbox_position[height] +1 )) 0
	zcurses string tailbox "${(r:${$(( $tailbox_position[width] + $tailbox_position[offset_x] ))}:: :)${}}"

	zcurses scroll tailbox +2
	zcurses border tailbox
		
	zcurses move tailbox \
		$tailbox_position[height] \
		${tailbox_position[offset_x]}
	zcurses attr tailbox standout
	zcurses string tailbox "Pipe '$1' has ended. Press any key to close this dialog."
	zcurses refresh tailbox
	zcurses attr tailbox -standout

	# wait for user input and close the tailbox
	# if any key is pressed.
	while true; do
		zcurses input stdscr raw key mouse
		# ignore mouse events
		[ "$mouse" = "" ] && break
	done
}

# _run_editor $file [$line]
_run_editor() {
	editor=${EDITOR:-nano}
	if (( $+commands[$editor] )); then
		[ "$#" -eq 1 ] && {
			"$editor" "$1"
		} || {
			"$editor" "+$2" "$1"
		}
	else
		error_msg "Could not launch $editor, because it is not in the path."
	fi
	# this will redraw all windows after beeing
	# messed up by something that wrote to stdout
	_draw_stdscr 
}

#   _       _ _   _       _ _
#  (_)_ __ (_) |_(_) __ _| (_)_______
#  | | '_ \| | __| |/ _` | | |_  / _ \
#  | | | | | | |_| | (_| | | |/ /  __/
#  |_|_| |_|_|\__|_|\__,_|_|_/___\___|
zmodload zsh/curses
zcurses init

#                              _                     _ _ _
#    ___ _ __ _ __ ___  _ __  | |__   __ _ _ __   __| | (_)_ __   __ _
#   / _ \ '__| '__/ _ \| '__| | '_ \ / _` | '_ \ / _` | | | '_ \ / _` |
#  |  __/ |  | | | (_) | |    | | | | (_| | | | | (_| | | | | | | (_| |
#   \___|_|  |_|  \___/|_|    |_| |_|\__,_|_| |_|\__,_|_|_|_| |_|\__, |
#                                                                |___/
# set traps to auto cleanup and display errors
has_err=false
error_log_file=$(mktemp -t bzcurses.error_log.$$.XXXXX)
err_trap() {
	{
		echo "============================================"
		echo "Error in file $funcfiletrace[1] ($functrace[1])":
		echo "$(cat $stderr_file && echo >$stderr_file)"
		echo ""
		echo "TRACE:"
		echo "------"
		for ((index=1; index <= ${#funcfiletrace[@]}; ++index)); do
			echo "${funcfiletrace[index]} -> ${functrace[index]}"
		done | column -t
		echo "--------------------------------------------"
		echo ""
	} >> $error_log_file
	has_err=true
	kill -INT $$
}


exit_trap() {
	trap - EXIT INT
	test -f $error_log_file && cat $error_log_file

	test -f $stderr_file && rm -f $stderr_file
	test -f $error_log_file && rm -f $error_log_file

}
trap 'err_trap "$0" "$LINENO";'       ERR ZERR
trap 'zcurses end; reset; exit_trap;' EXIT INT

#   _   _
#  | |_| |__   ___ _ __ ___   ___
#  | __| '_ \ / _ \ '_ ` _ \ / _ \
#  | |_| | | |  __/ | | | | |  __/
#   \__|_| |_|\___|_| |_| |_|\___|
if [[ "${theme:-undefined}" = "undefined" && $+commands[fc-list] -gt 0 ]]; then
	# try to detect wether nerdfonts are installed or not
	# and if they are installed use the nerdfonts theme 
	# as default theme because we assume that who has them
	# installed is also using them.
	fc-list | grep -i "nerdfonts" >/dev/null && {
		theme="nerdfonts"
	} || {
		theme="default"
	}
elif [ "${theme:-undefined}" = "undefined" ]; then
	theme="default"
fi

# the default theme is defined in the head of this file
# themes will overwrite the default theme variables
if [ "$theme" != "default" ]; then
	theme_path="${0:h}/bzcurses.${theme}.theme.zsh"
	test -f "$theme_path" && {
		. "$theme_path"
	} || {
		echo "ERROR: theme not found '${theme_path}'" 1>&2
		false
	}
fi

#   _                      _             _
#  | |_ ___ _ __ _ __ ___ (_)_ __   __ _| |
#  | __/ _ \ '__| '_ ` _ \| | '_ \ / _` | |
#  | ||  __/ |  | | | | | | | | | | (_| | |
#   \__\___|_|  |_| |_| |_|_|_| |_|\__,_|_|
#                                   _
#    __ _  ___  ___  _ __ ___   ___| |_ _ __ _   _
#   / _` |/ _ \/ _ \| '_ ` _ \ / _ \ __| '__| | | |
#  | (_| |  __/ (_) | | | | | |  __/ |_| |  | |_| |
#   \__, |\___|\___/|_| |_| |_|\___|\__|_|   \__, |
#   |___/                                    |___/
_calculate_terminal_space() {
	if [[ $LINES -lt 24 || $COLUMNS -lt 80 ]]; then
		echo "ERROR, your terminal is to small." 1>&2
		echo "Expected at least 80x24, got: ${COLUMNS}x${LINES}" 1>&2
		false # trigger ERR trap
	fi

	typeset -g height=$LINES
	typeset -g width=$COLUMNS

	if [[ $debug = true ]]; then
		if [ $(( $height - 20 )) -lt 24 ]; then
			height=24
		else
			height=$(( $LINES -20 ))
		fi
		if [ $(( $LINES - $height )) -lt 4 ]; then
			echo "ERROR, your terminal is to small for debug mode." 1>&2
			echo "Expected at least 80x24+4, got: ${COLUMNS}x${LINES}" 1>&2
			false # trigger ERR trap
		fi
	fi
}
_calculate_terminal_space

#       _      _                            _           _
#    __| | ___| |__  _   _  __ _  __      _(_)_ __   __| | _____      __
#   / _` |/ _ \ '_ \| | | |/ _` | \ \ /\ / / | '_ \ / _` |/ _ \ \ /\ / /
#  | (_| |  __/ |_) | |_| | (_| |  \ V  V /| | | | | (_| | (_) \ V  V /
#   \__,_|\___|_.__/ \__,_|\__, |   \_/\_/ |_|_| |_|\__,_|\___/ \_/\_/
#                          |___/
if [ $debug = true ]; then
	zcurses addwin debug \
		$(( $LINES - $height )) $(( $COLUMNS -2 )) \
		$height 1 \
		stdscr

	typeset -A debug_size
	debug_size=(
		height $(( $LINES - $height -1 ))
		width  $(( $COLUMNS -2 ))
	)

	debug_msg "debug mode active"
else
	# overwrite function
	debug_msg() {}
fi

# set the postion array for stdscr so we know
# the size of our terminal
_set_position_array stdscr border

# the maximum size should leave a one char gap around
# the maximum sized window plus one line for the titlebar
typeset -A max_window_size
max_window_size=(
	height $(( $height -2 ))
	width  $(( $width -2 ))
)

#       _      _                 _   _ _   _                        _
#   ___| |_ __| |___  ___ _ __  | |_(_) |_| | ___    __ _ _ __   __| |
#  / __| __/ _` / __|/ __| '__| | __| | __| |/ _ \  / _` | '_ \ / _` |
#  \__ \ || (_| \__ \ (__| |    | |_| | |_| |  __/ | (_| | | | | (_| |
#  |___/\__\__,_|___/\___|_|     \__|_|\__|_|\___|  \__,_|_| |_|\__,_|
#   _                   _
#  | |__   ___  _ __ __| | ___ _ __
#  | '_ \ / _ \| '__/ _` |/ _ \ '__|
#  | |_) | (_) | | | (_| |  __/ |
#  |_.__/ \___/|_|  \__,_|\___|_|
_draw_stdscr() {
	zcurses clear stdscr redraw
	zcurses move stdscr 0 0
	zcurses attr stdscr bold
	zcurses string stdscr "[${title_stdscr}]"
	zcurses attr stdscr -bold
	zcurses refresh stdscr
}
_draw_stdscr
