/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/

from EMSboundary import EMget_objid;

method EMcheckOverlap(IGRlong *EMmsg;
                      struct EMSinlist *inlist;
                      IGRboolean *does_overlap; IGRushort options)
/*
Description
    This message will determine if this tree node has an overlap of
    surfaces/topology based on the inlist.

Return Values    
    EMS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added so far. 
        does_overlap - TRUE if an overlap is detected.
        options - EMcheck_overlap_TREAT_SFS_AS_SFMOD - if specified, treat
                  the ids in the sflist as surfs modified.

History
    DLB 02/03/90 Was calling EFis_ed_owned_by_edlp then && with
                 firstpe_is_copy.  If firstpe_is_copy was true then the 
                 splited index was junk resulting in a memory fault.
    DLB 11/03/89 Modified extraction of added/removed edges to handle this
                 node being inactive.
    DLB 06/08/89 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            ii, jj, kk, num_added_ed, num_removed_ed, num_copied_ed,
                    firstpe, splited;
  GRobjid           *ssi_id, *added_ed=NULL, *removed_ed=NULL,
                    *copied_ed=NULL, loop_id, owned_ed;
  union EMSssi_table     *ssi=NULL;
  struct EMSsspssi_table *my_info=NULL;
  OM_S_CHANSELECT        to_edges;
  IGRboolean             EFis_edge_owned_by_edlp(), got_splited,
                         firstpe_is_copy; 
  OMuword                dumosnum;


  *EMmsg = EMS_S_Success;
  *does_overlap = FALSE;

  if (options & EMcheck_overlap_TREAT_SFS_AS_SFMOD) goto wrapup;

  /*Get the SSI stuff.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->spl_info;

  /*For every surface of the inlist struct, see if it is also a surface
   * removed by this state.
   */ 
  for(ii=0; ii<inlist->sflist.num_surfs; ii++)
  {
    for(jj=0; jj<my_info->num_srf; jj++)
    {
      if (inlist->sflist.surf_ids[ii] == my_info->srf_ids[jj])
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }
  }

  /*At this point need to determine the added edges and copied edges due to
   * this state.
   */
  /*Mallocing a bit too much here.*/
  added_ed = (GRobjid *) om$malloc
             (size = my_info->num_edges * sizeof(GRobjid));
  removed_ed = (GRobjid *) om$malloc
               (size = my_info->num_edges * sizeof(GRobjid));
  copied_ed = (GRobjid *) om$malloc
              (size = my_info->num_edges * sizeof(GRobjid));
  if (!removed_ed || !added_ed || !copied_ed)
  {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  num_added_ed = num_removed_ed = num_copied_ed = 0;

  EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);

  for(ii=0; ii<my_info->num_edges;)       /*NO INCREMENT*/
  {
    firstpe = ii;                /*Remember the first pe.*/
    got_splited = FALSE;
    firstpe_is_copy = FALSE;

    while(!got_splited && ii<my_info->num_edges)
    {
      /*Get the pe's owned edge*/
      OM_stat = om$get_objid_at_index(objid = my_info->edge_ids[ii],
                                      p_chanselect = &to_edges,
                                      index = 0,
                                      objidaddr = &owned_ed,
                                      osnumaddr = &dumosnum);
      if (!(1 & OM_stat))
      {
        /*Not a part edge so have a copy case.*/
        OM_stat = OM_S_SUCCESS;
        firstpe_is_copy = TRUE;
        break;
      }

      /*See if the owned_ed is also the split ed.*/
      for(jj=ii+1; jj<my_info->num_edges; jj++)
      {
        if (owned_ed == my_info->edge_ids[jj])
        {
          /*Got the split edge.*/
          got_splited = TRUE;
          splited = jj;
          break;
        }
      }
      if (jj == my_info->num_edges)
      {
        /*Owned ed isn't the split ed. so try next pe.*/
        ii++;
      }
    }

    /*Could have gotten case of firstpe being a copy edge.  So test for this
     * case.
     */
    if ( (!firstpe_is_copy) &&  
         ( ii != my_info->num_edges || 
           EFis_edge_owned_by_edlp(EMmsg, my_info->edge_ids[firstpe],
           my_info->edge_ids[splited], OM_Gw_current_OS) ) )
    {
      /*Save the pe's from the first pe index to the split ed index.*/
      for(jj=firstpe; jj<splited; jj++)
      {
        added_ed[num_added_ed] = my_info->edge_ids[jj];
        num_added_ed++;
      }

      /*Save the split ed (a.k.a the removed edge).*/
      removed_ed[num_removed_ed] = my_info->edge_ids[splited];
      num_removed_ed++;

      ii = splited + 1;
    }
    else
    {
      /*Firsted picked was part of a copy and copied edge pair.*/
      copied_ed[num_copied_ed] = my_info->edge_ids[firstpe+1];
      num_copied_ed++;

      ii = firstpe + 2;
    }      
  }

  /*For every loop in the inlist struct...*/
  for(ii=0; ii<inlist->lplist.num_loops; ii++)
  {
    /*Does it own an ADDED edge by this state?*/
    ssi_id = added_ed;
    for(jj=0; jj<num_added_ed; jj++, ssi_id++)
    {
      if (EFis_edge_owned_by_edlp(EMmsg, *ssi_id,
                                  inlist->lplist.loop_ids[ii],
                                  OM_Gw_current_OS))
      {
        *does_overlap = TRUE;
        goto wrapup;
      }        
      else if (!(1 & *EMmsg)) goto wrapup;
    }
  }

  /*For every edge in the inlist struct...*/
  for(ii=0; ii<inlist->edlist.num_edges; ii++)
  {
    /*Is it a removed edge by this state?*/
    ssi_id = removed_ed;
    for(jj=0; jj<num_removed_ed; jj++, ssi_id++)
    {
      if (inlist->edlist.edge_ids[ii] == *ssi_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }      

    /*Is it a copied edge?*/
    ssi_id = copied_ed;
    for(jj=0; jj<num_copied_ed; jj++, ssi_id += 2)
    {
      if (inlist->edlist.edge_ids[ii] == *ssi_id)
      {
        *does_overlap = TRUE;
        goto wrapup;
      }
    }
  }

  wrapup:
    if (ssi) om$dealloc(ptr = ssi);
    if (added_ed) om$dealloc(ptr = added_ed);
    if (removed_ed) om$dealloc(ptr = removed_ed);
    if (copied_ed) om$dealloc(ptr = copied_ed);    
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfsplit.EMcheckOverlap")
    return(OM_stat);
}
end implementation EMSsfsplit;

