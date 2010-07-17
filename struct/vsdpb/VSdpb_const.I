/* $Id: VSdpb_const.I,v 1.2 2001/02/14 20:57:23 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsdpb/VSdpb_const.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdpb_const.I,v $
 *	Revision 1.2  2001/02/14 20:57:23  ramarao
 *	Modification related to SetProc() macro.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:10:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1997/12/19  04:18:32  pinnacle
# Replaced: vsdpb/VSdpb_const.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSdpb ;

#include <stdio.h>
#include "OMerrordef.h"		/* For OM_S_SUCCESS	*/
#include "exdef.h"
#include "ex.h"
#include "igr.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "vswelddef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method super_construct() {

/*
 *	Sets the default values of the parameter block.
 */
	long			msg ;
	unsigned		size,
				nret ;
	struct GRdpb_text_symb	textAttr ;

	SetProc( super_construct ); Begin

	me->B_rotation		= me->B_x_offset	= me->B_y_offset
				= me->P_offset		= 0. ;

	me->flags.B_symmetry		= VS_e_No_Symm ;
	me->flags.B_cardinal_point	= VS_e_BOT_LEFT ;
	me->J_weldAttr.code		= VS_K_wldFillet ;
	me->J_weldAttr.process		= VS_K_wldUndefProc ;
	me->J_weldAttr.info		= 0 ;
	me->J_weldAttr.side		= VS_K_wldLeftSide ;
	me->J_allowance			= 0 ;
	me->flags.P_orientation		= FALSE ;
//	me->flags.massp_toggle		= FALSE ;
	me->flags.massp_toggle		= TRUE ;
	me->FireProofingThk		= 0 ;

	/*
	 * Initialize arrow size with active text height.
	 */
	size = sizeof textAttr ;
	gr$get_text_symb(	msg	= &msg,
				sizbuf	= &size,
				nret	= &nret,
				buffer	= &textAttr ) ;

	if( msg & 1 )	me->B_arw_size = textAttr.Active_height ;
	else		me->B_arw_size = -1 ;

	End
	return OM_S_SUCCESS ;

} /* method super_construct() */
/*----------------------------------------------------------------------------*/

end implementation VSdpb ;
