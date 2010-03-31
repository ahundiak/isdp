/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"

#define INCREMENT 50        /*For booleans use a large increment.*/

method EMgetInInfo(IGRlong *EMmsg; 
                   struct EMSinlist *inlist; 
                   GRobjid uneval_sender_id; 
                   IGRboolean is_kd_on; 
                   IGRushort options)
/*
Description
    This message will return the in information for this state by adding it
    to the existing inlist.  This includes the surfaces of the state being
    unevaluated (if one exists). 

Return Values    
    EMSS_S_Success if all is well.

Notes
    This node must be the active state in order to return correct in
    information.  

    About parameters:
        inlist  - contains surf/loop/edge ids that have been added so far.
                  This structure may be passed this info aready in it.  
                  The memory may be malloc'd or realloc'd as necessary.
        uneval_sender_id - the id of the node that defines the path of
                           deactivation. 
                          if (options & EMget_in_inf_SHELL_ALL_DEP || is_kd_on)
                          then this may be passed as NULL_OBJID.
        is_kd_on  - indicates whether this node recieved a EMdeactivateState
                    message with the KD flag turned on.
        options - EMget_in_inf_SHELL_ALL_DEP if set all of the surfaces of the
                  uneval node will be gotten.  Otherwise, only those that are
                  affected by this operation will be gotten.

History
    DLB 05/22/91 Support new options.
    DLB 03/13/91 Support SURFS_ONLY option.
    DLB 01/28/91 Use EFget_ininfo_from_lpinfo and EFalloc_list.
    DLB 11/08/90 Modified to use EMgetInGeomIds instead of EMgetUnevalIds. 
                 This message is send by EMgetInGeomIds and is therefore wasted
                 code in this method.  Also changed env param in EMgetInGeomIds
                 to is_kd_on.   Broke out EMgetInGeomIds to a separate function
                 EFgetInGeomInfo.
    DLB 10/19/89 Change code to use EFgetEdgesAddRemModUnchg.  Note that this
                 node must be active for in information to be returned 
                 correctly.
    DLB 10/04/89 Added EFgetLoopsEdges call when getting a surface.
    DLB 09/06/89 Again changed logic as follows:
                 if (shelling dependent)
                    get all loops in, all edges in, and surfaces in of dep.
                 else
                    get all loops in, all edges in
    DLB 07/25/89 Changed logic to add only affected surfaces of uneval node to
                 in list.
    DLB 06/19/89 Modified to add newly created edges to the edges in list.
    DLB 12/07/88 Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  union EMSssi_table      *ssi=NULL;
  struct EMSboolssi_table *my_info=NULL;
  extern IGRlong          EFget_ininfo_from_lpinfo();
  extern void             EFgetInGeomIds();


  *EMmsg = EMS_S_Success;

  if (!(options & EMget_in_inf_NO_SURFS) &&
      (options & EMget_in_inf_SHELL_ALL_DEP) ||
      is_kd_on)
  {
    /*Get all added surfaces (for booleans it the surf of the the nodes being
     * unevaluated.
     */ 
    EFgetInGeomInfo(EMmsg, my_id, OM_Gw_current_OS, inlist, uneval_sender_id,
                    is_kd_on, INCREMENT, NULL); 
    if (!(1 & *EMmsg)) goto wrapup;
  }

  if (!((options & EMget_in_inf_NO_LOOPS) && 
        (options & EMget_in_inf_NO_EDGES) && 
        (options & EMget_in_inf_NO_EDGES_FROM_LOOPS)))
  {
    /*Get in info for this state.*/
    OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    
  
    my_info = &ssi->bool_info;
  
    OM_stat = EFget_ininfo_from_lpinfo(EMmsg,
                                       my_info->num_surfaces,
                                       my_info->num_regions_in,
                                       my_info->num_regions_out,
                                       my_info->region_in_ids,
                                       my_info->region_out_ids,
                                       inlist, OM_Gw_current_OS, options);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "sfb.getInInfo")
  return(OM_stat);
}
end implementation EMSsfboolean;

#ifdef LEFT_OUT_BUT_KEPT_IN_ORDER_TO_REMEMBER_WHAT_I_DID
  if (!(options & EMget_in_inf_SHELL_ALL_DEP) && !is_kd_on)
  {
    /*Get only the affected surfaces of this node.*/
    tmp_cnt = my_info->num_surfaces + inlist->sflist.num_surfs;
    if (inlist->sflist.array_size < tmp_cnt) 
    {
      /*Perform realloc or malloc*/
      tmp_cnt += INCREMENT;
      if (inlist->sflist.array_size)
      {
        inlist->sflist.surf_ids = (GRobjid *) om$realloc 
                                           (ptr = inlist->sflist.surf_ids, 
                                            size = tmp_cnt * sizeof(GRobjid));
      }
      else
      {
        inlist->sflist.surf_ids = (GRobjid *) om$malloc 
                                           (size = tmp_cnt * sizeof(GRobjid));
      }
      if (!inlist->sflist.surf_ids)
      {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
      inlist->sflist.array_size = tmp_cnt;
    }

    tmp_cnt = inlist->sflist.num_surfs;
    for (ii=0; ii<my_info->num_surfaces; ii++) 
    {
      tmp_id = my_info->surface_ids[ii];

      /*Do I already have this surface?*/
      for(jj=0; jj<tmp_cnt; jj++)
      {
        if (inlist->sflist.surf_ids[jj] == tmp_id) break;
      }

      if (jj == tmp_cnt)
      {
        /*Nope.*/
        inlist->sflist.surf_ids[inlist->sflist.num_surfs++] = tmp_id;
      }
    }
  }  
#endif
