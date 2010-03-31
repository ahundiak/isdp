/* ###################   APOGEE COMPILED   ################## */
/*
Description
    This method recovers the state before make face in
    case make face failed.

History
         RC    11/11/87      Creation date
*/

class implementation EMSsfmkface;

#include "EMS.h"
#include "emserr.h"
#include "emserr.h"
#include "emsdef.h"     /* MAXFLOAT, MINFLOAT */
#include "emsdattyp.h"
#include "EMSbnddef.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "emssfint.h"
#include "EMSopt.h"

from  EMSedge        import  EMget_props, EMget_top_part_edges;
from  EMSboundary    import  EMget_objid, EMcheck_props, 
                             EMgetsurface_info;
from  EMSloopset     import  EMget_loops, EMnesting, EMtreemod;
from  EMSloop        import  EMtreemod, EMactivate_loop, EMgivenestinfo,
                             EMtree_traverse, EMset_props, EMget_loops;
from  EMSgradata     import  EMchangeSurface;

extern OMuword  OPP_EMSgradata_class_id;

method EMgraceful_exit ( 
  IGRlong                   *EMmsg;
  struct   EMSpartolbasis   *partolbasis;
  struct   GRmd_env         *md_env;
  struct   EMSsfintedpar    **loops_trim_info;
  IGRint                    num_trim_info;
  struct  EMSmkf_edcon_info *ed_con_info;
  IGRint                    num_edcon_entries;
  GRobjid                   gr1_ls_id;
  GRobjid                   gr2_ls_id;
  struct  GRid              sf_GRid;
  GRobjid                   sf_org_ls;
  GRobjid                   *sf_org_lps;
  IGRint                    num_sf_org_lps;
  GRobjid                   part_sf_id;
  IGRushort         dis_options)

