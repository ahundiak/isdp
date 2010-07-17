/* $Id: VSplplate.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSplplate.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSplplate.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/02/20  23:45:36  pinnacle
# Created: ./vsapis/VSplplate.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *
 ***************************************************************************/

class implementation VSplate ;

#include <stdio.h>
#include <string.h>
#include "madef.h"
#include "exmacros.h"
#include "ACcheckin.h"
#include "msdef.h"
#include "VDSsymb_def.h"
#include "vsRDBmacros.h"
#include "vscmdmacros.h"
#include "vsplatmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "vsnameproto.h"

/*----------------------------------------------------------------------------*/
long VSplace_plate( msg,
		    surfaceId,
		    surfaceEnv,
		    representation,
		    transtable,
		    basename,
		    directory,
		    display,
		    level,
		    matType,
		    matGrade,
		    partFam,
		    partNum,
		    usrNotes,
		    mtoSrc,
		    mtoStk,
		    fireProofing,
		    mtoChgNo,
		    apprvStat,
		    constStat,
		    mbrClass,
		    mbrType,
		    orientation,
		    cutOff,
		    offset,
		    thickness,
		    UAid,
		    plateId )

long			*msg ;
struct GRid		*surfaceId ;
struct GRmd_env 	*surfaceEnv ;
VSdspRep		representation ;
int			transtable ;
char			*basename ;
char			*directory ;
struct IGRdisplay	*display ;
short			level ;
char			*matType ;
char			*matGrade ;
char			*partFam ;
char			*partNum ;
char			*usrNotes ;
char			*mtoSrc ;
char			*mtoStk ;
double			fireProofing ;
int			mtoChgNo ;
char			*apprvStat ;
char			*constStat ;
int			mbrClass ;
int			mbrType ;
int			orientation ;
double			cutOff ;
double			offset ;
double			thickness ;
struct GRid		*UAid ;
struct GRid		*plateId ; {

	/*
	 * This function is interfaced by macro 'vs$place_plate'.
	 */

	long			sts ;
	struct GRobj_env	surface ;
	struct GRmd_env 	curEnv ;
	struct GRvg_construct	cstargs ;
	struct VScnst_list	vsargs ;
	VSpartAttr		part ;
	VSplateAttr		plate ;
	struct GRid		cachedPart ;
	struct ACdb_info	checkin ;
	char			loc_directory[DI_PATH_MAX],
				loc_basename[DI_PATH_MAX],
				plate_name[DI_PATH_MAX],
				errStr[MS_MAX_MSG_LENGTH] ;
	struct VDSsymb		symb ;
	short			loc_level ;
	struct IGRdisplay	loc_display ;
	struct GRid		loc_UAid ;

	SetProc( VSplace_plate ) ; Begin

	plateId->objid = NULL_OBJID ;

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
	 * plate.
	 */
	if( transtable ) {
		sts = vs$getBmOrPlCstDefaults( msg	   = msg,
					       symb_id	   = curEnv.md_id,
					       symb	   = &symb,
					       memberClass = 0,
					       matchKey    = "plate",
					       matchId	   = surfaceId,
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
	 * Fix plate representation.
	 */
	VSfixPlateRep( representation, &representation ) ;

	__DBGpr_str( "Directory",      loc_directory	  ) ;
	__DBGpr_int( "Level",	       loc_level	  ) ;
	__DBGpr_int( "Color",	       loc_display.color  ) ;
	__DBGpr_int( "Weight",	       loc_display.weight ) ;
	__DBGpr_int( "Style",	       loc_display.style  ) ;
	__DBGpr_int( "Representation", representation	  ) ;

	/*
	 * Generate name of plate.
	 */
	strcpy( loc_basename, basename ) ;
	strcat( loc_basename, "0" ) ;
	VSbuildName( msg, loc_directory, loc_basename, plate_name ) ;

	__DBGpr_str( "Plate name", plate_name ) ;

	/*
	 * Fill construction list.
	 */
	vs$fill_cnst_list( Env_info	= &curEnv,
			   Display	= &loc_display,
			   Level	= loc_level,
			   Name 	= plate_name,
			   Class_attr	= &vsargs,
			   Cnst_list	= cstargs,
			   Msg		= msg ) ;

	surface._grid	= *surfaceId ;
	surface.mod_env = *surfaceEnv ;

	vsargs.parent_count   = 1 ;
	vsargs.parent_list    = &surface ;
	vsargs.representation = representation ;
	vsargs.feature_att    = (char *) &part ;

	/*
	 * Fill plate attributes.
	 */
	if( UAid ) loc_UAid = *UAid ;
	else {
		   loc_UAid.osnum = curEnv._MD_OS ;
		   loc_UAid.objid = NULL_OBJID ;
	}

	sts = vs$fillPlateAttr( msg		= msg,
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
				orientation	= orientation,
				cutOff		= cutOff,
				offset		= offset,
				thickness	= thickness,
				usrAttrId	= &loc_UAid,
				partAttr	= &part,
				plateAttr	= &plate ) ;

	__CheckRC( sts, *msg, "vs$fillPlateAttr", wrapup ) ;

	/*
	 * Load plate from RDB.
	 */
	vs$load_part_from_RDB( msg	= msg,
			       errStr	= errStr,
			       material = matType,
			       family	= partFam,
			       part	= partNum,
			       osnum	= curEnv._MD_OS,
			       object	= &cachedPart ) ;

	if( !( *msg & 1 ) ) {
		printf( "!!! place plate ERROR : %s\n", errStr ) ;
		goto wrapup ;
	}

	/*
	 * Construct the plate.
	 */
	plateId->osnum = curEnv._MD_OS ;

	sts = om$construct( classname = "VSsrcPlate",
			    osnum     = plateId->osnum,
			    p_objid   = &plateId->objid,
			    msg       =
				  message GRgraphics.GRconstruct( &cstargs ) ) ;

	__CheckRC( sts, *msg, "om$construct", wrapup ) ;

	__DBGpr_obj( "Constructed plate", *plateId ) ;

	/*
	 * Store PDU check-in information.
	 */
	strcpy( checkin.catalog , "VSsrcPlate" ) ;
	strcpy( checkin.part_num, "VSsrcPlate" ) ;
	strcpy( checkin.revision, "1" ) ;
	strcpy( checkin.usage	, "..." ) ;
	checkin.quantity = STRUCT_PLATE_OBJ ;

	om$send( msg	  = message ACdb_info.ACset_db_info( msg,
							     &checkin ),
		 senderid = NULL_OBJID,
		 targetid = plateId->objid,
		 targetos = plateId->osnum ) ;

	/*
	 * Display plate.
	 */
	vs$bulk_display( grids	= plateId,
			 theEnv = &curEnv ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) && plateId->objid != NULL_OBJID )
			vs$bulk_delete( grids  = plateId,
					theEnv = &curEnv ) ;

		End
		return sts ;

} /* VSplace_plate */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
