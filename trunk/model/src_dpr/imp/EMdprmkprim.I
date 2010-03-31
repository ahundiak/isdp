/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMSmsgdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "stdio.h"
#include "string.h"

extern OMuword OPP_EMSsfsolid_class_id,
               OPP_EMSgensolid_class_id,
               OPP_EMSgencompsf_class_id, 
               OPP_EMSsldpr_class_id, 
               OPP_EMSsfdpr_class_id;

from EMSsurface import EMcompress_top, EMmovesurfs, EMfix_creator_id;
from NDnode import NDmove_to_root;

method EMmake_primitive1(IGRlong *EMmsg; struct GRmd_env *my_env;
                         struct GRid *new_id)
/*
Description
    This method will compress the state tree into a single primitive
    composite object or a single surface by:
 
    1) Creating the proper class of composite object.  Note that if this is
       single surface state tree then no composite object will be created. 
       Instead the single surface will be disconnected from the tree.
  
    2) Sending EMmovesurfs to myself to move all of my leaf components
       (these will be surfaces) to the new composite object.  Again if this
       is a single surface state tree then EMmovesurfs will disconnect the
       surface AND return its id to me so I will know who the surface is.
       EMmovesurfs will take care of deleting all composite object that had
       their surfaces removed.

    4) Compress the topology of the surfaces on the new composite object or
       the surface returned by EMmovesurfs. 

Return values 
    EMS_S_Success is returned if all is well.
    EMS_E_InvalidSend is returned if this is not a surface or solid state
                      tree.

Change history:
    SM    04/22/93 When fixing creator id, use NULL_OBJID as the new creator.
    DLB   06/01/91 Fix up the creator id in topology of the compressed node.
    DLB   05/15/91 Don't move non-associative nodes to root.
    DLB   04/30/91 Support IS_ASSOC and EXTERNAL_CONSTR'd bits.
    DLB   01/15/90 Added check to putname to only put a non-null name.
    DLB   10/05/89 Added sends to move name of active state to new prim.
    DLB   10/23/88 Removed reduce range code. RR is now sent by the compress
                   tree command.  This change is done because the other
                   code sends EMmake_primitive but does not want the 
                   surface to change.  So, anyone wanting to reduce the
                   range of the surface must send the message explicitly.
    DLB   06/13/88 Added code to construct EMSsfsolid in special cases.
    Moghe 04/xx/88 Added send for reduce range.
    DLB   11/02/87 Rewrote for version 1.1.0
    DLB   04/14/87 Major mods and the addition of EMmovesurfs method.
    gupta 12/02/86 Creation date
    RC    12/02/86 Creation date
*/
{
 IGRlong         OM_stat;
 IGRint          count;
 OM_S_CHANSELECT to_owners;
 struct GRid     prim_id;
 IGRshort        action;
 OMuword         construct_class;
 extern IGRboolean EFisAncestryValid();
 IGRchar         name[DI_PATH_MAX];
      

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
    
 /*Get my name for use later - IGNORE return codes*/
 om$send(msg = message GRvg.GRgetname(EMmsg, name),
         targetid = my_id); 
 *EMmsg = EMS_S_Success;

 /*First determine how may surfaces I own.*/
 OM_stat = om$send(msg = message GRowner.GRget_number_components(EMmsg,
                         &count),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;     
  
 /*Construct the primitive state*/
 if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, OPP_EMSsldpr_class_id,
                       FALSE))
 {
   /*This is a solid state tree.*/
   if (count == 1)
     /*This is a single surface solid.*/
     construct_class = OPP_EMSsfsolid_class_id;
   else
     /*This is a multipe surface solid.*/
     construct_class = OPP_EMSgensolid_class_id;
 }
 else
 {
   if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, OPP_EMSsfdpr_class_id,
                         FALSE))
   {
     /*This is a surface or composite surface state tree.*/
     if (count == 1)
       /*This is a single surface state tree.*/
       construct_class = NULL;
     else
       /*This is a composite surface state tree.*/
       construct_class = OPP_EMSgencompsf_class_id;
   }
   else
   {
     /*This is a type of state tree I don't understand.*/
     *EMmsg = EMS_E_InvalidSend; 
     goto wrapup;
   }
 }

 /*If this is a composite tree then I will construct 
  * the primitive type for it.
  */
 if (construct_class)
 {
   OM_stat = om$construct(classid = construct_class,
                          p_objid = &prim_id.objid);
   if (! (1 & OM_stat)) goto wrapup;
 }
 else
   prim_id.objid = NULL_OBJID;
 
 prim_id.osnum = OM_Gw_current_OS;

 /*Move all my surfaces to the new primitive.
  *
  *NOTE: If this is a surface tree then the move surfs message will
  * eventually be sent to the one surface that this state tree exists for. 
  * The EMmovesurfs method at the subsurface level will disconnect itself 
  * from its next state and return its id as the prim_id.  In order for the
  * subsurface to recognize that it is the only surface I must send the
  * prim_id variable with NULL_OBJID as the object id.
  */
 
 OM_stat = om$send(msg = message EMSsurface.EMmovesurfs(EMmsg, &prim_id, 
                         my_env),
                   targetid = my_id);
 if (! (1 & OM_stat)) goto wrapup;

 /*Tell the world about the new composite.*/
 new_id->objid = prim_id.objid;
 new_id->osnum = prim_id.osnum;

 OM_stat = EMmake_chanselect(GRconnector_to_owners, &to_owners);
 if (! (1 & OM_stat)) goto wrapup;

 /*Move all connected on my to_owners channel to the new object.*/
 OM_stat = om$send(msg = message Root.move_chan(to_owners, my_id,
                         OM_Gw_current_OS, to_owners),
                   targetid = prim_id.objid);
 if (! (1 & OM_stat)) goto wrapup;
 
 if (strlen(name))
 {
   /*Move the elements name to the new primitive - IGNORE return codes.*/
   om$send(msg = message GRvg.GRputname(EMmsg, name),
           targetid = prim_id.objid); 
   *EMmsg = EMS_S_Success;
 }

 /*And lastly move my GRgraphics props to the new composite*/
 action = TRUE;
 ME.GRgraphics->properties &= ~(GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT);
 OM_stat = om$send(msg = message GRvg.GRchgprops(EMmsg, &action,
                         &ME.GRgraphics->properties),
                   targetid = prim_id.objid);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;                   

 { /*INTENTIONAL - DLB 04/30/91*/
   IGRlong loc_msg;

   if (construct_class)
   {
     /*i be a composite chap*/
     struct GRid tmp_GRid;
     OM_S_CHANSELECT to_comps;

     EMmake_chanselect(GRcmpowner_to_components, &to_comps);
     om$send(msg = message NDnode.NDmove_to_root(&loc_msg, &tmp_GRid, my_env),
             senderid = prim_id.objid,
             p_chanselect = &to_comps);
   }                       
   else
   {
     om$send(msg = message NDnode.NDmove_to_root(&loc_msg, &prim_id, my_env),
             targetid = prim_id.objid);
   }
 }                     
                   

 /*I and all others are gone so now compress the topology of the new
  * primitive.
  */
 OM_stat = om$send(msg = message EMSsurface.EMcompress_top(EMmsg, my_env),
                   targetid = prim_id.objid);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 /*Fix up the creator id in the topology of the compressed node.*/
 OM_stat = om$send(msg = message EMSsurface.EMfix_creator_id(EMmsg, NULL,
                         NULL_OBJID, NULL),
                   targetid = prim_id.objid);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;                   

wrapup:
 EMWRAPUP(*EMmsg, OM_stat, "dpr.mkprim")
 return (OM_stat);
}
end implementation EMSdpr;
