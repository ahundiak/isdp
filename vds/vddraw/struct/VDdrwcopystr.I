/* $Id: VDdrwcopystr.I,v 1.2 2001/01/31 17:40:58 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/struct/VDdrwcopystr.I
 *
 * Description:
 *		This file contain functions to copy the I/VDS parser 
 *		data structure into the I/STRUCT data structure and
 *		visa versus.
 *
 * Dependencies:
 *		I/STRUCT include file "vsdrw.h"
 *
 * Revision History:
 *	$Log: VDdrwcopystr.I,v $
 *	Revision 1.2  2001/01/31 17:40:58  ramarao
 *	Implemented CR# 4564.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/08/31  21:45:18  pinnacle
# Replaced: ./vddraw/struct/VDdrwcopystr.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/08/21  16:27:26  pinnacle
# Replaced: vddraw/struct/VDdrwcopystr.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/08/16  14:50:10  pinnacle
# Created: vddraw/struct/VDdrwcopystr.I by azuurhou for vds.240
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
#include <math.h>
#define _INGR_EXTENSIONS
#include "bstypes.h"
#include "exdef.h"
#include "exmacros.h"
#include "nddef.h"
#include "vddrwattr.h"
#include "v_drwdef.h"
#include "v_drwapi.h"
#include "v_drw.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "VSdrw.h"


/*----------------------------------------------------------------------------*/
long	VDdrw_cpy_Garbage( in, out )

struct VD_s_drwGarbage		*in ;
struct VS_s_drwGarbage		*out ; {

	SetProc( VDdrw_cpy_Garbage ); Begin

	if( in ){
		out->temporary		= in->temporary ;
		out->next		= NULL ;
	}

	End ;
	return TRUE ;
}
/*----------------------------------------------------------------------------*/
long	VDdrw_cpy_Text( in, out )

struct VD_s_drwText		*in ;
struct VS_s_drwText		*out ; {

	SetProc( VDdrw_cpy_Text ); Begin

	out->buffer		= in->buffer ;
	out->bufsiz		= in->bufsiz ;
	out->curpos		= in->curpos ;

	End ;
	return TRUE ;
}
/*----------------------------------------------------------------------------*/
long	VDdrw_cpy_Info( in, out )

VD_drwInfo		*in ;
VSdrwInfo		*out ; {

	SetProc( VDdrw_cpy_Info ); Begin

	out->drwEnv		= in->drwEnv ;
	out->drwLbsys		= in->drwLbsys ;
	out->drwPlane		= in->drwPlane ;
	out->viewPlane		= in->viewPlane ;
	out->viewVector		= in->viewVector ;

	End ;
	return TRUE ;
}
/*----------------------------------------------------------------------------*/
long	VDdrw_cpy_Group( in, out )

VD_drwInputData		*in ;
VSdrwGroup		*out ; {

	long			msg, sts ;
	IGRint			i, 
				cnt,
				rfCount = 0 ;
	struct GRid		actMod,
				*rfList = NULL ,
				*idList = NULL ;

	SetProc( VDdrw_cpy_Group ); Begin

	sts	= MSSUCC ;
	msg	= MSSUCC ;

	out->elmCount		= 0 ;
	out->elmList		= NULL ;

	sts =
	ex$get_cur_mod(	osnum	= &actMod.osnum,
			id	= &actMod.objid );

	__DBGpr_str( " refSetName ", in->refSetName );

	sts =
	VDdrwMgrGetInfo(	&msg,
				in->drwInfo.drwEnv,
				VD_O_drw2dObj,
				in->refSetName,
				NULL,		/* Select Mask */
				&rfCount,	/* Number of objects. */
				&rfList,	/* Listof Objects */
				NULL );
	__CheckRC( sts, msg, "VDdrwMgrGetInfo", wrapup );

	/*
	 * Get the parent objects to check internal. This will be a 
	 * ACpretendin object for reference objects and a VDdrw3d or model
	 * object for local design processing.
	 */

	/*
	 * Allocate memory for reference input list of 'struct GRid' objects.
	 */
	__DBGpr_int(" rfCount ", rfCount );
	if( ! rfCount )	goto wrapup ;

	if( ! (idList = _MALLOC( rfCount, struct GRid ))){
		msg = MSFAIL ;
		goto wrapup ;
	}

	sts = VD_setGRids( actMod.osnum, rfCount, idList );

	for( i=0 ; i<rfCount ; i++ ){
		sts =
		_VD_SEND_OBJN(	rfList[i],
				NDnode.NDget_objects(	ND_ROOT, idList +i,
							1, NULL, 1, 1, &cnt ));
		if( !(sts&1))	idList[i].objid = NULL_OBJID ;
	}


	out->elmCount	= rfCount ;
	out->elmList	= idList ;

	idList	= NULL ;

	wrapup:
		if( !(sts & msg & 1)){
			_FREE( out->elmList );
			out->elmList = NULL ;
			out->elmCount = 0 ;
		}
	
		_FREE( idList );
		_FREE( rfList );
		End ;
		return TRUE ;
}
/*----------------------------------------------------------------------------*/
long	VDdrw_cpy_InputFiles( in, out )

