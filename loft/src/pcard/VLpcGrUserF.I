/* $Id: VLpcGrUserF.I,v 1.11 2002/04/19 19:55:55 ramarao Exp $  */
/*************************************************************************
 * I/LOFT
 *
 * File:        src/pcard/VLpcGrUserF.I
 *
 * Description: Definition PC User Function used with Strudel.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLpcGrUserF.I,v $
 *      Revision 1.11  2002/04/19 19:55:55  ramarao
 *      Fixed a problem in new build.
 *
 *      Revision 1.10  2002/04/08 16:39:44  ramarao
 *      Fixed TR# 6257.
 *
 *      Revision 1.9  2001/03/10 21:38:28  ramarao
 *      Added tolerance argument to IsCurvedbeam() function.
 *
 *      Revision 1.8  2001/02/22 00:40:44  ramarao
 *      Fixed TR# 4460. Added GetStartPoint Function.
 *
 *      Revision 1.7  2001/02/20 01:05:29  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.6  2001/02/08 19:14:08  ramarao
 *      Fixed TR# 4448.
 *
 *      Revision 1.5  2001/02/06 22:33:05  ramarao
 *      Fixed TR# 4559.
 *
 *      Revision 1.4  2001/01/28 18:38:38  ramarao
 *      Implemented CR# MP 4301 on Stiffner Automarking process.
 *
# Revision 1.6  2000/12/16  00:11:06  pinnacle
# Replaced: loft/src/pcard/VLpcGrUserF.I for:  by rchennup for Service Pack
#
# Revision 1.4  2000/10/22  18:09:56  pinnacle
# Replaced: loft/src/pcard/VLpcGrUserF.I for:  by rchennup for Service Pack
#
# Revision 1.7  2000/03/28  16:26:12  pinnacle
# Replaced: src/pcard/VLpcGrUserF.I for:  by impd252 for loft
#
# Revision 1.6  2000/03/23  21:41:46  pinnacle
# Replaced: src/pcard/VLpcGrUserF.I for:  by impd252 for loft
#
# Revision 1.5  2000/03/21  14:33:50  pinnacle
# Replaced: src/pcard/VLpcGrUserF.I for:  by impd252 for loft
#
# Revision 1.4  2000/03/08  23:34:24  pinnacle
# (No comment)
#
# Revision 1.3  2000/03/01  19:09:42  pinnacle
# Header Creation and Added getViewName function
#
 *
 * History:
 * MM/DD/YY   AUTHOR       DESCRIPTION
 * 04/05/94   LLC	   File Creation.
 * 03/01/00   Rama Rao     Header Creation and Added getViewName function
 *************************************************************************/

class implementation VLpcAbst;

#include <stdio.h>
#include <math.h>
#include "igrdef.h"
#include "igr.h"
#include "bserr.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsmkvec.h"
#include "bspj_pt_cv.h"
#include "bsdistptpt.h"
#include "bsnrm_2_cvs.h"
#include "ci.h"
#include "ciexecmacros.h"
#include "EMSmsgdef.h"
#include "AS_status.h"
#include "grdpbmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "expression.h"
#include "expmacros.h"
#include "acmacros.h"
#include "exmacros.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_pplslc.h"
#include "VDobj.h"
#include "VDmem.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "vsdrwapi.h"
#include "acrepdef.h"
#include "vsmiscmacros.h"
#include "vsdpb.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vssectiondef.h"
#include "vsplatedef.h"
#include "vsbeamdef.h"
#include "vsglobalmsg.h"
#include "vlpcdef.h"
#include "vlpc.h"
#include "vlpcmacros.h"
#include "vlsdldef.h"
#include "vlsdl.h"
#include "vlsdlmacros.h"
#include "vlquerydef.h"
#include "vlstifbend.h"
#include "vldbgmacros.h"

#define	vsDEBUG		1
#define vserrDEBUG	1

extern	GRclassid	OPP_ACconst_class_id,  OPP_VDdrwGm_class_id,
			OPP_ACheader_class_id, OPP_nci_macro_class_id,
			OPP_VSsrcPlate_class_id;

#if ISDP_MAKE_SP
   extern IGRchar 	pcBorderName[DI_PATH_MAX];
   extern IGRint  	isWebRight;
#else
   IGRchar		pcBorderName[DI_PATH_MAX];
   IGRint		isWebRight;
#endif

extern          VLgetMacrosAtStep();

from	VSbeam		import	VSextractProfile;
from	GRgencs		import	GRgetmatrix;
from	ACcpx_defn	import	ACgive_temp_desc, ACgive_name;
from    GRlinear	import  GRgetpolyline;
from    VSbeam          import  VSgetSupportAxis;

#define MAX_MAC_BOTH_ET	100
#define MAX_MAC_OPEN_ET	100

static IGRdouble	x_vec[3];
static IGRboolean	glob_pc_terminate;

static int		nb_mac_both_et;
static VStktxt		mac_both_et[MAX_MAC_BOTH_ET];
static int              nb_mac_open_et;
static VStktxt          mac_open_et[MAX_MAC_OPEN_ET];

/* -------------------- FCT VLdrwFUNCTIONFirstEtPos () -----------	*/
/* -------------------- ALIAS FirstEtPos FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, FirstEtPos ) {

long			sts;
struct	ACrg_coll	attr;

	DBL_RES( 0 );		// init	output

	strcpy( attr.name, VLPC_MC_ET1_POS );
	sts = vl$sdlGetAttr(	ctx	= (VLsdlContext *) inp->appData,
				colType	= VLSDL_SYST_COL,
				attr	= &attr );
	if( ! (sts&1))	return xfFAILURE;

	if( AC_ATTRIB_DOUBLE != attr.desc.type ) return xfFAILURE;

	DBL_RES( attr.desc.value.att_exp );

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONInterEtsLen () -----------	*/
/* -------------------- ALIAS InterEtsLen FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, InterEtsLen ) {

long			sts;
struct	ACrg_coll	attr;

	DBL_RES( 0 );		// init	output

	strcpy( attr.name, VLPC_MC_ETS_LEN );
	sts = vl$sdlGetAttr(	ctx	= (VLsdlContext *) inp->appData,
				colType	= VLSDL_SYST_COL,
				attr	= &attr );
	if( ! (sts&1))	return xfFAILURE;

	if( AC_ATTRIB_DOUBLE != attr.desc.type ) return xfFAILURE;

	DBL_RES( attr.desc.value.att_exp );

return	xfSUCCESS;
}

/* -------------------- FCT VLgetMcInfoStruct () ----------------------	*/

IGRlong VLgetMcInfoStruct( struct GRid *mcId, VLpcContext *pcCtx, 
							VLmacInfo **pMcInfo )
{
int	i;

	for( i=0; i<pcCtx->nbMac; i++ )

		if( pcCtx->macInfoList[i].mac->obj_id.objid == mcId->objid &&
		    pcCtx->macInfoList[i].mac->obj_id.osnum == mcId->osnum ){

			*pMcInfo = &pcCtx->macInfoList[i];
			return	MSSUCC;
		}

return	MSFAIL;
}

