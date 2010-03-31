/*
  OVERVIEW

  This file consists of functions related to basic top-down traversal of
  the components of a Surface Entity - composite surfaces, simple surfaces, 
  loops and edges. Surface Entities are seen as comprising of one or more 
  composite surfaces (0 or more in number), which in turn consist of simple
  surfaces, which in turn consist of one or more faces (loops), 
  which in turn consist of one or more edges. Seen top-down these structures 
  form a pure tree. 

  This file contains the different functions that are used to visit the
  various entities top-down, ie,  surfaces, loops and edges. Vertices
  are logical entities at the ends of edges. These are accessed
  in a special way and this is outside the scope of this file.

  The traversal is depth-first, "left-to-right". At this basic level, the user 
  is allowed the ability to provide a function that will be invoked at every 
  object (surface, loop and edge, depending on the traversal function used) 
  visited. The user-provided function is expected to have the following
  prototype (included in the comments of this file's prototype header file):
       PWresult user_func 
       (
         PWobjid visited_object,
         PWosnum os,
         void *user_args
       )
  If the function returns an error code, the traversal terminates. An exception
  to this rule is the "Interrupt" informational code. The traversal will also
  stop when this informational code is returned.

  The in-built traversal code will return an error code (hence also terminate
  the traversal) on finding any inconsistency in the data-structure of this
  tree. The return code in this latter case is - "Internal" error. 

  These traversal functions are used to implement some of the higher level
  APIs that are typically the ones more often used.


  HISTORY  

  Sanjay  :            :  Creation
  Siki    : Apr 10, 95 :  Re-write 
*/

class implementation EMSsurface;

#include <alloca.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/sfdntrav.h"
#include "PWapi/sftype.h"

%safe
struct S_apply_func
{
  PWresult (*func)();
  void *func_args;
};

static PWresult traverse_csf_csfs
(
  PWobjid,
  PWosnum,
  PWboolean,
  struct S_apply_func *
);

static PWresult traverse_sf_sfs
(
  PWobjid,
  PWosnum,
  struct S_apply_func *
);

static PWresult traverse_sf_lps
(
  PWobjid,
  PWosnum,
  struct S_apply_func *
);

static PWresult traverse_lp_lps
(
  PWobjid,
  PWosnum,
  struct S_apply_func *
);

static PWresult traverse_lp_eds 
(
  PWobjid,
  PWosnum,
  struct S_apply_func *
);
%endsafe
 
/*
  ABSTRACT

  This is an API function that is used to traverse all composite surfaces of
  a given composite surface entity and to apply a given function to each of
  these with user-supplied arguments. See file header for information about the
  user-supplied function and the generic behaviour of this traversal function.

  
  NOTES

  There is a special Boolean flag argument -- "depth_first". This flag needs
  to be set to TRUE if you require a depth-first visitation of the tree. If
  set to FALSE, the first node in the tree to get processed will be the input
  node and the nodes below it, thereafter.
*/

PWresult pwTraverseCSfCSfs
(
  PWobjid csfobj,
  PWosnum os,
  PWboolean depth_first,
  PWresult (*func)(),
  void *func_args
)
{
  PWresult result;

  if (pwIsCompSf (csfobj, os))
  {
    static struct S_apply_func apply_on_csf;

    apply_on_csf.func = func;
    apply_on_csf.func_args = func_args;
    
    result = traverse_csf_csfs (csfobj, os, depth_first, &apply_on_csf);
  }
  else
  {
    result = SetError (PW_K_Pathway, PW_K_InvalidArg);
  }

  PW_WrapupId (result, "pwTraverseCSfCSfs", csfobj);
  return (result);
}


/*
  ABSTRACT

  This is an API function that is used to traverse all the simple surfaces of
  a given surface entity (including a simple surface) and to apply a given 
  function to each of these with user-supplied arguments. See file header
  for information about the user-supplied function and the generic behaviour
  of this traversal function.
*/

PWresult pwTraverseSfSfs
(
  PWobjid sfobj,
  PWosnum os,
  PWresult (*func)(),
  void *func_args
)
{
  PWresult result;

  if (pwIsSurface (sfobj, os))
  {
    static struct S_apply_func apply_on_sf;

    apply_on_sf.func = func;
    apply_on_sf.func_args = func_args;
    
    result = traverse_sf_sfs (sfobj, os, &apply_on_sf);
  }
  else
  {
    result = SetError (PW_K_Pathway, PW_K_InvalidArg);
  }

  PW_WrapupId (result, "pwTraverseSfSfs", sfobj);
  return (result);
}


