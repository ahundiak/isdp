/* $Id: VSgetbsattr.I,v 1.1.1.1 2001/01/04 21:10:08 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSgetbsattr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSgetbsattr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:08  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/02/20  23:44:50  pinnacle
# Created: ./vsapis/VSgetbsattr.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *
 ***************************************************************************/

class implementation VSbeam ;

#include <stdio.h>
#include <string.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "VDSsymb_def.h"
#include "vsattr.h"
#include "vsbeam.h"
#include "vscmdmacros.h"
#include "vsdatamacros.h"
#include "vsplatmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */

#define VS_m_Representation	0x010000000
#define VS_m_BeamName		0x020000000
#define VS_m_AlongPlane		0x040000000

#ifdef vsDEBUG
#define GET_ATTR( value, mask ) if( (value) ) {\
					printf( "\tGet attribute : " #mask "\n" ) ;\
					iWant |= VS_m_##mask ;\
				}

#define IF_TO_SET( mask ) if( iWant & VS_m_##mask ) { printf( "\tSet attribute : " #mask "\n" ) ;

#define SET_VALUE( value, attr ) printf( "\t\t-> %g\n", (attr) ) ; *(value) = (attr) ; }
#define SET_CHAR( value, attr ) printf( "\t\t-> %s\n", (attr) ) ; strcpy( (value), (attr) ) ; }
#define SET_GRID( value, attr ) printf( "\t\t-> [%d,%d]\n", (attr).osnum, (attr).objid ) ; *(value) = (attr) ; }
#else
#define GET_ATTR( value, mask ) if( (value) ) {\
					iWant |= VS_m_##mask ;\
				}

#define IF_TO_SET( mask ) if( iWant & VS_m_##mask ) {

#define SET_VALUE( value, attr ) *(value) = (attr) ; }
#define SET_CHAR( value, attr ) strcpy( (value), (attr) ) ; }
#define SET_GRID( value, attr ) *(value) = (attr) ; }
#endif

from VSstfBeam	import VSgetConstructionType ;

/*----------------------------------------------------------------------------*/
static long VSget_bmstf_attributes( msg,
				    bmstfId,
				    bmstfName,
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
				    UAid,
				    xOffset,
				    yOffset,
				    rotAngle,
				    cardPnt,
				    symmetry,
				    alongPlane )

