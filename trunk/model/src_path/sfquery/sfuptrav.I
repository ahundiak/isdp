/*
  OVERVIEW

  This file contains the functions that obtain the interesting or useful
  nodes in the tree comprising of the components of a Surface Entity,
  as we go bottom-up, ie, edges, loops, simple surface and the topmost
  composite surface (if this tree is of a composite surface). Vertices
  are logical entities at the ends of edges. These are handled a bit
  specially and that handling is outside the scope of this file.

  Surface Entities are seen as comprising of one or more 
  simple surfaces, which in turn consist of one or more faces (loops), 
  which in turn consist of one or more edges. Seen bottom-up we face the
  additional complexity of picking the active element that 'owns' the
  entity in question. For example: the data-structure provides the ability 
  for more than one loop to own an edge but only one "active" loop owns an
  edge at a time. Looking up from the edge, the edge needs to view only 
  the active loop.

  The bottom-up traversal thus has a unique path right up to the top of this
  surface component tree. For this reason, there is no need to provide the
  ability to "apply" functions on visitation of a target node in the tree
  during the traversal. The caller can get the objid of the target node
  and invoke the function him(her)self.

  HISTORY  

  Siki   : May 4, 95 :  Creation. Brought in code from elsewhere too.
*/

class implementation EMSsurface;

#include <alloca.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/sfuptrav.h"
#include "PWapi/grprops.h"
#include "PWapi/lpprops.h"

extern PWclassid OPP_EMSloop_class_id, OPP_EMSloopset_class_id;
extern PWclassid OPP_EMSsurface_class_id;

/*
  ABSTRACT

  This is an API function that gets the topmost-owner surface-entity (composite
  surface) of which the given surface forms a component. If the given surface
  does not have any surface-entity as an "owner" it returns PW_K_NullObjid.
*/

PWobjid pwGetTopOwnOfSf
(
  PWobjid sfobj,
  PWosnum os
)
{
  unsigned int tnum=0;
  PWresult result=PW_K_Success;
  PWclassid own_class=OM_K_NOTUSING_CLASSID;
  PWobjid ownobj=PW_K_NullObjid;
  OM_S_CHANSELECT to_owners;
  OM_S_OBJECT_LINKAGE owner;

  if (pwIsRigidComp (sfobj, os))
  {
    EMmake_chanselect (GRconnector_to_owners, &to_owners);

    om$get_channel_objects (objid = sfobj, osnum = os,
     p_chanselect = &to_owners, list = &owner, size = 1, count = &tnum);
    OnErrorState (tnum != 1, result, SetError (PW_K_Pathway, PW_K_Internal),
     wrapup);

    om$get_classid (objid = owner.S_objid, osnum = os,
     p_classid = &own_class);

    if (om$is_ancestry_valid (subclassid = own_class,
         superclassid = OPP_EMSsurface_class_id) == OM_S_SUCCESS)
    {
      ownobj = pwGetTopOwnOfSf (owner.S_objid, os);
    }
  }
  else
  {
    om$get_classid (objid = sfobj, osnum = os,
     p_classid = &own_class);

    if (om$is_ancestry_valid (subclassid = own_class,
         superclassid = OPP_EMSsurface_class_id) == OM_S_SUCCESS)
      ownobj = sfobj;
  }

wrapup:
  PW_WrapupId (result, "pwGetTopOwnOfSf", sfobj);
  return (ownobj);
}

/*
  ABSTRACT

  This is an API function that gets the simple surface of which the given
  edge forms a component. If none can be found (due to error or otherwise,
  PW_K_NullObjid is returned).
*/

PWobjid pwGetSfOfEd
(
  PWobjid edobj,
  PWosnum os
)
{
  PWresult result=PW_K_Success;
  PWobjid lpobj=PW_K_NullObjid;

  lpobj = pwGetLpOfEd (edobj, os);
  OnErrorState (lpobj == PW_K_NullObjid, result,
   SetError (PW_K_Pathway, PW_K_NotFound), wrapup);

  lpobj = pwGetSfOfLp (lpobj, os);
  OnErrorState (lpobj == PW_K_NullObjid, result,
   SetError (PW_K_Pathway, PW_K_NotFound), wrapup);

wrapup:
  PW_WrapupId (result, "pwGetSfOfEd", edobj);
  return (lpobj);
}

/*
  ABSTRACT

  This is an API function that gets the active loop of which the given
  edge forms a component. If none can be found (due to error or otherwise,
  PW_K_NullObjid is returned).
*/

