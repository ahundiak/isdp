#
# NAME
#	genmenu.sh - menu generation utility
#
# SYNOPSIS
#	genmenu.sh [-v] [-p <palette prefix>] [-n] <outline>
#
# DESCRIPTION
#	Genmenu.sh creates I/FORMS panel, bar and pocket menu files for
#	MicroStation32 applications from text outlines.
#
#	If the -v option is specified, genmenu.sh prints a description
#	of the menu to standard output (stdout).
#
#	Error messages are printed to standard error (stderr).
#
#
#	The menu naming conventions required by MicroMenu are enforced
#	by genmenu.sh.  The extensions for the outline files are:
#		`.pnl' for panel menu outlines
#		`.bar' for bar menu outlines
#		`.pkt' for pocket menu outlines
#
#	The period, `.', will be replaced by an underbar, `_', in the
#	name of the menu file.  For example:
#		`ustn.bar' outline --> `ustn_bar' menu file
#
#
#	When creating a panel menu, the menu file contains only the data
#	from the first palette.  The other palettes are written to files
#	with names generated from the palette names in the outline and the
#	characters preceeding the `.pnl' in the outline name.  A palette
#	file name is the first 14 characters from:
#
#		<outline name without .pnl>_<palette name>
#
#	In the file name, characters other than letters, numbers, the
#	period, `.', and the underbar, `_' are replaced by underbars.
#
#	For example, the `Fence Manipulations' palette described in the
#	`ustn.pnl' outline is written to the `ustn_Fence_Man' palette file.
#
#
#	The -p option overrides the characters from the outline name
#	used in generating the palette file names.  The <palette prefix>
#	is used instead.
#
#	For example, if `-p MD.' is specified and the palette name in
#	md.pnl is UTILITIES, the generated palette file name is
#	`MD.UTILITIES' rather than `md_UTILITIES'.
#
#
#	The -n option suppresses using the characters from the outline
#	name when generating the palette file names.
#
#	For example, if the -n option is specified and the palette name
#	in the iras32.pnl outline is `iras32_display', the file name is
#	`iras32_display'.
#
# NOTES
#	The -n option should only be used when palette names in the
#	outline include the product name.  Palette file names must be
#	unique across products.
#

usage='usage : genmenu.sh [-v] [-n] [-p <palette prefix>] <menu outline>'
tmpfile=/usr/tmp/genmenu.tmp

verbose_opt=""
prefix_opt="-p"
prefix=""
outline=""

while test $# -gt 0
do
	case $1 in
	-v )	verbose_opt="-v"
		;;
	-n )	prefix_opt=""
		prefix=""
		;;
	-p* )	prefix_opt="-p"
		prefix=`echo $1 | cut -c3-`
		if test -z "$prefix"
		then
			shift
			prefix=$1
		fi
		;;
	-* )	echo $usage >&2
		exit 66
		;;
	* )	if test -z "$outline"
		then
			outline=$1
		else
			echo $usage >&2
			exit 66
		fi
		;;
	esac
	shift
done

if test -z "$outline"
then
	echo $usage >&2
	exit 66
elif test -r $outline
then
	menutype=`sed -n '1p' $outline | \
		  awk -F, '{ print $1 }' | \
		  awk '{ print $1 }'`

	echo $outline>$tmpfile
	menuext=`awk -F. '{ print $NF }' $tmpfile`
else
	echo $outline not found >&2
	echo $usage >&2
	exit 65
fi

if test "$menutype" = "PANEL"
then
	if test "$menuext" != "pnl"
	then
		echo .$menuext : Invalid panel outline extension.  Use .pnl >&2
		exit 64
	fi

	if test -n "$prefix_opt" -a -z "$prefix"
	then
		prefix=`basename $outline .$menuext`_
	fi
elif test "$menutype" = "BAR"
then
	if test "$menuext" != "bar"
	then
		echo .$menuext : Invalid bar outline extension.  Use .bar >&2
		exit 64
	fi

	prefix_opt=""
	prefix=""
elif test "$menutype" = "POCKET"
then
	if test "$menuext" != "pkt"
	then
		echo .$menuext : Invalid pocket outline extension.  Use .pkt >&2
		exit 64
	fi

	prefix_opt=""
	prefix=""
else
	echo $menutype : Invalid menu type defined in $outline. >&2
	echo Replace with PANEL, BAR or POCKET.
	exit 64
fi

genmenu=${MS_DIR:-`grep MS_DIR= /usr/bin/mce | cut -c9-`}/umenu/bin/genmenu
menuname=`dirname $outline`/`basename $outline .$menuext`_$menuext
$genmenu $verbose_opt $prefix_opt $prefix $outline $menuname
exit $?
