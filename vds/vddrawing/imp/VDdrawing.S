/* $Id: VDdrawing.S,v 1.1.1.1 2001/01/04 21:08:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/imp / VDdrawing.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrawing.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/10/07  15:01:10  pinnacle
# Replaced: vddrawing/imp/VDdrawing.S for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class specification VDdrawing (0:0) of VDSroot;

#include "VDCmdDrwFr.h"

override ACconstruct_feet,
	 ACgive_structure,
	 ACfind_temp_obj,
	 GRxform;

/*+mo
  Overriden Message
	VDgetObjDef from VDSroot

  Abstract
        Returns the definition of an object: name of templates and feet, etc.
  Arguments
        OUT     long            *msg            Completion code.
        IN      VDobjDef        *objDef         Object definition.
  Note
        The fields of `objDef' point to static buffers and therefore should
        not be freed.
-mo*/

override VDgetObjDef;

message VDset_DrwFrParaIns( long *msg; struct  VDdrwFrmPar myFrmPar );
message VDget_DrwFrParaIns( long *msg; struct  VDdrwFrmPar *myFrmPar);

end specification VDdrawing;