long			*msg ;
struct GRid		*bmstfId ;
char			*bmstfName ;
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
struct GRid		*UAid ;
double			*xOffset ;
double			*yOffset ;
double			*rotAngle ;
enum VScardinal_point	*cardPnt ;
enum VSsymmetry 	*symmetry ;
int			*alongPlane ; {

	long			sts ;
	VSpartAttr		part ;
	VSbeamAttr		beam ;
	VSdspRep		bmstfRep ;
	char			name[DI_PATH_MAX] ;
	int			cnstType ;
	unsigned long		iWant ;

	__DBGpr_obj( "Beam or Stiffener", *bmstfId ) ;

      	/*
	 * See if input arguments are valid.
	 */
	if( !bmstfName		&
	    !representation	&
	    !matType		&
	    !matGrade		&
	    !partFam		&
	    !partNum		&
	    !usrNotes		&
	    !mtoSrc		&
	    !mtoStk		&
	    !fireProofing	&
	    !mtoChgNo		&
	    !apprvStat		&
	    !constStat		&
	    !mbrClass		&
	    !mbrType		&
	    !UAid		&
	    !xOffset		&
	    !yOffset		&
	    !rotAngle		&
	    !cardPnt		&
	    !symmetry		&
	    !alongPlane		)
		vs$inv_arg() ;

	/*
	 * See which attributes we want.
	 */
	iWant = 0 ;

 	GET_ATTR( bmstfName,	 	BeamName 	) ;
	GET_ATTR( representation,	Representation	) ;
	GET_ATTR( matType,		MatType		) ;
	GET_ATTR( matGrade,		MatGrade	) ;
	GET_ATTR( partFam,		PartFam		) ;
	GET_ATTR( partNum,		PartNum		) ;
	GET_ATTR( usrNotes,		Notes		) ;
	GET_ATTR( mtoSrc,		MtoSrc		) ;
	GET_ATTR( mtoStk,		MtoStk		) ;
	GET_ATTR( fireProofing,		FpThck		) ;
	GET_ATTR( mtoChgNo,		ChgNum		) ;
	GET_ATTR( apprvStat,		AppStat		) ;
	GET_ATTR( constStat,		CstStat		) ;
	GET_ATTR( mbrClass,		MbrClass	) ;
	GET_ATTR( mbrType,		MbrType		) ;
	GET_ATTR( UAid,			UsrAttr		) ;
	GET_ATTR( xOffset,		xOffset		) ;
	GET_ATTR( yOffset,		yOffset		) ;
	GET_ATTR( rotAngle,		RotAngle	) ;
	GET_ATTR( cardPnt,		cardPnt		) ;
	GET_ATTR( symmetry,		Symmetry	) ;
	GET_ATTR( alongPlane,		AlongPlane	) ;

	/*
	 * Retrieve attributes.
	 */
	if( iWant & ~( VS_m_Representation | VS_m_BeamName | VS_m_AlongPlane ) ) {

		part.Iwant	= iWant & ~( VS_m_Representation | 
					     VS_m_BeamName       |
					     VS_m_AlongPlane     ) ;
		part.specific	= (void *) &beam ;

		sts = om$send( msg	= message VSbeam.GRgetattr( msg,
								    (char *) &part ),
			       senderid = NULL_OBJID,
			       targetid = bmstfId->objid,
			       targetos = bmstfId->osnum ) ;

		__CheckRC( sts, *msg, "VSbeam.GRgetattr", wrapup ) ;
	}

	/*
	 * Retrieve beam representation.
	 */
	if( iWant & VS_m_Representation ) {
		sts = om$send( msg	= message ACncpx.ACget_NV_rep( &bmstfRep ),
			       senderid = NULL_OBJID,
			       targetid = bmstfId->objid,
			       targetos = bmstfId->osnum ) ;

		__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;
	}

	/*
	 * Retrieve beam/stiffener name.
	 */
	if( iWant & VS_m_BeamName ) {
		sts = om$send( msg	= message GRvg.GRgetname( msg, 
								  name ),
			       senderid = NULL_OBJID,
			       targetid = bmstfId->objid,
			       targetos = bmstfId->osnum ) ;

		__CheckRC( sts, *msg, "GRvg.GRgetname", wrapup ) ;
	}

	/*
	 * Retrieve along plane for stiffener.
	 */
	if( iWant & VS_m_AlongPlane ) {
		sts = om$send( msg	= message VSfeature.VSforwardToOriginal(
					msg,
					OM_e_wrt_object,
					message VSstfBeam.VSgetConstructionType(
						           msg, &cnstType )),
			       senderid = NULL_OBJID,
			       targetid = bmstfId->objid,
			       targetos = bmstfId->osnum ) ;

		__CheckRC( sts, *msg, "VSstfBeam.VSgetConstructionType", wrapup ) ;
	}

	/*
	 * Fill output argument.
	 */
	IF_TO_SET( BeamName 		)
		SET_CHAR(  bmstfName, 		name 			) ;

	IF_TO_SET( Representation 	)
		SET_VALUE( representation,	bmstfRep		) ;

	IF_TO_SET( MatType 		)
		SET_CHAR(  matType,		part.info.material	) ; 

	IF_TO_SET( MatGrade 		)
		SET_CHAR(  matGrade,		part.info.grade		) ;

	IF_TO_SET( PartFam 		)
		SET_CHAR(  partFam,		part.info.family	) ;

	IF_TO_SET( PartNum 		)
		SET_CHAR(  partNum,		part.info.partNum	) ;

	IF_TO_SET( Notes	 	)
		SET_CHAR(  usrNotes,		part.info.notes		) ;

	IF_TO_SET( MtoSrc 		)
		SET_CHAR(  mtoSrc,		part.mto.source		) ;

	IF_TO_SET( MtoStk 		)
		SET_CHAR(  mtoStk,		part.mto.stock		) ;

	IF_TO_SET( FpThck	 	)
		SET_VALUE( fireProofing,	part.info.fpthickness	) ;

	IF_TO_SET( ChgNum	 	)
		SET_VALUE( mtoChgNo,		part.mto.chgnum		) ;

	IF_TO_SET( AppStat 		)
		SET_CHAR(  apprvStat,		part.info.apprvstat	) ;

	IF_TO_SET( CstStat 		)
		SET_CHAR(  constStat,		part.info.conststat	) ;

	IF_TO_SET( MbrClass 		)
		SET_VALUE( mbrClass,		part.info.memberClass	) ;

	IF_TO_SET( MbrType 		)
		SET_VALUE( mbrType,		part.info.memberType	) ;

	IF_TO_SET( UsrAttr		)
		SET_GRID(  UAid,		part.usrAttr		) ;

	IF_TO_SET( xOffset		)
		SET_VALUE( xOffset,		beam.xoff		) ;	

	IF_TO_SET( yOffset		)
		SET_VALUE( yOffset,		beam.yoff		) ;	

	IF_TO_SET( RotAngle		)
		SET_VALUE( rotAngle,		beam.rotat		) ;

	IF_TO_SET( cardPnt		)
		SET_VALUE( cardPnt,		beam.card		) ;

	IF_TO_SET( Symmetry		)
		SET_VALUE( symmetry,		beam.sym		) ;

	IF_TO_SET( AlongPlane		)
		SET_VALUE( alongPlane,		cnstType		) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VSget_bmstf_attributes */
/*----------------------------------------------------------------------------*/
long VSget_beam_attributes( msg,
			    beamId,
			    beamName,
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
			    UAid,
			    xOffset,
			    yOffset,
			    rotAngle,
			    cardPnt,
			    symmetry ) 

long			*msg ;
struct GRid		*beamId ;
char			*beamName ;
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
struct GRid		*UAid ;
double			*xOffset ;
double			*yOffset ;
double			*rotAngle ;
enum VScardinal_point	*cardPnt ;
enum VSsymmetry 	*symmetry ; {

	long		sts ;

	SetProc( VSget_beam_attributes ) ; Begin

	sts = VSget_bmstf_attributes( msg,
				      beamId,
				      beamName,
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
				      UAid,
				      xOffset,
				      yOffset,
				      rotAngle,
				      cardPnt,
				      symmetry,
				      (int*) NULL ) ;

	End
	return sts ;

} /* VSget_beam_attributes */
/*----------------------------------------------------------------------------*/
long VSget_stiffener_attributes( msg,
				 stiffenerId,
				 stiffenerName,
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
				 UAid,
				 xOffset,
				 yOffset,
				 rotAngle,
				 cardPnt,
				 symmetry,
				 alongPlane )

long			*msg ;
struct GRid		*stiffenerId ;
char			*stiffenerName ;
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
struct GRid		*UAid ;
double			*xOffset ;
double			*yOffset ;
double			*rotAngle ;
enum VScardinal_point	*cardPnt ;
enum VSsymmetry 	*symmetry ;
int			*alongPlane ; {

	long		sts ;

	SetProc( VSget_stiffener_attributes ) ; Begin

	sts = VSget_bmstf_attributes( msg,
				      stiffenerId,
				      stiffenerName,
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
				      UAid,
				      xOffset,
				      yOffset,
				      rotAngle,
				      cardPnt,
				      symmetry,
				      alongPlane ) ;

	End
	return sts ;

} /* VSget_stiffener_attributes */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
