/* $Id: VSdrwgroutpt.I,v 1.3 2001/02/15 23:27:31 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        vsdrawing/VSdrwgroutpt.I
 *
 * Description: Output routine implementations.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwgroutpt.I,v $
 *      Revision 1.3  2001/02/15 23:27:31  ramarao
 *      Implemented CR# 4038.
 *
 *      Revision 1.2  2001/01/16 22:18:50  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/07/17  15:26:56  pinnacle
# Created: struct/vsdrawing/VSdrwgroutpt.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/02/25  16:04:26  pinnacle
# Replaced: vsdrawing/VSdrwgroutpt.I for:  by rchennup for struct
#
# Revision 1.3  1997/12/26  10:52:38  pinnacle
# Replaced: vsdrawing/VSdrwgroutpt.I for:  by rchennup for struct
#
# Revision 1.2  1997/10/29  15:42:34  pinnacle
# Replaced: vsdrawing/VSdrwgroutpt.I for:  by rchennup for struct
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/29/97   Rama Rao     Header Creation & Add placemacro
 *************************************************************************/

class implementation VSfeature ;

#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "msdef.h"
#include "nddef.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "gotextdef.h"
#include "fontdef.h"
#include "font.h"
#include "acmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "vsslcdef.h"
#include "vsattr.h"
#include "vsslc.h"
#include "vsdrwdef.h"
#include "vsdrwapi.h"
#include "VSdrwgrammar.h"
#include "vsjointdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define vsDEBUG 1
#define vserrDEBUG 1

/*
 * Includes for function prototypes.
 */
#include "vsdrwproto.h"

from	ACcpx_defn	import	ACgive_temp_desc, 
				ACgive_feet_desc,
				ACgive_name ;
