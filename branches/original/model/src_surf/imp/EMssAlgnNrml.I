/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "msmacros.h"
# include "EMSssprops.h"
# include "bserr.h"
# include "psdinc.h"

method EMalgnnrml(IGRlong *EMmsg;
                  IGRushort options;
                  IGRshort *pos_orient;
                  IGRpoint orientation_point;
                  struct GRmd_env *surf_env)
/*
Description

    This method will flag the pos orient bit of the surface based
    on whether orientation_point lies on the natural side of the surface
    or not.

    Input
      orientation_point      -    any point lying on the solid side
                               of the surface
      surf_env            -    module environment information of the
                               surface

    Output
      EMmsg               -    pointer to completion code

Notes

    Upon exit the completion code will be one of the following

    MSSUCC            -    if successful
    MSFAIL               -    otherwise


Algorithm
  1.    Get the abstract geometry of the surface.
  2.    Determine if the orientation_point is lying on natural side
        of the surface or not.
  3.    Appropriately modify the surface properties bit.

   
History
 
    PP      :  01/01/87         design date
    NP      :  08/24/92 	Changed "num_of_bytes" to IGRlong for ANSI compliance
*/
      
{
 IGRlong                num_of_bytes; /* for memory allocation purposes */
 BSrc                   rc;           /* Math completion status */


 IGRlong                status;       /* OM return code */
 IGRlong                loc_sts;

 IGRboolean             nat_side;     /* true if point in solid is lying
                                         on natural side of the surface

                                         false otherwise */



 struct                 IGRbsp_surface *surf;
                                      /* pointer to the abstract geometry
                                         of the surface */

 IGRchar                str[EMMAXERRMSG_LEN];

  extern  void                   BSptonnsdsf (); 
                                      /* Function declaration */


 /*
  * Initialization
  */
 *EMmsg = MSSUCC;
 status = OM_S_SUCCESS;
 surf = NULL;
 strcpy(str, "EMSsubbs.EMalgnnrml");

 if (options & EMS_SET_POS_ORIENT)
 {
  if (pos_orient && !(orientation_point)) /* if pos orient bit is set and 
                                             there is no orienation point
                                             coming in */
  {
   if (! (*pos_orient))
     me^^EMSsubbs.ss_props = me^^EMSsubbs.ss_props | EMSIS_NRML_REVERSED;
   else 
     me^^EMSsubbs.ss_props = me^^EMSsubbs.ss_props & (~EMSIS_NRML_REVERSED);

   loc_sts = GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);
  }
  else if (orientation_point)
  {
  if (!surf_env)
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }
 status = om$send (mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetsize (EMmsg,
                         &surf_env->md_env.matrix_type,
                         surf_env->md_env.matrix,
                         &num_of_bytes),
                   senderid = my_id,
                   targetid = my_id);
 EMomerr_hndlr_action(status, goto wrapup, "return from GRgetsize")

 surf = (struct IGRbsp_surface *) om$malloc (size = num_of_bytes);
 EMerr_hndlr_action(surf == NULL, *EMmsg, MSNOMEM, goto wrapup)

 status = om$send (mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetgeom (EMmsg,
                         &surf_env->md_env.matrix_type,
                         surf_env->md_env.matrix,
                         (IGRchar *) surf),
                   senderid = my_id,
                   targetid = my_id);
 EMomerr_hndlr_action(status, goto wrapup, "return from GRgetgeom")
 surf->num_boundaries = 0;
 
 (void) BSptonnsdsf (surf, orientation_point, &nat_side, &rc);
 EMerr_hndlr_action(rc != BSSUCC, *EMmsg, MSFAIL, goto wrapup)

 if (! nat_side)
  me^^EMSsubbs.ss_props = me^^EMSsubbs.ss_props | EMSIS_NRML_REVERSED;
 else 
  me^^EMSsubbs.ss_props = me^^EMSsubbs.ss_props & (~EMSIS_NRML_REVERSED);

 loc_sts = GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);

 if (options & EMS_POINT_OUT_OF_SOLID)
  me^^EMSsubbs.ss_props ^= EMSIS_NRML_REVERSED;
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }
}

 if (options & EMS_GET_POS_ORIENT)
 {
  if (me^^EMSsubbs.ss_props & EMSIS_NRML_REVERSED)
   *pos_orient = 0;
  else
   *pos_orient = 1;
 }
 

wrapup:
 if (surf) om$dealloc (ptr = (IGRchar *) surf);
 return (status);
}

end implementation EMSsubbs;