PWobjid pwGetLpOfEd
(
  PWobjid edobj,
  PWosnum os
)
{
  unsigned int num_owners=0, tnum=0;
  int i;
  PWresult result=PW_K_Success;
  PWclassid own_class;
  PWobjid lpobj=PW_K_NullObjid;
  OM_S_CHANSELECT to_owners;
  OM_S_OBJECT_LINKAGE *p_owners=NULL;

  lpobj = PW_K_NullObjid;

  EMmake_chanselect (EMSedge_to_owner, &to_owners);

  om$get_channel_count (objid = edobj, osnum = os,
   p_chanselect = &to_owners, count = &num_owners);
  OnErrorState (!num_owners, result,
   SetError (PW_K_Pathway, PW_K_Internal), wrapup);

  p_owners = (OM_S_OBJECT_LINKAGE *) alloca (num_owners * 
              sizeof (OM_S_OBJECT_LINKAGE));
  om$get_channel_objects (objid = edobj, osnum = os,
   p_chanselect = &to_owners, list = p_owners, size = num_owners,
   count = &tnum);
  OnErrorState (tnum != num_owners, result,
   SetError (PW_K_Pathway, PW_K_Internal), wrapup);

  /*
   * Go through each owner and on finding a loop check if it is the active
   * P-loop. If so return this loop, else continue the look-up.
   */

  for (i=0; i<num_owners; i++)
  {
    own_class = OM_K_NOTUSING_CLASSID;
    om$get_classid (objid = p_owners[i].S_objid, osnum = os,
     p_classid = &own_class);

    if (om$is_ancestry_valid (subclassid = own_class,
         superclassid = OPP_EMSloop_class_id) == OM_S_SUCCESS)
    {
      if (pwIsLpActive (p_owners[i].S_objid, os))
      {
        lpobj = p_owners[i].S_objid; 
        break;
      }
    }
  }

wrapup:
  PW_WrapupId (result, "pwGetLpOfEd", edobj);
  return (lpobj);
}

/*
  ABSTRACT

  This is an API function that gets the simple surface of which the given
  loop forms a component. If none can be found (due to error or otherwise,
  PW_K_NullObjid is returned).
*/

PWobjid pwGetSfOfLp
(
  PWobjid lpobj,
  PWosnum os
)
{
  unsigned int is_owner, is_loopset;
  PWresult result=PW_K_Success;
  PWobjid sfobj, tmp_lpobj;
  PWclassid own_class;
  OM_S_CHANSELECT chan_to_outter, chan_to_surf;
  OM_S_OBJECT_LINKAGE owner;

  sfobj = PW_K_NullObjid;

  EMmake_chanselect (EMSloop_to_outter, &chan_to_outter);

  is_loopset = FALSE;
  tmp_lpobj = lpobj;
  while (!is_loopset)
  {
    is_owner = 0;
    om$get_channel_objects (objid = tmp_lpobj, osnum = os,
     p_chanselect = &chan_to_outter, list = &owner, size = 1, 
     count = &is_owner);
    OnErrorState (!is_owner, result, SetError (PW_K_Pathway, PW_K_Internal),
     wrapup);

    own_class = OM_K_NOTUSING_CLASSID;
    om$get_classid (objid = owner.S_objid, osnum = os, 
     p_classid = &own_class);

    if (om$is_ancestry_valid (subclassid = own_class,
         superclassid = OPP_EMSloopset_class_id) == OM_S_SUCCESS)
    {
      is_loopset = TRUE;
    }
    else
      tmp_lpobj = owner.S_objid;
  }

  /*
   * If a loopset is not found, this was probably an inactive loop. It is
   * illegal to invoke this function on such a loop.
   */

  OnErrorState (!is_loopset, result, SetError (PW_K_Pathway, PW_K_InvalidArg),
   wrapup);


  EMmake_chanselect (EMSloopset_to_surface, &chan_to_surf);

  is_owner = 0;
  om$get_channel_objects (objid = owner.S_objid, osnum = os,
   p_chanselect = &chan_to_surf, list = &owner, size = 1, 
   count = &is_owner);
  OnErrorState (!is_owner, result, SetError (PW_K_Pathway, PW_K_Internal),
   wrapup);

  sfobj = owner.S_objid;

wrapup:
  PW_WrapupId (result, "pwGetSfOfLp", lpobj);
  return (sfobj);
}

end implementation EMSsurface;