VD_drwInputFiles	*in ;
VSdrwInputFiles		*out ; {

	int		i ;

	SetProc( VDdrw_cpy_InputFiles ); Begin

	/*
	 * Not needed during processing. ?????
	 */

	out->iScanned	= in->iScanned ;

        for( i = 0 ; i < VD_K_DRW_MAXINFILES ; i++ ) {
		out->stream[i]	= in->stream[i] ;
		out->lineno[i]  = in->lineno[i] ;
		strcpy( out->name[i], in->name[i] );
	}

	End ;
	return TRUE ;
}
/*----------------------------------------------------------------------------*/
long	VDdrw_cpy_TxPosition( in, out )

VD_drwTxPosition	*in ;
VSdrwTxPosition		*out ; {

	SetProc( VDdrw_cpy_TxPosition ); Begin

	out->voffVal		= in->voffVal ;
	out->hoffVal		= in->hoffVal ;

	__DBGpr_com(" loc ");

	switch(	in->loc ){
	case VD_middle		: out->loc = VSmiddle ;		break ;
        case VD_center		: out->loc = VScenter ;		break ;
        case VD_innermost	: out->loc = VSinnermost ;	break ;
        case VD_left		: out->loc = VSleft ;		break ;
        case VD_right		: out->loc = VSright ;		break ;
        case VD_top		: out->loc = VStop ;		break ;
        case VD_bottom		: out->loc = VSbottom ;		break ;
        case VD_1stEnd		: out->loc = VS1stEnd ;		break ;
        case VD_2ndEnd		: out->loc = VS2ndEnd ;		break ;
	default			: out->loc = VSmiddle ;		break ;
	}

	End ;

	__DBGpr_com(" voff ");

	switch( in->voff ){
	case VD_above		: out->voff = VSabove ;		break ;
	case VD_vcenter		: out->voff = VSvcenter ;	break ;
	case VD_below		: out->voff = VSbelow ;		break ;
	default			: out->voff = VSabove ;		break ;
	}

	__DBGpr_com(" hoff ");

	switch( in->hoff ){
	case VD_toTheLeft	: out->hoff = VStoTheLeft ;	break ;
	case VD_hcenter		: out->hoff = VShcenter ;	break ;
	case VD_toTheRight	: out->hoff = VStoTheRight ;	break ;
	default			: out->hoff = VShcenter ;	break ;
	}

	__DBGpr_com(" dir ");

	switch( in->dir ){
	case VD_horiz		: out->dir = VShoriz ;	break ;	
	case VD_para		: out->dir = VSpara ;	break ;	
	case VD_ortho		: out->dir = VSortho ;	break ;	
	default 		: out->dir = VShoriz ;	break ;	
	}


	__DBGpr_com(" rev ");

	switch( in->rev ){
	case VD_notReversed	: out->rev = VSnotReversed ;	break ;
	case VD_upsideDown	: out->rev = VSupsideDown ;	break ;
	case VD_rightToLeft	: out->rev = VSrightToLeft ;	break ;
	default 		: out->rev = VSnotReversed ;	break ;
	}

	End ;
	return TRUE ;
}
/*----------------------------------------------------------------------------*/

long	VDdrw_cpy_DspAttr( in, out )

VD_drwDspAttr		*in ;
VSdrwDspAttr		*out ; {

	SetProc( VDdrw_cpy_DspAttr ); Begin

	out->scale		= in->scale ;
	out->offset		= in->offset ;
	out->filledDisplay	= in->filledDisplay ;
	out->hiddenStyle	= in->hiddenStyle ;

	End ;
	return TRUE ;
}

