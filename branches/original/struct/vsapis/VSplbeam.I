/* $Id: VSplbeam.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsapis/VSplbeam.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSplbeam.I,v $
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
# Revision 1.2  1996/05/06  15:27:20  pinnacle
# Replaced: vsapis/VSplbeam.I for:  by svkadamb for struct
#
# Revision 1.1  1996/02/20  23:45:28  pinnacle
# Created: ./vsapis/VSplbeam.I by azuurhou for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *           ef      Creation date
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
#include "vsbeam.h"
#include "vsRDBmacros.h"
#include "vscmdmacros.h"
#include "vsbeammacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsAPImacros.h"  // CR179800807

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "vsnameproto.h"

long VSplace_beam(	long			*msg,
			struct GRid		inputId[2],
			struct GRmd_env 	inputEnv[2],
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
			IGRboolean		displayFlag,
			enum GRdpmode		dpmode,
			int			webAlign,
			struct GRid		*beamId )
{

	/*
	 * This function is interfaced by macro 'vs$place_beam'.
	 */

	long			sts ;
	struct GRmd_env 	curEnv ;
	struct GRvg_construct	cstargs ;
	struct VScnst_list	vsargs ;
	VSpartAttr		part ;
	VSbeamAttr		beam ;
	struct GRobj_env	parents[2] ;
	struct GRid		cachedPart ;
	struct ACdb_info	checkin ;
	char			loc_directory[DI_PATH_MAX],
				loc_basename[DI_PATH_MAX],
				beam_name[DI_PATH_MAX],
				errStr[MS_MAX_MSG_LENGTH] ;
	short			loc_level ;
	struct IGRdisplay	loc_display ;
	struct VDSsymb		symb ;
	struct GRid		loc_UAid ;

	SetProc( VSplace_beam ) ; Begin

	beamId->objid = NULL_OBJID ;

	/*
	 * Get current module environnement.
	 */
	sts = ex$get_cur_mod( osnum = &curEnv._MD_OS,
			      id    = &curEnv._MD_ID ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	curEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, curEnv._MATRIX ) ;

	/*
	 * If we want to use the transTable, retrieve informations to place the
	 * beam.
	 */
	if( transtable ) {
		sts = vs$getBmOrPlCstDefaults( msg	   = msg,
					       symb_id	   = curEnv.md_id,
					       symb	   = &symb,
					       memberClass = 0,
					       matchKey    = "beam",
					       matchId	   = inputId +0,
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
	 * Fix beam representation.
	 */
	VSfixBeamRep( representation, &representation ) ;

	__DBGpr_str( "Directory",      loc_directory	  ) ;
	__DBGpr_int( "Level",	       loc_level	  ) ;
	__DBGpr_int( "Color",	       loc_display.color  ) ;
	__DBGpr_int( "Weight",	       loc_display.weight ) ;
	__DBGpr_int( "Style",	       loc_display.style  ) ;
	__DBGpr_int( "Representation", representation	  ) ;

	/*
	 * Generate name of beam.
	 */
	strcpy( loc_basename, basename ) ;
	strcat( loc_basename, "0" ) ;
	VSbuildName( msg, loc_directory, loc_basename, beam_name ) ;

	__DBGpr_str( "Beam name", beam_name ) ;

	/*
	 * Fill construction list.
	 */
	vs$fill_cnst_list( Env_info	= &curEnv,
			   Display	= &loc_display,
			   Level	= loc_level,
			   Name 	= beam_name,
			   Class_attr	= &vsargs,
			   Cnst_list	= cstargs,
			   Msg		= msg ) ;

	/*
	 * Add parents to construction list.
	 */
	vsargs.parent_count	= 2 ;
	vsargs.parent_list	= parents ;

	parents[0]._grid   = inputId[0] ;
	parents[0].mod_env = inputEnv[0] ;

	parents[1]._grid   = inputId[1] ;
	parents[1].mod_env = inputEnv[1] ;

	__DBGpr_obj( "Parent #0 (surface)", parents[0]._grid ) ;
	__DBGpr_obj( "Parent #1 (curve)",   parents[1]._grid ) ;

	/*
	 * Load beam from RDB.
	 */
	vs$load_part_from_RDB( msg	= msg,
			       errStr	= errStr,
			       material = matType,
			       family	= partFam,
			       part	= partNum,
			       osnum	= curEnv._MD_OS,
			       object	= &cachedPart ) ;

	if( !( *msg & 1 ) ) {
		printf( "!!! place beam ERROR : %s\n", errStr ) ;
		goto wrapup ;
	}

	/*
	 * Fill beam attributes.
	 */
	vsargs.representation	= representation ;
	vsargs.feature_att	= (char *) &part ;

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
				yOffset 	= yOffset,
				RotAngle	= rotAngle,
				cardPnt 	= cardPnt,
				symmetry	= symmetry,
				partAttr	= &part,
				beamAttr	= &beam ) ;

	__CheckRC( sts, *msg, "vs$fillBeamAttr", wrapup ) ;

/* CR179800807 Web Alignment */
if (webAlign) {
  part.Iwant & = ~VS_m_detCard ;
}
	/*
	 * Construct the beam.
	 */
	beamId->osnum = curEnv._MD_OS ;

	sts = om$construct( classname = "VSsrcBeam",
			    osnum     = beamId->osnum,
			    p_objid   = &beamId->objid,
			    msg       =
				  message GRgraphics.GRconstruct( &cstargs ) ) ;

	__CheckRC( sts, *msg, "om$construct", wrapup ) ;

	__DBGpr_obj( "Constructed beam", *beamId ) ;

	/*
	 * Store PDU check-in information.
	 */
	strcpy( checkin.catalog , "vssrcbeam" ) ;
	strcpy( checkin.part_num, "vssrcbeam" ) ;
	strcpy( checkin.revision, "1" ) ;
	strcpy( checkin.usage	, "..." ) ;
	checkin.quantity = partFam[0] != '#' ? STRUCT_BEAM_OBJ :
					       STRUCT_PLATE_OBJ ;

	om$send( msg	  = message ACdb_info.ACset_db_info( msg,
							     &checkin ),
		 senderid = NULL_OBJID,
		 targetid = beamId->objid,
		 targetos = beamId->osnum ) ;
	/*
	 * Display beam.
	 */
	if( displayFlag ) {
		vs$bulk_display( dpmode	= dpmode,
				 grids	= beamId,
				 theEnv = &curEnv ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( beamId->objid != NULL_OBJID )
				vs$bulk_delete( grids  = beamId,
						theEnv = &curEnv ) ;
		}

		End
		return sts ;

} /* VSplace_beam */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
