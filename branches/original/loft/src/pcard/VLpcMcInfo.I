/* $Id: VLpcMcInfo.I,v 1.6 2001/10/17 22:48:51 jayadev Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/pcard/VLpcMcInfo.I
 *
 * Description: Management of cutting macro information during PC process.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLpcMcInfo.I,v $
 *      Revision 1.6  2001/10/17 22:48:51  jayadev
 *      fix for TR#5216
 *
 *      Revision 1.5  2001/03/12 21:03:53  ramarao
 *      Changes to accept ~~orientation1 && ~~orientation2.
 *
 *      Revision 1.4  2001/02/20 01:05:32  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.3  2001/01/28 18:38:41  ramarao
 *      Implemented CR# MP 4301 on Stiffner Automarking process.
 *
# Revision 1.2  2001/01/04  20:54:58  pinnacle
# Replaced: loft/src/pcard/VLpcMcInfo.I for:  by rchennup for Service Pack
#
# Revision 1.4  2000/03/23  21:46:12  pinnacle
# Replaced: src/pcard/VLpcMcInfo.I for:  by impd252 for loft
#
# Revision 1.3  2000/03/09  23:41:32  pinnacle
# Fixed problems in VLpcMcInfo and VLpcMarkingMcInfo functions.
#
 *
 * History:
 * MM/DD/YY   AUTHOR       DESCRIPTION
 * 09/07/94   LLC          File Creation.
 * 03/09/00   Rama Rao     Header Creation and fixed problems in
 *			   VLpcMcInfo and VLpcMarkingMcInfo functions.
 * 10/17/00   Jayadev      Added VLpcDoubleCutMacro() for TR# MP5216
 *************************************************************************/

class implementation VLpcAbst;

#include <stdio.h>
#include "igrdef.h"
#include "igr.h"
#include "AS_status.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "vsdrwapi.h"
#include "vlsdldef.h"
#include "vlsdl.h"
#include "vlsdlmacros.h"
#include "vlpcdef.h"
#include "vlpc.h"
#include "vlpcmacros.h"
#include "stdlib.h"
#include "bserr.h"
#include "bstypes.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "VDobj.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"
#include "vldbgmacros.h"
#include "vlquerydef.h"

#define vsDEBUG		1
#define vserrDEBUG	1

from	GRgencs		import	GRgetmatrix;
from	GRcurve		import	GRendpts;
from	GRcurve		import	GRrevparm;
from	EMSsubbs	import	EMproject_curve_along_surface_normals;
from    VSbeam		import	VSgetSegmentEnds;

extern  IGRdouble       VLatan2();
extern  GRclassid	OPP_GRbcsubbc_class_id;
extern  double		pcBeamLength;

static  int		is_from_extreme;

/* -------------------- FCT VLpcMarkingMcInfo () ----------------------------- */
long VLpcMarkingMcInfo( VLmacInfo *macInfo, VLsInfoForMc *stInfo,
                            struct GRmd_env *curEnv, char *feet_name )
{
    BSrc			rc;
    IGRint			i, j;
    IGRlong 			sts, msg, nb_res=0;
    IGRdouble			spt[3], ept[3], mac_org[3], ptMc[3], proj[3], 
				vm[3], vCross[3], X, Y;
    struct GRid			ptMcId, res_id;
    struct GRobj_env		mark_feet, cvOv;
    struct  GRparms     	PJparm;
    IGRpoint            	eval[2];
    struct ret_struct   	st;
    struct IGRbsp_curve 	*isoBs  = NULL;
    struct GRvg_construct       cnst_lis;
    struct GRlc_info 		curv_info,surf_info;
    OM_S_OBJID  		*obj_id = NULL;

    SetProc( VLpcMarkingMcInfo ); Begin

