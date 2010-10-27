/* $Id: VDgeomKnot.I,v 1.1 2001/01/11 18:41:18 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgeomKnot.I
 *
 * Description:	Curve Knot Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomKnot.I,v $
 *      Revision 1.1  2001/01/11 18:41:18  art
 *      sp merge
 *
# Revision 1.3  2000/07/27  20:40:00  pinnacle
# ah
#
# Revision 1.2  2000/04/28  19:32:24  pinnacle
# ah
#
# Revision 1.1  2000/04/25  16:16:16  pinnacle
# ah
#
# Revision 1.1  2000/04/11  17:14:28  pinnacle
# ah
#
# Revision 1.5  2000/04/05  22:18:28  pinnacle
# ah
#
# Revision 1.4  2000/03/31  17:00:56  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/21/00  ah      Added Header
 * 03/21/00  ah      Changed BSalloccv to VDgeomAllocCrv()
 * 04/05/00  ah      Changed GetKnot tolerance
 * 07/27/00  ah      Force beg/end knot to 0.0/1.0
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"

static int traceFlag;

/* -----------------------------------------------
 * Initialize a knot buffer
 */
IGRstat VDgeomInitKnots(TVDgeomKnots *knots, IGRdouble *buf, IGRint max)
{ 
  if (knots == NULL) goto wrapup;
  
  memset(knots,0,sizeof(TVDgeomKnots));
  knots->sbuf  = buf;
  knots->knots = buf;
  knots->max   = max;

 wrapup:  
  return 1;
}
/* -----------------------------------------------
 * Frees a knot buffer if required
 */
IGRstat VDgeomFreeKnots(TVDgeomKnots *knots)
{

  if (knots == NULL) goto wrapup;
  if (knots->knots != knots->sbuf) _FREE(knots->knots);

 wrapup:  
  return 1;
}

/* -----------------------------------------------
 * Return a list of unique knots allocating
 * more room if required
 *
 * Uses new interface
 */
IGRstat VDgeomGetKnotsFromCurve(TGRbsp_curve *a_crv,   // I  - the curve 
				IGRdouble     a_tol,   // I  - Optional parameter tolerance
				IGRdouble     a_par0,  // I  - Optional parameter filter
				IGRdouble     a_par1,  // I  - Optional parameter filter
				TVDgeomKnots *a_knots) // IO - Knot Information
{
  IGRstat retFlag = 0;

  IGRdouble *knots,knot;

  IGRint i,j;
  
  // Arg check
  if (a_knots == NULL) goto wrapup;
  if (a_crv   == NULL) goto wrapup;

  // Knot structure must be initted correctly
  knots = a_knots->knots;
  a_knots->cnt = 0;
  
  /* -------------------------------------------------------------------
   * This is pretty critical, .01 filters out too many knots
   * What is really needed is a special check for line strings and return
   * one knot per pole, but for now, .001 seems to work.
   */
  if (a_tol < .0001) a_tol = VDGEOM_TOL_PARAMETER;
    
  // Make sure have room
  if ((knots == NULL) || (a_crv->num_knots > a_knots->max)) {
    if ((knots == NULL) || (knots == a_knots->sbuf)) {
      knots = _CALLOC (a_crv->num_knots,IGRdouble);
    }
    else {
      knots = _REALLOC(knots,a_crv->num_knots,IGRdouble);
    }
    
    if (knots == NULL) {
      printf("*** Problem allocating knot array\n");
      goto wrapup;
    }
    a_knots->knots = knots;
    a_knots->max   = a_crv->num_knots;  
  }

  // Cycle through
  for(i = 0; i < a_crv->num_knots; i++) {
    knot = a_crv->knots[i];
    if ((knot >= a_par0) && (knot <= a_par1)) {
      j = a_knots->cnt;
      if ((j == 0) || ((knot - knots[j-1]) >= a_tol)) {
	knots[j] = knot;
	a_knots->cnt++;
      }
    }
  }
  /* --------------------------------------------------------
   * Learned the hard way the there can be quite a gap
   * between .999 and 1.0
   */
  if (a_knots->cnt) {
    knots[a_knots->cnt - 1] = a_par1;
  }
  knots[0] = a_par0;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation Root;

