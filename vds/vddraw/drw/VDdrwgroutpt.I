/* $Id: VDdrwgroutpt.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwgroutpt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwgroutpt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/06/03  17:56:14  pinnacle
# Replaced: vddraw/drw/VDdrwgroutpt.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/12/26  19:36:00  pinnacle
# Replaced: vddraw/drw/VDdrwgroutpt.I for:  by v250_int for vds
#
# Revision 1.3  1997/10/29  14:45:52  pinnacle
# Replaced: vddraw/drw/VDdrwgroutpt.I for:  by rchennup for vds
#
# Revision 1.2  1997/07/08  14:09:32  pinnacle
# Replaced: vddraw/drw/VDdrwgroutpt.I for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.3  1996/11/03  15:41:54  pinnacle
# Replaced: vddraw/drw/VDdrwgroutpt.I for:  by v241_int for vds.241
#
# Revision 1.2  1996/11/02  16:16:20  pinnacle
# Replaced: vddraw/drw/VDdrwgroutpt.I for:  by v241_int for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.8  1996/06/07  21:09:34  pinnacle
# Replaced: vddraw/drw/VDdrwgroutpt.I for:  by v240_int for vds.240
#
# Revision 1.7  1995/08/16  14:50:50  pinnacle
# Replaced: vddraw/drw/VDdrwgroutpt.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			adz		creation date
 *	08/15/95	adz		code correction.
 *	11/03/96	adz		Add Centerline call.
 *	07/07/97	yzhu		Add symbology: VD_drwCstSymbology.
 *      06/03/98        Ming            TR179800595
 *
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
#include "expression.h"
#include "acrepdef.h"
#include "acmacros.h"
#include "expmacros.h"
#include "EMSmsgdef.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_drwdef.h"
#include "v_drwapi.h"
#include "VDdrwgrammar.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*
 * Includes for function prototypes.
 */
#include "v_drwproto.h"

from	ACcpx_defn	import	ACgive_temp_desc;

%safe
const char* VD_drwOUTPUTnotSupported = "!!! Output '%s' not supported for %s\n";
%endsafe


/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
/* Graphical Function used for the Visualization Process	              */
/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, cog ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTcog ); Begin

	sts = VD_drwAnchorPoint( &msg, inp, xData, "sol",
					VD_drwAnchorCtrOfGrv ) ;
	
	xData->txPosHelper = VD_useAllCurves ;
	sts = VDdrwcstPoint ( &msg, inp, xData, outpgr);

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTcog */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, edges_A ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTedges_A ); Begin

	sts = VD_drwCstConstVisEdges( &msg, inp, xData, outpgr,
					VD_K_DRW_PROCESS_A ) ;

	xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTedges_A */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, edges_B ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTedges_B ); Begin

	sts = VD_drwCstConstVisEdges( &msg, inp, xData, outpgr,
					VD_K_DRW_PROCESS_B ) ;

	xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTedges_B */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, edges_C ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTedges_C ); Begin

	sts = VD_drwCstConstVisEdges( &msg, inp, xData, outpgr,
					VD_K_DRW_PROCESS_C ) ;

	xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTedges_C */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, env_edges_A ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTenv_edges_A ); Begin

	sts = VD_drwCstConstVisEdges( &msg, inp, xData, outpgr,
					VD_K_ENV_PROCESS_A ) ;

	xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTenv_edges_A */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, env_edges_B ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTenv_edges_B ); Begin

	sts = VD_drwCstConstVisEdges( &msg, inp, xData, outpgr,
					VD_K_ENV_PROCESS_B ) ;

	xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTenv_edges_B */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, env_edges_C ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTenv_edges_C ); Begin

	sts = VD_drwCstConstVisEdges( &msg, inp, xData, outpgr,
					VD_K_ENV_PROCESS_C ) ;

	xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTenv_edges_C */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, member_A ) {

	long		sts, msg ;
	VD_tktxt	member ;

	SetProc( VD_drwOUTPUTmember_A ); Begin

	CHECK_ARGCOUNT( 1 )

	VD_drwStrVal( &arglist->arg, member ) ;

	sts = VD_drwCstConstMemEdges( &msg, inp, xData, member, outpgr,
					VD_K_DRW_PROCESS_A ) ;

	xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTmember_A */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, member_B ) {

	long		sts, msg ;
	VD_tktxt	member ;

	SetProc( VD_drwOUTPUTmember_B ); Begin

	CHECK_ARGCOUNT( 1 )

	VD_drwStrVal( &arglist->arg, member ) ;

	sts = VD_drwCstConstMemEdges( &msg, inp, xData, member, outpgr,
					VD_K_DRW_PROCESS_B ) ;

	xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTmember_B */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, member_C ) {

	long		sts, msg ;
	VD_tktxt	member ;

	SetProc( VD_drwOUTPUTmember_C ); Begin

	CHECK_ARGCOUNT( 1 )

	VD_drwStrVal( &arglist->arg, member ) ;

	sts = VD_drwCstConstMemEdges( &msg, inp, xData, member, outpgr,
					VD_K_DRW_PROCESS_C ) ;

	xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTmember_C */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, centerline ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTcenterline ); Begin

	sts = OM_S_SUCCESS ;
        msg = MSSUCC ;

        sts = VD_drwCstConstCenterLine( &msg, inp, xData, outpgr, 0 );
        xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTcenterline */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, centerline_A ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTcenterline_A ); Begin

	sts = OM_S_SUCCESS ;
	msg = MSSUCC ;

        sts = VD_drwCstConstCenterLine( &msg, inp, xData, outpgr, 
					VD_K_DRW_PROCESS_A );
        xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTcenterline_A */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, centerline_B ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTcenterline_B ); Begin

	sts = OM_S_SUCCESS ;
	msg = MSSUCC ;

        sts = VD_drwCstConstCenterLine( &msg, inp, xData, outpgr, 
					VD_K_DRW_PROCESS_B );
        xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTcenterline_B */

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, axis_A ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTaxis_A ); Begin

	sts = OM_S_SUCCESS ;
	msg = MSSUCC ;

        sts = VD_drwCstConstCenterLine( &msg, inp, xData, outpgr, 
						VD_K_DRW_PROCESS_A );
        xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTaxis_A */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, axis_B ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTaxis_B ); Begin

	sts = OM_S_SUCCESS ;
	msg = MSSUCC ;

        sts = VD_drwCstConstCenterLine( &msg, inp, xData, outpgr, 
						VD_K_DRW_PROCESS_B );
        xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTaxis_B */

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
/* Graphical Function used for the Volume Cut Process.		              */
/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, volume_cut ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTvolume_cut ); Begin

	sts = VD_drwCstConstVolCuts( &msg, inp, xData, outpgr ) ;

	xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTvolume_cut */

