/* $Id: VSjngetobjdf.I,v 1.1.1.1 2001/01/04 21:10:47 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsjoint/VSjngetobjdf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSjngetobjdf.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:47  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/11/14  12:11:50  pinnacle
# Replaced: vsjoint/VSjngetobjdf.I for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSjoint ;

#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "grerr.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

	long		sts ;	/* OM return code	*/
	/*
	 * Graphic foot's name.
	 */
	static char	*oNames[] = {	VS_K_jnGrCmpName },
	/*
	 * Virtual feet's names.
	 */
		*vNames[] = {
			VS_K_jnWldCodAttr,	/* Weld code spec.	*/
			VS_K_jnWldPrcAttr,	/* Weld process		*/
			VS_K_jnWldInfAttr,	/* Weld info		*/
			VS_K_jnWldSidAttr,	/* Weld side		*/
			VS_D_jnAllwncAttr,	/* Joint weld size	*/
			VS_K_jnGrvAngAttr,	/* Groove angle		*/
			VS_K_jnPitchAttr,	/* Pitch		*/
			VS_K_jnIncrLnAttr,	/* Length of increments	*/
			VS_K_jnUsrSymAttr,	/* User symbol		*/
			VS_K_prUsrAttr,		/* Usr attr. collection	*/
			VS_K_jnWldPosAttr,      /* weld position        */
			VS_K_jnShrnkAttr,	/* shrinkage		*/
			VS_K_jnFieldWeld	/* field weld flag	*/
		} ;
	/*
	 * Virtual feet's types.
	 */
	static int	vTypes[] = {
			double_type,	/* Weld code spec.	*/
			double_type,	/* Weld process		*/
			double_type,	/* Weld info		*/
			double_type,	/* Weld side		*/
			double_type,	/* Joint allowance	*/
			double_type,	/* Groove angle		*/
			double_type,	/* Pitch		*/
			double_type,	/* Length of increments	*/
			text_type,	/* User symbol		*/
			gen_rg_collect,	/* Usr attr. collection	*/
			double_type,	/* weld position	*/
			double_type,	/* shrinkage		*/
			double_type	/* field weld flag	*/
	} ;

#define nbOutputs	1

	/*
	 * The template definitions are sub-class dependent and are not defined
	 * here.
	 */
	myDef->input.count = 0 ;

	/*
	 * Feet.
	 */
	myDef->output.count		= nbOutputs ;
	myDef->output.names		= oNames ;
	myDef->output.type.classids	= NULL ;

	/*
	 * Virtual feet.
	 */
	myDef->virtual.count		= sizeof vNames / sizeof *vNames ;
	__DBGpr_int( "Count of virtual feet", myDef->virtual.count ) ;
	myDef->virtual.names		= vNames ;
	myDef->virtual.type.types	= vTypes ;
	
	/*
	 * Template feet.
	 */
	myDef->i2o.count		= 0 ;
	myDef->i2o.type.types		= NULL ;
	myDef->i2o.names		= NULL ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

