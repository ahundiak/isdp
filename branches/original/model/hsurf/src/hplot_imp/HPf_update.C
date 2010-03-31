
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>
#include <FI.h>
#include "DIdef.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "msmacros.h"
#include "plotmsg.h"

#include "HSplot.h"
#include "HSplot_def.h"
#include "HSplot_label.h"
#include "hsmsg.h"

#include "wl.h"
#include "HSpr_hplot.h"
 

extern FILE *popen();
extern char *fgets(), *strchr();
extern int strncmp();
extern int FIfld_set_text ();
extern int FIg_display ();
extern int FIg_erase ();
extern int FIg_reset ();
extern int FIg_set_text ();


/*---HPupdate_queue_status-----------------------------------------------*/

/*
NAME
	HPupdate_queue_status
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	Collect qstat information about the active queue and display
	on the shaded queue status form
	
PARAMETERS
	info	:(IN) : shaded plotting global information
	
GLOBALS USED
	-none-
	
HISTORY
	??/??/?/	M. Lanier
		Created
        05/18/93        M. Lanier
                Change strcpy to strncpy for non-ENV5 compiles
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HPupdate_queue_status( struct HSplot_info *info )
#else
	IGRint	HPupdate_queue_status( info )

	struct HSplot_info	*info;
#endif

	{
	int	sts, i, row, sel;
	int	ii, jj;
	char	buf[128];
	FILE	*pp = NULL;

	sts = PI_S_SUCCESS;

	/* clear the job list field */

	FIg_reset( info->displayed_form, QS_JOB_LIST );
	FIg_display( info->displayed_form, QS_JOB_LIST );

	/* get the command to run from the field on the form (allows the */
	/* user to alter the command, added options, ... ) */

	FIfld_get_text( 
		info->displayed_form, 
		QS_QUEUE, 
		0, 0, 128, 
		buf, 
		&sel, &row );

	if( strlen(buf) == 0 )
		{
		sts = PI_F_NOQUEUE;
		goto finish;
		}

	/* command line must be a qstat command (prevent user self-mutiliation) */

	if( strncmp( buf, "qstat", 5 ) )
		{
		ex$message( msgnumb = PI_E_InvInp, buff = buf );
		goto finish;
		}

	/* open a pipe to the command output */
	
	ii = 0;
	jj = strlen( buf );
	while( ii < jj )
		if( buf[ii++] == '@' ) break;

	ii--;

#       if defined (ENV5)	
	strcpy( info->nodename, &buf[ii], jj-ii+1 );
#       else
	strncpy( info->nodename, &buf[ii], jj-ii+1 );
#       endif

	ii = 0;
	jj = strlen( info->nodename );
	while( ii < jj )
		{
		if( info->nodename[ii] == ' ' )
			{
			info->nodename[ii] = 0;
			break;
			}
			
		ii++;
		}

	pp = popen( buf, "r" );

	if( pp == NULL )
		{
		sts = PI_F_QSTAT;

		ex$message(
			msgnumb = PI_E_CantExe,
			type = "%s",
			var = `"qstat"`,
			buff = buf);

		goto finish;
		}

	/* copy the command output to the form */

	i = -1;
	while( (fgets( buf, sizeof(buf), pp ) != NULL) && (i++ < 1000) )
		{
		FIfld_set_text( info->displayed_form, QS_JOB_LIST, i, 0, buf, 0);
		}

	buf[0] = NULL;

finish:

	if(pp)
		pclose (pp);

	FIfld_set_text( info->displayed_form, FI_MSG_FIELD, 0, 0, buf, 0 );

	return(sts);
	}

/*---HPget_qstat_command---------------------------------------*/

/*
NAME
	HPget_qstat_command
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	Build the qstat command to display on the form
	
PARAMETERS
	queue	:(IN) :  Name of the active queue
	cmdline	:(OUT):  formatted qstat command line
	
HISTORY
	??/??/??	M. Mathis, M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HPget_qstat_command( IGRchar *queue,
				    IGRchar *cmdline )
#else
	IGRint HPget_qstat_command( queue, cmdline )
	
	IGRchar	*queue, *cmdline;
#endif

	{
	int	sts, i;
	char	buf[128], *c, qatnode[32];
	char	buf1[64], buf2[32];
	FILE	*pp = NULL;

	sts = PI_S_SUCCESS;

	/* format a command line to figure out what queue@node to display */

	sprintf (buf, "qstat -x %s 2>&1", queue);

	if( (pp = popen(buf, "r")) == NULL )
		{
		sts = PI_F_QSTAT;
		goto finish;
		}

	/* look for the Destset or Devset line */

	i = 0;
	qatnode[0] = NULL;
	while( (fgets(buf, sizeof (buf), pp) != NULL) && (i++ < 20) )
		{
		sscanf( buf, "%s %*s %s", buf1, buf2 );
		if( strcmp(buf1, "Destset") == 0 || strcmp(buf1, "Devset") == 0 )
			{
			c = buf2;
			while( *c != '}' ) c++;
			*c = NULL;
			c = buf2 + sizeof (char);
			strncpy( qatnode, c, 32 );
			break;
			}
		}

	pclose (pp);

	c = (qatnode[0]) ? qatnode : queue;

	/* format a command line to get the desired queue status */

	sprintf( cmdline, "qstat -a %s 2>&1 ", c );

finish:

	return(sts);
	}