/*----------------------------------------------------------------------------*/

long	VDdrw_cpy_ConstructData( in, out )

VD_drwConstructData	*in ;
VSdrwConstructData	*out ; {

	SetProc( VDdrw_cpy_ConstructData ); Begin

	out->viewConeAngle	= in->viewConeAngle ;
	out->textSymb		= in->textSymb ;
	out->elmDisplay		= in->elmDisplay ;
	out->elmLevel		= in->elmLevel ;

	VDdrw_cpy_DspAttr(	& in->dpAttr,	& out->dpAttr );
	VDdrw_cpy_TxPosition(	& in->textPos,	& out->textPos );

	End ;
	return TRUE ;
}

/*----------------------------------------------------------------------------*/

#ifdef	NOT_NEEDED

long	VDdrw_cpy_GraphicGroup( in, out )

VD_drwGraphicGroup	*in ;
VSdrwGraphicGroup	*out ; {

	SetProc( VDdrw_cpy_GraphicGroup ); Begin


	if( in ){
		out->count	= in->count ;
		out->list	= in->list ;
	}

	End ;
	return TRUE  ;
}

#endif

/*----------------------------------------------------------------------------*/
/* EXTERNAL	CALLED
/*----------------------------------------------------------------------------*/

long	VDdrw_ret_GraphicGroup( in, out )

VSdrwGraphicGroup	*in ;
VD_drwGraphicGroup	*out ; {

	SetProc( VDdrw_ret_GraphicGroup ); Begin

	if( in  && out ){
		out->count	= in->count ;
		out->list	= in->list ;
		in->list	= NULL ;
	}

	End ;
	return TRUE  ;
}

/*----------------------------------------------------------------------------*/
/* EXTERNAL	CALLED
/*----------------------------------------------------------------------------*/

long	VDdrw_cpy_InputData( in, out )

VD_drwInputData		*in ;
VSdrwInputData		*out ; {

	SetProc( VDdrw_cpy_InputData ); Begin

	out->elmId	= in->elmId ;
	out->elmEnv	= in->elmEnv ;
	out->appData	= in->appData ;

	strcpy(		out->constDefName,	in->constDefName );

	VDdrw_cpy_ConstructData(& in->defaults,		& out->defaults );
	VDdrw_cpy_Info(		& in->drwInfo,		& out->drwInfo );
	VDdrw_cpy_Group(	in,			& out->toBeDrawn );

	__DBGpr_com(" viewType ");

	switch( in->viewType ){
	case VD_fromTop		: out->viewType = VSfromTop ;		break ;
	case VD_fromBottom	: out->viewType = VSfromBottom ;	break ;
	case VD_fromSide	: out->viewType = VSfromSide ;		break ;
	case VD_endOn		: out->viewType = VSendOn ;		break ;
	case VD_unknownViewType	: out->viewType = VSunknownViewType ;	break ;
	case VD_anyViewType	: out->viewType = VSanyViewType;	break ;
	default			: out->viewType = VSunknownViewType ;	break ;
	}

#ifdef	NOT_NEEDED
	VDdrw_cpy_InputFiles(	& in->inputFiles,	& out->inputFiles );
#endif

	End ;
	return TRUE ;
}

/*----------------------------------------------------------------------------*/
/* EXTERNAL	CALLED
/*----------------------------------------------------------------------------*/

long	VDdrw_cpy_ExecData( in, out )

struct VD_s_drwExecData		*in ;
struct VS_s_drwExecData		*out ; {

	SetProc( VDdrw_cpy_ExecData ); Begin

	out->logFile		= in->logFile ;
	out->symbOverrides	= in->symbOverrides ;
	out->verbose		= in->verbose ;
	out->action		= in->action ;
	out->elmQuery		= in->elmQuery ;
	out->anchorPoint[0]	= in->anchorPoint[0] ;
	out->anchorPoint[1]	= in->anchorPoint[1] ;
	out->anchorPoint[2]	= in->anchorPoint[2] ;
	out->anchorCurve	= in->anchorCurve ;
	out->parsedElmType	= in->parsedElmType ;
	strcpy( out->parsedElmDesc,	in->parsedElmDesc );
	strcpy(	out->filter,		in->filter );
	strcpy(	out->viewCriterion,	in->viewCriterion );

