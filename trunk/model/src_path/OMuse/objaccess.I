/*
  OVERVIEW

  This file contains APIs that are used to gain first-level access to objects
  inside a datafile. These APIs only deal at the OM or Rtree level and no
  knowledge of the semantics of the objects is assumed here. The only criteria
  that can be used to look up objects involve classids and 3D geometry ranges
  (the latter for objects in the Rtree).


  HISTORY

  SS   :   06/13/95   :   Creation
*/

class implementation Root;

#include <alloca.h>

#include "OMmacros.h"
#include "OMindex.h"

#include "godef.h"

#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/objaccess.h"
#include "PWapi/ommisc.h"
#include "PWapi/clsid.h"
#include "PWapi/memfunc.h"

%safe
static int max_space_map_entries
(
  PWosnum os
);
%endsafe

from OMrtree import get_stat;
from OMindex import translate;

/*
  ABSTRACT

  This function is used to obtain the object of a given classid from a given
  OS. This function will be typically used, when it is known that there can 
  be only one object of a given classid inside this object-space. If no such
  object found a PW_K_NullObjid is returned.
*/

PWobjid omObjOfClass
(
  PWclassid objclass,
  PWosnum os
)
{
  int objid, max;
  PWobjid classobj=PW_K_NullObjid;

  max = max_space_map_entries (os);
  for (objid=0; objid<max; objid++)
  {
    if (omIsAncestryValid (omClassidFromObjid (objid, os), objclass))
    {
      classobj = objid;
      break;
    }
  }
  return (classobj);
}

/*
  ABSTRACT

  This function is used to obtain all the objects that belong to one of the
  given classids in a given OS. Atleast one classid must be specified ("Root"
  catches all). Optionally, a list of classids can also be specified to 
  which these object must NOT belong. This function will malloc the memory
  for output. 'free' should be used to release the memory back to the heap.
  The number of objects found is always returned in 'num_objids'.


  NOTE

  If a NULL is specified in place of the output argument -- 'objids',
  no attempt to return the objids is made, but the number of objects being
  returned is still valid.
*/

PWresult omGetObjsOfClass
(
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWosnum os,
  int *num_objids,
  PWobjid **objids
)
{
  if (objids)
    *objids = NULL;
  *num_objids = 0;

  return omEligObjs (max_space_map_entries (os), NULL, os, num_eligclass, 
          eligclass, num_ineligclass, ineligclass, num_objids, objids);
}


/*
  ABSTRACT

  This function takes in an array of objids together with class eligibility
  (and optionally, ineligibility) criteria. It outputs into 'outobjs', all
  those objects that are found to satisfy the class criteria. The memory for
  'outobjs' may or may not be supplied.

  The only failure that can be detected occur within this function is, when
  a request to malloc memory cannot be fulfilled. 


  OPTIONS

  The input 'inobjs' can be NULL. In this case, the objids are considered
  as ranging from '0' to 'num_inobjs-1', ie, the objids are taken to
  be implied. 

  The output 'outobjs' can be NULL, if only a count of eligible objects is
  desired. '*outobjs' can also point to the same memory location as
  'inobjs', in which case, the input array is re-written with only those 
  objids that are "valid". Lastly, '*outobjs' can point to NULL, in which
  case, this function will malloc the memory for the caller.
*/

#define MALLOC_CHUNKS  50

PWresult omEligObjs
(
  int num_inobjs,
  PWobjid *inobjs,
  PWosnum os,
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  int *num_outobjs,
  PWobjid **outobjs
)
{
  PWboolean pass_elig, pass_inelig, outmem_input;
  int objid, inx, i;
  PWclassid classid;
  PWresult result=PW_K_Success;
  
  *num_outobjs = 0;
  if (outobjs && *outobjs)
    outmem_input = TRUE;
  else
    outmem_input = FALSE;

  for (inx=0; inx<num_inobjs; inx++)
  {
    if (!inobjs)
      objid = inx;
    else
      objid = inobjs[inx];

    classid = omClassidFromObjid (objid, os);

    pass_elig=FALSE;
    for (i=0; i<num_eligclass; i++)
    {
      if (omIsAncestryValid (classid, eligclass[i]))
      {
        pass_elig = TRUE;
        break;
      }
    }

    pass_inelig = TRUE;
    if (pass_elig && num_ineligclass)
    {
      for (i=0; i<num_ineligclass; i++)
      {
        if (omIsAncestryValid (classid, ineligclass[i]))
        {
          pass_inelig = FALSE;
          break;
        }
      }
    }

    if (pass_elig && pass_inelig)
    {
      if (outobjs)
      {
        if (!outmem_input)
        {
          result = pwMemInChunks (*num_outobjs+1, (void **) outobjs, 
                    sizeof (PWobjid), MALLOC_CHUNKS);
          OnErrorCode (result, wrapup);
        }
        (*outobjs)[*num_outobjs] = objid;
      }

      (*num_outobjs)++;
    }
  }

wrapup:
  PW_Wrapup (result, "omEligObjs");
  return (result);
}

