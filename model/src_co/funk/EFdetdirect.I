/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This functions determines if the input curve object is flowing
 in the correct direction.  This is done by using the input point
 to determine which endpoint of the input curve is closer to
 the boreline.

 Return Values

 polygon_inx                    TRUE, if curve needs to be reversed
                                FALSE, if curve direction is ok
 Notes

 Closed curves are not handeled very intelligently.
 
 History

 12/19/87 : rlw : Creation date
 02/16/88 : rlw : Modified such that coordinate of input event is
                  modified to reflect the closest endpoint.
 Sudha   06/02/93        modified to include for BSprototype headers
 */

class implementation Root;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"          /* Includes everything */
#include "OMmacros.h"           /* OM block move */
#include <alloca.h>
#include "maptlnpro.h"
#include "ma2pt2di.h"

from GRcurve import GRendpts;
from GRvg import EMpratpt;

IGRlong EFdetermine_direction(
 event,
 my_stupid_id,
 msg)

struct          GRevent *event;
OM_S_OBJID      my_stupid_id;
IGRlong         *msg;

{
 IGRboolean     *curve_is_reversed;
 IGRpoint       end_points[2];
 struct         GRlc_info *located_object;
/*
 * Initialize
 */
 *msg = MSSUCC;
 located_object = &event->located_object[0];
 curve_is_reversed = &located_object->geom_parms.polygon_inx;
 *curve_is_reversed = FALSE;
/*
 * Get the curve endpoints
 */
 {
  IGRlong       sts;
  struct        GRid *located_object_id;
  struct        GRmdenv_info *mdenv_info;

  located_object_id = &located_object->located_obj;
  mdenv_info = &located_object->module_info.md_env;
  sts = om$send(
    msg = message GRcurve.GRendpts(
     msg,
     &mdenv_info->matrix_type,
     mdenv_info->matrix,
     end_points[0],
     end_points[1]),
    senderid = my_stupid_id,
    targetid = located_object_id->objid,
    targetos = located_object_id->osnum);
   if (! (1 & sts)) goto wrapup;
 }
/*
 * Determine if this event was a locate by name or a locate
 * by data point.
 */
 if (event->response == EX_DATA)
  {
   IGRlong      sts;
   struct       GRprops properties;
/*
 * Determine if this curve is physically closed
 * or not
 */
   sts = EFgetprops(
     event,
     my_stupid_id,
     &properties,
     msg);
    if (! (1 & sts)) goto wrapup;
   if (properties.phy_closed)
    {
        /*DLB - Added support for closed curves.*/
        IGRdouble      u_parm;

        if (located_object->located_obj.objid != 
            located_object->geom_parms.leaf_id.objid ||
            located_object->located_obj.osnum != 
            located_object->geom_parms.leaf_id.osnum)
        {
          IGRint num_parm;

          /*Got a composite curve so must compute u parm from merged curve.*/
          sts = om$send(msg = message GRvg.EMpratpt(msg,
                              &located_object->module_info.md_env.matrix_type,
                              located_object->module_info.md_env.matrix,
                              located_object->proj_pnt,
                              &u_parm, &num_parm),
                        senderid = NULL_OBJID,
                        targetid = located_object->located_obj.objid,
                        targetos = located_object->located_obj.osnum);
          if (!(1 & sts & *msg)) goto wrapup;
        }
        else u_parm = located_object->geom_parms.u;
                   
        if (u_parm > 0.5) *curve_is_reversed = TRUE;
    } /* if (properties.phy_closed) */
/*
 * Get the view boreline
 */
   else
    {
     IGRboolean status, EFboreline();
     IGRlong    i;
     IGRdouble  t, distance[2];
     IGRpoint   point1, point2;
     IGRpoint   projected_point;
     struct     IGRline bore_line;

     bore_line.point1 = &point1[0];
     bore_line.point2 = &point2[0];
     status = EFboreline(
       msg, 
       my_stupid_id, 
       event,
       &bore_line);
      if (! status) goto wrapup;
/*
 * Determine which endpoint is closer to the boreline
 */
     for (i = 0; i < 2; i++)
      {
       status = MAptlnproj(
         msg,
         end_points[i],
         &bore_line,
         projected_point,
         &t);
        if (! status) goto wrapup;
       status = MA2pt2dis(
         msg,
         end_points[i],
         projected_point,
         &distance[i]);
        if (! status) goto wrapup;
      } /* for (i = 0; i < 2; i++) */
     if (distance[1] < distance[0])
      *curve_is_reversed = TRUE;
    } /* ELSE FOR if (properties.phy_closed) */
  } /* if (event->response == EX_DATA) */
/*
 * Return the correct xyz point
 */
 if (*curve_is_reversed)
  OM_BLOCK_MOVE(
   end_points[1],
   &event->event.button.x,
   sizeof(IGRpoint));
 else
  OM_BLOCK_MOVE(
   end_points[0],
   &event->event.button.x,
   sizeof(IGRpoint));
/*
 * eof
 */
wrapup:
 if (1 & *msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation Root;
