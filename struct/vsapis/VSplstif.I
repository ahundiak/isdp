/* $Id: VSplstif.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsapis/VSplstif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSplstif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/04/20  15:59:50  pinnacle
# CR179800807
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/02/20  23:45:40  pinnacle
# Created: ./vsapis/VSplstif.I by azuurhou for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *	     ef      Creation date
 * 02/27/98  ah      CR179800807 - Added Web Alignment Option
 *    "      ah      Copied pototype from vsAPImacros.h
 ***************************************************************************/

class implementation VSbeam ;

#include <stdio.h>
#include <string.h>
#include "nddef.h"
#include "madef.h"
#include "exmacros.h"
#include "ACcheckin.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "VDSsymb_def.h"
#include "vsdpb.h"
#include "vsstfnr.h"
#include "vsbeam.h"
#include "vsbmaxisdef.h"
#include "vsstfnrdef.h"
#include "vsplatedef.h"
#include "vsRDBmacros.h"
#include "vscmdmacros.h"
#include "vsbeammacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "vsnameproto.h"

#include "vsAPImacros.h"  // CR179800807

extern OMuword	OPP_VSbeamAxis_class_id;

extern long	VSgetHeightOfCrossSectionDef() ;

from VSbeamAxis import	VSgetConstructionType ;

long VSplace_stiffener( long			*msg,
		        struct GRid		*axisId,
			VSdspRep		representation,
			int			transtable,
			char			*basename,
			char			*directory,
			struct IGRdisplay	*display,
			short			level,
			char			*matType,
			char			*matGrade,
			char			*partFam,
			char			*partNum,
			char			*usrNotes,
			char			*mtoSrc,
			char			*mtoStk,
			double			fireProofing,
			int			mtoChgNo,
			char			*apprvStat,
			char			*constStat,
			int			mbrClass,
			int			mbrType,
			struct GRid		*UAid,
			double			xOffset,
			double			yOffset,
			double			rotAngle,
			enum VScardinal_point	cardPnt,
			enum VSsymmetry 	symmetry,
			int			alongPlane,
			int			topOfPlate,
			int			webAlign,
			struct GRid		*stiffenerId )
{

	/*
	 * This function is interfaced by macro 'vs$place_stiffener'.
	 */

	long			sts ;
	int			rc ;
	struct GRmd_env 	curEnv ;
	struct GRvg_construct	cstargs ;
	struct VScnst_list	vsargs ;
	VSstfnrAttr		stfnr ;
	VSbeamAttr		beam ;
	struct GRid		plateId;
	struct GRmd_env		plateEnv;
	struct GRobj_env	parents[2] ;
	struct GRid		cachedPart ;
	struct ACdb_info	checkin ;
	char			loc_directory[DI_PATH_MAX],
				loc_basename[DI_PATH_MAX],
				stiffener_name[DI_PATH_MAX],
				errStr[MS_MAX_MSG_LENGTH] ;
	short			loc_level ;
	struct IGRdisplay	loc_display ;
	int			cst_type ;
	struct VDSsymb		symb ;
	struct GRid		loc_UAid ;
	double			internalYOff ;

	SetProc( VSplace_stiffener ) ; Begin

	stiffenerId->objid = NULL_OBJID ;

	/*
	 * Check if the given axis is of class VSbeamAxis.
	 */
	if( !vs$is_ancestry_valid( object	= axisId,
				   classid	= OPP_VSbeamAxis_class_id ) )
		vs$inv_arg();

	/*
	 * Get current module environnement.
	 */
	sts = ex$get_cur_mod( osnum = &curEnv._MD_OS,
			      id    = &curEnv._MD_ID ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	curEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, curEnv._MATRIX ) ;

