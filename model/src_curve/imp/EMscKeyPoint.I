class implementation GRsubbc;

#include "EMS.h"
#include "msdef.h" /* MS message codes */
#include "OMminimum.h"     /* for gocmacros.h  */
#include "igrtypedef.h"     /* for gocmacros.h  */
#include "godef.h"
#include "gocmacros.h"     /* GRgetabsg macro  */
#include "bserr.h"
#include "emserr.h"
#include "emsdef.h"
#include "malnpspro.h"
#include "bsunwght_p.h"

method GRkeypoint(
  IGRlong *msg;                         /* Error return code */
  IGRshort *matrix_type;                /* My matrix type */
  IGRmatrix matrix;                     /* My matrix */
  struct IGRline *boreline;             /* Bore line for projection */
  IGRpoint keypoint;                    /* Closest keypoint */
  struct GRparms *key_parm)             /* Parameters for keypoint */

/*
Abstract
	This method returns the closest keypoint of the B_spline curve
	to the input line.  If the polygon is on, then the poles are
	considered to be the keypoint.  If the surface is on, then the
	method is sent to the parent to determine the keypoint by the 
	knots.

Arguments
	msg				Error return code.  MSSUCC if successful, MSNOMEM if
					can't allocate memory, and MSFAIL for all others.
	matrix_type		My matrix type.
	matrix			My matrix.
	boreline		Bore line for projection.
	keypoint		Closest keypoint.
	key_parm		Parameters for keypoint.

Files
	EMsckeypoint.I

History
	dhm    7/6/87      Creation date
    dhm    2/22/88     Added GR_NOTIFY_LISTENERS
    dhm    06/09/88    Took out GR_INQUIRED notification.
    Sudha  06/16/93     Modified for BSprototype ansification

*/

{
  IGRlong			msg_loc, status, sts, i;
  struct IGResbc	element_specific;
  struct IGRbsp_curve		*curve;
  struct IGRpointset		pt_set;
  IGRpoint			pnt_on_line;
  IGRdouble			*unwpoles, t_of_line;
  IGRlong			pole_num;
  IGRchar			errmsg[EMMAXERRMSG_LEN];

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  msg_loc = MSSUCC;
  strcpy (errmsg, "GRsubbc.EMsckeypoint");
  curve = NULL;
  unwpoles = NULL;

  /*
   * Get attributes to find out if
   * polygon display is on
   */

  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetattr(&msg_loc, (IGRchar *)
                         &element_specific),
                   senderid = my_id,
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  if (element_specific.is_polydis)
  {
     /*
      * Get the geometry of the curve.
      */

     GRgetabsg(&msg_loc, matrix_type, matrix, (char **) &curve, i);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     /*
      * Form a point set from the B-spline poles.
      */

     pt_set.num_points = curve->num_poles;
     pt_set.points = curve->poles;

     /*
      * If rational, then unweight
      * the poles.
      */

     if (curve->rational)
     {
        unwpoles = (IGRdouble *) om$malloc(size = pt_set.num_points *
                                           sizeof(IGRdouble) * 3);
        EMerr_hndlr(!unwpoles, *msg, MSNOMEM, ret_end);

        status = BSunwght_p(&msg_loc, curve->poles, curve->weights,
                            &pt_set.num_points, unwpoles);
        pt_set.points = unwpoles;
     }

     /*
      * Project the input boreline to
      * the point set.
      */

     status = MAlnpsproj(&msg_loc, boreline, &pt_set, pnt_on_line,
                         keypoint, &t_of_line, &pole_num);
     EMerr_hndlr(!status, *msg, MSFAIL, ret_end);

     key_parm->leaf_id.objid = my_id;
     key_parm->leaf_id.osnum = OM_Gw_current_OS;
     key_parm->u = pole_num - 1;
     key_parm->v = 0;
     key_parm->polygon_inx = 1;
  }
  else if (element_specific.is_curvedis)
  {
     status = om$send(mode = OM_e_wrt_message,
                      msg = message GRbspline.GRkeypoint(msg, matrix_type,
                            matrix, boreline, keypoint, key_parm),
                      targetid = my_id);
     EMomerr_hndlr(status, ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
  }

ret_end:
  if (unwpoles) om$dealloc(ptr = unwpoles);
  return(status);

}

end implementation GRsubbc;