/* -------------------- FCT VLdrwFUNCTIONmacPosition () -----------	*/
/* -------------------- ALIAS macPosition FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, macPosition ) {

long			sts;
char			footName[DI_PATH_MAX];
VLmacInfo		*macInfo;


	STR_RES("");		// no output
	CHECK_ARGCOUNT( 0 );	// check arg number

	sts = VLgetMcInfoStruct( inp->elmId, 
				((VLpcContext*)
				  ((VLsdlContext*)(inp->appData))->stateArgs ),
					&macInfo );
	if( ! (sts&1))	return	xfFAILURE;

	sprintf( footName, "%f %f", macInfo->xpos, macInfo->ypos );

	STR_RES( footName );

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONmacAngle () -----------	*/
/* -------------------- ALIAS macAngle FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, macAngle ) {

long			sts;
VLmacInfo		*macInfo;
char			footName[DI_PATH_MAX];


	STR_RES("");		// no output
	CHECK_ARGCOUNT( 0 );	// check arg number

	sts = VLgetMcInfoStruct( inp->elmId, 
				((VLpcContext*)
				  ((VLsdlContext*)(inp->appData))->stateArgs ),
					&macInfo );
	if( ! (sts&1))	return	xfFAILURE;

	sprintf( footName, "%f", macInfo->alpha );

	STR_RES( footName );

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONmacSide () -----------	*/
/* -------------------- ALIAS macSide FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, macSide ) {

long			sts;
VLmacInfo		*macInfo;
char			footName[DI_PATH_MAX];


	STR_RES("");		// no output
	CHECK_ARGCOUNT( 0 );	// check arg number

	sts = VLgetMcInfoStruct( inp->elmId, 
				((VLpcContext*)
				  ((VLsdlContext*)(inp->appData))->stateArgs ),
					&macInfo );
	if( ! (sts&1))	return	xfFAILURE;

	sprintf( footName, "%d", macInfo->side );

	STR_RES( footName );

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONviewCs () -----------	*/
/* -------------------- ALIAS viewCs FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, viewCs ) {

	res->type		= VS_object;
	res->_oval.obj_id	= inp->toBeDrawn.elmList[VLPC_IDX_BORDER];
	res->_oval.mod_env	= *inp->drwInfo.drwEnv;

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONviewEndCs () ---------	*/
/* -------------------- ALIAS viewEndCs FUNCTION --------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, viewEndCs ) {
long			sts, msg;
double			csMat[16];
struct	GRid		csId;
VLvasCs			*vas;


	STR_RES("");		// no output
	CHECK_ARGCOUNT( 0 );	// check arg number
	 
	// view origin Cs
	csId	= inp->toBeDrawn.elmList[VLPC_IDX_BORDER];
	sts = om$send(	msg	 = message GRgencs.GRgetmatrix
					( &msg, csMat ),
			targetid = csId.objid,
			targetos = csId.osnum,
			senderid = NULL_OBJID );
	if( ! (sts&msg&1))	return	xfFAILURE;

	// get view info
	vas = &((VLpcContext*)((VLsdlContext*)(inp->appData))
						->stateArgs )->vasCs;

	// create a garbage Cs
	csMat[3] += vas->xView;
//	csMat[7] += vas->yView;

	res->type		= VS_object;
	res->_oval._objid	= NULL_OBJID;
	res->_oval._osnum	= inp->drwInfo.drwEnv->md_id.osnum;
	res->_oval.mod_env	= *inp->drwInfo.drwEnv;

	sts = vl$plcs(	mat	= csMat,
			env	= &res->_oval.mod_env,
			csId	= &res->_oval.obj_id );
	if( ! (sts&1))	return	xfFAILURE;

	// place newCs in garbage
	VSdrwAddGarbage( &msg, xData, &res->_oval );

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONviewMacroCs () -----------	*/
/* -------------------- ALIAS viewMacroCs FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, viewMacroCs ) {

long			sts, msg;
VLmacInfo		*macInfo;
double			csMat[16];
struct	GRid		csId;
VLvasCs			*vas;
int			i;
IGRboolean		noangle=FALSE;
char                    footName[DI_PATH_MAX];

	STR_RES("");		// no output
	
	if( argc == 1 ) 
        {
	   VSdrwStrVal( &arglist->arg, footName );
	   if( !strcmp( footName, "noangle" ) )  noangle = TRUE;
	}
 
	// view origin Cs
	csId	= inp->toBeDrawn.elmList[VLPC_IDX_BORDER];
	sts = om$send(	msg	 = message GRgencs.GRgetmatrix
					( &msg, csMat ),
			targetid = csId.objid,
			targetos = csId.osnum,
			senderid = NULL_OBJID );
	if( ! (sts&msg&1))	return	xfFAILURE;

	// get macro info
	sts = VLgetMcInfoStruct( inp->elmId, 
				((VLpcContext*)
				  ((VLsdlContext*)(inp->appData))->stateArgs ),
					&macInfo );
	if( ! (sts&1))	return	xfFAILURE;

	// get view scale
	vas = &((VLpcContext*)((VLsdlContext*)(inp->appData))
						->stateArgs )->vasCs;

	// create a garbage Cs
	csMat[3] += (macInfo->xpos * vas->xSca);
	csMat[7] += (macInfo->ypos * vas->ySca);

	footName[0] = '\0';
	sts = VLgetOperName("", inp->elmId, "~~orientation", footName);
	if( sts&1 )
        {
	    if( fabs( macInfo->alpha ) > 0.01 && noangle == FALSE ){
		double	locAngle;
		double	rotMat[16], nMat[16];
		short	four = 4;

		locAngle = macInfo->alpha;

		MAidmx( &msg, rotMat );

		rotMat[0] = cos( locAngle );
		rotMat[1] = -sin( locAngle );
		rotMat[4] = sin( locAngle );
		rotMat[5] = cos( locAngle );

		MAmulmx(&msg, &four, &four, &four, csMat, rotMat, nMat);
		for( i=0; i<16; i++ )	csMat[i] = nMat[i];
	    }

	    if( macInfo->side == -1 ){
		// reverse X and Z 
		csMat[0]  = -csMat[0];
		csMat[4]  = -csMat[4];
		csMat[8]  = -csMat[8];
		csMat[12] = -csMat[12];

		csMat[2]  = -csMat[2];
		csMat[6]  = -csMat[6];
		csMat[10] = -csMat[10];
		csMat[14] = -csMat[14];
	    }
	}

	if( isWebRight )
	{
                // reverse X and Z
                csMat[0]  = -csMat[0];
                csMat[4]  = -csMat[4];
                csMat[8]  = -csMat[8];
                csMat[12] = -csMat[12];
	}

	res->type		= VS_object;
	res->_oval._objid	= NULL_OBJID;
	res->_oval._osnum	= inp->drwInfo.drwEnv->md_id.osnum;
	res->_oval.mod_env	= *inp->drwInfo.drwEnv;

	sts = vl$plcs(	mat	= csMat,
			env	= &res->_oval.mod_env,
			csId	= &res->_oval.obj_id );
	if( ! (sts&1))	return	xfFAILURE;

	// place newCs in garbage
	VSdrwAddGarbage( &msg, xData, &res->_oval );

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONgetStiff () -----------	*/
/* -------------------- ALIAS getStiff FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, getStiff ) {

	STR_RES("");		// no output
	CHECK_ARGCOUNT( 0 );	// check arg number

	res->type		= VS_object;
	if( !strcmp( xData->parsedElmDesc, VLPC_INITIALIZE ) ||
	    !strcmp( xData->parsedElmDesc, VLPC_BORDER ) )
	{
	   res->_oval.obj_id    = inp->toBeDrawn.elmList[0];
	}
	else
 	{
	   res->_oval.obj_id	= inp->toBeDrawn.elmList[VLPC_IDX_SUPPORT];
       	}
	res->_oval.mod_env	= *inp->drwInfo.drwEnv;

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONgetFoot () -----------	*/
/* -------------------- ALIAS getFoot FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, getFoot ) {
IGRint		suc;
IGRlong		sts, msg;
struct GRid	border, footId;
VStktxt 	footName;

	STR_RES("");		// no output
	CHECK_ARGCOUNT( 1 );	// check arg number

	VSdrwStrVal( &arglist->arg, footName );

        // get border
        border = inp->toBeDrawn.elmList[VLPC_IDX_BORDER];

        if( !vs$is_ancestry_valid( object  = &border,
                                  classid = OPP_ACheader_class_id ) ) {
           if( vs$is_ancestry_valid( 
			object  = &inp->toBeDrawn.elmList[VLPC_IDX_ACHEADER],
                        classid = OPP_ACheader_class_id ) )
                border = inp->toBeDrawn.elmList[VLPC_IDX_ACHEADER];
           else return xfFAILURE;
        }

        sts = om$send(  msg      = message NDmacro.ACreturn_foot(
                                                &msg,
                                                footName,
						&footId,
                                                NULL, NULL ),
            	senderid = NULL_OBJID,
            	targetid = border.objid,
            	targetos = border.osnum );
        if( ! (sts&msg&1))      return xfFAILURE;

        // generate pretend on border for the foot
        res->_oval.obj_id.objid     = NULL_OBJID;
        sts = om$send(  msg      = message ASnode.ACconnect_pretend
                                      ( &suc, footName, &footId ),
                senderid = NULL_OBJID,
                targetid = border.objid,
                targetos = border.osnum );

	res->type		= VS_object;
	res->_oval.obj_id	= footId;
	res->_oval.mod_env	= *inp->drwInfo.drwEnv;

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONgetViewName () -----------      */
/* -------------------- ALIAS getViewName FUNCTION ----------------      */
#argsused
IMPLEMENT_FUNCTION( VL, getViewName ) {

long                    sts;
struct  ACrg_coll       attr;

        DBL_RES( 0 );           // init output

        strcpy( attr.name, VLSDL_VIEW );
        sts = vl$sdlGetAttr(    ctx     = (VLsdlContext *) inp->appData,
                                colType = VLSDL_SYST_COL,
                                attr    = &attr );
        if( ! (sts&1))  return xfFAILURE;

        if( AC_ATTRIB_TEXT != attr.desc.type ) return xfFAILURE;

        STR_RES( attr.desc.value.att_txt );

return  xfSUCCESS;
}