{
  OM_S_CHANSELECT    com_ed_chan, ed_lp_chan, lp_ed_chan, ls_lp_chan, 
                     sf_ls_chan, ls_sf_chan, to_inner;

  struct EMSnest_info nesting;

  enum GRdpmode      DisplayMode = GRbd;
  IGRlong            OM_stat;
IGRlong   mthd_stat;

  IGRint             buf_size, depth, i, j, k, 
                     num_org_ls_lps, num_part_edges, num_split_edges, sts;

  OMuint             edge_in_index;

  IGRushort          ls_props, ed_props, lp_props, 
                     *org_ls_lp_props;

  GRobjid            com_ed_id, *org_ls_lps, lp_id, lp_sf_id, 
                     ls_to_delete, *part_edges, *split_edges;

  IGRboolean         is_lp_org;

  void               EMget_sp_edges();

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  org_ls_lps = NULL;
  split_edges = NULL;
  org_ls_lp_props = NULL;
  part_edges = NULL;

  OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &com_ed_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSloopset_to_surface, &ls_sf_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSloop_to_inner, &to_inner);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  /*
   * If some of the edges's common edge was moved 
   * to its copy during  makeface-collapse-copy, move
   * them back to their original edges.
   */

  if (num_edcon_entries)
  {
    for (i = 0; i < num_edcon_entries; i++)
    {
      OM_stat = om$send (msg = message Root.wild_disconnect (
                          com_ed_chan), 
                         targetid = ed_con_info[i].cm_ed_id);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      OM_stat = om$send (msg = message Root.connect (com_ed_chan,
                          NULL, ed_con_info[i].cm_ed_id, OM_Gw_current_OS,
                          com_ed_chan, NULL),
                         targetid = ed_con_info[i].ed_id);
      EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

    } /* for (i = 0; i < num_edcon_entries; i++) */

  } /* if (num_edcon_entries) */

  /*
   * During loopset split procees, the common edges might
   * have been split and replaced by split edges. If so,
   * replace back the split edges by their original edges.
   */

  if (num_trim_info)
  {
    EMget_sp_edges (&mthd_stat, loops_trim_info, num_trim_info, 0, NULL,  
                    &split_edges, &num_split_edges);
    EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

    /*
     * now we have all of the edges of the original surface
     * that were split. Next job is to find out their common
     * edges and the top part edges of these common edges.
     * These top part edges replaced the the common edges
     * during splitting process. Replace back the part edges
     * by their original edges
     */

    buf_size = NULL;

    if (num_split_edges)
    {
      OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
      EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      OM_stat = EMmake_chanselect (EMSedge_to_owner, &ed_lp_chan);
      EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      for (i = 0; i < num_split_edges; i++)
      {
         num_part_edges = 0;
         com_ed_id = NULL_OBJID;

         OM_stat = om$send (msg = message EMSboundary.EMget_objid(
                               &mthd_stat, &com_ed_id),
                              senderid = split_edges[i],
                              p_chanselect = &com_ed_chan);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

        OM_stat = om$send (msg = message EMSedge.EMget_top_part_edges(
                               &mthd_stat, &part_edges, &num_part_edges,
                               &buf_size),
                              targetid = com_ed_id);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

        sts = EMsend_loops(&mthd_stat,
                              message EMSboundary.EMget_objid( &mthd_stat,
                               &lp_id),
                              part_edges[0], NULL, OM_K_MAXINT, 
                              EMLP_ACTIVE, NULL, NULL);
        EMerr_hndlr(!(1&sts&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
        
        OM_stat = om$get_index ( osnum_c = OM_Gw_current_OS,
                      objid_c = lp_id, p_chanselect = &lp_ed_chan,
                      objid = part_edges[0], indexaddr = &edge_in_index);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

        OM_stat = om$send (msg = message Root.connect( lp_ed_chan, 
                                OM_K_MAXINT, com_ed_id, OM_Gw_current_OS, 
                                ed_lp_chan, edge_in_index),
                               targetid = lp_id);
        EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

       /*
        * while deleting a part edge use lp_id as
        * sender_id. It is because the part edge delete
        * method checks if the sender id is lp_id or not.
        * If not, it will not delete it self.
        */

      for (k = 0; k < num_part_edges; k++)
      {
              OM_stat = om$send (msg = message Root.delete(1), 
                                 senderid = lp_id,
                                 targetid = part_edges[k]);
              EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

       } /* for (k = 0; k < my_info->num_edges_in[ll]; k++) */

       /*
        * It may be possible that the loop is now natural
        * and so is its loopset. Make a check for this 
        * and set properties appropriately.
        */

       ls_props = NULL;
       lp_props = EMLP_NATURAL;
       ed_props = NULL;

       OM_stat = om$send (msg = message EMSboundary.EMcheck_props (
                          &mthd_stat, &ls_props, &lp_props, &ed_props),
                         targetid = lp_id);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

       lp_sf_id = NULL_OBJID;

       OM_stat = om$send (msg =message EMSboundary.EMgetsurface_info(
                                &mthd_stat, &lp_sf_id, NULL),
                               targetid = lp_id);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

       if(IF_NULL_OBJID(lp_sf_id)) continue;

       ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;
       lp_props = NULL;
       ed_props = NULL;
	
       OM_stat = om$send (msg = message EMSboundary.EMcheck_props (
                                &mthd_stat, &ls_props, &lp_props, 
                                &ed_props),
                               senderid = lp_sf_id, 
                               p_chanselect = &sf_ls_chan);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);


      } /* for (i = 0; i < num_split_edges; i++) */

    } /* if (num_split_edges) */

  } /* if (num_trim_info) */

  /*
   * 1. Decide which one of the gr1_ls_id and gr2_ls_id is the original
   *    loopset. 
   * 2. Get the current loops of the original loopset.
   * 3. for each of these loops
   *     4.   If it is also in the sf_org_lps, take this entry out
   *            of sf_org_lps.
   *     5.   else
   *            Take the loop out and delete it.
   * 6.  Now, sf_org_lps has loops that are not in the original loopset.
   * 7.  For each of these loops
   *     8. Get the nesting of this loop
   *     9. If this loop has a owner.
   *        10. Extract it.
   *     11. Get the nestinfo of this loop w.r.t to original loopset.
   *     12. Nest this loop in the original loopset.
   *
   * 13. Delete the ls_to_delete.
   */

  if (sf_org_ls == gr1_ls_id) 
     ls_to_delete = gr2_ls_id;

  else if (sf_org_ls == gr2_ls_id) 
          ls_to_delete = gr1_ls_id;
       else
       {
         *EMmsg = EMS_E_InvalidArg;
         goto wrapup;
       }

  OM_stat = om$send (msg = message Root.wild_disconnect (sf_ls_chan),
                     targetid = sf_GRid.objid);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$send (msg = message Root.connect (sf_ls_chan,
                      NULL, sf_org_ls, OM_Gw_current_OS, ls_sf_chan,
                      NULL),
                     targetid = sf_GRid.objid);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  depth = MAXINT;
  buf_size = NULL;
  OM_stat = om$send (msg = message EMSloopset.EMget_loops (&mthd_stat,
                       EMS_OPT_ALL, &depth, &org_ls_lps, &org_ls_lp_props,
                       &buf_size, &num_org_ls_lps), 
                      targetid = sf_org_ls);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

  buf_size += num_org_ls_lps; /* buf_size = num_of_empty_slots */

  for (i = 0; i < num_org_ls_lps; i++)
  {
      is_lp_org = FALSE;
      j = 0;

      while (!is_lp_org && j < num_sf_org_lps)
      {
        if (org_ls_lps[i] == sf_org_lps[j]) 
          is_lp_org = TRUE;

        else j++;

      }
 
      if (is_lp_org)
      {
        for (k = j; k < (num_sf_org_lps - 1); k++)
           sf_org_lps[k] = sf_org_lps[k+1];
        num_sf_org_lps--;
      }
      else
      {
         OM_stat = om$send (msg = message EMSloop.EMtreemod (&mthd_stat,
                          &nesting, DELETE, partolbasis),
                         targetid = org_ls_lps[i]);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
       } 

  } /* for (i = 0; i < num_org_ls_lps; i++) */

  for (i = 0; i < num_sf_org_lps; i++)
  {
     /*
      * some of the sf_org_lps may have non_original loops as
      * their childern. It is therefore needed to extract and delete
      * them.
      */
     
     depth = MAXINT;
     num_org_ls_lps = NULL;
     OM_stat = om$send (msg = message EMSloop.EMget_loops (&mthd_stat,
                       EMS_OPT_ALL, &depth, &org_ls_lps, &org_ls_lp_props,
                       &buf_size, &num_org_ls_lps), 
                      senderid = sf_org_lps[i],
                      p_chanselect = &to_inner);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
  
     buf_size += num_org_ls_lps;

     for (k = 0; k < num_org_ls_lps; k++)
     {
        is_lp_org = FALSE;
        j = 0;

        while (!is_lp_org && j < num_sf_org_lps)
        {
          if (org_ls_lps[k] == sf_org_lps[j]) 
            is_lp_org = TRUE;

          else j++;

        }
 
        if (!is_lp_org)
        {
          OM_stat = om$send (msg = message EMSloop.EMtreemod (&mthd_stat,
                          &nesting, DELETE, partolbasis),
                         targetid = org_ls_lps[k]);
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
        } 

     } /* for (k = 0; k < num_org_ls_lps; k++) */

     OM_stat = om$send (msg = message EMSloop.EMactivate_loop (
                          &mthd_stat),
                       targetid = sf_org_lps[i]);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

     nesting.parent = NULL_OBJID;
     OM_stat = om$send(msg = message EMSloop.EMgivenestinfo( &mthd_stat,
                       &nesting), targetid = sf_org_lps[i]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

     if (!IF_NULL_OBJID(nesting.parent))
     {
        OM_stat = om$send (msg = message EMSloop.EMtreemod (&mthd_stat,
                            &nesting, EXTRACT, partolbasis),
                           targetid = sf_org_lps[i]);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
     }
       
     nesting.parent = NULL_OBJID;
     OM_stat = om$send(msg = message EMSloopset.EMnesting(
                      &mthd_stat, &nesting, partolbasis),
                     targetid = sf_org_ls);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

     if(IF_EQ_OBJID(sf_org_ls,nesting.parent))

        OM_stat = om$send(msg = message EMSloopset.EMtreemod(
                          &mthd_stat, &nesting, ADD_CHILD, partolbasis),
                         targetid = sf_org_ls);
     else

        OM_stat = om$send(msg = message EMSloop.EMtreemod(
                          &mthd_stat, &nesting, ADD_CHILD, partolbasis),
		         targetid = nesting.parent);

     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

  } /* for (i = 0; i < num_sf_org_lps; i++) */

  /*
   * delete the loopset
   */

 if (!IF_NULL_OBJID(ls_to_delete))
 {
  OM_stat = om$send (msg = message Root.delete (1), 
                       targetid = ls_to_delete);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
 
 }  /* if (!IF_NULL_OBJID(ls_to_delete)) */
        
    
 /*
  * If a partial surface has been constructed, delete it
  */

 if (!IF_NULL_OBJID(part_sf_id))
 {
   OM_stat = om$send (msg = message GRgraphics.GRdelete(&mthd_stat,
                    md_env), targetid = part_sf_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

 } /* if (!IF_NULL_OBJID(part_sf_id)) */

 /*
  * Some of the garphic data objects may not
  * be connected to sf_GRid.
  */

 OM_stat = om$send (msg = message EMSloop.EMtree_traverse( 
                    &mthd_stat, message EMSgradata.EMchangeSurface(
                     &mthd_stat, sf_GRid.objid), MAXINT, 1, 
                     &OPP_EMSgradata_class_id, TRUE,
                     EMLP_PLOOP, NULL, NULL),
                   senderid = sf_org_ls,
                   p_chanselect = &ls_lp_chan);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

 /*
  * It may be possible that the loopset is natural
  */

 ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;
 lp_props = NULL;
 ed_props = NULL;
	
 OM_stat = om$send (msg = message EMSboundary.EMcheck_props (
                      &mthd_stat, &ls_props, &lp_props, 
                      &ed_props),
                     targetid = sf_org_ls);
 EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

 if ((dis_options & EMS_DO_DISPLAY) &&
     !(dis_options & EMS_DONT_REDRAW))
 {
   /*
    * Display the original surface
    */
   
   OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                       &md_env->md_env.matrix_type,
                        md_env->md_env.matrix, &DisplayMode,
                       &md_env->md_id),
                      targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
   EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError,wrapup);
 }

wrapup:

EMWRAPUP (*EMmsg, OM_stat, "In EMSsfmkface.EMgraceful_exit");
if (org_ls_lps)  om$dealloc (ptr = org_ls_lps);
if (org_ls_lp_props) om$dealloc (ptr = org_ls_lp_props);
if (split_edges) om$dealloc (ptr = split_edges);
if (part_edges ) om$dealloc (ptr = part_edges);

return (OM_stat);

}   




