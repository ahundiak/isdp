#include	<stdlib.h>
#include	<stdio.h>
#include	"defs.h"

/*
 * This routine is called to execute a shell command without exiting
 * newprod. It accepts as input a string, creates a subprocess
 * and performs an "exec sh -c <string>" to execute the shell
 * command.
 */
void	shellcmd()
{
	char	buffer[STRSIZ];	/*receive command line here if "cmd" NULL*/
	int	rstat;		/*return status from system calls*/
	extern char	*shell;

	for (;;) {
		PRINT "\nCommand line> ");
		if (!fgets(buffer, STRSIZ, stdin)) {
			PRINT "\n");
			clearerr(stdin);
			break;
		}
		if (buffer[0] == '\n')
			break;
		if ((rstat = fork()) != -1)
			if (!rstat) {	/*in the child*/
				if ((rstat = execl(shell, shell, "-c",
				    buffer, 0)) == -1) {
					PRINT "Error creating shell.\n");
					_exit(-1);
				}
			} else 
				wait((int *) 0); /*wait on cmd to complete*/
		else
			PRINT "Error in fork for cmd %s.\n", buffer);
	}
}
