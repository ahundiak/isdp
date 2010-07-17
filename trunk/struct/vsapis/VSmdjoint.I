/* $Id: VSmdjoint.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSmdjoint.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSmdjoint.I,v $
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
# Revision 1.1  1996/02/20  23:45:02  pinnacle
# Created: ./vsapis/VSmdjoint.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *	04/17/1998	Manoj 		CR 1798000807
 *                                      Facility to change 
 *                                      1. Field weld 
 *					2. Weld Position 
 *                                      3. Shrinkage Ratio
 ***************************************************************************/

class implementation VSjoint ;

#include <stdio.h>
#include <string.h>
#include "madef.h"
#include "exmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "VDSsymb_def.h"
#include "vsattr.h"
#include "vsjoint.h"
#include "vswelddef.h"
#include "vsAPIwelddef.h" 
#include "vsnamemacros.h"
#include "vscmdmacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsAPImacros.h"// CR 179800807
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"

#ifdef vsDEBUG
#define SET_ATTR( value, mask, attr ) if( (value) ) {\
				        printf( "\tModify attribute " #mask "-> %g\n", *(value) ) ;\
					jnPart.Iwant |= VS_m_##mask ;\
					(attr) = *(value) ;\
				      }
#else
#define SET_ATTR( value, mask, attr ) if( (value) ) {\
					jnPart.Iwant |= VS_m_##mask ;\
					(attr) = *(value) ;\
				      }
#endif

/*----------------------------------------------------------------------------*/
long VSmodify_joint( 
long			*msg ,
struct GRid		*jointId ,
int			*weldCode ,
int			*weldProcess ,
int			*weldInfo ,
int			*weldContour ,
int			*weldSide ,
double			*allowance ,
double			*grooveAngle ,
double			*pitch ,
double			*lengthOfIncr ,
char			*usrSymbol ,
int                     *fieldWeld,
int                     *weldPosition,
double                  *shrinkage,
struct GRid		*UAid  ) {

	/*
	 * This function is interfaced by macro 'vs$modify_joint'.
	 */

	long			sts ;
	VSpartAttr		jnPart ;
	VSjointAttr		jointAttr ;

	SetProc( VSmodify_joint ) ; Begin

	__DBGpr_obj( "Joint to modify", *jointId ) ;

	/*
	 * See if some attributes was given.
	 */
	if( !weldCode		&
	    !weldProcess	&
	    !weldInfo		&
	    !weldContour	&
	    !weldSide		&
	    !allowance		&
	    !grooveAngle	&
	    !pitch		&
	    !lengthOfIncr	&
	    !usrSymbol		&
	    !UAid 		)
		vs$inv_arg() ;

	/*
	 * Modify current attributes with the new one.
	 */
	jnPart.specific	= (void *) &jointAttr ;
	jnPart.Iwant	= 0 ;

	if( weldCode	||
	    weldProcess ||
	    weldInfo	||
	    weldContour ||
	    weldSide	) {
		/*
	     	 * Retrieve current values.
	     	 */
		__DBGpr_com( "Retrieve current weld attributes" ) ;

		jnPart.Iwant = VS_m_WeldAttr ;

		sts = om$send( msg	= message GRvg.GRgetattr( msg,
						  	          (char*) &jnPart ),
			       senderid = NULL_OBJID,
			       targetid = jointId->objid,
			       targetos = jointId->osnum ) ;

		__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

		jnPart.Iwant = 0 ;
	}

	SET_ATTR( weldCode,	WeldAttr,	jointAttr.weldAttr.code 	) ;
	SET_ATTR( weldProcess,	WeldAttr,	jointAttr.weldAttr.process	) ;
	SET_ATTR( weldSide,	WeldAttr,	jointAttr.weldAttr.side		) ;
	if( weldInfo || weldContour ) {
		jointAttr.weldAttr.info = 0 ;
		jnPart.Iwant |= VS_m_WeldAttr ;
	}

	if(fieldWeld || weldPosition ){
		jnPart.Iwant |= VS_m_AddWeldAttr ;
	} // CR 179800807 
	if(fieldWeld ){
		jointAttr.addWldAttr.fieldweld =  *fieldWeld ;
		__DBGpr_int("field weld", *fieldWeld);
	} // CR 179800807 
	if(weldPosition ){
		jointAttr.addWldAttr.position =  *weldPosition ;
		__DBGpr_int("Position ", *weldPosition);
	} // CR 179800807 
	if(shrinkage ){
		jnPart.Iwant |= VS_m_Shrinkage ;
		jointAttr.shrinkage =  *shrinkage ;
		__DBGpr_dbl("shrink ", *shrinkage);
	} // CR 179800807 
	
