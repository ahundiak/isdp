/* $Id: VDfrmattr.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vdannot/imp/VDfrmattr.I
 *
 * Description:
 *
 *      This file implements the methods GRgetattr and GRputattr for VDfrmtxt
 *	objects.
 *      
 * Dependencies:
 *      VDfrmtxt.S
 *
 * Revision History
 *	$Log: VDfrmattr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/05/09  22:31:46  pinnacle
# Created: vdannot/imp/VDfrmattr.I by yzhu for vds.240
#
 *
 * History:
 *	05/07/96	yzhu		creation date
 *                                      content are empty so far. 
 * -------------------------------------------------------------------------
 */

class implementation VDfrmtxt;

#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "exdef.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "vddrwattr.h"
#include "vds.h"
#include "VDmsg.h"

/*+mo
 -------------------------------------------------------------------------
  Public Message 
	GRputattr	from GRvg

  	Retrieve the attributes from the VDfrmtxt object.

  Arguments
	IGRlong         *msg		O : Completion code.
	IGRchar		*attr		I : Attribute Structure.

  Status/Return Code

	OM_S_SUCCESS	if success;
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-me*/

method GRputattr(	IGRlong			*msg;
			IGRchar			*attr ){

	IGRint		sts = OM_S_SUCCESS ;	/* OMreturn code   */

	SetProc( VDfrmtxt_GRputattr ); Begin

	*msg	= MSSUCC ;

	End;
	return sts ;
}

/*+mo
 -------------------------------------------------------------------------
  Public Message 
	GRgetattr	from GRvg

  Abstract
  	Retrieve the attributes from the VDfrmtxt object.

  Arguments
	IGRlong         *msg		O : Completion code.
	IGRchar 	*attr		O : Attribute Structure.

  Status/Return Code

	OM_S_SUCCESS	if success;
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-me*/

method GRgetattr(	IGRlong			*msg;
			IGRchar			*attr ){

	IGRint		sts = OM_S_SUCCESS ;	/* OMreturn code   */

	SetProc( VDfrmtxt_GRgetattr ); Begin

	*msg	= MSSUCC ;

	End;
	return sts;
}

/*----------------------------------------------------------------------------*/

end implementation VDfrmtxt;