    __DBGpr_obj("Input Macro ", macInfo->mac->obj_id );
    sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                &msg,
                                feet_name,
                                &mark_feet.obj_id,
                                &mark_feet.mod_env.md_env.matrix_type,
                                mark_feet.mod_env.md_env.matrix),
                senderid = NULL_OBJID,
                targetid = macInfo->mac->obj_id.objid,
                targetos = macInfo->mac->obj_id.osnum );
     mark_feet.mod_env.md_id.osnum = mark_feet.obj_id.osnum;
     sts = ex$get_modid( mod_osnum = mark_feet.mod_env.md_id.osnum,
                         mod_id    = &mark_feet.mod_env.md_id.objid );
     __DBGpr_str("Feet Name ", feet_name );
     __DBGpr_obj("Feet Object ", mark_feet.obj_id );

     VLinitCnst(&cnst_lis);

     curv_info.located_obj = mark_feet.obj_id;
     curv_info.module_info = mark_feet.mod_env;

     surf_info.located_obj = stInfo->webLeft.obj_id;
     surf_info.module_info = stInfo->webLeft.mod_env;
     __DBGpr_obj("Stiffenet Web Left ", stInfo->webLeft.obj_id );

     sts=om$send(msg=message     EMSsubbs.EMproject_curve_along_surface_normals(
                                 &curv_info,
                                 &surf_info,
                                 &cnst_lis,
                                 TRUE,
                                 TRUE,
                                 &nb_res,
                                 &obj_id,
                                 &msg),
                    senderid = NULL_OBJID,
                    targetid = surf_info.located_obj.objid,
                    targetos = surf_info.located_obj.osnum);
     as$status(sts=sts);

     __DBGpr_int("Number of intersections between web left and marking feet ", nb_res );
     if( nb_res < 1 ) 
     {
	sts = MSFAIL;
	goto wrapup;
     }

     res_id.objid = obj_id[0];
     res_id.osnum = curEnv->md_id.osnum;

     __DBGpr_obj("Intersection Curve ", res_id );
     __DBGpr_obj("Stiffenet iso curve ( common edge ) ", stInfo->iso0 );
     sts = VLcreateDblInter( &msg, &res_id, curEnv, &stInfo->iso0, &stInfo->webLeft.mod_env, 
			     &mac_org[0], curEnv );
     __DBGpr_vec("Macro Origin ", &mac_org[0] );

     sts = om$send ( msg      = message GRcurve.GRendpts (
                                                &msg,
                                                &curEnv->md_env.matrix_type,
                                                curEnv->md_env.matrix,
                                                spt,
                                                ept ),
                        senderid = NULL_OBJID,
                        targetid = obj_id[0],
                        targetos = curEnv->md_id.osnum );

    for( i=0; i<3; i++ )    ptMc[i] = mac_org[i];
    if( ( BSdistptpt( &rc, mac_org, spt ) ) < ( BSdistptpt( &rc, mac_org, ept ) ) )
    {
	VLvector( &msg, mac_org, ept, 1.0, 1.0, TRUE, vm );
    }
    else
    {
        VLvector( &msg, mac_org, spt, 1.0, 1.0, TRUE, vm );
    }

    VLplPt( &msg, ptMc, &ptMcId, curEnv );

    sts = VLlengthAlongCv( &msg, &stInfo->nf, curEnv,
                                        &stInfo->origin, curEnv,
                                        &ptMcId, curEnv, &macInfo->xpos );
    as$status( sts = sts );
    as$status( sts = msg );
    __DBGpr_dbl("X position ", macInfo->xpos );

    // compute Y elevation
    sts = om$send ( msg      = message GRgraphics.GRptproject (
                                        &msg,
                                        &curEnv->md_env.matrix_type,
                                        curEnv->md_env.matrix,
                                        ptMc, proj, &PJparm ),
                        senderid = NULL_OBJID,
                        targetid = stInfo->iso0.objid,
                        targetos = stInfo->iso0.osnum );
    as$status( sts = sts );
    as$status( sts = msg );

    __DBGpr_vec("Point on iso0, near origin ", proj );
    macInfo->ypos = BSdistptpt( &rc, ptMc, proj );
    __DBGpr_dbl("Y position ", macInfo->ypos );

    // get tg of macro origin on iso0
    cvOv.obj_id     =  stInfo->iso0;
    cvOv.mod_env    = *curEnv;
    VLgetGeometry( &cvOv, (IGRboolean) FALSE, NULL_OBJID,
                          (IGRchar **) &isoBs, &msg );
    BScveval( isoBs, PJparm.u, 1, eval, &rc );

    // compute side and angle
    BSnorvec( &rc, eval[1] );

    X = BSdotp( &rc, eval[1], vm );
    BScrossp( &rc, eval[1], vm, vCross );
    Y = BSlenvec( &rc, vCross );
    macInfo->side =(short)( X < 0 ? -1 : 1 );

    macInfo->alpha = VLatan2( Y, X );
    sts = MSSUCC;

