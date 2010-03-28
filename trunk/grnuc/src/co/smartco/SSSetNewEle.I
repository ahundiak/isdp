/*

Name
  SSSetNewEle.I

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
#include "igrdef.h"
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


/*

Name
  SSSetNewElement

Abstract
  This routine is used to tell the Smart Sketch that an element is being
  constructed. The Smart Sketch will attempt to recognize constraints between
  that new element and the current elements it is considering.  SS will also 
  recognize constraints on the object itself (horizontal, vertical, ...)
 
Synopsis
  int SSSetNewElement ( ElementType, Points, NewFlag )
  int      ElementType   IN  The type of element the user is constructing
  IGRpoint Points        IN  The points that define that element (- 1)
  int      NewFlag       IN  sets to communicate more info about new element

Description

Return Value
  OM_S_SUCCESS  success
  MSINARG       if (ElementType != SSNONE && Points == NULL)

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */
int SSSetNewElement ( ElementType, Points, NewFlag )
  int      ElementType;
  IGRpoint Points;
  int      NewFlag;
{
  int status = OM_S_SUCCESS;

  /*
   *  An once of prevention:  If ElementType is not SSNONE, then Points 
   *  had better not be NULL.
   */
  if (ElementType != SSNONE && Points == NULL)
  {
    status = MSINARG;
    goto wrapup;
  }

  SSNewElementType = ElementType;
  SSNewFlag = NewFlag;

  switch (ElementType)
  {
    case SSLINE : 
    {
      memcpy ( SSNewPoints [0], Points, sizeof ( IGRpoint ) );
      break;
    }

    case SSARC :
    {
      /*
       *  SSNewPoints[0] - first Edgepoint
       *  SSNewPoints[1] - Center point of arc
       */
      memcpy ( SSNewPoints [0], Points, 2*sizeof ( IGRpoint ) );
      break;
    }

    case SSCIRCLE :
    {
      memcpy ( SSNewPoints [0], Points, sizeof ( IGRpoint ) );
      break;
    }

    case SSPOINT :
    {
      memcpy ( SSNewPoints [0], Points, sizeof ( IGRpoint ) );
      break;
    }

    case SSBSCURVE :
    {
      memcpy ( SSNewPoints [0], Points, sizeof ( IGRpoint ) );
      break;
    }

    default :
    {
      /* this handles the case of SSNONE */
      SSNewElementType = SSNONE;
    }
  }

wrapup:

  return status;
}

end implementation Root;