/*
  ABSTRACT

  This is an API function that is used to traverse all the loops of
  a given surface entity (including a simple surface) and to apply a given 
  function to each of these with user-supplied arguments. See file header
  for information about the user-supplied function and the generic behaviour
  of this traversal function.
*/

PWresult pwTraverseSfLps
(
  PWobjid sfobj,
  PWosnum os,
  PWresult (*func)(),
  void *func_args
)
{
  PWresult result;

  if (pwIsSurface (sfobj, os))
  {
    static struct S_apply_func apply_on_lp;

    apply_on_lp.func = func;
    apply_on_lp.func_args = func_args;

    result = pwTraverseSfSfs (sfobj, os, 
              (PWresult (*)()) traverse_sf_lps, (void *) &apply_on_lp);
  }
  else
  {
    result = SetError (PW_K_Pathway, PW_K_InvalidArg);
  }

  PW_WrapupId (result, "pwTraverseSfLps", sfobj);
  return (result);
}



/*
  ABSTRACT

  This is an API function that is used to traverse all the edges of
  a given surface entity (including a simple surface) and to apply a given 
  function to each of these with user-supplied arguments. See file header
  for information about the user-supplied function and the generic behaviour
  of this traversal function.
*/

PWresult pwTraverseSfEds
(
  PWobjid sfobj,
  PWosnum os,
  PWresult (*func)(),
  void *func_args
)
{
  PWresult result;

  if (pwIsSurface (sfobj, os))
  {
    struct S_apply_func apply_on_ed;

    apply_on_ed.func = func;
    apply_on_ed.func_args = func_args;

    result = pwTraverseSfLps (sfobj, os, 
              (PWresult (*)()) traverse_lp_eds, (void *) &apply_on_ed);
  }
  else
  {
    result = SetError (PW_K_Pathway, PW_K_InvalidArg);
  }

  PW_WrapupId (result, "pwTraverseSfEds", sfobj);
  return (result);
}



/*------------------ STATIC FUNCTION DEFINITIONS ------------------*/

/*
  ABSTRACT

  This is a locally used function that traverses the composite surfaces that
  in turn comprise the given composite surface entity and applies the given
  function to each such composite surface visited (along with the supplied
  arguments). 
*/

static PWresult traverse_csf_csfs
(
  PWobjid csfobj,
  PWosnum os,
  PWboolean depth_first,
  struct S_apply_func *apply_func
)
{
  int i;
  PWresult result=PW_K_Success;
  OMuint compcount, newcount;
  OM_S_CHANSELECT chan_to_comps;
  OM_p_OBJECT_LINKAGE objlist;

  if (pwIsCompSf (csfobj, os))
  {
    /*
     * Get the components of this owner.
     */

    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    compcount = 0;
    om$get_channel_count (objid = csfobj, osnum = os, 
     p_chanselect = &chan_to_comps, count = &compcount);

    if (compcount)
    {
      objlist = (OM_p_OBJECT_LINKAGE) alloca (compcount * 
               sizeof (OM_S_OBJECT_LINKAGE));

      newcount = 0;
      om$get_channel_objects (objid = csfobj, osnum = os, 
       p_chanselect = &chan_to_comps, count = &newcount, size = compcount, 
       list = objlist);
      OnErrorState (newcount != compcount, result, SetError (PW_K_Pathway,
       PW_K_Internal), wrapup);
    }

    /*
     * Apply the function before recursing down, if the request is not-depth-
     * first.
     */

    if (!depth_first)
    {
      if (apply_func && apply_func->func)
      {
        result = (*apply_func->func) (csfobj, os, apply_func->func_args);
        OnErrorCode (result, wrapup);
        if (GetCode (result) == PW_K_Interrupt)
          goto wrapup;
      }
    }

    /*
     * Go through each component and recurse down if the component is 
     * another owner.
     */

    for (i=0; i<compcount; i++)
    {
      if (pwIsCompSf (objlist[i].S_objid, os))
      {
        result = traverse_csf_csfs (objlist[i].S_objid, os, depth_first,
                  apply_func);
        OnErrorCode (result, wrapup);
        if (GetCode (result) == PW_K_Interrupt)
          goto wrapup;
      }
    }

    /*
     * Apply the function after recursing down, if the request was depth-
     * first.
     */

    if (depth_first)
    {
      if (apply_func && apply_func->func)
      {
        result = (*apply_func->func) (csfobj, os, apply_func->func_args);
        OnErrorCode (result, wrapup);
        if (GetCode (result) == PW_K_Interrupt)
          goto wrapup;
      }
    }
  }
  else
  {
    /*
     * The input object is not a composite surface.
     * This is an invalid argument.
     */

    result = SetError (PW_K_Pathway, PW_K_InvalidArg);
    goto wrapup;
  }

wrapup:
  PW_WrapupId (result, "traverse_csf_csfs", csfobj);
  return (result);
}


