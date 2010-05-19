/* $Id: VDdrwunits.I,v 1.2 2001/09/04 14:24:09 ramarao Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vddraw/.../VDdrwunits.I
 *
 * Description: VISUAL implementation functions.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwunits.I,v $
 *      Revision 1.2  2001/09/04 14:24:09  ramarao
 *      Fixed TR# 5534.
 *
 *      Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/18  19:01:32  pinnacle
# Replaced: vddraw/drw/VDdrwunits.I for:  by azuurhou for vds
#
# Revision 1.1  1998/04/09  18:32:14  pinnacle
# Created: vddraw/drw/VDdrwunits.I by yzhu for vds
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      04/03/98   Adz	        File Creation
 *      04/03/98   YZHU         Modify
 *************************************************************************/

class implementation VDSroot;

#include        <stdio.h>
#include        <string.h>
#include        "EMSmsgdef.h"
#include        "ACattrib.h"
#include        "ACrg_collect.h"
#include        "nddef.h"
#include        "exmacros.h"
#include        "vddrwattr.h"
#include        "v_drwapi.h"
#include        "v_drwmacros.h"
#include        "v_datamacros.h"
#include        "v_miscmacros.h"
#include        "v_drw.h"
#include        "v_dbgmacros.h"
#include        "v_drwdef.h"