%safe
const char* VSdrwOUTPUTnotSupported = "!!! Output '%s' not supported for %s\n" ;
%endsafe

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VS, intersection ) {

	long		sts, msg ;
	const char	*type = xData->parsedElmDesc ;

	if(    !strcmp( type, "beam" )
	    || !strcmp( type, "stiffener" ) ) {
		sts = VSdrwCstBeamProf( &msg, inp, xData, outpgr ) ;
	} else if( !strcmp( type, "plate" ) ) {
		sts = VSdrwCstPlateVwIntersection( &msg, inp, xData, outpgr ) ;
	} else {
		WRONG_OUTPUT ;
	}

	xData->txPosHelper = VSuseFirstCurve ;
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VSdrwOUTPUTintersection */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VS, profile ) {

	long		sts, msg ;
	const char	*type = xData->parsedElmDesc ;

	if(    !strcmp( type, "beam" )
	    || !strcmp( type, "stiffener" ) ) {
		sts = VSdrwCstBeamProf( &msg, inp, xData, outpgr ) ;
	} else {
		WRONG_OUTPUT ;
	}

	xData->txPosHelper = VSuseFirstCurve ;
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VSdrwOUTPUTprofile */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VS, projection ) {

	long		sts, msg ;
	char		option[30];
	const char	*type = xData->parsedElmDesc ;
	VSdspRep	rep ;

	if(    !strcmp( type, "beam" )
	    || !strcmp( type, "stiffener" ) ) {
		om$send( msg	  = message ACncpx.ACget_NV_rep( &rep ),
			 senderid = inp->elmId->objid,
			 targetid = inp->elmId->objid,
			 targetos = inp->elmId->osnum ) ;
		if( rep != AC_2D_REP ) {
			sts = VSdrwCstPartProj( &msg, inp, xData, outpgr ) ;
		} else {
                        if( argc == 1 ) VD_drwStrVal( &arglist->arg, option );
                        else            strcpy( option, "" );

			sts = VSdrwCstBeamAxis( &msg, inp, xData, 
						option, outpgr ) ;
		}
		xData->txPosHelper = VSuseAllCurves ;
	} else if( !strcmp( type, "plate" ) ) {
		sts = VSdrwCstPartProj( &msg, inp, xData, outpgr ) ;
		xData->txPosHelper = VSuseAllCurves ;
	} else {
		WRONG_OUTPUT ;
	}

	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VSdrwOUTPUTprojection */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VS, axis ) {

	long		sts, msg ;
	char		option[30];
	const char	*type = xData->parsedElmDesc ;

	if(    !strcmp( type, "beam" )
	    || !strcmp( type, "stiffener" ) ) {
                if( argc == 1 ) VD_drwStrVal( &arglist->arg, option );
                else            strcpy( option, "" );
		sts = VSdrwCstBeamAxis( &msg, inp, xData, option, outpgr ) ;
	} else {
		WRONG_OUTPUT ;
	}

	xData->txPosHelper = VSuseFirstCurve ;

	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VSdrwOUTPUTaxis */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VS, member ) {

	long		sts, msg ;
	VStktxt		member ;

	CHECK_ARGCOUNT( 1 )

	VSdrwStrVal( &arglist->arg, member ) ;

	sts = VSdrwCstConstMember( &msg, inp, xData, member, outpgr ) ;

	xData->txPosHelper = VSuseAllCurves ;

	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VSdrwOUTPUTmember */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VS, contour ) {

	long		sts, msg ;
	char		option[30];
	const char	*type = xData->parsedElmDesc ;

	if( !strcmp( type, "plate" ) ) {
                if( argc == 1 ) VSdrwStrVal( &arglist->arg, option );
                else            strcpy( option, "" );
		sts = VSdrwPlateContour( &msg, inp, xData, option, outpgr ) ;
	} else {
		WRONG_OUTPUT ;
	}

	xData->txPosHelper = VSuseFirstCurve ;

	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VSdrwOUTPUTcontour */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VS, edge ) {

	long		sts, msg ;
	const char	*type = xData->parsedElmDesc ;

	if( !strcmp( type, "plate" ) ) {
		sts = VSdrwPlateBottomSide( &msg, inp, xData, outpgr ) ;
	} else {
		WRONG_OUTPUT ;
	}

	xData->txPosHelper = VSuseFirstCurve ;

	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VSdrwOUTPUTedge */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VS, weldline) {

	long		sts, msg ;
	const char	*type = xData->parsedElmDesc ;

	if( !strcmp( type, "joint" ) ) {
		sts = VSdrwJoint( &msg, inp, xData, outpgr ) ;
	} else {
		WRONG_OUTPUT ;
	}

	xData->txPosHelper = VSuseAllCurves ;

	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VSdrwOUTPUTweldline */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VS, placemacro ) {

long			sts, msg;
VStktxt			macName;
struct	GRid		macId, id;
struct	GRobj_env	macTemp[200];
int			i;
VSdrwArgLst		*p;
VSxfRC			rc;
struct	GRsymbology	symb;
VStktxt			str;
struct	GRid		defId;
int			nbTemp;
struct	stemp		*tempDesc;


	// argument :	Cell name, arglist 
	VSdrwStrVal( &arglist->arg, macName );

	// get macro definition Id
        defId.objid    = NULL_OBJID;
        sts = ac$find_macro_defn(       action          = ACfind_load,
                                        macro_name      = macName,
                                        p_macro_defn_id = &defId );
        if( ! (sts&1) || defId.objid == NULL_OBJID ){
		VSdrwPrintf("!!! %s(): macro %s is not into the placement list\n",
					"placemacro", macName );
		rc = xfFAILURE;
		goto	wrapup;
	}

	// get template description
	sts = om$send(	msg	 = message ACcpx_defn.ACgive_temp_desc
					( &nbTemp, &tempDesc ),
			senderid = NULL_OBJID,
			targetid = defId.objid,
			targetos = defId.osnum );
	as$status( sts = sts );

	// get assoc template
	for( i=0, p=arglist->next; i<nbTemp && i<argc-1 && p; i++, p=p->next ){

		switch( p->arg.type ){

		case VS_int :
		case VS_double :
		case VS_string :

			if( tempDesc[i].type == double_type ){
				sts = exp$create(	
					exp_value  = VSdrwDblVal(&p->arg),
					osnum      = inp->drwInfo.drwEnv->md_id.osnum,
				     	p_exp_id   = &macTemp[i].obj_id.objid,
	        	        	p_osnum    = &macTemp[i].obj_id.osnum );
				as$status( sts = sts );

			} else {

				sts = exp$create(	
					exp_syntax = VSdrwStrVal(&p->arg, str),
					osnum      = inp->drwInfo.drwEnv->md_id.osnum,
			     		p_exp_id   = &macTemp[i].obj_id.objid,
	        			p_osnum    = &macTemp[i].obj_id.osnum,
					type_rq	   = EXP_TEXT );
				as$status( sts = sts );
			  }

			macTemp[i].mod_env	= *inp->drwInfo.drwEnv;
			break;

		case VS_object :
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
		VSdrwPrintf("!!! placeMacro(): macro can not be constructed\n");
		rc = xfFAILURE;
		goto	wrapup;
	}

	// manage the symbologie in a ligth way
	if( xData->symbOverrides & VSdrwLevelOverriden )
		sts = om$send(	msg	 = message GRvg.GRchglevel
					( &msg, &xData->overrides.elmLevel ),
				senderid = NULL_OBJID,
				targetid = macId.objid,
				targetos = macId.osnum );

	if( xData->symbOverrides & VSdrwColorOverriden )
		sts = om$send(	msg	 = message GRvg.GRchgcolor( 
						&msg,
						NULL,
						&xData->overrides.elmDisplay.color ),
				senderid = NULL_OBJID,
				targetid = macId.objid,
				targetos = macId.osnum );

	if( xData->symbOverrides & VSdrwWeightOverriden )
		sts = om$send(	msg	 = message GRvg.GRchgweight( 
						&msg,
						&xData->overrides.elmDisplay.weight ),
				senderid = NULL_OBJID,
				targetid = macId.objid,
				targetos = macId.osnum );

	if( xData->symbOverrides & VSdrwStyleOverriden )
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

	rc = xfSUCCESS;

wrapup :

return	rc;
} /* VSdrwOUTPUTplacemacro */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VS, set_joint_geom ) {
     IGRint			i, args_cnt, *purpose;
     IGRlong			sts, msg=xfSUCCESS;
     const  VSdrwArgLst		*p;
     struct GRid		joint_id;
     struct GRmd_env            md_env;
     struct GRvg_construct   	cst ;           /* My construction list */
     struct GRsymbology      	mySymb ;        /* My symbology         */

	joint_id = inp->toBeDrawn.elmList[inp->toBeDrawn.elmCount-1];

	purpose = (IGRint *) inp->appData;

        /*
         * Fill construction list.
         */
        sts = om$send(  msg     = message GRvg.GRgetsymb( &msg, &mySymb ),
                        mode    = *purpose & VS_K_InitialPlacement
                                        ? OM_e_wrt_message
                                        : OM_e_wrt_object,
			senderid = joint_id.objid,
                        targetid = joint_id.objid,
			targetos = joint_id.osnum   );
        __CheckRC( sts, msg, "GRvg.GRgetsymb", wrapup ) ;

	if( xData->symbOverrides & VSdrwLevelOverriden )
	    mySymb.level = xData->overrides.elmLevel;

	if( xData->symbOverrides & VSdrwColorOverriden )
	    mySymb.display_attr.color = xData->overrides.elmDisplay.color;

	if( xData->symbOverrides & VSdrwWeightOverriden )
	    mySymb.display_attr.weight = xData->overrides.elmDisplay.weight;

	if( xData->symbOverrides & VSdrwStyleOverriden )
	    mySymb.display_attr.style = xData->overrides.elmDisplay.style;

        vs$fill_cnst_list(      Msg		= &msg,
				Env_info        = inp->drwInfo.drwEnv,
                                Display         = &mySymb.display_attr,
                                Level           = mySymb.level,
                                Cnst_list       = cst ) ;

	args_cnt = 0;

	for( i=0, p=arglist; p; i++, p=p->next ){

		switch( p->arg.type ){

		case VS_object :
			++args_cnt;
 		    break;

		case VS_int :
		case VS_double :
		case VS_string :

		default :	printf(" unknown case \n");
				return	xfFAILURE;
		}
	}

	if( !args_cnt )
	{
	   printf(" Error!!! Send objects as Input\n" );
	   return  xfFAILURE;
	}

	outpgr->count = args_cnt;

	outpgr->list  = _MALLOC( args_cnt, struct GRid );

	for( i=0, p=arglist; p; i++, p=p->next ){

		switch( p->arg.type ){

		case VS_object :
		    /*
		     * Need not make a copy of another jointGroup macro
		     * We need to put only the user defined symbology to the
		     * joint group
		     */
		    if( vs$is_ancestry_valid( object  = &p->arg.v.oval.obj_id,
					      classid = OPP_ACcpx_class_id )  )
		    {
			struct GRid	MacroDefId ;
			char		*macName = NULL ;

			/*
			 * object might be a joint group.
			 */
			sts = om$send ( msg = message ACcpx.find_macro( 
							&MacroDefId ),
					senderid = NULL_OBJID,
					targetid = p->arg.v.oval._objid,
					targetos = p->arg.v.oval._osnum );
			__CheckRC( sts, 1, "find_macro", wrapup );

			sts  = om$send ( msg = message ACcpx_defn.ACgive_name(
								&macName ),
					senderid = NULL_OBJID,
					targetid = MacroDefId.objid,
					targetos = MacroDefId.osnum);
			__CheckRC( sts, 1, "ACgive_name", wrapup );

			if( strcmp ( macName , VS_K_jnJointGroup ) == 0 )
			{
				outpgr->list[i] = p->arg.v.oval.obj_id;
				goto put_symbology;
			}
		    } 

		    outpgr->list[i].osnum = cst.env_info->md_id.osnum;
		    md_env = p->arg.v.oval.mod_env;

   		    sts = om$send(msg = message GRgraphics.GRcopy(
                                                &msg,
						&md_env,
                                                cst.env_info,
                                                &outpgr->list[i].objid ),
                                senderid = NULL_OBJID,
                                targetid = p->arg.v.oval._objid,
                                targetos = p->arg.v.oval._osnum   );
put_symbology :
   		    sts = om$send(  msg = message GRvg.GRputsymb( 
							&msg, &mySymb ),
                     		senderid = NULL_OBJID,
                     		targetid = outpgr->list[i].objid,
                     		targetos = outpgr->list[i].osnum   );

 		    break;

		case VS_int :
		case VS_double :
		case VS_string :

		default :	printf(" unknown case \n");
				return	xfFAILURE;
		}
	}

wrapup :
	return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VSdrwOUTPUTset_joint_geom */
/*----------------------------------------------------------------------------*/
long VSdrwOutputGraphic( msg, inp, xData, output, text, arglist, outdata )

long			*msg ;
VSdrwInputData		*inp ;
VSdrwExecData		*xData ;
const char		*output ;
int			text ;
const VSdrwArgLst	*arglist ;
VSdrwOutputData		**outdata ; {

	VSdrwGraphicGroup	outputgr ;
	long			sts ;
	int			argc ;	/* Argument count	*/
	const VSdrwArgLst	*argv ;	/* Argument list	*/

	outputgr.count = 0 ; outputgr.list = NULL ;

	for( argv = arglist, argc = 0 ; argv ; argv = argv->next ) argc++ ;

	if( text ) {
		sts = VSdrwCstSymbol( msg, inp, xData, xData->lastGraphic,
					&outputgr ) ;

	} else {
		VSxfRC rc = ((VSdrwOutput) xData->action)(
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
		VSdrwOutputData	*new = VSdrwNewOutputData( outdata ) ;
		if( new ) {
			new->set		= outputgr ;
			new->tag		= xData->tag ;
			new->isText		= text ;
			if( !text ) xData->lastGraphic = &new->set ;
		} else {
			vs$bulk_delete(	grids	= outputgr.list,
					count	= outputgr.count,
					theEnv	= inp->drwInfo.drwEnv ) ;
			if( outputgr.list ) free( outputgr.list ) ;
			*msg = EMS_E_NoDynamicMemory ;
			sts  = 0 ;
		}
	}
	return sts ;

} /* VSdrwOutputGraphic */
/*----------------------------------------------------------------------------*/
long VSdrwUndefinedAction __(( void )) {

	fprintf( stderr,
		 "!!! Undefined action reached in Drawing Extraction Language\n" ) ;
	return 0 ;

} /* VSdrwUndefinedAction */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

