/* $Id: VSmdplate.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSmdplate.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSmdplate.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/02/20  23:45:06  pinnacle
# Created: ./vsapis/VSmdplate.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *
 ***************************************************************************/

class implementation VSplate ;

#include <stdio.h>
#include "exmacros.h"
#include "msdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vsRDBmacros.h"
#include "vsplatmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#define VS_m_Representation	0x010000000

#define SET_OPTION( value, mask ) if( (value) ) options |= VS_m_##mask ;

/*----------------------------------------------------------------------------*/
long VSmodify_plate( msg,
		     plateId,
		     representation,
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
		     UAid )

long			*msg ;
struct GRid		*plateId ;
VSdspRep		*representation ;
char			*matType ;
char			*matGrade ;
char			*partFam ;
char			*partNum ;
char			*usrNotes ;
char			*mtoSrc ;
char			*mtoStk ;
double			*fireProofing ;
int			*mtoChgNo ;
char			*apprvStat ;
char			*constStat ;
int			*mbrClass ;
int			*mbrType ;
int			*orientation ;
double			*cutOff ;
double			*offset ;
double			*thickness ;
struct GRid		*UAid ; {

	/*
	 * This function is interfaced by macro 'vs$modify_plate'.
	 */

	long			sts ;
	int			options,
				needRecompute,
				mode ;
	struct GRid		curEnv ;
	VSpartAttr		part ;
	VSplateAttr		plate ;
	struct GRid		cachedPart ;
	char			errStr[MS_MAX_MSG_LENGTH] ;

	SetProc( VSmodify_plate ) ; Begin

	__DBGpr_obj( "Plate to modify", *plateId ) ;

	/*
	 * Get current module environnement.
	 */
	sts = ex$get_cur_mod( osnum = &curEnv.osnum,
			      id    = &curEnv.objid ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	/*
	 * Retrieve attributes of plate.
	 */
	part.Iwant	= VS_m_All ;
	part.specific	= (void *) &plate ;

	sts = om$send( msg	= message VSplate.GRgetattr( msg,
							     (char *) &part ),
		       senderid = NULL_OBJID,
		       targetid = plateId->objid,
		       targetos = plateId->osnum ) ;

	__CheckRC( sts, *msg, "VSplate.GRgetattr", wrapup ) ;

	/*
	 * Set option to fill plate attributes.
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
	SET_OPTION( orientation,	Orientation	) ;
	SET_OPTION( cutOff,		CutOff		) ;
	SET_OPTION( offset,		Offset		) ;
	SET_OPTION( thickness,		Thickness	) ;
	SET_OPTION( UAid,		UsrAttr 	) ;

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
	if( options & VS_m_Orientation	  ) printf( "\t\tOrientation\n"    ) ;
	if( options & VS_m_CutOff	  ) printf( "\t\tCutOff\n"	   ) ;
	if( options & VS_m_Offset	  ) printf( "\t\tOffset\n"	   ) ;
	if( options & VS_m_Thickness	  ) printf( "\t\tThickness\n"	   ) ;
	if( options & VS_m_UsrAttr	  ) printf( "\t\tUsrAttr\n"	   ) ;
#endif

	/*
	 * Modify plate attributes if needed.
	 */
	if( options != VS_m_Representation ) {
		sts = vs$fillPlateAttr( msg		= msg,
					options 	= options &
							  ~VS_m_Representation,
					partFam 	= partFam,
					matType 	= matType,
					matGrade	= matGrade,
					partNum 	= partNum,
					usrNotes	= usrNotes,
					mtoSrc		= mtoSrc,
					mtoStk		= mtoStk,
					FireProofing	= fireProofing	?
							  *fireProofing : NULL,
					mtoChgNo	= mtoChgNo	?
							  *mtoChgNo	: NULL,
					apprvStat	= apprvStat,
					constStat	= constStat,
					mbrClass	= mbrClass	?
							  *mbrClass	: NULL,
					mbrType 	= mbrType	?
							  *mbrType	: NULL,
					orientation	= orientation	?
							  *orientation	: NULL,
					cutOff		= cutOff	?
							  *cutOff	: NULL,
					offset		= offset	?
							  *offset	: NULL,
					thickness	= thickness	?
							  *thickness	: NULL,
					usrAttrId	= UAid,
					partAttr	= &part,
					plateAttr	= &plate ) ;

		__CheckRC( sts, *msg, "vs$fillPlateAttr", wrapup ) ;
	}

	/*
	 * Load plate from RDB if something changed.
	 */
	if( options & VS_m_PartFam  ||
	    options & VS_m_MatType  ||
	    options & VS_m_PartNum  ) {
		vs$load_part_from_RDB( msg	= msg,
				       errStr	= errStr,
				       material = part.info.material,
				       family	= part.info.family,
				       part	= part.info.partNum,
				       osnum	= curEnv.osnum,
				       object	= &cachedPart ) ;

		if( !( *msg & 1 ) ) {
			printf( "!!! modify plate ERROR : %s\n", errStr ) ;
			goto wrapup ;
		}
	}

	/*
	 * See if the plate must recompute.
	 */
	needRecompute = options & ( VS_m_Representation |
				    VS_m_PartNum	|
				    VS_m_Orientation	|
				    VS_m_CutOff 	|
				    VS_m_Offset 	|
				    VS_m_Thickness	) ;

	__DBGpr_int( "Recompute plate ?", needRecompute ) ;

	/*
	 * Modify the plate.
	 */
	if( options != VS_m_Representation ) {
		sts = om$send( msg	= message VSplate.GRputattr(
							       msg,
							       (char *) &part ),
			       senderid = NULL_OBJID,
			       targetid = plateId->objid,
			       targetos = plateId->osnum ) ;

		__CheckRC( sts, *msg, "VSplate.GRputattr", wrapup ) ;
	}

	if( options & VS_m_Representation ) {
		sts = om$send( msg	= message VSplate.ACput_NV_rep(
							      *representation ),
			       senderid = NULL_OBJID,
			       targetid = plateId->objid,
			       targetos = plateId->osnum ) ;

		__CheckRC( sts, 1, "VSplate.ACput_NV_rep", wrapup ) ;
	}

	/*
	 * Recompute the plate if needed.
	 */
	if( needRecompute ) {
		sts = om$send( msg	= message VSplate.VSregenerate(),
			       senderid = NULL_OBJID,
			       targetid = plateId->objid,
			       targetos = plateId->osnum ) ;

		__CheckRC( sts, *msg, "VSplate.VSregenerate", wrapup ) ;

		nd$mod_batch( request	 = ND_GET,
			      p_ret_mode = &mode ) ;

		if( mode != ND_DEFER ) nd$exec_batch() ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSmodify_plate */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
