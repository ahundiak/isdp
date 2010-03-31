/*
  OVERVIEW

  This file contains query APIs on features and booleaned objects.
*/
  
class implementation EMSdpr;

#include "emsdef.h"
#include "emsbool.h"
#include "EMSasfeatdef.h"
#include "REaddrmfea.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/clsid.h"
#include "channel.h"
#include "PWapi/objquery.h"
#include "PWapi/featquery.h"
#include "PWapi/grprops.h"
#include "PWapi/grownquery.h"

extern GRclassid OPP_EMSsfboolean_class_id, OPP_EMSslboolean_class_id;
extern GRclassid OPP_EMSsffeature_class_id, OPP_EMSdpr_class_id;
extern GRclassid OPP_EMSslslotfea_class_id, OPP_EMSsfboolfea_class_id;
extern GRclassid OPP_EMSsfaddraft_class_id, OPP_EMSlift_class_id;

from EMSsfboolean import EMget_operation_type;
from EMSassoc import EMget_info;


/*
  DESCRIPTION

  The following function returns a TRUE if the supplied objid belongs to
  a 'true' Boolean node. A 'true' Boolean node is one with only two operands
  and is created by one of the Boolean types described in the enumeration --
  PWbooltype. If found, the Boolean operation is also returned


  HISTORY

  SS  :  03/26/96  :  Creation
*/
  
PWboolean pwIsBooleanObj
(
  PWobjid obj,
  PWosnum os,
  enum PWbooltype *booltype
)
{
  PWboolean isbool;
  IGRlong msg_loc;
  IGRuint count=0;
  GRclassid classid;
  enum EMSbooltype general_type, exact_type;
  OM_S_CHANSELECT chan_to_comps;

  *booltype = PWbool_unknown;
  isbool = FALSE;

  classid = omClassidFromObjid (obj, os);
  if (classid == OPP_EMSsfboolean_class_id ||
      classid == OPP_EMSslboolean_class_id)
  {
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    om$get_channel_count (objid = obj, osnum = os, 
     p_chanselect = &chan_to_comps, count = &count);
    if (count == 2)
    {
      general_type = exact_type = EMSbool_nullNullU;
      om$send (msg = message EMSsfboolean.EMget_operation_type
       (&msg_loc, NULL, &exact_type, &general_type, NULL, NULL,
       NULL, NULL, NULL, NULL, NULL, NULL), targetid = obj, 
       targetos = os, senderid = PW_K_NullObjid);

      general_type = exact_type;
      if (exact_type == EMSbool_saveside)
        general_type = EMSbool_saveside;
  
      if (general_type == EMSbool_union)
      {
        *booltype = PWbool_union;
        isbool = TRUE;
      }
      else if (general_type == EMSbool_intersect)
      {
        *booltype = PWbool_intersection;
        isbool = TRUE;
      }
      else if (general_type == EMSbool_difference)
      {
        *booltype = PWbool_difference;
        isbool = TRUE;
      }
      else if (general_type == EMSbool_saveside)
      {
        *booltype = PWbool_saveside;
        isbool = TRUE;
      }
    }
  }

  return (isbool);
}


/*
  DESCRIPTION

  The following function returns the type of a supplied feature node. If the
  given object is not a feature node or is not a recognized one, then it 
  returns the type -- PWfeat_unknown. See PWgmdata.h for the different
  enumerations of a feature.


  HISTORY

  SS  :  04/03/96  :  Creation
*/
  
enum PWfeattype pwFeatureType
(
  PWobjid featobj,
  PWosnum os
)
{
  IGRlong msg;
  PWresult result=PW_K_Success;
  PWclassid featclass;
  unsigned int i_feattype, info_size=0;
  enum PWfeattype feattype=PWfeat_unknown;

  result = om$send (msg = message EMSassoc.EMget_info (&msg, NULL,
            &i_feattype, &info_size, NULL), targetid = featobj, targetos = os,
            senderid = PW_K_NullObjid);
  OnErrorCode (result & msg, wrapup);
  featclass = omClassidFromObjid (featobj, os);

  if (omIsAncestryValid (featclass, OPP_EMSsffeature_class_id))
  {
    if (i_feattype == EMS_ASSOC_FEATURE_ADD_MATERIAL)
      feattype = PWfeat_addmaterial;
    else if (i_feattype == EMS_ASSOC_FEATURE_REMOVE_MATERIAL)
      feattype = PWfeat_removematerial;
    else if (i_feattype == EMS_ASSOC_FEATURE_RIB)
      feattype = PWfeat_rib;
  }
  else if (omIsAncestryValid (featclass, OPP_EMSslslotfea_class_id))
  {
    feattype = PWfeat_slot;
  }
  else if (omIsAncestryValid (featclass, OPP_EMSsfboolfea_class_id))
  {
    if ((i_feattype >= EMS_ASCIR_THRU_ALL_HOLE_TYPE  &&
         i_feattype <= EMS_ASCIR_FINITE_V_HOLE_TYPE) ||
        (i_feattype >= EMS_ASCIR_THRU_ALL_HOLE_TYPE_1 &&
         i_feattype <= EMS_ASCIR_FINITE_V_REFPLANE))
      feattype = PWfeat_hole;
    else if (i_feattype >= EMS_ASCBORE_AXIS_NOR_AND_THRU &&
             i_feattype <= EMS_ASCBORE_AXIS_ALI_AND_BLIND)
      feattype = PWfeat_counterbore;
    else if (i_feattype >= EMS_ASCSINK_AXIS_NOR_AND_THRU &&
             i_feattype <= EMS_ASCSINK_AXIS_ALI_AND_BLIND) 
      feattype = PWfeat_countersink;
    else if (i_feattype == EMS_I_AM_A_BOSS)
      feattype = PWfeat_boss;
    else if (i_feattype == EMS_I_AM_A_POCKET)
      feattype = PWfeat_pocket;
    else if (i_feattype >= EMS_ASPRO_THRU_ALL_HOLE_TYPE  &&
             i_feattype <= EMS_ASPRO_THRU_UNTIL_HOLE_TYPE)
      feattype = PWfeat_cutout;
  }
  else if (omIsAncestryValid (featclass, OPP_EMSsfaddraft_class_id))
  {
    if (i_feattype == REPLACE_SURFACE)
      feattype = PWfeat_replacesf;
    else
      feattype = PWfeat_adddraft;
  }
  else if (omIsAncestryValid (featclass, OPP_EMSlift_class_id))
  {
    feattype = PWfeat_liftface;
  }

wrapup:
  return (feattype);
}

