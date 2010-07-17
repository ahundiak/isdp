/* $Id: VLpcUserFunk.I,v 1.10 2002/04/22 14:58:26 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/pcard/VLpcUserFunk.I
 *
 * Description: Definition PC User Function used with Strudel.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLpcUserFunk.I,v $
 *      Revision 1.10  2002/04/22 14:58:26  ramarao
 *      Commented the annoying prints in the back screen.
 *
 *      Revision 1.9  2002/04/02 19:54:09  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/10/17 22:49:01  jayadev
 *      fix for TR#5216
 *
 *      Revision 1.7  2001/03/12 21:03:55  ramarao
 *      Changes to accept ~~orientation1 && ~~orientation2.
 *
 *      Revision 1.6  2001/02/20 01:05:34  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.5  2001/02/08 17:25:12  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/01/28 18:38:43  ramarao
 *      Implemented CR# MP 4301 on Stiffner Automarking process.
 *
 *      Revision 1.3  2001/01/22 15:58:13  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/16 19:21:09  ramarao
 *      *** empty log message ***
 *
# Revision 1.3  2000/12/22  18:58:14  pinnacle
# Replaced: loft/src/pcard/VLpcUserFunk.I for:  by rchennup for Service Pack
#
# Revision 1.7  2000/03/23  21:43:50  pinnacle
# Replaced: src/pcard/VLpcUserFunk.I for:  by impd252 for loft
#
# Revision 1.6  2000/03/03  21:08:30  pinnacle
# Change in getAttributeVal() function.
#
# Revision 1.5  2000/03/01  19:25:04  pinnacle
# Header Creation and Added VLgetRollMacOnStiff() function.
#
 *
 * History:
 * MM/DD/YY   AUTHOR       DESCRIPTION
 * 04/05/94   LLC          File Creation.
 * 03/01/00   Rama Rao     Header Creation and Added VLgetRollMacOnStiff() 
 * 03/03/00   Rama Rao     In the getAttributeVal function, if the attribute is
 *			   not found in user collection, check in system coll.
 * 03/23/00   Rama Rao	   Added isWebRight and pcBorderName as globals.
 * 10/17/00   Jayadev      Added VLpcDoubleCutMacro() for TR# MP5216 
 *************************************************************************/

class implementation VLpcAbst;

#include <stdio.h>
#include "igrdef.h"
#include "igr.h"
#include "AS_status.h"
#include "grdpbmacros.h"

#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "vsdrwapi.h"
#include "acrepdef.h"
#include "vsmiscmacros.h"
#include "vsdpb.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vlpcdef.h"
#include "vlpc.h"
#include "vlpcmacros.h"
#include "vlsdldef.h"
#include "vlsdl.h"
#include "vlsdlmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDobj.h"
#include "vlquerydef.h"
#include "nddef.h"
#include "grmacros.h"
#include "vlmsg.h"
#include "vldbgmacros.h"

#define vsDEBUG		1
#define vserrDEBUG	1

extern	GRclassid	OPP_ACncpx_class_id, OPP_nci_macro_class_id,
			OPP_ACconst_class_id, OPP_ACdyn_col_class_id,
			OPP_VSimgFeature_class_id;

from    VSfeature	import  VSforwardToSource;
from	VSbeam		import	VSextractProfile, VSgetSupportAxis, 
				VSgetBeamLength;
from	GRgencs		import	GRgetmatrix;
from	ACrg_collect	import	ACmod_list_attribute, ACadd_list_attribute,
				ACget_named_attribute, ACset_list_attribute;
from	ACpretend	import	ACfind_parent;
from	ACcpx_defn	import	ACgive_name;
from	ACheader	import	ACfind_model;
from	VDlink		import	ACget_model_list;

#if ISDP_MAKE_SP
extern int             	VLInstPointCounter;
#else
       int             	VLInstPointCounter;
#endif

extern int		isWebRight;
extern char		pcBorderName[DI_PATH_MAX];

extern	long VLgetCsStiff();
extern   OM_S_CHANSELECT AS_to_owner;


/* -------------------- FCT VLdrwISOFTYPErefMarkBlock() -----------	*/
/* -------------------- ALIAS refMarkBlock IS OF TYPE  ---------------	*/
#argsused
IMPLEMENT_ISOFTYPE( VL, refMarkBlock ) {

long			sts;
struct	ACrg_coll	attr;
GRname			cmd;
struct	GRid		defId;
char			*macDef;


	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "NOCLASS1" );
	if( DRW_wantType ){

		DRW_elmType = 0;

		// get macro def Id
		cmd[0] = '\0';
		inp->constDefName[0] = '\0';
		sts = VLgetOperName( NULL, DRW_elmId, 
						VLPC_DEF_ATT_CMD, cmd );
		if( ! (sts&1))	return;

		if( strcmp( cmd, VLPC_REF_MARK_CMD ) )	return;

		DRW_elmType	= VL_M_PlcSeam;

		// get macro definition
		sts = om$send(	msg	 = message ACcpx.find_macro( &defId ),
				targetid = DRW_elmId->objid,
				targetos = DRW_elmId->osnum,
				senderid = NULL_OBJID );
		if( sts&1 )

			sts = om$send(	msg 	= message ACcpx_defn.ACgive_name
							( &macDef ),
					targetid = defId.objid,
					targetos = defId.osnum,
					senderid = NULL_OBJID );

		if( sts&1 )	strcpy( inp->constDefName, macDef );
	}
	if( DRW_wantView ){

		DRW_elmView = VSunknownViewType;

		strcpy( attr.name, VLSDL_VIEW );
		sts = vl$sdlGetAttr(	ctx	= (VLsdlContext *) inp->appData,
					attr	= &attr,
					colType	= VLSDL_SYST_COL );
		if( ! (sts&1))	return;

		if( ! strcmp( attr.desc.value.att_txt, VLPC_VIEW_SIDE ))
				DRW_elmView = VSfromSide;

		else if( ! strcmp( attr.desc.value.att_txt, VLPC_VIEW_BOTTOM ))
				DRW_elmView = VSfromBottom;

	} // end-want-view

}

