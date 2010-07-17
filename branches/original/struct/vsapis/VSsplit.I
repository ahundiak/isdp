/* $Id: VSsplit.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSsplit.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSsplit.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/02/20  23:45:48  pinnacle
# Created: ./vsapis/VSsplit.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *
 ***************************************************************************/

class implementation VSfeature ;

#include <stdio.h>
#include "madef.h"
#include "exmacros.h"
#include "EMSmsgdef.h"
#include "vsattr.h"
#include "vsplate.h"
#include "vsbeam.h"
#include "vsjoint.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"

extern void	VSbuildNameInSameDirIfPossible(),
		VSfitNamesInString() ;

extern OMuword	OPP_GRcurve_class_id,
		OPP_EMSplane_class_id,
		OPP_VSsubPlate_class_id,
		OPP_VSsubBeam_class_id ;

from VSdivFeature 	import VSget_sub_features ;

/*----------------------------------------------------------------------------*/
static long VSsplit_element( msg,
			     elemId,
			     elemEnv,
			     bm0_pl1,
			     cutterId,
			     cutterEnv,
			     splitId )

long			*msg ;
struct GRid		*elemId ;
struct GRmd_env		*elemEnv ;
int			bm0_pl1 ;
struct GRid		*cutterId ;
struct GRmd_env		*cutterEnv ;
struct GRid		splitId[2] ; {

	long			sts ;
	int			count ;
	struct GRmd_env 	curEnv ;
	struct GRvg_construct	cst ;
	struct VScnst_list	attr ;
	VSpartAttr		part ;
	VSplateAttr		plate ;
	VSbeamAttr		beam ;
	VSdivArgs		dvargs ;
	VSjoinInfo		jnInfo ;
	struct GRobj_env	parents[2] ;
	char			name[DI_PATH_MAX] ;
#define MAX_ABBRV	17
	char			info[MAX_ABBRV*3+10] ;
	struct GRid		cstObject ;

	splitId[0].objid = NULL_OBJID ;
	splitId[1].objid = NULL_OBJID ;

	cstObject.objid = NULL_OBJID ;

	__DBGpr_obj( "Element to split", *elemId   ) ;
	__DBGpr_obj( "Cutter element",   *cutterId ) ;

	/*
	 * Get current module environnement.
	 */
	sts = ex$get_cur_mod( osnum = &curEnv._MD_OS,
			      id    = &curEnv._MD_ID ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	curEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, curEnv._MATRIX ) ;

	/*
	 * See if cutter element is a curve or a plane.
	 */
	if( !vs$is_ancestry_valid( object  = cutterId,
				   classid = OPP_GRcurve_class_id )	&&
	    !vs$is_ancestry_valid( object  = cutterId,
				   classid = OPP_EMSplane_class_id )	)
		vs$inv_arg() ;

	/*
	 * Fill construction list.
	 */
	vs$fill_cnst_list( Cnst_list	= cst,
			   Msg		= msg,
			   Env_info	= &curEnv,
			   Display	= NULL,
			   Level	= 0,
			   Name		= name,
			   Class_attr	= &attr ) ;

	parents[0]._grid   = *elemId ;
	parents[0].mod_env = *elemEnv ;

	parents[1]._grid   = *cutterId ;
	parents[1].mod_env = *cutterEnv ;

	attr.parent_count	= 2 ;
	attr.parent_list	= parents ;
	attr.representation	= AC_NO_REP ;
	attr.feature_att	= (char *) &dvargs ;

	dvargs.subFeatureAttr	= (void *) &part ;

	if( bm0_pl1 )
		dvargs.subFeatureClassid = OPP_VSsubPlate_class_id ;
	else
		dvargs.subFeatureClassid = OPP_VSsubBeam_class_id ;
		
	dvargs.divInfo		= (void *) &jnInfo ;
	jnInfo.action		= VS_K_DO_NOT_JOIN ;
	jnInfo.dir		= NULL ;

	/*
	 * Get attribute of element because the sub-elements have the
	 * same.
	 */ 
	part.Iwant	= VS_m_All ;
	if( bm0_pl1 )
		part.specific	= (void *) &plate ;
	else
		part.specific	= (void *) &beam ;