/*
  DESCRIPTION

  The following function inputs a feature node object (protrusion, cutout,
  hole, etc) and outputs the object(s) that serve to define it. It obtains
  the surface-entities that have been used to modify the primitive while
  forming the feature. In the case of a Boolean operation, all the
  operands except for the first one are considered the modifiers.


  HISTORY

  SS  :  04/03/96  :  Creation
*/
  
PWresult pwGetFeatureSfs
(
  PWobjid featnode,
  PWosnum os,
  int *num_featsfs,
  PWobjid **featsfs
)
{
  int num_comps;
  PWresult result=PW_K_Success;
  OM_S_CHANSELECT chan_to_comps;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  num_comps = omNumObjsOnChannel (featnode, os, &chan_to_comps);
  if (num_comps >= 2)
  {
    *featsfs = (PWobjid *) malloc (num_comps * sizeof (PWobjid));
    OnErrorState (!*featsfs, result, 
     SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);

    OnErrorState (
     omGetObjsOnChannel (featnode, os, &chan_to_comps, *featsfs) != num_comps,
     result, SetError (PW_K_Pathway, PW_K_Internal), wrapup);
 
    *num_featsfs = num_comps-1;
    memcpy (*featsfs, &(*featsfs)[1], *num_featsfs * sizeof (PWobjid));
  }
  else
  {
    OnErrorState (TRUE, result, SetError (PW_K_Pathway, PW_K_InvalidArg),
     wrapup);
  }

wrapup:
  return (result);
}


/*
  DESCRIPTION

  The following function returnd the feature node responsible for a given
  surface. The input surface id -- 'sf' belongs to the "modifier" set of
  of surfaces of the output feature node. The "modifier" set is defined as
  the set of surfaces that go to add/subtract/modify the previous state of
  the surface entity, before the feature was applied.

  If such a feature node cannot be found then the out is PW_K_NullObjid.

 
  HISTORY

  SS  :  04/06/96  :  Creation
*/

PWobjid pwFeatureIdFromSf
(
  PWobjid sf,
  PWosnum os
)
{
  PWobjid featnode=PW_K_NullObjid, ownobj;

  if (pwIsRigidComp (sf, os))
  {
    ownobj = pwOwnerOfComp (sf, os);

    if (omIsAncestryValid (omClassidFromObjid (ownobj, os), 
         OPP_EMSdpr_class_id))
      featnode = ownobj;
    else
      featnode = pwFeatureIdFromSf (ownobj, os);
  }

  return (featnode);
}


/*
  DESCRIPTION

  The following function returns TRUE if the input objid is a feature tree
  node. It also returns the feature type of the state as enumerated in
  PWgmdata.h.

  HISTORY

  Aditya  :  07/26/96  :  Creation
*/

PWboolean pwIsFeatureState
(
  PWobjid feature_id,
  PWosnum os,
  enum PWfeattype *feat_type
)
{
  int sts=1;

  PWresult PWsts=PW_K_Success;
  PWclassid classid;

  /*
   * Validate the incoming feature state.
   */
  sts = om$is_objid_valid ( objid = feature_id, osnum = os);
  OnErrorState(!(1&sts), PWsts, 
   SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  classid = omClassidFromObjid ( feature_id , os ) ;
  OnErrorState(!(omIsAncestryValid ( classid , OPP_EMSdpr_class_id )),
               PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  if(feat_type)
  {
    *feat_type = pwFeatureType( feature_id, os);
  }

wrapup:

  if(IsError(PWsts)) return(FALSE);

  return(TRUE);
}

/*
  DESCRIPTION

  The following function returns TRUE if the input objid is the top state
  of a feature tree, which is the active state of the feature tree.

  HISTORY

  Aditya  :  07/26/96  :  Creation
*/

PWboolean pwIsFeatureActive
(
  PWobjid feature_id,
  PWosnum os
)
{
  unsigned short props=0;
  long msg=EMS_S_Success;
  int sts=1;

  PWresult PWsts=PW_K_Success;

  /*
   * Check if the feature is an active state of the dpr tree.
   */
  sts = om$send(msg = message EMSdpr.EMget_dpr_props( &msg, &props),
                senderid = PW_K_NullObjid,
                targetid = feature_id,
                targetos = os);
  OnErrorState(!(1 & msg & sts), PWsts, 
   SetError (PW_K_Pathway, PW_K_Error), wrapup);

  OnErrorState(!(props & EMSIS_ACTIVE_STATE), PWsts, 
   SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

wrapup:

 if(IsError(PWsts)) return(FALSE);

 return(TRUE);
}

end implementation EMSdpr;
