/* $Id: VDtblInit.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDtblInit.I
 *
 * Description:
 *	Implementation of the following method  for VDdrwTbl :
 *		VDinitTbl
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	07/14/95	R. Manem	Initialize adsTblName
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTbl;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "vds.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

/*+me
 ---------------------------------------------------------------------------
  Public Message VDinitTbl

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDinitTbl(   IGRlong         *msg )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTbl.VDinitTbl ); Begin

    *msg = MSSUCC;

    me->tblLayoutName[0] = '\0';
    me->adsTblName[0] = '\0';
    me->approvalStatus = 0;

    End
    return status;
}

end implementation VDdrwTbl;

