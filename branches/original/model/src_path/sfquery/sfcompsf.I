/*
  OVERVIEW

    The following routines relates to the queries between the surface and
    the composite surface.

  HISTORY

    Sanjay   08/25/95   Creation
*/

class implementation EMSsurface;

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWerror.h"

#include "PWapi/sfcompsf.h"
#include "PWapi/sftype.h"

/*
  DESCRIPTION

    Returns the number of single surfaces owned by the given composite surface.

  NOTES

    In case of any failure, it returns ZERO. 
*/

int pwNumSfsOfCompSf 
(
  PWobjid  sfobj,
  PWosnum  os
)
{
  int i=0;
  PWresult result=PW_K_Success;
  OMuint count=0, newcount=0, totalcount=0;
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
        totalcount += pwNumSfsOfCompSf (objlist[i].S_objid, os);
      }
      else if (pwIsSimpleSf (objlist[i].S_objid, os))
      {
        totalcount ++;
      }
      else
      {
        result = SetError (PW_K_Pathway, PW_K_Internal);
        goto wrapup;
      } 
    }
  }
  else if (pwIsSimpleSf (sfobj, os))
  {
    totalcount = 1;
  }

wrapup :

  PW_Wrapup (result, "pwNumSfsOfCompSf");

  if (IsError (result))
    return 0;
  else
    return totalcount; 
}


/*
  DESCRIPTION

    Returns the number of single surfaces owned by a composite surfaces and
    the single surface ids. 

  NOTES

    In case of any failure, it returns ZERO. All the memory for the output
    must be allocated by the caller.
*/

int pwGetSfsOfCompSf 
(
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_sfs
)
{
  int i=0;
  PWresult result=PW_K_Success;
  OMuint count=0, newcount=0, totalcount=0;
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
        newcount = pwGetSfsOfCompSf (objlist[i].S_objid, os, 
                                     &p_sfs[totalcount]);
        totalcount += newcount;
      }
      else if (pwIsSimpleSf (objlist[i].S_objid, os))
      {
        p_sfs [totalcount] = objlist[i].S_objid;
        totalcount ++;
      }
      else
      {
        result = SetError (PW_K_Pathway, PW_K_Internal);
        goto wrapup;
      } 
    }
  }
  else if (pwIsSimpleSf (sfobj, os))
  {
    p_sfs [0] = sfobj;
    totalcount = 1;
  }
  else
  {
    result = SetError (PW_K_Pathway, PW_K_Internal);
    goto wrapup;
  }

wrapup :

  PW_Wrapup (result, "pwGetSfsOfCompSf");

  if (IsError (result))
    return 0;
  else
    return totalcount; 
}

end implementation EMSsurface;


