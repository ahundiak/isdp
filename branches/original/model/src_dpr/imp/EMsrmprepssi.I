/* ###################   APOGEE COMPILED   ################## */
/*
History
	SM	05-Feb-88	Creation.
	SM	21-Jun-89	Turn the MSCEXISTS and MSCCOMMON bits
				on the copy edge after doing construct_and_copy
				in EMprepare_edge_copies().
        WBC     30-Apr-91       Not using the MSCEXISTS bit anymore.
*/

class implementation EMSsfregmod;

#include "EMS.h"
#include "emserr.h"
#include "emserr.h"
#include "emsdef.h"     /* MAXFLOAT, MINFLOAT */
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emsinter.h"
#include "emssfint.h"
#include "EMSopt.h"
#include "OMmacros.h"


extern OMuword OPP_EMSloop_class_id, OPP_EMSpartedge_class_id;

from EMSloopset  import         EMset_props, EMget_loops;

from EMSboundary import         EMget_objid, EMgetsurface_info;

from EMSedge     import         EMget_top_part_edges, EMget_props, 
                                EMset_props;

from EMSloop     import         EMset_props, EMtree_traverse;

 
struct split_ed_info
{
  GRobjid       com_ed_id;
  GRobjid       *part_edges;
  IGRint        num_part_edges;
  GRobjid       lp_id;
};

#define BUF_INC	10

static IGRint EMprepare_edge_copies(EMmsg, num_lps_out, lps_out, 
				  orig_edges, copy_edges, num_copies)
 IGRlong		*EMmsg;
 IGRint			num_lps_out;
 GRobjid		*lps_out;
 GRobjid		**orig_edges, 
			**copy_edges;
 IGRint			*num_copies;
{
  IGRlong		sts;
  IGRint		buf_size, i, rc, j;
  OMuint		num_edges;
  OM_S_CHANSELECT	to_edges, to_common_edge, to_owners, to_assoc;
  GRobjid		edgeid, com_edgeid, copy_edgeid, my_actloop, 
			com_actloop;
  OMuword		edge_classid;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  *orig_edges = (GRobjid *) om$malloc(size = BUF_INC * sizeof(GRobjid));
  *copy_edges = (GRobjid *) om$malloc(size = BUF_INC * sizeof(GRobjid));
  buf_size = BUF_INC;
  *num_copies = 0;

  sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
  sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
  sts = EMmake_chanselect (EMSedge_to_owner, &to_owners);
  sts = EMmake_chanselect (GRnotify_notification, &to_assoc);
			
  /* For each loop taken out do the following -
     For each edge of the loop do the following -
       If the edge is not part of the trim_info and not owned by an active
       loop and if it has a commonedge which is owned by active loop
       then replace the common edge with its copy and store the ids.
  */

  for(i=0; i<num_lps_out; i++)  
   {
     sts = om$get_channel_count(objid = lps_out[i], count = &num_edges, 
				p_chanselect = &to_edges);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
     for(j=0; j<num_edges; j++)
      {
	/* Get the edgeid from the loop taken out.
	*/
	sts = om$send(msg = message EMSboundary.EMget_objid
					(EMmsg, &edgeid), 
			senderid = lps_out[i], p_chanselect = &to_edges, 
			from = j, to = j);
	EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	
	/* Get the common edge of the edge obtained.
	*/
	com_edgeid = NULL_OBJID;
	sts = om$send(msg = message EMSboundary.EMget_objid
				(EMmsg, &com_edgeid), senderid = edgeid, 
				p_chanselect = &to_common_edge);
	EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
	
	/* If no common edge I am outta here.
	*/
	if(IF_NULL_OBJID(com_edgeid)) continue;

	/* If this edge is part of trim info continue.
	*/
	
/************************
	skip = FALSE;
	for(k=0; k<num_trim_info; k++)
	 {
	   if(IF_EQ_OBJID(trim_info[k]->edgeid, edgeid) ||
	      (trim_info[k]->next ? 
		 IF_EQ_OBJID(trim_info[k]->next->edgeid, edgeid) : NULL))
	     {skip = TRUE; break;}
	 }
	if(skip) continue;
************************/
	
	/* Is this edge owned by another loop which is active?
	*/
	my_actloop = NULL_OBJID;
	sts = EMsend_loops(&rc, message EMSboundary.EMget_objid
				(EMmsg, &my_actloop), edgeid, 0, MAXINT, 
				EMLP_ACTIVE, NULL, NULL);
	EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
	
	/* If the edge is owned by an active loop, continue.
	*/
	if(!IF_NULL_OBJID(my_actloop)) continue;

	/* Is the common edge owned by an active loop?
	*/
	com_actloop = NULL_OBJID;
	sts = EMsend_loops(&rc, message EMSboundary.EMget_objid
				(EMmsg, &com_actloop), com_edgeid, 0, MAXINT, 
				EMLP_ACTIVE, NULL, NULL);
	EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
	
	/* If the common edge is not owned by an active loop, continue.
	*/
	if(IF_NULL_OBJID(com_actloop)) continue;
	
	/* Since all the tests have been satisfied, make a copy of the common
	   edge and replace it. Also store the ids.
	*/
	sts = om$construct_and_copy(objid = com_edgeid, 
				    p_objid = &copy_edgeid);
	EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

	/* Turn off the common edge connection related property bits of
	the copied edge since they do not make sense.
	*/
	sts = om$send(msg = message EMSedge.EMset_props
		(EMmsg, EMED_SUBORDINATE | EMED_REVERSE_CONNECT
			| EMED_MSCEXISTS /* | EMED_MSCCOMMON*/, EMS_O_OFF), 
		targetid = copy_edgeid, senderid = copy_edgeid);
	EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_EdgeError, wrapup);
	
	sts = om$get_classid(objid = com_edgeid, p_classid = &edge_classid);
	
	/* Move the to owners channel to the copy edge.
	*/
	sts = om$send(msg = message Root.move_chan(to_owners, com_edgeid, 
				OM_Gw_current_OS, to_owners), 
				senderid = com_edgeid, 
				targetid = copy_edgeid);
	EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

	/* Move associations to the new edge
	*/
  	sts = om$send(msg = message Root.move_chan(to_assoc, com_edgeid,
                           OM_Gw_current_OS, to_assoc),
                     targetid = copy_edgeid, senderid = com_edgeid);
	EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

	/* If the common edge was a part edge then establish a connection
	   for it towards its actual geometry. The old part edge since
	   it is getting replaced, will have no path to its geometry.
	   But since it is out of the loopset, who cares?
	*/
	sts = om$is_ancestry_valid(subclassid = edge_classid, 
				   superclassid = OPP_EMSpartedge_class_id);
	if(sts == OM_S_SUCCESS)
	 {
  	  sts = om$send(msg = message Root.move_chan(to_edges, com_edgeid,
                           OM_Gw_current_OS, to_edges),
                     targetid = copy_edgeid, senderid = com_edgeid);
	  EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
	 }
	else
	 sts = OM_S_SUCCESS;
	
	/* Store the edgeids.
	*/
	if(!buf_size)
	 {
	   *orig_edges = (GRobjid *) om$realloc(ptr = (IGRchar *) *orig_edges, 
			  size = (BUF_INC + *num_copies) * sizeof(GRobjid));
	   *copy_edges = (GRobjid *) om$realloc(ptr = (IGRchar *) *copy_edges, 
			  size = (BUF_INC + *num_copies) * sizeof(GRobjid));
	   buf_size = BUF_INC;	
	 }
	(*orig_edges)[*num_copies] = com_edgeid;
	(*copy_edges)[*num_copies] = copy_edgeid;
	(*num_copies)++;
	buf_size--;
	
      } /* for(j=0; j<num_edges; j++) */

   } /* for(i=0; i<num_lps_out; i++) */


