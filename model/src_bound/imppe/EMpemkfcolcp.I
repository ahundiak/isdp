/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSlm.h"
#include "emsdef.h"
#include "OMmacros.h"

#define INITIAL_SIZE 30
#define INCREMENT    10

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

History   RC 05/10/87   Creation Date
          RC 11/03/87   Modified for version 1.1.0
*/

{
  IGRlong               OM_stat;
IGRlong   mthd_stat;
  IGRint                chan_count;
  IGRboolean            copy_myself = TRUE, part_of_nat_edge;
  GRobjid               col_ed, child_id, ne_cp_id, ne_id, cm_ed_id;
  OMuint                num_cm_ed;
  OM_S_CHANSELECT       to_owner, com_ed_chan, pe_ed_chan;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  *ed_cp_id = NULL_OBJID;
  part_of_nat_edge = (ME.EMSedge->ed_props & EMED_NATURAL) ? TRUE : FALSE;

  OM_stat = EMmake_chanselect (EMSedge_to_owner, &to_owner);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
                        
  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &pe_ed_chan);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  /*
   * if always_cp_ed is FALSE, it means copy myself
   * whenever necessary. The criterion for deciding
   * to copy myself is based upon the number of owners
   * I have across my to_owners channel.
   * If I have only one owner, it is the one who
   * sent this message. Therefore, there is no need
   * to copy myself.
   */

  if (!always_cp_ed)
  {
    OM_stat = om$get_channel_count (object = me, p_chanselect = &to_owner,
                                    count = (OMuint *)&chan_count);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    if (chan_count <= 1) copy_myself = FALSE;
  }

  /*
   * Copy myself if needed and then compress myself or my_copy.
   */

  if (!copy_myself) col_ed = my_id;
  else
  {
    OM_stat = om$construct_and_copy(object = me, p_objid = &col_ed);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
  
    {
      /*DLB*/
      extern OM_S_OBJID current_creator;
      OM_stat = om$send(msg = message EMSboundary.EMfix_creator_id(EMmsg,
                              NULL, current_creator, NULL),
                        targetid = col_ed);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
     
    OM_stat = om$send (msg = message EMSboundary.EMget_objid( &mthd_stat,
                       &child_id), p_chanselect = &pe_ed_chan);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

    OM_stat = om$send (msg = message Root.connect ( pe_ed_chan, 
                        OM_K_MAXINT, child_id, OM_Gw_current_OS, to_owner,
                        NULL), targetid = col_ed);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
  }

  OM_stat = om$send (msg =  message EMSboundary.EMcompress_top(&mthd_stat,
                      partolbasis, ed_cp_id), targetid = col_ed);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

  /*
   * If I am a part of a natural edge, compressing the edge
   * tree will not compress the natural edge I am a part of.
   * In such a case construct a copy of my natural edge and
   * initialize it.
   */

  if (part_of_nat_edge)
  {
    OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                        &ne_id),
                       senderid = *ed_cp_id,                       
                       p_chanselect = &pe_ed_chan);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
  
    OM_stat = om$construct_and_copy(objid = ne_id, 
                                    obj_osnum = OM_Gw_current_OS,
                                    p_objid = &ne_cp_id);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
 
    {
      /*DLB*/
      extern OM_S_OBJID current_creator;
      OM_stat = om$send(msg = message EMSboundary.EMfix_creator_id(EMmsg,
                              NULL, current_creator, NULL),
                        targetid = ne_cp_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    OM_stat = om$send (msg = message Root.wild_disconnect (pe_ed_chan),
                       targetid = *ed_cp_id);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror,wrapup);

    OM_stat = om$send (msg = message Root.connect ( pe_ed_chan, 
                        OM_K_MAXINT, ne_cp_id, OM_Gw_current_OS, to_owner,
                        NULL), targetid = *ed_cp_id);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);


  } /* if (part_of_nat_edge) */

  /*
   * If I have been collapsed, my_common edge connection
   * is collpased to my collpsed version. On the other
   * hand, if my copy has been collpased, the my common
   * edge connection is not moved. Therefore, move
   * the common edge connection in case I have been copied 
   * fill this information in ed_con_info struct.
   */

 if (copy_myself)
 {
   OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &com_ed_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = om$get_channel_count (object = me, 
                                     p_chanselect = &com_ed_chan,
                                     count = &num_cm_ed);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   if (num_cm_ed)
   {
     OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                       &cm_ed_id), senderid = my_id,
                      p_chanselect = &com_ed_chan);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError, wrapup);

     OM_stat = om$send (msg = message Root.move_chan( com_ed_chan, my_id,
                       OM_Gw_current_OS, com_ed_chan), 
                      targetid = *ed_cp_id);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     if (! *array_size) 
     {
       *ed_con_info = NULL;
       *ed_con_info = (struct EMSmkf_edcon_info *) om$malloc (size = 
           (unsigned) (INITIAL_SIZE * sizeof(struct EMSmkf_edcon_info)));
       EMerr_hndlr(!(*ed_con_info),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

       *array_size = INITIAL_SIZE;

     }
     else if ((*num_entries + 1) > *array_size)
     {
      (*array_size) += INCREMENT;
      *ed_con_info = (struct EMSmkf_edcon_info *) om$realloc (ptr =
                     (IGRchar *)*ed_con_info, size = (unsigned) (*array_size) * 
                     sizeof(struct EMSmkf_edcon_info));
      EMerr_hndlr(!(*ed_con_info),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

     }
 
     (*ed_con_info)[*num_entries].ed_id = my_id;
     (*ed_con_info)[*num_entries].cm_ed_id = cm_ed_id;
     (*num_entries)++;

   } /* if (num_cm_ed) */

 } /* if (copy_myself) */
    
 if (*ed_cp_id == my_id) *ed_cp_id = NULL_OBJID;

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMSpartedge.EMmkface_collapse_copy");

  return(OM_stat);

}

end implementation EMSpartedge;
