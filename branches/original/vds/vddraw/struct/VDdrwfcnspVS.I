/* $Id: VDdrwfcnspVS.I,v 1.4 2001/03/08 22:51:11 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/struct/VDdrwfcnspVS.I
 *
 * Description: 
 *		This file 'keyword' used in the VDS parser, but having the
 *		duty to call the I/STRUCT STRUDL functionality.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwfcnspVS.I,v $
 *	Revision 1.4  2001/03/08 22:51:11  ramarao
 *	Added "declivity" Keyword in VISUAL and STRUDEL.
 *	
 *	Revision 1.3  2001/01/31 17:36:02  ramarao
 *	Implemented CR# 4564.
 *	
 *	Revision 1.2  2001/01/19 21:41:28  ramarao
 *	Merged from SP.
 *	
# Revision 1.1  2000/10/14  18:44:58  pinnacle
# Created: vds/vddraw/struct/VDdrwfcnspVS.I by rchennup for Service Pack
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
# Revision 1.1  1995/08/16  14:51:00  pinnacle
# Created: vddraw/struct/VDdrwfcnspVS.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/14/95	adz		creation date
 *
 ***************************************************************************/

class implementation VDSroot ;

#include <stdlib.h>
#include <string.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include "ma.h"
#include "bstypes.h"
#include "VDobj.h"
#include "v_drwdef.h"
#include "v_drwapi.h"
#include "v_miscmacros.h"
#include "vdprdmacros.h"
#include "v_geommacros.h"
#include "v_globalmsg.h"
#include "v_dbgmacros.h"

#include "VSdrw.h"

/*----------------------------------------------------------------------------*/
%safe
const char *VD_drwNotAPlate    = "!!! %s(): element is not a plate\n" ;
const char *VD_drwNotABeam     = "!!! %s(): element is not a beam\n" ;
const char *VD_drwNotAJoint    = "!!! %s(): element is not a joint\n" ;
%endsafe
/*----------------------------------------------------------------------------*/

//extern char *VD_drwNotAPlate, *VD_drwNotABeam, *VD_drwNotAJoint;

/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, profile_direction ) {

        long		sts ;
        int		pfDir ;
        char		pfDirASCII[3] ;
	VSdrwInputData	S_inp ;
	VSdrwExecData	S_xData ;

	SetProc( VD_profile_direction ); Begin

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
		End ;
                return xfUNKFCN ;
        }

        res->type       = VD_string ;
        *res->_sval     = '\0' ;

        CHECK_ARGCOUNT( 0 )

	VDdrw_cpy_InputData( inp,	&S_inp );
	VDdrw_cpy_ExecData(  xData,	&S_xData );

        VSfindProfileX( &sts, &S_inp, &S_xData, &pfDir, pfDirASCII ) ;

	_FREE( S_inp.toBeDrawn.elmList );

        if( sts & 1 ) {
                strcpy( res->_sval, pfDirASCII ) ;
		End ;
                return xfSUCCESS ;
        }

	End ;
        return xfFAILURE ;

} /* VD_drwFUNCTIONprofile_direction */

/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, plate_direction ) {

        long		sts ;
        int		plDir ;
        char		plDirASCII[3] ;
	VSdrwInputData	S_inp ;
	VSdrwExecData	S_xData ;

	SetProc( VD_plate_direction ); Begin

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
		End ;
                return xfUNKFCN ;
        }

        res->type       = VD_string ;
        *res->_sval     = '\0' ;

        CHECK_ARGCOUNT( 0 )

	VDdrw_cpy_InputData( inp,	&S_inp );
	VDdrw_cpy_ExecData(  xData,	&S_xData );

        VSfindProfileX( &sts, &S_inp, &S_xData, &plDir, plDirASCII ) ;

	_FREE( S_inp.toBeDrawn.elmList );

        if( sts & 1 ) {
                strcpy( res->_sval, plDirASCII ) ;
		End ;
                return xfSUCCESS ;
        }

	End ;
        return xfFAILURE ;

} /* VD_drwFUNCTIONplate_direction */

/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, is_plate_hidden ) {

	long		sts ,
			msg ;
	int		isHidden ;
	VSdrwInputData	S_inp ;
	VSdrwExecData	S_xData ;

	SetProc( VD_is_plate_hidden ); Begin

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
		End ;
                return xfUNKFCN ;
        }

	res->type	= VD_int ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 0 )

        if( strcmp( xData->parsedElmDesc, "plate" )) {
                XFERR( VD_drwNotAPlate, function ) ;
                return xfINVARG ;
        }

	VDdrw_cpy_InputData( inp,	&S_inp );
	VDdrw_cpy_ExecData(  xData,	&S_xData );

        sts = VSdrwIsPlateHidden( &msg, &S_inp, &S_xData, &isHidden ) ;

	_FREE( S_inp.toBeDrawn.elmList );

        if( sts & 1 & msg ) {
                res->_ival = isHidden ? 1 : 0 ;
		End ;
                return xfSUCCESS ;
        }

	End ;
        return xfFAILURE ;

} /* VD_drwFUNCTIONis_plate_hidden */

