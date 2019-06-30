#             _
#    ___ ___ | | ___  _ __ ___
#   / __/ _ \| |/ _ \| '__/ __|
#  | (_| (_) | | (_) | |  \__ \
#   \___\___/|_|\___/|_|  |___/
default_fg="black"
default_bg="cyan"

error_fg="white"
error_bg="red"

scroll_indicator_fg="white"
scroll_indicator_bg="black"

row_active_fg="black"
row_active_bg="white"

button_active_fg="black"
button_active_bg="white"
button_inactive_fg="magenta"
button_inactive_bg="blue"

button_active_prefix=" "
button_active_postfix="  "
button_inactive_prefix=" "
button_inactive_postfix="  "

#         _             _
#    __ _| |_   _ _ __ | |__  ___
#   / _` | | | | | '_ \| '_ \/ __|
#  | (_| | | |_| | |_) | | | \__ \
#   \__, |_|\__, | .__/|_| |_|___/
#   |___/   |___/|_|
checkbox_checked_chars=" "
checkbox_unchecked_chars=" "

radio_checked_chars=" "
radio_unchecked_chars=" "

scroll_up_indicator_char=""   # only 1 char allowed
scroll_down_indicator_char="" # only 1 char allowed

choices_choice_prefix=" "

# keys have to be upper case.
# they will be matched against
# the button text converted to upper case.
button_icons+=(
	"EDIT"      " "
	"EDITOR"    " "
	"BACK"      " "
	"SEARCH"    " "
	"FIND"      " "
	"SETTINGS"  " "
	"CONFIGURE" " "
	"EXIT"      " "
	"HELP"      " "
	"SELECT"    " "
	"OK"        " "
	"SAVE"      " "
	"STORE"     " "
	"PLAY"      "輸"
	"REPLAY"    "菱"
	"REFRESH"   "菱"
	"YES"       " "
	"NO"        " "
	"DELETE"    " "
	"REMOVE"    " "
	"UNDEFINED" " "
)
