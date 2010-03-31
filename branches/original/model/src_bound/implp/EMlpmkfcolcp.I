/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "emsmacros.h"
#include "OMmacros.h"

#define INITIAL_SIZE    10
#define INCREMENT       5

from EMSedge    import  EMmkface_collapse_copy;
from EMSloopset import  EMtreemod;
from EMSgradata import  EMchangeLoop;

method EMmkface_collapse_copy (
        IGRlong                         *EMmsg;
        struct  EMSpartolbasis          *partolbasis;
        GRobjid                         *new_lps_added;
        IGRint                          *num_lps_added;
        GRobjid                         **lps_removed;
        IGRint                          *num_lps_removed;
        IGRint                          *lps_rm_array_size;
        struct EMSmkf_edcon_info        **ed_con_info;
        IGRint                          *num_edcon_entries;
        IGRint                          *edcon_array_size)
/*
 Notes
        This method is currently used by MAKE FACE
        operation. It is not clear if this functionality
        can be used any where else.

        In case of a make face operation, the boundaries 
        are moved from the original surface to the newly
        made face. Since a boundary can not share two
        (u,v) spaces, it is needed to copy the boundary
        if necessary and then collapse it.

History 
         RC    05/10/87     Creation Date
         RC    11/02/87     Modified for version 1.1.0
         DLB   06/18/91     Fix creator id.
*/

        
{
   IGRlong              OM_stat;
   IGRlong              mthd_stat;

   IGRboolean           always_cp_ed = FALSE, copy_lp;
   
   IGRint               i , j;
   OMuint               num_edges;
   GRobjid              ed_cp_id, lp_cp_id;
   
   OM_S_CHANSELECT      lp_ed_chan, ed_lp_chan, to_inner;

   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

   lp_cp_id = my_id;

    OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    OM_stat = EMmake_chanselect (EMSedge_to_owner, &ed_lp_chan);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    OM_stat = EMmake_chanselect (EMSloop_to_inner, &to_inner);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   /*
    * find out if I am in the array new_lps_added. If not,
    * I have been moved from the original surface to the
    * partial surface. Since I have to be saved for the 
    * deactivate purposes, I should perform the following
    * steps:
    *
    *  1. Copy myself.
    *  2. Extract my self from the loopset.
    *  3. Put my copy in the loopset.
    *  4. Put mysef in the array lps_removed.
    *
    * Pass the message to my copy's inner loops.
    */

   copy_lp = TRUE;

   /*
    * If a loop is in the new_lps_added array, it is new loop
    * and thus need not to be copied. If it is a new loop, its
    * entry in the new_lps_added should be taken out. The
    * net result of this process will be the new loops
    * added on to the original surface and this information
    * will be neeeded in the save state process.
    */

   for ( i = 0; i < *num_lps_added; i++)
   {
      if (IF_EQ_OBJID (my_id, new_lps_added[i])) 
      {
         copy_lp = FALSE;
         for (j = i+1; j < *num_lps_added; j++)
             {
            new_lps_added[j - 1] = new_lps_added[j];
         }
         (*num_lps_added)--;

      } /* if (IF_EQ_OBJID (my_id, new_lps_added[i])) */

   } /* for ( i = 0; i < *num_lps_added; i++) */

   /*
    * If I have to be copied, construct my copy.
    * If I am a p-loop, move my graphics data object to my copy
    */

   if (copy_lp)
   {
     OM_stat = om$construct_and_copy (object = me, 
                  osnum = OM_Gw_current_OS, p_objid = &lp_cp_id);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
     always_cp_ed = TRUE;

     { /*DLB*/
       extern OM_S_OBJID current_creator;
       OM_stat = om$send(msg = message EMSboundary.EMfix_creator_id(EMmsg,
                               NULL, current_creator, NULL),
                         targetid = lp_cp_id);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;                         
     }

     if (ME.EMSloop->lp_props & EMLP_PLOOP)
     {
       OM_S_CHANSELECT  to_helpers;

       OM_stat = EMmake_chanselect (EMSrequester_to_helpers, &to_helpers);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_Fail,wrapup);

       OM_stat = om$send(msg = message EMSgradata.EMchangeLoop(&mthd_stat,
                         lp_cp_id), p_chanselect = &to_helpers);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_Fail,wrapup);

     } /* if (ME.EMSloop->lp_props & EMLP_PLOOP) */

   } /* if (copy_lp) */

   OM_stat = om$get_channel_count (object = me, 
                   p_chanselect = &lp_ed_chan, count = &num_edges);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   for (i = 0; i < num_edges; i++)
   {
     ed_cp_id = NULL_OBJID;

     OM_stat = om$send (msg = message EMSedge.EMmkface_collapse_copy(
                         &mthd_stat, partolbasis, always_cp_ed,
                         &ed_cp_id, ed_con_info, num_edcon_entries,
                          edcon_array_size),
                        p_chanselect = &lp_ed_chan, from = i, to = i);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     /*
      * if the loop is copied, each of the edge will be copied.
      * In this case connect the copied edge to the copied loop
      *
      * On the other hand, if the loop is not copied, the edge
      * may still be copied. In such a case, if the edge is copied,
      * disconnect the old edge from the loop and connect its
      * copy to the loop.
      */
                
     if (copy_lp)
     {
       OM_stat = om$send (msg = message Root.connect ( lp_ed_chan,
                           NULL, ed_cp_id, OM_Gw_current_OS, ed_lp_chan,
                           i), targetid = lp_cp_id);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
     }
     else

     if (!IF_NULL_OBJID(ed_cp_id))
     {
        OM_stat = om$send (msg = message Root.range_disconnect (
                            lp_ed_chan, i, i),
                           targetid = my_id);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
                                                
        OM_stat = om$send (msg = message Root.connect ( lp_ed_chan,
                            NULL, ed_cp_id, OM_Gw_current_OS,
                            ed_lp_chan, i),
                           targetid = my_id);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     } /* if (!IF_NULL_OBJID(ed_cp_id)) */
   
   } /* for (i = 0; i < num_edges; i++) */

   /*
    * If have been copied, move owner as well as inner
    * channels to my copy.
    */

   if (copy_lp)
   {
      OM_S_CHANSELECT outter_chan;
        
      OM_stat = EMmake_chanselect (EMSloop_to_outter, &outter_chan);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      OM_stat = om$send (msg = message Root.move_chan(outter_chan,
                          my_id, OM_Gw_current_OS, outter_chan),
                         targetid = lp_cp_id);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror, wrapup);

      OM_stat = om$send (msg = message Root.move_chan(to_inner,
                          my_id, OM_Gw_current_OS, to_inner),
                         targetid = lp_cp_id);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror, wrapup);

      /*
       * add my self to the lps_removed array
       */

      if (! (*lps_rm_array_size))       
      {
        *lps_removed = NULL;
        *lps_removed = (GRobjid *) om$malloc (size = (unsigned) 
                (INITIAL_SIZE * sizeof(GRobjid)));

        EMerr_hndlr(!(*lps_removed),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

        *lps_rm_array_size = INITIAL_SIZE;

      } /* if (! (*lps_rm_array_size)) */

      else if ((*num_lps_removed + 1) > (*lps_rm_array_size))
      {
        (*lps_rm_array_size) += INCREMENT;

         *lps_removed = (GRobjid *) om$realloc (ptr = (char *)(*lps_removed), 
          size = (unsigned) (*lps_rm_array_size) * sizeof(GRobjid));
         EMerr_hndlr(!(*lps_removed),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

       }

       (*lps_removed)[(*num_lps_removed)++] = my_id;
 
   } /* if (copy_lp) */

   /*
    * pass the message to my inner loops
    */

   OM_stat = om$send (msg = message EMSloop.EMmkface_collapse_copy (
                       &mthd_stat, partolbasis, new_lps_added,
                        num_lps_added, lps_removed, num_lps_removed,
                        lps_rm_array_size, ed_con_info, num_edcon_entries,
                        edcon_array_size), senderid = lp_cp_id, 
                       p_chanselect = &to_inner);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

wrapup:
        
   EMWRAPUP (*EMmsg, OM_stat, "In EMSloop.EMmkface_collapse_copy");

   return (OM_stat);

}

end implementation EMSloop;