	sts = om$send( msg	= message GRvg.GRgetattr( msg,
							 (char *) &part ),
		       senderid = NULL_OBJID,
		       targetid = parents[0]._objid,
		       targetos = parents[0]._osnum ) ;

	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	/*
	 * Sub-element #0 will have parent's name, generate a name for sub-element
	 * #1.
	 */
	sts = om$send( msg	= message GRvg.GRgetname( msg, name ),
		       senderid = NULL_OBJID,
		       targetid = parents[0]._objid,
		       targetos = parents[0]._osnum ) ;

	__CheckRC( sts, *msg, "GRvg.GRgetname", wrapup ) ;

	if( *name ) {
		char	save[DI_PATH_MAX] ;

		strcpy( save, name ) ;

		VSbuildNameInSameDirIfPossible(	curEnv._MD_OS,
						parents[0]._osnum,
						save,
						NULL,
						name ) ;

		VSfitNamesInString( MAX_ABBRV, save, save, name, info ) ;
	}

	/*
	 * Construct object.
	 */
	cstObject.osnum = curEnv._MD_OS ;

	sts = om$construct( classname = bm0_pl1 ? "VSsplPlate" : "VSpntBeam",
			    osnum     = cstObject.osnum,
			    p_objid   = &cstObject.objid,
			    msg	      = message GRgraphics.GRconstruct( &cst ) ) ;

	__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

	/*
	 * Retrieve sub-element then display them.
	 */
	sts = om$send( msg	= message VSdivFeature.VSget_sub_features(
									msg, 
									&count, 
									splitId ),
		       senderid = NULL_OBJID,
		       targetid = cstObject.objid,
		       targetos = cstObject.osnum ) ;

	__CheckRC( sts, *msg, "VSdivFeature.VSget_sub_features", wrapup ) ;

	vs$bulk_display( count	= 2,
			 grids	= splitId,
			 theEnv	= &curEnv ) ;

	__DBGpr_obj( "Result #0", splitId[0] ) ;
	__DBGpr_obj( "Result #1", splitId[1] ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( splitId[0].objid != NULL_OBJID ||
			    splitId[1].objid != NULL_OBJID )
				vs$bulk_delete( count  = 2,
						grids  = splitId,
						theEnv = &curEnv ) ;

			if( cstObject.objid != NULL_OBJID )
				vs$bulk_delete( grids  = &cstObject,
						theEnv = &curEnv ) ;
		}

		return sts ;

} /* VSsplit_element */
/*----------------------------------------------------------------------------*/
long VSsplit_plate( msg, plateId, plateEnv, cutterId, cutterEnv, splitId )

long		*msg ;
struct GRid	*plateId ;
struct GRmd_env	*plateEnv ;
struct GRid	*cutterId ;
struct GRmd_env	*cutterEnv ;
struct GRid	splitId[2] ; {

	long	sts ;

	SetProc( VSsplit_plate ) ; Begin

	sts = VSsplit_element( msg,
			       plateId,
			       plateEnv,
			       TRUE,
			       cutterId,
			       cutterEnv,
			       splitId ) ;

	End
	return sts ;

} /* VSsplit_plate */
/*----------------------------------------------------------------------------*/
long VSsplit_beam( msg, beamId, beamEnv, cutterId, cutterEnv, splitId )

long		*msg ;
struct GRid	*beamId ;
struct GRmd_env	*beamEnv ;
struct GRid	*cutterId ;
struct GRmd_env	*cutterEnv ;
struct GRid	splitId[2] ; {

	long	sts ;

	SetProc( VSsplit_beam ) ; Begin

	sts = VSsplit_element( msg,
			       beamId,
			       beamEnv,
			       FALSE,
			       cutterId,
			       cutterEnv,
			       splitId ) ;

	End
	return sts ;

} /* VSsplit_beam */
/*----------------------------------------------------------------------------*/
long VSsplit_stiffener( msg, stiffenerId, stiffenerEnv, cutterId, cutterEnv, splitId )

long		*msg ;
struct GRid	*stiffenerId ;
struct GRmd_env	*stiffenerEnv ;
struct GRid	*cutterId ;
struct GRmd_env	*cutterEnv ;
struct GRid	splitId[2] ; {

	long	sts ;

	SetProc( VSsplit_stiffener ) ; Begin

	sts = VSsplit_element( msg,
			       stiffenerId,
			       stiffenerEnv,
			       FALSE,
			       cutterId,
			       cutterEnv,
			       splitId ) ;

	End
	return sts ;

} /* VSsplit_stiffener */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
