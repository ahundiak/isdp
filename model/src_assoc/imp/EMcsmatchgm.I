/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

/*
History
        10-Jun-90       SM      Creation.
        09-Aug-90       SM      Change class of my component after sending
                                AEstore to it, if it is not of the same class
                                as rhs component.
        19-Sep-90       DLB     Major rewrite to do topology match- instead of
                                moving right to left, tags, parents, & depends.
                                are moved left to right.
        10-Oct-90       SM      Untill error recovery,delete the
                                old dude.
        01/23/91        DLB     Added HAS_COMPOSITE_OWNER option.
        01/29/91        DLB     Turn off NOT_IN_RTREE bit since this dude is
                                permanent.
        02/11/91        DLB     Change name for 2.0.1
        03/23/91        DLB     Match surface orientation. Add EFmatch_orient
                                function.
        04/02/91        DLB     Don't match orient if in mismatch pass.
        05/18/91        DLB     Fixed a bad bug in the match orient stuff.
        08/06/91        AIC     Added md_env to EFsend_store_on call.
        08/10/91        pp      Checking for component count before matching
        10/14/91        DLB     Added DONT_ORIENT check.
        03/19/92        SM      Handle the fact that a composite may not
				have a EMSsubbs type component. Could happen
				for NULL state
*/

#include "EMSdpr.h"
#include "emsdef.h"
#include "EMSssprops.h"
#include "OMmacros.h"

from EMSsubbs import EMget_props, EMset_props;

method EMmatch_geometry(IGRlong *EMmsg; IGRushort options;
                        struct GRmd_env *md_env; GRobjid new_objid)
{
 IGRlong         OM_stat=OM_S_SUCCESS, EFsend_store_on(), EFmatch_orient();
 IGRboolean      EFmatch_classes(), EFisAncestryValid();
 OM_S_CHANSELECT to_comps;
 extern OMuword  OPP_EMSsolid_class_id;
 

 *EMmsg = EMS_S_Success;

 if (new_objid == my_id) return(OM_S_SUCCESS);

 if (!(options & EMstore_opt_MATCH_FAILED) && 
     !EFmatch_classes(EMmsg, my_id, new_objid, OM_Gw_current_OS, NULL)) 
 {
   options |= EMstore_opt_MATCH_FAILED;   
 }

 /*Move tag (if match successful), name, channels*/
 OM_stat = EFmove_to_rhs(EMmsg, my_id, new_objid, sender_id, OM_Gw_current_OS,
                         options); 
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 EMmake_chanselect(GRcmpowner_to_components, &to_comps);

 if (!(options & EMstore_opt_DONT_ORIENT) &&
     !(options & EMstore_opt_HAS_COMPOSITE_OWNER) &&
     !(options & EMstore_opt_MATCH_FAILED) &&
     !EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, OPP_EMSsolid_class_id,
                        FALSE))
 {
   /*Match the orientation between the 2 composites.*/
   IGRint ii;
   GRobjid old_comp_id = NULL_OBJID, comp_id = NULL_OBJID;
   OMuword dumosnum;
   IGRint          comp_count;
   
   OM_stat = om$get_channel_count(p_chanselect = &to_comps,
                                  objid = my_id,
                                  osnum = OM_Gw_current_OS,
                                  count = (OMuint *)&comp_count);
   if (!(1 & OM_stat)) goto wrapup;                                     
   
   if (comp_count)
   {
    comp_id = my_id;
    for(ii=0; ii<2; ii++)
    {
     do
     {
       OM_stat = om$get_objid_at_index(objid = comp_id,
                                       p_chanselect = &to_comps,
                                       index = 0,
                                       objidaddr = &comp_id,
                                       osnumaddr = &dumosnum);
       if(OM_stat == OM_E_INVINDEX)
        {
	 OM_stat = OM_S_SUCCESS;
	 comp_id = NULL_OBJID;
	 break;
        }
       if (!(1 & OM_stat)) goto wrapup;                                     
     } 
     while (!EFisAncestryValid(EMmsg, comp_id, OM_Gw_current_OS, 
                               OPP_EMSsubbs_class_id, FALSE));
     if (!(1 & *EMmsg)) goto wrapup;

     if (ii == 0)
     {
       old_comp_id = comp_id;
       comp_id = new_objid;
     }
    }

   /*Ensure that the new ids orientation matches me*/
   if( (!IF_NULL_OBJID(old_comp_id)) && (!IF_NULL_OBJID(comp_id)))
    {
     OM_stat = EFmatch_orient(EMmsg, old_comp_id, comp_id, new_objid,
                            OM_Gw_current_OS, NULL);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }
 }

 options |= EMstore_opt_HAS_COMPOSITE_OWNER;
 OM_stat = EFsend_store_on(EMmsg, my_id, OM_Gw_current_OS, new_objid,
                           &to_comps, options, md_env);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;                           

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "csf.EMmatch_geom")
  return(OM_stat);
}

IGRlong EFmatch_orient(EMmsg, old_id, new_id, reverse_id, osnum, options)
IGRlong           *EMmsg;
GRobjid           old_id;
GRobjid           new_id;
GRobjid           reverse_id;
OMuword           osnum;
IGRushort options;
{
  IGRlong OM_stat=OM_S_SUCCESS;
  IGRuchar old_props, new_props; 


  OM_stat = om$send(msg = message EMSsubbs.EMget_props(EMmsg, &old_props),
                    senderid = NULL_OBJID,
                    targetid = old_id,
                    targetos = osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;  

  OM_stat = om$send(msg = message EMSsubbs.EMget_props(EMmsg, &new_props),
                    senderid = NULL_OBJID,
                    targetid = new_id,
                    targetos = osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;  

  if ((old_props & EMSIS_NRML_REVERSED) != (new_props & EMSIS_NRML_REVERSED))
  {
    OM_stat = om$send(msg = message EMSsubbs.EMset_props(EMmsg,
                            EMSIS_NRML_REVERSED, EMS_O_TOGGLE),
                      senderid = NULL_OBJID,
                      targetid = reverse_id,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;             
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFmatch_orient")
  return(OM_stat);
}

end implementation EMScompsurf;