/*
  ABSTRACT

  This function is used to obtain all the objects in the R-tree of a given OS,
  that belong to one of the given classids. Atleast one classid must be
  specified ("Root" catches all). Optionally, a list of classids can also be
  specified to which these object must NOT belong. This function will malloc
  the memory for output. 'free' should be used to release the memory back to
  the heap. The number of objects found is always returned in 'num_objids'.


  NOTE

  If a NULL is specified in place of the output argument -- 'objids',
  no attempt to return the objids is made, but the number of objects being
  returned is still valid.
*/

PWresult omGetRtreeObjsOfClass
(
  int num_eligclass,
  PWclassid *eligclass,
  int num_ineligclass,
  PWclassid *ineligclass,
  PWosnum os,
  int *num_objids,
  PWobjid **objids
)
{
  int size, ret, num_rtree_entries;
  PWobjid rtree, *rtree_entries;
  PWresult result=PW_K_Success;
  OM_S_KEY_DESC rtree_key;
  DB_3D_DBL_BOX range_box;
  OM_p_OBJARRAY p_rtree_objarray;
  OM_S_RTREESTAT rtree_stat;

  /*
   * Initialize the output
   */

  *num_objids = 0;
  if (objids)
    *objids = NULL;

  /*
   * Obtain the GRrtree object in this OS. There is only one per OS.
   */

  rtree = omObjOfClass (omClassidFromName ("GRrtree", os), os);
  OnErrorState (rtree == PW_K_NullObjid, result,
   SetError (PW_K_Pathway, PW_K_NotFound), wrapup);

  /*
   * Get the total number of entries in this R-tree
   */

  rtree_stat.request_type = RTREE_MISC_STATUS;
  result = om$send (msg = message OMrtree.get_stat (&rtree_stat, &ret),
            targetid = rtree, targetos = os, senderid = rtree);
  OnErrorCode (result, wrapup);
  num_rtree_entries = rtree_stat.rtree_status.misc.key_count;

  /*
   * Obtain all the entries in the R-tree using a range stretching across
   * design limits. Space for obtaining these objids is allocated on the
   * stack.
   */
  
  size = (sizeof (OM_S_OBJID) * num_rtree_entries) + sizeof (OM_S_OBJARRAY);
  p_rtree_objarray = (OM_S_OBJARRAY *) alloca (size);
  p_rtree_objarray->size = size;
  p_rtree_objarray->count = 0;
  p_rtree_objarray->tree_type = KEY_3D_DBL;

  range_box.xmin = GRDGNLIMITS_MIN_D;
  range_box.ymin = GRDGNLIMITS_MIN_D;
  range_box.zmin = GRDGNLIMITS_MIN_D;
  range_box.xmax = GRDGNLIMITS_MAX_D;
  range_box.ymax = GRDGNLIMITS_MAX_D;
  range_box.zmax = GRDGNLIMITS_MAX_D;
  rtree_key.type = KEY_3D_DBL;
  rtree_key.key.p_3ddbl = &range_box;

  result = om$send (msg = message OMindex.translate (p_rtree_objarray,
            &rtree_key, NULL, NULL, &ret), targetid = rtree, targetos = os,
            senderid = rtree);
  OnErrorCode (result, wrapup);
  rtree_entries = p_rtree_objarray->array;

  /*
   * Scan through this list of objids and return those that satisfy the
   * class eligibility criteria.
   */

  result = omEligObjs (num_rtree_entries, rtree_entries, os, 
            num_eligclass, eligclass, num_ineligclass, ineligclass,
            num_objids, objids);
  OnErrorCode (result, wrapup);

wrapup:
  PW_Wrapup (result, "omGetRtreeObjsOfClass");
  return (result);
}

/*----------------------- STATIC FUNCTION DEFINITIONS ----------------------*/

static int max_space_map_entries
(
  PWosnum os
)
{
  int i, max=0;
  OM_p_OSD p_OSD;
  OM_p_SPAMAPENT p_entry;

  p_OSD = OM_GA_OSDs[os];
  if (p_OSD && p_OSD->CurSpaceMapSize)
  {
    for (i = p_OSD->CurSpaceMapSize-1, p_entry = p_OSD->Spacemap+i;
         i >= 0;
         i--, p_entry--)
    {
      if (! (OM_OBJ_INVALID (p_entry->flags)))
      {
        max = i+1;
        break;
      }
    }
  }

  return (max);
}

end implementation Root;
