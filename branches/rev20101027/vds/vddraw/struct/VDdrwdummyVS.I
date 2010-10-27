/* $Id: VDdrwdummyVS.I,v 1.5 2001/03/08 22:51:09 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwdummyVS.I
 *
 * Description:
 *		Thsi file support dummy calles for I/STRUCT routines.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwdummyVS.I,v $
 *	Revision 1.5  2001/03/08 22:51:09  ramarao
 *	Added "declivity" Keyword in VISUAL and STRUDEL.
 *	
 *	Revision 1.4  2001/02/02 21:24:57  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/01/31 17:39:16  ramarao
 *	Implemented CR# 4564.
 *	
 *	Revision 1.2  2001/01/19 21:41:26  ramarao
 *	Merged from SP.
 *	
# Revision 1.1  2000/10/14  20:34:56  pinnacle
# Created: vds/vddraw/struct/VDdrwdummyVS.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/08/16  14:50:46  pinnacle
# Created: vddraw/struct/VDdrwdummyVS.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/12/95	adz		creation date
 *
 ***************************************************************************/

class implementation VDSroot ;

#include <stdlib.h>
#include <string.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include "ma.h"
#include "bstypes.h"
#include "v_drw.h"
#include "v_drwapi.h"
#include "v_miscmacros.h"
#include "vdprdmacros.h"
#include "v_geommacros.h"
#include "v_globalmsg.h"
#include "v_dbgmacros.h"

#include "VSdrw.h"

/*
 * Keyword function call BODY.
 */
#define KEYWORD_FUNC( _STR_ )						\
long VS##_STR_( msg, inp, xData, outp )					\
long                    *msg ;						\
VSdrwInputData          *inp ;						\
VSdrwExecData           *xData ;					\
VSdrwGraphicGroup       *outp ;


/*
 * View Type definition For I/STRUCT objects.
 */
#define	VIEWTYPE_FUNC( _STR_ )						\
long VSdrwGetViewTypeFrom##_STR_( msg, inp, xData )			\
long			*msg ;						\
VSdrwInputData		*inp ;						\
VSdrwExecData		*xData ;

/*----------------------------------------------------------------------------*/


long VSfindProfileX( msg, inp, xData, pfDir, pfDirASCII ) 

long			*msg ;
const VSdrwInputData	*inp ;
const VSdrwExecData	*xData ;
int			*pfDir ;
char			pfDirASCII[3]; {

	SetProc( DUMMY_VSfindProfileX ); Begin

	*msg = MSFAIL ;	

	End ;
	return xfSUCCESS ;

} /* VSfindProfileX */

/*----------------------------------------------------------------------------*/

long  VSdrwIsPlateHidden( msg, inp, xData, hidden ) 

long			*msg ;
const VSdrwInputData	*inp ;
const VSdrwExecData	*xData ;
int			*hidden ; {

	SetProc( DUMMY_VSdrwIsPlateHidden ); Begin

	*msg = MSFAIL ;
	End ;
        return xfFAILURE ;

} /* VSdrwIsPlateHidden */

/*----------------------------------------------------------------------------*/

long VSdrwIsBeamHidden( msg, inp, xData, hidden ) 


long			*msg ;
const VSdrwInputData	*inp ;
const VSdrwExecData	*xData ;
int			*hidden ; {

	SetProc( DUMMY_VSdrwIsBeamHidden ); Begin

	*msg = MSFAIL ;
	End ;
        return xfFAILURE ;

} /* VSdrwIsBeamHidden */
/*----------------------------------------------------------------------------*/

long VSdrwIsMarkHidden( msg, inp, xData, hidden ) 


long			*msg ;
const VSdrwInputData	*inp ;
const VSdrwExecData	*xData ;
int			*hidden ; {

	SetProc( DUMMY_VSdrwIsMarkHidden ); Begin

	*msg = MSFAIL ;
	End ;
        return xfFAILURE ;

} /* VSdrwIsMarkHidden */

/*----------------------------------------------------------------------------*/

long VSdrwGetDeclivity( msg, inp, xData, declivityAngle )


long                    *msg ;
const VSdrwInputData    *inp ;
const VSdrwExecData     *xData ;
double                  *declivityAngle ; {

        SetProc( DUMMY_VSdrwGetDeclivity ); Begin

        *msg = MSFAIL ;
        End ;
        return xfFAILURE ;

} /* VSdrwGetDeclivity */

/*----------------------------------------------------------------------------*/

long VSdrwArePlatesParallel( msg, plate1, plate2, parallel ) 