/* TR179800595 */
#argsused
IMPLEMENT_OUTPUT( VD, volume_mem ) {

	long		sts, msg ;
	VD_tktxt	member ;

	SetProc( VD_drwOUTPUTvolume_mem ); Begin

	CHECK_ARGCOUNT( 1 )

	VD_drwStrVal( &arglist->arg, member );

	sts = VD_drwCstConstVolMems( &msg, inp, xData, member, outpgr );

	xData->txPosHelper = VD_useAllCurves;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

}  /* VD_drwOUTPUTvolume_mem */

#argsused
IMPLEMENT_OUTPUT( VD, placemacro ) {

long			sts, msg;
VD_tktxt		macName;
struct	GRid		macId, id;
struct	GRobj_env	macTemp[200];
int			i;
VD_drwArgLst		*p;
struct	GRsymbology	symb;
VD_tktxt		str;
struct	GRid		defId;
int			nbTemp;
struct	stemp		*tempDesc;

	SetProc( VD_drwOUTPUTplacemacro ); Begin

	// argument :	Cell name, arglist 
	VD_drwStrVal( &arglist->arg, macName );

	// get macro definition Id
        defId.objid    = NULL_OBJID;
        sts = ac$find_macro_defn(       action          = ACfind_load,
                                        macro_name      = macName,
                                        p_macro_defn_id = &defId );
        if( ! (sts&1) || defId.objid == NULL_OBJID ){
		VD_drwPrintf("!!! %s(): macro %s is not into the placement list\n",
					"placemacro", macName );
		goto	wrapup;
	}

	// get template description
	sts = om$send(	msg	 = message ACcpx_defn.ACgive_temp_desc
					( &nbTemp, &tempDesc ),
			senderid = NULL_OBJID,
			targetid = defId.objid,
			targetos = defId.osnum );
	__CheckRC( sts, 1, "ACcpx_defn.ACgive_temp_desc", wrapup );

	// get assoc template
	for( i=0, p=arglist->next; i<nbTemp && i<argc-1 && p; i++, p=p->next ){

		switch( p->arg.type ){

		case VD_int :
		case VD_double :
		case VD_string :

			if( tempDesc[i].type == double_type ){
				sts = exp$create(	
					exp_value  = VD_drwDblVal(&p->arg),
					osnum      = inp->drwInfo.drwEnv->md_id.osnum,
				     	p_exp_id   = &macTemp[i].obj_id.objid,
	        	        	p_osnum    = &macTemp[i].obj_id.osnum );
				__CheckRC( sts, 1, "exp$create", wrapup );
			} else {

				sts = exp$create(	
					exp_syntax = VD_drwStrVal(&p->arg, str),
					osnum      = inp->drwInfo.drwEnv->md_id.osnum,
			     		p_exp_id   = &macTemp[i].obj_id.objid,
	        			p_osnum    = &macTemp[i].obj_id.osnum,
					type_rq	   = EXP_TEXT );
				__CheckRC( sts, 1, "exp$create", wrapup );
			  }

			macTemp[i].mod_env	= *inp->drwInfo.drwEnv;
			break;

		case VD_object :
			macTemp[i] =  p->arg.v.oval;
			break;

		default :	printf(" unknown case \n");
				return	xfFAILURE;
		}
	}

	// set symbologie
	symb.display_attr	= xData->overrides.elmDisplay;
	symb.level		= xData->overrides.elmLevel;

	// place macro
	sts = vd$plmacro(	macName	= macName,
				tplNb	= argc - 1,
				tplList	= macTemp,
				props	= AChdr_nodisplay,
//				symb	= &symb,
				env	= inp->drwInfo.drwEnv,
				macId	= &macId );
	if( ! (sts&1)){
		VD_drwPrintf("!!! placemacro(): macro can not be constructed\n");
		goto	wrapup;
	}

	// manage the symbologie in a ligth way
	if( xData->symbOverrides & VD_drwLevelOverriden )
		sts = om$send(	msg	 = message GRvg.GRchglevel
					( &msg, &xData->overrides.elmLevel ),
				senderid = NULL_OBJID,
				targetid = macId.objid,
				targetos = macId.osnum );

	if( xData->symbOverrides & VD_drwColorOverriden )
		sts = om$send(	msg	 = message GRvg.GRchgcolor( 
						&msg,
						NULL,
						&xData->overrides.elmDisplay.color ),
				senderid = NULL_OBJID,
				targetid = macId.objid,
				targetos = macId.osnum );

	if( xData->symbOverrides & VD_drwWeightOverriden )
		sts = om$send(	msg	 = message GRvg.GRchgweight( 
						&msg,
						&xData->overrides.elmDisplay.weight ),
				senderid = NULL_OBJID,
				targetid = macId.objid,
				targetos = macId.osnum );

	if( xData->symbOverrides & VD_drwStyleOverriden )
		sts = om$send(	msg	 = message GRvg.GRchgstyle( 
						&msg,
						&xData->overrides.elmDisplay.style ),
				senderid = NULL_OBJID,
				targetid = macId.objid,
				targetos = macId.osnum );

	// move_to_root
	sts = om$send(	msg	 = message NDnode.NDmove_to_root(
					&msg,
					&id,
					inp->drwInfo.drwEnv ),
			senderid = NULL_OBJID,
			targetid = macId.objid,
			targetos = macId.osnum );

	// set output
	outpgr->list	= (struct GRid *)malloc(sizeof(struct GRid));
	outpgr->list[0]	= macId;
	outpgr->count	= 1;

wrapup :

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;
}


