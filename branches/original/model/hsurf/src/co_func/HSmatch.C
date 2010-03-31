
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

/*		Apogee compliant		*/

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hsmacdef.h"
#include "hsmsg.h"
#include "msmacros.h"
#include "msdef.h"
#include "exmacros.h"
#include "exdef.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSpr_co_func.h"

#define ERROR	1
#define DEBUG	0
#define DEBUG2	0

#define SIGNAL_RECEIVED		-1

/*--- HSfork -----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	int HSfork( int num_entries,
		   char *argstr[],
		    int wait_flag )
#else
	int HSfork( num_entries, argstr, wait_flag )
	int num_entries;
	char *argstr[];
	int wait_flag;
#endif

/*
NAME
	HSfork

KEYWORD
	animate

DESCRIPTION
	This function forks a child process from Ems rather than drive. It waits
	for the child to finish before returning in the parent process. The
	child process begins and ends here within this function.

PARAMETERS
	num_entries (IN) - Number of arguments plus command (Not used)
	argstr (IN) - Array of strings containing command and arguments
	wait_flag (IN) - Boolean indicating whether to wait until child finishes

GLOBALS USED
	none

RETURN VALUES
	0 - Always

HISTORY
	07/17/90 Created. -Trevor Mink
*/
{
	int stat_loc, pid, wt, rc;

#if DEBUG
	fprintf( stderr, "Passing to execvp() %s %s and %s\n", argstr[0], argstr[0], argstr[1] );
#endif
	/* The child process */
#ifdef IRIX
	if( (pid = fork()) == 0 )
#else
	if( (pid = vfork()) == 0 )
#endif
	{
#if DEBUG
		fprintf( stderr, "Inside the child, pid = %d\tgetpid = %d\n", pid, getpid() );
#endif
		argstr[2] = (char *)NULL;
		rc = execvp( argstr[0], argstr );
#if DEBUG2
		fprintf( stderr, "%s %s returns %d\n", argstr[0], argstr[1], rc );
#endif
	}
	else /* parent process */
	{
		/* wait for the child process to finish and return */
#if DEBUG
		fprintf( stderr, "Waiting in the parent, pid = %d\tgetpid = %d\n", pid, getpid() );
#endif
		if( wait_flag )
		{
			do
			{
				wt = wait( &stat_loc );
#if DEBUG2
				fprintf( stderr, "Inside the parent\twt = %d\tstat_loc = %x\n",
					wt, stat_loc );
#endif
			}
			while( stat_loc && wt != SIGNAL_RECEIVED );
		}
#if DEBUG
		fprintf( stderr, "Inside the parent, finished waiting.\twt = %d\tstat_loc = %x\n",
			wt, stat_loc );
#endif
	}

	return (0);

} /* HSfork */

/*--- HSget_file_o_files -----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	int HSget_file_o_files( char file_name[], 
				FILE **name_file_ptr,
				char *file_o_files )
#else
	int HSget_file_o_files( file_name, name_file_ptr, file_o_files)
	char file_name[], *file_o_files;
	FILE **name_file_ptr;
#endif

/*
NAME
	HSget_file_o_files

KEYWORD
	animate

DESCRIPTION

PARAMETERS
	file_name (IN) - Filename input by the user (Potentially w/wildcards
		and/or tilde
	name_file_ptr (OUT) - Pointer to file containing list of files opened
		for reading
	file_o_files (OUT) - String filename of file of files

GLOBALS USED
	none

RETURN VALUES
	0 - Success
	Non-zero - Error

HISTORY
	--/--/-- Created. -???
*/
{
	int len, test, ret;
	char ch, *temp_fname1, *temp_fname2, *filename1;
	char *argstr[3];
	char comm_str[40];
	FILE *datfile1,*datfile2;

	len = strlen(file_name);
	test = strspn("*", file_name);
	ch = file_name[len-1];
	if( test != 0 )
		ch = '*';

	if ( (ch != '*') && (ch != '~') )/* user used a simple file name */
	{
		temp_fname2 = tmpnam(NULL);
		datfile2 = fopen ( temp_fname2, "w");
		fprintf(datfile2,"%s\n",file_name);
		fclose(datfile2);
		chmod( temp_fname2, 0777);

		*name_file_ptr = fopen( temp_fname2, "r");
		if( *name_file_ptr == NULL )
			return(ERROR);
		else
			strcpy( file_o_files, temp_fname2 );
		return(0);
	}
	else if( ch == '*' ) /* user used a wild card in file name */
	{
		temp_fname1 = tmpnam(NULL);
		filename1 = (char *)malloc( strlen( temp_fname1 ) );
		strcpy( filename1, temp_fname1 );

		temp_fname2 = tmpnam(NULL);

		datfile1 = fopen( filename1, "w" );
		datfile2 = fopen( temp_fname2, "w" );

		fprintf (datfile1, "ls $1 > %s\nexit 0", temp_fname2);

		fclose (datfile1);
		fclose (datfile2);

		chmod (filename1, 0777);
		chmod (temp_fname2, 0777);

		argstr[0] = comm_str; strcpy (comm_str, filename1);
		argstr[1] = file_name;

		ret = HSfork( 2, argstr, 1 );
#if False
		ret = ex$fork( num_entry = 2, argu = argstr, wait_flag = 1);
#endif
		switch ( ret >> 8 )
		{
		case 0:
			/* Forked ls was successful */
			break;
		case 2:
			/* Forked ls failed		*/
			return(ERROR);
		} /* end case */

		*name_file_ptr = fopen(temp_fname2 , "r" );
		if( *name_file_ptr == NULL )
			return(ERROR);

		strcpy( file_o_files, temp_fname2 );
		return(0);
	}
	else /* user used a tilde file containing the names of rle files */
	{
		*name_file_ptr = fopen(file_name, "r");
		if( *name_file_ptr == NULL )
			return(ERROR);
		else
			return(0);
	}

} /* HSget_file_o_files */

