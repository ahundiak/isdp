/* $Id: VDdomMisc.c,v 1.2 2001/03/11 18:35:11 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDdomMisc.c
 *
 * Description: Misc functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdomMisc.c,v $
 *      Revision 1.2  2001/03/11 18:35:11  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/11 19:28:37  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:00:28  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/05  16:35:24  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/01/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDdom.h"

#include "VDassert.h"

VDASSERT_FFN("vddom/VDdomMisc.c");

/* -----------------------------------------------
 * Pulls out a list of doubles from an attribute string
 *
 * Note: cnt may be set to a value higher than max!!!
 * doubles will not be overfilled but calling routine
 * needs to be aware
 */
IGRstat VDdomGetDoublesFromAttribute(IGRchar   *value, 
				     IGRint     max, 
				     IGRint    *cnt, 
				     IGRdouble *doubles)
{
  VDASSERT_FN("VDdomGetDoublesFromAttribute");
  IGRstat retFlag = 0;

  IGRdouble dbl;
  IGRint    cntx = 0;
  IGRchar  *p;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  if (cnt) *cnt = 0;
  VDASSERTW(value);
  
  // Loop
  p = value;
  while(*p) {
    
    // Strip leading blanks
    for(; *p == ' '; p++);
    
    // Pull double
    if (*p) {
      dbl = atof(p);
      if ((doubles) && (cntx < max)) {
	doubles[cntx] = dbl;
      }
      cntx++;
    }
    
    // Continue to next space
    for(; *p > ' '; p++);
    
  }
  
  // Done
  if (cnt) *cnt = cntx;
  retFlag = 1;
  
 wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}
