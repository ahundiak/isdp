/* $Id: VDctxStubs.c,v 1.3 2002/02/26 15:36:01 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/s/VDctxStubs.c
 *
 * Description: Stubs for stand alone programs
 *              These should never actualy be called
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxStubs.c,v $
 *      Revision 1.3  2002/02/26 15:36:01  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/17 14:20:43  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/14 16:08:21  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/14/01  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDctx.h"
#include "VDobj2.h"
#include "VDos.h"

VDASSERT_FFN("vdctx/s/VDctxStubs.c");

/* -----------------------------------------------
 * Stub function, gets overridden in the om routines
 */
IGRstat VDctxInitCt1CP(TVDctxCP *baseCP, TVDctxCP *cp)
{
  VDASSERT_FN("STUB VDctxInitCt1CP");
  VDASSERTW(0);
 wrapup:
  return 0;
}

/* -----------------------------------------------
 * Stub function, gets overridden in the om routines
 */
IGRstat VDctxInitAtCP(TVDctxCP *baseCP, TVDctxCP *cp)
{
  VDASSERT_FN("STUB VDctxInitAtCP");
  VDASSERTW(0);
 wrapup:
  return 0;
}

/* -----------------------------------------------
 * Stub function, gets overridden in the om routines
 */
IGRstat VDctxInitOmCP(TVDctxCP *baseCP, TVDctxCP *cp)
{
  VDASSERT_FN("STUB VDctxInitOmCP");
  VDASSERTW(0);
 wrapup:
  return 0;
}




