/*

Name
  SSChkCndt.I

Description

Notes


 */
class implementation Root;

#include <math.h>
#include <bsvalues.h>

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

/* prototypes */
#include "maptlnpro.h"


/*

Name
  SSCheckCoincident 

Abstract

Synopsis
  int SSCheckCoincident()
    SSObject       *pObject         IN  The object to check for coinc cnstr
    SSObject       *PLastObject     IN  The last object in the list (not used)
    double         Tolerance        IN  The window tolerance            
    struct IGRline *PBoreLine       IN  The bore line
    IGRpoint       ConstraintPoint  OUT The point we are constrained to
    IGRpoint       KeyPoint         OUT The key point of the element (not used)
    SSObject       **PpObject       OUT Pointer to other object (not used)

Description
 This routine checks if the current mouse position (x, y, z) is close enough
 to a keypoint for a coincident constraint to be recognized. 
 

Return Value
 If coincident constraint is within tolerance, it's type is returned.
 Else, SSNONE is returned

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added.

 */
#argsused
int SSCheckCoincident ( pObject, PLastObject, Tolerance, PBoreLine, 
                        ConstraintPoint, KeyPoint, PpObject )
SSObject       *pObject       /* The object to check for coinc cnstr    IN  */;
SSObject       *PLastObject   /* The last object in the list (not used) IN  */;
IGRdouble       Tolerance     /* The window tolerance                   IN  */;
struct IGRline *PBoreLine     /* The bore line                          IN  */;
IGRpoint       ConstraintPoint/* The point we are constrained to        OUT */;
IGRpoint       KeyPoint       /* The key point of the element (not used)OUT */;
SSObject       **PpObject     /* Pointer to other object (not used)     OUT */;
{
  int      KeyPointIndex, ConstraintType = SSNONE;
  long     LocalStatus;
  IGRpoint Point;
  double   UParm, Distance;
  
  /*
   * Check if one of the key points is within tolerance of the known
   * keypoints
   */
  for ( KeyPointIndex = 0; 
        (KeyPointIndex < pObject->NbKeyPoints) && (ConstraintType == SSNONE); 
        KeyPointIndex++ )
  {
    if (PBoreLine->point2)
    {
      MAptlnproj ( &LocalStatus, 
                    pObject->KeyPoints [KeyPointIndex], 
                    PBoreLine, 
                    Point, 
                   &UParm );
      Distance = MAXFLOAT;
      MA2ptdis ( &LocalStatus, 
                  pObject->KeyPoints [KeyPointIndex], 
                  Point, 
                 &Distance );
    }
    else
      MA2ptdis ( &LocalStatus, 
                  pObject->KeyPoints [KeyPointIndex], 
                  PBoreLine->point1, 
                  &Distance );


    if ( Distance < Tolerance ) /* close enough */
    {
      /*
       * It's good enough for us...
       */
      switch ( KeyPointIndex )
      {
	case 0:
        {
	  if (pObject->type == SSCIRCLE)
	  {
            ConstraintType = SSCENTER;
	  }
          else
	  {
            ConstraintType = SSFIRSTPOINT;
	  }
	}
	break;

	case 1:
	{
          if (pObject->type == SSLINE)
	  {
            ConstraintType = SSMIDPOINT;
	  }
          else
	  {
            if (pObject->type == SSARC)
	    {
              ConstraintType = SSCENTER;
	    }
            else
	    {
              ConstraintType = SSKEYPOINT;
	    }
	  }
	}
	break;

	case 2:
	{
          if (pObject->type == SSARC || pObject->type == SSLINE)
	  {
            ConstraintType = SSLASTPOINT;
	  }
          else if (pObject->type == SSBSCURVE)
	  {
            ConstraintType = SSMIDPOINT;
	  }
          else
	  {
            ConstraintType = SSKEYPOINT;
	  }
	}
	break;

	case 3:
	{
          if (pObject->type == SSARC)
	  {
            ConstraintType = SSMIDPOINT;
	  }
          else
	  {
            ConstraintType = SSKEYPOINT;
	  }
	}
	break;

	default:
        {
	  ConstraintType = SSKEYPOINT;
        }
      }

      memcpy ( ConstraintPoint,
	       pObject->KeyPoints [KeyPointIndex],
	       sizeof ( IGRpoint ) );
      SSSaveLastConstraint ( pObject, 
			     NULL,
			     ConstraintType,
			     pObject->KeyPoints [KeyPointIndex],
                             pObject->KeyPoints [KeyPointIndex] );
      pObject->KeyPointActive [KeyPointIndex] = 1;
    }
  }
  
  return ConstraintType;
}
  
end implementation Root;