wrapup :
    if( isoBs )     free( isoBs );
    if( nb_res > 0 && obj_id )
    {
       for (i=0;i<nb_res;i++)
       {
            om$send(    msg      = message GRgraphics.GRdelete
                                      ( &msg, curEnv ),
                      senderid = NULL_OBJID,
                      targetid = obj_id[i],
                      targetos = curEnv->md_id.osnum );
       }
       free( obj_id );
    }

    End
    return  sts;
}

/* -------------------- FCT VLpcMcInfo () -----------------------------	*/
long VLpcMcInfo( VLmacInfo        *macInfo, 
                 VLsInfoForMc     *stInfo,
		 struct GRmd_env  *curEnv )
{
long			sts, msg;
int			suc;
int			i, j;
struct	ret_struct	st;
short			four = 4;
char			footName[DI_PATH_MAX];
struct	GRobj_env	contId;
IGRboolean		word	= TRUE;
double			invMat[16];
double			mat[16];
short			matType;
double			vm[3], vCross[3], X, Y;
BSrc			rc;
double			proj[3];
struct	GRparms		PJparm;
double			ptMc[3];
struct	GRid		ptMcId, gensolid;
struct	IGRbsp_curve	*isoBs	= NULL;
IGRpoint		eval[2];
struct	GRobj_env	cvOv;
short                   topProp = VL_Q_TOP_SOURCE;
int                     nbStep;
struct GRobj_env        *stepList = NULL, beam;
extern  int             VLgetStepInfo();

	SetProc( VLpcMcInfo ); Begin

        gensolid.objid        = NULL_OBJID;
        beam.obj_id.objid     = NULL_OBJID;
    
        // try to get parent beam from webLeft 
        __DBGpr_obj("webLeft ",stInfo->webLeft.obj_id); 

        ASget_as_owner(&stInfo->webLeft.obj_id, &gensolid);
        if(gensolid.objid != NULL_OBJID)
        {
          ASget_as_owner(&gensolid, &beam.obj_id);
          if(beam.obj_id.objid != NULL_OBJID)
          {
            __DBGpr_obj("beam ",beam.obj_id); 
            beam.mod_env = stInfo->webLeft.mod_env;
          }
          else
          {
            __DBGpr_com("Failed to get beam from webLeft");            
          }

        }
        // Query stiffener steps History

        if(beam.obj_id.objid != NULL_OBJID) 
          VLbrowseFctInTree( &beam, topProp, NULL,
                             VL_Q_DOWN_DIRECT,
                             VLgetStepInfo,
                             &nbStep, &stepList, curEnv );
        __DBGpr_int("nbStep ",nbStep);

