/* $Id: VDCmdDirUpd.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/cmd / VDCmdDirUpd.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDirUpd.I,v $
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
# Revision 1.2  1996/05/21  13:31:42  pinnacle
# Replaced: vdvisual/cmd/VDCmdDirUpd.I for:  by v240_int for vds.240
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
 *	05/21/96	adz		Split file in two....
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

/*
 * Override the function in the file super_diri.I
 *
 *	Whenever the function DIupdate_form is called we can check here
 *	which form is active and be updated.
 *
 * I/VDS macro: vd$dir_update_form() is a macro in I/VDS which can be used
 *		by any command object to update the form directly.
 */

int DIupdate_form ()
{
  int         status;
  DIobjid     form_id;
  OMuword     form_os;
  Form        form1;
  Form        form2;
  extern void DIget_dir_form();
  extern void VDget_dir_form();

  DIget_dir_form ( &form1 );

  if (form1)
  {
#ifdef	DEBUG
    printf(" DIupdate_form: EMS form update \n");
#endif
    status = FIf_get_cmd_oid_os ( form1, &form_id, &form_os );
    if (!status)
      status = om$send ( msg      = message FIdirform.update (),
                         senderid = NULL_OBJID,
                         targetid = form_id,
                         targetos = form_os );
  }

  VDget_dir_form ( &form2 );

  if (form2)
  {

#ifdef	DEBUG
    printf(" DIupdate_form: VDS form update \n");
#endif

    status = FIf_get_cmd_oid_os ( form2, &form_id, &form_os );
    if (!status)
      status = om$send ( msg      = message VDCmdDirFrm.update (),
                         senderid = NULL_OBJID,
                         targetid = form_id,
                         targetos = form_os );
  }

  return DIR_S_SUCCESS;
}

end implementation Root;
