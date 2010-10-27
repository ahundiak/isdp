/* $Id: ACcpx_symb.I,v 1.2 2001/01/18 19:08:43 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / ACcpx_symb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACcpx_symb.I,v $
 *	Revision 1.2  2001/01/18 19:08:43  ramarao
 *	Merged Service Pack Files to 262 pload.
 *	
# Revision 1.1  2000/04/21  22:24:32  pinnacle
# Created: vds/vdassoc/ACcpx_symb.I by rchennup for Service Pack
#
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

/*
 LLC 3 june 93
 fix macro occurrence symbology to escape expression and there dunny level.
*/
class implementation ACcpx;

#define AS_DEBUG


#include <limits.h>
#include "macro.h"
#include "acmacros.h"
#include "grownerdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "grownmacros.h"
#include "grerr.h"
#include "acrepdef.h"
#include "asbox.h"

extern GRclassid        OPP_ACrg_collect_class_id;

method GRgetsymb(IGRlong *msg; struct GRsymbology *symb)
{
IGRlong			sts;
int			i;
struct	GRid		CMP;
GRclassid		cls_id;

	*msg	= MSFAIL;
	sts	= OM_S_SUCCESS;

/*
 * code in EMS 3.0
 *
 *   IGRlong om_msg;
 *
 *   for(i=0;i<OM_K_MAXINT;i++)
 *   {
 *    om_msg = om$send(msg = message GRvg.GRgetsymb (msg, symb),
 *                   p_chanselect = &AC_mto_graf_chns,
 *                   from = i,
 *                   to = i);
 *
 *    if(om_msg != OM_W_UNKNOWN_MSG)
 *    {
 *     break;
 *    }
 *   }
 *   return( om_msg );
 */
	for( i=0; ; i++ ){

		sts = om$get_objid_at_index(
					objid		= my_id,
					p_chanselect	= &AS_to_comp,
					index		= i,
					objidaddr	= &CMP.objid,
					osnumaddr	= &CMP.osnum );
		if( ! (sts&1)){ *msg = MSFAIL; break; }

		// Exclude the ACrg_collect classes
                om$get_classid( objid     = CMP.objid,
                                osnum     = CMP.osnum,
                                p_classid = &cls_id );
                if(om$is_ancestry_valid ( subclassid = cls_id,
                   superclassid = OPP_ACrg_collect_class_id ) == OM_S_SUCCESS)
                continue;

		sts = om$send(	msg	 = message GRvg.GRgetsymb
						( msg, symb ),
				targetid = CMP.objid,
				targetos = CMP.osnum );
		if( sts & (*msg) & 1 ) 
			if( *msg != GR_I_NO_LAYER && symb->level != -1 )
				return	sts;
	}

	*msg	= MSFAIL;

return 	OM_S_SUCCESS;
}

end implementation ACcpx;
