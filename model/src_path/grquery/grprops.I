/*
  OVERVIEW
  
  This file contains the set of APIs that returns the various properties of 
  GRgraphics objects.

  
  HISTORY

  SS   :  06/13/95   :   Creation
*/

class implementation GRgraphics;

#include "emsdef.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/grprops.h" 

extern PWclassid OPP_GRcmpowner_class_id;

PWboolean pwIsRigidComp
(
  PWobjid grobj,
  PWosnum os
)
{
  unsigned int num_owners=0;
  long msg_loc=TRUE;
  short props=NULL;
  OM_S_CHANSELECT to_owners;

  om$send (msg = message GRgraphics.GRgetprops (&msg_loc, &props),
   targetid = grobj, targetos = os, senderid = PW_K_NullObjid);

  if (props & GR_RIGID_RELATIONSHIP)
    return TRUE;

  EMmake_chanselect (GRconnector_to_owners, &to_owners);

  om$get_channel_count (objid = grobj, osnum = os,
   p_chanselect = &to_owners, count = &num_owners);

  if (num_owners == 1)
    return TRUE;

  return FALSE;
}


PWboolean pwIsRigidOwner
(
  PWobjid grobj,
  PWosnum os
)
{
  unsigned int i, num_comps=0, num_rigid_comps=0;
  short props;
  long msg_loc;

  if (omIsAncestryValid (
       omClassidFromObjid (grobj, os), 
       OPP_GRcmpowner_class_id))
  {
    num_comps = pwNumCompsOfOwner (grobj, os);
    for (i=0; i<num_comps; i++)
    {
      props = NULL;
      om$send (msg = message GRgraphics.GRgetprops (&msg_loc, &props),
       targetid = pwCompAtInxOfOwner (grobj, i), targetos = os,
       senderid = PW_K_NullObjid);
      
      if (props & GR_RIGID_RELATIONSHIP)
        num_rigid_comps++;
    }

    return (num_comps == num_rigid_comps);
  }
  else
  {
    return (FALSE);
  }
}

/*----------------------------- Internal APIs -----------------------------*/

short GraphicsProps
(
  PWobjid grobj,
  PWosnum os
)
{
  short props=NULL;
  long msg_loc;

  om$send (msg = message GRgraphics.GRgetprops (&msg_loc, &props),
   targetid = grobj, targetos = os, senderid = PW_K_NullObjid);

  return (props);
}


end implementation GRgraphics;
