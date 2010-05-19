/* $Id: MacroMod.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdequip/api/MacroMod.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: MacroMod.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/10/29  17:24:12  pinnacle
# Place Equipment API
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/19/96	i-paris		created
 *
 ***************************************************************************/

class implementation Root;

#include	<stdio.h>
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"igrdef.h"
#include	"igr.h"
#include	"exdef.h"
#include	"ex.h"
#include	"igrdp.h"
#include	"gr.h"
#include	"growner.h"
#include	"godef.h"
#include	"go.h"
#include	"griodef.h"
#include	"grio.h"
#include	"AS_status.h"
#include	"asmacros.h"
#include	"grmacros.h"
#include	"macro.h"
#include	"acrepdef.h"
#include	"acrepmacros.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"nd.h"
#include	"nddef.h"
#include	"ndmacros.h"
#include	"msmacros.h"
#include	"parametric.h"
#include	"acdef.h"
#include	"acmacros.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"PDUerror.h"
#include	"ACdb_info.h"
#include	"expression.h"
#include	"expmacros.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"VDSpathdef.h"
#include	"VDSutil.h"

#include	"vdAPIequips.h"
#include	"vdmacprotos.h"

from	ACcpx	import	ACfind_exp_temp_obj;
from	NDnode	import	NDchange_connect;

/* ************************************************************************** */
IGRlong	VDmodifyMacro (		IGRlong		*msg,
			struct	VDcollector	*OccCol,
				IGRint		TplNum,
			struct	VDcollector	TplCol[],
				IGRint		immediate	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i, suc=1, cn_type=ND_COMP;
struct	GRid		OccId, *OldId, *NewId;

	/* Initialize */
	OldId = NULL;
	NewId = NULL;
	if ( (TplNum <= 0) || (TplCol == NULL) )	goto wrapup;

	/* Get macro occurence ID */
	sts = VDexpCollector ( msg, 1, OccCol );
	as$status ( sts    = sts,
		    msg    = "VDexpCollector()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	sts = vd$collectorGetRow ( msg = msg,
				   idx = 0,
				   Col = OccCol,
				   Obj = &OccId );
	as$status ( sts    = sts,
		    msg    = "vd$collectorGetRow(Obj 0)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Allocate memory */
	NewId = om$calloc ( num = TplNum, structure = struct GRid );
	OldId = om$calloc ( num = TplNum, structure = struct GRid );

	/* Expand template collector */
	sts = VDexpCollector ( msg, TplNum, TplCol );
	as$status ( sts    = sts,
		    msg    = "VDexpCollector()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Make source on template collector */
	sts = VDmakCollector ( msg, TplNum, TplCol );
	as$status ( sts    = sts,
		    msg    = "VDmakCollector()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Check types of template collector */
	sts = VDchkCollector ( msg, TplNum, TplCol );
	as$status ( sts    = sts,
		    msg    = "VDchkCollector()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Fill arrays */
	for ( i=0; i<TplNum; i++ ) {
		
		/* Fill NEW array */
		sts = VDgetCollRow ( msg, &TplCol[i], NULL, &NewId[i], NULL,
				     NULL, NULL, NULL, FALSE );
		as$status ( sts    = sts,
			    msg    = "VDgetCollRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Fill NEW array */
		sts = om$send ( msg = message ACcpx.ACfind_exp_temp_obj
					( &suc, i, &OldId[i] ),
				senderid = NULL_OBJID,
				targetid = OccId.objid,
				targetos = OccId.osnum );
		*msg = suc;
		as$status ( sts    = sts,
			    msg    = "ACcpx.ACfind_exp_temp_obj",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	/* Change templates */
	sts = om$send ( msg = message NDnode.NDchange_connect
					( TplNum, OldId, NewId ),
			senderid = NULL_OBJID,
			targetid = OccId.objid,
			targetos = OccId.osnum );
	as$status ( sts    = sts,
		    msg    = "NDnode.NDchange_connect",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Put the modified occurence in the batch */
	nd$wait_batch ( type	   = GR_GEOM_POSTED,
                        nb_obj     = 1,
                        l_object   = &OccId,
                        l_obj_info = &cn_type );

	/* Execute immediately */
	if (immediate == TRUE)	nd$exec_batch();

wrapup:
	if (OldId) {	om$dealloc (ptr = OldId);	OldId = NULL;	}
	if (NewId) {	om$dealloc (ptr = NewId);	NewId = NULL;	}
	return (sts);
}
/* ************************************************************************** */

end implementation Root;