/*
  ABSTRACT

  This is a locally used function that traverses the surfaces of a composite
  surface and applies the given function to each of the surfaces visited
  (along with the supplied arguments). The given surface can be a simple 
  surface too. In this latter case, the given function is applied to the
  simple surface.
*/

static PWresult traverse_sf_sfs
(
  PWobjid sfobj,
  PWosnum os,
  struct S_apply_func *apply_func
)
{
  int i;
  PWresult result=PW_K_Success;
  OMuint count, newcount;
  OM_S_CHANSELECT chan_to_comps;
  OM_p_OBJECT_LINKAGE objlist;

  if (pwIsCompSf (sfobj, os))
  {
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    count = 0;
    om$get_channel_count (objid = sfobj, osnum = os, 
     p_chanselect = &chan_to_comps, count = &count);
    OnErrorState (!count, result, SetInfo (PW_K_Pathway, PW_K_NotFound),
     wrapup);

    objlist = (OM_p_OBJECT_LINKAGE) alloca (count * 
               sizeof (OM_S_OBJECT_LINKAGE));
    newcount = 0;
    om$get_channel_objects (objid = sfobj, osnum = os, 
     p_chanselect = &chan_to_comps, count = &newcount, size = count, 
     list = objlist);
    OnErrorState (newcount != count, result, SetError (PW_K_Pathway,
     PW_K_Internal), wrapup);

    for (i=0; i<count; i++)
    {
      if (pwIsCompSf (objlist[i].S_objid, os))
      {
        result = traverse_sf_sfs (objlist[i].S_objid, os, apply_func);
        OnErrorCode (result, wrapup);
        if (GetCode (result) == PW_K_Interrupt)
          goto wrapup;
      }
      else if (pwIsSimpleSf (objlist[i].S_objid, os))
      {
        if (apply_func && apply_func->func)
        {
          result = (*apply_func->func) (objlist[i].S_objid, os, 
                    apply_func->func_args);
          OnErrorCode (result, wrapup);
          if (GetCode (result) == PW_K_Interrupt)
            goto wrapup;
        }
      }
      else
      {
        /*
         * This composite surface has components that are not surfaces.
         * This is a data-structure error.
         */

        result = SetError (PW_K_Pathway, PW_K_Internal);
        goto wrapup;
      }
    }
  }
  else if (pwIsSimpleSf (sfobj, os))
  {
    if (apply_func && apply_func->func)
    {
      result = (*apply_func->func) (sfobj, os, apply_func->func_args);
      OnErrorCode (result, wrapup);
      if (GetCode (result) == PW_K_Interrupt)
        goto wrapup;
    }
  }
  else
  {
    /*
     * The input object is neither a composite surface nor a simple surface.
     * This is an invalid argument.
     */

    result = SetError (PW_K_Pathway, PW_K_InvalidArg);
    goto wrapup;
  }

wrapup:
  PW_WrapupId (result, "traverse_sf_sfs", sfobj);
  return (result);
}


/*
  ABSTRACT

  This is an internal function that traverses all the loops of a given simple
  surface, applying the given function (with the supplied args) on each
  of the loops encountered.
*/

static PWresult traverse_sf_lps
(
  PWobjid sfobj,
  PWosnum os,
  struct S_apply_func *apply_func
)
{
  int i;
  unsigned int count, newcount;
  PWresult result=PW_K_Success;
  OM_S_CHANSELECT chan_to_loopset, chan_to_loops;
  OM_S_OBJECT_LINKAGE loopset_objlink, *objlist;

  OnErrorState (!pwIsSimpleSf (sfobj, os), result,
   SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);

  count = 0;
  om$get_channel_count (objid = sfobj, osnum = os, 
   p_chanselect = &chan_to_loopset, count = &count);
  if (count == 1)
  {
    newcount = 0;
    om$get_channel_objects (objid = sfobj, osnum = os, 
     p_chanselect = &chan_to_loopset, count = &newcount, size = 1, 
     list = &loopset_objlink);
    OnErrorState (newcount != 1, result, SetError (PW_K_Pathway,
     PW_K_Internal), wrapup);

    count = 0;
    om$get_channel_count (objid = loopset_objlink.S_objid, osnum = os, 
     p_chanselect = &chan_to_loops, count = &count);
    OnErrorState (!count, result, SetError (PW_K_Pathway, PW_K_Internal),
     wrapup);

    objlist = (OM_p_OBJECT_LINKAGE) alloca (count * 
                sizeof (OM_S_OBJECT_LINKAGE));
    newcount = 0;
    om$get_channel_objects (objid = loopset_objlink.S_objid, osnum = os, 
     p_chanselect = &chan_to_loops, count = &newcount, size = count, 
     list = objlist);
    OnErrorState (newcount != count, result, SetError (PW_K_Pathway,
     PW_K_Internal), wrapup);

    for (i=0; i<count; i++)
    {
      result = traverse_lp_lps (objlist[i].S_objid, os, apply_func);
      OnErrorCode (result, wrapup);
      if (GetCode (result) == PW_K_Interrupt)
        goto wrapup;
    }
  }
  else
  {
    /*
     * This surface has no loopset. This is not an invalid condition.
     * An information code is returned.
     */

    result = SetInfo (PW_K_Pathway, PW_K_NotFound);
    goto wrapup;
  }

wrapup:
  PW_WrapupId (result, "traverse_sf_lps", sfobj);
  return (result);
}



