/* $Id: VDdrwgroutVS.I,v 1.3 2001/02/15 23:22:33 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwgroutVS.I
 *
 * Description:
 *		This file contains I/VDS parser keywords, which will be
 *		activated when I/STRUCT is active. The functionality is
 *		controlled inside the STRUDL parser.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwgroutVS.I,v $
 *	Revision 1.3  2001/02/15 23:22:33  ramarao
 *	Implemented CR# 4038.
 *	
 *	Revision 1.2  2001/01/19 21:41:30  ramarao
 *	Merged from SP.
 *	
# Revision 1.1  2000/07/17  15:22:06  pinnacle
# Created: vds/vddraw/struct/VDdrwgroutVS.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/07/24  04:04:48  pinnacle
# Replaced: vddraw/struct/VDdrwgroutVS.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/08/16  14:51:14  pinnacle
# Created: vddraw/struct/VDdrwgroutVS.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			adz		creation date
 *	07/23/97	Sundar		Modified the keywords intersectio &
 *					contour for compartments
 ***************************************************************************/

class implementation VDSroot ;

#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "gotextdef.h"
#include "fontdef.h"
#include "font.h"
#include "acrepdef.h"
#include "EMSmsgdef.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_drwdef.h"
#include "v_drwapi.h"
#include "vdprdmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "VSdrw.h"

/*
 * Includes for function prototypes.
 */
#include "v_drwproto.h"

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
/* Graphical Function used for the Structural Elements		              */
/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

#argsused
IMPLEMENT_OUTPUT( VD, intersection ) {

	long		sts, msg ;
        const char      *type = xData->parsedElmDesc ;
        VSdrwInputData		S_inp ;
        VSdrwExecData		S_xData ;
	VSdrwGraphicGroup	S_outgr ;

	SetProc( VD_drwOUTPUTintersection ); Begin

	S_outgr.count	= 0 ;
	S_outgr.list	= NULL ;

	if( !strcmp(type, "compartment") ){
                sts = VDdrwCompInterContour( &msg, inp, xData, outpgr ) ;
                xData->txPosHelper = VD_useFirstCurve ;
 
                return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;
        }

	if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
		WRONG_OUTPUT ;
	}

        if(    !strcmp( type, "beam" )
            || !strcmp( type, "stiffener" ) ) {

		VDdrw_cpy_InputData( inp, &S_inp );
		VDdrw_cpy_ExecData( xData, &S_xData );
                sts = VSdrwCstBeamProf( &msg, &S_inp, &S_xData, &S_outgr ) ;
		_FREE( S_inp.toBeDrawn.elmList );

        } else if( !strcmp( type, "plate" ) ) {
		VDdrw_cpy_InputData( inp, &S_inp );
		VDdrw_cpy_ExecData( xData, &S_xData );
                sts = VSdrwCstPlateVwIntersection( &msg, &S_inp, &S_xData, &S_outgr ) ;
		_FREE( S_inp.toBeDrawn.elmList );
        } else {
                WRONG_OUTPUT ;
        }

	VDdrw_ret_GraphicGroup( &S_outgr, outpgr );

        xData->txPosHelper = VD_useFirstCurve ;
	End ;
        return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTintersection */

/*----------------------------------------------------------------------------*/

#argsused
IMPLEMENT_OUTPUT( VD, profile ) {

	long		sts, msg ;
        const char      *type = xData->parsedElmDesc ;
        VSdrwInputData		S_inp ;
        VSdrwExecData		S_xData ;
	VSdrwGraphicGroup	S_outgr ;

	SetProc( VD_drwOUTPUTprofile ); Begin

	S_outgr.count	= 0 ;
	S_outgr.list	= NULL ;

	if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
		WRONG_OUTPUT ;
	}

        if(    !strcmp( type, "beam" )
            || !strcmp( type, "stiffener" ) ) {
		VDdrw_cpy_InputData( inp, &S_inp );
		VDdrw_cpy_ExecData( xData, &S_xData );
                sts = VSdrwCstBeamProf( &msg, &S_inp, &S_xData, &S_outgr ) ;
		_FREE( S_inp.toBeDrawn.elmList );
        } else {
                WRONG_OUTPUT ;
        }

	VDdrw_ret_GraphicGroup( &S_outgr, outpgr );

        xData->txPosHelper = VD_useFirstCurve ;
	End ;
        return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTprofile */

