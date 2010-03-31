/*
  OVERVIEW

  This file contains APIs to query the owner-component tree.


  HISTORY

  SS  :  08/29/95   :   Creation
*/

class implementation GRcmpowner;

#include "emsdef.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/grprops.h"
#include "PWapi/grownquery.h"

%safe
static PWresult get_max_tree_depth 
(
  PWobjid,
  PWosnum,
  void *
);

static PWresult get_comp_tree_depth 
(
  PWobjid,
  PWosnum,
  int *
);
%endsafe

/*
  ABSTRACT

  The following is a set of API functions that answer queries about the
  immediate components of the given owner object. Queries like - number
  of components, component at index, etc. In case where an object id is
  expected as the return value, a PW_K_NullObjid is returned if the object
  couldn't be found (index out of range, bad input, etc). In case where
  an index is expected as a return, a -1 will be the return value on
  encountering an error condition.

  
  NOTES

  When an array is expected as an output argument, the function assumes
  that the memory is sufficient to hold the output.
*/

PWobjid pwNumCompsOfOwner
(
  PWobjid ownobj,
  PWosnum os
)
{
  unsigned int count=0;
  OM_S_CHANSELECT chan_to_comps;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$get_channel_count (objid = ownobj, osnum = os, 
   p_chanselect = &chan_to_comps, count = &count);

  return (count);
}

int pwCompsOfOwner
(
  PWobjid ownobj,
  PWosnum os,
  PWobjid *p_comps
)
{
  unsigned int i, count=0;
  OM_S_CHANSELECT chan_to_comps;
  OM_p_OBJECT_LINKAGE p_objlinks;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$get_channel_count (objid = ownobj, osnum = os, 
   p_chanselect = &chan_to_comps, count = &count);

  p_objlinks = (OM_p_OBJECT_LINKAGE) alloca (count * 
                sizeof (OM_S_OBJECT_LINKAGE));
  om$get_channel_objects (objid = ownobj, osnum = os, 
   p_chanselect = &chan_to_comps, size = count, list = p_objlinks, 
   count = &count);

  for (i=0; i<count; i++)
    p_comps[i] = p_objlinks[i].S_objid;

  return (count);
}

PWobjid pwCompAtInxOfOwner
(
  PWobjid ownobj,
  PWosnum os,
  int index
)
{
  PWobjid compobj=PW_K_NullObjid;
  PWosnum dumos;
  OM_S_CHANSELECT chan_to_comps;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$get_objid_at_index (objid = ownobj, osnum = os, index = index,
   p_chanselect = &chan_to_comps, objidaddr = &compobj, osnumaddr = &dumos);

  return (compobj);
}

int pwCompInxOnOwner
(
  PWobjid compobj,
  PWosnum os
)
{
  PWresult result=PW_K_Success;
  unsigned int index;
  int ret_inx=-1;
  PWobjid ownobj=PW_K_NullObjid;
  OM_S_CHANSELECT chan_to_comps;
  
  ownobj = pwOwnerOfComp (compobj, os);
  if (ownobj != PW_K_NullObjid)
  {
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    result = om$get_index (osnum_c = os, objid_c = ownobj,
              p_chanselect = &chan_to_comps, objid = compobj, osnum2 = os,
              indexaddr = &index); 
    if (!IsError (result))
      ret_inx = index;
  }
  
  return (ret_inx);
}

PWobjid pwOwnerOfComp
(
  PWobjid compobj,
  PWosnum os
)
{
  unsigned int count=0;
  OM_S_CHANSELECT to_owners;
  OM_S_OBJECT_LINKAGE owner;

  EMmake_chanselect (GRconnector_to_owners, &to_owners);
  owner.S_objid = PW_K_NullObjid;
  om$get_channel_objects (objid = compobj, osnum = os,
   p_chanselect = &to_owners, list = &owner, size = 1, count = &count);
 
  return (owner.S_objid);
}

/*
  ABSTRACT

  This is an API function that gets the maximum depth of the owner-component
  tree from the given object. That is, this function will return the
  maximum number of component nodes it can hit on a direct downward traversal.
  If this tree consists of just one object then it's depth is 0.
*/

int pwMaxTreeDepth 
(
  PWobjid ownobj,
  PWosnum os
)
{
  PWresult result=PW_K_Success;
  int depth=0;

  result = pwTraverseCSfCSfs (ownobj, os, FALSE, 
           (PWresult (*)()) get_max_tree_depth, 
           (void *) &depth);
   if (IsError (result))
     return (-1);
   else
     return (depth);
}

/*
  ABSTRACT

  This is an API function that gets the depth of a given entity in the
  composite tree of rigidly owned entities. Depth is defined as the number of
  entities that can be found on the way to the top of such a tree from the
  given entity. So the topmost entity has a depth of 0. A standalone simple 
  entity has a depth of 0. If an error occurred, the value returned is -1.
*/

int pwCompTreeDepth
(
  PWobjid compobj,
  PWosnum os
)
{
   PWresult result=PW_K_Success;
   int depth=0;

   result = get_comp_tree_depth (compobj, os, &depth);
   if (IsError (result))
     return (-1);
   else
     return (depth);
}


/*
  ABSTRACT

  The following function returns the topmost owner of this owner-component
  tree, given a component of the tree. This component need not be a leaf node.
  If the input component does not have any owner, then this id itself is
  returned. The input object is always assumed to be subclassed from
  GRvg.
*/

PWobjid pwTopOwner
(
  PWobjid grcomp,
  PWosnum os
)
{
  PWobjid ownobj;

  ownobj = pwOwnerOfComp (grcomp, os);
  if (ownobj == PW_K_NullObjid)
    ownobj = grcomp;
  else
    ownobj = pwTopOwner (ownobj, os);

  return (ownobj);
}


  
/*----------------------- STATIC FUNCTIONS --------------------------------*/

static PWresult get_max_tree_depth 
(
  PWobjid ownobj,
  PWosnum os,
  void *args
)
{
  if (pwCompTreeDepth (ownobj, os) > *((int *) args))
    (* ((int *) args))++;
  return (PW_K_Success);
}

static PWresult get_comp_tree_depth 
(
  PWobjid compobj,
  PWosnum os,
  int *depth
)
{
  unsigned int tnum=0;
  PWresult result=PW_K_Success;
  OM_S_CHANSELECT to_owners;
  OM_S_OBJECT_LINKAGE owner;

  if (pwIsRigidComp (compobj, os))
  {
    EMmake_chanselect (GRconnector_to_owners, &to_owners);

    om$get_channel_objects (objid = compobj, osnum = os,
     p_chanselect = &to_owners, list = &owner, size = 1, count = &tnum);
    OnErrorState (tnum != 1, result, SetError (PW_K_Pathway, PW_K_Internal),
     wrapup);

    (*depth)++;
    return (get_comp_tree_depth (owner.S_objid, os, depth));
  }

wrapup:
  return (result);
}

end implementation GRcmpowner;
