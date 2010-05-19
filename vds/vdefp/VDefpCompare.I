/* $Id: VDefpCompare.I,v 1.1 2001/01/11 19:04:49 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdefp/VDefpCompare.I
 *
 * Description: Pcmk Attribute Comparison Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDefpCompare.I,v $
 *      Revision 1.1  2001/01/11 19:04:49  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  16:53:24  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDexp.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"

#include "VDassert.h"

// Just to make sure
extern double fabs(double);

/* -----------------------------------------------
 * Plate thickness are .1 mm increments
 */
IGRint VDefpPcmkCompareDouble(IGRdouble tol, IGRdouble val1, IGRdouble val2)
{
  IGRdouble delta;
  
  delta = fabs(val1 - val2);
  if (delta < tol) return 0;
  
  if (val1 < val2) return -1;
  return 1;
}

/* -----------------------------------------------
 * Plate thickness are .1 mm increments
 */
IGRint VDefpPcmkComparePlateThickness(IGRdouble thick1, IGRdouble thick2)
{
  return VDefpPcmkCompareDouble(0.1,thick1,thick2);
}

/* -----------------------------------------------
 * Plate area use 4mm tolerance
 */
IGRint VDefpPcmkComparePlateArea(IGRdouble area1, IGRdouble area2)
{
  return VDefpPcmkCompareDouble(4.0,area1,area2);
}

/* -----------------------------------------------
 * Total Edge Length 2.0 mm
 */
IGRint VDefpPcmkComparePlateEdgeLength(IGRdouble len1, IGRdouble len2)
{
  return VDefpPcmkCompareDouble(2.0,len1,len2);
}

/* -----------------------------------------------
 * Total Beam Length 2.0 mm
 */
IGRint VDefpPcmkCompareBeamLength(IGRdouble len1, IGRdouble len2)
{
  return VDefpPcmkCompareDouble(2.0,len1,len2);
}
/* -----------------------------------------------
 * Total Beam Height .1 mm
 */
IGRint VDefpPcmkCompareBeamHeight(IGRdouble height1, IGRdouble height2)
{
  return VDefpPcmkCompareDouble(0.1,height1,height2);
}

end implementation Root;