	__DBGpr_obj("Input Macro ", macInfo->mac->obj_id );
	// get macro origin 
	footName[0] = '\0';
	sts = VLgetOperName("",&macInfo->mac->obj_id,"~~orientation",footName);
        if( !(sts&1) )
          sts = VLpcDoubleCutMacro(&msg, &macInfo->mac->obj_id,
                                   stepList, nbStep, footName);
	if( ! (sts&1))
	   sts = VLgetOperName("", &macInfo->mac->obj_id,
				"~~orientation1", footName);
        if( ! (sts&1))
           sts = VLgetOperName("", &macInfo->mac->obj_id,
                                "~~orientation2", footName);
	if( ! (sts&1))
	{
           IGRchar	attr_name[30];

	   vdobj$Get( objOE = macInfo->mac, macName = attr_name );
           if( !strcmp( attr_name, "stfPcMark" ) )
	   {
	      __DBGpr_com("This is stfPcMark macro" );
	      sts = VLpcMarkingMcInfo( macInfo, stInfo, curEnv, "Geom" );
	      sts = MSFAIL; goto wrapup;
	   }

           for( i=0; i<10; ++i )
           { 
               	sprintf( attr_name, "~~marking%d", i );
		sts = VLgetOperName("", &macInfo->mac->obj_id, attr_name,footName);
		if( sts&1 ) break;

            	sprintf( attr_name, "~~marking0%d", i );
                sts = VLgetOperName("", &macInfo->mac->obj_id, attr_name,footName);
                if( sts&1 ) break;
           }
	   if( i != 10 )
	   {
	        __DBGpr_com("This macro has ~~marking");
		sts = VLpcMarkingMcInfo(macInfo, stInfo, curEnv, footName);
	        sts = MSFAIL; goto wrapup;
	   }
	   if( ! (sts&1)) 
	   {
	    	sts = MSFAIL; goto wrapup; 
	   }
	}

	sts = om$send(	msg	 = message NDmacro.ACgive_structure(
						&suc,
						NULL,
						footName,
						&st,
						&macInfo->mac->mod_env ),
			senderid = NULL_OBJID,
			targetid = macInfo->mac->obj_id.objid,
			targetos = macInfo->mac->obj_id.osnum );
	if( ! (sts&suc&1))	return	MSFAIL;

	// compute len
	for( i=0; i<3; i++ )	ptMc[i] = st.var.ref_st.t[(i*4)+3];

	__DBGpr_vec("Macro Origin ", ptMc );
	sts = om$send ( msg      = message GRgraphics.GRptproject (
					&msg,
                                        &curEnv->md_env.matrix_type,
                                        curEnv->md_env.matrix,
                                        ptMc, proj, &PJparm ),
                        senderid = NULL_OBJID,
                        targetid = stInfo->webLeft.obj_id.objid,
                        targetos = stInfo->webLeft.obj_id.osnum );
        as$status( sts = sts );
        as$status( sts = msg );

	for( i=0; i<3; i++ )    ptMc[i] = proj[i];
	__DBGpr_vec("After projecting onto web left, Macro Origin ", ptMc );

	VLplPt( &msg, ptMc, &ptMcId, curEnv );

	sts = VLlengthAlongCv( &msg, &stInfo->nf, curEnv, 
					&stInfo->origin, curEnv, 
					&ptMcId, curEnv, &macInfo->xpos );
	as$status( sts = sts );
	as$status( sts = msg );
	__DBGpr_dbl("X position ", macInfo->xpos );

	// compute Y elevation
	sts = om$send ( msg	 = message GRgraphics.GRptproject (
					&msg,
					&curEnv->md_env.matrix_type,
					curEnv->md_env.matrix,
					ptMc, proj, &PJparm ),
			senderid = NULL_OBJID,
			targetid = stInfo->iso0.objid,
			targetos = stInfo->iso0.osnum );
	as$status( sts = sts );
	as$status( sts = msg );

	__DBGpr_vec("Point on iso0 near macro origin ", proj );
	macInfo->ypos = BSdistptpt( &rc, ptMc, proj );
	__DBGpr_dbl("Y position ", macInfo->ypos );

	// get tg of macro origin on iso0
	cvOv.obj_id 	=  stInfo->iso0;
	cvOv.mod_env	= *curEnv;
	VLgetGeometry( &cvOv, (IGRboolean) FALSE, NULL_OBJID,
					(IGRchar **) &isoBs, &msg );
	BScveval( isoBs, PJparm.u, 1, eval, &rc );

	// compute side and angle
	
	for(i=0, j=0; i<3; i++, j+=4 )	vm[i] = st.var.ref_st.t[j];

	BSnorvec( &rc, eval[1] );

	X = BSdotp( &rc, eval[1], vm );
	BScrossp( &rc, eval[1], vm, vCross );
	Y = BSlenvec( &rc, vCross );

	macInfo->side =(short)( X < 0 ? -1 : 1 );

	macInfo->alpha = VLatan2( Y, X );
	if( macInfo->side < 0 )	macInfo->alpha -= PI;	

