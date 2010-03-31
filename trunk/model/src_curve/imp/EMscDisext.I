class implementation GRsubbc;

#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "godef.h"
#include "gocmacros.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "bserr.h"
#include "bspolyxtdst.h"
#include "bsnorkts.h"
#include "bsfreecv.h"
#include "bsdistptpt.h"
#include "bscnvtomkt.h"
#include "bsalloccv.h"

method GRdisextend(IGRlong *msg; struct GRmd_env *md_env; IGRpoint
                   endpoint; IGRdouble *dist; IGRpoint new_endpt)
/*
Abstract
	This method extends one end of a general sub B_spline curve
	by a specified distance.

Arguments
	*msg	MSSUCC -- if successful
			MSINARG -- if curve is physically closed
			MSNOMEM -- if can't allocate memory
			MSFAIL -- all other errors

Files
	EMscdisext.I

History
	dhm   9/1/87    Creation date.
	dhm   9/15/87	Fixed problem with determining the distance
					and unweighted the end point if the extended curve was
					rational so as to get the correct end point to return.
    dhm   2/22/88   Added GR_NOTIFY_LISTENERS
    SS    02/14/90  Normalize the output curve after calling the math function
    Sudha  06/16/93     Modified for BSprototype ansification
*/

{
  IGRlong		status, sts, msg_loc, size, num_poles;
  struct IGRbsp_curve	*curve, *ext_curve;
  IGRchar		errmsg[EMMAXERRMSG_LEN];
  IGRint		i;
IGRboolean   end_flag;
  extern   IGRboolean	GRabsg_del();
  struct GRpost_info	info;
  GRobjid		new_obj;
IGRdouble   dist1, dist2;
  IGRpoint		startpnt, endpnt;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy (errmsg, "GRsubbc.GRdisextend");
  curve = NULL;
  ext_curve = NULL;

  /*
   * Get the abstract geometry of the curve
   */
 
  GRgetabsg (&msg_loc, &md_env->md_env.matrix_type, md_env->md_env.matrix,
             (char **) &curve, i);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Check to see if physically closed.
   * Can't extend a closed curve.
   */

  if (curve->phy_closed)
  {
     *msg = MSINARG;
     goto ret_end;
  }

  /*
   * Determine the distance between the
   * end points of the curve and the input
   * endpoint to see which end to return as
   * the new endpoint.
   */

  status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                        &md_env->md_env.matrix_type, md_env->md_env.matrix,
                        startpnt, endpnt),
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  dist1 = BSdistptpt(&msg_loc, startpnt, endpoint);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  dist2 = BSdistptpt(&msg_loc, endpnt, endpoint);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  if (dist1 < dist2)
     end_flag = 0;  /* start point */
  else
     end_flag = 1;  /* end point */

  /*
   * Allocate memory for the extended curve.
   */

  if (*dist > 0)
     num_poles = curve->num_poles + curve->order - 1;
  else
     num_poles = curve->num_poles;

  BSalloccv(curve->order, num_poles, curve->rational,
            curve->num_boundaries, &ext_curve, &msg_loc);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSNOMEM, ret_end);

  /*
   * Call the math routine to extend the curve. Normalize the knots as
   * math does not do it.
   */

  BSpolyxtdst(curve, endpoint, *dist, ext_curve, &msg_loc);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
  if (ext_curve->periodic)
    {
    status = BScnvtomkt (&msg_loc, ext_curve);
    EMerr_hndlr (!status, *msg, MSFAIL, ret_end);
    }
  status = BSnorkts (&msg_loc, &ext_curve->order, &ext_curve->num_poles, 
            ext_curve->knots);
  EMerr_hndlr (!status, *msg, MSFAIL, ret_end);

  /*
   * Return the new endpoint.
   */

  if (!end_flag)  /* return the start point of extended curve */
  {
     if (ext_curve->rational)
     {
        new_endpt[0] = ext_curve->poles[0] / ext_curve->weights[0];
        new_endpt[1] = ext_curve->poles[1] / ext_curve->weights[0];
        new_endpt[2] = ext_curve->poles[2] / ext_curve->weights[0];
     }
     else
     {
        new_endpt[0] = ext_curve->poles[0];
        new_endpt[1] = ext_curve->poles[1];
        new_endpt[2] = ext_curve->poles[2];
     }
  }
  else  /* return the end point of the extended curve */
  {
     num_poles = (ext_curve->num_poles - 1) * 3;
   
     if (ext_curve->rational)
     {
        new_endpt[0] = ext_curve->poles[num_poles]
                       / ext_curve->weights[ext_curve->num_poles-1];
        new_endpt[1] = ext_curve->poles[num_poles+1]
                       / ext_curve->weights[ext_curve->num_poles-1];
        new_endpt[2] = ext_curve->poles[num_poles+2]
                       / ext_curve->weights[ext_curve->num_poles-1];
     }
     else
     {
        new_endpt[0] = ext_curve->poles[num_poles];
        new_endpt[1] = ext_curve->poles[num_poles+1];
        new_endpt[2] = ext_curve->poles[num_poles+2];
     }
  }

  /*
   * Post the geometry back to the curve.
   */

  info.construct_flag = FALSE;
  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRpostabsg(&msg_loc, md_env,
                         &info, (IGRchar *)ext_curve, &new_obj),
                   senderid = my_id,
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  sts = GRabsg_del(curve);
  EMerr_hndlr(!sts, *msg, MSFAIL, ret_end);

ret_end: 
  if (ext_curve)
  {
     sts = BSfreecv(&msg_loc, ext_curve);
     EMerr_hndlr_action(!sts || msg_loc != BSSUCC, *msg, MSFAIL, ;);
  }

  GR_NOTIFY_LISTENERS(msg, &status, GR_GEOM_MODIFIED);
  return(status);

}

end implementation GRsubbc;
