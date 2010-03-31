
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

#include <sys/signal.h>

static int	igestop;
static int	stopproc = -1;

extern  int	IGEsetstop();

extern char *getenv();

IGEstopinit()
{

	int pid,status,parent_id;
	char *argv[4];
/*
	removed *env[] 
	changed for porting - GVK prasad.
	char *argv[4], *env[];
*/
	char parent_string_id[100], *string[50], string1[50], string2[50];

	int IGEkillstop();

/*  Set up IGEsetstop to be called when SIGUSR1 is sent to the IGE process */

	signal(SIGUSR1,IGEsetstop);
	signal(SIGILL,IGEkillstop);
	signal(SIGEMT,IGEkillstop);
	signal(SIGBUS,IGEkillstop);
	signal(SIGSEGV,IGEkillstop);

	/* Setup path to grstoproc and symbol file for stop sign */

	parent_id = getpid();
	if (!(pid = fork()))
	{
	   GetDirectory( "Grnuc", string, 0 );
	   if( !string[0] ) exit(1);
	   argv[0] = string1;
	   sprintf( argv[0], "%s/bin/grstoproc", string );

/*	   argv[0]="grstoproc"; */
	   sprintf(parent_string_id,"%d",parent_id);
	   argv[1] = parent_string_id;

	   GetDirectory( "Grnuc", string, 1 );
	   if( !string[0] ) exit(1);
	   argv[2] = string2;
	   sprintf( argv[2], "%s/icons/", string );
/*	   argv[2] = "./sym/"; */

	   argv[3] = (char *)0;
	   execv( argv[0], argv );
	}
	else
	{
	  stopproc = pid;
	}

wrapup:
	return(1);

}


/* resets the stop variable  */

void	IGEresetstop()
{
   igestop = 0;
}

/* returns the current state of the stop variable   */

int	IGEstop()
{
   return(igestop);
}

/* This is the routine that sets the igestop variable when an SIGUSR1
   interrupt is detected						*/

int IGEsetstop()
{
   signal(SIGUSR1,IGEsetstop);
   igestop = 1;
   return(1);
}

int IGEkillstop()
{
	if (stopproc != -1)
	{
	  kill(stopproc,SIGKILL);
	  stopproc = -1;
	}
}
