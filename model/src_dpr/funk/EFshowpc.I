class implementation EMSassoc;

#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "asbox.h" /* For NULL_GRID */
#include "nddef.h"
#include <alloca.h>
#include "OMmacros.h"
#include "EMSdpr.h"
#include "EMSprop.h"
#include "msmacros.h"

#define DEP_BUFF_INCR 30

from EMSdpr      import EMget_feature_definition, EMget_dpr_props,
                        EMcheckOverlap;
from EMSsurface  import EMget_tree_top, EMgetSurfsOfPrim;
from EMSboundary import EMgetsurface_info, EMget_objid;

#argsused
static IGRboolean EFis_part_of_id(EMmsg, id, internal_id, osnum, options)
IGRlong         *EMmsg;
GRobjid         id, internal_id;
OMuword         osnum, options;
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  GRobjid           top_comp_id=NULL_OBJID, tmp_id=NULL_OBJID,
                    tree_top_id=NULL_OBJID;
  extern OMuword    OPP_EMSboundaryr_class_id;
  
  *EMmsg = EMS_S_Success;

  if (EFisAncestryValid(EMmsg, internal_id, osnum, OPP_EMSboundary_class_id,
                        FALSE))
  {
    OM_stat = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg,
                            &tmp_id, NULL),
                      senderid = NULL_OBJID, 
                      targetid = internal_id,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      

    if (tmp_id == NULL_OBJID)
    {
      /*id is part of inactive topology!!*/
      *EMmsg = EMS_I_NotFound;
      goto wrapup;
    }
    else internal_id = tmp_id;
  }
    
  /*Get the top composite and the first dpr.*/
  OM_stat = om$send(msg = message EMSsurface.EMget_tree_top(EMmsg,
                                  &tree_top_id, &top_comp_id,
                                  EMget_tree_top_FIRST_DPR), 
                    senderid = NULL_OBJID, 
                    targetid = internal_id,
                    targetos = osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      

  if (tree_top_id == top_comp_id) 
  {
    /*id is part of inactive surface*/
    *EMmsg = EMS_I_NotFound; 
    goto wrapup;
  }
  else if (top_comp_id == id) return(TRUE);
  else return(FALSE);

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFis_part_of_id")
  return(FALSE);
}

#define SF_INCR 10

#argsused
IGRlong EFget_group_comp_ptrs(EMmsg, node_id, group_comp_id, osnum,
                              num_ptrs, ptrs, options)
