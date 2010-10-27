/* $Id: showctx.I,v 1.1.1.1 2001/01/04 21:08:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddbg / showctx.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: showctx.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:33  cvs
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

class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"

method GRgetinstance(IGRlong *msg;IGRshort *type;IGRmatrix matrix;
	GRspacenum *osnum; IGRshort *flag; struct GRid *context_info)

{
    IGRlong i;				/* loop index			*/
    IGRlong OMmsg;			/* local return codes		*/
    IGRchar classname[100];


    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;

    for (i=0; i<16; ++i)
    {
	matrix[i] = me->matrix[i];
    }
    *type = me->mx_type;
    *osnum = me->osnum;
    *flag = me->flags;

    context_info->objid = my_id;
    context_info->osnum = OM_Gw_current_OS;


    OMmsg = om$get_classname(   osnum = context_info->osnum,
                                objid = context_info->objid,
                                classname = classname );
 
    printf(" CONTEXT: %d,%d >%s<\n",  my_id, OM_Gw_current_OS, classname );
    printf(" type : %d | osnum : %d | flag : %d \n", *type, *osnum, *flag);
    for(i=0;i<4;i++)
      printf(" %f %f %f %f \n", matrix[i*4], matrix[i*4+1], matrix[i*4+2],
				matrix[i*4+3] );


    return( OMmsg );
}
end implementation GRcontext;
