#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <memory.h>

#include "igrtypedef.h"
#include "igr.h"        
#include "bs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"

#include "emsedgedef.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWerror.h"

/*
  ABSTRACT

  NOTES
*/

int pwGetEdTypeFromBsType
( 
  int bstype
)
{
  switch (bstype)
  {
    case BSPOINT :
      return EMpoint;

    case BSLINE : 
      return EMlinesegment;

    case BS3DLINESTR :
    case BS2DLINESTR :
      return EMlinestring;

    case BSCIRCLE :
      return EMcircle;

    case BSELLIPSE :
      return EMellipse;

    case BSCIRC_ARC :
      return EMcircular_arc;
      
    case BSELLIP_ARC :
      return EMelliptical_arc;

    default :
      return EMfreeform_curve;
  }
}