/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, is_beam_hidden ) {

	long		sts ,
			msg ;
	int		isHidden ;
	VSdrwInputData	S_inp ;
	VSdrwExecData	S_xData ;

	SetProc( VD_is_beam_hidden ); Begin

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
		End ;
                return xfUNKFCN ;
        }

	res->type	= VD_int ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 0 )

        if(    !strcmp( xData->parsedElmDesc, "beam" )
            && !strcmp( xData->parsedElmDesc, "stiffener" )){
                XFERR( VD_drwNotABeam, function ) ;
                return xfINVARG ;
        }

	VDdrw_cpy_InputData( inp,	&S_inp );
	VDdrw_cpy_ExecData(  xData,	&S_xData );

        sts = VSdrwIsBeamHidden( &msg, &S_inp, &S_xData, &isHidden ) ;

	_FREE( S_inp.toBeDrawn.elmList );

        if( sts & 1 & msg ) {
                res->_ival = isHidden ? 1 : 0 ;
		End ;
                return xfSUCCESS ;
        }

	End ;
        return xfFAILURE ;

} /* VD_drwFUNCTIONis_beam_hidden */

/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, is_mark_hidden ) {

	long		sts ,
			msg ;
	int		isHidden ;
	char            clsName[50];
	VSdrwInputData	S_inp ;
	VSdrwExecData	S_xData ;

	SetProc( VD_is_mark_hidden ); Begin

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_LOFT )){
		End ;
                return xfUNKFCN ;
        }

	res->type	= VD_int ;

	CHECK_ARGCOUNT( 0 )

	clsName[0] = '\0' ;

        vdobj$Get( objID     = inp->elmId,
                   className = clsName );

        if(    !strcmp(clsName, "VLmrkLine" ) ) {
                XFERR( VD_drwNotABeam, function ) ;
                return xfINVARG ;
        }

	VDdrw_cpy_InputData( inp,	&S_inp );
	VDdrw_cpy_ExecData(  xData,	&S_xData );

        sts = VSdrwIsMarkHidden( &msg, &S_inp, &S_xData, &isHidden ) ;

	_FREE( S_inp.toBeDrawn.elmList );

        if( sts & 1 & msg ) {
                res->_ival = isHidden ? 1 : 0 ;
		End ;
                return xfSUCCESS ;
        }

	End ;
        return xfFAILURE ;

} /* VD_drwFUNCTIONis_mark_hidden */

/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, declivity ) {

        long            sts ,
                        msg ;
	double		declivityAngle=0.0;
        VSdrwInputData  S_inp ;
        VSdrwExecData   S_xData ;

        SetProc( VD_declivity ); Begin

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
                End ;
                return xfUNKFCN ;
        }

        res->type       = VD_double;
        res->_dval      = 0.0 ;

        VDdrw_cpy_InputData( inp,       &S_inp );
        VDdrw_cpy_ExecData(  xData,     &S_xData );

        sts = VSdrwGetDeclivity( &msg, &S_inp, &S_xData, &declivityAngle ) ;

        _FREE( S_inp.toBeDrawn.elmList );

        if( sts & 1 & msg ) {
		res->_dval = declivityAngle ;
                End ;
                return xfSUCCESS ;
        }

        End ;
        return xfFAILURE ;

} /* VD_drwFUNCTIONdeclivity */
/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, parallel_plates ) {

        long			sts ;
        const VD_execRes	*plate1,        /* First  plate         */
				*plate2 ;       /* Second plate         */

	SetProc( VD_parallel_plates ); Begin

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
		End ;
                return xfUNKFCN ;
        }

        res->type = VS_int ;
        res->_ival= 0 ;

        CHECK_ARGCOUNT( 2 )

        plate1 = &arglist->arg ;
        plate2 = &arglist->next->arg ;

        CHECK_FOR_OBJ( *plate1, 1 ) ;
        CHECK_FOR_OBJ( *plate2, 2 ) ;

        VSdrwArePlatesParallel( &sts, &plate1->_oval, &plate2->_oval,
                                &res->_ival ) ;

	End ;
        return sts & 1 ? xfSUCCESS : xfFAILURE ;

} /* VD_drwFUNCTIONparallel_plates */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, int_holes_to_delete ) {

    VSdrwArgLst		cp_arglist;

    if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
            return xfUNKFCN ;
    }

    INT_RES( 1 );

    VDdrw_cpy_ArgList( arglist, &cp_arglist );
    VSaddInternalNamesToDelete( &cp_arglist );

    return xfSUCCESS ;
}

end implementation VDSroot ;