	macInfo->set |= VLPC_MAC_ALPHA;

	// get macro range
	footName[0] = '\0';
	sts = 
	VLgetOperName( "", &macInfo->mac->obj_id, "~~operator", footName );
	if( ! (sts&1))	
		sts = VLgetOperName( "", &macInfo->mac->obj_id, 
						"~~operator0", footName );
	if( ! (sts&1))	return	MSFAIL;

	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&msg,
					footName,
					&contId.obj_id,
					&contId.mod_env.md_env.matrix_type,
					contId.mod_env.md_env.matrix),
			senderid = NULL_OBJID,
			targetid = macInfo->mac->obj_id.objid,
			targetos = macInfo->mac->obj_id.osnum );
	as$status( sts = sts );
	if( ! (sts&msg&1))	return	MSFAIL;

	if( contId.mod_env.md_env.matrix_type != MAIDMX ){
		// convert orient CS into contId enviroment
		MAinvmx(&msg, &four, contId.mod_env.md_env.matrix, invMat );
		MAmulmx(&msg, &four, &four, &four, invMat, 
							st.var.ref_st.t, mat );

	} else for( i=0; i<16; i++ )	mat[i] = st.var.ref_st.t[i];

	MAinvmx(&msg, &four, mat, invMat);
	MAtypemx(&msg, invMat, &matType);

	// get range in local position
	sts = om$send(	msg	 = message GRgraphics.GRgetrang(
						&msg,
						&matType,
						invMat,
						&word,
						macInfo->range ),
				senderid = NULL_OBJID,
				targetid = contId.obj_id.objid,
				targetos = contId.obj_id.osnum );
	as$status( sts = sts );
	if( ! (sts&msg&1))	return	MSFAIL;

	// set all
	macInfo->set = ~0;


	// print result
/*
	printf(" MacId : %d/%d\n", macInfo->mac->obj_id.objid,
						macInfo->mac->obj_id.osnum );
	printf(" xpos  : %f , height : %f\n", macInfo->xpos, macInfo->ypos );
	printf(" angle : %f , side   : %d\n", macInfo->alpha, macInfo->side );

	printf(" Rg pt1 : %f, %f, %f\n", macInfo->range[0],
						 macInfo->range[1],
 						 macInfo->range[2] );
	printf(" Rg pt2 : %f, %f, %f\n", macInfo->range[3],
						 macInfo->range[4],
						 macInfo->range[5] );
*/

	sts = MSSUCC;

wrapup :

	if( isoBs )	free( isoBs );
        if( stepList )  free( stepList );
	End
	return	sts;
}

VLpcSetIsFromExtremeties( IGRint  inp_opt )
{
   is_from_extreme = inp_opt;
}

VLpcGetIsFromExtremeties( IGRint  *out_opt )
{
   *out_opt = is_from_extreme ;
}