	if( weldInfo ) {
		switch( *weldInfo ) {
			case VS_WI_No_No_No :
				jointAttr.weldAttr.info |= 0 ;
				__DBGpr_com( "Modify attribute weldInfo -> VS_WI_No_No_No" ) ;
				break ;
			case VS_WI_Fw_No_No :
				jointAttr.weldAttr.info |= VS_m_wldFieldWeld ;
				__DBGpr_com( "Modify attribute weldInfo -> VS_WI_Fw_No_No" ) ;
				break ;
			case VS_WI_No_Mt_No :
				jointAttr.weldAttr.info |= VS_m_wldMeltThru ;
				__DBGpr_com( "Modify attribute weldInfo -> VS_WI_No_Mt_No" ) ;
				break ;
			case VS_WI_Fw_Mt_No :
				jointAttr.weldAttr.info |= VS_m_wldFieldWeld	|
							   VS_m_wldMeltThru  ;
				__DBGpr_com( "Modify attribute weldInfo -> VS_WI_Fw_Mt_No" ) ;
				break ;
			case VS_WI_No_No_Wa :
				jointAttr.weldAttr.info |= VS_m_wldWeldAllAround ;
				__DBGpr_com( "Modify attribute weldInfo -> VS_WI_No_No_Wa" ) ;
				break ;
			case VS_WI_Fw_No_Wa :
				jointAttr.weldAttr.info |= VS_m_wldFieldWeld	|
							   VS_m_wldWeldAllAround ;
				__DBGpr_com( "Modify attribute weldInfo -> VS_WI_Fw_No_Wa" ) ;
				break ;
			case VS_WI_No_Mt_Wa :
				jointAttr.weldAttr.info |= VS_m_wldMeltThru	|
							   VS_m_wldWeldAllAround ;
				__DBGpr_com( "Modify attribute weldInfo -> VS_WI_No_Mt_Wa" ) ;
				break ;
			case VS_WI_Fw_Mt_Wa :
				jointAttr.weldAttr.info |= VS_m_wldFieldWeld	|
							   VS_m_wldMeltThru	|
							   VS_m_wldWeldAllAround ;
				__DBGpr_com( "Modify attribute weldInfo -> VS_WI_Fw_Mt_Wa" ) ;
				break ;
			default:
				break ;
		}
	}

	if( weldContour ) {
		switch( *weldContour ) {
			case VS_WK_Flush :
				jointAttr.weldAttr.info |= VS_m_wldFlushContour ;
				__DBGpr_com( "Modify attribute weldContour -> VS_WK_Flush" ) ;
				break ;
			case VS_WK_Concave :
				jointAttr.weldAttr.info |= VS_m_wldConcaveContour ;
				__DBGpr_com( "Modify attribute weldContour -> VS_WK_Concave" ) ;
				break ;
			case VS_WK_Convex :
				jointAttr.weldAttr.info |= VS_m_wldConvexContour ;
				__DBGpr_com( "Modify attribute weldContour -> VS_WK_Convex" ) ;
				break ;
			default:
				break ;
		}
	}

	SET_ATTR( allowance, 	Allowance, 	jointAttr.allowance 	) ;
	SET_ATTR( grooveAngle,	GrooveAngle,	jointAttr.grooveAngle	) ;
	SET_ATTR( pitch,	Pitch,		jointAttr.pitch		) ;
	SET_ATTR( lengthOfIncr,	IncrLength,	jointAttr.incrLength	) ;


	if( usrSymbol )	{
		__DBGpr_str( "Modify attribute usrSymbol", usrSymbol ) ;
		strncpy( jointAttr.usrSymbol, usrSymbol, VS_K_MAXUSRSYMSZ ) ;
		jnPart.Iwant |= VS_m_UsrSymbol ;
	}

	if( UAid ) {
		__DBGpr_obj( "modify attribute UAid", *UAid ) ;
		jnPart.usrAttr	= *UAid ;
		jnPart.Iwant |= VS_m_UsrAttr ;
	}

	/*
	 * Modify attributes of joint.
	 */
	sts = om$send( msg	= message GRvg.GRputattr( msg,
							  (char*) &jnPart ),
		       senderid = NULL_OBJID,
		       targetid = jointId->objid,
		       targetos = jointId->osnum ) ;

	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSmodify_joint */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;
