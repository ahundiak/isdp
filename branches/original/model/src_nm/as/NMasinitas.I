class implementation NMassoc;

#include "emsmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"

from EMSsurface import EMtransform_to_associative;

extern OMuword OPP_ASsource_class_id, OPP_NDnodein_class_id, 
	       OPP_EMSsurface_class_id, OPP_EMSboundary_class_id;

#define StaticBuf	10

method EMinit_associative  (IGRlong *EMmsg;
                            IGRushort options;
                            IGRint num_parents;
                            struct EMSobject_info *parent_info;
                            IGRint type;
                            unsigned int size;
                            IGRchar *recomp_info;
                            struct GRvg_construct *construct_list)

{
 IGRlong		sts = OM_S_SUCCESS;

 *EMmsg = EMS_S_Success;

 /******* If the parent does not have NDnodein in its ancestry, there will
 be a ASsource object introduced. Following problem exists now - If the
 parent is owned, the owner is used as the source object. However the 
 ASreturn_go override at EMSassoc returns my_id as the go object. This causes
 the EMinit_associative and EMget_parent_info messages to be out of sync.
 If a parent A is owned by B, the latter message retunrs B as the parent
 during subsequent calls. Hence for now, I am using EMtransform_to_assoc..
 message if the parent is not associative, to avoid dealing with the source
 objects.
 SM May 20, 1991.
 ***********/
 {
  IGRint	i;
  struct GRid	*thisparent;
  OM_S_OBJID	junk;

  for(i=0; i<num_parents; i++)
   {
    thisparent = &parent_info[i].grid;
    if(EFisAncestryValid(EMmsg, thisparent->objid, thisparent->osnum, 
       OPP_NDnodein_class_id, FALSE)) continue;
    else if(EFisAncestryValid(EMmsg, thisparent->objid, thisparent->osnum, 
       OPP_EMSsurface_class_id, FALSE))
     {
      sts = om$send(msg = message EMSsurface.EMtransform_to_associative
            (EMmsg, &junk), targetid = thisparent->objid, 
            targetos = thisparent->osnum);
      if(!(1&*EMmsg&sts)) goto wrapup;
      EMerr_hndlr(!IF_EQ_OBJID(junk, thisparent->objid), *EMmsg, EMS_E_Fail, 
                wrapup);
     }
    else if(EFisAncestryValid(EMmsg, thisparent->objid, thisparent->osnum, 
       OPP_EMSboundary_class_id, FALSE))
     {
      GRobjid crtid = NULL_OBJID;

      /* Specifically using this function rather than sending the message
         EMget_put_creator_id, because the function sets the proper creator
         id in the instance data of the boundary object if it is not already
         stored.
      */
      sts = EFget_creator_id(EMmsg, thisparent->objid, thisparent->osnum, 
            &crtid, NULL);
      if(!(1&*EMmsg&sts)) goto wrapup;

      if( (!IF_NULL_OBJID(crtid)) && (EFisAncestryValid(EMmsg, crtid, 
           thisparent->osnum, OPP_EMSsurface_class_id,  FALSE)) &&
           (!EFisAncestryValid(EMmsg, crtid, thisparent->osnum, 
             OPP_NDnodein_class_id, FALSE)))
       {
        sts = om$send(msg = message EMSsurface.EMtransform_to_associative
              (EMmsg, &junk), targetid = crtid, targetos = thisparent->osnum);
        if(!(1&*EMmsg&sts)) goto wrapup;
        EMerr_hndlr(!IF_EQ_OBJID(junk, crtid), *EMmsg, EMS_E_Fail, wrapup);
       }
     }

   }
 }

 sts = om$send(mode = OM_e_wrt_message, 
       msg = message EMSassoc.EMinit_associative(EMmsg, options, num_parents, 
             parent_info, type, size, recomp_info, construct_list), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

wrapup:
EMWRAPUP(*EMmsg, sts, "NMassoc.EMinit_associative");
return(sts);
}


end implementation NMassoc;
