#include "main.h"

int 
run_shell(cmd)

char *cmd;

/***************************************************************************/
/* this is the x version of run_shell, hope and pray that it is simpler    */
/***************************************************************************/

{
	char	x_cmd[200];
	int	sts;

#ifdef __clipper__
	sprintf(x_cmd, "/usr/bin/X11/xterm -T \"vprod\" -s -geometry 80x24+572+511 -e %s/runit.sh \"%s\"", MYSTUFFDIR, cmd);
#else
	sprintf(x_cmd, "/usr/openwin/bin/xview/shelltool -Wl \"vprod\" %s/runit.sh \"%s\"", MYSTUFFDIR, cmd);
#endif
	sts = system(x_cmd);
	return(sts >> 8);
}

