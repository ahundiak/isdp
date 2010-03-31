/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "EMSdpr.h"
#include "OMmacros.h"
#include "emsdef.h"

method EMnodeBrokeApart(IGRlong *EMmsg; 
                        GRobjid original_node_id;
                        GRobjid new_node_id;         
                        IGRint num_comp_moved;
                        GRobjid *comp_moved_ids;
                        IGRushort options)
/*
Description
    This message notifies and owner DPR nodes that a node in history broke
    apart.  Any node that is interested, needs to override this message in
    order to update its SSI.

Return Values
    EMS_S_Success if all is well.

Notes
    About parameters:
      original_node_id - id of the node that has broken apart.
      node_node_id - the node created from the original.
      num_comp_moved - number of component nodes that were moved to the new
                       node.
      comp_moved_ids - the moved component nodes.
      options - currently unused.

History
    DLB 01/09/89 Creation.
*/
{
  IGRlong                  OM_stat=OM_S_SUCCESS;
  union EMSssi_table       *ssi=NULL;
  struct EMSboolssi_table  *my_info;
  union EMSri_table        *ri=NULL;
  OM_S_CHANSELECT          to_owners;
  IGRboolean               SSI_changed=FALSE, composite_added=FALSE;
  void                     EFcompositeSSIchanged();


  *EMmsg = EMS_S_Success;

  my_info = NULL;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  my_info = &ssi->bool_info;

  EFcompositeSSIchanged(EMmsg,
                        &my_info->num_composites, 
                        &my_info->composite_ids,
                        &my_info->num_surfaces_out,
                        my_info->surface_out_ids,
                        my_info->composite_indices,
                        num_comp_moved,
                        comp_moved_ids,
                        original_node_id,
                        new_node_id,
                        &SSI_changed, &composite_added);
  if (!(1 & *EMmsg)) goto wrapup;                               

  if (SSI_changed)
  {
    OM_stat = om$send(msg = message EMSdpr.EMgetRI(EMmsg, &ri),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    OM_stat = om$send(msg = message EMSdpr.EMputSSI(EMmsg, ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (ri)
    {
      OM_stat = om$send(msg = message EMSdpr.EMputRI(EMmsg, ri),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

  /*Send on up.*/
  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  OM_stat = om$send(msg = OPPmargs,
                    p_chanselect = &to_owners);
  if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
  OM_stat = OM_S_SUCCESS;

  wrapup:
    if (composite_added) 
    {
      if (my_info->composite_ids) om$dealloc(ptr = my_info->composite_ids);
      if (my_info->num_surfaces_out) 
                                  om$dealloc(ptr = my_info->num_surfaces_out);
    }
    if (ssi) om$dealloc(ptr = ssi);
    if (ri) om$dealloc(ptr = ri);

    EMWRAPUP(*EMmsg, OM_stat, "EMSsfboolean.EMnodeBrokeApart")
    return(OM_stat);
}

void EFcompositeSSIchanged(EMmsg,
                           num_composites, 
                           composite_ids,
                           num_surfaces_out,
                           surface_out_ids,
                           composite_indices,
                           num_comp_moved,
                           comp_moved_ids,
                           original_node_id,
                           new_node_id,
                           SSI_changed,
                           composite_added)
IGRlong     *EMmsg;
IGRint      *num_composites;
GRobjid     **composite_ids;
IGRint      **num_surfaces_out;
GRobjid     *surface_out_ids;
IGRint      *composite_indices;
IGRint      num_comp_moved;
GRobjid     *comp_moved_ids;
GRobjid     original_node_id;
GRobjid     new_node_id;
IGRboolean  *SSI_changed, *composite_added;
{
  IGRlong   OM_stat=OM_S_SUCCESS;
  IGRint    ii, jj, kk, num_moved, composite_inx;
  GRobjid   *sf_out, *comp_ids=NULL;
  IGRint    *num_surfs_out=NULL;


  /*See if any out surfaces are also comp_moved_ids*/
  num_moved = 0;
  sf_out = surface_out_ids;
  for(ii=0; ii<*num_composites; ii++)
  {
    if ((*composite_ids)[ii] == original_node_id)
    {
      /*Possible affected case.*/
      for(jj=0; jj<(*num_surfaces_out)[ii]; jj++, sf_out++)
      {
        for(kk=0; kk<num_comp_moved; kk++)
        {
          if (*sf_out == comp_moved_ids[kk])
          {
            /*Got a moved surface out*/
            num_moved++;
            break;
          }
        } 
      }
      composite_inx = ii;
      break;
    }
  }

  if (num_moved)
  {
    *SSI_changed = TRUE;

    /*Did all surfs removed get moved up?*/
    if (num_moved == (*num_surfaces_out)[composite_inx])
    {
      /*Yea, nice case.  Only change composite id.*/
      *composite_added = FALSE;
      (*composite_ids)[composite_inx] = new_node_id;
    }     
    else
    {
      IGRint tmp_inx, total_sf_out, sf_out_inx;

      /*No. Must add new node to composite id list and moved surfs removed to
       * surf out ids list (and comp inx to comp inx list).  Also
       * must remove moved surfs from existing surf list and decrement
       * num surfs out cnt.
       */

      /*Since the SSI table is just one partitioned array. I must allocate the
       * pieces that I change rather than reallocing the existing ones.
       */
      *composite_added = TRUE;

      comp_ids = (GRobjid *) om$malloc
                 (size = (*num_composites + 1) * sizeof(GRobjid));
      if (!comp_ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

      OM_BLOCK_MOVE(*composite_ids,
                    comp_ids,
                    *num_composites * sizeof(GRobjid));

      *composite_ids = comp_ids;

      num_surfs_out = (IGRint *) om$malloc
                      (size = (*num_composites + 1) * sizeof(IGRint));
      if (!num_surfs_out) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

      OM_BLOCK_MOVE(*num_surfaces_out,
                    num_surfs_out,
                    *num_composites * sizeof(IGRint));

      *num_surfaces_out = num_surfs_out;

      /*Now move the moved surfs out to the end of the array.*/
      total_sf_out = 0;
      sf_out_inx = 0;

      for(ii=0; ii<*num_composites; ii++)
      {
        if (ii == composite_inx) sf_out_inx = total_sf_out;
        total_sf_out += (*num_surfaces_out)[ii];
      }

      for(ii=sf_out_inx; ii<(*num_surfaces_out)[composite_inx];) /*NO INC*/
      {
        for(jj=0; jj<num_comp_moved; jj++)
        {
          if (surface_out_ids[ii] == comp_moved_ids[jj])
          {
            OM_BLOCK_MOVE(&surface_out_ids[ii+1],
                          &surface_out_ids[ii],
                          (total_sf_out - ii - 1) * sizeof(GRobjid));
            surface_out_ids[total_sf_out-1] = comp_moved_ids[jj];

            tmp_inx = composite_indices[ii];
            OM_BLOCK_MOVE(&composite_indices[ii+1],
                          &composite_indices[ii],
                          (total_sf_out - ii - 1) * sizeof(GRobjid));
            composite_indices[total_sf_out-1] = tmp_inx;

            (*num_surfaces_out)[composite_inx]--;
            break;
          }
        }
        if (num_comp_moved == jj) ii++;
      }  

      (*composite_ids)[*num_composites] = new_node_id;
      (*num_surfaces_out)[*num_composites] = num_moved;
      (*num_composites)++;      
    }
  }
  else *SSI_changed = FALSE;

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EFcompositeSSichanged")
    return;
}
end implementation EMSsfboolean;

