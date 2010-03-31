/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfregmod;
#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsdef.h"

from EMSboundary import EMget_objid, EMgetsurface_info, EMcheck_props;
from EMSloop     import EMmodify_edge;

/*
 * NOTE : The following function is used during deactivate
 * process of LIFT, MAKE FACE and IMPOSE BOUNDARY operations.
 *
 * Given the save state information, namely,
 * a) one_eds_list each one of which is  replaced by a set of
 * b) many_eds_list or vice versa in the active loop only.
 *
 * The taken out edges are deleted if the user has requested so. 
 * Also, the active loop and the loopset of the old edge is
 * tested for natural property if the caller has requested.
 *
 * History 
 *         RC   11/17/88    Creation Date
 *         SM   22-Dec-88   replace edges only if ids are valid. This is
 *                          a safety check.
 *         RC   01/27/89    Rewrote such the replacement takes place
 *                          only in the active loop. Also, one should
 *                          be able to replace one edge by many edges
 *                          as well as many edges by one edge.
 *         SM   10/05/92    Use MAXINT (instead of NULL) in the Root.connect
                            message sends as the loop's index on the ed->lp
                            channel. This is to ensure that the active loop
                            is at the last index.
           WBC  12/20/93    Additional checks to see if edge ids are valid.
                            (TR#119309313)
 */

void EFrpl_old_new_eds (EFmsg, num_one_eds, one_eds_list, num_many_eds,
                        many_eds_list, cur_os, replace_one_by_many,
                        delete_taken_out_eds, check_ls_lp_props)
     IGRlong         *EFmsg;
     IGRint          num_one_eds;
     GRobjid         *one_eds_list;
     IGRint          *num_many_eds;
     GRobjid         *many_eds_list;
     GRspacenum      cur_os;
     IGRboolean      replace_one_by_many, delete_taken_out_eds, 
                     check_ls_lp_props;


{
  OM_S_CHANSELECT     sf_ls_chan, lp_ed_chan, ed_lp_chan;
  OM_S_OBJECT_LINKAGE ls_list;
  IGRlong             OM_stat, mthd_stat, rc;
  IGRint              cur_ed, i, sts;
  OMuint              in_inx, count;
  GRobjid             lp_id, sf_id;
  IGRushort   ls_props, lp_props, ed_props;
  extern IGRint       EMsend_loops();

  OM_stat = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;

  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSedge_to_owner, &ed_lp_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  for (cur_ed = 0; cur_ed < num_one_eds; cur_ed++, one_eds_list++)
  {
   if( ( (OM_stat = om$is_objid_valid(objid = *one_eds_list, 
                   osnum = cur_os)) != OM_S_SUCCESS)  ||
          (IF_EQ_OBJID(*one_eds_list,*many_eds_list)) ||
         ((! replace_one_by_many) &&
          (OM_stat = om$is_objid_valid(objid = *many_eds_list, 
                   osnum = cur_os)) != OM_S_SUCCESS))
          
     {OM_stat = OM_S_SUCCESS; 
      many_eds_list++;
      continue;
     }

   sts = EMsend_loops (&rc,
                       message EMSboundary.EMget_objid (&mthd_stat,
                        &lp_id),
                       replace_one_by_many ? *one_eds_list :
                                             *many_eds_list,
                       NULL, MAXINT, EMLP_ACTIVE, NULL, NULL);
   EMerr_hndlr (!(1&sts&mthd_stat&rc),*EFmsg,EMS_E_Fail,wrapup);

   OM_stat = om$get_index (osnum_c = cur_os, objid_c = lp_id, 
                           objid = replace_one_by_many ? *one_eds_list :
                                   *many_eds_list,
                           p_chanselect = &lp_ed_chan,
                           osnum2 = cur_os,
                           indexaddr = &in_inx);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   if (replace_one_by_many)
   {
     OM_stat = om$send (msg = message Root.disconnect (lp_ed_chan, 
                         *one_eds_list, cur_os, ed_lp_chan),
                        senderid = NULL_OBJID,
                        targetid = lp_id, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

     if (delete_taken_out_eds)
     {
       OM_stat = om$send (msg = message Root.delete(1),
                          senderid = NULL_OBJID,
                          targetid = *one_eds_list, targetos = cur_os);
       EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

     } /* if (delete_taken_out_eds) */

   } /* if (replace_one_by_many) */
   else
   {
     OM_stat = om$send (msg = message Root.connect (lp_ed_chan,
                         MAXINT, *one_eds_list, cur_os, ed_lp_chan,
                         in_inx),
                        senderid = NULL_OBJID,
                        targetid = lp_id, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   } /* else for if (replace_one_by_many) */

   for (i = 0; i < num_many_eds[cur_ed]; i++, many_eds_list++)
   {
    if( (OM_stat = om$is_objid_valid(objid = *many_eds_list, 
                                     osnum = cur_os)) 
		!= OM_S_SUCCESS) {OM_stat = OM_S_SUCCESS; continue;}
	
    if (replace_one_by_many)
    {
      OM_stat = om$send (msg = message Root.connect (lp_ed_chan,
                          MAXINT, *many_eds_list, cur_os, ed_lp_chan,
                          in_inx+i),
                         senderid = NULL_OBJID,
                         targetid = lp_id, targetos = cur_os);
      EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

    } /* if (replace_one_by_many) */
    else
    {
      OM_stat = om$send (msg = message Root.disconnect (lp_ed_chan,
                          *many_eds_list, cur_os, ed_lp_chan),
                         senderid = NULL_OBJID,
                         targetid = lp_id, targetos = cur_os);
      EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

      if (delete_taken_out_eds)
      {
        OM_stat = om$send (msg = message Root.delete(1),
                           senderid = NULL_OBJID,
                           targetid = *many_eds_list, targetos = cur_os);
      } /* if (delete_taken_out_eds) */

    } /* else for if (replace_one_by_many) */

   } /* for (i = 0; i < num_many_eds[cur_ed]; i++, many_eds_list++) */

   if (check_ls_lp_props)
   {
     /*
      * It may be possible that the loop is now natural
      * and so is its loopset. Make a check for this 
      * and set properties appropriately.
      */

     ls_props = ed_props = NULL;
     lp_props = EMLP_NATURAL;

     OM_stat = om$send (msg = message EMSboundary.EMcheck_props (
                         &mthd_stat, &ls_props, &lp_props, &ed_props),
                        senderid = NULL_OBJID,
                        targetid = lp_id, targetos = cur_os);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

     OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info(
                         &mthd_stat, &sf_id, NULL),
                        senderid = NULL_OBJID,
                        targetid = lp_id, targetos = cur_os);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

     OM_stat = om$get_channel_objects (osnum = cur_os,
                  objid = sf_id, p_chanselect = &sf_ls_chan,
                  list = &ls_list, size = 1, count = &count);
     EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);

     ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;
     lp_props = ed_props = NULL;
	
     OM_stat = om$send (msg = message EMSboundary.EMcheck_props (
                          &mthd_stat, &ls_props, &lp_props, &ed_props),
                        senderid = NULL_OBJID, 
                        targetid = ls_list.S_objid, targetos = cur_os);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

   } /* if (check_ls_lp_props) */

  } /* for (cur_ed = 0; cur_ed < num_one_eds; cur_ed++, one_eds_list++) */

 wrapup:
  EMWRAPUP (OM_stat, *EFmsg, "In EFrpl_old_new_eds");
  return;

} /* void EFrpl_old_new_eds () */


end implementation EMSsfregmod;
