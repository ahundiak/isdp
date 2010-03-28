#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

extern int DLIreport_errors;

static double DLIidentity[16] = {1.0, 0.0, 0.0, 0.0,
                                 0.0, 1.0, 0.0, 0.0,
                                 0.0, 0.0, 1.0, 0.0,
                                 0.0, 0.0, 0.0, 1.0};

/*--- DLreset_matrix --------------------------------------------------------*/

int DLreset_matrix(
   int pipe_id )

/*
NAME
	DLreset_matrix

DESCRIPTION
	This function resets the transformation matrix of a drawing pipeline
	to the identity.

SYNOPSIS
	int DLreset_matrix(
	   int pipe_id )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.

RELATED INFORMATION

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   pipe->clip_flag |= DLI_CL_IDENTITY;

   /* reset matrix characterization */
   pipe->matmap[0] = 0xf;
   pipe->matmap[1] = 0xf;
   pipe->matmap[2] = 0xf;
   pipe->matmap[3] = 0xf;
   memcpy( pipe->viewing_matrix, DLIidentity, 16 * sizeof( double ) );

   DLIsetup_DL_window( pipe );

#if defined( OPENGL )
   if ( pipe->using_opengl )
   {
      DLIsetup_OPENGL_window( pipe, FALSE );
   }
#endif

#if defined( XGL )
   if( pipe->using_xgl )
   {
      DLIsetup_XGL_window( pipe, FALSE );
   }
#endif

#if defined( ENV5 )
   if ( pipe->using_eg )
   {
      DLIsetup_EG_window( pipe );
   }

   if ( pipe->using_gpipe )
   {
      sts = GPResetMatrix( pipe->gpipe_id );
      sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;

      if ( !(pipe->clip_flag & DLI_CL_MOD_IDENTITY) )
      {
         sts = GPMultMatrix( pipe->gpipe_id, pipe->modelling_matrix, GP_PREMULT );
         sts = (sts == 0) ? DL_SUCCESS : DL_ERROR;
      }
   }
#endif

   return( sts );

}  /* DLreset_matrix */

