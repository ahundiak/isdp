#include "grimport.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "dpdef.h"

#include "wl.h"
#include "igr.h"
#include "dl.h"

#include "dpmacros.h"

/* prototype files */
#include "dpmtxstack.h"

#include "matrnmx.h"

extern int DPinq_display_tolerance( int * );

/*
HISTORY

   06/22/93 added eye_pt, vup, and vpn for OPENGL perspective case
            to create the rotation and translation matrix for eye
            coordinates.
*/

IGRint DPpush_vwmtx(
   IGRlong   *message,	     /* output completion cond */
   IGRmatrix matrix,	     /* view matrix		  */
   IGRdouble scale,
   IGRint    gpipe_id,       /* window number          */
   IGRdouble *eye_pt,        /* eye point for perspective */
   IGRdouble *vup,           /* view up vector for perspective */
   IGRdouble *vpn )          /* view plane normal for perspective */
{
    IGRint     status = TRUE;
    IGRboolean ret_val;
    IGRint     tol_factor;
    IGRdouble  tol;
    IGRshort   four = 4;
    IGRdouble  trnsp_matrix[16];
	
    dp$inq_display_tolerance( pixel_toler = &tol_factor );
    tol = tol_factor / scale;

    if ( !(MAtrnmx( message, &four, matrix, trnsp_matrix )) )
    {
	status = FALSE;
	goto  wrapup;
    }

#if DEBUG
    printf("The matrix in DPpush_matrix is \n");

    printf("    %lf  %lf  %lf  %lf\n",trnsp_matrix[0],trnsp_matrix[1],
                                      trnsp_matrix[2],trnsp_matrix[3]);

    printf("    %lf  %lf  %lf  %lf\n",trnsp_matrix[4],trnsp_matrix[5],
                                      trnsp_matrix[6],trnsp_matrix[7]);

    printf("    %lf  %lf  %lf  %lf\n",trnsp_matrix[8],trnsp_matrix[9],
                                      trnsp_matrix[10],trnsp_matrix[11]);

    printf("    %lf  %lf  %lf  %lf\n\n",trnsp_matrix[12],trnsp_matrix[13],
                                        trnsp_matrix[14],trnsp_matrix[15]);
#endif

    /* pass on the eye_pt, vpn, and vup for generating the OPENGL perspective
       translation and rotation matrix to put into the MODELVIEW matrix to 
       transform into eye coordinates */
    if ( DLset_matrix( gpipe_id, trnsp_matrix, eye_pt, vpn, vup ) != DL_SUCCESS )
       {
       status = FALSE;
       goto wrapup;
       }

     DLset_curve_tolerance( gpipe_id, tol, tol_factor );

#if DEBUG
	printf("The world tolerance is %lf, and the device tolerance is %lf\n",
		tol,tol_factor);
#endif

     DLcharacterize_matrix( gpipe_id );

    *message = (status) ? MSSUCC : MSFAIL;

wrapup:
    return( status );

}  /* DPpush_vwmtx */