/*
History
	RC	Long Ago	Creation.
	SM	17-Jan-89	Return the split edges information about
				the common edge of an split edge only if
				1) The common edge has not been split
				explicitly (indicated via being in trim_info)
				2) The common edge is not owned by any
				of the loops taken out.
*/
void  EMget_sp_edges (
      EFmsg,
      loops_trim_info,
      num_trim_info,
      num_loops_removed, 
      loops_removed, 
      split_edges,
      num_split_edges)

  IGRlong                  *EFmsg;
  struct   EMSsfintedpar   **loops_trim_info;
  IGRint                   num_trim_info;
  IGRint		   num_loops_removed;
  GRobjid		   *loops_removed;
  GRobjid                  **split_edges;
  IGRint                   *num_split_edges;

{
  OM_S_CHANSELECT       com_ed_chan,  lp_ed_chan;
  struct EMSsfintedpar  *local_ptr;
  IGRlong               OM_stat;
  OMuint                i, j, k, inx, comm_count = 0;
  GRobjid               edge_id;
  IGRboolean            edge_exists;
  OM_S_OBJECT_LINKAGE	comm;
  
  OM_stat = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;
  
 *split_edges = NULL;
 *num_split_edges = 0;
 
 if (num_trim_info)
 {
 OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &com_ed_chan);
 EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

 OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
 EMerr_hndlr (!(1&OM_stat),  *EFmsg,  EMS_E_OMerror,  wrapup);

 /*
  * the maximum number of edges of the original surface,
  * that can be split is num_trim_info * 2. 
  */

  *split_edges = (GRobjid *) om$malloc (size = num_trim_info * 2 *
                                           sizeof(GRobjid));
  EMerr_hndlr (!(*split_edges),*EFmsg,EMS_E_NoDynamicMemory,wrapup);
 

  for (i = 0; i < num_trim_info; i++)
  {
    for (k = 0; k < 2; k++)
    {
      local_ptr = k ? loops_trim_info[i]->next : loops_trim_info[i];

      if (local_ptr)
      {
        edge_id = local_ptr->edgeid;
        if(!EFisAncestryValid(EFmsg, edge_id, OM_Gw_current_OS, 
            OPP_EMSedge_class_id, TRUE))
         edge_id = NULL_OBJID;

        if (!IF_NULL_OBJID(edge_id))
        {
           /*
            * The edge was actually split if the intersection location
            * was not at one of the end points
            */

           if (local_ptr->intloc == EMScvint_middle    ||
               local_ptr->intloc == EMScvint_collapsed ||
               local_ptr->intloc == EMScvint_overlap   ||
               local_ptr->intloc == EMScvint_unknown ) 
           {
	     OM_stat = om$get_channel_objects(osnum = OM_Gw_current_OS, 
				objid = edge_id, p_chanselect = &com_ed_chan, 
				list = &comm, size = 1, count = &comm_count);
             EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);
        
             if (comm_count)
             {
                edge_exists = FALSE;

                if (*num_split_edges)
                {
                  j = 0;
                  do
                  {
                    if (IF_EQ_OBJID(edge_id, (*split_edges)[j])) 
                        edge_exists = TRUE;
                    j++;
                   } while (j < *num_split_edges && !edge_exists);

                 } /* if (*num_split_edges) */

                 if (!edge_exists)
                 {
	           /*
	            * If the common edge is owned by any of
	            * the loops taken out, the loop taken out is
	            * replaced by a new loop which has the common
	            * edge replaced by its split pieces. The 
	            * loop taken out still has the original common edge.
	            * When an undo operation is performed,  the
	            * loop taken out is put back and thus the common edge
	            * is back. 
	            * So, the split common edges whose loops are not
	            * taken out need to ve saved for save state
	            * purposes.
	            */
	
                   
	           for ( inx = 0; inx < num_loops_removed; inx++)
	           {
		     OM_stat = om$is_objid_on_channel (
		                  objid_c = loops_removed[inx], 
		                  p_chanselect = &lp_ed_chan, 
		                  objid = comm.S_objid);
		     if (OM_stat == OM_S_SUCCESS)
                     { edge_exists = TRUE;  break;  }
	             else OM_stat = OM_S_SUCCESS;
	

                    } 
                    if (!edge_exists)
                        (*split_edges)[(*num_split_edges)++] =edge_id; 
            }


            } /* if (comm_count) */

           }  /* if (local_ptr->intloc == EMScvint_middle    ||
                     local_ptr->intloc == EMScvint_collapsed ||
                     local_ptr->intloc == EMScvint_overlap   ||
                     local_ptr->intloc == EMScvint_unknown ) */

        } /* if (!IF_NULL_OBJID(edge_id)) */

      } /* if (local_ptr) */

    } /* for (k = 0; k < 2; k++) */

  } /* for (i = 0; i < num_trim_info; i++) */

 } /* if (num_trim_info) */

wrapup:

  EMWRAPUP (*EFmsg, OM_stat, "In EMget_sp_edges");

  return;

} /* end EMget_sp_edges */

end implementation  EMSsfmkface;
