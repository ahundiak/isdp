/* $Id: VDSetSuperi.I,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdgraphics/imp / VDSetSuperi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSetSuperi.I,v $
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
# Revision 1.3  1995/11/21  23:44:16  pinnacle
# Replaced: vdgraphics/imp/VDSetSuperi.I for:  by azuurhou for vds.240
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
 *      11/30/94        Chaya Rao       ope
 * -------------------------------------------------------------------*/

class implementation VDSetSuper;

#include "OMminimum.h"
/*#include "OMeveryone.h" */
#include "OMindex.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "igetypedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "madef.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "acdef.h"
#include "acmacros.h"
#include "grmessage.h"

#include "OMversion.h"
#include  "expression.h"
#include  "expmacros.h"

#define AS_DEBUG

%safe 
struct GRid VDsetmgr_grid = {0,(OM_S_OBJID)-1} ; 
%endsafe

from    VDsetmgr   import   VDclean_up;

/********************************************************************
  Construct if necessary a VDSetSuper object in the current directory
*********************************************************************/

void
VDSet_Super_construct()
{
OM_S_OBJID	super_id;
struct	GRid	mod;

	/*
	 * get the module environment 
	 */
	ex$get_cur_mod(	id	= &mod.objid,
			osnum	= &mod.osnum);

		/*
		 * call get super
		 */
		ex$get_super(	mod_id		= mod.objid,
	       			mod_osnum	= mod.osnum,
				super_name	= "VDsuperset",
				create		= TRUE,
				super_class	= "VDsetmgr",
				super_id	= &super_id );

		VDsetmgr_grid.objid = super_id;
		VDsetmgr_grid.osnum = mod.osnum;

#ifdef	DEBUG
		printf( "VDsetmgr_grid: %d,%d\n ",
				VDsetmgr_grid.objid,VDsetmgr_grid.osnum );
#endif
}

/*===========================================================================*/

method sleep( IGRint pos )
{
IGRlong			msg;
IGRint			status, size ;
struct	GRmd_env	md_env;

/*
 * clean up empty sets
 */
	size = sizeof ( struct GRmd_env );
	status =
	gr$get_module_env(	msg	= & status,
				sizbuf	= & size,
				buffer	= & md_env,
				nret	= & size );

        status =
	om$send(msg 	 = message VDsetmgr.VDclean_up( &msg, &md_env ),
                targetid = VDsetmgr_grid.objid,
                targetos = VDsetmgr_grid.osnum );


        return( OM_S_SUCCESS );
}

/*============================================================================*/


end implementation VDSetSuper;