/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
/* Graphical Function used for the Attribute Driven Symbology                 */
/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, symbology ) {

	long		sts, msg ;

	SetProc( VD_drwOUTPUTsymbology ); Begin

	sts  = OM_S_SUCCESS ;
	msg = MSSUCC ;

	sts = VD_drwCstSymbology( &msg, inp, xData, outpgr ) ;
	xData->txPosHelper = VD_useAllCurves ;

	End
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VD_drwOUTPUTsymbology */
/*----------------------------------------------------------------------------*/
long VD_drwOutputGraphic( msg, inp, xData, output, text, arglist, outdata )

long			*msg ;
VD_drwInputData		*inp ;
VD_drwExecData		*xData ;
const char		*output ;
int			text ;
const VD_drwArgLst	*arglist ;
VD_drwOutputData		**outdata ; {

	VD_drwGraphicGroup	outputgr ;
	long			sts ;
	int			argc ;	/* Argument count	*/
	const VD_drwArgLst	*argv ;	/* Argument list	*/

	SetProc( VD_drwOutputGraphic ); Begin

	outputgr.count = 0 ; outputgr.list = NULL ;

	for( argv = arglist, argc = 0 ; argv ; argv = argv->next ) argc++ ;

	if( text ) {
		sts = VD_drwCstSymbol( msg, inp, xData, xData->lastGraphic,
					&outputgr ) ;

	} else {
		VD_xfRC rc = ((VD_drwOutput) xData->action)(
							inp,
							xData,
							output,
							arglist,
							argc,
							&outputgr ) ;
		if( rc == xfSUCCESS ) {
			sts  = OM_S_SUCCESS ;
			*msg = MSSUCC ;
		} else {
			sts  = OM_W_ABORT ;
			*msg = MSFAIL ;
		}
	}

	if( *msg & 1 ) {
		VD_drwOutputData	*new = VD_drwNewOutputData( outdata ) ;
		if( new ) {
			new->set		= outputgr ;
			new->tag		= xData->tag ;
			new->isText		= text ;
			if( !text ) xData->lastGraphic = &new->set ;
		} else {
			vd_$bulk_delete(	grids	= outputgr.list,
					count	= outputgr.count,
					theEnv	= inp->drwInfo.drwEnv ) ;
			if( outputgr.list ) free( outputgr.list ) ;
			*msg = EMS_E_NoDynamicMemory ;
			sts  = 0 ;
		}
	}

	End
	return sts ;

} /* VD_drwOutputGraphic */
/*----------------------------------------------------------------------------*/
long VD_drwUndefinedAction __(( void )) {

	fprintf( stderr,
		 "!!! Undefined action reached in Drawing Extraction Language\n" ) ;
	return 0 ;

} /* VD_drwUndefinedAction */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

