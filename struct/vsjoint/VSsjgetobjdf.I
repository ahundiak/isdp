/* $Id: VSsjgetobjdf.I,v 1.1.1.1 2001/01/04 21:10:48 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsjoint/VSsjgetobjdf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSsjgetobjdf.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:48  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.5  1998/01/06  04:18:32  pinnacle
# Replaced: vsjoint/VSsjgetobjdf.I for:  by svkadamb for struct
#
# Revision 1.4  1997/11/19  08:04:06  pinnacle
# Replaced: vsjoint/VSsjgetobjdf.I for:  by svkadamb for struct
#
# Revision 1.3  1997/11/18  13:52:00  pinnacle
# Replaced: vsjoint/VSsjgetobjdf.I for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  13:10:18  pinnacle
# Replaced: vsjoint/VSsjgetobjdf.I for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSsrcJoint ;

#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 5

	long		sts ;		/* OM return code		*/
	static char	*iNames  [nbInputs] = {	VS_K_jnFeature0,
						VS_K_jnFeature1,
						VS_K_prPrvAttr,
						VS_K_prUsrAttr,
						VS_K_jnGeometry		} ;

	static int	 iTypes  [nbInputs] = {	macro_generic,
						macro_generic,
						gen_rg_collect,
						gen_rg_collect,
						curve_generic		} ;

	sts = om$send(	msg	= message VSjoint.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	myDef->info			= VS_gI_Joint ;
	myDef->type			= VS_m_SRC_JOINT ;
	myDef->minInput			= 2 ;
	myDef->input.count		= nbInputs ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;

	myDef->i2o.count		= 0 ;
	myDef->i2o.names		= NULL ;
	myDef->i2o.type.types		= NULL ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSsrcJoint ;
