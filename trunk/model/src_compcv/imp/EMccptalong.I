/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
#include "OMminimum.h"
#include "msdef.h"
#include "godef.h"
#include "gr.h"
#include "grdpbmacros.h"
#include "gocmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"

method GRptalong(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		  IGRpoint pnt1, pnt2; struct GRparms *parm1, *parm2;
		  IGRdouble *dist; IGRpoint out_point)
/*
Abstract
	This method produces a point on a composite curve at a given distance
	from the input point in the direction of the second point.

Arguments

Notes

Files
	EMccptalong.I

History
	dhm		10/22/87		Creation date.
	dhm		12/21/87		converted to 1.1
    dhm     03/07/88        Rewrite the right way.
    dhm     10/27/88        changed to handle point on a extension.
*/

{
  IGRlong	msg_loc, status;
  IGRint        i;
  OMuint	 count, ind1, ind2;
  IGRchar	errmsg[EMMAXERRMSG_LEN];
  IGRdouble distance, arclength;
  IGRpoint  start_pnt, end_pnt, point1, point2;
  struct GRparms   spar, epar;
  OM_S_CHANSELECT  to_comps;
  IGRboolean       is_right;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg, "GRcompcurve.GRptalong\n");
  distance = *dist;
  is_right = TRUE;

  /*
   * Initialize the channel selector
   */

  status = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Get the number of components on the channel.
   */

  status = om$get_channel_count(object = me,
                                p_chanselect = &to_comps,
                                count = &count);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Get the indexes that pnt1 and pnt2 lie on.
   */

  status = om$get_index(object_c = me,
                        p_chanselect = &to_comps,
                        objid = parm1->leaf_id.objid,
                        indexaddr = &ind1);
  EMomerr_hndlr(status, ret_end, errmsg);

  status = om$get_index(object_c = me,
                        p_chanselect = &to_comps,
                        objid = parm2->leaf_id.objid,
                        indexaddr = &ind2);
  EMomerr_hndlr(status, ret_end, errmsg);

  if ( (ind1 > ind2) || ((ind1 == ind2) && (parm1->u > parm2->u)) )
     is_right = FALSE;

  /*
   * Get the endpoints of object at ind1 and use to
   * get the arclength from pnt1 to one of the endpoints
   * (depending on direction).  Compare the arclength to the
   * distance and send to the object if arclength is > distance;
   * else subtract arclength from distance.
   */

  status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                         matrix_type, matrix, start_pnt, end_pnt),
                   p_chanselect = &to_comps,
                   from = ind1,
                   to = ind1);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  if (is_right)
  {
     point2[0] = end_pnt[0];
     point2[1] = end_pnt[1];
     point2[2] = end_pnt[2];
     epar.u = 1.0;
  }
  else
  {
     point2[0] = start_pnt[0];
     point2[1] = start_pnt[1];
     point2[2] = start_pnt[2];
     epar.u = 0.0;
  }

  status = om$send(msg = message GRcurve.GRarclength(&msg_loc, matrix_type,
                         matrix, pnt1, pnt1, point2, parm1, parm1, &epar,
                         &arclength),
                   p_chanselect = &to_comps,
                   from = ind1,
                   to = ind1);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  if ( (arclength >= distance) ||
       (is_right && (ind1 == count-1)) ||
       (!is_right && (ind1 == 0)) )
  {
     status = om$send(msg = OPPmargs,
                      p_chanselect = &to_comps,
                      from = ind1,
                      to =ind1);
     EMomerr_hndlr(status, ret_end, errmsg);
     EMerr_hndlr(EMis_error(*msg), *msg, MSFAIL, ret_end);

     goto ret_end;
  }
  else
    distance -= arclength;

  if (is_right)  i = ind1 + 1;
  else  i = ind1 - 1;

  /*
   * Get the total length of the next object and send
   * the GRptalong message to theat object if the 
   * arclength is >= distance.  If it is not, then
   * subtract arclength from distance and repeat until
   * the condition is met or there are no more objects.
   */

  while ( (distance > 0) && (i < count) && (i >= 0) )
  {
    status = om$send(msg = message GRcurve.GRtotlength(&msg_loc,
                           matrix_type, matrix, &arclength),
                     p_chanselect = &to_comps,
                     from = i,
                     to = i);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    if ( (arclength >= distance) || (i == count - 1) || (i == 0) )
    {
       status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                              matrix_type, matrix, start_pnt, end_pnt),
                        p_chanselect = &to_comps,
                        from = i,
                        to = i);
       EMomerr_hndlr(status, ret_end, errmsg);
       EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

       if (is_right)
       {
          point1[0] = start_pnt[0];
          point1[1] = start_pnt[1];
          point1[2] = start_pnt[2];
          point2[0] = end_pnt[0];
          point2[1] = end_pnt[1];
          point2[2] = end_pnt[2];
          spar.u = 0.0;
          epar.u = 1.0;
       }
       else
       {
          point1[0] = end_pnt[0];
          point1[1] = end_pnt[1];
          point1[2] = end_pnt[2];
          point2[0] = start_pnt[0];
          point2[1] = start_pnt[1];
          point2[2] = start_pnt[2];
          spar.u = 1.0;
          epar.u = 0.0;
       }

       status = om$send(msg = message GRcurve.GRptalong(&msg_loc,
                              matrix_type, matrix, point1, point2, &spar,
                              &epar, &distance, out_point),
                        p_chanselect = &to_comps,
                        from = i,
                        to =i);
       EMomerr_hndlr(status, ret_end, errmsg);
       EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

       goto ret_end;
    }
    else
       distance -= arclength;

    if (is_right)  i = i + 1;
    else  i = i - 1;

  }  /* end while */


ret_end:
	return(status);

}

end implementation GRcompcurve;
