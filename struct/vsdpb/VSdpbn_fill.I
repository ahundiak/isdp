/* $Id: VSdpbn_fill.I,v 1.1.1.1 2001/01/04 21:10:32 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsdpb/VSdpbn_fill.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdpbn_fill.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/11/14  13:33:48  pinnacle
# Created: vsdpb/VSdpbn_fill.I by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSdpbn ;

#include <stdio.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "msdef.h"		/* For MS...		*/
#include "igetypedef.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "gr.h"
#include "vsdbgmacros.h"

extern OMuword OPP_VSdpbn_class_id ;
/*----------------------------------------------------------------------------*/
int VSdpbn_fill( )
{
	OM_S_OBJID	mod_id ,
			p_dpb_id ;
	int		rc ;
	OMuword		p_dpb_os ;

	SetProc( VSdpbn_VSdpbn_fill ) ; Begin

	ex$get_cur_mod( osnum	= &p_dpb_os );

	rc = ex$get_super(      mod_id          = mod_id,
				mod_osnum       = p_dpb_os,
				super_name      = "STRUCTdpbn",
				super_class     = "VSdpbn",
				create          = TRUE,
				super_id        = &p_dpb_id ) ;
	if( rc & 1 )  {
		rc = TRUE ;
		p_dpb_id = NULL_OBJID ;
	} else {
		rc = FALSE ;
	}
	End 
	return rc ;
	
} /* VSdpbn_fill */
/*----------------------------------------------------------------------------*/end implementation VSdpbn ;