/************************************************************************/
long VD_drwProcessTranspMode( msg, xData, lflag )
long                    *msg ;
struct VD_s_drwExecData *xData ;
int			lflag;
{

        long                    sts ;           /* OM completion code   */

        SetProc( VD_drwProcessTranspMode ); Begin

        /*
         * set xData->processFlags = TRUE for each object 
         */

        sts  = OM_S_SUCCESS ;
        *msg = MSSUCC ;

        xData->selectMask = lflag;
	__DBGpr_int(" selectMask ", xData->selectMask );

        End
        return sts ;

} /* VD_drwProcessTranspMode */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
long VD_drwGetTransMode( msg, inp, prcMask )
long                    *msg ;
VD_drwInputData         *inp;
int                     *prcMask;
{

        long                    sts ;           /* OM completion code   */
        struct GRid             *drwId;
        VDpartAttr              attr ;

        SetProc( VD_drwGetTransMode ); Begin

        sts  = OM_S_SUCCESS ;
        *msg = MSSUCC ;

        drwId = ((struct GRid *) (inp->appData));
        __DBGpr_obj( "Object to handle", *drwId ) ;

        /* get mask */
        attr.Iwant = VD_I_drwSelectMask ;
        sts =
        _VD_SEND_OBJN( *drwId, GRvg.GRgetattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

        *prcMask = (int) attr.aType;

        wrapup :
                End
                return sts ;

} /* VD_drwInTransMode */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
long VD_drwInTransMode( msg, inp, xData, prcMask, inSet )
long                    *msg ;
VD_drwInputData         *inp;
struct VD_s_drwExecData *xData;
int			prcMask;
int                     *inSet;
{

        long                    sts ;           /* OM completion code   */
	struct GRid             *drwId;
        VDpartAttr              attr ;
	int 		        elmMask ;
	
        SetProc( VD_drwInTransMode ); Begin

        /*
         * get msak (attr.aType) from object inp->appData
         * and compare it with process mask. if elmMask <= prcMask
	 * pFlag = TRUE, else, pFlag = FALSE;
         */

        sts  = OM_S_SUCCESS ;
        *msg = MSSUCC ;

	*inSet = FALSE;

        drwId = ((struct GRid *) (inp->appData));
        __DBGpr_obj( "Object to handle", *drwId ) ;

        /* get mask */
	attr.Iwant = VD_I_drwSelectMask ;
        sts =
        _VD_SEND_OBJN( *drwId, GRvg.GRgetattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

        elmMask = (int) attr.aType;

	if( elmMask <= prcMask )	*inSet = TRUE;
	else 	  			*inSet = FALSE;

        wrapup :
                End
                return sts ;

} /* VD_drwInTransMode */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
long VD_drwSetTransMode( msg, inp, xData, index )
long                    *msg ;
VD_drwInputData         *inp;
struct VD_s_drwExecData *xData;
int 			index;
{

        long                    sts ;           /* OM completion code   */
	struct GRid		*drwId;
        VDpartAttr              attr ;

        SetProc( VD_drwSetTransMode ); Begin

        /*
         * put mask (xData->selectMask) to object inp->appData
         */

        sts  = OM_S_SUCCESS ;
        *msg = MSSUCC ;

        drwId = ((struct GRid *) (inp->appData));
        __DBGpr_obj( "Object to handle", *drwId ) ;

        /* put mask as attr.aType  */
        attr.Iwant      = VD_I_drwSelectMask ;
	attr.aType	= index ;

        sts =
        _VD_SEND_OBJN( *drwId, GRvg.GRputattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

        wrapup :
                End
                return sts ;

} /* VD_drwSetTransMode*/

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, unit_process ) { 
        long            sts, msg ;

        SetProc( VD_drwOUTPUTunit_process ); Begin

        sts  = OM_S_SUCCESS ;
        msg = MSSUCC ;

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "unit-processing" ) ;
        if( DRW_wantView )   DRW_elmView = VD_anyViewType ;

        End
        // return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;


} /* VD_drwOUTPUTunit_process */

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, in_transp_level_A ) {

        long           	sts, msg ;
	int		inSelectSet ;

	SetProc( VDdrwFUNCTIONin_transp_level_A ); Begin
        /* set flag to res->_ival */
	sts = OM_S_SUCCESS;

        res->type      = VD_int ;
        res->_ival     = 0 ;

        CHECK_ARGCOUNT( 0 )
        sts = 
	VD_drwInTransMode( &msg, inp, xData, VD_K_drwLevel_1, &inSelectSet );
        if( sts & 1 & msg ) {
        	res->_ival = inSelectSet ? 1 : 0 ;
		End ;
                return xfSUCCESS ;
        }
	
        End
        return xfFAILURE ;

} /* VSdrwOUTPUTin_transp_level_A */

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, in_transp_level_B ) {

        long            sts, msg ;
        int             inSelectSet ;

        SetProc( VDdrwFUNCTIONin_transp_level_B ); Begin

        sts = OM_S_SUCCESS;

        res->type      = VD_int ;
        res->_ival     = 0 ;

        CHECK_ARGCOUNT( 0 )
        sts = 
        VD_drwInTransMode( &msg, inp, xData, VD_K_drwLevel_2, &inSelectSet );
        if( sts & 1 & msg ) {
                res->_ival = inSelectSet ? 1 : 0 ;
                End ;
                return xfSUCCESS ;
        }
        End
        return xfFAILURE ;

} /* VSdrwOUTPUTin_transp_level_B */

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, in_transp_level_C ) {

        long            sts, msg ;
        int             inSelectSet ;

        SetProc( VDdrwFUNCTIONin_transp_level_C ); Begin

        sts = OM_S_SUCCESS;

        res->type      = VD_int ;
        res->_ival     = 0 ;

        CHECK_ARGCOUNT( 0 )
        sts = 
        VD_drwInTransMode( &msg, inp, xData, VD_K_drwLevel_3, &inSelectSet );
        if( sts & 1 & msg ) {
                res->_ival = inSelectSet ? 1 : 0 ;
                End ;
                return xfSUCCESS ;
        }
        End
        return xfFAILURE ;

} /* VSdrwOUTPUTin_transp_level_C */

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, in_transp_level_D ) {

        long            sts, msg ;
        int             inSelectSet ;

        SetProc( VDdrwFUNCTIONin_transp_level_D ); Begin

        sts = OM_S_SUCCESS;

        res->type      = VD_int ;
        res->_ival     = 0 ;

        CHECK_ARGCOUNT( 0 )
        sts = 
        VD_drwInTransMode( &msg, inp, xData, VD_K_drwLevel_4, &inSelectSet );
        if( sts & 1 & msg ) {
                res->_ival = inSelectSet ? 1 : 0 ;
                End ;
                return xfSUCCESS ;
        }
        End
        return xfFAILURE ;

} /* VSdrwOUTPUTin_transp_level_D */

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, in_transp_level_E ) {

        long            sts, msg ;
        int             inSelectSet ;

        SetProc( VDdrwFUNCTIONin_transp_level_E ); Begin

        sts = OM_S_SUCCESS;

        res->type      = VD_int ;
        res->_ival     = 0 ;

        CHECK_ARGCOUNT( 0 )
        sts = 
        VD_drwInTransMode( &msg, inp, xData, VD_K_drwLevel_5, &inSelectSet );
        if( sts & 1 & msg ) {
                res->_ival = inSelectSet ? 1 : 0 ;
                End ;
                return xfSUCCESS ;
        }

        End
        return xfFAILURE ;

} /* VSdrwOUTPUTin_transp_level_E */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, set_object_trans ) {

        long            sts, msg ;
        int             inSelectSet ;

        SetProc( VDdrwFUNCTIONset_object_trans ); Begin

        sts = OM_S_SUCCESS;

	CHECK_ARGCOUNT( 0 )

        res->type      = VD_int ;
        res->_ival     = 0 ;

	VD_drwSetTransMode( &msg, inp, &xData, VD_K_drwTrans );

        End
        return xfSUCCESS ;

} /* VSdrwOUTPUTin_transp_level_E */
/*----------------------------------------------------------------------------*/


end implementation VDSroot;
