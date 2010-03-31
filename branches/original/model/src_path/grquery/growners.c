/*
  OVERVIEW

  This file contains APIs to access the top-owners in an OS


  HISTORY

  SS  :  06/16/95   :   Creation
*/
#include <malloc.h>
#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/growners.h"
#include "PWapi/grownquery.h"
#include "PWapi/grprops.h"
#include "PWapi/objaccess.h"
#include "PWapi/memfunc.h"
#include "PWapi/sfuptrav.h"


#define MALLOC_CHUNKS 10

/*
  ABSTRACT

  This API gets all the top-owners in a given file (specified by OS-number)
  that satisfy a given class eligibility criteria. Every object in the
  file, satisfying this criteria is checked to see if it is not a component
  of a "rigid" owner. If it is not, then this object is added to the output.

  If the 'top_objs' argument is passed in as NULL, no attempt is made to
  output the set of objects. Otherwise, this function mallocs memory for
  the output. 'num_top_objs' is always output
*/

PWresult pwGetFileTopOwners 
(
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWosnum os,
  int *num_top_objs,
  PWobjid **top_objs
)
{
  int i, num_file_objs=0;
  PWobjid *file_objs=NULL;
  PWresult result=PW_K_Success;

  *num_top_objs = 0;
  if (top_objs)
    *top_objs = NULL;

  /*
   * Obtain all eligible objects in the datafile.
   */

  result = omGetObjsOfClass (num_eligclass, eligclass, 
            num_ineligclass, ineligclass, os, &num_file_objs, &file_objs);
  OnErrorCode (result, wrapup);

  /*
   * Look to see if the objects located are indeed top-owners. If so,
   * then these are added to the output.
   */

  for (i=0; i<num_file_objs; i++)
  {
    if (pwIsRigidComp (file_objs[i], os))
      continue;

    if (top_objs)
    {
      result = pwMemInChunks ((*num_top_objs)+1, (void **) top_objs,
                sizeof (PWobjid), MALLOC_CHUNKS);
      OnErrorCode (result, wrapup);
 
      (*top_objs)[*num_top_objs] = file_objs[i];
    }
    (*num_top_objs)++;
  }

wrapup:
  if (file_objs)
    free (file_objs);

  PW_Wrapup (result, "pwGetFileTopOwners");
  return (result);
}


/*
  ABSTRACT

  This API gets all the top-owners in a given file (specified by OS-number)
  that satisfy a given class eligibility criteria. Every object in the
  R-tree that belongs to 'rtree_class' is looked up for it's top-owner and
  all such unique top-owners are added to the output. Note that the object
  in the R-tree can itself be a top-owner if it is not a rigid component.

  If the 'top_objs' argument is passed in as NULL, no attempt is made to
  output the set of objects. Otherwise, this function mallocs memory for
  the output. 'num_top_objs' is always output
*/

PWresult pwGetRtreeTopOwners 
(
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWclassid rtree_class,
  PWosnum os,
  int *num_objids,
  PWobjid **objids
)
{
  PWboolean unique;
  int i, j, num_rtree_objs=0, num_top_objs=0;
  PWobjid top_objid, *rtree_objs=NULL, *top_objs=NULL;
  PWresult result=PW_K_Success;

  /*
   * Obtain all objects in the R-tree belonging to the specified R-tree
   * class.
   */

  result = omGetRtreeObjsOfClass (1, &rtree_class, 0, NULL, os,
            &num_rtree_objs, &rtree_objs);
  OnErrorCode (result, wrapup);

  /*
   * Find each one's top-owner and make a list of all the unique top-owners
   * thus found.
   */

  for (i=0; i<num_rtree_objs; i++)
  {
    top_objid = pwTopOwner (rtree_objs[i], os);
    if (top_objid == PW_K_NullObjid)
      continue;

    for (j=0, unique=TRUE; j<num_top_objs && unique; j++)
      if (top_objid == top_objs[j])
        unique = FALSE;

    if (unique)
    {
      result = pwMemInChunks (num_top_objs+1, (void **)&top_objs, 
				sizeof (PWobjid), MALLOC_CHUNKS);
      OnErrorCode (result, wrapup);
 
      top_objs[num_top_objs] = top_objid;
      num_top_objs++;
    }
  }

  /*
   * Apply the class eligibility criteria to the unique list of top-owners
   * so far compiled. Note that the memory allocated to hold the unique 
   * top-owners list, is itself used for output (so that another malloc 
   * is prevented).
   */

  result = omEligObjs (num_top_objs, top_objs, os,
            num_eligclass, eligclass, num_ineligclass, ineligclass,
            num_objids, &top_objs);
  OnErrorCode (result, wrapup);
  if (objids)
  {
    *objids = top_objs;
    top_objs = NULL;
  }

wrapup:
  if (rtree_objs)
    free (rtree_objs);
  if (top_objs)
    free (top_objs);

  PW_Wrapup (result, "pwGetRtreeTopOwners");
  return (result);
}

