
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>
#include <FI.h>

#include "OMminimum.h"
#include "DIdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "msmacros.h"
#include "madef.h"
#include "godef.h"
#include "plotmsg.h"

#include "HSplot.h"
#include "HSplot_def.h"
#include "hsmsg.h"

#include "wl.h"
#include "HSpr_hplot.h"




extern IGRchar	*strrchr( );

/*---HPexecute---------------------------------------*/

/*
NAME
	HPexecute
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	Make sure enough information has been collected, the
	call function to submit plot job
	
PARAMETERS
	into	:(IN) : shaded plotting global information
	results	:(OUT): status message from the submit
	
GLOBALS USED

FUNCTIONS CALLED
	strlen
	ex$message
	HPqprreq
	strncpy
	strrchr
	sprintf
	sscanf
		
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HPexecute( struct HSplot_info *info,
				      IGRchar *result )
#else
	IGRint	HPexecute( info, result )

	struct HSplot_info	*info;
	IGRchar			*result;
#endif

	{
	IGRint	sts;
	IGRchar	*c;

	sts = PI_F_FAIL;

	/* verify that enough information is present to submit a plot */

	if( strlen( info->plotfile ) == 0 )
		{
		ex$message( msgnumb = HS_P_EntFlNme, buff = result );
		
		goto finish;
		}

	if( strlen( info->queue ) == 0 )
		{
		ex$message( msgnumb = HS_P_SpecifyQ, buff = result );
		goto finish;
		}

	sts = HPqprreq( info, result );

	if( sts & 1 )
		{
		/* save the job information */

		strncpy( info->last_job_queue, info->queue, 32 );
		
		if( c = strrchr( info->plotfile, '/' ) )
			c++;
		else
			c = info->plotfile;
			
		sprintf( info->last_job_name, c, 16 );
		sscanf( result, "%*s %s", info->last_job_id );
		}

finish:

	return( sts );
	}
