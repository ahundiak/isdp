/*

Name
  SSListRm.C

Description
  Function used to remove elements from the the SSObjects[] array.

Notes

 */

#include <math.h>
#include "bserr.h"
#include "bsvalues.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"

/*

Name
  SSListRemoveObject

Abstract
  This routine finds the specifiec object (objid) in the SSObjects[] list
  and removes it. 

Synopsis

int SSListRemoveObject  ( objid, osnum )
  GRobjid     objid   (IN)  objid  of element to be removed form the list
  GRspacenum  osnum   (IN)  object space of element ( if 0, master assumed )

Description
  If the object (*objid) is in the list (SSObjects[]), it is removed.
  The relative order of the remaining members of the list is unchanged.

Return Value
  OM_S_SUCCESS always

Notes

  Global variables modified:
    SSObjects[]
    SSnb_objects

Index

Keywords

History
  09/07/93 : Shelley R. Heard : created


 */

int SSListRemoveObject( objid, osnum )
  GRobjid     objid;
  GRspacenum  osnum;
{
  int rc = OM_S_SUCCESS;
  int ssobj_index;
  int ndx;

  if ( SSListMember( objid, osnum, &ssobj_index ) )
  {
    SSListFreeMember( ssobj_index );

    /*
     * Shift the list to bump the last object out and make room for the
     * new one.  The "oldest" objects have the smallest indices.
     */
    for (ndx = ssobj_index; ndx < SSnb_objects - 1; ndx++)
    {
      SSObjects [ndx] = SSObjects [ndx + 1];
    }
    SSnb_objects--;
  }

  return rc;
}
