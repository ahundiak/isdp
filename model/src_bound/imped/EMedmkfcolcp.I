/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSlm.h"

#define INITIAL_SIZE    30
#define INCREMENT       10

method EMmkface_collapse_copy (
        IGRlong                  *EMmsg;
        struct EMSpartolbasis    *partolbasis;
        IGRboolean               always_cp_ed;
        GRobjid                  *ed_cp_id;
        struct EMSmkf_edcon_info **ed_con_info;
        IGRint                   *num_entries;
        IGRint                   *array_size)

/*
 Notes
        This method is currently used by MAKE FACE
        operation. It is not clear if this functionality
        can be used any where else.

        In case of a make face operation, the boundaries 
        are moved from the original surface to the newly
        made face. Since a boundary can not share two
        (u,v) spaces, it is needed to copy the boundary
        if necessary and then collapse it (remove all
        of the intermediate edges). Also, during movement,
        move the common edge connections appropriately.

History 
        RC      05/10/87   Creation Date
        RC      11/02/87   Modified for version 1.1.0
        DLB     06/18/91   Fixed the creator id.
*/

{
  IGRlong             OM_stat;
  IGRlong   mthd_stat;
  OMuint              num_my_owners;
  GRobjid             cm_ed_id;
  IGRboolean          copy_myself = TRUE;
  OMuint              num_cm_ed;
  OM_S_CHANSELECT     to_owner, com_ed_chan;


  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  *ed_cp_id = NULL_OBJID;

  /*
   * if always_cp_ed is FALSE, it means copy myself
   * whenever necessary. The criterion for deciding
   * to copy myself is based upon the number of owners
   * I have across my to_owners channel.
   * If I am have only one owner, it is the one who
   * sent this message. Therefore, there is no need
   * to copy myself.
   */

  if (!always_cp_ed)
  {
    to_owner.type = OM_e_addr;
    to_owner.u_sel.addr = &ME.EMSedge->to_owner;

    OM_stat = om$get_channel_count (object = me,
                                    p_chanselect = &to_owner,
                                    count = &num_my_owners);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    if (num_my_owners <= 1) copy_myself = FALSE;
  }

  if (copy_myself)
  {
     OM_stat = om$construct_and_copy ( object = me, 
                                       osnum = OM_Gw_current_OS,
                                       p_objid = ed_cp_id);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     {
       /*DLB*/
       extern OM_S_OBJID current_creator;
       OM_stat = om$send(msg = message EMSboundary.EMfix_creator_id(EMmsg,
                               NULL, current_creator, NULL),
                         targetid = *ed_cp_id);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;
     }

     OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &com_ed_chan);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     /*
      * get the common edge id
      */

     OM_stat = om$get_channel_count (object = me, 
                                     p_chanselect = &com_ed_chan,
                                     count = &num_cm_ed);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
  
     if (num_cm_ed)
     {
       OM_stat = om$send (msg = message EMSboundary.EMget_objid (
                           &mthd_stat, &cm_ed_id), senderid = my_id,
                         p_chanselect = &com_ed_chan);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       /*
        * Move my common edge connection to my copy
        * and fill this information in ed_con_info struct.
        */

       OM_stat = om$send (msg = message Root.move_chan( com_ed_chan, 
                         my_id, OM_Gw_current_OS, com_ed_chan),
                        targetid = *ed_cp_id);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     
       if (!(*array_size))      
       {
         *ed_con_info = NULL;
         *ed_con_info = (struct EMSmkf_edcon_info *) 
                om$malloc (size = (unsigned) 
                (INITIAL_SIZE * sizeof (struct EMSmkf_edcon_info)));

         EMerr_hndlr((!(*ed_con_info)),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

         *array_size = INITIAL_SIZE;

       }
       else if ((*num_entries + 1) > *array_size)
       {
         (*array_size) += INCREMENT;
         *ed_con_info = (struct EMSmkf_edcon_info *) 
           om$realloc (ptr = (IGRchar *)*ed_con_info,   size = (unsigned) 
           (*array_size) * sizeof(struct EMSmkf_edcon_info));
         EMerr_hndlr((!(*ed_con_info)),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

       }
 
       (*ed_con_info)[*num_entries].ed_id = my_id;
       (*ed_con_info)[*num_entries].cm_ed_id = cm_ed_id;
       (*num_entries)++;
    
     } /* if (num_cm_ed) */

  } /* if (copy_myself) */

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMSedge.EMmkface_collapse_copy");

  return(OM_stat);


}

end implementation EMSedge;
