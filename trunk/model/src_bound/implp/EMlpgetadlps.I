/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "emsmacros.h"

from EMSedge import EMget_props;

method EMgetAdjacentLoops (
    IGRlong             *EMmsg;
    GRobjid             *master_list_lps;
    IGRint              *num_master_list_lps;
    GRobjid             *adjacent_lps;
    IGRint              *num_adj_lps;
    IGRushort   mustHaveProps;
    IGRushort   mustNotHaveProps
)

/*
NOTES
        If the caller is interested in only the adjacent
        loops out of a given set of loops, these loops
        can be passed in master_list. In such
        a case, if an adjacent loop is not in the master_list,
        it is ignored.

        On the other hand, if the caller is interested in
        all of the adjacent loops, the master_list_lps
        and num_master_list_lps should be passed in 
        as NULL.
 
 History

04 Nov 1988 jBk In the last modification I forgot to allow for no
                properties in the mustHaveProps argument.  I made
                the appropriate change.
09 Sep 1988 jBk Changed name of message EMget_adjacent_loops to
                EMgetAdjacentLoops.  Added code to support new
                mustHaveProps and mustNotHaveProps arguments of
                message EMgetAdjacentLoops.
                Changed an OM_S_CHANSELECT direct assignment to
                an om$make_chanselect.

        RC   04/27/87  Creation Date
        RC   08/31/87  Modified such that seam edges are treated
                       correctly.

 Description
        This method can be used to determine the adjacent
        p-loops of a given p-loop across its edges' common edge
        channel. 
       
Assumptions
        This method makes the following assumptions:

        a) the loop which receives this message is
        always a P-loop. It is responsibility of the caller
        to make sure that this assumption is satisfied.

        b) There is no P-loop inside a P-loop. Also
        there is no C-loop inside a C-loop.

Algorithm

          a) I donot have any loops across my edge's common 
             edge channel and thus do not have any adjacent loops.
             This will be the case for a natural loop or the
             loops at depth down from the loopset.

          b) I have some adjacent loops acorss my edges' common
             edge channel. All of the p-loops among are adjacent to
             me.
*/ 


{
  IGRint                OM_stat, i,sts;
  OMuint                num_edges, num_com_ed, count;
  IGRlong		mthd_stat;

  OM_S_CHANSELECT       com_ed_chan, lp_ed_chan;

  OM_S_OBJECT_LINKAGE   my_ed_cm_ed;

  GRobjid               cm_ed_lp_id, my_ed_id;

  OMuword               my_ed_os;

  IGRushort     lp_props, ed_props;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  *num_adj_lps = 0;

  OM_stat = EMmake_chanselect(EMSbd_owner_to_comps, &lp_ed_chan);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect(EMSedge_to_common_edge, &com_ed_chan);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  /* 
   * find  out if my edges have
   * any common edges. If so, find their loop ids. If any of 
   * these loops are p-loops, they will be adjacent to me.
   */

  OM_stat = om$get_channel_count (object = me,
                                  p_chanselect = &lp_ed_chan,
                                  count = &num_edges);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
    
  for (i = 0; i < num_edges; i++)
  {
    OM_stat = om$get_objid_at_index (object = me, 
                                     p_chanselect = &lp_ed_chan,
                                     index = i,
                                     objidaddr = &my_ed_id,
                                     osnumaddr = &my_ed_os);
    EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    /*
     * It may be possible that the edge is seam edge.
     * If so, reject this edge
     */

    OM_stat = om$send (msg = message EMSedge.EMget_props (
                        &mthd_stat, &ed_props),
                       targetid = my_ed_id, targetos = my_ed_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError, wrapup);
        
    if (!(ed_props & EMED_SEAM))
    {
      OM_stat = om$get_channel_count (osnum = my_ed_os,
                                      objid = my_ed_id,
                                      p_chanselect = &com_ed_chan,
                                      count = &num_com_ed);
      EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      if (num_com_ed)
      {
        OM_stat = om$get_channel_objects (osnum = my_ed_os,
                                          objid = my_ed_id,
                                          p_chanselect = &com_ed_chan,
                                          list = &my_ed_cm_ed,
                                          size = 1,
                                          count = &count);
        EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
        EMerr_hndlr ((count != 1), *EMmsg, EMS_E_ChanCountNot1, wrapup);

        sts = EMsend_loops(&mthd_stat, 
                           message EMSboundary.EMget_objid( &mthd_stat,
                             &cm_ed_lp_id),
                           my_ed_cm_ed.S_objid,
                           NULL, OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
         EMerr_hndlr(!(1&sts&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

         /*
          * It may be possible that the edge under
          * consideration is a seam edge. In such a case
          * the I will be the active loop of this edge's
          * common edge. In such a case, reject it for adjacent
          * loop.
          * find out if the active loop of the common edge
          * is a p-loop or not. 
          * If it is a p-loop, find out if it already been 
          * selected or not. If not, check if 
          * the master_list is passed in or not. If the
          * master list is passed in, check if this loop is
          * in the master list or not. If so, this loop is
          * adjacent to me .
          */

         if (cm_ed_lp_id != my_id )
         { 

           OM_stat = om$send (msg = message EMSloop.EMget_props( 
                               &mthd_stat, &lp_props),
                              targetid = cm_ed_lp_id);
           EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

           /*
                it is okay to try to add cm_ed_lp_id to the list
                if it has at least one of mustHaveProps (if there
                are any) and none of mustNotHaveProps -- jBk 
            */

           if (
                (lp_props & mustHaveProps OR NOT mustHaveProps) AND
                NOT (lp_props & mustNotHaveProps)
           ) 
           {
              IGRint k;
              IGRboolean is_adjacent, lp_exists;

              lp_exists = FALSE;
              if ( *num_adj_lps)
              {
                 k = 0;
                 lp_exists = FALSE;
                 do
                 {
                   if (adjacent_lps[k] == cm_ed_lp_id) lp_exists = TRUE;
                   k++;
                 } while (!lp_exists && k < (*num_adj_lps) );

               } /* if ( *num_adj_lps) */

               if (!lp_exists)
               {
                 if (master_list_lps)
                 {
                   k = 0;
                   is_adjacent = FALSE;

                   do
                   {
                    if (master_list_lps[k++] == cm_ed_lp_id)
                    {
                        adjacent_lps[(*num_adj_lps)++] = cm_ed_lp_id;
                        is_adjacent = TRUE;
                    } 
                   } while (k < *num_master_list_lps && !is_adjacent);
           
                 } /* if (master_list_lps) */
                 else
                   adjacent_lps[(*num_adj_lps)++] = cm_ed_lp_id;

               } /* if (!lp_exists) */
        
              } /* if (lp_props & EMLP_PLOOP) */
                        
            } /* if (cm_ed_lp_id != my_id ) */

           } /* if (num_com_ed) */

        } /* if (!(ed_props & EMED_SEAM)) */

    } /* for (i = 0; i < num_edges; i++) */
 

wrapup:

  EMWRAPUP(*EMmsg,OM_stat,"In EMSloop.EMgetAdjacentLoops");

  return(OM_stat);

}

end implementation EMSloop;
