/* $Id: VDCmdVdsUpd.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/cmd/VDCmdVdsUpd.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdVdsUpd.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
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
# Revision 1.1  1996/05/21  13:32:00  pinnacle
# Created: vdvisual/cmd/VDCmdVdsUpd.I by v240_int for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>

#include <OMerrordef.h>
#include <OMmacros.h>
#include <OMprimitives.h>

#include "DItypedef.h"
#include "DIdef.h"
#include "FI.h"

from	FIdirform	import update;
from	VDCmdDirFrm	import update;

/*+fe
  Function VDdir_update_form

  Macro Name
	vd$dir_update_form

  Abstract
	Macro to be called by every command object which can change the
	active situation of the Directory Form.

  Arguments
      <Data Type>	<Name>  <I/O>	<Description>

	none.

  Algorithm
	Check form pointer and get the object (id/os) to call the update form
	method.
	
  Notes/Remarks

  Examples
	exp$create( ... )

	vd$dir_update_form();

  Returns
	Allways TRUE.

-fe*/


int VDdir_update_form ()
{
int			status;
DIobjid			form_id;
OMuword			form_os;
Form			form1;
Form			form2;

extern void		DIget_dir_form();
extern void		VDget_dir_form();

	DIget_dir_form( &form1 );

	if( form1 ){
#ifdef	DEBUG
		printf(" VDdir_update_form: EMS form update \n");
#endif
		status = FIf_get_cmd_oid_os ( form1, &form_id, &form_os );
		if (!status)
			status =
			om$send(msg      = message FIdirform.update (),
				senderid = NULL_OBJID,
				targetid = form_id,
				targetos = form_os );
	}

	/*
	 * get the I/VDS form pointer.
	 */
	VDget_dir_form ( &form2 );

	if (form2) {

#ifdef  DEBUG
		printf(" VDdir_update_form: VDS form update \n");
#endif
		status = FIf_get_cmd_oid_os ( form2, &form_id, &form_os );
		if (!status)
			status =
			om$send(msg      = message VDCmdDirFrm.update (),
				senderid = NULL_OBJID,
				targetid = form_id,
				targetos = form_os );
	}

	return OM_S_SUCCESS;
}

end implementation Root;
