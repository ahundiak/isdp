/*

Name
  SSSvLstCnstr.I

Description

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
  SSSaveLastConstraint

Abstract
  This routine saves the constraint passed in as the last constraint and pushes
  PObject1 (and PObject2 if any) to the beginning of the list.
 

Synopsis
  int SSSaveLastConstraint ( PObject1, PObject2, ConstraintType, 
                           ConstraintPoint, KeyPoint )
  SSObject *PObject1        IN   First object to be constrained
  SSObject *PObject2        IN   Second object (if any) to be constrained
  int      ConstraintType   IN   Type of constraint  (See SS.h)
  IGRpoint ConstraintPoint  IN   The Point where the constraint is matched
  IGRpoint KeyPoint         IN   The key point of the object

Description

Return Value

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

int SSSaveLastConstraint ( PObject1, 
                           PObject2, 
                           ConstraintType, 
                           ConstraintPoint,
                           KeyPoint )
SSObject *PObject1;
SSObject *PObject2;
int      ConstraintType;
IGRpoint ConstraintPoint;
IGRpoint KeyPoint;
{
  OM_S_OBJID Objid1 = NULL_OBJID; 
  OM_S_OBJID Objid2 = NULL_OBJID;
  int        ObjectIndex;
  
  /*
   * Save the last constraint. We compute the index of PObject1 and PObject2
   * because the list is going to change and the pointers will no longer be
   * valid.
   */
  SSLastConstraintType = ConstraintType;

  if (PObject1)
    Objid1 = PObject1->grid.objid;
  if (PObject2)
    Objid2 = PObject2->grid.objid;

  /*
   * We save the constraint point and the key point before last (used to display
   * and compute multiple constraints).
   */
  memcpy ( &SSLastConstraintPoint [3], SSLastConstraintPoint, sizeof ( IGRpoint ) );
  memcpy ( &SSLastKeypoint [3], SSLastKeypoint, sizeof ( IGRpoint ) );
  
  memcpy ( SSLastConstraintPoint, ConstraintPoint, sizeof ( IGRpoint ) );
  if (KeyPoint)
    memcpy ( SSLastKeypoint, KeyPoint, sizeof ( IGRpoint ) );
  SSLastAvailable = 1;

  for (ObjectIndex = 0, SSLastObject1 = NULL, SSLastObject2 = NULL; 
       ObjectIndex < SSnb_objects; ObjectIndex++)
  {
    if (SSObjects [ObjectIndex].grid.objid == Objid1 && PObject1)
      SSLastObject1 = &SSObjects [ObjectIndex];
    if (SSObjects [ObjectIndex].grid.objid == Objid2 && PObject2)
      SSLastObject2 = &SSObjects [ObjectIndex];
  }

  return OM_S_SUCCESS;  
}


end implementation Root;
