/* $Id: VDsetmgri.I,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdgraphics/imp / VDsetmgri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDsetmgri.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:50  cvs
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

/* I/VDS
 *
 * File:         ~VDS/VDS--/VDsetmgri.I
 *
 * Description:
 *      This file implements set messages used in I/VDS.
 *      its the implementation file for VDsetmgr.
 *
 * History:
 *      06/10/94        Chaya V. Rao
 *
 */
/*============================================================================*/

class implementation VDsetmgr;

#include	<stdio.h>

#include 	"OMerrordef.h"
#include	"igrtypedef.h"
#include        "AS_status.h"

from	VDgrset 	import	VDdelete_if_empty;

/** #define   DEBUG  1 **/

/*===========================================================================*/
/*          method VDclean_up  - sends a VDdelete_if_empty message to        */
/*                          all sets it is connected to                      */
/*===========================================================================*/

method VDclean_up(	long	*msg;		/* i/o - return status	*/
			struct GRmd_env *md_env /* i  - moduleInfo  	*/
    		)
{
long		status;
OM_S_CHANSELECT	GRcmpowner_to_connector_CS;

	*msg = MSSUCC;
        
        status =
        om$make_chanselect( channame      = "GRcmpowner.to_components",
                            p_chanselect  = &GRcmpowner_to_connector_CS
                          );
        as$status();

	status =
	om$send(msg	= message VDgrset.VDdelete_if_empty(	msg,
								md_env ),
                p_chanselect = &GRcmpowner_to_connector_CS );
        as$status();

	return( OM_S_SUCCESS );
}

/*===========================================================================*/

end implementation VDsetmgr;