long			*msg ;
const struct GRobj_env	*plate1 ;
const struct GRobj_env	*plate2 ;
int			*parallel ; {

	SetProc( DUMMY_VSdrwArePlatesParallel ); Begin

	*msg = MSFAIL ;
	End ;
        return xfFAILURE ;

} /* VSdrwArePlatesParallel */

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

KEYWORD_FUNC( drwCstBeamProf ){

	SetProc( DUMMY_VSdrwCstBeamProf ); Begin

	outp->list	= NULL ;
	outp->count	= 0 ;

	End ;
	*msg	= MSFAIL ;
	return	OM_E_ABORT ;

} /* VSdrwCstBeamProf */

/*----------------------------------------------------------------------------*/

KEYWORD_FUNC( drwCstPlateVwIntersection ){

	SetProc( DUMMY_VSdrwCstPlateVwIntersection ); Begin

	outp->list	= NULL ;
	outp->count	= 0 ;

	End ;
	*msg	= MSFAIL ;
	return	OM_E_ABORT ;

} /* VSdrwCstPlateVwIntersection */

/*----------------------------------------------------------------------------*/

KEYWORD_FUNC( drwCstPartProj ){

	SetProc( DUMMY_VSdrwCstPartProj ); Begin

	outp->list	= NULL ;
	outp->count	= 0 ;

	End ;
	*msg	= MSFAIL ;
	return	OM_E_ABORT ;

} /* VSdrwCstPartProj */

/*----------------------------------------------------------------------------*/

KEYWORD_FUNC( drwCstBeamAxis ){

	SetProc( DUMMY_VSdrwCstBeamAxis ); Begin

	outp->list	= NULL ;
	outp->count	= 0 ;

	End ;
	*msg	= MSFAIL ;
	return	OM_E_ABORT ;

} /* VSdrwCstBeamAxis */

/*----------------------------------------------------------------------------*/

KEYWORD_FUNC( drwPlateContour ){

	SetProc( DUMMY_VSdrwPlateContour ); Begin

	outp->list	= NULL ;
	outp->count	= 0 ;

	End ;
	*msg	= MSFAIL ;
	return	OM_E_ABORT ;

} /* VSdrwPlateContour */

/*----------------------------------------------------------------------------*/

KEYWORD_FUNC( drwPlateBottomSide ){

	SetProc( DUMMY_VSdrwPlateBottomSide ); Begin

	outp->list	= NULL ;
	outp->count	= 0 ;

	End ;
	*msg	= MSFAIL ;
	return	OM_E_ABORT ;

} /* VSdrwPlateBottomSide */

/*----------------------------------------------------------------------------*/

KEYWORD_FUNC( drwJoint ){

	SetProc( DUMMY_VSdrwJoint ); Begin

	outp->list	= NULL ;
	outp->count	= 0 ;

	End ;
	*msg	= MSFAIL ;
	return	OM_E_ABORT ;

} /* VSdrwJoint */

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

VIEWTYPE_FUNC( Beam ){

	SetProc( DUMMY_ViewTypeBeam ); Begin

	DRW_elmView = VSunknownViewType ;

	*msg = MSSUCC ;
	return	OM_S_SUCCESS ;
}

/*----------------------------------------------------------------------------*/

VIEWTYPE_FUNC( Plate ){

	SetProc( DUMMY_ViewTypePlate ); Begin

	DRW_elmView = VSunknownViewType ;

	*msg = MSSUCC ;
	return	OM_S_SUCCESS ;
}

/*----------------------------------------------------------------------------*/

VIEWTYPE_FUNC( Joint ){

	SetProc( DUMMY_ViewTypeJoint ); Begin

	DRW_elmView = VSunknownViewType ;

	*msg = MSSUCC ;
	return	OM_S_SUCCESS ;
}

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

long    VDdrw_get_ElmType( out )

struct VS_s_drwExecData         *out ; {

        SetProc( VDdrw_get_ElmType ); Begin

	out->parsedElmType = 0 ;

	End ;
	return FALSE ;
}

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

VSaddInternalNamesToDelete( arglist )
VD_drwArgLst	*arglist;
{
        SetProc( VSaddInternalNamesToDelete ); Begin

        End ;
        return xfFAILURE ;
}

VSinitNamesToDelete()
{
        SetProc( VSinitNamesToDelete ); Begin

        End ;
        return xfFAILURE ;
}

VSdrwArgLst *VSdrwAddArg( msg, arg, argl )

long            *msg ;          /* OUT: Completion code                 */
const VSexecRes *arg ;          /* IN : Argument to add to list         */
VSdrwArgLst     *argl; 
{
   return NULL;
}

end implementation VDSroot ;