/* ------------------------ PCcvrtStrToDbl ----------------------	*/

#argsused
IMPLEMENT_FUNCTION( VL, PCcvrtStrToDbl ) {

VStktxt			str;
struct	ACrg_coll	attrib;

	ACcol_set_type_val( VSdrwStrVal( &arglist->arg, str ), &attrib );

	if( attrib.desc.type == AC_ATTRIB_DOUBLE ){
			DBL_RES( attrib.desc.value.att_exp );

	} else {	STR_RES( attrib.desc.value.att_txt ); }

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONbrAnchorPoint () -----------	*/
/* -------------------- ALIAS brAnchorPoint FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, brAnchorPoint ) {

long			sts;
VStktxt			str;
int			suc;
struct	GRid		border;
struct	ret_struct	st;


	STR_RES("");		// no output
	CHECK_ARGCOUNT( 1 );	// check arg number

	// get border
	border = inp->toBeDrawn.elmList[VLPC_IDX_BORDER];

	// get point with path
	sts = om$send(	msg	 = message NDmacro.ACgive_structure(
					&suc,
					NULL,
					VSdrwStrVal( &arglist->arg, str ),
					&st,
					inp->drwInfo.drwEnv ),
			targetid = border.objid,
			targetos = border.osnum,
			senderid = NULL_OBJID );
	if( ! (sts&suc&1))	return	xfFAILURE;

	// set active anchor point in Strudel context
	if( st.type & point_generic ){
		xData->anchorPoint[0] = st.var.point_st.pt[0];
		xData->anchorPoint[1] = st.var.point_st.pt[1];
		xData->anchorPoint[2] = st.var.point_st.pt[2];

	} else if( st.type & ref_generic ){
			xData->anchorPoint[0] = st.var.ref_st.t[3];
			xData->anchorPoint[1] = st.var.ref_st.t[7];
			xData->anchorPoint[2] = st.var.ref_st.t[11];

	} else	return xfFAILURE;

	xData->txPosHelper	= VSuseAnchorPoint;

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONbrInstPoint () -----------	*/
/* -------------------- ALIAS brInstPoint FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, brInstPoint ) {

long			sts;
int			suc;
struct	GRid		border;
struct	ret_struct	st;
char			instPointPath[1024]; // DI_MAX_PATH];
extern	int		VLInstPointCounter;

	STR_RES("");		// no output
	CHECK_ARGCOUNT( 0 );	// check arg number

	// get border
	border = inp->toBeDrawn.elmList[VLPC_IDX_BORDER];

	// create path and incremente context
	sprintf( instPointPath, "%s%d", INST_POINT_RADICAL, VLInstPointCounter);
	VLInstPointCounter++;	

	// get point with path
	sts = om$send(	msg	 = message NDmacro.ACgive_structure(
					&suc,
					NULL,
					instPointPath,
					&st,
					inp->drwInfo.drwEnv ),
			targetid = border.objid,
			targetos = border.osnum,
			senderid = NULL_OBJID );
	if( ! (sts&suc&1))	return	xfFAILURE;

	// set active anchor point in Strudel context
	xData->anchorPoint[0] = st.var.point_st.pt[0];
	xData->anchorPoint[1] = st.var.point_st.pt[1];
	xData->anchorPoint[2] = st.var.point_st.pt[2];

	xData->txPosHelper	= VSuseAnchorPoint;

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONPCbrMember () -----------	*/
/* -------------------- ALIAS PCbrMember FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, PCbrMember ) {

long			sts, msg;
struct	GRid		border;
VStktxt			str;
struct	GRobj_env	footOv;


	STR_RES("");		// no output
	CHECK_ARGCOUNT( 1 );	// check arg number : (member)

	// get border
	border = inp->toBeDrawn.elmList[VLPC_IDX_BORDER];

	footOv.mod_env.md_id = inp->drwInfo.drwEnv->md_id;
	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&msg,
					VSdrwStrVal( &arglist->arg, str ),
					&footOv.obj_id,
					&footOv.mod_env.md_env.matrix_type,
					footOv.mod_env.md_env.matrix ),
			senderid = NULL_OBJID,
			targetid = border.objid,
			targetos = border.osnum );
	if( ! (sts&msg&1))	return	xfFAILURE;

	// copy object
	res->type		= VS_object;
	res->_oval._objid	= NULL_OBJID;
	res->_oval._osnum	= inp->drwInfo.drwEnv->md_id.osnum;
	res->_oval.mod_env	= *inp->drwInfo.drwEnv;

	sts = gr$copy_object(	msg		= &msg,
				object_id	= &footOv.obj_id,
				md_env		= &footOv.mod_env,
				new_env		= &res->_oval.mod_env,
				new_id		= &res->_oval.obj_id,
				display_flag	= 0 );
	if( ! (sts&msg&1))	return	xfFAILURE;

	// place newCs in garbage
	VSdrwAddGarbage( &msg, xData, &res->_oval );

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONgetMcDefAttribute () ---------	*/
/* -------------------- ALIAS getMcDefAttribute FUNCTION --------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, getMcDefAttribute ) {

long			sts;
char			selector[DI_PATH_MAX];
char			pathSelect[DI_PATH_MAX];

	STR_RES("");		// init	output
	CHECK_ARGCOUNT( 1 );	// check arg number : (selector)

	VSdrwStrVal( &arglist->arg, selector );

	sts = VLgetOperName( NULL, inp->elmId, selector, pathSelect );

	if( ! (sts&1)){
		VSdrwPrintf( "!!! %s() : attribute is not found", function );
		return	xfFAILURE;
	}

	STR_RES( pathSelect );

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONgetAttributeVal () -----------	*/
/* -------------------- ALIAS getAttributeVal FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, getAttributeVal ) {

long			sts;
struct	ACrg_coll	attr;

	STR_RES("");		// init	output
	CHECK_ARGCOUNT( 1 );	// check arg number : (name)

	VSdrwStrVal( &arglist->arg, attr.name );
	sts = vl$sdlGetAttr(	ctx	= (VLsdlContext *) inp->appData,
				attr	= &attr );
        if( !(sts&1) )
        {
           sts = vl$sdlGetAttr( ctx     = (VLsdlContext *) inp->appData,
                                attr    = &attr,
                                colType = VLSDL_SYST_COL );
        }
	if( ! (sts&1))	return xfFAILURE;

	if( AC_ATTRIB_DOUBLE == attr.desc.type ){
		INT_RES( ((int)attr.desc.value.att_exp) );
	}
	else	STR_RES( attr.desc.value.att_txt );

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONsetAttributeVal () -----------	*/
/* -------------------- ALIAS setAttributeVal FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, setAttributeVal ) {
long			sts;
struct	ACrg_coll	attr;
VSdrwArgLst		*pArg;

	STR_RES("");		// init	output
	CHECK_ARGCOUNT( 2 );	// check arg number : (name,value)

	VSdrwStrVal( &arglist->arg, attr.name );
	attr.desc.type	= AC_ATTRIB_TYPE_NOT_DEF;
	pArg	= arglist->next;
	VSdrwStrVal( &pArg->arg, attr.desc.value.att_txt );

	sts = vl$sdlSetAttr(	ctx	= (VLsdlContext *) inp->appData,
				attr	= &attr );
	if( ! (sts&1))	return xfFAILURE;

	*res	= pArg->arg;

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONPCsetLabel () ----------------	*/
/* -------------------- ALIAS PCsetLabel FUNCTION ---------------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, PCsetLabel ) {
long			sts, msg;
struct	ACrg_coll	label[4];
struct	GRid		*labCol;
int			*pNbLab;
VSdrwArgLst		*pArg;


	STR_RES("");			// init	output
	CHECK_ARGCOUNTS( 2, 3 );	// check arg number :
					// <origin>, <text>, [reference]

	// initialization of attribute
	strcpy( label[0].name, VLPC_LAB_ORIG );
	label[0].desc.type		= AC_ATTRIB_TYPE_NOT_DEF;
	*label[0].desc.value.att_txt	= 0;

	strcpy( label[1].name, VLPC_LAB_TEXT);
	label[1].desc.type		= AC_ATTRIB_TYPE_NOT_DEF;
	*label[1].desc.value.att_txt	= 0;

	strcpy( label[2].name, VLPC_LAB_REF );
	label[2].desc.type		= AC_ATTRIB_TYPE_NOT_DEF;
	*label[2].desc.value.att_txt	= 0;

	// set block name
	strcpy( label[3].name, VLSDL_STATE );
	label[3].desc.type		= AC_ATTRIB_TYPE_NOT_DEF;
	strcpy( label[3].desc.value.att_txt, VLPC_LAB );




//	pArg	= arglist;	arglist is const
	VSdrwStrVal( &arglist->arg, label[0].desc.value.att_txt );

//	pArg	= pArg->next;
	pArg	= arglist->next;
	VSdrwStrVal( &pArg->arg, label[1].desc.value.att_txt );

	pArg	= pArg->next;
	if( pArg )
		VSdrwStrVal( &pArg->arg, label[2].desc.value.att_txt );

	// create collection
	pNbLab = &(((VLpcContext*)((VLsdlContext*)(inp->appData))
						->stateArgs )->nbLabel);
	labCol = &(((VLpcContext*)((VLsdlContext*)(inp->appData))
						->stateArgs )->label[*pNbLab]);
	(*pNbLab)++;

	labCol->osnum	= inp->drwInfo.drwEnv->md_id.osnum;
	sts = om$construct(	classid	= OPP_ACdyn_col_class_id,
				osnum	= labCol->osnum,
				p_objid = &labCol->objid );
	as$status( sts = sts );

	// set attribute
	sts = om$send(	msg	 = message ACrg_collect.ACset_list_attribute
					( &msg, 4, label ),
			senderid = NULL_OBJID,
			targetid = labCol->objid,
			targetos = labCol->osnum );
	as$status( sts = sts );
	as$status( sts = msg );


return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONsetLabelOrigin () -----------	*/
/* -------------------- ALIAS setLabelOrigin FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, setLabelOrigin ) {
long			sts;
struct	ACrg_coll	attr;

	STR_RES("");		// init	output
	CHECK_ARGCOUNT( 1 );	// check arg number : (origin)

	strcpy( attr.name, VLPC_LAB_ORIG );
	attr.desc.type		= AC_ATTRIB_DOUBLE;
	attr.desc.value.att_exp = VSdrwDblVal( &arglist->arg );
	sts = vl$sdlSetAttr(	ctx	= (VLsdlContext *) inp->appData,
				attr	= &attr,
				colType	= VLSDL_SYST_COL );
	if( ! (sts&1))	return xfFAILURE;

	*res	= arglist->arg;

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONgetLabelOrigin () -----------	*/
/* -------------------- ALIAS getLabelOrigin FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, getLabelOrigin ) {
long			sts, msg;
struct	ACrg_coll	attr;
VLmacInfo		*sortList;
int			count;
int			i;
double			labOri, delta, labLen, stiffLen;

	DBL_RES( 0 );			// init	output
	CHECK_ARGCOUNTS( 0, 1 );	// check arg number : - (label length)
					// 		      - or no value

	// get stored value
	if( ! argc ){

		attr.desc.value.att_exp = 0.;
		strcpy( attr.name, VLPC_LAB_ORIG );
		sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
						( &msg, &attr ),
				senderid = NULL_OBJID,
				targetid = inp->elmId->objid,
				targetos = inp->elmId->osnum );
		as$status( sts = sts );
		as$status( sts = msg );

		DBL_RES( attr.desc.value.att_exp );
		return	xfSUCCESS;
	}

	// compute origin value
	sortList = ((VLpcContext*)
			((VLsdlContext*)(inp->appData))
						->stateArgs )->macInfoList;
	count	 = ((VLpcContext*)
			((VLsdlContext*)(inp->appData))
						->stateArgs )->nbMac;
	labLen = VSdrwDblVal( &arglist->arg );

	// find label position
	for( i=0, labOri = 50.; i<count; i++ ){

		delta = sortList[i].xpos + sortList[i].range[0] - labOri;

		if( delta > labLen ) break;

		else	labOri = sortList[i].xpos + sortList[i].range[3];
	}
	if( i==count ){ 
		// test space between last macro and end of stiffener
		stiffLen	= 0;
		sts = om$send(	msg	 = message VSbeam.VSgetBeamLength( 
						&msg, 
						inp->drwInfo.drwEnv, 
						&stiffLen ),
				senderid = NULL_OBJID,
				targetid = inp->toBeDrawn.elmList[VLPC_IDX_SUPPORT].objid,
				targetos = inp->toBeDrawn.elmList[VLPC_IDX_SUPPORT].osnum );
		as$status( sts = sts );

		delta =  stiffLen - labOri;
		if( delta < labLen )	labOri = 50.; 
	}

	DBL_RES( labOri );

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONgetLabelText () --------------	*/
/* -------------------- ALIAS getLabelText FUNCTION -------------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, PCgetLabelText ) {
long			sts, msg;
struct	ACrg_coll	attr;

	STR_RES( "" );		// init	output.
	CHECK_ARGCOUNT( 0 );	// check arg number.

	// get stored value

	attr.desc.value.att_exp = 0.;
	strcpy( attr.name, VLPC_LAB_TEXT );
	sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
						( &msg, &attr ),
				senderid = NULL_OBJID,
				targetid = inp->elmId->objid,
				targetos = inp->elmId->osnum );

	STR_RES( attr.desc.value.att_txt );

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONgetLabelRef () --------------	*/
/* -------------------- ALIAS getLabelRef FUNCTION -------------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, PCgetLabelRef ) {
long			sts, msg;
struct	ACrg_coll	attr;

	STR_RES( "" );		// init	output.
	CHECK_ARGCOUNT( 0 );	// check arg number.

	// get stored value

	attr.desc.value.att_exp = 0.;
	strcpy( attr.name, VLPC_LAB_REF );
	sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
						( &msg, &attr ),
				senderid = NULL_OBJID,
				targetid = inp->elmId->objid,
				targetos = inp->elmId->osnum );

	STR_RES( attr.desc.value.att_txt );

return	xfSUCCESS;
}

/* --------------------- FCT VLpcDoubleCutMacro () --------------------	*
 *
 * This function checks if the input macro has both the ~~orientation1 
 * and ~~orientation2 defined and if any of the stiffeners in the stepList 
 * match with either of its two parents; If there is a match, the feetName 
 * corresponding to the ~~orientation[1 or 2] as per the matching parent 
 * number will be returned in footName
 *
 */ 
 
long VLpcDoubleCutMacro(  IGRlong          *msg,
                          struct GRid      * macro, 
                          struct GRobj_env *stepList, 
                          IGRint           nbStep,
                          GRname           footName
                       )
{
  IGRlong        sts; 
  IGRint         i, j, count;
  struct GRid    mcStiff[2], parent;
  GRname         footName1, footName2;
  
  *msg         = MSFAIL;
  sts          = OM_W_ABORT;

  if((stepList == NULL) || (macro == NULL)  || (nbStep == 0)) 
  {
    __DBGpr_com("Invalid arguments for VLpcDoubleCutMacro() ");
    goto wrapup;
  }

  footName[0]  = '\0';
  footName1[0]  = '\0';
  footName2[0]  = '\0';
  
  sts = VLgetOperName( "", macro,
		 "~~orientation1", footName1 );
  if(!(sts&1) && (footName1[0] == '\0'))
  {
    __DBGpr_obj("Macro doesn't have ~~orientation1", *macro);
    goto wrapup;
  }
  sts = VLgetOperName( "", macro,
		 "~~orientation2", footName2 );
  if(!(sts&1) && (footName2[0] == '\0'))
  {
    __DBGpr_obj("Macro doesn't have ~~orientation2", *macro);
    goto wrapup;
  }
  
  __DBGpr_str("FootName1 ",footName1); 
  __DBGpr_str("FootName2 ",footName2); 

  {
    mcStiff[0].objid   = NULL_OBJID;
    mcStiff[1].objid   = NULL_OBJID;
    sts = om$send(  msg      = message NDnode.NDget_objects(
                                       ND_ROOT,mcStiff, 2, NULL,
                                       0, 1, &count ),
		    senderid = NULL_OBJID,
		    targetid = macro->objid,
		    targetos = macro->osnum );
    if( ! (sts&1)) goto wrapup;
    if((mcStiff[0].objid == NULL_OBJID ) ||
       (mcStiff[1].objid == NULL_OBJID )) goto wrapup;
    
    __DBGpr_obj("Macro ",*macro); 
    __DBGpr_obj("First object in father channel ",mcStiff[0]); 
    __DBGpr_obj("Second object in father channel ",mcStiff[1]); 
    
    parent.objid = NULL_OBJID;
    sts = om$send(  msg      = message ACpretend.ACfind_parent
		                       ( &parent, NULL, NULL ),
		    senderid = NULL_OBJID,
		    targetid = mcStiff[0].objid,
		    targetos = mcStiff[0].osnum );
    if((parent.objid == NULL_OBJID )) parent = mcStiff[0]; 
    __DBGpr_obj("First parent of Macro ",parent); 
    
    // check if first parent is in Steps list
    for( j=0; j<nbStep; j++ )
      if( parent.objid == stepList[j].obj_id.objid )
      {
        if(footName1[0] != '\0')
	{
	  strcpy(footName,footName1);
	  sts  = OM_S_SUCCESS;
	  *msg = MSSUCC;
	  goto wrapup; 
	}
      }
    __DBGpr_obj("First parent for macro not found",*macro);
    
    parent.objid = NULL_OBJID;
    sts = om$send(  msg      = message ACpretend.ACfind_parent
	             	               ( &parent, NULL, NULL ),
		    senderid = NULL_OBJID,
		    targetid = mcStiff[1].objid,
		    targetos = mcStiff[1].osnum );
    if((parent.objid == NULL_OBJID )) parent = mcStiff[1]; 
    __DBGpr_obj("Second parent of Macro ",parent); 
    
    // check if second parent is in Steps list
    for( j=0; j<nbStep; j++ )
      if( parent.objid == stepList[j].obj_id.objid ) 
      {
        if(footName2[0] != '\0')
	{
	  strcpy(footName,footName2);
	  sts  = OM_S_SUCCESS;
	  *msg = MSSUCC;
	  goto wrapup;
	} 
      }
    __DBGpr_obj("Second parent for macro not found",*macro);
  }
 wrapup:
  return sts; 
}
/* --------------------- FCT VLgetRollMacOnStiff () ------------------- */
IGRlong VLgetRollMacOnStiff(  struct GRobj_env 	*stiff,
		   	      IGRchar		*mac_name,
			      struct GRobj_env	*roll_mac	)
{
IGRlong			sts, msg, notUsed;
IGRchar			*axis_name=NULL;
struct GRid		axis_mac, macro_def;
struct GRobj_env	axis;

    SetProc( VLgetRollMacOnStiff ); Begin

   __DBGpr_obj("Input Stiffener ", stiff->obj_id);
    sts = om$send(  msg = message VSfeature.VSforwardToSource(
                    &notUsed,
                    OM_e_wrt_object,
                    message VSbeam.VSgetSupportAxis(
                            &msg,
			    &stiff->mod_env,
			    &axis 		)) ,
	    senderid = NULL_OBJID,
            targetid = stiff->_objid,
	    targetos = stiff->_osnum  );
    __CheckRC( sts, msg, "VSbeam.VSgetSupportAxis", wrapup ) ;
    __DBGpr_obj("Stiffener Axis(graphics)  ", axis.obj_id );

    sts = om$get_objid_at_index( osnum        = axis._osnum,
				 objid        = axis._objid,
				 p_chanselect = &AS_to_owner,
				 index        = 0,
				 objidaddr    = &axis_mac.objid,
				 osnumaddr    = &axis_mac.osnum   );
    __CheckRC( sts, 1, "om$get_objid_at_index", wrapup ) ;
    __DBGpr_obj("Stiffener Axis(macro) ", axis_mac ); 

    if( ! vs$is_ancestry_valid( object  = &axis_mac,
				classid = OPP_nci_macro_class_id ) )
    {
	__DBGpr_com("Stiffener Axis is NOT an nci_macro, going to wrapup");
	sts = OM_E_NOTIMPL;
	goto wrapup;
    } 

    sts = om$send(  msg = message ACcpx.find_macro( &macro_def ),
		    senderid = NULL_OBJID,
		    targetid = axis_mac.objid,
		    targetos = axis_mac.osnum   );
    __CheckRC( sts, 1, "ACcpx.find_macro", wrapup ) ;

    sts = om$send( msg = message ACcpx_defn.ACgive_name( &axis_name ),
		   senderid = NULL_OBJID,
		   targetid = macro_def.objid,
		   targetos = macro_def.osnum   );
    __CheckRC( sts, 1, "ACcpx_defn.ACgive_name", wrapup ) ;
    __DBGpr_str("Axis Macro Name ", axis_name );
    __DBGpr_str("Input Macro ", mac_name );

    if( strcmp(mac_name, axis_name) )
    {
	__DBGpr_com("Axis Macro Name is NOT same as input name, going to wrapup");
        sts = OM_E_NOTIMPL;
        goto wrapup;
    }
    
    roll_mac->obj_id  = axis_mac; 
    roll_mac->mod_env = axis.mod_env;
    __DBGpr_obj("Axis output is set to ", roll_mac->obj_id );

    sts = MSSUCC;

wrapup:
    End
    return sts;
}

/* --------------------- FCT VLcollectMacOnStiff () -------------------	*/
long VLcollectMacOnStiff(	struct GRobj_env *stiff,
			struct GRmd_env	 *loc_env, 
			int		 *nbMac,
			struct GRobj_env **macList)
{
long			msg;
long			sts;
// short			world = 1;
// GRrange			lrange;
long			VLcheckStiffMac();
int			nbStep;
struct GRobj_env 	*stepList = NULL;
extern			VLbrowseFctInTree();
extern	int		VLgetMacrosAtStep();
extern	int		VLgetStepInfo();
int			i, j;
int			maxMac, count;
struct	GRid		mcStiff, foot_id;
int			ind1, ind2, ind3;
int			maxMacro;
int			maxTrace;
short			topProp = VL_Q_TOP_SOURCE;
GRname                  cmdType, matchName;
char			attr_name[30], footName[30];

	// check support type
	if( vs$is_ancestry_valid(
		object  = &stiff->obj_id,
		classid = OPP_VSimgFeature_class_id ) ) 
						topProp = VL_Q_TOP_CURRENT;


//	sts = om$send(	msg	 = message GRgraphics.GRgetrang(
//					&msg,
//					&stiff->mod_env.md_env.matrix_type,
//					stiff->mod_env.md_env.matrix,
//					&world,
//					lrange ),
//			targetid = stiff->obj_id.objid,
//			targetos = stiff->obj_id.osnum,
//			senderid = NULL_OBJID );
//	if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }

	// Query macros attached by range
//	sts = VLrLocRef(lrange, nbMac, macList, loc_env);
//	printf(" Range Loc ----------------------------	# : %d\n", *nbMac);


	*nbMac	= 0;
	nbStep 	= 0;

	// Query macros attach to the stiffener History
	VLbrowseFctInTree( stiff, topProp, NULL, 
					VL_Q_DOWN_DIRECT,
					VLgetMacrosAtStep,
					nbMac, macList, loc_env );
//	printf(" History Loc --------------------------	# : %d\n", *nbMac);
//	for( i=0; i<*nbMac; i++ )
//		printf(" macro list[%d].ID : %d/%d\n", i, 
//				(*macList)[i].obj_id.objid, 
//				(*macList)[i].obj_id.osnum );

	// Query stiffener steps History
	VLbrowseFctInTree( stiff, topProp, NULL, 
					VL_Q_DOWN_DIRECT,
					VLgetStepInfo,
					&nbStep, &stepList, loc_env );
//	printf(" History Steps ------------------------	# : %d\n", nbStep);
//	for( i=0; i<nbStep; i++ )
//		printf(" stepId : %d/%d\n", stepList[i].obj_id.objid,
//						stepList[i].obj_id.osnum );

	// filtre par classe
	VLfilterClass(*nbMac,*macList,nbMac,OPP_ACncpx_class_id);
//	printf(" Filtrage class -----------------------	# : %d\n", *nbMac);

	maxMacro = *nbMac;

	// filtrage par attribut de definition et geometrie
	ind1 = ind2 = 0;
	VLfilterDefAttrName( *nbMac, *macList, &ind1, "~~operand" );
	VLfilterDefAttrName( *nbMac - ind1, 
				&(*macList)[ind1], &ind2, "~~operand0" );
	*nbMac = ind1 + ind2;

	ind1 = ind2 = ind3 = 0;
	VLfilterDefAttrName( *nbMac, *macList, &ind1, "~~operator" );
	VLfilterDefAttrName( *nbMac - ind1, 
			&(*macList)[ind1], &ind2, "~~operator0" );
	VLfilterDefAttrName( *nbMac - ind1 - ind2, 
			&(*macList)[ind1+ind2], &ind3, "~~operator0~0" );
	*nbMac = ind1 + ind2 + ind3 ;

	ind1 = ind2 = ind3 = 0;
	VLfilterDefAttrName( *nbMac, *macList, &ind1, "~~orientation" );
	VLfilterDefAttrName( *nbMac - ind1,
			&(*macList)[ind1], &ind2, "~~orientation1" );
	VLfilterDefAttrName( *nbMac - ind1 - ind2,
                        &(*macList)[ind1+ind2], &ind3, "~~orientation2" );
	*nbMac = ind1 + ind2 + ind3 ;

	maxMac = *nbMac;
        for ( i=0, *nbMac=0; i<maxMac; i++) {

                footName[0]   = '\0';
                foot_id.objid = NULL_OBJID;

		VLgetOperName( "", &(*macList)[i].obj_id,
			       "~~orientation", footName );

                sts = om$send ( msg = message NDmacro.ACreturn_foot
                                ( &msg, footName, &foot_id, NULL, NULL ),
                                senderid = NULL_OBJID,
                                targetid = (*macList)[i].obj_id.objid,
                                targetos = (*macList)[i].obj_id.osnum );
                if ((sts & 0x00000001 & msg) && (foot_id.objid != NULL_OBJID))
		{
                        VLswapObjEnv ( (*macList), i, (*nbMac)++);
			continue;
		}
                footName[0]   = '\0';
                foot_id.objid = NULL_OBJID;
                sts = VLpcDoubleCutMacro(&msg, &(*macList)[i].obj_id,  
                                         stepList, nbStep, footName);
                if((sts & msg & 1) && (footName[0] != '\0'))
                {
                  sts = om$send ( msg = message NDmacro.ACreturn_foot
                                       ( &msg, footName, &foot_id, NULL, NULL ),
                                  senderid = NULL_OBJID,
                                  targetid = (*macList)[i].obj_id.objid,
                                  targetos = (*macList)[i].obj_id.osnum );
                  if ((sts & 0x00000001 & msg) && (foot_id.objid != NULL_OBJID))
		  {
                          VLswapObjEnv ( (*macList), i, (*nbMac)++);
		       	  continue;
		  }

                } 
                
                VLgetOperName( "", &(*macList)[i].obj_id,
                               "~~orientation1", footName );
                
                sts = om$send ( msg = message NDmacro.ACreturn_foot
                                ( &msg, footName, &foot_id, NULL, NULL ),
                                senderid = NULL_OBJID,
                                targetid = (*macList)[i].obj_id.objid,
                                targetos = (*macList)[i].obj_id.osnum );
                if (sts & 0x00000001 & msg)
                {
                        VLswapObjEnv ( (*macList), i, (*nbMac)++);
                        continue;
                }
                VLgetOperName( "", &(*macList)[i].obj_id,
                               "~~orientation2", footName );

                sts = om$send ( msg = message NDmacro.ACreturn_foot
                                ( &msg, footName, &foot_id, NULL, NULL ),
                                senderid = NULL_OBJID,
                                targetid = (*macList)[i].obj_id.objid,
                                targetos = (*macList)[i].obj_id.osnum );
                if (sts & 0x00000001 & msg)
                {
                        VLswapObjEnv ( (*macList), i, (*nbMac)++);
                        continue;
                }
        }

	// get first template
	maxMac = *nbMac;
	for( i=0, *nbMac=0; i<maxMac; i++ ){
	  
          // grab the macro cutting both the parents
          sts = VLpcDoubleCutMacro(&msg, &(*macList)[i].obj_id,  stepList, nbStep, 
                                   matchName);
	  
          if(!(sts & msg & 1) || (matchName[0] == '\0'))
          {
            __DBGpr_obj("Macro is not double cut type ",(*macList)[i].obj_id);
          }
          else
          {
            __DBGpr_obj("Macro is double cut type ",(*macList)[i].obj_id);
            __DBGpr_str("Matching foot name ", matchName);
	    VLswapObjEnv( *macList, i, (*nbMac)++ );
            continue;
          }
	  
	  mcStiff.objid	= NULL_OBJID;
	  sts = om$send(	msg	 = message NDnode.NDget_objects(
	                                           ND_ROOT,&mcStiff, 1, NULL,
	                                           0, 0, &count ),
				senderid = NULL_OBJID,
				targetid = (*macList)[i].obj_id.objid,
				targetos = (*macList)[i].obj_id.osnum );
	  if( ! (sts&1) || mcStiff.objid == NULL_OBJID ) continue;
	  
	  sts = om$send(	msg	 = message ACpretend.ACfind_parent
				                   ( &mcStiff, NULL, NULL ),
				senderid = NULL_OBJID,
				targetid = mcStiff.objid,
				targetos = mcStiff.osnum );
	  
	  // check if first is in Steps list
	  for( j=0; j<nbStep; j++ )
	    if( mcStiff.objid == stepList[j].obj_id.objid ){
	      VLswapObjEnv( *macList, i, (*nbMac)++ );
	      break;
	    }
	}
	
	// check Geometries 
//	VLfilterGeometry(*nbMac, *macList, nbMac, VLcheckStiffMac, stiff);
//	printf(" Filtrage Geom	-----------------------	# : %d\n", *nbMac);
//	for( i=0; i<*nbMac; i++ ){
//
//		printf(" macro list[%d].ID : %d/%d\n", i, 
//				(*macList)[i].obj_id.objid, 
//				(*macList)[i].obj_id.osnum );
//	}


	// extract the Positionnel Marking Line 
	maxTrace = 0;
	VLfilterDefAttrValue( maxMacro, &(*macList)[*nbMac], &maxTrace, 
			      VLPC_DEF_ATT_CMD, VLPC_REF_MARK_CMD );
	*nbMac += maxTrace;
	
        for( i=0; i<10; ++i )
        {   
	  ind1 = ind2 = 0;
	  sprintf( attr_name, "~~marking%d", i );
	  VLfilterDefAttrName( maxMacro, &(*macList)[*nbMac], 
			       &ind1, attr_name );
	  for( j=0; j<ind1; ++j )
	  { 
	    VLgetOperName( "", &(*macList)[*nbMac+j].obj_id,
			   attr_name, footName );
	    
	    sts = om$send ( msg = message NDmacro.ACreturn_foot
			    ( &msg, footName, &foot_id, NULL, NULL ),
			    senderid = NULL_OBJID,
			    targetid = (*macList)[*nbMac+j].obj_id.objid,
			    targetos = (*macList)[*nbMac+j].obj_id.osnum );
	    if( !(sts&1&msg) ) continue;
	    
	    sts = VLgetOperName( NULL, &(*macList)[*nbMac+j].obj_id,
				 VLPC_DEF_ATT_CMD, cmdType );
	    if((sts&1)&&(!strcmp( VLPC_END_TREAT_CMD, cmdType))) continue;
	    VLswapObjEnv( &(*macList)[*nbMac], j, ind2 );
	    ind2++;
	  }
	  *nbMac += ind2;
	  
	  ind1 = ind2 = 0;
	  sprintf( attr_name, "~~marking0%d", i );
	  VLfilterDefAttrName( maxMacro, &(*macList)[*nbMac], 
			       &ind1, attr_name );
	  for( j=0; j<ind1; ++j )
	  {
	    VLgetOperName( "", &(*macList)[*nbMac+j].obj_id,
			   attr_name, footName );
	    
	    sts = om$send ( msg = message NDmacro.ACreturn_foot
			    ( &msg, footName, &foot_id, NULL, NULL ),
			    senderid = NULL_OBJID,
			    targetid = (*macList)[*nbMac+j].obj_id.objid,
			    targetos = (*macList)[*nbMac+j].obj_id.osnum );
	    if( !(sts&1&msg) ) continue;
	    
	    sts = VLgetOperName( NULL, &(*macList)[*nbMac+j].obj_id,
				 VLPC_DEF_ATT_CMD, cmdType );
	    if((sts&1)&&(!strcmp( VLPC_END_TREAT_CMD, cmdType))) continue;
	    VLswapObjEnv( &(*macList)[*nbMac], j, ind2 );
	    ind2++;
	  }
	  *nbMac += ind2;
        }
	
	VLfilterDef( maxMacro, &(*macList)[*nbMac], &ind1, "stfPcMark" );
	*nbMac += ind1;
	

  // printf("Number of Macro Recognized by Profile Card = %d\n", *nbMac );
  // for( i=0; i<*nbMac; i++ )
  //    vdobj$Print( objOE = &(*macList)[i] );

	
	sts = MSSUCC;
	
	// wrapup :
	
	if( stepList )	free( stepList );
	
	return	sts;
}

/* --------------------- FCT VLgetMacOnStiff () --------------------	*/

long VLgetMacOnStiff(	struct GRobj_env *stiff,
			struct GRmd_env	 *loc_env, 
			int		 *nbMac,
			struct GRobj_env **macList )
{
long			sts, msg;
int			i, j;
struct	GRid		link, model;
int			count;
struct	GRid		cs, csAs;
double			plPt[10], matPl[16];
short			four = 4;
short			one  = 1;
double			locPt[4];
struct	GRobj_env	modOv;
struct	GRobj_env	*modList;
int			countM;
struct	GRobj_env	imgOv;
struct	GRobj_env	*imgList;
int			countI;
struct	GRid		imgId;
int			countMI;

	*nbMac		= 0;
	*macList	= NULL;

	// get support type	
	if( vs$is_ancestry_valid(
		object  = &stiff->obj_id,
		classid = OPP_VSimgFeature_class_id ) ) {

		model.objid	= NULL_OBJID;
		sts = om$send(	msg	 = message ACheader.ACfind_model
						( &msg, &link ),
				targetid = stiff->obj_id.objid,
				targetos = stiff->obj_id.osnum,
				senderid = NULL_OBJID );
		if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }

		sts = om$send(	msg	= message VDlink.ACget_model_list
						( &msg, 1, &model, &count ),
				targetid = link.objid,
				targetos = link.osnum,
				senderid = NULL_OBJID );
		if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }

		// get symetry plane of image
		sts = om$send(msg = message NDnode.NDget_objects(
						ND_ROOT, 
						&csAs, 1, NULL,
                                             	1, 1, &count ),
				targetid = stiff->obj_id.objid,
				targetos = stiff->obj_id.osnum,
				senderid = NULL_OBJID );

		sts = om$send(  msg	= message NDnode.ASreturn_go
						( &cs, NULL, NULL ),
				senderid = NULL_OBJID,
				targetid = csAs.objid,
				targetos = csAs.osnum);

		sts = om$send(	msg	 = message GRgencs.GRgetmatrix
						( &msg, matPl ),
				targetid = cs.objid,
				targetos = cs.osnum,
				senderid = NULL_OBJID );
		if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }

		plPt[0] = matPl[3]; plPt[1] = matPl[7]; plPt[2] = matPl[11];

		locPt[0] = 1; locPt[1] = locPt[2] = 0; locPt[3] = 1;
	        MAmulmx( &msg, &four, &four, &one, matPl, locPt, &plPt[3] );

		locPt[0] = locPt[1] = 0; locPt[2] = locPt[3] = 1;
	        MAmulmx( &msg, &four, &four, &one, matPl, locPt, &plPt[6] );