/*----------------------------------------------------------------------------*/

#argsused
IMPLEMENT_OUTPUT( VD, projection ) {

        long            sts, msg ;
	char		option[30];
        const char      *type = xData->parsedElmDesc ;
        VD_dspRep       rep ;
        VSdrwInputData		S_inp ;
        VSdrwExecData		S_xData ;
	VSdrwGraphicGroup	S_outgr ;

	SetProc( VD_drwOUTPUTprojection ); Begin

	S_outgr.count	= 0 ;
	S_outgr.list	= NULL ;

	if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
		WRONG_OUTPUT ;
	}

        if(    !strcmp( type, "beam" )
            || !strcmp( type, "stiffener" ) ) {
                om$send( msg      = message ACncpx.ACget_NV_rep( &rep ),
                         senderid = inp->elmId->objid,
                         targetid = inp->elmId->objid,
                         targetos = inp->elmId->osnum ) ;
                if( rep != AC_2D_REP ) {
			VDdrw_cpy_InputData( inp, &S_inp );
			VDdrw_cpy_ExecData( xData, &S_xData );
                        sts = VSdrwCstPartProj( &msg, &S_inp, &S_xData, &S_outgr);
			_FREE( S_inp.toBeDrawn.elmList );
                } else {
			VDdrw_cpy_InputData( inp, &S_inp );
			VDdrw_cpy_ExecData( xData, &S_xData );

                	if( argc == 1 ) VD_drwStrVal( &arglist->arg, option );
                	else            strcpy( option, "" );

                        sts = VSdrwCstBeamAxis( &msg, &S_inp, &S_xData, 
						option, &S_outgr ) ;
			_FREE( S_inp.toBeDrawn.elmList );
                }
                xData->txPosHelper = VD_useAllCurves ;

        } else if( !strcmp( type, "plate" ) ) {
		VDdrw_cpy_InputData( inp, &S_inp );
		VDdrw_cpy_ExecData( xData, &S_xData );
                sts = VSdrwCstPartProj( &msg, &S_inp, &S_xData, &S_outgr ) ;
		_FREE( S_inp.toBeDrawn.elmList );
                xData->txPosHelper = VD_useAllCurves ;

        } else {
                WRONG_OUTPUT ;
	}

	VDdrw_ret_GraphicGroup( &S_outgr, outpgr );

	End ;
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTprojection */

/*----------------------------------------------------------------------------*/

#argsused
IMPLEMENT_OUTPUT( VD, axis ) {

	long			sts, msg ;
	char			option[30];
        const char		*type = xData->parsedElmDesc ;
        VSdrwInputData		S_inp ;
        VSdrwExecData		S_xData ;
	VSdrwGraphicGroup	S_outgr ;

	SetProc( VD_drwOUTPUTaxis ); Begin

	S_outgr.count	= 0 ;
	S_outgr.list	= NULL ;

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
                WRONG_OUTPUT ;
        }

        if(    !strcmp( type, "beam" )
            || !strcmp( type, "stiffener" ) ) {
		VDdrw_cpy_InputData( inp, &S_inp );
		VDdrw_cpy_ExecData( xData, &S_xData );

                if( argc == 1 ) VD_drwStrVal( &arglist->arg, option );
                else            strcpy( option, "" );

                sts = VSdrwCstBeamAxis( &msg, &S_inp, &S_xData, 
					option, &S_outgr ) ;
		_FREE( S_inp.toBeDrawn.elmList );
        } else {
                WRONG_OUTPUT ;
        }

	VDdrw_ret_GraphicGroup( &S_outgr, outpgr );

        xData->txPosHelper = VD_useFirstCurve ;

	End ;
        return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTaxis */

