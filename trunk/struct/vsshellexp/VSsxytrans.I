/*
	I/STRUCT
*/
class implementation VSshellExp ;

#include <stdio.h>
#include <math.h>
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "nddef.h"
#include "msdef.h"
#include "vsshexpdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*
 * Includes of function prototypes.
 */

extern struct GRid	NULL_GRID ;

extern OMuword	OPP_ACrg_collect_class_id ;

from ACrg_collect import	ACmod_list_attribute,
				ACadd_list_attribute,
				ACget_attribute_at_index ;

/*----------------------------------------------------------------------------*/
method VSstore_y_translation( long		*msg ;
			      struct GRmd_env	*myEnv ;
			      double		yTrans )
{
	long			sts ;	   /* OM return code.		      */
	int			count ;    /* Count of parents. 	      */
	struct GRid		yTransID ; /* ACrg_collect where y translation*/
					   /* is stored.		      */
	struct ACrg_coll	colAttr ;  /* ACrg_collect attribute.	      */

	SetProc( VSshellExp_VSstore_y_translation ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "VSstore_y_translation" //, argfmt = "", args = ``
        );

	__DBGpr_dbl( "Y translation", yTrans ) ;

	strcpy( colAttr.name, VS_K_sxYTrans ) ;
	colAttr.desc.type	   = AC_ATTRIB_DOUBLE ;
	colAttr.desc.value.att_exp = yTrans ;

	/*
	 * If we have already an y translation, change the y translation value.
	 * Otherwise, create an ACrg_collect as parent and store the y
	 * translation value on it.
	 */
	if( me->flagAttr & VS_K_sxUseYTranslation ) {

		__DBGpr_com( "Change the y translation" ) ;

		sts = om$send( msg	= message NDnode.NDget_objects(
								    ND_ROOT,
								    NULL,
								    0,
								    NULL,
								    0,
								    OM_K_MAXINT,
								    &count ),
			       targetid = my_id ) ;

		*msg = sts & 1 ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;

		__DBGpr_int( "Count of parents", count ) ;

		sts = om$send( msg	= message NDnode.NDget_objects(
								      ND_ROOT,
								      &yTransID,
								      1,
								      NULL,
								      count-1,
								      count-1,
								      &count ),
			       targetid = my_id ) ;

		*msg = sts & 1 ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;

		__DBGpr_obj( "Y translation object", yTransID ) ;

		sts = om$send( msg	= message ACrg_collect.ACmod_list_attribute(
								     msg,
								     1,
								     &colAttr ),
			       targetid = yTransID.objid,
			       targetos = yTransID.osnum ) ;

		__CheckRC( sts, *msg, "ACrg_collect.ACmod_list_attribute", wrapup ) ;

	} else {

		yTransID.osnum = OM_Gw_current_OS ;
		yTransID.objid = NULL_OBJID ;

		sts = om$construct( classid = OPP_ACrg_collect_class_id,
				    osnum   = yTransID.osnum,
				    p_objid = &yTransID.objid ) ;

		*msg = sts & 1 ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "om$construct", wrapup ) ;

		__DBGpr_obj( "Y translation object", yTransID ) ;

		sts = om$send( msg	= message ACrg_collect.ACadd_list_attribute(
								     msg,
								     1,
								     &colAttr ),
			       targetid = yTransID.objid,
			       targetos = yTransID.osnum ) ;

		__CheckRC( sts, *msg, "ACrg_collect.ACadd_list_attribute", wrapup ) ;

		sts = om$send( msg	= message NDnode.NDconnect( 1,
								    &yTransID,
								    NULL_GRID,
								    ND_ADD ),
			       targetid = my_id ) ;

		__CheckRC( sts, *msg, "NDnode.NDconnect", wrapup ) ;

		me->flagAttr |= VS_K_sxUseYTranslation ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) &&
		    !( me->flagAttr & VS_K_sxUseYTranslation ) )
			vs$bulk_delete( count = 1,
					grids = &yTransID,
					theEnv= myEnv ) ;

        __exitMethod ( name = "VSstore_y_translation", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End

		return sts ;

} /* VSstore_y_translation */
/*----------------------------------------------------------------------------*/
method VSget_y_translation( long		*msg ;
			    struct GRmd_env	*myEnv ;
			    double		*yTrans )
{
	long			sts ;	   /* OM return code.		      */
	int			count ;    /* Count of parents. 	      */
	struct GRid		yTransID ; /* ACrg_collect where y translation*/
					   /* is stored.		      */
	struct ACrg_coll	colAttr ;  /* ACrg_collect attribute.	      */

	SetProc( VSshellExp_VSget_y_translation ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "VSget_y_translation" //, argfmt = "", args = ``
        );

	*yTrans = 0. ;

	if( me->flagAttr & VS_K_sxUseYTranslation ) {

		__DBGpr_com( "Retrieve y translation object" ) ;

		sts = om$send( msg	= message NDnode.NDget_objects(
								    ND_ROOT,
								    NULL,
								    0,
								    NULL,
								    0,
								    OM_K_MAXINT,
								    &count ),
			       targetid = my_id ) ;

		*msg = sts & 1 ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;

		sts = om$send( msg	= message NDnode.NDget_objects(
								    ND_ROOT,
								    &yTransID,
								    1,
								    NULL,
								    count-1,
								    count-1,
								    &count ),
			       targetid = my_id ) ;

		*msg = sts & 1 ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;

		__DBGpr_obj( "Y translation object", yTransID ) ;

		sts = om$send( msg	= message ACrg_collect.ACget_attribute_at_index(
								     msg,
								     0,
								     &colAttr ),
			       targetid = yTransID.objid,
			       targetos = yTransID.osnum ) ;

		__CheckRC( sts, *msg, "ACrg_collect.ACget_attribute_at_index",
			   wrapup ) ;

		*yTrans = colAttr.desc.value.att_exp *
			  sqrt( myEnv->_MATRIX[0] * myEnv->_MATRIX[0] +
				myEnv->_MATRIX[4] * myEnv->_MATRIX[4] +
				myEnv->_MATRIX[8] * myEnv->_MATRIX[8] ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		__DBGpr_dbl( "Y translation", *yTrans ) ;

        __exitMethod ( name = "VSget_y_translation", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End
		return sts ;

} /* VSget_y_translation */
/*----------------------------------------------------------------------------*/

end implementation VSshellExp ;
