/* $Id: VSmdstif.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSmdstif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSmdstif.I,v $
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
# Revision 1.1  1996/02/20  23:45:10  pinnacle
# Created: ./vsapis/VSmdstif.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *      04/17/98        suresh          CR179800807 - Added Web Alignment Option
 ***************************************************************************/

class implementation VSbeam ;

#include <stdio.h>
#include <string.h>
#include "madef.h"
#include "exmacros.h"
#include "msdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vsbmaxisdef.h"
#include "vsstfnrdef.h"
#include "vsqryrdbdef.h"
#include "vsRDBmacros.h"
#include "vsbeammacros.h"
#include "vsmiscmacros.h"
#include "vsAPImacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "vsgetaxofstf.h"

from VSbeamAxis import	VSgetConstructionType ;
from VSstfBeam	import	VSputConstructionType ;

extern long	VSgetHeightOfCrossSectionDef() ;

#define VS_m_Representation	0x010000000
#define VS_m_AlongPlane 	0x020000000

#define SET_OPTION( value, mask ) if( (value) ) options |= VS_m_##mask ;

/*----------------------------------------------------------------------------*/
long VSmodify_stiffener( long			*msg,
			 struct GRid		*stiffenerId,
			 VSdspRep		*representation,
			 char			*matType,
			 char			*matGrade,
			 char			*partFam,
			 char			*partNum,
			 char			*usrNotes,
			 char			*mtoSrc,
			 char			*mtoStk,
			 double			*fireProofing,
			 int			*mtoChgNo,
			 char			*apprvStat,
			 char			*constStat,
			 int			*mbrClass,
			 int			*mbrType,
			 struct GRid		*UAid,
			 double			*xOffset,
			 double			*yOffset,
			 double			*rotAngle,
			 enum VScardinal_point	*cardPnt,
			 enum VSsymmetry	*symmetry,
			 int			*alongPlane,
			 int			webAlign )
{

	/*
	 * This function is interfaced by macro 'vs$modify_stiffener'.
	 */

	long			sts ;
	int			options,
				needRecompute,
				cst_type,
				mode ;
	struct GRmd_env 	curEnv ;
	VSpartAttr		part ;
	VSbeamAttr		beam ;
	struct GRid		cachedPart,
				beamAxis ;
	char			material[VS_K_MAXDBNAME],
				family[VS_K_MAXDBNAME],
				partnum[VS_K_MAXDBNAME],
				errStr[MS_MAX_MSG_LENGTH] ;
	double			yoffset,
				internalYOff ;
	int			yoffMustPut = FALSE ;

	SetProc( VSmodify_stiffener ) ; Begin

	__DBGpr_obj( "Stiffener to modify", *stiffenerId ) ;

	/*
	 * Get current module environnement.
	 */
	sts = ex$get_cur_mod( osnum = &curEnv._MD_OS,
			      id    = &curEnv._MD_ID ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	curEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, curEnv._MATRIX ) ;

	/*
	 * Retrieve attributes of stiffener.
	 */
	part.Iwant	= VS_m_All ;
	part.specific	= (void *) &beam ;

	sts = om$send( msg	= message VSbeam.GRgetattr( msg,
							    (char *) &part ),
		       senderid = NULL_OBJID,
		       targetid = stiffenerId->objid,
		       targetos = stiffenerId->osnum ) ;

	__CheckRC( sts, *msg, "VSbeam.GRgetattr", wrapup ) ;

	/*
	 * Save material, family and part local attributes.
	 */
	strcpy( material, part.info.material ) ;
	strcpy( family,   part.info.family   ) ;
	strcpy( partnum,  part.info.partNum  ) ;

	/*
	 * Set option to fill stiffener attributes.
	 */
	options = 0 ;

	SET_OPTION( representation,	Representation	) ;
	SET_OPTION( matType,		MatType 	) ;
	SET_OPTION( matGrade,		MatGrade	) ;
	SET_OPTION( partFam,		PartFam 	) ;
	SET_OPTION( partNum,		PartNum 	) ;
	SET_OPTION( usrNotes,		Notes		) ;
	SET_OPTION( mtoSrc,		MtoSrc		) ;
	SET_OPTION( mtoStk,		MtoStk		) ;
	SET_OPTION( fireProofing,	FpThck		) ;
	SET_OPTION( mtoChgNo,		ChgNum		) ;
	SET_OPTION( apprvStat,		AppStat 	) ;
	SET_OPTION( constStat,		CstStat 	) ;
	SET_OPTION( mbrClass,		MbrClass	) ;
	SET_OPTION( mbrType,		MbrType 	) ;
	SET_OPTION( UAid,		UsrAttr 	) ;
	SET_OPTION( xOffset,		xOffset 	) ;
	SET_OPTION( yOffset,		yOffset 	) ;
	SET_OPTION( rotAngle,		RotAngle	) ;
	SET_OPTION( cardPnt,		cardPnt 	) ;
	SET_OPTION( symmetry,		Symmetry	) ;
	SET_OPTION( alongPlane, 	AlongPlane	) ;

	__DBGpr_int( "Option", options ) ;

	__DBGpr_com( "Modify following attributes :" ) ;
#ifdef vsDEBUG
	if( options & VS_m_Representation ) printf( "\t\tRepresentation\n" ) ;
	if( options & VS_m_MatType	  ) printf( "\t\tMatType\n"	   ) ;
	if( options & VS_m_MatGrade	  ) printf( "\t\tMatGrade\n"	   ) ;
	if( options & VS_m_PartFam	  ) printf( "\t\tPartFam\n"	   ) ;
	if( options & VS_m_PartNum	  ) printf( "\t\tPartNum\n"	   ) ;
	if( options & VS_m_Notes	  ) printf( "\t\tNotes\n"	   ) ;
	if( options & VS_m_MtoSrc	  ) printf( "\t\tMtoSrc\n"	   ) ;
	if( options & VS_m_MtoStk	  ) printf( "\t\tMtoStk\n"	   ) ;
	if( options & VS_m_FpThck	  ) printf( "\t\tFpThck\n"	   ) ;
	if( options & VS_m_ChgNum	  ) printf( "\t\tChgNum\n"	   ) ;
	if( options & VS_m_AppStat	  ) printf( "\t\tAppStat\n"	   ) ;
	if( options & VS_m_CstStat	  ) printf( "\t\tCstStat\n"	   ) ;
	if( options & VS_m_MbrClass	  ) printf( "\t\tMbrClass\n"	   ) ;
	if( options & VS_m_MbrType	  ) printf( "\t\tMbrType\n"	   ) ;
	if( options & VS_m_UsrAttr	  ) printf( "\t\tUsrAttr\n"	   ) ;
	if( options & VS_m_xOffset	  ) printf( "\t\txOffset\n"	   ) ;
	if( options & VS_m_yOffset	  ) printf( "\t\tyOffset\n"	   ) ;
	if( options & VS_m_RotAngle	  ) printf( "\t\tRotAngle\n"	   ) ;
	if( options & VS_m_cardPnt	  ) printf( "\t\tcardPnt\n"	   ) ;
	if( options & VS_m_Symmetry	  ) printf( "\t\tSymmetry\n"	   ) ;
	if( options & VS_m_AlongPlane	  ) printf( "\t\tAlongPlane\n"	   ) ;
#endif

	/*
	 * Remove internal Y offset from Y offset if needed.
	 */
	if( ( options & ~( VS_m_Representation | VS_m_AlongPlane )  ) &&
	    ( beam.sym == VS_e_XY_Symm || beam.sym == VS_e_X_Symm   ) ) {

		vs$load_part_from_RDB( msg	= msg,
				       errStr	= errStr,
				       material = material,
				       family	= family,
				       part	= partnum,
				       osnum	= curEnv._MD_OS,
				       object	= &cachedPart ) ;

		if( !( *msg & 1 ) ) {
			printf( "!!! modify stiffener ERROR : %s\n", errStr ) ;
			goto wrapup ;
		}

		sts = VSgetHeightOfCrossSectionDef( msg,
						    &cachedPart,
						    &curEnv,
						    &internalYOff ) ;

		__CheckRC( sts, *msg, "VSgetHeightOfCrossSectionDef", wrapup ) ;

		__DBGpr_dbl( "Old Y offset", beam.yoff ) ;

		beam.yoff -= internalYOff ;

		__DBGpr_dbl( "Remove internal Y offset", internalYOff ) ;

		yoffMustPut = TRUE ;
	}

	yoffset = beam.yoff ;

	/*
	 * Modify stiffener attributes if needed.
	 */
	if( options & ~( VS_m_Representation | VS_m_AlongPlane ) ) {
		sts = vs$fillBeamAttr( msg	    = msg,
				       options	    = options &
						      ~( VS_m_Representation |
							 VS_m_AlongPlane ),
				       partFam	    = partFam,
				       matType	    = matType,
				       matGrade     = matGrade,
				       partNum	    = partNum,
				       usrNotes     = usrNotes,
				       mtoSrc	    = mtoSrc,
				       mtoStk	    = mtoStk,
				       FireProofing = fireProofing ?
						      *fireProofing	: NULL,
				       mtoChgNo     = mtoChgNo	   ?
						      *mtoChgNo 	: NULL,
				       apprvStat    = apprvStat,
				       constStat    = constStat,
				       mbrClass     = mbrClass	   ?
						      *mbrClass 	: NULL,
				       mbrType	    = mbrType	   ?
						      *mbrType		: NULL,
				       usrAttrId    = UAid,
				       xOffset	    = xOffset	   ?
						      *xOffset		: NULL,
				       yOffset	    = yOffset	   ?
						      *yOffset		: NULL,
				       RotAngle     = rotAngle	   ?
						      *rotAngle 	: NULL,
				       cardPnt	    = cardPnt	   ?
						      *cardPnt	: VS_e_UPP_LEFT,
				       symmetry     = symmetry	   ?
						      *symmetry : VS_e_No_Symm,
				       partAttr     = &part,
				       beamAttr     = &beam ) ;

		__CheckRC( sts, *msg, "vs$fillBeamAttr", wrapup ) ;
	}

	/*
	 * Modify material, family and part local attributes.
	 * We cannot use directly part.info.material and other, because
	 * it set to NULL by vs$fillBeamAttr if it's not modified.
	 */
	if( options & VS_m_MatType ) strcpy( material, part.info.material ) ;
	if( options & VS_m_PartFam ) strcpy( family,   part.info.family   ) ;
	if( options & VS_m_PartNum ) strcpy( partnum,  part.info.partNum  ) ;
	if( options & VS_m_yOffset ) yoffset = beam.yoff ;

	/*
	 * Load stiffener from RDB if something changed.
	 */
	if( options & VS_m_PartFam					||
	    options & VS_m_MatType					||
	    options & VS_m_PartNum					||
	    ( (options & VS_m_Symmetry) &&
	      (beam.sym == VS_e_XY_Symm || beam.sym == VS_e_X_Symm) )	) {

		vs$load_part_from_RDB( msg	= msg,
				       errStr	= errStr,
				       material = material,
				       family	= family,
				       part	= partnum,
				       osnum	= curEnv._MD_OS,
				       object	= &cachedPart ) ;

		if( !( *msg & 1 ) ) {
			printf( "!!! modify stiffener ERROR : %s\n", errStr ) ;
			goto wrapup ;
		}
	}

	/*
	 * Restore internal Y offset to Y offset if needed.
	 */
	if( ( options & ~( VS_m_Representation | VS_m_AlongPlane )  ) &&
	    ( beam.sym == VS_e_XY_Symm || beam.sym == VS_e_X_Symm   ) ) {

		sts = VSgetHeightOfCrossSectionDef( msg,
						    &cachedPart,
						    &curEnv,
						    &internalYOff ) ;

		__CheckRC( sts, *msg, "VSgetHeightOfCrossSectionDef", wrapup ) ;

		yoffset += internalYOff ;

		__DBGpr_dbl( "New Y offset", yoffset ) ;

		__DBGpr_dbl( "Restore internal Y offset", internalYOff ) ;

		yoffMustPut = TRUE ;
	}

	if( yoffMustPut ) {
		beam.yoff   = yoffset ;
		part.Iwant |= VS_m_yOffset ;
	}

	/*
	 * See if the stiffener must recompute.
	 */
	needRecompute = options & ( VS_m_Representation |
				    VS_m_PartNum	|
				    VS_m_xOffset	|
				    VS_m_yOffset	|
				    VS_m_RotAngle	|
				    VS_m_cardPnt	|
				    VS_m_Symmetry	|
				    VS_m_AlongPlane	) ;

	__DBGpr_int( "Recompute stiffener ?", needRecompute ) ;

	/*
	 * Modify the stiffener.
	 */
	if( options & ~( VS_m_Representation | VS_m_AlongPlane ) ) {
		sts = om$send( msg	= message VSbeam.GRputattr(
							       msg,
							       (char *) &part ),
			       senderid = NULL_OBJID,
			       targetid = stiffenerId->objid,
			       targetos = stiffenerId->osnum ) ;

		__CheckRC( sts, *msg, "VSbeam.GRputattr", wrapup ) ;
	}
        if( webAlign ) {
                sts = om$send(msg = message ACncpx.ACchg_STATE(
                                                                VS_m_NdState,
                                                                VS_m_NdState ),
                                senderid = NULL_OBJID,
                                targetid= stiffenerId->objid,
                                targetos= stiffenerId->osnum );
        } else {
                sts = om$send(msg = message ACncpx.ACchg_STATE(
                                                                VS_m_NdState,
                                                                ND_DEFAULT ),
                                senderid = NULL_OBJID,
                                targetid= stiffenerId->objid,
                                targetos= stiffenerId->osnum );
        }

	if( options & VS_m_Representation ) {
		sts = om$send( msg	= message VSbeam.ACput_NV_rep(
							      *representation ),
			       senderid = NULL_OBJID,
			       targetid = stiffenerId->objid,
			       targetos = stiffenerId->osnum ) ;

		__CheckRC( sts, 1, "VSbeam.ACput_NV_rep", wrapup ) ;
	}

	if( options & VS_m_AlongPlane ) {
		sts = VSgetBeamAxisOfStiffener( msg,
						stiffenerId,
						&beamAxis ) ;

		__CheckRC( sts, *msg, "VSgetBeamAxisOfStiffener", wrapup ) ;

		sts = om$send( msg	=
				       message VSbeamAxis.VSgetConstructionType(
								    msg,
								    &cst_type ),
			       senderid = NULL_OBJID,
			       targetid = beamAxis.objid,
			       targetos = beamAxis.osnum ) ;

		__CheckRC( sts, *msg, "VSbeamAxis.VSgetConstructionType",
			   wrapup ) ;

		if( cst_type == VS_K_baIntersection ) {
			sts = om$send( msg	=
					  message VSfeature.VSforwardToOriginal(
					msg,
					OM_e_wrt_object,
					message VSstfBeam.VSputConstructionType(
							msg,
							*alongPlane ?
							VS_K_stUseSurfOfPrj :
							VS_K_stNormalToSide ) ),
				       senderid = NULL_OBJID,
				       targetid = stiffenerId->objid,
				       targetos = stiffenerId->osnum ) ;

			__CheckRC( sts, *msg, "VSstfBeam.VSputConstructionType",
				   wrapup ) ;
		}
	}

	/*
	 * Recompute the stiffener if needed.
	 */
	if( needRecompute ) {
		sts = om$send( msg	= message VSbeam.VSregenerate(),
			       senderid = NULL_OBJID,
			       targetid = stiffenerId->objid,
			       targetos = stiffenerId->osnum ) ;

		__CheckRC( sts, *msg, "VSbeam.VSregenerate", wrapup ) ;

		nd$mod_batch( request	 = ND_GET,
			      p_ret_mode = &mode ) ;

		if( mode != ND_DEFER ) nd$exec_batch() ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSmodify_stiffener */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