/* ------------------- FCT VLpcInfoStiff () ---------------------------	*/
long VLpcInfoStiff( struct GRobj_env *stiff, struct GRmd_env *curEnv, 
					double param, double *startPt, 
						VLsInfoForMc *stiffInfo )
{
long			sts, msg;
BSrc			rc;
int			suc;
struct	ret_struct	st;
double			H;
IGRpoint                pt1, pt2, endpt[2], extreme_pt, proj; 
struct	GRparms		PJparm;

	sts = VLgetCommonEdge ( stiff, VS_K_nmWebL, VS_K_nmFlgInfE, 
					&stiffInfo->webLeft, NULL,
					curEnv, &stiffInfo->iso0, &msg );
	if( ! (sts&msg&1))	return	MSFAIL;

/*
 *	If there is no common edge between VS_K_nmWebL and VS_K_nmFlgInfE
 *	(i.e. if it is not a "T" beam), I supposed it as a "I" beam.
 *	Compute the common edge between VS_K_nmWebL and VS_K_nmFlgInfILS,
 *	if the above function fails.
 */

        if( stiffInfo->iso0.objid == NULL_OBJID )
        {
           IGRchar name[50];

           sprintf ( name, "%s:%s:%s", VS_K_bmGrCmpName, VS_K_bmBody,
                                          VS_K_nmFlgInfILS );

	   sts = om$send( msg = message NDmacro.ACtest_foot( 
						&msg, name ),
			      senderid = NULL_OBJID,
			      targetid = stiff->obj_id.objid,
			      targetos =  stiff->obj_id.osnum );
	   if(!( sts & msg & 1) ) strcpy( name, VS_K_nmFlgInfILF );
	   else                   strcpy( name, VS_K_nmFlgInfILS );

           sts = VLgetCommonEdge ( stiff, VS_K_nmWebL, name,
                                        &stiffInfo->webLeft, NULL,
                                        curEnv, &stiffInfo->iso0, &msg );
           if( ! (sts&msg&1))      return  MSFAIL;
        }

	// orient iso0
	sts = om$send(	msg	 = message GRcurve.GRendpts(
					&msg,
					&curEnv->md_env.matrix_type,
					curEnv->md_env.matrix,
					pt1, pt2 ),
			senderid = NULL_OBJID,
			targetid = stiffInfo->iso0.objid,
			targetos = stiffInfo->iso0.osnum );
	as$status( sts = sts );
	as$status( sts = msg );

	if( BSdistptpt( &rc, startPt, pt1 ) > BSdistptpt( &rc, startPt, pt2 )){

		sts = om$send(	msg	 = message GRcurve.GRrevparm
						( &msg, curEnv ),
				senderid = NULL_OBJID,
				targetid = stiffInfo->iso0.objid,
				targetos = stiffInfo->iso0.osnum );
		as$status( sts = sts );
		as$status( sts = msg );
	}

//	if( param > 0.01 ){

	if( FALSE ){
		// get stiffener height
		sts = om$send(	msg	 = message NDmacro.ACgive_structure(
						&suc,
						NULL,
						VS_K_bmHeightAttr,
						&st,
						&stiff->mod_env ),
			senderid = NULL_OBJID,
			targetid = stiff->obj_id.objid,
			targetos = stiff->obj_id.osnum );
		as$status( sts = sts );
		as$status( sts = suc );
		if( ! (sts&suc&1))	return	MSFAIL;
		H = st.var.root_pm_st.value * param;

		sts = VLtopStfTpl( &stiffInfo->webLeft, 
					&stiffInfo->iso0, H, 1.0, curEnv, 
					&stiffInfo->nf, &msg );
		as$status( sts = sts );
		as$status( sts = msg );

		// orient nf 
		sts = om$send(	msg	 = message GRcurve.GRendpts(
						&msg,
						&curEnv->md_env.matrix_type,
						curEnv->md_env.matrix,
						pt1, pt2 ),
				senderid = NULL_OBJID,
				targetid = stiffInfo->nf.objid,
				targetos = stiffInfo->nf.osnum );
		as$status( sts = sts );
		as$status( sts = msg );

		if( BSdistptpt( &rc, startPt, pt1 ) > 
				BSdistptpt( &rc, startPt, pt2 )){

			sts = om$send(	msg	 = message GRcurve.GRrevparm
							( &msg, curEnv ),
					senderid = NULL_OBJID,
					targetid = stiffInfo->nf.objid,
					targetos = stiffInfo->nf.osnum );
			as$status( sts = sts );
			as$status( sts = msg );
		}

	} else stiffInfo->nf = stiffInfo->iso0;

	if( is_from_extreme )
	{
	    __DBGpr_com( "All the Dimensions will be calculated from extremeties" );
            sts = om$send(  msg = message VSbeam.VSgetSegmentEnds(
                                        &msg, &stiff->mod_env, endpt ),
                        senderid = NULL_OBJID,
                        targetid = stiff->obj_id.objid,
                        targetos = stiff->obj_id.osnum  );
	    if( !( sts&1&msg ) )	dblcpy( extreme_pt, startPt, 3 );
	    else
	    {	
               __DBGpr_vec("VSbeam.VSgetSegmentEnds, Start Point ", endpt[0] );
               __DBGpr_vec("VSbeam.VSgetSegmentEnds, End Point ", endpt[1] );

	       if(   BSdistptpt( &rc, endpt[0], startPt ) 
		   < BSdistptpt( &rc, endpt[1], startPt ) )
	       {
		   dblcpy( extreme_pt, endpt[0], 3 );
	       }
	       else
               {
                   dblcpy( extreme_pt, endpt[1], 3 );
               }
	    }
	}
	else
	{
  	   __DBGpr_com( "All the dimensions will be from origin parent" );
	   dblcpy( extreme_pt, startPt, 3 );
	}
        __DBGpr_vec( "Extreme Point", extreme_pt );

	// create origin id
	sts = om$send ( msg	 = message GRgraphics.GRptproject (
						&msg,
						&curEnv->md_env.matrix_type,
						curEnv->md_env.matrix,
						extreme_pt, proj, &PJparm ),
			senderid = NULL_OBJID,
			targetid = stiffInfo->nf.objid,
			targetos = stiffInfo->nf.osnum );
	as$status( sts = sts );
	as$status( sts = msg );

	VLplPt( &msg, proj, &stiffInfo->origin, curEnv );

return	MSSUCC;
}

