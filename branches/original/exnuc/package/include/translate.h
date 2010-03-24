/*
**	This struct is used to translate build name into
**	pertinent build info.
*/

static struct
{
	char	*name;		/* Build name. */
	int	rt;		/* TRUE iff this build is a runtime variant. */
	int	dp;		/* TRUE iff this build is a development platform variant. */
	char	*owner;		/* Argument for chown commands. */
	char	*group;		/* Argument for chgrp commands. */
}	Build[] = 
{
{"EXNUC",	1, 0, "sys", "bin"},
{"EXNUCDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{"EXNUCX",	1, 0, "sys", "bin"},
{"EXNUCXDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{"c1EXNUC",	1, 0, "sys", "bin"},
{"c1EXNUCDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{"c1EXNUCX",	1, 0, "sys", "bin"},
{"c1EXNUCXDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{"s4EXNUC",	1, 0, "sys", "bin"},
{"s4EXNUCDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{"c4EXNUC",	1, 0, "sys", "bin"},
{"c4EXNUCDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{"c4EXNUCX",	1, 0, "sys", "bin"},
{"c4EXNUCXDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{"m4EXNUC",	1, 0, "sys", "bin"},
{"m4EXNUCDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{"m5EXNUC",	1, 0, "sys", "bin"},
{"m5EXNUCDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{"s5EXNUC",	1, 0, "sys", "bin"},
{"s5EXNUCDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{"s6EXNUC",	1, 0, "sys", "bin"},
{"s6EXNUCDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{"i5EXNUC",	1, 0, "sys", "bin"},
{"i5EXNUCDP",	0, 1, "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f3`\"", "\"`egrep \\\"^$LOGNAME:\\\" < /etc/passwd | cut -d: -f4`\""},
{0},
};


/*
**	This struct is used to translate cpio filenames into
**	directory paths.  These are the base directories from
**	which files are gathered for cpio.  If the dirname begins
**	with '$', it is treated as an evironment variable and
**	expanded.
*/

static struct
{
	char	*name;	/* Cpio package name. */
	char	*dir;	/* Base directory name. */
} Cpio[] =
{
	{"archlib",	"$TARGET"},
	{"bin",		"$TARGET"},
	{"binopt",	"$TARGET"},
	{"binsrc",	"$EXNUC"},
	{"binoptsrc",	"$EXNUC"},
	{"cfggen",	"$TARGET"},
	{"clixdoc",	"$EXNUC"},
	{"clixspec",	"$EXNUC"},
	{"config",	"$EXNUC"},
	{"dir",		"$EXNUC"},
	{"doc",		"$EXNUC"},
	{"exprod",	"$TARGET"},
	{"exnuc",	"$TARGET"},
	{"inc",		"$EXNUC"},
	{"incppl",	"$EXNUC"},
	{"incsun",	"$EXNUC"},
	{"lib",		"$TARGET"},
	{"libom",	"$TARGET"},
	{"msgsrc",	"$EXNUC"},
	{"shlib",	"$TARGET"},
	{"spec",	"$EXNUC"},
	{0}
};