void VLpcSetGlobPcTerminate( IGRboolean		value )
{
    glob_pc_terminate = value ;
}

void VLpcGetGlobPcTerminate( IGRboolean         *value )
{
    *value = glob_pc_terminate ;
}

/* -------------------- FCT VLdrwFUNCTIONpcTerminate () -----------      */
/* -------------------- ALIAS pcTerminate FUNCTION ----------------      */
#argsused
IMPLEMENT_FUNCTION( VL, pcTerminate ) {

     INT_RES( 0  );

     glob_pc_terminate = TRUE;

     return  xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONpcSetExtremeDim () -----------      */
/* -------------------- ALIAS pcSetExtremeDim FUNCTION ----------------      */
#argsused
IMPLEMENT_FUNCTION( VL, pcSetExtremeDim ) {

     INT_RES( 0  );

     VLpcSetIsFromExtremeties( 1 );

     return  xfSUCCESS;
}

void VLpcResetBothETMac()
{
int	i;

   for( i=0; i<MAX_MAC_BOTH_ET; ++i )
	mac_both_et[i][0] = '\0';

   nb_mac_both_et = 0;
}

void VLpcSetBothETMac( IGRchar	*macName )
{
   if( nb_mac_both_et < MAX_MAC_BOTH_ET )
   {
      strcpy( mac_both_et[nb_mac_both_et], macName );
      nb_mac_both_et++;
   }
}

void VLpcGetBothETMacCount( IGRint *macCount )
{
   *macCount = nb_mac_both_et;
}

void VLpcGetBothETMac( IGRint	index, IGRchar  *macName )
{
   if( index < nb_mac_both_et )
   {
      strcpy( macName, mac_both_et[index] ); 
   }
}

void VLpcResetOpenETMac()
{
int	i;

   for( i=0; i<MAX_MAC_OPEN_ET; ++i )
        mac_open_et[i][0] = '\0';

   nb_mac_open_et = 0;
}

void VLpcSetOpenETMac( IGRchar  *macName )
{
   if( nb_mac_open_et < MAX_MAC_OPEN_ET )
   {
      strcpy( mac_open_et[nb_mac_open_et], macName ); 
      nb_mac_open_et++;
   }
}

void VLpcGetOpenETMacCount( IGRint *macCount )
{
   *macCount = nb_mac_open_et;
}

void VLpcGetOpenETMac( IGRint   index, IGRchar  *macName )
{
   if( index < nb_mac_open_et )
   {
      strcpy( macName, mac_open_et[index] ); 
   }
}

/* -------------------- FCT VLdrwFUNCTIONpcSetMacBothET () -----------      */
/* -------------------- ALIAS pcSetMacBothET FUNCTION ----------------      */
#argsused
IMPLEMENT_FUNCTION( VL, pcSetMacBothET ) {

     VStktxt macName;

     SetProc( VLdrwFUNCTIONpcSetMacBothET ); Begin

     CHECK_ARGCOUNT( 1 );    // check arg number

     VSdrwStrVal( &arglist->arg, macName );
     __DBGpr_str("Input Macro Name", macName );

     VLpcSetBothETMac( macName );

     End
     return  xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONpcSetMacOpenET () -----------      */
/* -------------------- ALIAS pcSetMacOpenET FUNCTION ----------------      */
#argsused
IMPLEMENT_FUNCTION( VL, pcSetMacOpenET ) {

     VStktxt macName;

     SetProc( VLdrwFUNCTIONpcSetMacOpenET ); Begin

     CHECK_ARGCOUNT( 1 );    // check arg number

     VSdrwStrVal( &arglist->arg, macName );
     __DBGpr_str("Input Macro Name", macName );

     VLpcSetOpenETMac( macName );

     End
     return  xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONpcGetXBase () -----------      */
/* -------------------- ALIAS pcGetXBase FUNCTION ----------------      */
#argsused
IMPLEMENT_FUNCTION( VL, pcGetXBase ) {

     IGRint		ind;
     IGRdouble		end_ln1, end_ln2;
     VLpcContext 	*pcCtx;

     SetProc( VLdrwFUNCTIONpcGetXBase ); Begin

     CHECK_ARGCOUNT( 1 );    // check arg number

     DBL_RES( 0.0 );

     ind = VSdrwIntVal( &arglist->arg );
     __DBGpr_int("Input for pcGetXBase function", ind );

     pcCtx =  ((VLpcContext*) ((VLsdlContext*)(inp->appData))->stateArgs );

     VLpcGetETLengths( pcCtx->nbMac, pcCtx->macInfoList,
	               &end_ln1, &end_ln2 );
     __DBGpr_dbl( "Start X Base", end_ln1 );
     __DBGpr_dbl( "End X Base", end_ln2 );

     if( ind == 0 )		{ DBL_RES( end_ln1 ); }
     else if( ind == 1 ) 	{ DBL_RES( end_ln2 ); }

     End
     return  xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONpcGetStartPoint () -----------      */
/* -------------------- ALIAS pcGetStartPoint FUNCTION ----------------      */
#argsused
IMPLEMENT_FUNCTION( VL, pcGetStartPoint ) {

VLpcContext             *pcCtx;

     pcCtx =  ((VLpcContext*) ((VLsdlContext*)(inp->appData))->stateArgs );

     res->type  = VS_object;

     res->_oval.obj_id  = pcCtx->stiffInfo->origin;
     res->_oval.mod_env = *(DRW_elmEnv);

     return  xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONpcGetPlateThkDir () -----------     */
/* -------------------- ALIAS pcGetPlateThkDir FUNCTION ---------------      */
#argsused
IMPLEMENT_FUNCTION( VL, pcGetPlateThkDir ) {
BSrc			rc;
IGRlong			sts, msg;
IGRint			i, count;
VStktxt 		macName, sfName;
IGRdouble		dotp;
IGRpoint		point[2], origin;
IGRvector		pltVector, stfVector;
struct GRid		plateID, *pChild=NULL;
struct GRobj_env	plt_surf;
struct IGRbsp_curve	*srfGeom=NULL;
VLpcContext             *pcCtx;

     SetProc( VLdrwFUNCTIONpcGetPlateThkDir ); Begin

     CHECK_ARGCOUNT( 0 );    // check arg number

     INT_RES( 0 );

     __DBGpr_obj( "Input Element", *DRW_elmId );

     vdobj$Get( objID = DRW_elmId, macName = macName );

     if( strcmp( macName, "stfPcMark" ) ) 
     {
	sts = VSgetChildrenGoThruPretends( &msg, DRW_elmId, &count, &pChild );
        if( ! (sts&msg&1) || !count )      goto wrapup;

	for( i=0; i<count; ++i )
	{
	   if( vd_$is_ancestry_valid( object  = &pChild[i],
				      classid = OPP_VSsrcPlate_class_id ) )
	   {
	       plateID = pChild[i];
	       break;
 	   }
	}
     }
     else
     {
        vdobj$GetParent( objID    = DRW_elmId,
                         idx      = 1,
                         parentID = &plateID );
     }
     __DBGpr_obj( "Chock Plate", plateID );

     for( i=0; i<2; ++i )
     {
	if( i == 0 ) 	strcpy( sfName, VS_K_plBotSfPath );
	else		strcpy( sfName, VS_K_plTopSfPath );

	_FREE( srfGeom );

        sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &msg,
                                      sfName,
                                      &plt_surf.obj_id,
                                      &plt_surf._matrix_type,
                                      plt_surf._matrix ),
               senderid = NULL_OBJID,
               targetid = plateID.objid,
               targetos = plateID.osnum ) ;
        __CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup ) ;
        __DBGpr_obj("Plate Surface", plt_surf.obj_id );

        plt_surf._md_os = plt_surf._osnum;
        sts = ex$get_modid( mod_osnum = plt_surf._md_os,
                            mod_id    = &plt_surf._md_id );

	sts = VLgetGeometry( &plt_surf, TRUE, NULL_OBJID,
			     (IGRchar **)&srfGeom, &msg );
        __CheckRC( sts, msg, "VLgetGeometry", wrapup ) ;

	BSsfeval( srfGeom, 0.5, 0.5, 0, point[i], &rc );
 
	_FREE( srfGeom );
     }

     __DBGpr_vec( "Base Point",   point[0] );
     __DBGpr_vec( "Offset Point", point[1] ); 

     BSmkvec ( &rc, pltVector, point[0], point[1] );
     BSnorvec( &rc, pltVector );
     __DBGpr_vec( "Plate Vector", pltVector );

     pcCtx =  ((VLpcContext*) ((VLsdlContext*)(inp->appData))->stateArgs );

     VLgetPtCoord( &msg, pcCtx->stiffInfo->origin, DRW_elmEnv, origin );
     __DBGpr_vec( "Stiffener Origin", origin );

     VLendpts( &msg, &pcCtx->stiffInfo->iso0,  DRW_elmEnv, point[0], point[1]);
     __DBGpr_vec( "Stiffener Start Point", point[0] );
     __DBGpr_vec( "Stiffener End Point", point[1] );

     if( BSdistptpt( &rc, origin, point[0] ) > 
	 BSdistptpt( &rc, origin, point[1] ) ) 
     {
	__DBGpr_com( "Need to reverse the points" );
	dblcpy( origin, point[0], 3 );
 	dblcpy( point[0], point[1], 3 );
	dblcpy( point[1], origin, 3 );

        __DBGpr_vec( "Stiffener TRUE Start Point", point[0] );
        __DBGpr_vec( "Stiffener TRUE End Point", point[1] );
     }

     BSmkvec ( &rc, stfVector, point[0], point[1] );
     BSnorvec( &rc, stfVector );
     __DBGpr_vec( "Stiffener Vector", stfVector );
     if( rc != BSSUCC ) goto wrapup;

     dotp = BSdotp( &rc, pltVector, stfVector );
     __DBGpr_dbl( "Dot Product between Plate/Stiffener vectors", dotp );

     if( dotp < 0 )  { INT_RES(  1 ); }
     else	     { INT_RES( -1 ); }

wrapup:
     _FREE( pChild );
     _FREE( srfGeom );
     End
     return  xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONisCurvedBeam () -----------      */
/* -------------------- ALIAS isCurvedBeam FUNCTION ----------------      */
#argsused
IMPLEMENT_FUNCTION( VL, isCurvedBeam ) {
BSrc			rc;
int                     ACrc, index = -1;
IGRboolean		check_tol=FALSE;
long                    sts, msg;
IGRdouble		tol, par1, par2, dist, maxdist, avgerr, ratio,
			line_length;
IGRpoint		pt1, pt2, spt, ept;
struct GRobj_env        stiff, axis;
struct ret_struct       rs ;
struct IGRbsp_curve	*axisGeom=NULL, *lineGeom=NULL;

     INT_RES( 0 );

     if( argc )
     {
	if( arglist->arg.type == VS_object )
	{
	     stiff = arglist->arg.v.oval;
	     if( argc > 1 )
	     {
	        check_tol = TRUE;
		tol = VSdrwDblVal( &arglist->next->arg );
	     }
	}
	else
	{
	     stiff.obj_id  = inp->toBeDrawn.elmList[0];
	     stiff.mod_env = *(inp->elmEnv);
	     check_tol = TRUE;
	     tol = VSdrwDblVal( &arglist->arg );
	}
     }
     else
     {
         stiff.obj_id  = inp->toBeDrawn.elmList[0];
         stiff.mod_env = *(inp->elmEnv);
     }

     sts = om$send(  msg     = message ACcpx.ACgive_structure(
                        &ACrc, &index, VS_K_prMbrGeoAttr, &rs, &stiff.mod_env ),
		     senderid = stiff.obj_id.objid,
                     targetid = stiff.obj_id.objid,
		     targetos = stiff.obj_id.osnum ) ;
     if( !(sts&ACrc&1) ) return xfFAILURE;

     INT_RES( rs.var.root_pm_st.value  );

     if( check_tol && rs.var.root_pm_st.value == 1.0 )
     {
	__DBGpr_dbl( "Input Tolerance for IsCurvebeam", tol );
        sts = om$send( msg = message VSbeam.VSgetSupportAxis(
                                        &msg,
                                        &stiff.mod_env,
                                        &axis ),
                        senderid = NULL_OBJID,
                        targetid = stiff.obj_id.objid,
                        targetos = stiff.obj_id.osnum ) ;
	if( !(sts&msg&1) ) return xfSUCCESS;

	sts = VLgetGeometry( &axis, FALSE, NULL_OBJID,
                             (IGRchar **)&axisGeom, &msg );
	if( !(sts&1&msg) ) return xfSUCCESS;

	MAbcendpts( &rc, axisGeom, spt, ept );

	VDgeomMakeLineCurve( spt, ept, &lineGeom );

	BSnrm_2_cvs( axisGeom, lineGeom, &maxdist, &avgerr, 
		     &par1, &par2, pt1, pt2, &rc );
	_FREE( axisGeom );
	_FREE( lineGeom );
	if( rc != BSSUCC ) return xfSUCCESS;

	__DBGpr_dbl( "Maximum Distance between two curves", maxdist );

	line_length = BSdistptpt( &rc, spt, ept );
	__DBGpr_dbl( "Linear Axis Length", line_length );

	ratio = maxdist / line_length ;
	__DBGpr_dbl( "Ratio", ratio );

	if( ratio < tol ) 
	{
	   INT_RES( 0 );
	}
     }

return  xfSUCCESS;
}

static IGRint VLpcSortBendLines ( line1, line2 )
struct GRobj_env *line1, *line2;
{
BSrc		rc;
IGRlong 	sts, msg;
IGRdouble	len1, len2;
IGRpoint	Spt1, Spt2, Ept;

  sts = VLendpts ( &msg, &line1->obj_id, &line1->mod_env, Spt1, Ept);
  sts = VLendpts ( &msg, &line2->obj_id, &line2->mod_env, Spt2, Ept);

  len1 = BSdotp ( &rc,  x_vec, Spt1 ) ;
  len2 = BSdotp ( &rc,  x_vec, Spt2 ) ;

  return ( ( len1 == len2 ) ? 0 : ( len1 < len2 ) ? -1 : 1);

}

static void  VLpcSetAndExecPPLInput(	IGRchar		*pplName,
					IGRchar		*funcName,
					IGRint		index,
					IGRdouble	step,
					IGRdouble	height,
					IGRchar		*macName )
{
   vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                           index      = 1,
                           type       = VD_int,
                           value      = &index );

   vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                           index      = 2,
                           type       = VD_double,
                           value      = &step );

   vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                           index      = 3,
                           type       = VD_double,
                           value      = &height );

   vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                           index      = 4,
                           type       = VD_string,
                           value      = macName  );

   ci$exec( file_name = pplName,
            sender_id = NULL_OBJID,
            entry     = funcName  );

}