/*
  ABSTRACT

  Internally used function that recursively traverses all the loops under this 
  loop, also invoking the given function (with the given arguments) on this
  loop.
*/

static PWresult traverse_lp_lps
(
  PWobjid lpobj,
  PWosnum os,
  struct S_apply_func *apply_func
)
{
  int i;
  unsigned int count, newcount;
  PWresult result=PW_K_Success;
  OM_S_CHANSELECT chan_to_inners;
  OM_p_OBJECT_LINKAGE objlist;

  EMmake_chanselect (EMSloop_to_inner, &chan_to_inners);

  count = 0;
  om$get_channel_count (objid = lpobj, osnum = os, 
   p_chanselect = &chan_to_inners, count = &count);
  if (count)
  {
    objlist = (OM_p_OBJECT_LINKAGE) alloca (count * 
               sizeof (OM_S_OBJECT_LINKAGE));
    newcount = 0;
    om$get_channel_objects (objid = lpobj, osnum = os, 
     p_chanselect = &chan_to_inners, count = &newcount, size = count, 
     list = objlist);
    OnErrorState (newcount != count, result, 
     SetError (PW_K_Pathway, PW_K_Internal), wrapup);

    for (i=0; i<count; i++)
    {
      result = traverse_lp_lps (objlist[i].S_objid, os, apply_func);
      OnErrorCode (result, wrapup);
      if (GetCode (result) == PW_K_Interrupt)
        goto wrapup;
    }
  }

  if (apply_func && apply_func->func)
  {
    result = (*apply_func->func) (lpobj, os, apply_func->func_args);
    OnErrorCode (result, wrapup);
    if (GetCode (result) == PW_K_Interrupt)
      goto wrapup;
  }

wrapup:
  PW_WrapupId (result, "traverse_lp_lps", lpobj);
  return (result);
}

/*
  ABSTRACT

  This is a locally used function that traverses all the edges of a given
  loop, applying the input function with the provided 'args' on the edges so
  traversed. If no edges are found, this function returns an "Internal" error 
  code as it is illegal for any loop to exist without any edge.
*/

static PWresult traverse_lp_eds 
(
  PWobjid lpobj,
  PWosnum os,
  struct S_apply_func *apply_func
)
{
  int i;
  unsigned int count, newcount;
  PWresult result=PW_K_Success;
  OM_S_CHANSELECT chan_to_edges;
  OM_p_OBJECT_LINKAGE objlist;

  EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);

  count = 0;
  om$get_channel_count (objid = lpobj, osnum = os, 
   p_chanselect = &chan_to_edges, count = &count);
  OnErrorState (!count, result, SetError (PW_K_Pathway, PW_K_Internal),
   wrapup);

  objlist = (OM_p_OBJECT_LINKAGE) alloca (count * 
             sizeof (OM_S_OBJECT_LINKAGE));
  newcount = 0;
  om$get_channel_objects (objid = lpobj, osnum = os, 
   p_chanselect = &chan_to_edges, count = &newcount, size = count, 
   list = objlist);
  OnErrorState (newcount != count, result, 
   SetError (PW_K_Pathway, PW_K_Internal), wrapup);

  for (i=0; i<count; i++)
  {
    if (apply_func && apply_func->func)
    {
       result = (*apply_func->func) (objlist[i].S_objid, os,
                 apply_func->func_args);
       OnErrorCode (result, wrapup);
       if (GetCode (result) == PW_K_Interrupt)
         goto wrapup;
    }
  }

wrapup:
  PW_WrapupId (result, "traverse_lp_eds", lpobj);
  return (result);
}

end implementation EMSsurface;
