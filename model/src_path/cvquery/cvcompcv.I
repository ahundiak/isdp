/*
  OVERVIEW

    The following routines relates to the queries between the curve and
    the composite curve.

  HISTORY

    Sanjay   08/25/95   Creation
*/

class implementation GRcurve;

#include "emsdef.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWerror.h"

#include "PWapi/cvcompcv.h"
#include "PWapi/cvtype.h"

/*
  DESCRIPTION

    Returns the number of single curves owned by the given composite curve.

  NOTES

    In case of any failure, it returns ZERO. 
*/

int pwNumCvsOfCompCv 
(
  PWobjid  cvobj,
  PWosnum  os
)
{
  int i=0;
  PWresult result=PW_K_Success;
  OMuint count=0, newcount=0, totalcount=0;
  OM_S_CHANSELECT chan_to_comps;
  OM_p_OBJECT_LINKAGE objlist;

  if (pwIsCompCv (cvobj, os))
  {
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    count = 0;
    om$get_channel_count (objid = cvobj, osnum = os,
     p_chanselect = &chan_to_comps, count = &count);
    OnErrorState (!count, result, SetInfo (PW_K_Pathway, PW_K_NotFound),
     wrapup);

    objlist = (OM_p_OBJECT_LINKAGE) alloca (count *
               sizeof (OM_S_OBJECT_LINKAGE));
    newcount = 0;
    om$get_channel_objects (objid = cvobj, osnum = os,
     p_chanselect = &chan_to_comps, count = &newcount, size = count,
     list = objlist);
    OnErrorState (newcount != count, result, SetError (PW_K_Pathway,
     PW_K_Internal), wrapup);

    for (i=0; i<count; i++)
    {
      if (pwIsCompCv (objlist[i].S_objid, os))
      {
        totalcount += pwNumCvsOfCompCv (objlist[i].S_objid, os);
      }
      else if (pwIsSimpleCv (objlist[i].S_objid, os))
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
  else if (pwIsSimpleCv (cvobj, os))
  {
    totalcount = 1;
  }

wrapup :

  PW_Wrapup (result, "pwNumCvsOfCompCv");

  if (IsError (result))
    return 0;
  else
    return totalcount; 
}


/*
  DESCRIPTION

    Returns the number of single curves owned by a composite curves and
    the single curve ids. 

  NOTES

    In case of any failure, it returns ZERO. All the memory for the output
    must be allocated by the caller.
*/

int pwCvsOfCompCv 
(
  PWobjid  cvobj,
  PWosnum  os,
  PWobjid  *p_cvs
)
{
  int i=0;
  PWresult result=PW_K_Success;
  OMuint count=0, newcount=0, totalcount=0;
  OM_S_CHANSELECT chan_to_comps;
  OM_p_OBJECT_LINKAGE objlist;

  if (pwIsCompCv (cvobj, os))
  {
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    count = 0;
    om$get_channel_count (objid = cvobj, osnum = os,
     p_chanselect = &chan_to_comps, count = &count);
    OnErrorState (!count, result, SetInfo (PW_K_Pathway, PW_K_NotFound),
     wrapup);

    objlist = (OM_p_OBJECT_LINKAGE) alloca (count *
               sizeof (OM_S_OBJECT_LINKAGE));
    newcount = 0;
    om$get_channel_objects (objid = cvobj, osnum = os,
     p_chanselect = &chan_to_comps, count = &newcount, size = count,
     list = objlist);
    OnErrorState (newcount != count, result, SetError (PW_K_Pathway,
     PW_K_Internal), wrapup);

    for (i=0; i<count; i++)
    {
      if (pwIsCompCv (objlist[i].S_objid, os))
      {
        newcount = pwCvsOfCompCv (objlist[i].S_objid, os, 
                                     &p_cvs[totalcount]);
        totalcount += newcount;
      }
      else if (pwIsSimpleCv (objlist[i].S_objid, os))
      {
        p_cvs [totalcount] = objlist[i].S_objid;
        totalcount ++;
      }
      else
      {
        result = SetError (PW_K_Pathway, PW_K_Internal);
        goto wrapup;
      } 
    }
  }
  else if (pwIsSimpleCv (cvobj, os))
  {
    p_cvs [0] = cvobj;
    totalcount = 1;
  }
  else
  {
    result = SetError (PW_K_Pathway, PW_K_Internal);
    goto wrapup;
  }

wrapup :

  PW_Wrapup (result, "pwCvsOfCompCv");

  if (IsError (result))
    return 0;
  else
    return totalcount; 
}

end implementation GRcurve;
