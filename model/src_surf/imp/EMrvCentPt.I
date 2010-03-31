/* ###################   APOGEE COMPILED   ################## */
/* 
 DESCRIPTION
	 This method returns the closest key axis-point on a surface of
	 revolution to the user point. This method was written with the
	 objective of making this class an eligible class for the "POINT
	 AT CENTER" event generator command.

 RETURN VALUES
	 pt                   The keypoint on the axis of rev of surface
  
  	 key_parm             Information about the keypoint found.
  	                      
  
	 msg                  MSSUCC if success
  	                      MSFAIL if problems 

 NOTES

  
 BUGS

 HISTORY
	Madhu		01/Jun/90	creation date.
	ashok		12/Jun/90	put this message in a new file
        NP              21/Aug/92       Modified for ANSI compliance.
*/

class implementation EMSrevol;
from IGEgragad import DPinrot;
#include "EMS.h"
# include "OMminimum.h"         /* for gocmacros.h                  */
# include "OMlimits.h"          /* lc.h replacement                 */
# include "igetypedef.h"
# include "igrtypedef.h"        /* for gocmacros.h                  */
# include "gocmacros.h"         /* GRgetabsg macro                  */
# include "msdef.h"             /* MS message codes                 */
# include "bserr.h"             /* BS message codes                 */
# include "emsdef.h"            /* MAXDOUBLE                        */
# include "ex.h"
# include "igr.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"


method GRcentcurv(
  IGRlong *msg;                         /* Error return code */
  IGRshort *matrix_type;                /* My matrix type */
  IGRmatrix matrix;                     /* My matrix */
  struct GRparms *key_parm;             /* Parameters for keypoint */
  long float *pt)
{
  IGRlong         status, msg_loc, i;
  IGRdouble       dist, min_dist;
  struct IGRline  boreline;           /* normal to view */
  IGRpoint        pt1, pt2, pt3;      /* boreline, endpoint */
  IGRmatrix       view_matrix;        /* of view in which ele identified */
  IGRpoint        pnt_arr[3];  /* has line pnt1 and pnt2 and center pnt */
  extern          IGRboolean    BSdistptli();
  IGRboolean      sts;
  IGRchar         errmsg[EMMAXERRMSG_LEN];
  struct        IGRbsp_surface *surf;
  void          EMextract_axis();
  struct EX_button *button;

  /*
   * Initialize
   */

  status = OM_S_SUCCESS;
  *msg = MSSUCC;
  strcpy (errmsg, "EMSrevol.GRcentcurv\n");
  surf = NULL;
  button = (struct EX_button *)pt;

    /*
     *  get the view vector and construct boreline
     */

/*	printf("entered EMSrevol.GRcentcurv sucessfully\n"); */

    sts = om$send (msg = message IGEgragad.DPinrot (msg, view_matrix),
                   senderid = my_id,
                   targetid = button->objid,
                   targetos = button->osnum);

    if (sts & *msg & 1)
    {
        pt1[0] = button->x;
        pt1[1] = button->y;
        pt1[2] = button->z;
        pt2[0] = button->x + view_matrix[8];
        pt2[1] = button->y + view_matrix[9];
        pt2[2] = button->z + view_matrix[10];
        boreline.point1 = pt1;
        boreline.point2 = pt2;
    }

  /*
   * Generate my abstract data
   */

  GRgetabsg(&msg_loc, matrix_type, matrix, (IGRchar **)&surf, i);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Get the axis and center point.
   */

  EMextract_axis(&msg_loc, NULL, surf, pnt_arr);
  if ( EMis_error(msg_loc) )  goto ret_end;

  /*
   * Compare the distance from axis and center
   * point to the input boreline.
   */

  for (i = 0; i < 3; i++)
  {
      sts = BSdistptli(&msg_loc, &pnt_arr[i][0], boreline.point1,
                       boreline.point2, &dist);
      EMerr_hndlr( !sts || (msg_loc != BSSUCC), *msg, MSFAIL, ret_end);

      if(i==0)	{
	 min_dist=dist;
         button->x = pnt_arr[0][0];
         button->y = pnt_arr[0][1];
         button->z = pnt_arr[0][2];
         key_parm->polygon_inx = 2;
      }

      if (dist < min_dist)
      {
         min_dist = dist;
         button->x= pnt_arr[i][0];
         button->y = pnt_arr[i][1];
         button->z = pnt_arr[i][2];
         key_parm->polygon_inx = 2;
      }
  }

ret_end:
  return(status);

}
end implementation EMSrevol;
