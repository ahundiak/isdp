/* $Id: VDreturnfoot.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdmisc/ VDreturnfoot.I
 *
 * Description:
 *    This file include function used for copy a query to a new query and
 *    change name A to A1 if A exists in the design file
 *
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDreturnfoot.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *      Initial import to CVS
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
# Revision 1.1  1996/03/21  22:55:42  pinnacle
# Created: vdmisc/VDreturnfoot.I by yzhu for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/21/95        Yzhu            create(copy from VLmiscMacro.I)
 * -------------------------------------------------------------------*/

class implementation VDSroot ;

#include	<stdio.h>
#include	<string.h>
#include	"AS_status.h"
#include	"grdpbmacros.h"
#include	"grmacros.h"
#include	"v_dbgmacros.h"

/*	#define	TRACE	*/

/* ========================================================================== */
IGRint	VDreturn_foot	(		IGRlong		*msg,
					IGRchar		*name,
				struct	GRid		*objId,
				struct	GRmd_env	*objEnv,
				struct	GRid		*footId,
				struct	GRmd_env	*footEnv	)
{
	IGRint	sts		=MSFAIL;
	struct	GRmd_env	env;

        SetProc( VDreturn_foot ); Begin
	/* Send the famous message */
	sts = om$send ( msg = message NDmacro.ACreturn_foot (
					msg,
					name,
					footId,
					&env.md_env.matrix_type,
					env.md_env.matrix ),
			senderid = NULL_OBJID,
			targetid = objId->objid,
			targetos = objId->osnum );

	if (!(sts & 0x00000001 & (*msg)))	goto wrapup;

	/* Complete foot environ */
	if (footEnv)	footEnv->md_env = env.md_env;
	if ( (footEnv) && (objEnv) ) {
			footEnv->md_id.objid = objEnv->md_id.objid;
			footEnv->md_id.osnum = footId->osnum;
	}

wrapup:
        End
	return (sts);
}
end implementation VDSroot;