/* -------------------- FCT VLpcGenerateNeutralFiber () ---------------	*/

long VLpcGenerateNeutralFiber( double param, struct GRobj_env *stiff, 
				struct GRmd_env *nfEnv, struct GRid *nfId,
				double *startPt )
{
long			sts, msg;
struct	GRobj_env	WebFace;
double			pt1[3], pt2[3];
BSrc			rc;
int			suc;
struct	ret_struct	st;
double			H;
struct	GRid		iso;


	sts = VLgetCommonEdge ( stiff, VS_K_nmWebL, VS_K_nmFlgInfE, 
						&WebFace, NULL,
						nfEnv, nfId, &msg );
	if( ! (sts&msg&1))	return	MSFAIL;

	printf(" WebFace : %d/%d\n", 
			WebFace.obj_id.objid, WebFace.obj_id.osnum );

	printf(" nfId : %d/%d\n", nfId->objid, nfId->osnum );

	if( param > 0.01 ){

		printf(" generate on iso curve\n");

		// get stiffener height
		sts = om$send(	msg	 = message NDmacro.ACgive_structure(
						&suc,
						NULL,
						VS_K_bmHeightAttr,
						&st,
						&stiff->mod_env ),
			senderid = NULL_OBJID,
			targetid = stiff->obj_id.objid,
			targetos = stiff->obj_id.osnum );
		as$status( sts = sts );
		as$status( sts = suc );
		if( ! (sts&suc&1))	return	MSFAIL;
		H = st.var.root_pm_st.value * param;

		printf(" H : %f\n", H );

		sts = VLtopStfTpl( &WebFace, nfId, H, 1.0, nfEnv, &iso, &msg );
		as$status( sts = sts );
		as$status( sts = msg );

		// delete last nfId
		if( nfId->objid != NULL_OBJID )
			om$send(msg	 = message GRgraphics.GRdelete
						( &msg, nfEnv ),
				senderid = NULL_OBJID,
				targetid = nfId->objid,
				targetos = nfId->osnum );

		*nfId = iso;

	}

	// get fisrt point
	sts = om$send(	msg	 = message GRcurve.GRendpts(
					&msg,
					&nfEnv->md_env.matrix_type,
					nfEnv->md_env.matrix,
					pt1, pt2 ),
			senderid = NULL_OBJID,
			targetid = nfId->objid,
			targetos = nfId->osnum );
	as$status( sts = sts );
	as$status( sts = msg );

	if( BSdistptpt( &rc, startPt, pt1 ) > BSdistptpt( &rc, startPt, pt2 )){

		printf(" reverse neutral fiber\n");
		sts = om$send(	msg	 = message GRcurve.GRrevparm
						( &msg, nfEnv ),
				senderid = NULL_OBJID,
				targetid = nfId->objid,
				targetos = nfId->osnum );
		as$status( sts = sts );
		as$status( sts = msg );
	}

return	MSSUCC;
}

end implementation VLpcAbst;


