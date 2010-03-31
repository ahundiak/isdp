class implementation EMSdpr;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"
#include "emsdef.h"

from EMSsurface import EMgetSurfsOfPrim;

#define SURF_BUF_INCR  20

void EFgetInGeomInfo(EMmsg, objid, osnum, inlist, uneval_sender_id,
                     is_kd_on, incr, options) 
IGRlong           *EMmsg; 
GRobjid           objid;
OMuword           osnum;
struct EMSinlist  *inlist; 
GRobjid           uneval_sender_id; 
IGRboolean        is_kd_on; 
IGRint            incr;
IGRushort options;
/*
Description
    This function sends EMgetInGeom and fills the inlist struct with the
    surfaces and their loops & edges.

Return Values    
    EMSS_S_Success if all is well.

Notes
    This node must be the active state in order to return correct in
    information.  

    About parameters:
        objid - objid in question.
        osnum - dito.
        inlist  - contains surf/loop/edge ids that have been added so far.
                  This structure may be passed this info aready in it.  
                  The memory may be malloc'd or realloc'd as necessary.
        uneval_sender_id - the id of the node that defines the path of
                           deactivation. 
        is_kd_on  - indicates whether this node recieved a EMdeactivateState
                    message with the KD flag turned on.
        incr - realloc incr.
        options - None so far.

History
    DLB 01/11/93 Fixed bug where EMgetInGeomIds may return composites instead
                 of simple surfaces.  Unroll such animals to their simple
                 surfaces.
    DLB 12/08/92 Added EFget_InGeomIds_removed_by_next_dprs call.
    DLB 02/13/91 Use EFalloc_list function.
    DLB 11/08/90 Creation - cut out of EMgetInInfo..
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  surf_cnt=0, surf_list_sz=0, base_surf_cnt,
                          ii, jj, tmp_cnt;
  GRobjid                 tmp_id;
  GRobjid                 *surf_list=NULL;
  void                    EFgetLoopsEdges(), EFalloc_list(), EFgetcomponents();
  IGRlong                 EFget_InGeomIds_removed_by_next_dprs();
  extern OMuword          OPP_EMScompsurf_class_id, OPP_EMSsubbs_class_id;


  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSdpr.EMgetInGeomIds(EMmsg,
                          uneval_sender_id, is_kd_on, &surf_cnt, &surf_list,
                          options), 
                    senderid = objid,
                    targetid = objid,
                    targetos = osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*See if any of the returned in-geom dudes are not simple surfaces.  If
   * so then unroll the composites into their atomic simple surfaces.  However,
   * keep the composite ids in the list and add their surfaces to the end.
   */
  base_surf_cnt = surf_list_sz = surf_cnt;

  for(ii=0; ii<base_surf_cnt; ii++)
  {
    /*Is it a composite?*/
    if (EFisAncestryValid(EMmsg, surf_list[ii], osnum,
                          OPP_EMScompsurf_class_id, FALSE))
    {
      /*Got one*/
      IGRuint       comp_cnt=0;
      struct GRid   *comp_lst=NULL;
      
      EFgetcomponents(EMmsg, surf_list[ii], surf_list[ii], osnum,
                      &comp_cnt, &comp_lst);
      if (!(1 & *EMmsg)) goto wrapup;
    
      EFalloc_list(EMmsg, 
                   &surf_list,
                   surf_cnt, 
                   &surf_list_sz,
                   comp_cnt, SURF_BUF_INCR, NULL);
      if (!(1 & *EMmsg)) goto wrapup;
      
      for(jj=0; jj<comp_cnt; jj++)
      {
        surf_list[surf_cnt] = comp_lst[jj].objid;
        surf_cnt++;
      }

      if (comp_lst) om$dealloc(ptr = comp_lst);
    }
  }                           

  OM_stat = EFget_InGeomIds_removed_by_next_dprs(EMmsg, objid, objid, osnum,
                                                 &surf_cnt, &surf_list,
                                                 &surf_list_sz);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
                                                   
  EFalloc_list(EMmsg, &inlist->sflist.surf_ids,
               inlist->sflist.num_surfs, 
               &inlist->sflist.array_size,
               surf_cnt, incr, NULL);
  if (!(1 & *EMmsg)) goto wrapup;

  tmp_cnt = inlist->sflist.num_surfs;
  for (ii=0; ii<surf_cnt; ii++) 
  {
    tmp_id = surf_list[ii];

    /*Do I already have this surface?*/
    for(jj=0; jj<tmp_cnt; jj++)
    {
      if (inlist->sflist.surf_ids[jj] == tmp_id) break;
    }

    if (jj == tmp_cnt)
    {
      /*Nope.*/
      inlist->sflist.surf_ids[inlist->sflist.num_surfs++] = tmp_id;

      if (EFisAncestryValid(EMmsg, surf_list[ii], osnum,
                            OPP_EMSsubbs_class_id, FALSE))
      {
        EFgetLoopsEdges(EMmsg, 1, &tmp_id,
                        &inlist->lplist.array_size,
                        &inlist->lplist.num_loops,
                        &inlist->lplist.loop_ids,
                        &inlist->edlist.array_size,
                        &inlist->edlist.num_edges,
                        &inlist->edlist.edge_ids,
                        osnum);
        if (!(1 & *EMmsg)) goto wrapup;
      }
    }
  }

