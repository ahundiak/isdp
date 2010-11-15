/* Do not alter this SPC information: $Revision: 1.2.26.1 $ */
/*
**	NAME:							plbmisc.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					7/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#endif
#if !defined(WIN32S)
#include <stdio.h>
#endif
#include <signal.h>

#if defined(unix) || defined(DOS)
#include <sys/time.h>
#endif

#if defined(WIN32)
#include <time.h>
#endif
#if defined(WIN32S)
#include "prog32s.h"
#endif 

/*
**	DEFINES
*/

/*
**	TYPES
*/
typedef struct tempfile_s
{
	char				name[L_tmpnam];
	struct tempfile_s	*next;
} tempfile_s;

/*
**	FUNCTION PROTOTYPES
*/
#define plbmisc_c
#include "plbmisc.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
tempfile_s *tempfiles = NULL;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int sleep60(
	int	time)				/* time in 1/60ths of a second */
{
#if defined(WIN32) || defined(DOS)
	_sleep(time); 	/* user-defined non-ANSI function for DOS ONLY */
#endif
#if defined(unix)
	int sts;
	struct itimerval t;

	memset(&t,0, sizeof(t));

	t.it_value.tv_sec = time/60;
	time -= time / 60 * 60;
	t.it_value.tv_usec = time * 16667;

	sighold(SIGALRM);

	if ((sts = setitimer(ITIMER_REAL, &t, NULL)) != 0)
	{
		return sts;
	}

	sigpause(SIGALRM);
#endif
	return 0;
}

/******************************************************************************/

#if defined(DOS)
extern void _sleep(
	int time)
{
	clock_t start = clock()/CLOCKS_PER_SEC;
	do
	{
		/* Just wait */
	} while(((clock()/CLOCKS_PER_SEC) - start) <= (clock_t) time);
}
#endif

/******************************************************************************/

extern void add_tempfile(
	char *name)
{
	tempfile_s *temp;

	if (name)
	{
		if ((temp = (tempfile_s *)malloc(sizeof(tempfile_s))) != NULL)
		{
			strcpy(temp->name, name);
			temp->next = tempfiles;
			tempfiles = temp;
		}
	}
}

/******************************************************************************/

extern void delete_tempfiles(
	void)
{
	for(;tempfiles; tempfiles = tempfiles->next)
	{
		remove(tempfiles->name);	
	}
}

/******************************************************************************/

extern void Exit(
	int sts)
{
	delete_tempfiles();
	exit(sts);
}

/******************************************************************************/