wrapup:
	EMWRAPUP(*EMmsg, sts, "In EMprepare_edge_copies")
	return(sts);
}


method  EMprepare_ssi(IGRlong *EMmsg;
		      struct EMSsfintedpar **loops_trim_info;
		      IGRint num_trim_info;
		      IGRint num_new_lps_added;
		      GRobjid *new_lps_added;		
		      struct EMSownercomp *sf_lps_removed;
		      IGRint num_srf_GRid;
		      struct GRid  *srf_GRid;
		      union  EMSssi_table **ssi_table;
		      )
{
   IGRboolean                   lp_exists;

   IGRint                       buf_size = 0,
                                i, j, k,l, lk,jj,
                                sts,
                                num_com_ed_lps = 0,
                                num_part_edges = 0,
                                num_sped_entries = 0,
                                num_split_edges = 0, 
				num_copies = 0;
				   
   IGRushort            props;

   IGRlong                      OM_stat, 
                                mthd_stat;

   GRobjid                      cm_ed_srf,
                                *com_ed_lps,
				*orig_edges, *copy_edges, 
                                *split_edges;


   struct  split_ed_info        *sped_info;
   union   EMSssiSizeData       ssi_size;
   struct  EMSsfssi_table       *my_info;

   OM_S_CHANSELECT              srf_ls_chan,
                                com_ed_chan,
                                lp_ls_chan,
                                ls_srf_chan,
                                ls_lp_chan;


   void				EMget_sp_edges();

   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;


   
   com_ed_lps = NULL;
   sped_info = NULL;
   split_edges = NULL;
   *ssi_table = NULL;
   orig_edges = NULL;
   copy_edges = NULL;

   OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &srf_ls_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = EMmake_chanselect (EMSloopset_to_surface, &ls_srf_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &com_ed_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);


    /*
     *
     * The following information is needed to be saved:
     *
     *  1) the loops that are taken out. This will
     *     include the loops taken out during 
     *     splitting process and the loops whose
     *     copies were moved on to the partial surface
     *     constructed for make face. This information
     *     will be stored through SSI instance data
     *     and EMSdpr.ids[] vla.
     *
     *  2) Some of the edges were split during
     *     loops trimming process. At the same 
     *     time the common edges of these edges, if
     *     any, were also split. Then the original
     *     edges common edges were replaced by their
     *     partedges in their respective loops.
     *     This information about common edges and
     *     and their part edges will be stored through
     *     SSI inastance data and EMSdpr.ids[] vla.
     *

   /*
    * Get the edges of the original surface that had a common edge
    * connection and were split. If an edge has no topological connection
    * then it is of no concequence as far as save state is concerned.
    */

   EMget_sp_edges (&mthd_stat, loops_trim_info, num_trim_info,
		   sf_lps_removed ? sf_lps_removed->num_comps : 0, 
		   sf_lps_removed ? sf_lps_removed->comps : NULL, 
                   &split_edges, &num_split_edges);
   EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

   /*
    * now we have all of the edges of the origunal surface
    * that were split. Next job is to find out their common
    * edges and the top part edges of these common edges.
    * These top part edges replaced the the common edges
    * during splitting process and we need to save
    * this information for the save state purposes.
    */

  if (num_split_edges)
  {
    OM_stat = EMmake_chanselect (EMSloop_to_outter, &lp_ls_chan);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    sped_info = (struct split_ed_info *) om$malloc(size =
                num_split_edges * sizeof(struct split_ed_info));
    EMerr_hndlr(!sped_info,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

    com_ed_lps = (GRobjid *) om$malloc(size =
                num_split_edges * sizeof(GRobjid));
    EMerr_hndlr(!com_ed_lps,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

    num_com_ed_lps = 0;
    for (i = 0; i < num_split_edges; i++)
    {
           OM_stat = om$send (msg = message EMSboundary.EMget_objid(
                        &mthd_stat,
                        &(sped_info[num_sped_entries].com_ed_id)),
                senderid = split_edges[i],
                p_chanselect = &com_ed_chan);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

          sped_info[num_sped_entries].part_edges = NULL;
          sped_info[num_sped_entries].num_part_edges = 0;
          sped_info[num_sped_entries].lp_id = NULL_OBJID;

          buf_size = 0;
          OM_stat = om$send (msg = message EMSedge.EMget_top_part_edges(
                        &mthd_stat,
                        &(sped_info[num_sped_entries].part_edges),
                        &(sped_info[num_sped_entries].num_part_edges),
                        &buf_size),
                targetid = sped_info[i].com_ed_id);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

	  if(!sped_info[num_sped_entries].num_part_edges) continue;
	
          sts = EMsend_loops(&mthd_stat,
   	             message EMSboundary.EMget_objid(
                        &mthd_stat,
                        &(sped_info[num_sped_entries].lp_id)),
                        sped_info[num_sped_entries].part_edges[0],
                        NULL,
                        OM_K_MAXINT,
                        EMLP_ACTIVE,
                        NULL,
                        NULL);
         EMerr_hndlr(!(1&sts&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
        
         num_part_edges +=sped_info[num_sped_entries++].num_part_edges;

        /*
         * It may be possible that the loop is the same as
         * that of another sped_info entry. In this case 
         * donot increase num_com_ed_lps
         */
        
        lp_exists = FALSE;

        if (num_sped_entries > 1)
        {       
          IGRint cur_entry = 0;

          do
          {
            if (sped_info[cur_entry].lp_id == 
                sped_info[num_sped_entries - 1].lp_id) lp_exists = TRUE;
            else cur_entry++;
          } while (cur_entry < (num_sped_entries-1) && !lp_exists);
        
        } /* if (num_sped_entries > 1) */

        if (!lp_exists) com_ed_lps[num_com_ed_lps++] 
                = sped_info[num_sped_entries - 1].lp_id;

         /*
          * It may be possible that the loop of the common edge
          * was a natural one before splitting and after splitting
          * has become non natural. It is therefore needed to
          * turn EMLP_NATURAL off. Also turn off the EMLS_NATURAL
          * bit of the loopset owning this loop.
          */

         if (!lp_exists) 
         {
          props = EMLP_NATURAL;
          OM_stat = om$send (msg = message EMSloop.EMset_props(
                        &mthd_stat, props, EMS_O_OFF),
                   targetid = sped_info[num_sped_entries-1].lp_id);

          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

          OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info(
                                &mthd_stat, &cm_ed_srf, NULL),
                           targetid= sped_info[num_sped_entries-1].lp_id);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
        
          props = EMLS_NATURAL;
          OM_stat = om$send (msg = message EMSloopset.EMset_props (
                        &mthd_stat, props, EMS_O_OFF),
                        senderid = cm_ed_srf,
                        p_chanselect = &srf_ls_chan);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
          } /* if (!lp_exists) */

    } /* for (i = 0; i < num_split_edges; i++) */

  } /* if (num_split_edges) */

  /* Decide whether any edge copies have to be made.
  */
  orig_edges = copy_edges = NULL;
  num_copies = 0;
  if(sf_lps_removed)
   {
     sts = EMprepare_edge_copies(EMmsg, sf_lps_removed->num_comps, 
			     sf_lps_removed->comps, &orig_edges, &copy_edges, 
			     &num_copies);
     EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }

    /*
     * now all of the information is ready, time to save it.
     * fill SSI table and call putSSI
     */
    
    ssi_size.sf_info.num_surfaces = 1;
    ssi_size.sf_info.num_regions_in = num_new_lps_added;
    if (sf_lps_removed) ssi_size.sf_info.num_regions_out = 
                        sf_lps_removed->num_comps;
     else
	ssi_size.sf_info.num_regions_out = 0;

    ssi_size.sf_info.num_regions =  num_com_ed_lps;
    ssi_size.sf_info.num_edges_in = num_part_edges;
    ssi_size.sf_info.num_edges_out = num_sped_entries;
    ssi_size.sf_info.num_edges_copied = num_copies;

    OM_stat = om$send (msg = message EMSdpr.EMgetSSIbuffer(
                        &mthd_stat, &ssi_size, ssi_table),
                      targetid = my_id);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
  
    /*
     * fill the buffer
     */

    my_info = &(*ssi_table)->sf_info;
    my_info->num_surfaces = 1;
    my_info->surface_ids[0] = srf_GRid[0].objid;
    my_info->num_regions_in[0] = num_new_lps_added;

    for (i = 0; i < num_new_lps_added; i++)
        my_info->region_in_ids[i] = new_lps_added[i];

    if (sf_lps_removed) my_info->num_regions_out[0] =  
                        sf_lps_removed->num_comps;
    else
	my_info->num_regions_out[0] = 0;

    i = 0;
    if (sf_lps_removed)
     for (i = 0; i < sf_lps_removed->num_comps; i++)
       my_info->region_out_ids[i] = sf_lps_removed->comps[i];

    my_info->num_regions = num_com_ed_lps;
    my_info->cum_num_edges_out = num_sped_entries;

    for (i = 0; i < num_com_ed_lps; i++)
    {
        my_info->region_ids[i] = com_ed_lps[i];

     } 

     k = l = lk = 0;

     for (i = 0; i < num_com_ed_lps; i++)
     {
        my_info->num_edges_out[i] = 0;

        for (j = 0; j < num_sped_entries; j++)
        {
          if (sped_info[j].lp_id == com_ed_lps[i])
          {
            my_info->num_edges_in[k++] = 
                        sped_info[j].num_part_edges;
            my_info->num_edges_out[i] += 1;

            for (jj = 0; jj < sped_info[j].num_part_edges; jj++)
            {
                my_info->edge_in_ids[l++] = 
                        sped_info[j].part_edges[jj];
            }
            my_info->edge_out_ids[lk++] = 
                        sped_info[j].com_ed_id;

          } /* if (sped_info[j].lp_id == com_ed_lps[i]) */

        } /* for (j = 0; j < num_sped_entries; j++) */

     } /* for (i = 0; i < num_com_ed_lps; i++) */

    /* Fill the copy ids in the following fashion -
       ed1
       ed1_copy
       ed2
       ed2_copy...etc.
    */
    my_info->num_edges_copied = num_copies;
    k = 0;
    for(i=0; i<num_copies; i++)       
     {
	my_info->ed_cp_ed_ids[k++] = orig_edges[i];
	my_info->ed_cp_ed_ids[k++] = copy_edges[i];
     }

wrapup:
  /*
   * free memory
   */

  if (com_ed_lps) om$dealloc (ptr = com_ed_lps);
  
  if (sped_info)
  {
      for (i = 0; i < num_sped_entries; i++)
         if (sped_info[i].part_edges) 
                        om$dealloc (ptr = sped_info[i].part_edges);

      om$dealloc (ptr = sped_info);
  }

  if (split_edges) om$dealloc(ptr = split_edges);

  if(orig_edges) om$dealloc(ptr = orig_edges);
  if(copy_edges) om$dealloc(ptr = copy_edges);

  EMWRAPUP (*EMmsg, OM_stat, "In EMSsfregmod.EMprepare_ssi");
  return (OM_stat);

}





end implementation  EMSsfregmod;
                                  