//		stiff->mod_env.md_env = MOD_ENV.md_env;

		// find macros on image
		imgOv.obj_id	= stiff->obj_id;
		imgOv.mod_env	= *loc_env;
		imgOv.mod_env.md_id.osnum	= imgOv.obj_id.osnum;
		imgList		= NULL;
		countI		= 0;
		sts = VLcollectMacOnStiff( &imgOv, loc_env, &countI, &imgList );
		as$status( sts = sts );

		// find macros on model
		modOv.obj_id	= model;
		modOv.mod_env	= *loc_env;
		modOv.mod_env.md_id.osnum	= modOv.obj_id.osnum;
		modList		= NULL;
		countM		= 0;
		sts = VLcollectMacOnStiff( &modOv, loc_env, &countM, &modList );
		as$status( sts = sts );
		for( i=0, countMI=0; i<countM; i++ ){

			// get image of this macro
			imgId.objid = NULL_OBJID;
			if( VDScheck_image_placement(	&modList[i].obj_id, 
							&modList[i].mod_env,
							plPt,
							loc_env->md_id.osnum,
							&imgId ) ){

				modList[countMI].obj_id	 = imgId;
				modList[countMI].mod_env = *loc_env;
				countMI++;
			}
		}

		// merge the two listes

		if( countMI ){
			if( countI ){
				*nbMac	= countI + countMI;
				imgList = (struct GRobj_env *) realloc( imgList,
					sizeof(struct GRobj_env) * *nbMac );
				for( i=countI, j=0; i<*nbMac; i++ )
						imgList[i] = modList[j];
				free( modList ); modList = NULL;
				*macList = imgList;

			} else {
				*macList	= modList;
				*nbMac 		= countMI;
			  }

		} else { *macList = imgList; *nbMac = countI; }

	} else {

		// Query macro attach to the support
		*nbMac	= 0;
		sts = VLcollectMacOnStiff( stiff, loc_env, nbMac, macList );
		as$status( sts = sts );
	}

wrapup :

return	sts;
}

end implementation VLpcAbst;