	/*
	 * Retrieve parent plate of stiffener axis.
	 */
	sts = om$send( msg	= message ACcpx.ACfind_temp_obj(
							       &rc,
							       VS_K_baPlateSupp,
							       &plateId ),
		       senderid = NULL_OBJID,
		       targetid = axisId->objid,
		       targetos = axisId->osnum ) ;
	*msg = rc & 1 ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup ) ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							"",
							&plateId,
							&plateEnv.md_env.matrix_type,
							plateEnv.md_env.matrix ),
		        senderid = NULL_OBJID,
			targetid= plateId.objid,
			targetos= plateId.osnum ) ;
	
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	plateEnv.md_id.osnum = plateId.osnum ;

	ex$get_modid( mod_osnum = plateEnv.md_id.osnum,
		      mod_id	= &plateEnv.md_id.objid ) ;

	/*
	 * If we want to use the transTable, retrieve informations to place the
	 * stiffener.
	 */
	if( transtable ) {
		sts = vs$getBmOrPlCstDefaults( msg	   = msg,
					       symb_id	   = curEnv.md_id,
					       symb	   = &symb,
					       memberClass = 0,
					       matchKey    = "stiffener",
					       matchId	   = &plateId,
					       path	   = loc_directory,
					       level	   = &loc_level,
					       display	   = &loc_display ) ;

		__CheckRC( sts, *msg, "vs$getBmOrPlCstDefaults", wrapup ) ;

	} else {
		strncpy( loc_directory, directory, DI_PATH_MAX ) ;
		loc_level   = level ;
		loc_display = *display ;
	}

	/*
	 * Fix stiffener representation.
	 */
	VSfixBeamRep( representation, &representation ) ;

	__DBGpr_str( "Directory",      loc_directory	  ) ;
	__DBGpr_int( "Level",	       loc_level	  ) ;
	__DBGpr_int( "Color",	       loc_display.color  ) ;
	__DBGpr_int( "Weight",	       loc_display.weight ) ;
	__DBGpr_int( "Style",	       loc_display.style  ) ;
	__DBGpr_int( "Representation", representation	  ) ;

	/*
	 * Generate name of stiffener.
	 */
	strcpy( loc_basename, basename ) ;
	strcat( loc_basename, "0" ) ;
	VSbuildName( msg, loc_directory, loc_basename, stiffener_name ) ;

	__DBGpr_str( "Stiffener name", stiffener_name ) ;

	/*
	 * Fill construction list.
	 */
	vs$fill_cnst_list( Env_info	= &curEnv,
			   Display	= &loc_display,
			   Level	= loc_level,
			   Name 	= stiffener_name,
			   Class_attr	= &vsargs,
			   Cnst_list	= cstargs,
			   Msg		= msg ) ;

	/*
	 * Add parents to construction list.
	 */
	vsargs.parent_count	= 2 ;
	vsargs.parent_list	= parents ;

	parents[0]._grid   = plateId ;
	parents[0].mod_env = plateEnv ;

	__DBGpr_obj( "Parent #0 (plate)", parents[0]._grid ) ;

	sts = om$send( msg	= message NDmacro.ACreturn_foot(
							      msg,
							      VS_K_baBmAxis,
							      &parents[1]._grid,
							      NULL,
							      NULL ),
		       senderid = NULL_OBJID,
		       targetid = axisId->objid,
		       targetos = axisId->osnum ) ;

	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	parents[1].mod_env = curEnv ;

	__DBGpr_obj( "Parent #1 (axis)", parents[1]._grid ) ;

	/*
	 * Load stiffener from RDB.
	 */
	vs$load_part_from_RDB( msg	= msg,
			       errStr	= errStr,
			       material = matType,
			       family	= partFam,
			       part	= partNum,
			       osnum	= curEnv._MD_OS,
			       object	= &cachedPart ) ;

	if( !( *msg & 1 ) ) {
		printf( "!!! place stiffener ERROR : %s\n", errStr ) ;
		goto wrapup ;
	}

	/*
	 * Calculate internal Y offset.
	 */
	if( symmetry == VS_e_XY_Symm || symmetry == VS_e_X_Symm  ) {
		sts = VSgetHeightOfCrossSectionDef( msg,
						    &cachedPart,
						    &curEnv,
						    &internalYOff ) ;

		__CheckRC( sts, *msg, "VSgetHeightOfCrossSectionDef", wrapup ) ;
	} else internalYOff = 0. ;

	/*
	 * Fill stiffener attributes.
	 */
	vsargs.representation	= representation ;
	vsargs.feature_att	= (char *) &stfnr ;

	if( UAid ) loc_UAid = *UAid ;
	else {
		   loc_UAid.osnum = curEnv._MD_OS ;
		   loc_UAid.objid = NULL_OBJID ;
	}

	sts = vs$fillBeamAttr(	msg		= msg,
				options 	= VS_m_All,
				partFam 	= partFam,
				matType 	= matType,
				matGrade	= matGrade,
				partNum 	= partNum,
				usrNotes	= usrNotes     ? usrNotes : "",
				mtoSrc		= mtoSrc       ? mtoSrc   : "",
				mtoStk		= mtoStk       ? mtoStk   : "",
				FireProofing	= fireProofing,
				mtoChgNo	= mtoChgNo,
				apprvStat	= apprvStat    ? apprvStat: "",
				constStat	= constStat    ? constStat: "",
				mbrClass	= mbrClass,
				mbrType 	= mbrType,
				usrAttrId	= &loc_UAid,
				xOffset 	= xOffset,
				yOffset 	= yOffset + internalYOff,
				RotAngle	= rotAngle,
				cardPnt 	= cardPnt,
				symmetry	= symmetry,
				partAttr	= &stfnr.attr,
				beamAttr	= &beam ) ;

	__CheckRC( sts, *msg, "vs$fillBeamAttr", wrapup ) ;

	if( topOfPlate ) stfnr.onWhichSideOfPlate = VS_K_baOnTopOfPlate ;
	else		 stfnr.onWhichSideOfPlate = VS_K_baOnBotOfPlate ;

	if( alongPlane ) {
		sts = om$send( msg	=
				       message VSbeamAxis.VSgetConstructionType(
								    msg,
								    &cst_type ),
			       senderid = NULL_OBJID,
			       targetid = axisId->objid,
			       targetos = axisId->osnum ) ;

		__CheckRC( sts, *msg, "VSbeamAxis.VSgetConstructionType",
			   wrapup ) ;

		if( cst_type == VS_K_baIntersection )
			stfnr.constructType = VS_K_stUseSurfOfPrj ;
		else	stfnr.constructType = VS_K_stNormalToSide ;

	} else stfnr.constructType = VS_K_stNormalToSide ;

