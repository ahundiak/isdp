/* $Id: VDgrsetDel.I,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdgraphics/imp / VDgrsetDel.I
 *
 * Description:
 *     This file implements set functions used in I/VDS.
 *      its the implementation file for VDgrset.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgrsetDel.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:50  cvs
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
# Revision 1.6  1995/06/28  13:03:02  pinnacle
# Replaced: vdgraphics/imp/VDgrsetDel.I for:  by azuurhou for vds.240
#
# Revision 1.5  1995/06/19  13:27:46  pinnacle
# Replaced: vdgraphics/imp/VDgrsetDel.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/03/22  13:32:14  pinnacle
# Replaced: vdgraphics/imp/VDgrsetDel.I by azuurhou r#
#
# Revision 1.3  1994/12/29  21:51:18  pinnacle
# Replaced:  vdgraphics/imp/VDgrsetDel.I r#
#
# Revision 1.2  1994/11/30  21:19:30  pinnacle
# Replaced:  vdgraphics/imp r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/10/94        Chaya V. Rao
 *	06/17/95	adz		Delete drawing reference.
 *
 * --------------------------------------------------------------------------*/


/*===========================================================================*/

class implementation VDgrset;

#include <stdio.h>
#include "igetypedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "vdsetmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "AS_status.h"

/*===========================================================================*/
/*              function VDdelete_set -This function deletes a set           */
/*===========================================================================*/

int	 VDdelete_set( set_name )

char	*set_name;		/* i - name of set to be deleted */

{
IGRint			status;
IGRlong			msg;
struct	GRobj_env	set_grid;

	SetProc( VDdelete_set ); Begin 

	status = OM_S_SUCCESS ;
	msg    = MSSUCC ;

        set_grid.obj_id.objid = NULL_OBJID; 
	status = vd$setname_tobjenv( set_name = set_name, 
                                     VDset_grid = &set_grid
                                   );

	if ( (status == OM_S_SUCCESS) && (set_grid.obj_id.objid != NULL_OBJID) )
	{
		status =
		_VD_SEND_OBJN(	set_grid.obj_id,
				GRowner.GRdelete_owner( &msg,
							&set_grid.mod_env ));
	}

	End
	return( OM_S_SUCCESS );
}

/*============================================================================*/

end implementation VDgrset;
