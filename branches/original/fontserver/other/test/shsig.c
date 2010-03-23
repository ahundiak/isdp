/* This program tests the signal-vulnerability of the Font Server.	*/
/* The shshowsig program, which creates a shared font and displays it,	*/
/* is executed and, after a few seconds, the SIGUSR1 signal, which	*/
/* shshowsig should catch, is rapidly sent to it.  If all goes well,	*/
/* shshowsig and the daemon should not crash.  See shshowsig.c.		*/
/* Simply run this program and watch.					*/


#include <stdio.h>
#include <signal.h>


static int	status;


Death ()
{
    wait (&status);
}


main ()
{
    int	pid;

    sigset (SIGCLD, Death);

    pid = vfork ();
    if (pid == 0)
    {
	execl ("shshowsig", "shshowsig", "1", (char *) 0);
	printf ("Can't exec kid!\n");
	exit (1);
    }
    else if (pid > 0)
    {
	sleep (5);	/* give my kid time to start up */
	while (kill (pid, SIGUSR1) == 0);

	if ((status & 0xFF) == 0x7F)	/* kid stopped */
	{
		printf ("Kid stopped due to signal: %d\n",
			(status & 0xFF00) >> 8);
	}
	else if ((status & 0xFF) == 0)	/* normal termination */
	{
		printf ("Normal termination: %d\n", (status & 0xFF00) >> 8);
	}
	else	/* terminated by a signal */
	{
		printf ("Kid terminated by signal: %d\n", status & 0x7F);
		if (status & 0x80)
			printf ("Core dumped\n");
	}

	exit (0);
    }
    else
    {
	printf ("Fork failed!\n");
	exit (1);
    }
}