#if WORKS_ONLY_IF_ACTIVE_BUT_ILL_LEAVE_IT_SO_I_REMEBER_WHAT_I_DID

  for (i=0; i<my_info->num_edges;)      /*NO INCREMENT!*/
  {
    loop_id = NULL_OBJID;
    OM_stat = EMsend_loops(EMmsg,
                           message EMSboundary.EMget_objid(EMmsg, &loop_id), 
                           my_info->edge_ids[i], 0, OM_K_MAXINT,
                           EMLP_ACTIVE, NULL, NULL);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (loop_id != NULL_OBJID)
    {
      /*Got an active edge.  Now see if the next edge is also on the loop.*/
      OM_stat = om$is_objid_on_channel(objid_c = loop_id,
                                       p_chanselect = &to_edges,
                                       objid = my_info->edge_ids[i+1]);
      if (!(1 & OM_stat) && (OM_stat != OM_W_NOTONCHAN)) goto wrapup;
      if (OM_stat == OM_S_SUCCESS)
      {
        /*Yup, the edge is on the channel.  Got an added edge.*/
        added_ed[num_added_ed] = my_info->edge_ids[i];     /*Save 1st added.*/
        added_ed[num_added_ed+1] = my_info->edge_ids[i+1]; /*Save 2nd added.*/
        num_added_ed += 2;
        i += 2; /*Increment past first 2 added.*/

        edge_on_chan = TRUE;
        do
        {
          OM_stat = om$is_objid_on_channel(objid_c = loop_id,
                                           p_chanselect = &to_edges,
                                           objid = my_info->edge_ids[i]);
          if (!(1 & OM_stat) && (OM_stat != OM_W_NOTONCHAN)) goto wrapup;
          if (OM_stat == OM_S_SUCCESS)
          {
            /*Got another added edge.*/
            added_ed[num_added_ed] = my_info->edge_ids[i]; /*Save next.*/
            num_added_ed++;
          }
          else
          {
            /*Got the split edge (a.k.a the removed edge).*/
            removed_ed[num_removed_ed] = my_info->edge_ids[i]; /*Save rem ed*/
            num_removed_ed++;
            edge_on_chan = FALSE;
          }
          i++; /*Increment past either the split edge or the added edge.*/
        } while (edge_on_chan);
        OM_stat = OM_S_SUCCESS;
      }
      else 
      {
        /*Edge not on channel.  Got copy edge case.*/
        copied_ed[num_copied_ed] = my_info->edge_ids[i+1];
        num_copied_ed++;
        i += 2; /*Increment past copy and original.*/
        OM_stat = OM_S_SUCCESS;
      }      
    }
    else
    {
       *EMmsg = EMS_E_InvalidCase;
       goto wrapup;
    }
  }
#endif
