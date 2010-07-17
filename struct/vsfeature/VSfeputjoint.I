/* $Id: VSfeputjoint.I,v 1.1.1.1 2001/01/04 21:10:37 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsfeature/VSfeputjoint.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSfeputjoint.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/01/02  12:14:48  pinnacle
# Replaced: vsfeature/VSfeputjoint.I for:  by svkadamb for struct
#
# Revision 1.3  1997/11/19  08:06:38  pinnacle
# Replaced: vsfeature/VSfeputjoint.I for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  12:50:10  pinnacle
# Replaced: vsfeature/VSfeputjoint.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "EMSmsgdef.h"
#include "expression.h"
#include "expmacros.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

extern long	VSmakeJointName() ;
extern OMuword	OPP_VSsrcJoint_class_id ;
/*----------------------------------------------------------------------------*/
method VSputJoint(	long			*msg ;
			struct GRmd_env		*myEnv ;
			struct GRobj_env	*otherFeature ;
			struct GRobj_env	*jnCurve ;
			VSdspRep		jointRep ;
			struct GRvg_construct	*cst ;
			char			*jnDir ;
			struct GRid		*joint  ) {

	long			sts ;		/* OM return code	*/
	struct VScnst_list	vsargs ;	/* Feature arguments	*/
	struct GRobj_env	parents[3] ;	/* Parents of joint	*/
	VSjointAttr		*attr ;		/* Attributes of joint	*/
	GRname			name ;		/* Name of joint	*/
	char			*saveName ;	/* Saving `cst->name'	*/

	/*
	 * >> SHOULD CHECK HERE IF FEATURES NOT ALREADY JOINED
	 */
	joint->osnum = cst->env_info->_MD_OS ;
	sts = om$construct(	classid	= OPP_VSsrcJoint_class_id,
				osnum	= joint->osnum,
				p_objid	= &joint->objid ) ;
	if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;

	attr = (VSjointAttr *) cst->class_attr ;

	/*
	 * NOTE: `cst->name' does not contain a name for the joint but a
	 * directory where joint will automatically name itself using its
	 * parents' names.
	 */
	saveName		= cst->name ;
	parents[0]._objid	= my_id ;
	parents[0]._osnum	= OM_Gw_current_OS ;
	parents[0].mod_env	= *myEnv ;
	parents[1]		= *otherFeature ;
	if( jnCurve ) {
		parents[2]		= *jnCurve ;
		vsargs.parent_count	= 3 ;
	} else {
		vsargs.parent_count	= 2 ;
	}
	vsargs.parent_list	= parents ;
	vsargs.representation	= jointRep ;
	vsargs.feature_att	= (char *) attr ;
	cst->class_attr		= (char *) &vsargs ;
	cst->name		= name ;

	if( jnDir && *jnDir ) {
		VSmakeJointName( msg, &parents[0]._grid, &parents[1]._grid,
				 jnDir, name ) ;
	} else {
		*name = '\0' ;
	}

	sts = om$send(	msg	= message GRgraphics.GRconstruct( cst ),
			targetid= joint->objid,
			targetos= joint->osnum ) ;

	*msg = *cst->msg ;
	cst->class_attr = (char *) attr ;
	cst->name	= saveName ;

	__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

	wrapup	:
		/*
		 * If construction failed, joint has deleted itself.
		 */
		if( !( sts & 1 & *msg ) ) joint->objid = NULL_OBJID ;
		return sts ;

} /* method VSputJoint */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

