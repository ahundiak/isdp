#include	<errno.h>
#include	<stdlib.h>
#include	<stdio.h>
#include	<signal.h>
#include	<sys/types.h>
#include	<termio.h>
#include	<pwd.h>
#include	<string.h>
#include	"vtmisc.h"

char   *strcpy ();
extern char linename[];		/* terminal name as found in "/dev"	*/
extern char exec_cmd[];		/* Unix command for -x option		*/
int	exec_pid;		/* pid of exec process			*/
int	sh_retval;

/*extern struct passwd	*getpwuid ();*/

void child_death ()		/* called when child dies to gather status */
{
    int pid, status, retval;

    while (((pid = wait (&status)) != exec_pid)) {
	if (pid == -1) {
	    if (errno == EINTR)
	        continue;	/* clean up process table entry for child */
	    else
	        perror("WARNING: wait() failed in child_death()! ");
	}
    }
    retval = (status>>8) & 0xff;
    Set_user_data(retval);
    sh_retval = retval;
}

void exec_command()
{
    int i,a;
    char devicename[16];
    struct termio termio, defTermio;
    struct passwd *pw;

    /* setup default "preference" keys in case parent is not attached to
       a terminal */

    defTermio.c_cc[VINTR] = CINTR;
    defTermio.c_cc[VERASE] = CERASE;
    defTermio.c_cc[VKILL] = CKILL;

    /* if parent is attached to a terminal, grab its termio settings */
    for (i = 0; i <= 2; i++) {
	struct termio oldio;
	if (ioctl (i, TCGETA, &oldio) == 0) {
	    defTermio.c_cc[VINTR] = oldio.c_cc[VINTR];
	    defTermio.c_cc[VERASE] = oldio.c_cc[VERASE];
	    defTermio.c_cc[VKILL] = oldio.c_cc[VKILL];
	    break;
        }
    }
    if ((exec_pid = fork ()) != -1)
    {
	if (!exec_pid)	/* Is this the child?? */
	{
/*	    signal (SIGINT, SIG_DFL);	*/
/*	    signal (SIGQUIT, SIG_DFL);	*/
/*	    signal (SIGHUP, SIG_DFL);	*/

	    signal (SIGINT, SIG_IGN);
	    signal (SIGQUIT, SIG_IGN);
	    signal (SIGHUP, SIG_IGN);

	    for (i = 0; i < 20; i++)	/* close all open files */
		close(i);		/* include stdin, stdout, stderr */

	    setpgrp ();		/* make child process group leader */

	    sprintf (devicename, "/dev/%s", linename);

	    a=open (devicename, 2);
	    a=open (devicename, 2);
	    a=open (devicename, 2);


	    /* Set up the termio for the process */
	    ioctl (0, TCGETA, &termio);
	    termio.c_iflag |= IGNPAR | ICRNL | IXON | IXANY | BRKINT;
	    termio.c_oflag |= OPOST | ONLCR;
	    termio.c_cflag = (termio.c_cflag & ~CBAUD) | B9600;
	    termio.c_cflag = (termio.c_cflag & ~CSIZE) | CS8;
	    termio.c_cflag |= CREAD | CLOCAL;
	    termio.c_lflag |= ISIG | ICANON | ECHO | ECHOE | ECHOK;

	    termio.c_cc[VINTR] = defTermio.c_cc[VINTR];
	    termio.c_cc[VERASE] = defTermio.c_cc[VERASE];
	    termio.c_cc[VKILL] = defTermio.c_cc[VKILL];

	    ioctl (0, TCSETA, &termio);

	    chown(devicename,getuid(),getgid());
	    chmod(devicename,0622);

	    pw = getpwuid (getuid());
	    if (pw != NULL)
	    {
		char	*argv0;

		/* Set to uid, gid of vterm's parent */
		setuid (getuid ());
		setgid (getgid ());

		argv0 = strrchr (pw->pw_shell, '/') + 1;
		if (argv0 == NULL)	/* should never happen */
		    argv0 = "sh";
			
		Wait_timer(2);

		if ((execl (pw->pw_shell, argv0, "-c", exec_cmd, 0)) == -1)
		    _exit (0);
	    }
	    else
		perror ("vterm,spawn.c  -  getpwuid failed");
	}
    }
    else
	perror ("vterm,spawn.c  -  fork failed");
}