static void  VLpcGetPPLOutput(  IGRint		*count,
			     	struct GRid	**list )
{
IGRint 			i, tmp_count=0;
struct GRobj_env 	tmp_obj;

   vd$ppl_get_size(  which_info = OUTPUT_INFO,
                     size       = &tmp_count );

   if( (*list) )
   {
        (*list) = _REALLOC( (*list), (*count) + tmp_count, struct GRid );
   }
   else
   {
       (*list) =  _MALLOC( tmp_count, struct GRid ) ;
   }

   for( i=0; i<tmp_count; ++i )
   { 
      vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
                              index      = i,
                              value      = &tmp_obj  );
      (*list)[i+(*count)] = tmp_obj.obj_id;
    }
    (*count) += tmp_count;
}

/* -------------------- FCT VLdrwFUNCTIONplaceBendTable () -----------      */
/* -------------------- ALIAS placeBendTable FUNCTION ----------------      */
#argsused
IMPLEMENT_OUTPUT( VL, placeBendTable ) {

BSrc			rc;
IGRlong			sts, msg;
IGRshort                RefMatType, trfMatType;
IGRint			i, j, k, ind, ii, nb_lines, bendCount=0, outCount=0,
			four=4, nb_heights=0, action=1;
IGRchar                 srfName[DI_PATH_MAX];
IGRpoint        	pts[5], Spt, Ept, Cpt, CsOrigin, *pnt=NULL;
IGRvector       	Vec, Xvec, Yvec;
IGRdouble		step, len, *height_val=NULL, *par=NULL;
IGRmatrix               OrgMat, RefMat, trfMat;
struct GRid		gmMacDef, *bendList=NULL, *outList=NULL;
struct GRsymbology      symbology;
struct GRvg_construct   cst;
struct GRobj_env	stiff, cs, BaseSrf;
struct IGRpolyline      poly;
struct IGRbsp_curve     *crv=NULL;
VLpcContext             *pcCtx;
GRname			gmMacro;
VStktxt         	faceName, pplName;

   SetProc( VLdrwFUNCTIONplaceBendTable ); Begin

   /* Initialization */
   outpgr->count   = 0;
   outpgr->list    = NULL;

   outCount = 0;
   outList  = NULL;

   __DBGpr_int("Argument Count ", argc );
   if(!argc ) return xfFAILURE;

   vs$fill_cnst_list( Msg          = &msg,
                      Env_info     = inp->drwInfo.drwEnv,
                      Level        = xData->overrides.elmLevel,
                      Display      = &xData->overrides.elmDisplay,
                      Cnst_list    = cst ) ;

   bendCount   = MACRO_SB_FFEET+MACRO_SB_VFEET;
   if( !( bendList = _MALLOC( bendCount, struct GRid )) )
   vd_$mem_fail(msg=&msg);

   for ( i=0; i<bendCount; i++) {
  	bendList[i].objid = NULL_OBJID;
        bendList[i].osnum = cst.env_info->md_id.osnum;
   }

   poly.num_points = 5;
   poly.points     = (IGRdouble *) pts;

   pcCtx =  ((VLpcContext*) ((VLsdlContext*)(inp->appData))->stateArgs );

   // Cs
   sts = om$send(  msg     = message NDmacro.ACreturn_foot( &msg, "",
                                        &cs.obj_id,
                                        &cs._matrix_type,
                                        cs._matrix ),
                        senderid = NULL_OBJID,
                        targetid = arglist->arg.v.oval._objid,
                        targetos = arglist->arg.v.oval._osnum );
   cs._md_os = arglist->arg.v.oval._osnum;
   sts = ex$get_modid( mod_osnum =  cs._md_os,
                       mod_id    = &cs._md_id );
   __DBGpr_obj("Coordinate System Object ", cs.obj_id );

   VSdrwStrVal( &arglist->next->arg, faceName );
   __DBGpr_str("Web Face Name ", faceName );

   if( argc > 1 )  step = VSdrwDblVal( &arglist->next->next->arg );
   else		   step = 300.0;
   __DBGpr_dbl("Step Value ", step );

   VSdrwStrVal( &arglist->next->next->next->arg, pplName );
   __DBGpr_str("PPL Name ", pplName );

   // Stiffner
   sts = om$send(  msg     = message NDmacro.ACreturn_foot( 
					&msg, "",
                                        &stiff.obj_id,
                                        &stiff._matrix_type,
                                        stiff._matrix ),
                        senderid = NULL_OBJID,
              targetid = inp->toBeDrawn.elmList[VLPC_IDX_SUPPORT].objid,
	      targetos = inp->toBeDrawn.elmList[VLPC_IDX_SUPPORT].osnum );
   __CheckRC( sts, msg, "ACreturn_foot:Stiffener", wrapup );

   stiff._md_os = stiff._osnum;
   sts = ex$get_modid( mod_osnum =  stiff._md_os,
                       mod_id    = &stiff._md_id );
   __DBGpr_obj("Stiffener Object ", stiff.obj_id );

   //cs.obj_id  = inp->toBeDrawn.elmList[VLPC_IDX_BORDER] ;
   //cs.mod_env = *inp->drwInfo.drwEnv ;
   //__DBGpr_obj("Coordinate System Object ", cs.obj_id );

   srfName[0] = '\0';
   sprintf( srfName, "%s:%s:%s", VS_K_bmGrCmpName, VS_K_bmBody, faceName );
   __DBGpr_str("Getting Face from Stiffener ", srfName );

   sts = om$send ( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        srfName,
                                        &BaseSrf.obj_id,
                                        &BaseSrf.mod_env.md_env.matrix_type,
                                        BaseSrf.mod_env.md_env.matrix ),
                                senderid = NULL_OBJID,
                                targetid = stiff._objid,
                                targetos = stiff._osnum );
   __CheckRC( sts, msg, "ACreturn_foot:WebFace", wrapup );
  BaseSrf.mod_env = stiff.mod_env;
  __DBGpr_obj("Face ID ", BaseSrf.obj_id );

  /* Get the coordinate system matrix */
  sts = om$send ( msg = message GRgencs.GRgetmatrix
                                                ( &msg, OrgMat ),
                        senderid = NULL_OBJID,
                        targetid = cs._objid,
                        targetos = cs._osnum );
  __CheckRC( sts, msg, "GRgencs.GRgetmatrix", wrapup );

  if( cs._matrix_type != MAIDMX ){
  	MAmulmx( &msg, &four, &four, &four, cs._matrix, OrgMat, trfMat );
        for( i=0; i<16; i++ )   RefMat[i] = trfMat[i];
  }
  else  for( i=0; i<16; i++ )   RefMat[i] = OrgMat[i];
  MAtypemx( &msg, RefMat, &RefMatType);

  CsOrigin[0] = RefMat[3]; 
  CsOrigin[1] = RefMat[7];
  CsOrigin[2] = RefMat[11];
  __DBGpr_vec("Coordinate System Origin ", CsOrigin );

  /* Call computation function */
  sts = VLcreStifBend ( &stiff, &BaseSrf, &cst, RefMat, faceName,
			&bendCount, bendList, &msg );
  __CheckRC( sts, msg, "VLcreStifBend", wrapup );

  nb_lines = bendCount / 2 - 1;
  __DBGpr_int("Number of Bending Curves Placed ", nb_lines );

  /* Store direction and orthogonal vectors */
  for ( i=0; i<3; i++) {  Xvec[i]  = RefMat[4*i];
			  x_vec[i] = RefMat[4*i];
                          Yvec[i]  = RefMat[4*i+1];        }

  sts = om$send ( msg = message GRlinear.GRgetpolyline (
                                 &msg,
                                 &inp->drwInfo.drwEnv->md_env.matrix_type,
                                 inp->drwInfo.drwEnv->md_env.matrix,
                                 &action, &poly ),
                        senderid = NULL_OBJID,
                        targetid = bendList[0].objid,
                        targetos = bendList[0].osnum );
  __CheckRC( sts, msg, "GRlinear.GRgetpolyline", wrapup );

  vd$ppl_set_size(  which_info = INPUT_INFO,
                    size       = 6              );

  vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                          index = 0,
                          type  = VD_object,
                          value = &cs );

  ci$exec( file_name = pplName,
           sender_id = NULL_OBJID,
           entry     = "header"  );

  VLpcGetPPLOutput( &outCount, &outList );

  // If the function returns more than one bending line,
  // Sort them in X direction.
  if( nb_lines > 1 )
  {
     struct GRobj_env *bendObj=NULL;

     __DBGpr_objlist("Before Sort BendLines ",nb_lines,&bendList[nb_lines+2]);
     ind = 0;
     if( !( bendObj = _MALLOC( nb_lines, struct GRobj_env )) )
   	vd_$mem_fail(msg=&msg);
     for( i=0; i<nb_lines; ++i )
     {
	bendObj[i].obj_id  = bendList[i+nb_lines+2];
	bendObj[i].mod_env = *(inp->drwInfo.drwEnv);
     }
     qsort ( bendObj, nb_lines, sizeof(struct GRobj_env),
				(int (*)())VLpcSortBendLines );
     for( i=0; i<nb_lines; ++i ) bendList[i+nb_lines+2] = bendObj[i].obj_id;
     __DBGpr_objlist("After Sort BendLines ",nb_lines,&bendList[nb_lines+2]);
     _FREE( bendObj );
  }

  ind = 1;
  for( i=nb_lines+2; i<bendCount; ++i )
  {
    	__DBGpr_int("Calculating Heights for curve ", i );
    	nb_heights = 0;
    	_FREE( height_val );
    	_FREE( crv );

	if( ind == 1 ) // Evaluate only once
	{
            /* Evaluate end vectors of curve */
            sts = VLendpts ( &msg, &bendList[i], inp->drwInfo.drwEnv,
                             Spt, Ept);
            __CheckRC( sts, msg, "VLendpts", wrapup );
            __DBGpr_vec("Start Point of BendLine ", Spt );
            __DBGpr_vec("End Point of BendLine ", Ept );

	    if( ( BSdistptpt( &rc, CsOrigin, Spt ) ) <
		( BSdistptpt( &rc, CsOrigin, Ept ) ) )
			BSmkvec ( &rc, Vec, CsOrigin, Spt );
	    else	BSmkvec ( &rc, Vec, CsOrigin, Ept );

            len = fabs( BSdotp ( &rc,  Xvec, Vec ) );
            __DBGpr_dbl("Offset of Bend Curve from CS ", len );
            __DBGpr_int("Number of Macros on Stiffener ", pcCtx->nbMac );
	}

        /* Get bended line geometry */
        sts = VLgetGeometry ( &bendList[i], FALSE, NULL_OBJID, 
				  (IGRchar **)&crv, &msg);
        __CheckRC( sts, msg, "VLgetGeometry:BendLine", wrapup );

        /* Compute heights */
        sts = VLgetHeights ( inp->drwInfo.drwEnv, &bendList[i],
                             &poly.points[0], &poly.points[3], step,
                         Xvec, Yvec, crv, &nb_heights, &height_val, &msg );
	__CheckRC( sts, msg, "VLgetHeights", wrapup );
        __DBGpr_int("Number of Heights ", nb_heights );

        for( j=0; j<nb_heights; ++j )
        {
	   IGRint	tmp_count=0;

	   vd$ppl_free_args( which_info = OUTPUT_INFO );
	   for( k=0; k<pcCtx->nbMac; ++k )
	   {
	      if(( pcCtx->macInfoList[k].xpos >= (len+height_val[2*j])  )
	        && pcCtx->macInfoList[k].xpos < (len+height_val[2*(j+1)])  )
	      {
		 IGRlong		 num_proj=0;
		 IGRdouble		 height=0.0;
		 IGRchar                 *macDef = NULL;
		 struct  GRid            defCol;

		 for ( ii=0; ii<3; ii++)  Cpt[ii] = poly.points[ii] + 
				 pcCtx->macInfoList[k].xpos * Xvec[ii];

		 _FREE( pnt ); _FREE( par );
		 BSpj_pt_cv ( crv, Cpt, Yvec, &num_proj, &pnt, &par, &rc );
		 if (rc != BSSUCC){ msg = MSFAIL; goto wrapup; }

		 if( num_proj > 0 ) 
		 {
		   __DBGpr_vec("Cpt ", Cpt );
		   __DBGpr_vec("Projection Point ", pnt[0] );

		   BSmkvec ( &rc, Vec, Cpt, pnt[0] );
		   if (rc != BSSUCC){ msg = MSFAIL; goto wrapup; }

		   __DBGpr_vec("Height Vector ", Vec );
		   height = BSlenvec ( &rc, Vec);
		   if (rc != BSSUCC){ msg = MSFAIL; goto wrapup; }

		   __DBGpr_dbl("Height ", height );
		 }

                 sts = om$send(  msg      = message ACcpx.find_macro( &defCol ),
                                targetid = pcCtx->macInfoList[k].mac->_objid,
                                targetos = pcCtx->macInfoList[k].mac->_osnum,
                                senderid = NULL_OBJID );

                 sts = om$send(  msg     = message ACcpx_defn.ACgive_name( 
								&macDef ),
                                targetid = defCol.objid,
                                targetos = defCol.osnum,
                                senderid = NULL_OBJID );

                vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                                        index      = 5,
                                        type       = VD_object,
                                        value      = pcCtx->macInfoList[k].mac);

		VLpcSetAndExecPPLInput( pplName, "row", ind, 
			pcCtx->macInfoList[k].xpos, height, macDef  );

		VLpcGetPPLOutput( &outCount, &outList );

		 ind++;
		 break;
              }
            }
	    VLpcSetAndExecPPLInput( pplName, "row", ind, len+height_val[2*j],
				    height_val[2*j+1], "" );
	    VLpcGetPPLOutput( &outCount, &outList );
	    ind++;	
	} 
   }

   outpgr->count = 1;
   if( !( outpgr->list = _MALLOC( 1, struct GRid )) )
       vd_$mem_fail(msg=&msg);

   sts = VD_drwGeomGiveMacroBySize( &msg, outCount+5, gmMacro );
   __CheckRC( sts, msg, "VD_drwGeomGiveMacroBySize", wrapup );
   __DBGpr_str(" Macro Name ", gmMacro );

   gmMacDef.objid = NULL_OBJID ;
   sts = ac$find_macro_defn(    action           = ACfind_load,
                                macro_name       = gmMacro,
                                p_macro_defn_id  = &gmMacDef );

   outpgr->list[0].osnum = cst.env_info->md_id.osnum;
   sts = om$construct(  classid = OPP_VDdrwGm_class_id,
                        osnum   = outpgr->list[0].osnum,
                        p_objid = &outpgr->list[0].objid,
                        msg     = message ACcpx.ACload_macro(gmMacDef));
   __CheckRC( sts, 1, "Construct VDdrwGm and Load Geom macro", wrapup );

   for( i=0 ; i<outCount ; i++ ){
        IGRlong  tmp_ind = OM_K_MAXINT;

        sts = om$send ( msg = message GRconnector.GRrigidconn(
				&msg, &outpgr->list[0], &tmp_ind ),
                        senderid = NULL_OBJID,
                        targetid = outList[i].objid,
                        targetos = outList[i].osnum );
        __CheckRC( sts, msg, "GRgencs.GRgetmatrix", wrapup );
   }

   sts = om$send ( msg = message NDnode.NDmove_to_root(
				&msg, &outpgr->list[0], cst.env_info ),
			senderid = NULL_OBJID,
                        targetid = outpgr->list[0].objid,
                        targetos = outpgr->list[0].osnum );
   __CheckRC( sts, msg, "NDnode.NDmove_to_root", wrapup );

   symbology.display_attr = *(cst.display) ;
   symbology.level = cst.level;
   sts = om$send( msg   = message GRvg.GRputsymb( &msg,&symbology ),
                         senderid = NULL_OBJID,
                         targetid = outpgr->list[0].objid,
                         targetos = outpgr->list[0].osnum );
   __DBGpr_obj("Final Output Object ( VDdrwGm ) ", outpgr->list[0] );

