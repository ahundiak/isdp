/* ###################   APOGEE COMPILED   ################## */
/* 
 DESCRIPTION
	 This method returns the closest keypoint of a surface of
	 revolution to the input line.  First, the parent's keypoint
	 method is called.  Next, the axis points and center of axis
	 is determined.  The distance between the boreline and axis points,
	 center point, and keypoint on the surface are all computed and the
	 smallest of these is taken to be the keypoint.

 RETURN VALUES
	 keypoint             The keypoint on the polygon or smooth surface
  
  	 key_parm             Information about the keypoint found.  Contains
  	                      the (u,v) parameters or pole indices.  
  
	 msg                  MSSUCC if success
  	                      MSFAIL if problems 

 NOTES
	 If an axis point or the center point is returned, then the parameter
	 is not on the surface (key_parm->polygon_inx = 2) and u,v parameter
	 info has no meaning.
  
 BUGS

 HISTORY
    dhm	    12/29/87	creation date.
    dhm     02/27/89    changed to return keypoint from parent if
                        the extract axis function fails.
    NP      08/21/92    Modified for ANSI compliance.
*/

class implementation EMSrevol;

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

method GRkeypoint(
  IGRlong *msg;                         /* Error return code */
  IGRshort *matrix_type;                /* My matrix type */
  IGRmatrix matrix;                     /* My matrix */
  struct IGRline *boreline;             /* Bore line for projection */
  IGRpoint keypoint;                    /* Closest keypoint */
  struct GRparms *key_parm)             /* Parameters for keypoint */
{
  IGRlong       status, msg_loc, i;
  IGRdouble     dist, min_dist;
  IGRpoint      pnt_arr[3];  /* has line pnt1 and pnt2 and center pnt */
  extern   IGRboolean    BSdistptli();
IGRboolean   sts;
  IGRchar       errmsg[EMMAXERRMSG_LEN];
  struct        IGRbsp_surface *surf;
  void          EMextract_axis();

  /*
   * Initialize
   */

  status = OM_S_SUCCESS;
  *msg = MSSUCC;
  strcpy (errmsg, "EMSrevol.GRkeypoint\n");
  surf = NULL;

  /*
   * Generate my abstract data
   */

  GRgetabsg(&msg_loc, matrix_type, matrix, (IGRchar **)&surf, i);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Call my parents GRkeypoint to get
   * the closest keypoint on the surface.
   */

  status = om$send(mode = OM_e_wrt_message,
                   msg = message EMSsubbs.GRkeypoint(msg, matrix_type,
                         matrix, boreline, keypoint, key_parm),
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Make the minimum distance equal
   * the distance from the boreline and the
   * keypoint on the surface.
   */

  sts = BSdistptli(&msg_loc, keypoint, boreline->point1, boreline->point2,
                   &min_dist);
  EMerr_hndlr( !sts || (msg_loc != BSSUCC), *msg, MSFAIL, ret_end);

  /*
   * Get the axis and center point.
   */

  EMextract_axis(&msg_loc, NULL, surf, pnt_arr);
  if ( EMis_error(msg_loc) )  goto ret_end;

  /*
   * Compare the distance from axis and center
   * point to the input boreline to see if one
   * of them is closer to it than the keypoint
   * on the surface.
   */

  for (i = 0; i < 3; i++)
  {
      sts = BSdistptli(&msg_loc, &pnt_arr[i][0], boreline->point1,
                       boreline->point2, &dist);
      EMerr_hndlr( !sts || (msg_loc != BSSUCC), *msg, MSFAIL, ret_end);

      if (dist < min_dist)
      {
         min_dist = dist;
         keypoint[0] = pnt_arr[i][0];
         keypoint[1] = pnt_arr[i][1];
         keypoint[2] = pnt_arr[i][2];
         key_parm->polygon_inx = 2;
      }
  }

ret_end:
  return(status);

}

end implementation EMSrevol;
