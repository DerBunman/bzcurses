# bzcurses

*bzcurses* is a zsh library based on zshmod/curses to display ncurses dialogs like the famous [dialog package](https://invisible-island.net/dialog/).
The main difference is, that bzcurses is a native zsh script so you can write zsh scripts with it way more comfortable.

## State

Work in progress. Everything may change but I'll try to keep everything compatible.

### Features

* dialogs
	* checkboxes dialog
	* choices dialog (a menu)
	* textbox (to display text)
	* error messages
* debug mode toggleable via debug=true
* scales to terminal size (only on startup)
* themes (colors, pre/postfixes, icons)
* incomplete mouse input:
	* scrolling works
* no dependencies beyond zsh

### TODO

* handle terminal resize somehow
* add function to validate all the dialog definitions
* handle mouse clicks
* dialogs
	* dialogs I consider adding:
		* file select
		* datetime select
		* tailbox
		* text input
		* forms
		* ...
	* needed tweaks for dialogs:
		* choices & checkboxes
			* dynamicly resize intro text height
* documentation (for now look at the [examples](examples/))
* cleanup code

## Screnshots
![screenshot1](screenshots/screenshot.example.zsh.main.choices.with.debugmode.jpg)

![screenshot2](screenshots/screenshot.example.zsh.checkboxes.with.debugmode.jpg)

