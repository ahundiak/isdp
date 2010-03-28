#include "grimport.h"
#include <stdio.h>
#include "igrtypedef.h"
#include "msdef.h"
#include "dpdef.h"

#include "wl.h"
#include "igr.h"
#include "dl.h"

/* prototype files */
#include "dpclpstack.h"

IGRint DPpush_clip(
   IGRlong    *message,
   IGRboolean rect,
   IGRboolean front,
   IGRboolean back,
   IGRdouble  range[6],  
   IGRint     gpipe_id,
   IGRdouble  vw_volume[6] )

/*
NAME
	DPpush_clip

DESCRIPTION
	This function sets the viewport clipping
	information into the DL

HISTORY
   06/22/93  added view volume paramater for OPENGL perspective case

*/
	
{
    IGRint status;

    /* push clip struct on stack */
    /* add vw_volume for OPENGL perspective case to set up the PROJECTION 
       matrix with the correct view volume to map to the viewport (the other
       parameters (put into OPENGL by glviewport */
    if ( DLset_viewport( gpipe_id, range[0], range[1], range[2],
            range[3], range[4], range[5], vw_volume ) != DL_SUCCESS )
    {
	status = FALSE;
	*message = MSFAIL;
	goto wrapup;
    }

    if ( DLset_z_clipping( gpipe_id, (int) front, (int) back ) != DL_SUCCESS )
    {
	status = FALSE;
	*message = MSFAIL;
    }

wrapup:
    return( status );

}  /* DPpush_clip */