wrapup:
   vd$ppl_free_args( which_info = INPUT_INFO ); 
   vd$ppl_free_args( which_info = OUTPUT_INFO );

   vs$bulk_display( dpmode  = GRbehe,
                    count   = bendCount,
                    grids   = bendList,
		    theEnv  = cst.env_info );

   for( i=0; i<bendCount; ++i )
   {
        sts = om$send( msg = message GRgraphics.GRdelete(&msg,
                                                          cst.env_info),
                         senderid = NULL_OBJID,
                         targetid = bendList[i].objid,
                         targetos = bendList[i].osnum );
   }

   _FREE( height_val );
   _FREE( crv );
   _FREE( pnt ); 
   _FREE( par );
   _FREE( bendList );
   _FREE( outList );
   End
   return  xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONsetBorder () -----------      */
/* -------------------- ALIAS setBorder FUNCTION ----------------      */
#argsused
IMPLEMENT_FUNCTION( VL, setBorder ) {

long            sts;
struct  GRid    defId;
VStktxt         borderName;

        CHECK_ARGCOUNT( 1 );    // check arg number

        VSdrwStrVal( &arglist->arg, borderName );

        // check drawing border definition
        defId.objid    = NULL_OBJID;
        sts = ac$find_macro_defn(       action          = ACfind_load,
                                        macro_name      = borderName,
                                        p_macro_defn_id = &defId );
        if( ! (sts&1) || defId.objid == NULL_OBJID ) return xfFAILURE;

	strcpy( pcBorderName, borderName );

return  xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONsetWebRight () -----------      */
/* -------------------- ALIAS setWebRight FUNCTION ----------------      */
#argsused
IMPLEMENT_FUNCTION( VL, setWebRight ) {

	isWebRight = 1;

return  xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONgetMacroList () -----------      */
/* -------------------- ALIAS getMacroList FUNCTION ----------------      */
#argsused
IMPLEMENT_FUNCTION( VL, getMacroList ) {
int			i;
long                    sts;
VLpcContext 		*pcCtx;
VSexecRes               *pArray   = NULL ;

        pcCtx =  ((VLpcContext*) ((VLsdlContext*)(inp->appData))->stateArgs );

        pArray = VSdrwAryMalloc( pcCtx->nbMac ) ;
        res->type       = VS_array ;
        res->_aval.size = pcCtx->nbMac ;
        res->_aval.element = pArray ;

	for( i=0; i<pcCtx->nbMac; i++ )
	{
	   pArray[i].type  = VS_object;
	   pArray[i]._oval = *(pcCtx->macInfoList[i].mac);
	}

return  xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONgetMacroPositions () ----------- */
/* -------------------- ALIAS getMacroPositions FUNCTION ---------------- */
#argsused
IMPLEMENT_FUNCTION( VL, getMacroPositions ) {
int			i;
long                    sts;
VLpcContext             *pcCtx;
VSexecRes               *pArray   = NULL ;

        pcCtx =  ((VLpcContext*) ((VLsdlContext*)(inp->appData))->stateArgs );

        pArray = VSdrwAryMalloc( pcCtx->nbMac ) ;
        res->type       = VS_array ;
        res->_aval.size = pcCtx->nbMac ;
        res->_aval.element = pArray ;

        for( i=0; i<pcCtx->nbMac; i++ )
        {
           pArray[i].type  = VS_double;
           pArray[i]._dval = pcCtx->macInfoList[i].xpos;
        }
return  xfSUCCESS;
}

/* -------------------- FCT VLdrwFUNCTIONrotateGraphic () ----------	*/
/* -------------------- ALIAS rotateGraphic FUNCTION ----------------	*/
#argsused
IMPLEMENT_FUNCTION( VL, rotateGraphic ) {

long			sts, msg;
int			i;
double			angle;
VSdrwArgLst		*p;
double			rotMat[16], csMat[16], invCsMat[16];
double			xfMat[16], nMat[16];
short			xfType;
struct	GRid		csId;
GRobjid			newId;
short			four = 4;

	STR_RES("");		// no output
				// check arg number : 
				//	- Rotation angle
				//	- List of Graphic Object Id to rotate

	angle = VSdrwDblVal( &arglist->arg );

	MAidmx( &msg, rotMat );
	rotMat[0]	=  cos( angle );
	rotMat[1]	= -sin( angle );
	rotMat[4]	=  sin( angle );
	rotMat[5]	=  cos( angle );

	for( i=0, p=arglist->next ; i<argc-1 && p; i++, p=p->next ){

		csId	= p->arg.v.oval.obj_id;
		sts = om$send(	msg	 = message GRgencs.GRgetmatrix
						( &msg, csMat ),
				targetid = csId.objid,
				targetos = csId.osnum,
				senderid = NULL_OBJID );
		if( ! (sts&msg&1))	return	xfFAILURE;

		MAinvmx(&msg, &four, csMat, invCsMat);
		MAmulmx(&msg, &four, &four, &four, csMat, rotMat, nMat);
		MAmulmx(&msg, &four, &four, &four, nMat, invCsMat, xfMat);

		MAtypemx( &msg, xfMat, &xfType );
		sts = om$send(	msg	 = message GRgraphics.GRxform(
							&msg,
							inp->drwInfo.drwEnv,
							&xfType,
							xfMat,
							&newId ),
				senderid = NULL_OBJID,
				targetid = csId.objid,
				targetos = csId.osnum );
		as$status( sts = sts );
		as$status( sts = msg );
	}

return	xfSUCCESS;
}

/* -------------------- FCT VLdrwOUTPUTgetSection () ------------------	*/
/* -------------------- ALIAS getSection OUTPUT -----------------------	*/

IMPLEMENT_OUTPUT( VL, getSection ){

long			sts;
struct	GRid		xsId;
struct	GRvg_construct	cnst;
struct	GRobj_env	support;
double			SecMat[16];
double			Tx[16];
double			Ry[16];
double			invSec[16];
double			transf1[16];
double			transf2[16];
double			transf[16];
GRobjid			newId;
short			matType;
double			param;
short			four = 4;
long			msg ;
VSxfRC			rc ;


	/* Initialization */
	outpgr->count	= 0;
	outpgr->list	= NULL;

	CHECK_ARGCOUNTS(0,1);

	// get param
	param	= 0.;
	if( argc )param = VSdrwDblVal( &arglist->arg );

	vs$fill_cnst_list(	Cnst_list = cnst,
				Msg	  = &msg,
				Display	  = &xData->overrides.elmDisplay,
				Level	  = xData->overrides.elmLevel,
				Env_info  = inp->drwInfo.drwEnv );

	if( xData->overrides.dpAttr.filledDisplay )
					cnst.properties |= GRFILLED_DISPLAY;
	// get beam profile
	sts = om$send(	msg	 = message VSbeam.VSextractProfile(
					&msg,
					inp->elmEnv,
					NULL,	// surface
					NULL,	// axis
					0.,	// param,
					&cnst,
					AC_3D_REP,
					&xsId ),
			targetid = inp->elmId->objid,
			targetos = inp->elmId->osnum,
			senderid = NULL_OBJID );
	if( ! (sts & msg & 1)){ rc = xfFAILURE; goto wrapup; }

//	printf(" xsId : %d/%d\n", xsId.objid, xsId.osnum );

	// Transf = SecMat * T * Ry * inv(SecMat)
	support.obj_id 	= *(inp->elmId);
	support.mod_env = *(inp->elmEnv);
	sts = VLgetCsStiff( &support, SecMat );
	MAinvmx(&msg, &four, SecMat, invSec);

	// move profile in drawing view :: rotation of PI/2 around Y
	MAidmx( &msg, Ry );
	Ry[0] = 0; 	Ry[2]  = -1;
	Ry[8] = 1;	Ry[10] = 0;

	MAidmx( &msg, Tx );
	Tx[11] = param;

	MAmulmx(&msg, &four, &four, &four, SecMat, Tx , transf1);
	MAmulmx(&msg, &four, &four, &four, transf1, Ry, transf2);
	MAmulmx(&msg, &four, &four, &four, transf2, invSec, transf);
 
	MAtypemx( &msg, transf, &matType);

	sts = om$send( msg	 = message GRgraphics.GRxform(
						&msg,
						inp->drwInfo.drwEnv,
						&matType,
						transf,
						&newId ),
			targetos = xsId.osnum,
			targetid = xsId.objid,
			senderid = NULL_OBJID );

	outpgr->list	= (struct GRid *)malloc(sizeof(struct GRid));
	outpgr->list[0]	= xsId;
	outpgr->count	= 1;

	rc = xfSUCCESS;

wrapup :

return rc;
}

/* -------------------- FCT VLdrwOUTPUTvlProjection () -----------	*/
/* -------------------- ALIAS vlProjection OUTPUT ----------------	*/
#argsused
IMPLEMENT_OUTPUT( VL, vlProjection ) {

long			sts, msg;
VSxfRC			rc;
VLvasCs			*vas;
GRobjid			newId;
int			i;

	rc = VSdrwOUTPUTprojection(inp,xData,function,arglist,argc,outpgr);

	// xform out put 
	vas = &((VLpcContext*)((VLsdlContext*)(inp->appData))
						->stateArgs )->vasCs;
	for( i=0; i<outpgr->count; i++ ){

		sts = om$send( msg = message GRgraphics.GRxform(
					&msg,
					inp->drwInfo.drwEnv,
					&vas->type,
					vas->mat,
					&newId ),
				targetos = outpgr->list[i].osnum,
				targetid = outpgr->list[i].objid,
				senderid = NULL_OBJID );
		if( ! (sts&msg&1)){
			printf(" Error in XForm \n");
			as$status( sts = sts );
			as$status( sts = msg );
		}
	}

return	rc;
}

/* -------------------- FCT VLdrwOUTPUTvlMember () -----------	*/
/* -------------------- ALIAS vlMember OUTPUT ----------------	*/
#argsused
IMPLEMENT_OUTPUT( VL, vlMember ) {

long			sts, msg;
VSxfRC			rc;
VLvasCs			*vas;
GRobjid			newId;
int			i;

	rc = VSdrwOUTPUTmember(inp,xData,function,arglist,argc,outpgr);

	// xform out put 
	vas = &((VLpcContext*)((VLsdlContext*)(inp->appData))
						->stateArgs )->vasCs;
	for( i=0; i<outpgr->count; i++ ){

		sts = om$send( msg = message GRgraphics.GRxform(
					&msg,
					inp->drwInfo.drwEnv,
					&vas->type,
					vas->mat,
					&newId ),
				targetos = outpgr->list[i].osnum,
				targetid = outpgr->list[i].objid,
				senderid = NULL_OBJID );
		if( ! (sts&msg&1)){
			printf(" Error in XForm \n");
			as$status( sts = sts );
			as$status( sts = msg );
		}
	}

return	rc;
}

/* -------------------- FCT VLdrwOUTPUTplaceBendLines () -----------	*/
/* -------------------- ALIAS placeBendLines OUTPUT ----------------	*/
#argsused
IMPLEMENT_OUTPUT( VL, placeBendLines ) {
int			i;
long			sts, msg;
IGRboolean		onlyLines;
VSdrwArgLst		*p;
VStktxt			webSide;
struct GRobj_env	TempList[3];
struct GRsymbology	symb;

	SetProc( placeBendLines ); Begin

	outpgr->count = 0;
	outpgr->list  = NULL;

        onlyLines=TRUE;

	VSdrwStrVal( &arglist->arg, webSide );
	if( strcmp( webSide, VS_K_nmWebL ) && strcmp( webSide, VS_K_nmWebR ))
	{
	   strcpy( webSide, VS_K_nmWebL );
	}

	__DBGpr_int("Argument Count ", argc );
	for( i=0, p=arglist->next; p; ++i, p=p->next )
 	{
	   switch( p->arg.type ){

		case VS_object :
			TempList[i] =  p->arg.v.oval;
			break;

		default :	onlyLines = VSdrwBoolVal( &p->arg );
			/*	printf(" Invalid Argument \n");
				return	xfFAILURE;  */
	   }

	}

	__DBGpr_int("Only Bendling Lines? ", onlyLines );

	sts = VLcreBendOnPc( &msg, TempList[0],  TempList[1], TempList[2],
			     webSide, onlyLines, inp->drwInfo.drwEnv,
			     &outpgr->count, &outpgr->list );
	if( !(sts&msg&1) ) return xfFAILURE;

	if( xData->symbOverrides & VSdrwLevelOverriden )
	for( i=0; i<outpgr->count; ++i )
		sts = om$send(	msg	 = message GRvg.GRchglevel
					( &msg, &xData->overrides.elmLevel ),
				senderid = NULL_OBJID,
				targetid = outpgr->list[i].objid,
				targetos = outpgr->list[i].osnum );

	if( xData->symbOverrides & VSdrwColorOverriden )
	for( i=0; i<outpgr->count; ++i )
		sts = om$send(	msg	 = message GRvg.GRchgcolor( 
					&msg,
					NULL,
					&xData->overrides.elmDisplay.color ),
				senderid = NULL_OBJID,
				targetid = outpgr->list[i].objid,
				targetos = outpgr->list[i].osnum );

	if( xData->symbOverrides & VSdrwWeightOverriden )
	for( i=0; i<outpgr->count; ++i )
		sts = om$send(	msg	 = message GRvg.GRchgweight( 
					&msg,
					&xData->overrides.elmDisplay.weight ),
				senderid = NULL_OBJID,
				targetid = outpgr->list[i].objid,
				targetos = outpgr->list[i].osnum );

	if( xData->symbOverrides & VSdrwStyleOverriden )
	for( i=0; i<outpgr->count; ++i )
		sts = om$send(	msg	 = message GRvg.GRchgstyle( 
					&msg,
					&xData->overrides.elmDisplay.style ),
				senderid = NULL_OBJID,
				targetid = outpgr->list[i].objid,
				targetos = outpgr->list[i].osnum );
	End
	return	xfSUCCESS;
}

/* -------------------- FCT VLdrwOUTPUTplaceMacro () -----------	*/
/* -------------------- ALIAS placeMacro OUTPUT ----------------	*/
#argsused
IMPLEMENT_OUTPUT( VL, placeMacro ) {

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
					"vl-PlaceMacro", macName );
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

	if( nbTemp > (argc-1) )  nbTemp = (argc-1);

	// set symbologie
	symb.display_attr	= xData->overrides.elmDisplay;
	symb.level		= xData->overrides.elmLevel;

	// place macro
	sts = vl$plmacro(	macName	= macName,
				tplNb	= nbTemp,
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
}

/*---------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VL, stfPcMark ) {

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "stfPcMark" ) ;

	if( DRW_wantType  ) 
        {
	  DRW_elmType = 0 ;
	  inp->constDefName[0] ='\0';
          if (vs$is_ancestry_valid( object  = DRW_elmId,
                                     classid = OPP_nci_macro_class_id ) )
          {
	     vdobj$Get( objID = DRW_elmId, macName = inp->constDefName );
	     DRW_elmType = VS_gI_InAsbly ;
	     strcpy( DRW_elmFilter, "stfPcMark" ) ;
	  }
       }

        if( DRW_wantView )  DRW_elmView = VSanyViewType ;

} /* ISOFTYPE( stfPcMark ) */

end implementation VLpcAbst;
