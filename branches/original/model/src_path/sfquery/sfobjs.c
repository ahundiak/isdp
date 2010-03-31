/*
  OVERVIEW

  This file contains the APIs to access the various surface objects within
  a given OS. Example: All the top-owner surfaces (solids, inclusive) within
  a file.


  HISTORY

  SS  :  06/16/95   :  Creation
*/

#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/sfobjs.h"
#include "PWapi/growners.h"

extern PWclassid OPP_EMSsolid_class_id, OPP_EMSsubbs_class_id;
extern PWclassid OPP_EMScompsurf_class_id;

PWresult pwGetSolidsOfOS
(
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_solids,
  PWobjid **solids
)
{
  if (components_in_rtree)
    return (pwGetRtreeTopOwners (1, &OPP_EMSsolid_class_id, 0, NULL,
             OPP_EMSsubbs_class_id, os, num_solids, solids));
  else
    return (pwGetFileTopOwners (1, &OPP_EMSsolid_class_id, 0, NULL, os,
             num_solids, solids));
}

PWresult pwGetCompSfsOfOS
(
  PWosnum  os,
  PWboolean components_in_rtree,
  int *num_compsfs,
  PWobjid **compsfs
)
{
  if (components_in_rtree)
    return (pwGetRtreeTopOwners (1, &OPP_EMScompsurf_class_id, 
                                 1, &OPP_EMSsolid_class_id,
                                 OPP_EMSsubbs_class_id, os, 
                                 num_compsfs, compsfs));
  else
    return (pwGetFileTopOwners (1, &OPP_EMScompsurf_class_id, 
                                1, &OPP_EMSsolid_class_id, os,
                                num_compsfs, compsfs));
}

PWresult pwGetSingleSfsOfOS
(
  PWosnum  os,
  PWboolean sfs_in_rtree,
  int *num_surfs,
  PWobjid **surfs
)
{
  if (sfs_in_rtree)
    return (pwGetRtreeTopOwners (1, &OPP_EMSsubbs_class_id, 0, NULL, 
             OPP_EMSsubbs_class_id, os, num_surfs, surfs));
  else
    return (pwGetFileTopOwners (1, &OPP_EMSsubbs_class_id, 0, NULL, os,
             num_surfs, surfs));
}

