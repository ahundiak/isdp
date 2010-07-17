/* $Id: VSgetplattr.I,v 1.1.1.1 2001/01/04 21:10:09 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSgetplattr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSgetplattr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:09  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/02/20  23:44:54  pinnacle
# Created: ./vsapis/VSgetplattr.I by azuurhou for struct
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
#include "msdef.h"
#include "EMSmsgdef.h"
#include "VDSsymb_def.h"
#include "vsattr.h"
#include "vsplate.h"
#include "vscmdmacros.h"
#include "vsdatamacros.h"
#include "vsplatmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */

#define VS_m_Representation	0x010000000
#define VS_m_PlateName		0x020000000

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

/*----------------------------------------------------------------------------*/
long VSget_plate_attributes( msg,
			     plateId,
			     plateName,
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
char			*plateName ;
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
	 * This function is interfaced by macro 'vs$get_plate_attributes'.
	 */

	long			sts ;
	VSpartAttr		part ;
	VSplateAttr		plate ;
	VSdspRep		plateRep ;
	char			plName[DI_PATH_MAX] ;
	unsigned long		iWant ;

	SetProc( VSget_plate_attributes ) ; Begin

	__DBGpr_obj( "Plate", *plateId ) ;

      	/*
	 * See if input arguments are valid.
	 */
	if( !plateName		&
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
	    !orientation	&
	    !cutOff		&
	    !offset		&
	    !thickness		&
	    !UAid 		)
		vs$inv_arg() ;

	/*
	 * See which attributes we want.
	 */
	iWant = 0 ;

 	GET_ATTR( plateName,	 	PlateName 	) ;
 	GET_ATTR( representation,	Representation 	) ;
 	GET_ATTR( matType,	 	MatType 	) ;
 	GET_ATTR( matGrade,	 	MatGrade 	) ;
 	GET_ATTR( partFam,	 	PartFam 	) ;
 	GET_ATTR( partNum,	 	PartNum 	) ;
 	GET_ATTR( usrNotes,	 	Notes	 	) ;
 	GET_ATTR( mtoSrc,	 	MtoSrc 		) ;
 	GET_ATTR( mtoStk,	 	MtoStk 		) ;
 	GET_ATTR( fireProofing,	 	FpThck	 	) ;
 	GET_ATTR( mtoChgNo,	 	ChgNum	 	) ;
 	GET_ATTR( apprvStat,	 	AppStat 	) ;
 	GET_ATTR( constStat,	 	CstStat 	) ;
 	GET_ATTR( mbrClass,	 	MbrClass 	) ;
 	GET_ATTR( mbrType,	 	MbrType 	) ;
 	GET_ATTR( orientation,	 	Orientation 	) ;
 	GET_ATTR( cutOff,	 	CutOff 		) ;
 	GET_ATTR( offset,	 	Offset 		) ;
 	GET_ATTR( thickness,	 	Thickness 	) ;
 	GET_ATTR( UAid,	 		UsrAttr		) ;

	/*
	 * Retrieve attributes.
	 */
	if( iWant & ~( VS_m_Representation | VS_m_PlateName ) ) { 

		part.Iwant	= iWant & ~( VS_m_Representation | VS_m_PlateName ) ;
		part.specific	= (void *) &plate ;

		sts = om$send( msg	= message VSplate.GRgetattr( msg,
								     (char *) &part ),
			       senderid = NULL_OBJID,
			       targetid = plateId->objid,
			       targetos = plateId->osnum ) ;

		__CheckRC( sts, *msg, "VSplate.GRgetattr", wrapup ) ;
	}

	/*
	 * Retrieve plate representation.
	 */
	if( iWant & VS_m_Representation ) {
		sts = om$send( msg	= message ACncpx.ACget_NV_rep( &plateRep ),
			       senderid = NULL_OBJID,
			       targetid = plateId->objid,
			       targetos = plateId->osnum ) ;

		__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;
	}

	/*
	 * Retrieve plate name.
	 */
	if( iWant & VS_m_PlateName ) {
		sts = om$send( msg	= message GRvg.GRgetname( msg, 
								  plName ),
			       senderid = NULL_OBJID,
			       targetid = plateId->objid,
			       targetos = plateId->osnum ) ;

		__CheckRC( sts, *msg, "GRvg.GRgetname", wrapup ) ;
	}

	/*
	 * Fill output argument.
	 */
	IF_TO_SET( PlateName 		)
		SET_CHAR(  plateName, 		plName 			) ;

	IF_TO_SET( Representation 	)
		SET_VALUE( representation,	plateRep		) ;

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

	IF_TO_SET( Orientation 		)
		SET_VALUE( orientation,		plate.orientation	) ;

	IF_TO_SET( CutOff 		)
		SET_VALUE( cutOff,		plate.cut_off		) ;

	IF_TO_SET( Offset 		)
		SET_VALUE( offset,		plate.offset		) ;

	IF_TO_SET( Thickness 		)
		SET_VALUE( thickness,		plate.thickness		) ;

	IF_TO_SET( UsrAttr		)
		SET_GRID(  UAid,		part.usrAttr		) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSget_plate_attributes */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