wrapup:
  if (surf_list) om$dealloc(ptr = surf_list);
  EMWRAPUP(*EMmsg, OM_stat, "EFgetInGeomInfo")
  return;
}

IGRlong EFget_InGeomIds_removed_by_next_dprs(EMmsg, dpr_id, composite_id,
                                             osnum, 
                                             surf_cnt, surf_list, surf_list_sz)
IGRlong     *EMmsg;
GRobjid     dpr_id;
GRobjid     composite_id;
OMuword     osnum;
IGRint      *surf_cnt;
GRobjid     **surf_list;
IGRint      *surf_list_sz;

/*
Description 
    Handle situation where in_geom_ids of a DPR operation must be determined
    because next state dpr operations have removed added surfaces from the
    dpr.

Notes
    Caller should pass *surf_cnt =0,
                       *surf_list = NULL,
                       *surf_list_sz = 0.
        or with valid memory, list size, and count a.k.a. initialize!
    Caller should free surf_list via om$dealloc.                       

History
    DLB     12/08/92    Creation.
*/

{
  IGRlong   OM_stat=OM_S_SUCCESS;
  OMuint    comps_cnt, ii;
  IGRint    tmp_num_surfs=0, tmp_num_active=0;
  GRobjid   comp_id, *tmp_surf_list=NULL;
  OM_S_CHANSELECT to_comps, to_owners;
  OMuword         dumosnum;
  extern OMuword  OPP_EMScompsurf_class_id;
  void            EFalloc_list();


  *EMmsg = EMS_S_Success;

  if (composite_id == dpr_id)
  {
    IGRushort dpr_props;

    /*First time in so see if there is anything to do.  If top state OR
     * the model has been undone to me then no need in checking for 
     * next dpr removal of my surfs.
     */
    OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg, &dpr_props),
                      senderid = dpr_id,
                      targetid = dpr_id,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    
    if (dpr_props & EMSIS_ACTIVE_STATE) goto wrapup; /*all is well*/
  }                      

  if (!EFisAncestryValid(EMmsg, composite_id, osnum, OPP_EMScompsurf_class_id,
                         FALSE)) goto wrapup;

  /*Get the ids removed from the current composite_id.*/
  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  OM_stat = om$send(msg = message EMSsurface.EMgetSurfsOfPrim(EMmsg,
                          composite_id, 
                          &tmp_surf_list, &tmp_num_surfs, &tmp_num_active),
                    senderid = dpr_id,
                    targetos = osnum,
                    p_chanselect = &to_owners);
  if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
  else if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (tmp_num_surfs && tmp_surf_list)
  {
    EFalloc_list(EMmsg, 
                 surf_list,
                 *surf_cnt, 
                 surf_list_sz,
                 tmp_num_surfs, SURF_BUF_INCR, NULL);
    if (!(1 & *EMmsg)) goto wrapup;

    OM_BLOCK_MOVE(tmp_surf_list, 
                  &(*surf_list)[*surf_cnt], 
                  tmp_num_surfs * sizeof(GRobjid));

    (*surf_cnt) += tmp_num_surfs;

    om$dealloc(ptr = tmp_surf_list);
    tmp_surf_list = NULL;
  }

  /*Go on down to any composites the composite_id has as components and
   * do it all again.
   */
  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  OM_stat = om$get_channel_count(objid = composite_id,
                                 osnum = osnum,
                                 p_chanselect = &to_comps,
                                 count = &comps_cnt);
  if (!(1 & OM_stat)) goto wrapup;

  if (comps_cnt <= 1) goto wrapup;

  for(ii=1; ii<comps_cnt; ii++)
  {
    OM_stat = om$get_objid_at_index(objid = composite_id,
                                    osnum = osnum,
                                    p_chanselect = &to_comps,
                                    index = ii,
                                    objidaddr = &comp_id,
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;                                    

    OM_stat =  EFget_InGeomIds_removed_by_next_dprs(EMmsg, 
                               dpr_id, comp_id, osnum, 
                               surf_cnt, surf_list, surf_list_sz);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

wrapup:    
  if (tmp_surf_list) om$dealloc(ptr = tmp_surf_list); /*safety check*/
  EMWRAPUP(*EMmsg, OM_stat, "EFget_InGeomIds_removed_by_next_dprs")
  return(OM_stat);
}
end implementation EMSdpr;