/* CR179800807 Web Alignment */
if (webAlign) {
  stfnr.attr.Iwant & = ~VS_m_detCard ;
}
	/*
	 * Construct the stiffener.
	 */
	stiffenerId->osnum = curEnv._MD_OS ;

	sts = om$construct( classname = "VSstfBeam",
			    osnum     = stiffenerId->osnum,
			    p_objid   = &stiffenerId->objid,
			    msg       =
				  message GRgraphics.GRconstruct( &cstargs ) ) ;

	__CheckRC( sts, *msg, "om$construct", wrapup ) ;

	__DBGpr_obj( "Constructed stiffener", *stiffenerId ) ;

	/*
	 * Store PDU check-in information.
	 */
	strcpy( checkin.catalog , "vssrcbeam" ) ;
	strcpy( checkin.part_num, "vssrcbeam" ) ;
	strcpy( checkin.revision, "1" ) ;
	strcpy( checkin.usage	, "..." ) ;
	checkin.quantity = STRUCT_BEAM_OBJ ;

	om$send( msg	  = message ACdb_info.ACset_db_info( msg,
							     &checkin ),
		 senderid = NULL_OBJID,
		 targetid = stiffenerId->objid,
		 targetos = stiffenerId->osnum ) ;

	/*
	 * Display stiffener.
	 */
	vs$bulk_display( grids	= stiffenerId,
			 theEnv = &curEnv ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( stiffenerId->objid != NULL_OBJID )
				vs$bulk_delete( grids  = stiffenerId,
						theEnv = &curEnv ) ;
		}

		End
		return sts ;

} /* VSplace_stiffener */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
