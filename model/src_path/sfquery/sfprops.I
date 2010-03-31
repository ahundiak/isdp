/*
  OVERVIEW

  This file consists of functions related to Surface Entity's properties.


  HISTORY

  SS    : 05/26/95  :  Creation
*/

class implementation EMSsurface;

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/sfdntrav.h" 
#include "PWapi/sfprops.h" 
#include "PWapi/lsprops.h"
#include "PWapi/edprops.h"

%safe
static PWresult is_ed_connectable
(
  PWobjid edobj,
  PWosnum os,
  void *is_connectable
);
%endsafe

from EMSplane import EMis_rect_plane;
from EMSsubbs import EMgetbsdef;

/*
  ABSTRACT
 
  Function that returns a Boolean flag indicating whether the given surface
  entity (composite, simple surface) has any non-degenerate edges that have 
  no common edges (that is, not a topological solid).
*/

PWboolean pwIsSfOpen 
(
  PWobjid sfobj,
  PWosnum os
)
{
  PWboolean is_open=FALSE;

  pwTraverseSfEds (sfobj, os, 
   (PWresult (*)()) is_ed_connectable, (void *) &is_open);
  
  return (is_open);
}


/*
  ABSTRACT
 
  Function that returns a Boolean flag indicating whether the given surface
  has it's natural normal (U X V), pointing towards the volume side or not.
  If the function returns TRUE, then one must reverse the normal in order 
  to have it point towards the volume.
*/

PWboolean pwIsSfNormalReversed
(
  PWobjid sfobj,
  PWosnum os
)
{
  long msg_loc;
  struct IGRbsp_surface sfdef;

  sfdef.pos_orient = TRUE;
  om$send (msg = message EMSsubbs.EMgetbsdef (&msg_loc, &sfdef),
   targetid = sfobj, targetos = os, senderid = PW_K_NullObjid);

  return (!sfdef.pos_orient);
}


/*
  ABSTRACT
 
  This function checks to see if the given surface is a rectangular plane
  as defined by the BSPMATH layer. This object's B-spline definition
  should consist of just 4 poles and these must define a rectangle.
*/

PWboolean pwIsRectPlane 
(
  PWobjid sfobj, 
  PWosnum sfos
)
{
  PWboolean is_rect=FALSE;
  long msg_loc;
  PWclassid sfclass=OM_K_NOTUSING_CLASSID;
  extern PWclassid OPP_EMSplane_class_id;

  om$get_classid (objid = sfobj, osnum = sfos, p_classid = &sfclass);
  if (om$is_ancestry_valid (subclassid = sfclass,
       superclassid = OPP_EMSplane_class_id) == OM_S_SUCCESS)
  {
    om$send (msg = message EMSplane.EMis_rect_plane (&msg_loc, &is_rect),
     targetid = sfobj, targetos = sfos, senderid = sfobj);
  }

  return (is_rect);
}


/*
  ABSTRACT

  The function returns a TRUE if the given surface object has a boundary
  that corresponds to the entire UV-domain. That is, the boundary is 
  "natural"
*/

PWboolean pwIsSfNatural
(
  PWobjid sfobj,
  PWosnum os
)
{
  PWboolean is_natural=TRUE;
  unsigned int count=0;
  OM_S_CHANSELECT chan_to_loopset;
  OM_S_OBJECT_LINKAGE lsobj;

  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  om$get_channel_objects (objid = sfobj, osnum = os, 
   p_chanselect = &chan_to_loopset, count = &count, size = 1,
   list = &lsobj);
  if (count == 1)
  {
    is_natural = pwIsLsNatural (lsobj.S_objid, os);
  }

  return (is_natural);
}

/*-------------------  Static functions ----------------------*/

static PWresult is_ed_connectable
(
  PWobjid edobj,
  PWosnum os,
  void *is_connectable
)
{
  unsigned int count;
  PWresult result=PW_K_Success;
  OM_S_CHANSELECT chan_to_common;

  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);
  count = 0;
  om$get_channel_count (objid = edobj, osnum = os, 
   p_chanselect = &chan_to_common, count = &count);
  if (!count && !pwIsEdDegen (edobj, os))
  {
    * (PWboolean *) is_connectable = TRUE;
    result = SetInfo (PW_K_Pathway, PW_K_Interrupt);
  }
  else
  {
    * (PWboolean *) is_connectable = FALSE;
  }

  return (result);
}

end implementation EMSsurface;

