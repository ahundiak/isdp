class implementation EMSsurface;

#include "msdef.h" /* MS message codes */
#include "OMmacros.h"
#include "emsdef.h"
#include "EMcp.h"
#include "godef.h"
#include "gocmacros.h"

#define NO_COPIED_ID -9999  /*Chopra's definition...not Daves!!! EMcpsearch.C*/

from EMSboundary import EMget_put_creator_id;

method GRcopy(IGRlong             *msg;
              struct GRmd_env     *obj_mdenv; 
              struct GRmd_env     *new_mdenv;
              GRobjid             *newobjid)
/*
Description 
This file contains the GRcopy method for the B-spline surface class of the
    GRgrpahics class.  

  *msg          method completion code.
  *obj_mdenv    struct describing objects's present environment.
  *new_mdenv    struct describing copy's environment.
  *newobjid     objid of the copied composite surface.

Return Values
  Upon exit the completion code will be one of 

   - MSSUCC if successful
   - MSFAIL(severe) if failure


History
  RC     12/03/86 : Creation date.
  RC     03/04/87 : Modified
  RC     10/29/87 : Modified for version 1.1.0
  dhm    04/05/88 : Added GR_NOTIFY_LISTENERS.
  RC     07/13/88 : Removed GR_NOTIFY_LISTENERS as it is done by EMintcopy
                    implementations of the surface and composite surface.
  SM     06-Jul-89: Argument change in EMSsurface.EMintcopy
  DLB    06/01/91 : Add EMfix_creator_id send.
  DLB    02/15/92 : Modified update of copies creator id to handle topology not
                    in the active model. 
  AMD    02/25/92 : Fix for TR 92N1751.
*/
{
  IGRlong            OM_stat;
  IGRint             ii;
  GRobjid            copy_id, cp_creator_id;
  struct EMcp_info   copy_info;
  extern OM_S_OBJID  current_creator;
  extern OMuword     OPP_EMSboundary_class_id, OPP_EMSloopset_class_id;
  extern void        EMcpsearch();
  GRspacenum         osnum; 
 
  *msg = MSSUCC;
  OM_stat = OM_S_SUCCESS;
 
  copy_info.num_entries = 0;
  copy_info.array_size = 0;
  copy_info.objid_array = NULL;
 
  /*send a message to myself to perform the copy process*/
  OM_stat = om$send(msg = message EMSsurface.EMintcopy(msg,
                          obj_mdenv, new_mdenv, newobjid, &copy_info, 
                          NULL, NULL),
                    targetid = my_id);
  if (!(1 & OM_stat & *msg)) goto wrapup;

  osnum = new_mdenv->md_id.osnum;
      
  for(ii=0; ii<copy_info.num_entries; ii++)
  {
    copy_id = copy_info.objid_array[ii*2+1];
 
    if (copy_id == NO_COPIED_ID) continue;
 
    if (EFisAncestryValid(msg, copy_id, osnum, 
                          OPP_EMSboundary_class_id, FALSE) &&
        !EFisAncestryValid(msg, copy_id, osnum,
                           OPP_EMSloopset_class_id, FALSE))
    {
      /*Got a copied topology element which must have its creator changed*/
 
      if (current_creator != NULL_OBJID)
      {
        /*Simply set the copied objects creator id to current_creator*/
        cp_creator_id = current_creator;
      }
      else
      {
        /*Must determine the creator of the copied object*/
        IGRboolean  copy_exists;
 
        OM_stat = om$send(msg = message EMSboundary.EMget_put_creator_id
                                (msg, &cp_creator_id, FALSE),
                          targetid = copy_id, 
                          targetos = osnum, 
                          senderid = NULL_OBJID);
        if (!(1 & OM_stat & *msg)) goto wrapup;                           
 
        /*Is there a map between old creator id and the new creator id?*/ 
        EMcpsearch(msg, cp_creator_id,
                   &cp_creator_id, &copy_info, 0, &copy_exists);
        if (!(1 & *msg)) goto wrapup;
 
        if (!copy_exists)
        {
          /*No - default to my copy counterpart as the creator*/
          cp_creator_id = *newobjid;
        }
        /*else Yes - and EMcpsearch set cp_creator_id to new creator*/
      }                                
 
      /*Put the new creator id in the copied topology object*/
      OM_stat = om$send(msg = message EMSboundary.EMget_put_creator_id(msg,
                              &cp_creator_id, TRUE), 
                        targetid = copy_id, 
                        targetos = osnum, 
                        senderid = NULL_OBJID);
      if (!(1 & OM_stat & *msg)) goto wrapup;                           
    }
  }

wrapup:
  EMWRAPUP(*msg, OM_stat, "EMSsurf.GRcopy");
  if (copy_info.objid_array) om$dealloc(ptr = copy_info.objid_array);
  return(OM_stat);
}
end implementation EMSsurface;