	VDdrw_get_ElmType( out );
	
	VDdrw_cpy_ConstructData(& in->overrides,	& out->overrides );

	__DBGpr_com(" parsedViewType ");

	switch( in->parsedViewType ){
	case VD_fromTop		: out->parsedViewType = VSfromTop ;	break ;
	case VD_fromBottom	: out->parsedViewType = VSfromBottom ;	break ;
	case VD_fromSide	: out->parsedViewType = VSfromSide ;	break ;
	case VD_endOn		: out->parsedViewType = VSendOn ;	break ;
	case VD_unknownViewType	: out->parsedViewType = VSunknownViewType ;
					break ;
	case VD_anyViewType	: out->parsedViewType = VSanyViewType;	break ;
	default			: out->parsedViewType = VSunknownViewType ;
					break ;
	}

	__DBGpr_com(" txPosHelper ");

	switch( in->txPosHelper ){
	case VD_undefTxPosHelper: out->txPosHelper = VSundefTxPosHelper;break ;
        case VD_useAnchorPoint	: out->txPosHelper = VSuseAnchorPoint ;	break ;
        case VD_useAnchorCurve	: out->txPosHelper = VSuseAnchorCurve ;	break ;
        case VD_useFirstCurve	: out->txPosHelper = VSuseFirstCurve ;	break ;
        case VD_useAllCurves	: out->txPosHelper = VSuseAllCurves ;	break ;
	default			: out->txPosHelper = VSuseAllCurves ;	break ;
	}


	VDdrw_cpy_Text(		& in->textFormat,	& out->textFormat );

	out->garbageList = NULL ;
	if( in->garbageList )
		VDdrw_cpy_Garbage( in->garbageList, out->garbageList );

	out->lastGraphic = NULL ;

#ifdef	NOT_NEEDED
	out->tag		= in_tag ;
	VDdrw_cpy_execRes(	& in->tag,		& out->tag );

	if ( in->lastGraphic )
		VDdrw_cpy_GraphicGroup(	in->lastGraphic, out->lastGraphic );
#endif

	End ;
	return TRUE ;
}

/*----------------------------------------------------------------------------*/
/*	EXTERNAL CALL							      */
/*----------------------------------------------------------------------------*/

long	VDdrw_ret_viewType( in, out )

VSdrwInputData		*in ;
VD_drwInputData		*out ; {

	SetProc( VDdrw_ret_viewType ); Begin

        __DBGpr_com(" viewType ");

        switch( in->viewType ){
        case VSfromTop         : out->viewType = VD_fromTop ;           break ;
        case VSfromBottom      : out->viewType = VD_fromBottom ;        break ;
        case VSfromSide        : out->viewType = VD_fromSide ;          break ;
        case VSendOn           : out->viewType = VD_endOn ;             break ;
        case VSunknownViewType : out->viewType = VD_unknownViewType ;   break ;
        case VSanyViewType     : out->viewType = VD_anyViewType;        break ;
        default                : out->viewType = VD_unknownViewType ;	break ;
        }

	return	TRUE ;
}

/*----------------------------------------------------------------------------*/
/* EXTERNAL     CALLED
/*----------------------------------------------------------------------------*/

long    VDdrw_cpy_ArgList( in, out )

struct VD_s_drwArgLst         *in ;
struct VS_s_drwArgLst         *out ; {
IGRlong				msg;
struct VD_s_drwArgLst		*argv;
struct VD_s_execRes		vdRes;
struct VS_s_execRes		vsRes;

   SetProc( VDdrw_cpy_ArgList ); Begin

   out = NULL;

   for( argv = in; argv ; argv = argv->next )
   {
      vdRes = argv->arg ;

      switch( vdRes.type )
      {
	 case VD_int:  
	     vsRes.type = VS_int;
	     vsRes.v.ival = vdRes.v.ival ;
	     break;

         case VD_double:  
             vsRes.type = VS_double;
             vsRes.v.dval = vdRes.v.dval ;
             break;

	 case VD_string:
	     vsRes.type = VS_string;
	     strcpy( vsRes.v.sval, vdRes.v.sval );
	     break;
      }
      VSdrwAddArg( &msg, &vsRes, out );
   }

   End
   return TRUE;
}


end implementation VDSroot ;

