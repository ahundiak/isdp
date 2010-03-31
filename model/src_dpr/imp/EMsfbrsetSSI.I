/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "OMmacros.h"

extern OMuword OPP_EMSsolid_class_id;

method EMresetSSI(IGRlong *EMmsg)
/*
Description
    This message will reset the SSI instance data to zero.

Return Values    
    EMSS_S_Success if all is well.

Notes

History
    DLB 09/05/90 Fixed code to use EMputRI instead of directly putting ri plane
                 in instance data.  Note this is not a bug fix but a
                 right-thing-to-do fix.
    DLB 11/11/89 Modified to use EMgetRI to get ri plane.
    DLB 12/13/88 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  union EMSri_table *ri=NULL;


  *EMmsg = EMS_S_Success;

  ME.EMSsfregmod->num_surfaces = 0;
  ME.EMSsfboolean->num_composites = 0;

  if (!EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                         OPP_EMSsolid_class_id, FALSE))
  {
    /*This code is added for the saveside on composite surface.
     * The plane is stored on the end of the vla and is used to recompute the
     * saveside.  Therefore, it is important not to destroy this info.
     */
    ri = NULL;
    OM_stat = om$send(msg = message EMSdpr.EMgetRI(EMmsg, &ri),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (ri)
    {
      /*Collapse vla.*/
      om$vla_set_dimension(varray = ME.EMSdpr->ids, size = 1);      

      /*Now resave the RI plane. - modified by DLB 9/5/90*/
      OM_stat = om$send(msg = message EMSdpr.EMputRI(EMmsg, ri),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      /**** REMOVED OLD WAY OF RESTORE - DLB 9/5/90
              ME.EMSdpr->ids[0] = ri->saveside_info.plane_id;
      ****/
    }
  }
  else
  {
    om$vla_set_dimension(varray = ME.EMSdpr->ids, size = 0);
  }

  om$vla_set_dimension(varray = ME.EMSsfregmod->in_out, size = 0);

wrapup:
  if (ri) om$dealloc(ptr = ri);
  EMWRAPUP(*EMmsg, OM_stat, "sfb.rsetSSI");
  return(OM_stat);
}
end implementation EMSsfboolean;
