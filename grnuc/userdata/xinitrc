# .xinitrc - OpenWindows system startup script.

if [ "$WindowManager" = "mwm" ]
then
#$OPENWINHOME/bin/reservecolors < .ems_reserve
	$OPENWINHOME/lib/openwin-sys 	# OpenWindows system initialization

	# Read the defaults file into the server
	xrdb $HOME/.Xdefaults

	# start a console
	xterm -C -T console -l -geometry 80x10+0+0 -bg black -fg white >/dev/console 2>&1 &

	mwm >/dev/console 2>&1
fi
