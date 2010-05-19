/* $Id: GRctxcheckct.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/grnuc/GRctxcheckct.I
 *
 * Description:
 *		Change the check of identical matrix.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: GRctxcheckct.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/03/01  14:17:00  pinnacle
# Replaced: emsfixes/grnuc/GRctx*.I for:  by impd252 for vds
#
# Revision 1.1  2000/02/20  19:35:20  pinnacle
# Created: emsfixes/grnuc/GRctxcheckct.I by impd252 for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRcheckctx - checks input context against instance 
		data
Synopsis
    	GRcheckctx(msg,type,matrix,osnum,context_id,same)
	
 	IGRlong	*msg		completion code
	IGRshort *type		matrix type
	IGRmatrix matrix	the environment matix
	GRspacenum *osnum	object space number of ref. file
	struct GRid *context_id this objects id and space number
	IGRboolean *same	indicator of whether context 
				matches

Description
	This method verifies if the input context information 
	is equal to the instance data of the GRcontext object.

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion context matched
	
	MSFAIL - error; context different
Notes
	None.

History
	MAS  	05/27/87 	Design date.

\*/

class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"

method GRcheckctx(IGRlong *msg;IGRshort *type;IGRmatrix matrix;
    GRspacenum *osnum; struct GRid *context_id; IGRboolean *same)

{
    IGRlong i;				/* loop index			*/
    IGRlong OMmsg;			/* local return codes		*/

#ifdef	DEBUG
	printf(" GRcheckctx : ENTER %d,%d \n", my_id, OM_Gw_current_OS );
#endif

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;
    *same = TRUE;

    if (( *type == me->mx_type) && ( *osnum == me->osnum))
    {
	context_id->objid = my_id;
	context_id->osnum = OM_Gw_current_OS;

#ifdef	DEBUG
		printf(" -- (1) ----- INVALID CHECK ------\n");
#endif
    	for (i=0; i<16 && *same; ++i)
    	{
	    if (me->matrix[i] != matrix[i])
	    {
		*msg = MSFAIL;
		OMmsg = OM_W_ABORT;
		*same = FALSE;
	    }
	}
	if (*same)
	{
	    OMmsg = OM_I_STOP_SENDING;
	}
    }
    else
    {
	*msg = MSFAIL;
	OMmsg = OM_W_ABORT;
	*same = FALSE;
    }

#ifdef	DEBUG
	printf(" GRcheckctx : EXIT %d,%d \n", my_id, OM_Gw_current_OS );
#endif

    return( OMmsg );
}
end implementation GRcontext;
