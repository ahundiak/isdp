/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function returns a point on the input surface 
 which is in the middle of a non-seam natural boundary/edge.
 This signfies the closest edge to the input point/event.

 Results

 event->event.button.xyz
  Model space point on the closest boundary
 event->located_object[0].geom_parms.uv
  Parameteric space point
 event->located_object[0].geom_parms.polygoninx
  one of BSULEFTBND, BSVLEFTBND, BSURIGHTBND, BSVRIGHTBND.  This
  indicates the closest side.

 Bugs

 I assume that the surface is parameterized from 0.0 to 1.0.

 History

 11/14/87 : rlw : Creation date
 */

class implementation Root;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"		/* Includes everything */
#include "bsconic.h"		/* BSULEFTBND, etc. */

#define u_low 0.0
#define u_hig 1.0
#define v_low 0.0
#define v_hig 1.0

from EMSsubbs import EMptatpr;
from EMSsubbs import EMgetbsdef;

IGRlong EFfind_closest_side(
 located_object,		/* Contains the object */
 event,				/* Contains the point */
 my_stupid_id,
 msg)

struct		GRlc_info *located_object;
struct		GRevent *event;
OM_S_OBJID	my_stupid_id;
IGRlong		*msg;

{
 IGRlong	sts;
 IGRpoint	*point;
 struct		GRparms *parms;
 struct		GRid *id;
 struct		GRmdenv_info *mdenv_info;
 struct		IGRbsp_surface surface;
/*
 * Initialize
 */
 *msg = MSSUCC;
 point = (IGRpoint *)&event->event.button.x;
 parms = &event->located_object[0].geom_parms;
 id = &located_object->located_obj;
 mdenv_info = &located_object->module_info.md_env;
/*
 * Get a point on the required object
 */
 sts = EFpoint_on_object(
   located_object,
   event,
   my_stupid_id,
   msg);
  if (! (1 & sts)) goto wrapup;
/*
 * Get the surfaces properties in
 * order to determine whats closed
 * and such
 */
 sts = om$send(
   msg = message EMSsubbs.EMgetbsdef(
    msg,
    &surface),
   senderid = my_stupid_id,
   targetid = id->objid,
   targetos = id->osnum);
  if (! (1 & sts)) goto wrapup;
/*
 * Find the closest side
 */
 {
  IGRlong	i, closest_side, start_index, end_index;
  IGRdouble	distance, distance_to_side[4], u_mid, v_mid;

  if (surface.u_phy_closed)
   {
    if (surface.v_phy_closed)
     {
      *msg = MSINARG;
      goto wrapup;
     }
    start_index = 2;
    end_index = 4;
   }
  else
   {
    start_index = 0;
    if (surface.v_phy_closed)
     end_index = 2;
    else
     end_index = 4;
   }
  distance_to_side[0] = parms->u - u_low;
  distance_to_side[1] = u_hig - parms->u;
  distance_to_side[2] = parms->v - v_low;
  distance_to_side[3] = v_hig - parms->v;
  distance = 1.0e38;;
  for (i = start_index; i < end_index; i++)
   {
    if (distance_to_side[i] < distance)
     {
      closest_side = i;
      distance = distance_to_side[i];
     }
   } /* for (i = 1; i < 4; i++) */
  u_mid = (u_hig - u_low) / 2.0;
  v_mid = (v_hig - v_low) / 2.0;
  switch (closest_side)
   {
    case 0:
     parms->u = u_low;
     parms->v = v_mid;
     parms->polygon_inx = BSULEFTBND;
     break;
    case 1:
     parms->u = u_hig;
     parms->v = v_mid;
     parms->polygon_inx = BSURIGHTBND;
     break;
    case 2:
     parms->u = u_mid;
     parms->v = v_low;
     parms->polygon_inx = BSVLEFTBND;
     break;
    case 3:
     parms->u = u_mid;
     parms->v = v_hig;
     parms->polygon_inx = BSVRIGHTBND;
     break;
    default:
     *msg = MSFAIL;
     goto wrapup;
   } /* switch (closest_side) */
 }
/*
 * Get the model space coordinate on
 * the closest edge
 */
 sts = om$send(
   msg = message EMSsubbs.EMptatpr(
    msg,
    &mdenv_info->matrix_type,
    mdenv_info->matrix,
    &parms->u,
    2,
    *point),
   senderid = my_stupid_id,
   targetid = id->objid,
   targetos = id->osnum);
  if (! (1 & sts)) goto wrapup;
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