IGRlong     *EMmsg;
GRobjid     node_id, group_comp_id;
OMuword     osnum;
IGRuint     *num_ptrs;
GRobjid     **ptrs;
OMuword     options;
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRuint           child_cnt, ptr_child_cnt, ii, jj;
  GRobjid           ptr_id, *surf_list=NULL;
  OM_S_CHANSELECT   to_children, to_common_edge;
  struct GRid       go_grid;
  struct EMSinlist  inlist;
  IGRboolean        part_of_id;
  OMuword           dumosnum;
  extern OMuword    OPP_EMSpointer_class_id, OPP_EMSedge_class_id;
  extern void       EFalloc_list();


  *EMmsg = EMS_S_Success;

  *num_ptrs = 0;

  memset((char *) &inlist, '\0', sizeof(struct EMSinlist));
  inlist.modlist.mod_id = NULL_OBJID;

  EMmake_chanselect(NDchildren_children, &to_children);

  OM_stat = om$get_channel_count(objid = node_id,
                                 osnum = osnum,
                                 p_chanselect = &to_children,
                                 count = &child_cnt);
  if (!(1 & OM_stat)) goto wrapup;
                                   
  if (!child_cnt) goto wrapup;

  /*Just allocate memory for all children since its more efficient than
   * doing a realloc.
   */
  *ptrs = (GRobjid *) om$malloc(size = child_cnt * sizeof(GRobjid));
  if (!*ptrs) {*EMmsg=EMS_E_NoDynamicMemory; goto wrapup;}

  EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);

  for(ii=0; ii<child_cnt; ii++)
  {
    OM_stat = om$get_objid_at_index(objid = node_id,
                                    osnum = osnum,
                                    p_chanselect = &to_children,
                                    index = ii,
                                    objidaddr = &ptr_id,
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;

    if (EFisAncestryValid(EMmsg, ptr_id, dumosnum, OPP_EMSpointer_class_id,
                          FALSE))
    {
      /*Found one!*/

      /*See if the ptr has any children, if not then no need to process*/
      OM_stat = om$get_channel_count(objid = ptr_id,
                                     osnum = osnum,
                                     p_chanselect = &to_children,
                                     count = &ptr_child_cnt);
      if (!(1 & OM_stat)) goto wrapup;
                                       
      if (!ptr_child_cnt) continue;

      go_grid.objid = NULL_OBJID;
      OM_stat = om$send(msg = message NDnode.ASreturn_go(&go_grid, NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = ptr_id,
                        targetos = osnum);
      if (!(1 & OM_stat)) goto wrapup;

      if (go_grid.objid != NULL_OBJID)
      {
        part_of_id = EFis_part_of_id(EMmsg, group_comp_id, go_grid.objid,
                                     osnum, NULL);
        if (!(1 & *EMmsg)) goto wrapup;

        if (*EMmsg == EMS_I_NotFound) part_of_id = TRUE;

        /*REMOVED SECTION <<A>> FROM HERE*/

        if (part_of_id)
        {
          (*ptrs)[*num_ptrs] = ptr_id;
          (*num_ptrs)++;
        }                             
      }
      else
      {
        /*Sick puppy... what do I do??*/
      }
    }
  }                                                              
  
wrapup:
  if (surf_list) om$dealloc(ptr = surf_list);
  if (inlist.sflist.surf_ids) om$dealloc(ptr = inlist.sflist.surf_ids);
  if (inlist.lplist.loop_ids) om$dealloc(ptr = inlist.lplist.loop_ids);
  if (inlist.edlist.edge_ids) om$dealloc(ptr = inlist.edlist.edge_ids);

  EMWRAPUP(*EMmsg, OM_stat, "EFget_group_comp_ptrs")
  return(OM_stat);
}

#if SECTION_A_HERE_WAS_REMOVE_FROM_ABOVE
        if (!part_of_id && *EMmsg == EMS_I_NotFound)
        {
          /*Handle case of ptr to inactive topology or into ssi. In this case:
           * 1. get the in info for group_comp_id
           * 2. traverse to the dependent of the ptr and see if it removed
           *      any of this in info (via EMcheckoverlap).
           */
          IGRint              num_surfs=0, num_active=0;
          GRobjid             ptr_child_id;
          OM_S_OBJECT_LINKAGE *ptr_child_links;

          OM_stat = om$send(msg = message EMSsurface.EMgetSurfsOfPrim(EMmsg,
                                  group_comp_id, &surf_list, &num_surfs,
                                  &num_active), 
                            senderid = group_comp_id,
                            targetid = group_comp_id,
                            targetos = osnum);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;

          EFalloc_list(EMmsg, &inlist.sflist.surf_ids, inlist.sflist.num_surfs,
                       &inlist.sflist.array_size, num_surfs, SF_INCR, NULL);
          if (!(1 & *EMmsg)) goto wrapup;                 

          for(jj=0; jj<num_surfs; jj++)
            inlist.sflist.surf_ids[jj] = surf_list[jj];
          
          inlist.sflist.num_surfs = num_surfs;

          if (surf_list)
          {  
            om$dealloc(ptr = surf_list);
            surf_list = NULL;
          }

          EFgetLoopsEdges(EMmsg, 
                          inlist.sflist.num_surfs, 
                          inlist.sflist.surf_ids,
                          &inlist.lplist.array_size,
                          &inlist.lplist.num_loops,
                          &inlist.lplist.loop_ids,
                          &inlist.edlist.array_size,
                          &inlist.edlist.num_edges,
                          &inlist.edlist.edge_ids,
                          osnum);
          if (!(1 & *EMmsg)) goto wrapup;

          /*See if the ptr points to a dpr*/
          ptr_child_links = (OM_S_OBJECT_LINKAGE *) 
                           alloca(ptr_child_cnt * sizeof(OM_S_OBJECT_LINKAGE));

          OM_stat = om$get_channel_objects(objid = ptr_id,
                                           osnum = osnum,
                                           p_chanselect = &to_children,
                                           list = ptr_child_links,
                                           size = ptr_child_cnt,
                                           count = &ptr_child_cnt);
          if (!(1 & OM_stat)) goto wrapup;
                     
          for(jj=0; jj<ptr_child_cnt; jj++)
          {
            ptr_child_id = ptr_child_links[jj].S_objid;

            if (EFisAncestryValid(EMmsg, ptr_child_id, osnum, 
                                  OPP_EMSdpr_class_id, FALSE))
            {
              part_of_id = FALSE; /*already set but makes me feel good*/
              OM_stat = om$send(msg = message EMSdpr.EMcheckOverlap(EMmsg, 
                                      &inlist, &part_of_id, NULL),
                                senderid = ptr_child_id,
                                targetid = ptr_child_id,
                                targetos = osnum);
              if (!(1 & OM_stat & *EMmsg)) goto wrapup;

              if (part_of_id) break;
            }
          }

          /*Reset count but don't free so mem can be used again.*/
          inlist.sflist.num_surfs = 0;
          inlist.lplist.num_loops = 0;
          inlist.edlist.num_edges = 0;
        }                                       

#endif /*SECTION A*/

IGRlong EFshow_parent_child_relationship(EMmsg, node_id, osnum, show_child,
                                         disp_env, display_mode, 
                                         par_chld_grids, par_chld_cnt,
                                         dont_proc_grids, dont_proc_cnt,
                                         known_chld_grids, known_chld_cnt,
                                         group_comp_id,
                                         options)
IGRlong         *EMmsg;
GRobjid         node_id;
OMuword         osnum;
IGRboolean      show_child;
struct GRmd_env *disp_env;
enum GRdpmode   display_mode;
struct GRid     **par_chld_grids;
IGRint          *par_chld_cnt;
struct GRid     *dont_proc_grids;
IGRint          dont_proc_cnt;
struct GRid     *known_chld_grids;
IGRint          known_chld_cnt;
GRobjid         group_comp_id;
OMuword         options;
/*
Description
    Given a node in the graph this function will show (via GRdisplay) the 
    children (show_child == TRUE) or parents (show_child == FALSE).  Parents
    or children of a group feature may be found if a group component id is
    passed in.

Notes 
     About parameters:
         show_child   - TRUE if want to show children else FALSE will show
                        parents.
                        WARNING - showing of parents is currently not
                                  implemented and will result in an
                                  EMS_E_NotSupported return code.

         disp_env     - the matrix must be the DISPLAY matrix obtained by
                        gr$get_display_env NOT THE LOCATE MATRIX!!
         display_mode - standard display types.
         par_chld_grids (cnt) - malloc'd array of parents/dependents found.  
                                 *par_chld_grids should be passes as NULL,
                                 *par_chld_count should be passes as 0.

         dont_proc_grids (cnt) - used internally to handle macro type features
                                 which should only be processed once.  
                                 dont_proc_grids should be passes as NULL,
                                 dont_proc_cnt should be passes as 0.
         known_chld_grids (cnt) - passed in by caller to indicate dependent
                                  ids already found and therefore should not 
                                  be returned by this function.  
         group_comp_id          - If the node_id is a group feature an id
                                  may be passed if parents or children are
                                  needed for the group component instead of
                                  the entire group feature.  Otherwise 
                                  a NULL_OBJID must be passed in.
                                  Also note that passing in of a group_comp_id
                                  should only be done if the node_id is a
                                  feature (rather obvious, don't you think?).
         options      - EFshow_par_child_rel_DONT_DISPLAY - dont display
                        EFshow_par_child_rel_DONT_RETURN_IDS - dont return ids.

History
     DLB  11/23/92  Creation.
*/
{
  IGRlong       OM_stat=OM_S_SUCCESS;
  int           type;
  int           obj_cnt;
  OMuint        ii, jj, kk;
  IGRint        fea_cnt=0;
  IGRuint       num_ptrs=0;
  GRobjid       *tmp_fea_ids=NULL, *ptrs=NULL;
  struct GRid   *tmp_obj_buf, *obj_buf=NULL, *fea_grids=NULL;
  OM_S_CHANSELECT      to_owners;
  IGRushort            dpr_props;
  extern OMuword       OPP_EMSdpr_class_id, OPP_EMSsuppress_class_id,
                       OPP_GAcurve_class_id;
  extern unsigned char EMS_locate_features;

  
  if (!show_child) {*EMmsg = EMS_E_NotSupported; goto wrapup;}

  *EMmsg = EMS_S_Success;

  /*Make screening checks...*/
  if (EFisAncestryValid(EMmsg, node_id, osnum, 
                        OPP_EMSsuppress_class_id, FALSE)) goto wrapup;
                        
  if (EFisAncestryValid(EMmsg, node_id, osnum, 
                        OPP_GAcurve_class_id, FALSE)) goto wrapup;

  for(ii=0; ii<dont_proc_cnt; ii++) 
  {
    if (dont_proc_grids[ii].objid == node_id &&
        dont_proc_grids[ii].osnum == osnum) goto wrapup;
  }    

  for(ii=0; ii<known_chld_cnt; ii++)
  {
    if (known_chld_grids[ii].objid == node_id &&
        known_chld_grids[ii].osnum == osnum) goto wrapup;
  }    

  type = show_child ? ND_CHILDREN : ND_ROOT;
  type |= ND_IN_BUF;

  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  if (EFisAncestryValid(EMmsg, node_id, osnum, OPP_EMSdpr_class_id, FALSE))
  {
    OM_stat = om$send(msg = message EMSdpr.EMget_feature_definition(EMmsg,
                                    &fea_cnt, &tmp_fea_ids, NULL),
                      senderid = node_id,
                      targetid = node_id,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      

    if (fea_cnt && tmp_fea_ids)
    {
      fea_grids = (struct GRid *) alloca(fea_cnt * sizeof(struct GRid));
      for(ii=0; ii<fea_cnt; ii++)
      {
        fea_grids[ii].objid = tmp_fea_ids[ii];
        fea_grids[ii].osnum = osnum;
      }
      om$dealloc(ptr = tmp_fea_ids);
      tmp_fea_ids = NULL;
    }

    if (group_comp_id != NULL_OBJID && fea_cnt)
    {
      /*Handle group feature case - 
       * For all ptrs on the node ids child chan, see if the object(!) they
       *  point to is part of the incoming group comp id.  If so then 
       *  proceed thru that pointer to get dependents, otherwise skip it.
       *
       * (!) if the object the ptr points to is an edge, see if the edge or
       *      its common edge is part of the incoming group comp id.
       */
      OM_stat = EFget_group_comp_ptrs(EMmsg, node_id, group_comp_id, osnum,
                                      &num_ptrs, &ptrs, NULL);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

  if (!fea_cnt) fea_cnt = 1;  /*loop just using incoming node_id*/

  for(ii=0; ii<fea_cnt; ii++)
  {
    if (fea_cnt && fea_grids) node_id = fea_grids[ii].objid;
    
    obj_cnt = 0;
    tmp_obj_buf = NULL;
    OM_stat = om$send(msg = message NDnode.NDget_objects(type,
                            NULL, 0, &tmp_obj_buf, 0, OM_K_MAXINT, &obj_cnt),
                      senderid = node_id,
                      targetid = node_id,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (obj_cnt && tmp_obj_buf)
    {
      obj_buf = (struct GRid *) alloca(obj_cnt * sizeof(struct GRid));
      OM_BLOCK_MOVE(tmp_obj_buf, obj_buf, obj_cnt * sizeof(struct GRid));
    }

    for(jj=0; jj<obj_cnt; jj++)
    {
      /*see if the returned id is in the dont_proc list*/
      for(kk=0; kk<dont_proc_cnt; kk++)
      {
        if (dont_proc_grids[kk].objid == obj_buf[jj].objid &&
            dont_proc_grids[kk].osnum == obj_buf[jj].osnum) break;
      }
      if (kk != dont_proc_cnt) continue; /*found one so skip it*/

      /*see if the returned id is in the dependent list*/
      for(kk=0; kk<(*par_chld_cnt); kk++)
      {
        if ((*par_chld_grids)[kk].objid == obj_buf[jj].objid &&
            (*par_chld_grids)[kk].osnum == obj_buf[jj].osnum) break;
      }
      if (kk != *par_chld_cnt) continue; /*found one so skip it*/
    
      /*see if the returned id is in the known child list*/
      for(kk=0; kk<known_chld_cnt; kk++)
      {
        if (known_chld_grids[kk].objid == obj_buf[jj].objid &&
            known_chld_grids[kk].osnum == obj_buf[jj].osnum) break;
      }
      if (kk != known_chld_cnt) continue; /*found one so skip it*/

      if (group_comp_id != NULL_OBJID)
      {
        /*see if the returned id is NOT in the ptr list*/
        for(kk=0; kk<num_ptrs; kk++)
        {
          if (ptrs[kk] == obj_buf[jj].objid && 
              osnum == obj_buf[jj].osnum) break;
        }
        if (kk == num_ptrs) continue; /*not in ptr list so skip it*/
      }

      /*an owner is considered a dependent but I dont want to handle it 
       * IS THIS A VALID ASSUMPTION???
       */
      OM_stat = om$is_objid_on_channel(objid_c = node_id,
                                       osnum_c = osnum,
                                       p_chanselect = &to_owners,
                                       objid = obj_buf[jj].objid,
                                       osnum2 = obj_buf[jj].osnum);

      if (!(1 & OM_stat)) /*no such chan or not on chan*/
      {
        if (EFisAncestryValid(EMmsg, obj_buf[jj].objid, obj_buf[jj].osnum,
                              OPP_EMSdpr_class_id, FALSE))
        {
          /*See if the dpr in question is deleted/suppressed*/
          OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg,
                                  &dpr_props),
                            senderid = node_id,
                            targetid = obj_buf[jj].objid,
                            targetos = obj_buf[jj].osnum);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;

          if (dpr_props & EMS_DELETED ||
              dpr_props & EMS_NULL_STATE) continue;

          if (!(options & EFshow_par_child_rel_DONT_DISPLAY))
          {
            struct GRobj_info dep_info;

            EMS_locate_features = TRUE;
            OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                                            &disp_env->md_env.matrix_type,
                                            disp_env->md_env.matrix,
                                            &display_mode, 
                                            &disp_env->md_id),
                              senderid = node_id,
                              targetid = obj_buf[jj].objid,
                              targetos = obj_buf[jj].osnum);
            EMS_locate_features = FALSE;
#           if DEBUG
            if (!(1 & OM_stat & *EMmsg))
            {
              fprintf(stderr, "dependent (%d) display failed!\n", 
                      obj_buf[jj].objid);
              EFprintcode(0, OM_stat);
              EFprintcode(0, *EMmsg);      
            }
#           endif

            OM_stat = om$send(msg = message GRgraphics.GRgetobjinfo(EMmsg, 
                                            &dep_info),
                              senderid = node_id,
                              targetid = obj_buf[jj].objid,
                              targetos = obj_buf[jj].osnum);
            if (1 & OM_stat & *EMmsg)
            {
              ex$message(in_buff = dep_info.type,
                         field = ERROR_FIELD);  
            }
          }

          if (!(options & EFshow_par_child_rel_DONT_RETURN_IDS))
          {
            /*Add the shown dependent to the dependent list to be returned.*/
            EFrealloc_if_needed(EMmsg, par_chld_grids, *par_chld_cnt, 
                                DEP_BUFF_INCR, sizeof(struct GRid));
            if (!(1 & *EMmsg)) goto wrapup;

            (*par_chld_grids)[*par_chld_cnt] = obj_buf[jj];
            (*par_chld_cnt)++;
          }
        }

        /*Will recurse on each child object*/
        OM_stat = EFshow_parent_child_relationship(EMmsg, obj_buf[jj].objid,
                                  obj_buf[jj].osnum, show_child,
                                  disp_env, display_mode,
                                  par_chld_grids, par_chld_cnt,
                                  dont_proc_cnt ? dont_proc_grids : fea_grids,
                                  (dont_proc_cnt ? dont_proc_cnt : 
                                     ((fea_cnt && fea_grids) ? fea_cnt : 0)), 
                                  known_chld_grids, known_chld_cnt,
                                  NULL_OBJID,
                                  options);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }
    }
  }

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

wrapup:
  if (tmp_fea_ids) om$dealloc(ptr = tmp_fea_ids);
  if (ptrs) om$dealloc(ptr = ptrs);
  if (obj_buf) allocf(obj_buf); /*NOOP!!!*/
  EMWRAPUP(*EMmsg, OM_stat, "EFshowpcrel")
  return(OM_stat);
}
end implementation EMSassoc;
