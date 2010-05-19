/* $Id: VDatStub.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatStup.I
 *
 * Description: Stub functions for ppl's which call product depcific functions.
 *              If for example, a set ppl calls a route function then need a 
 *              stub for it since all ppl's get executed while selecting a set
 *              to create.  Later, may add a product dependency to the process.
 *              And eliminate these stubs.  Need to be careful not to dynamically
 *              orvewrite the real functions hence the print statements.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatStub.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/04/27  15:43:08  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/27/98  ah      Creation
 ***************************************************************************/

class implementation VDatBase;

#include "VDobj.h"
#include "VDchn.h"
#include "v_dbgmacros.h"


/* --------------------------------------------------------
 * For the Maristep project
 */
IGRstat VDRTSumTreeNode(TGRid *objID)
{
  printf("*** Stub Function VDRTSumTreeNode Called For\n");
  vdobj$Print(objID = objID);
  return 0;
}

end implementation VDatBase;






