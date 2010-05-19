/* $Id: Windows.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdmeasure/func/Windows.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: Windows.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/11/08  21:52:06  pinnacle
# Created: vdmeasure/func/Windows.I by v241_int for vds.241
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/08/96        mf              creation date
 ***************************************************************************/

class implementation Root;

#include        <stdio.h>
#include        <string.h>
#include        "OMminimum.h"
#include        "OMerrordef.h"
#include        "OMprimitives.h"
#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "msdef.h"
#include        "AS_status.h"
#include        "DIdef.h"
#include        "gr.h"
#include        "igrdp.h"
#include        "go.h"
#include        "growner.h"
#include        "exdef.h"
#include        "ex.h"
#include        "griodef.h"
#include        "grio.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "dpstruct.h"

#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"

#include        "vdAPIequips.h"
#include        "vdmeasure.h"
#include        "vdmeaprotos.h"

/* ************************************************************************** */
IGRlong	VDgetDefaultView (		IGRlong		*msg,
					GRspacenum	ActiveOs,
				struct	GRid		*win	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRchar		path[DI_PATH_MAX];
	IGRint		num=0;
	DIgrid		*grid;

	/* Initialize */
	*msg = MSFAIL;
	win->objid = NULL_OBJID;
	win->osnum = ActiveOs;
	grid = NULL;

	/* Get active file name */
	sts = di$give_pathname ( osnum = ActiveOs, pathname = path );
	as$status ( sts    = sts,
                    msg    = "di$translate()",
                    test   = (sts != DIR_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Build path to views */
	sprintf ( path, "%s:views:regviews:GRviews", path );

	/* Find views number */
	sts = di$find ( start_dir	= path,
			ptr		= &num,
			max_level	= 1,
			options		= OPT_LEVEL );
	as$status ( sts    = sts,
                    msg    = "di$translate()",
                    test   = (sts != DIR_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory */
	if (num > 0)	grid = om$calloc ( num = num, structure = DIgrid );
	else		goto wrapup;

	/* Find views ID */
	sts = di$find ( start_dir	= path,
			grids		= &grid,
			ptr		= &num,
			max_level	= 1,
			options		= OPT_LEVEL );
	as$status ( sts    = sts,
                    msg    = "di$translate()",
                    test   = (sts != DIR_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Output first view */
	win->osnum = grid[0].osnum;
	win->objid = grid[0].objid;

	/* Set success */
	*msg = MSSUCC;

wrapup:
	if (grid != NULL)
		{	om$dealloc (ptr = grid);	grid = NULL;	}
	return (sts);
}
/* ************************************************************************** */

end implementation Root;
