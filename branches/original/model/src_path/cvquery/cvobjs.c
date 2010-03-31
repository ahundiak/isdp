/*
  OVERVIEW

  This file contains the APIs to access the various curve objects within
  a given OS. Example: All the profiles within a file.


  HISTORY

  SS  :  11/26/96   :  Creation
*/

#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/cvobjs.h"
#include "PWapi/growners.h"

extern PWclassid OPP_SKmgr_class_id, OPP_GRbspline_class_id;
extern PWclassid OPP_GRcompcurve_class_id;

PWresult pwGetProfilesOfOS
(
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_profiles,
  PWobjid **profiles
)
{
  if (components_in_rtree)
    return (pwGetRtreeTopOwners (1, &OPP_SKmgr_class_id, 0, NULL,
             OPP_GRbspline_class_id, os, num_profiles, profiles));
  else
    return (pwGetFileTopOwners (1, &OPP_SKmgr_class_id, 0, NULL, os,
             num_profiles, profiles));
}

PWresult pwGetCompCvsOfOS
(
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_compcvs,
  PWobjid **compcvs
)
{
  if (components_in_rtree)
    return (pwGetRtreeTopOwners (1, &OPP_GRcompcurve_class_id, 
                                 0, NULL,
                                 OPP_GRbspline_class_id, os, 
                                 num_compcvs, compcvs));
  else
    return (pwGetFileTopOwners (1, &OPP_GRcompcurve_class_id, 
                                0, NULL, os,
                                num_compcvs, compcvs));
}

PWresult pwGetSingleCvsOfOS
(
  PWosnum  os,
  PWboolean cvs_in_rtree,
  int *num_cvs,
  PWobjid **cvs
)
{
  if (cvs_in_rtree)
    return (pwGetRtreeTopOwners (1, &OPP_GRbspline_class_id, 0, NULL, 
             OPP_GRbspline_class_id, os, num_cvs, cvs));
  else
    return (pwGetFileTopOwners (1, &OPP_GRbspline_class_id, 0, NULL, os,
             num_cvs, cvs));
}

