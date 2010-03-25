#include	<stdlib.h>
#include	<stdio.h>
#include	"defs.h"

extern char	connstr[STRSIZ];
extern char	*strchr();

/*
 * This routine will display the prompt given in parm "prompt" on
 * stderr. It will continue to display the message until a character
 * other than newline is typed.
 */
void	display_prompt(prompt)
char	*prompt;
{
	register int	c;

	do {
		PRINT "%s", prompt);
		c = getc(stdin);
	} while (c == '\n');
	ungetc(c, stdin);
}

/*
 * This routine will prompt for a network address or logical
 * name. If a username/password is not keyed in, it is prompted
 * for. The connection string is placed into the global "connstr".
 */
void	get_node_name()
{
	register int	c;

	c = getc(stdin);
	if (c == '\n')
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
		display_prompt("Key in network connect nodename or address (XXX.XXX.XXX.XXX for TCP/IP, \n\tor 08-00-36-XX-XX-XX for XNS) ---> ");
#else
		display_prompt("Key in network connect nodename or address\n\t(XXX.XXX.XXX.XXX) ---> ");
#endif
	else
		ungetc(c, stdin);

	gets(connstr);
}

/*
 * This routine will prompt for a directory path (used for the -D option).
 */
void	get_local_dir()
{
	register int	c;
	extern char	localdir[STRSIZ];

	c = getc(stdin);
	if (c == '\n')
		display_prompt("Key in local directory ---> ");
	else
		ungetc(c, stdin);

	gets(localdir);
}

/*
 * This routine prompts for source of installation, which, at present,
 * is either FLOPPY or VAX. The returned value is the source media.
 */
int	get_src_media()
{
	register int	c, d;		/*Holds the user response to prompts*/

	for (;;) {
		display_prompt(
"Key in source of installation: n)etwork, f)loppy, t)ape, D)isk,\n\tr)emote CD/ROM or local C)D/ROM ---> ");
		c = getc(stdin);

		/* skip first word */
		do {
			d = getc(stdin);
		} while (d != ' ' && d != '\t' && d != '\n');
		/* skip white space, but leave the newline in the input buffer*/
		while (d == ' ' || d == '\t')
			d = getc(stdin);

		ungetc(d, stdin);

		switch (c) {
		case 'f':
		case 'F':
#ifdef SunOS_4
			getc(stdin);
#endif
			return(FLOPPY);
		case 'c':
		case 'C':
#ifdef SunOS_4
			getc(stdin);
#endif
			return(CDROM);
		case 't':
		case 'T':
#ifdef SunOS_4
			getc(stdin);
#endif
			return(TAPE);
		case 'n':
		case 'N':
			get_node_name();
			return(NETWORK);
		case 'r':
		case 'R':
			get_node_name();
			return(NETCDROM);
		case 'd':
		case 'D':
			get_local_dir();
			return(DIRECTORY);
		case 'q':
		case 'Q':
#ifdef SunOS_4
			getc(stdin);
#endif
			exit(0);
		case '!':
#ifdef SunOS_4
			getc(stdin);
#endif
			shellcmd();
			break;
		}
	}
}
