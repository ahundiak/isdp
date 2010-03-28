/*

Name
  SSOrder.I

Description
  Complete rewrite of SSOrder on September 1, 1993. SRH

Notes


 */
class implementation Root;

#include <math.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpmacros.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMdtmacros.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"
#include "bserr.h"


/*

Name
  SSOrder

Abstract
 This function re-orders the list of objects such that the objects
 *pObject1 and *pObject2 are at the beginning of the list (will get 
 chosen first when looking for constraints).

Synopsis
  int SSOrder ( pObject1, pObject2 )
  SSObject *pObject1   IN  object to raise the priority of
  SSObject *pObject2   IN  another object to raise the priority of

Description

Return Value
  OM_S_SUCCESS  always

Notes

  If pObject1 is NULL, nothing happens (and it is assumed that pObject2
  is also NULL).

   
              Before                        After

  oldest     0    Obj1                    0    Obj1
             1    Obj2                    1    Obj2
             2    Obj3 <- *pObject1-.     2    Obj4
             3    Obj4              |     3    Obj6
             4    Obj5 <- *pObject2-|-    4    Obj7
             5    Obj6              | \-> 5    Obj5
  newest     6    Obj7              .---> 6    Obj3

 If *pObject1 is moved - it is moved to SSObjects[SSnb_objects-1].
 If *pObject2 is moved - it is moved to SSObjects[SSnb_objects-2].

 An offset variable contains the number of objects that have been
 shifted to the head of the list (1 or 2).  This offset subtracted
 from the index in SSObjects[] provides the index in the NewList[]
 array.

 There is a function (SSWeNeedToReorder()) which can be ued to determine
 whether the this function (SSOrder) needs to be called.  It is not 
 used here but is available.  For example: 

   if ( SSWeNeedToReorder(pObject1, pObject2) )
   {
     SSOrder(pObject1, pObject2);
   }

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.
  09/01/93 : Shelley R. Heard : Complete redesign to fix bugs.

 */

int SSOrder ( pObject1, pObject2 )
SSObject *pObject1, *pObject2   /* The objects to raise the priority of IN  */;
{
  SSObject NewList[SS_MAX_OBJECTS];
  int      iObject; 
  int      Offset = 0;
  int      fModified = FALSE;

  /*
   *  Go through the SSObjects[] list and copy objects into the temp
   *  list (NewList); when elements *pObject1 and *pObject2 are encountered
   *  they are moved to the top (higher index) of the temp list. If 
   *  reordering occurs, then the NewList is copied into the SSObjects list.
   */
  for ( iObject = 0; iObject < SSnb_objects; iObject++ )
  {
    if ( pObject1->grid.objid == SSObjects[iObject].grid.objid )
    {
      NewList[SSnb_objects-1] = SSObjects[iObject];
      Offset++;
      fModified = TRUE;
    }
    else if (   pObject2 
             && pObject2 != pObject1
             && pObject2->grid.objid == SSObjects[iObject].grid.objid 
             && (SSnb_objects >= 2))
    {
      NewList[SSnb_objects-2] = SSObjects[iObject];
      Offset++;
      fModified = TRUE;
    }
    else
    {
      /* straight copy */
       NewList[iObject - Offset] = SSObjects[iObject];
    }
  } 

  if (fModified)
  {
    memcpy ( SSObjects, NewList, (sizeof ( SSObject ) * SS_MAX_OBJECTS));
  }
  return OM_S_SUCCESS;
}

end implementation Root;