/*----------------------------------------------------------------------------*/

#argsused
IMPLEMENT_OUTPUT( VD, contour ) {

	long			sts, msg ;
	char			option[30];
        const char      	*type = xData->parsedElmDesc ;
        VSdrwInputData		S_inp ;
        VSdrwExecData		S_xData ;
	VSdrwGraphicGroup	S_outgr ;

	SetProc( VD_drwOUTPUTcontour ); Begin

	S_outgr.count	= 0 ;
	S_outgr.list	= NULL ;

	if( !strcmp(type, "compartment") ){
                sts = VDdrwCompContour( &msg, inp, xData, outpgr ) ;
                xData->txPosHelper = VD_useFirstCurve ;
 
                return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;
        }

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
                WRONG_OUTPUT ;
        }

        if( !strcmp( type, "plate" ) ) {
		VDdrw_cpy_InputData( inp, &S_inp );
		VDdrw_cpy_ExecData( xData, &S_xData );

		if( argc == 1 ) VD_drwStrVal( &arglist->arg, option );
		else		strcpy( option, "" );

                sts = VSdrwPlateContour( &msg, &S_inp, &S_xData, 
					 option, &S_outgr ) ;
		_FREE( S_inp.toBeDrawn.elmList );
        } else {
                WRONG_OUTPUT ;
        }

	VDdrw_ret_GraphicGroup( &S_outgr, outpgr );
        xData->txPosHelper = VD_useFirstCurve ;

	End ;
        return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTcontour */

/*----------------------------------------------------------------------------*/

#argsused
IMPLEMENT_OUTPUT( VD, edge ) {

	long		sts, msg ;
        const char      *type = xData->parsedElmDesc ;
        VSdrwInputData		S_inp ;
        VSdrwExecData		S_xData ;
	VSdrwGraphicGroup	S_outgr ;

	SetProc( VD_drwOUTPUTedge ); Begin

	S_outgr.count	= 0 ;
	S_outgr.list	= NULL ;

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
                WRONG_OUTPUT ;
        }

        if( !strcmp( type, "plate" ) ) {
		VDdrw_cpy_InputData( inp, &S_inp );
		VDdrw_cpy_ExecData( xData, &S_xData );
                sts = VSdrwPlateBottomSide( &msg, &S_inp, &S_xData, &S_outgr ) ;
		_FREE( S_inp.toBeDrawn.elmList );
        } else {
                WRONG_OUTPUT ;
        }

	VDdrw_ret_GraphicGroup( &S_outgr, outpgr );
        xData->txPosHelper = VD_useFirstCurve ;

	End ;
        return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTedge */

/*----------------------------------------------------------------------------*/

#argsused
IMPLEMENT_OUTPUT( VD, weldline) {

        long            sts, msg ;
        const char      *type = xData->parsedElmDesc ;
        VSdrwInputData		S_inp ;
        VSdrwExecData		S_xData ;
	VSdrwGraphicGroup	S_outgr ;

	SetProc( VD_drwOUTPUTweldline ); Begin

	S_outgr.count	= 0 ;
	S_outgr.list	= NULL ;

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )){
                WRONG_OUTPUT ;
        }

        if( !strcmp( type, "joint" ) ) {
		VDdrw_cpy_InputData( inp, &S_inp );
		VDdrw_cpy_ExecData( xData, &S_xData );
                sts = VSdrwJoint( &msg, &S_inp, &S_xData, &S_outgr ) ;
		_FREE( S_inp.toBeDrawn.elmList );
        } else {
                WRONG_OUTPUT ;
        }

	VDdrw_ret_GraphicGroup( &S_outgr, outpgr );
        xData->txPosHelper = VD_useAllCurves ;

	End ;
        return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTweldline */

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

