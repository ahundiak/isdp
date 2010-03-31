/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "emsdef.h"         /*EMmake_chanselect def.*/
#include "EMSmsgdef.h"

extern OMuword OPP_EMSsubbs_class_id;

method EMgetInGeomIds(IGRlong *EMmsg; 
                      GRobjid nodes_side_id; 
                      IGRboolean is_kd_on; 
                      IGRint *num_in_geom_ids; 
                      GRobjid **in_geom_ids; 
                      IGRushort options)
/*
Description
    This message will get the geometry added by this operation.  The main user
    of this message will be the EMcheckRngOverlap message.

Return Values    
    EMS_S_Success if all is well.

Notes
    About parameters:
        node_id  - the added node which is being checked against.
        nodes_side_id - the component of this state that contains the
                        replacing node.  This is needed by some states 
                        such as booleans where in the added geometry can only
                        be determined relative to what has changed.  For local
                        operations this parameter MAY not be referenced.
        is_kd_on - indicates a known dependency and is an indicator of what is
                   added in a boolean op (which operand).
        num_in_geom_ids - returned num ids found.
        in_geom_ids - returned ids found.
        options - None so far.

History
    DLB 07/02/91 If ip-ss, the component plane is in geom.
    DLB 11/07/90 Mod to use get_members to get geom ids.
    DLB 10/17/89 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            num_ids=0, ii, jj, sf_count, maxGRid_count, tmp_count;
  GRobjid           *ids=NULL;  
  struct GRid       *GRids=NULL;
  union EMSri_table *ri=NULL;
  extern OMuword    OPP_EMSsolid_class_id;


  *EMmsg = EMS_S_Success;

  if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                        OPP_EMSsolid_class_id, FALSE))
  {
    OM_stat = om$send(msg = message EMSdpr.EMgetRI(EMmsg, &ri),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (ri)
    {
      /*This was an i p - save side op so only get the added plane*/
      *num_in_geom_ids = 1;
      *in_geom_ids = (GRobjid *) om$malloc(size = sizeof(GRobjid));
      if (! *in_geom_ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

      **in_geom_ids = ri->saveside_info.plane_id;
      goto wrapup; /*all done.*/
    }
  }

  /*Get the relative added nodes.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetUnevalIds(EMmsg, nodes_side_id,
                          is_kd_on, NULL, &num_ids, &ids),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Unwind the node ids into geometry GRobjids*/

  /*First find out how many surfs there are*/
  sf_count = 0;
  maxGRid_count = 0;
  for(ii=0; ii<num_ids; ii++)
  {
    if (!EFisAncestryValid(EMmsg, ids[ii], OM_Gw_current_OS, 
                           OPP_EMSsubbs_class_id, FALSE))
    {
      /*Got a composite so get its surfs count.*/
      tmp_count = 0;
      OM_stat = om$send(msg = message GRowner.GRget_number_components(EMmsg,
                              &tmp_count), 
                        targetid = ids[ii]);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      sf_count += tmp_count;
      if (tmp_count > maxGRid_count) maxGRid_count = tmp_count; 
    }
    else sf_count++;
  }

  if (!sf_count) 
  {
    *num_in_geom_ids = 0;
    *in_geom_ids = NULL;
    *EMmsg = EMS_I_NotFound;
    goto wrapup;
  }
  else if (maxGRid_count)
  {
    /*Alloc GRid array for max needed.*/
    GRids = (struct GRid *) stackalloc(maxGRid_count * sizeof(struct GRid));
    if (!GRids) {*EMmsg = EMS_E_NoStackMemory; goto wrapup;}
  }  

  *num_in_geom_ids = 0;
  *in_geom_ids = (GRobjid *) om$malloc(size = sf_count * sizeof(GRobjid));
  if (! *in_geom_ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  /*Go again getting the surfs.*/
  for(ii=0; ii<num_ids; ii++)
  {
    if (!EFisAncestryValid(EMmsg, ids[ii], OM_Gw_current_OS, 
                           OPP_EMSsubbs_class_id, FALSE))
    {
      /*The composite again.*/
      OM_stat = om$send(msg = message GRowner.GRget_components(EMmsg, NULL,
                              GRids, maxGRid_count, &tmp_count,
                              0, MAXINT),  
                        targetid = ids[ii]);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      for(jj=0; jj<tmp_count; jj++)
      {
        (*in_geom_ids)[*num_in_geom_ids] = GRids[jj].objid;
        (*num_in_geom_ids)++;
      }
    }
    else 
    {
      (*in_geom_ids)[*num_in_geom_ids] = ids[ii];
      (*num_in_geom_ids)++;
    }
  }

wrapup:
  if (ri) om$dealloc(ptr = ri);
  if (ids) om$dealloc(ptr = ids);
  if (GRids) stackfree(GRids);
  EMWRAPUP(*EMmsg, OM_stat, "sfb.getInGmIds")
  return(OM_stat);
}
end implementation EMSsfboolean;
