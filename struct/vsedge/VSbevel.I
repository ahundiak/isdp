/* $Id: VSbevel.I,v 1.11 2001/06/09 19:25:10 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsedge/VSbevel.I
 *
 * Description: functions for computing bevel macro: Bevel, EJ_Bevel, VA_Bevel
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbevel.I,v $
 *      Revision 1.11  2001/06/09 19:25:10  ramarao
 *      Fixed TR# 5297.
 *
 *      Revision 1.10  2001/06/07 00:24:41  ramarao
 *      Fixed TR# 5294.
 *
 *      Revision 1.9  2001/06/01 19:52:13  ramarao
 *      Fixed TR# 5284.
 *
 *      Revision 1.8  2001/05/14 15:28:16  ramarao
 *      Fixed TR# 5009.
 *
 *      Revision 1.7  2001/05/09 18:05:14  ramarao
 *      Fixed TR# 5182.
 *
 *      Revision 1.6  2001/04/17 17:09:48  ramarao
 *      Fixed CR# 5016.
 *
 *      Revision 1.5  2001/02/20 01:18:47  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.4  2001/02/05 17:04:59  jayadev
 *      OLD postfix removed from VSbev_ReadSetupFile()
 *
 *      Revision 1.3  2001/01/17 22:29:04  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/17 00:06:49  ramarao
 *      *** empty log message ***
 *
# Revision 1.14  2000/11/27  20:18:56  pinnacle
# ah
#
# Revision 1.13  2000/10/25  19:22:26  pinnacle
# ah
#
# Revision 1.12  2000/10/12  19:01:50  pinnacle
# ah
#
# Revision 1.11  2000/06/27  15:28:02  pinnacle
# ah added objid to messages
#
# Revision 1.10  2000/06/20  21:34:58  pinnacle
# ylong
#
# Revision 1.9  2000/05/23  18:46:16  pinnacle
# Modified VSsetGlobalFontSize
#
# Revision 1.7  2000/05/03  17:45:14  pinnacle
# Replaced: struct/vsedge/VSbevel.I for:  by rchennup for Service Pack
#
# Revision 1.6  2000/04/28  18:32:28  pinnacle
# Replaced: struct/vsedge/VSbevel.I for:  by rchennup for Service Pack
#
# Revision 1.5  2000/04/27  23:04:18  pinnacle
# Replaced: struct/vsedge/VSbevel.I for:  by rchennup for Service Pack
#
# Revision 1.4  2000/04/27  14:46:08  pinnacle
# VSsetGlobalFontSize
#
# Revision 1.3  2000/04/25  18:16:44  pinnacle
# Replaced: struct/vsedge/VSbevel.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/04/24  21:52:24  pinnacle
# ylong
#
# Revision 1.1  2000/04/24  18:38:28  pinnacle
# Created: struct/vsedge/VSbevel.I by impd252 for Service Pack
#
# Revision 1.9  2000/04/05  12:58:42  pinnacle
# Replaced: vsedge/VSbevel.I for:  by impd252 for struct
#
# Revision 1.6  2000/03/23  23:28:36  pinnacle
# ylong
#
# Revision 1.5  2000/03/17  21:50:00  pinnacle
# ylong
#
# Revision 1.3  2000/02/29  16:37:26  pinnacle
# ylong
#
# Revision 1.2  2000/02/18  15:41:20  pinnacle
# by ylong
#
# Revision 1.1  2000/02/11  00:16:42  pinnacle
# ylong
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/04/00  ylong   Creation
 * 02/18/00  ylong   added functions for EJ_ & VA_Bevel's
 * 02/29/00  ylong   added function VScomputeFab_Stock
 * 03/23/00  ylong   added some features and fixes
 * 04/04/00  ylong   minor fixes
 * 04/24/00  ylong   Update label point in VScomputeXXX
 * 05/23/00  ylong   Fix font size problem
 * 06/27/00  ah      Added objid to compute failure messages
 * 10/12/00  ah      Problem with getting distance from edge to surface
 * 11/27/00  ah      Link the new get/set font size routines
 * -------------------------------------------------------------------*/
class implementation Root;

/*
#define  DEBUG	1
#define  vdsDEBUG	1
*/
#include "EMSmsgdef.h"
#include "VDmaster.h"
#include "VSbevel.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDsa.h"
#include "VDgeom.h"
#include "VDefp.h"
#include "VDmem.h"
#include "VDfrm.h"
#include "vsgeommacros.h"
#include "VSefp.h"
#include "grwireframe.h"
#include "cotxmacros.h"
#include "gotextdef.h"
#include "grdpbmacros.h"
#include "acmacros.h"
#include "vdAPImacros.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "vsdbgmacros.h"

#include "bscveval.h"
#include "bscvcvint.h"
#include "bsactivsplt.h"
#include "bsmdstptcv.h"
#include "bsmdistptsf.h"
#include "bschgdeppar.h"
#include "bscvmidpt.h"
#include "bspl_nor_tc.h"
#include "bsproj1.h"

/************************************************************
  External functions.
 ************************************************************/

extern	VDclassid	OPP_nci_macro_class_id;
extern	GRclassid	OPP_GRbcsubbc_class_id;
extern	GRclassid	OPP_nci_macro_class_id, OPP_ACrg_collect_class_id;
extern	FILE*		VSbev_OpenBevelSetupFile();

from	GRvg		import	GRdetplane ;
from	GRvg		import	GRgetname ;
from    GRvg            import  GRcenter ;
from	GRgraphics	import	GRxform ;
from	GRgraphics	import	GRchgprops ;
from	GRgraphics	import	GRputname ;
from	GRbcsubbc	import	GRconstruct ;
from	GR3dpoint	import	GRaltconstruct ;
from	ACrg_collect	import	ACadd_list_attribute ;
from	ACrg_collect	import	ACset_list_attribute ;
from	ACrg_collect	import	AClist_attribute ;
from	ACcpx		import	ACfind_exp_temp_obj;
from	ci_macro	import	init ;
from	ci_macro	import	find_macro ;
from	NDnode		import	NDchange_connect ;
from	NDnode		import	NDchg_state ;
from	ACpretend	import	ACgive_downscan, ACfind_parent ;
from	GRconnector	import	GRrigidconn, GRdisconn ;
from	ACcpx_defn	import	ACgive_name ;
from    GRtext          import  GRgettxattr;

%safe
static	IGRchar	VSbevel_type = '2' ;
%endsafe

%safe
static	IGRint	VSbvl_font_size = 0 ;
%endsafe


IGRchar	VSbvl_get_bevel_type()
{
	return VSbevel_type ;
}

void	VSbvl_set_bevel_type( IGRchar type )
{
	VSbevel_type = type ;
}

/* -----------------------------------------------
 * Until the ppl command objects are rewritten
 * let these guys interface with the new get/set routines
 */
IGRint	VSbvl_get_font_size()
{
  return VSbevelGetFontSize();
}

void	VSbvl_set_font_size( IGRint fontSize )
{
  VSbevelSetFontSize(fontSize,NULL);
  VSbvl_font_size = fontSize;
}


/*****************************************************************/
IGRboolean  ObjsIdentical( obj1, obj2 )
TGRid	obj1 ;
TGRid	obj2 ;
{
	IGRboolean	retFlag ;
	
	if( obj1.objid == obj2.objid && obj1.osnum == obj2.osnum ) {
		retFlag = TRUE ;
	}
	else {
		retFlag = FALSE ;
	}

	return retFlag ;
}

/*****************************************************************/
IGRboolean  Get2crvsOverlap (	TGRobj_env	*crvOE1,
				TGRobj_env	*crvOE2,
				TGRbsp_curve 	**crv    )
{ 
	IGRboolean	retFlag ;
	IGRint		i, k, num_pts,  numDistCvs1=0, numDistCvs2=0, numOvCvs=0,
			ovLapCode ;
	IGRlong		msg ;
	TGRbsp_curve	*crv1=NULL, *crv2=NULL, **DCvs1=NULL,
                        **DCvs2=NULL, **OCvs=NULL;
	BSrc		rc ;
	
	// Init
	retFlag	= FALSE ;
	crv1	= NULL ;
	crv2	= NULL ;

	if( crvOE1 == NULL || crvOE1->obj_id.objid == NULL_OBJID ) {
		printf("Input is empty for crvOE1\n");
		goto wrapup;
	}
	if( crvOE2 == NULL || crvOE2->obj_id.objid == NULL_OBJID ) {
		printf("Input is empty for crvOE2\n");
		goto wrapup;
	}
	
	// Get crv1 geometry
	vs$get_geometry( msg	 = &msg,
			grobjId  = &crvOE1->obj_id, 
			grobjEnv = &crvOE1->mod_env , 
			geometry = &crv1 ) ; 
	if ( !(msg & 1) || crv1 == NULL) { 
		printf("vs$get_geometry failed for crv1\n");
		goto wrapup;
	}

	// Get crv2 geometry
	vs$get_geometry( msg	 = &msg,
			grobjId  = &crvOE2->obj_id,
			grobjEnv = &crvOE2->mod_env ,
			geometry = &crv2 ) ;
	if ( !(msg & 1) || crv2 == NULL) {
		printf("vs$get_geometry failed for crv2\n");
		goto wrapup;
	}

        BSchk2cvsov( crv1, crv2, 1.0, 1, &ovLapCode,
                     &numDistCvs1, &DCvs1, &numDistCvs2, &DCvs2,
                     &numOvCvs, &OCvs, &rc );
        if( rc == BSSUCC && numOvCvs > 0 )  
        {
	   retFlag = TRUE ;

	   if( crv )
	   {
              VDgeomAllocCrv( OCvs[0]->order, OCvs[0]->num_poles, 
			      OCvs[0]->rational,
                              OCvs[0]->num_boundaries, 0, crv );
              BScv_copy( &rc, OCvs[0], *crv );
              if( rc != BSSUCC ) _FREE( *crv );
	   }
        }

wrapup:
	_FREE( crv1 ) ;
	_FREE( crv2 ) ;
        if( numDistCvs1 )
        {
            for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
            _FREE( DCvs1 );
            numDistCvs1 = 0;
        }
        if( numDistCvs2 )
        {
            for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
            _FREE( DCvs2 );
            numDistCvs2 = 0;
        }
        if( numOvCvs )
        {
            for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
            _FREE( OCvs );
            numOvCvs = 0;
        }

	return	retFlag ;
}

/*****************************************************************/
IGRstat GetNeatPlate( plateOE, neatPlateOE)
TGRobj_env	*plateOE;
TGRobj_env	*neatPlateOE;
{
	IGRstat 	retFlag, sts ;
	IGRchar		activeFileName[128] ;
	VDosnum		activeOS ;
	TGRobj_env	srfOE ;

SetProc(GetNeatPlate); Begin

	retFlag		= 0 ;
	activeOS	= 0 ;
	activeFileName[0] = '\0' ;

	if( plateOE == NULL || plateOE->obj_id.objid == NULL_OBJID ) {
		goto wrapup ;
	}

	sts = ex$filename( name = activeFileName, len = 128 ) ;
	sts = di$give_osnum ( pathname = activeFileName, p_osnum = &activeOS ) ;
	if( activeOS == 0 ) activeOS = 2 ;

	vsefp$GetAttachedNeatPlateMacro(macName = VDEFP_NEAT_PLATE_MACRO_NAME,
					macOS	= activeOS ,
					plateOE = plateOE ,
					macOE	= neatPlateOE ) ;

	if( neatPlateOE->obj_id.objid == NULL_OBJID ) {
		vdefp$PlaceMacro(macName = VDEFP_NEAT_PLATE_MACRO_NAME,
				 tplOEs  = plateOE,
				 macOE   = neatPlateOE);
	}

	__DBGpr_obj("plate", plateOE->obj_id);
	__DBGpr_obj("neatPlate", neatPlateOE->obj_id);

	if (neatPlateOE->obj_id.objid == NULL_OBJID) {
		printf("Problem getting neat edge macro\n");
		goto wrapup;
	}

	retFlag = 1 ;
wrapup:
End
	return retFlag ;
}


/*****************************************************************/
typedef struct Edge {
	TGRobj_env	edgeOE;
	struct Edge	*next;
} EdgeNode;

IGRstat GetNeatEdges (
TGRobj_env	*neatPltOE ,	// in , neat plate
TGRobj_env	**edgOEs ,	// out, neat edges
IGRint		*edgCnt )	// out, the nember of edges
{
	IGRstat		retFlag = 0 ;
	IGRlong		msg ;
	IGRint		i, edgeFlag ;
	IGRchar		footName[128] ;
	TGRobj_env	footOE ;
	EdgeNode	*edgeList = NULL, *ep = NULL, *newp = NULL ;

SetProc(GetNeatEdges); Begin

	// Extract edges from neat plate
	*edgCnt = 0 ;
	edgeFlag = 1 ;
	while( edgeFlag ) {
		footName[0] = '\0' ;
		footOE.obj_id.objid = NULL_OBJID ;
		sprintf(footName,"edge%02d", *edgCnt) ;
		vdobj$GetFoot(	objOE    = neatPltOE,
				footName = footName,
				footOE   = &footOE );
		if ( footOE.obj_id.objid == NULL_OBJID) {
			edgeFlag = 0;
		}
		else {
			newp = _CALLOC( 1, EdgeNode ) ;
			if( newp == NULL ) {
				printf("_CALLOC failed\n");
				goto wrapup ;
			}

			newp->edgeOE = footOE ;
			newp->next   = NULL ;
			if( (*edgCnt) == 0 ) {
				edgeList = ep = newp ;
			}
			else {
				ep->next = newp ;
				ep  = newp ;
			}
			newp = NULL ;
			(*edgCnt)++ ;
		}
		
	}
	
	if( (*edgCnt) < 1 ) {
		printf("Failed to get neat edges\n");
		goto wrapup ;
	}

	*edgOEs = _CALLOC( *edgCnt, TGRobj_env ) ;
	if( edgOEs == NULL ) {
		printf("_CALLOC failed\n");
		goto wrapup ;
	}

	ep = edgeList ;
	for( i = 0; i < *edgCnt; i++ ) {
		(*edgOEs)[i] = ep->edgeOE ;
		ep = ep->next ;
	}

	retFlag = 1 ;
wrapup:
	if( edgeList != NULL ) {
		ep = newp = edgeList ;
		while( ep != NULL ) {
			newp = ep ;
			ep = ep->next ;	
			_FREE( newp ) ;
		}
	}
End
	return retFlag ;

}


/********************************************************************/
/*      If user does not input edge objs, this func is responsible  */
/*      to get overlaped edges from neat plates                     */

IGRstat GetBevelEdges(
TGRobj_env	*edgOEs1 ,	// in,  edges from plate 1
IGRint		 edgCnt1 ,	// in,  # of edges from plate 1
TGRobj_env	*edgOEs2 ,	// in,  edges from plate 2
IGRint		 edgCnt2 ,	// in,  # of edges from plate 2 
TGRobj_env	*edgOE1 ,	// out, edge 1, overlaped with edge 2
TGRobj_env	*edgOE2 )	// out, edge 2, overlaped with edge 1

{
	IGRstat		retFlag ;
	IGRlong		msg ;
	IGRint		i, j, sts;
	IGRboolean	overlap = FALSE ;

SetProc(GetBevelEdges) ; Begin
	retFlag = 0 ;

	// Find overlaped segments of two edges
	for( i = 0; i < edgCnt1; i = i+1 ) {
		__DBGpr_obj("edgOEs1", edgOEs1[i].obj_id);
		for( j = 0; j < edgCnt2; j = j+1 ) {
			overlap = Get2crvsOverlap (	&edgOEs1[i], 
							&edgOEs2[j], 
							NULL         ) ;
			if( overlap ) {
				(*edgOE1) = edgOEs1[i] ;
				(*edgOE2) = edgOEs2[j] ;
				retFlag = 1 ;
				__DBGpr_com("--- Found overlap ---");
				__DBGpr_obj("edge 1", edgOEs1[i].obj_id);
				__DBGpr_obj("edge 2", edgOEs2[j].obj_id);
				goto wrapup ;
			} 
		}
	}

wrapup:
End
	return retFlag ;

}

/*****************************************************************/
IGRstat ConstructBevel ( 
TGRobj_env	*edgOE1,	// in,  edge 1
TGRobj_env	*edgOE2,	// in,  egde 2
TGRobj_env	*bvlOE,		// out, bevel
TGRbsp_curve	**bvlCrv)	// out, bevel curve geom
{
	IGRstat		retFlag, sts ;
	IGRlong		msg ;
	IGRint		i ;
	BSrc		rc  ;
	IGRdouble	par1, par2 ;
	TGRmd_env	mod_env ;
	TGRbsp_curve	*crv ;
	TGRvg_construct	cst ;
	IGRboolean	bool ;

	SetProc(ConstructBevel); Begin

	retFlag = 0 ;
	crv	= NULL ;
	*bvlCrv	= NULL ;

	__DBGpr_obj("edge 1", edgOE1->obj_id);
	__DBGpr_obj("edge 2", edgOE2->obj_id);
	if( edgOE1== NULL || edgOE1->obj_id.objid == NULL_OBJID ) {
		printf("NULL object for edge 1\n");
		goto wrapup ;
	}

	if( edgOE2== NULL || edgOE2->obj_id.objid == NULL_OBJID ) {
		printf("NULL object for edge 2\n");
		goto wrapup ;
	}

	// Check if two edges overlaped 
	if( ! Get2crvsOverlap ( edgOE1, edgOE2, bvlCrv ) ) {
		printf("No overlap found between 2 edges within tolerance\n");
		goto wrapup ;
	}

	// Construct bevel object
	sts = gr$get_module_env(buffer = &mod_env) ;
	VDsupInitCnst( &cst ) ;
	cst.env_info = &mod_env ;
	cst.geometry = (char*) (*bvlCrv) ;
	bvlOE->mod_env = mod_env ;
	bvlOE->obj_id.osnum = mod_env.md_id.osnum ;
	bvlOE->obj_id.objid = NULL_OBJID ;

	sts = om$construct (	classid =  OPP_GRbcsubbc_class_id ,
				osnum   =  bvlOE->obj_id.osnum ,
				p_objid = &bvlOE->obj_id.objid ) ;
	if (!(sts & 1) || bvlOE->obj_id.objid == NULL_OBJID) {
		printf("Failed to construct bvlOE\n");
		goto wrapup;
	}

	sts = om$send(	msg      = message GRbcsubbc.GRconstruct(&cst),
			senderid = NULL_OBJID ,
			targetid = bvlOE->obj_id.objid ,
			targetos = bvlOE->obj_id.osnum ) ;
	cst.geometry = NULL ;
	if( !sts || bvlOE->obj_id.objid == NULL_OBJID ) {
		printf("GRgraphics.GRconstruct failed\n");
		goto wrapup ;
	}

	retFlag = 1 ;
wrapup:
	_FREE( crv ) ;
End
	return retFlag ;

}



/*****************************************************************/
IGRstat GetCenterOfEdges (	TGRobj_env	*neatPltOE ,	// input
				IGRpoint	 center )	// output
{
	IGRstat		retFlag, sts  ;
	BSrc		rc ;
	IGRlong		msg ;
	IGRint		i, cnt ;
	IGRdouble	area;
	IGRint		edgCnt ;
	TGRobj_env	*edgOEs ;
	TGRbsp_curve	*crv;
	IGRpoint	mpnt ;
	IGRdouble	mpar ;

SetProc(GetCenterOfEdges); Begin

	retFlag = 0 ;
	edgOEs  = NULL ;
	crv     = NULL ;
	cnt	= 0 ;
	center[0] = center[1] = center[2] = 0 ;

	if ( neatPltOE == NULL || neatPltOE->obj_id.objid == NULL_OBJID ) {
		goto wrapup ;
	}

	sts = GetNeatEdges ( neatPltOE, &edgOEs, &edgCnt ) ;
	if ( !sts || edgCnt < 1 ) {
		printf("Failed to get neat edges\n");
		goto wrapup ;
	}

	for( i = 0; i < edgCnt; i++ ) {
		vs$get_geometry( msg      = &msg,
				grobjId  = &edgOEs[i].obj_id,
				grobjEnv = &edgOEs[i].mod_env ,
				geometry = &crv ) ;
		if ( !(msg & 1) || crv == NULL) {
			printf("Problem getting edge geometry\n");
			goto wrapup;
		}

		if( edgCnt == 1 && crv->phy_closed )
		{
        	  sts = om$send(msg     = message GRvg.GRcenter (
				&msg, &edgOEs[i].mod_env.md_env.matrix_type,
				edgOEs[i].mod_env.md_env.matrix, center ),
                     senderid = NULL_OBJID ,
                     targetid = edgOEs[i].obj_id.objid,
                     targetos = edgOEs[i].obj_id.osnum );
		  cnt = 1;
		  break;
		}

		BScvmidpt( crv, &mpar, mpnt, &rc) ;
		if( rc != BSSUCC ) {
			__DBGpr_com("BScvmidpt() failed");
			continue ;
		}
		center[0] += mpnt[0] ;
		center[1] += mpnt[1] ;
		center[2] += mpnt[2] ;
		_FREE( crv ) ; crv = NULL ;
		cnt++ ;
	}

	if (cnt > 0 ) {
		center[0] /= cnt ;
		center[1] /= cnt ;
		center[2] /= cnt ;
	}

	retFlag = 1 ;
wrapup:
	_FREE( edgOEs ) ;
End
	return retFlag ;
		
}

/*****************************************************************/
IGRstat GetNeatCenter( neatPltOE, pntOE, pnt )
TGRobj_env	*neatPltOE ;	// input
TGRobj_env	*pntOE ;	// output
IGRdouble	*pnt ;		// output
{
	IGRstat		retFlag ;
	IGRlong		msg ;
	IGRdouble	pt[3] ;

SetProc(GetNeatCenter); Begin

	retFlag = 0 ;

	vdobj$GetFoot(	objOE    = neatPltOE,
			footName = "center" ,
			footOE   = pntOE );
	if (pntOE->obj_id.objid == NULL_OBJID) {
		printf("Failed to get center foot\n");
		goto wrapup ;
	}
	__DBGpr_obj("pntOE->obj_id", pntOE->obj_id);

	gr$get_endpoints (	msg       = &msg ,
				md_env    = &pntOE->mod_env ,
				object_id = &pntOE->obj_id ,
				point1    = pnt ,
				point2    = pt ) ;

	if ( !(msg & 1) || pnt == NULL) {
		printf("Problem getting center point\n");
		goto wrapup;
	}
	__DBGpr_vec("center pnt", pnt) ;

	retFlag = 1 ;
wrapup:
End
	return retFlag ;
		
}

/*************************************************************************/
IGRboolean PointIsOnPlane( 
TGRobj_env	*pntOE ,	// in,
TGRobj_env	*plateOE )	// in, 
{
	IGRlong		msg ;
	BSrc		rc ;
	IGRboolean	ret ;
	IGRdouble	pnt[3], pt[3] ;
	IGRdouble	u, v, dist ;
	TGRobj_env	srfOE ;
	TGRbsp_surface	*srf ;

SetProc(PointIsOnPlane); Begin

	ret = FALSE ;
	srf = NULL ;

	// If either one is null, do not check
	if( pntOE->obj_id.objid   == NULL_OBJID || 
	    plateOE->obj_id.objid == NULL_OBJID ) 
	{
		return TRUE ;
	}

	// get point geom from input point ID
	gr$get_endpoints (	msg       = &msg ,
				md_env    = &pntOE->mod_env ,
				object_id = &pntOE->obj_id ,
				point1    = pnt ,
				point2    = pt ) ;
	if ( !(msg & 1) ) {
		printf("Problem label point\n");
		goto wrapup;
	}

	// get surface geom from input plate ID
	vdobj$GetFoot(	objOE    = plateOE,
			footName = "plate:base",
			footOE   = &srfOE);
	if (srfOE.obj_id.objid == NULL_OBJID) goto wrapup;	

	vs$get_geometry(msg      = &msg,
			grobjId  = &srfOE.obj_id,
			grobjEnv = &srfOE.mod_env ,
			geometry = &srf ) ;
	if( !( msg&1) ) {
		printf("failed to get srf\n");
		goto wrapup ;
	}

	// Test if point in on the plane
	BSmdistptsf( &rc, srf, pnt, &u, &v, pt, &dist ) ;
	if( BSERROR(rc) ) goto wrapup ;
	if( dist > GAP_TOL ) {
		goto wrapup ;
	}

	ret = TRUE ;
wrapup:
	_FREE( srf ) ;
End
	return ret ;
}


/*****************************************************************/
IGRstat  GetLabelPoint (
TGRobj_env	*plateOE ,	// in , plate
TGRbsp_curve	*bvlCrv ,	// in , curve
IGRdouble	offsetVal ,	// in , offset btwn label and center of curve
TGRobj_env	*lblPntOE )	// out, label point
{
	IGRstat		retFlag, sts ;
	IGRlong		msg ;
	IGRint		i, inside ;
	IGRdouble	bvlMidPnt[3] ;		// mid point of bvlCrv
	IGRdouble	plnNorm[3], plnPnt[3] ;	// plane perpendicular to bvlCrv
	IGRdouble	orient[9] ;		// label orientation
	IGRdouble	lblPnt[3] ;		// label position
	IGRdouble	neatPnt[3], pnt[3] ;
	IGRdouble	tmp, dist, mpar, par[2] ;
	IGRboolean	flag ;
	BSrc		rc ;
	TGRpolyline	geom;
	TGRobj_env	neatPltOE, neatPntOE ;
	TGRobj_env	srfOE ;
	TGRmd_env	mod_env ;
	TGRvg_construct	cst ;
	TGRbsp_surface	*srfGeom ;

SetProc(GetLabelPoint); Begin;

	retFlag = 0 ;
	srfGeom = NULL ;
	lblPntOE->obj_id.objid = NULL_OBJID ;
	neatPltOE.obj_id.objid = NULL_OBJID ;
	neatPntOE.obj_id.objid = NULL_OBJID ;
	
	if(plateOE == NULL || plateOE->obj_id.objid==NULL_OBJID ) goto wrapup;
	if(bvlCrv == NULL) goto wrapup;

	sts = gr$get_module_env(buffer = &mod_env) ;
	if( !sts ) goto wrapup ;

	// Get neat plate center from plate
	sts = GetNeatPlate( plateOE, &neatPltOE) ;
	if( !sts || neatPltOE.obj_id.objid == NULL_OBJID ){
		printf("GetNeatPlate() failed\n");
		goto wrapup ;
	}
	sts = GetCenterOfEdges( &neatPltOE, neatPnt ) ;
	if( !sts ){
		printf("GetNeatCenter() failed");
		goto wrapup ;
	}

	// Get mid point of bevel curve
	BScvmidpt( bvlCrv, &mpar, bvlMidPnt, &rc) ;
	if( rc != BSSUCC ) {
		printf("BScvmidpt() failed\n");
		goto wrapup;
	}

	// Get base surface and geom of the plate
	vdobj$GetFoot (	objOE		= plateOE,
			footName	= "plate:base",
			footOE		= &srfOE);
	if (srfOE.obj_id.objid == NULL_OBJID) {
		printf("vdobj$GetFoot failed\n") ;
		goto wrapup;
	}
	vs$get_geometry (	msg		= &msg ,
				grobjId		= &srfOE.obj_id ,
				grobjEnv	= &srfOE.mod_env ,
				geometry	= &srfGeom);
	if ( !(msg&1) || srfGeom == NULL ) {
		printf("vs$get_geometry failed\n") ;
		goto wrapup;
	}

	// find a point on srfGeom which has minimum distance to bvlMidPnt
	BSmdistptsf( &rc, srfGeom, bvlMidPnt, &par[0], &par[1], pnt, &dist) ;
	if( rc != BSSUCC ) {
		printf("BSmdistptsf() failed\n");
		goto wrapup ;
	}

	// Get srf normal &orient[6] at the point found from above
	vs$get_normal( msg =	&msg ,
			sfId	= &srfOE.obj_id ,
			sfEnv	= &srfOE.mod_env ,
			parm	= par ,
			normal	= &orient[6] ) ;
	if ( !(msg&1) ) {
		printf("vs$get_normal failed\n") ;
		goto wrapup;
	}
			
	// Make a plane perpendicular to bvlCrv at mid point of bvlCrv
	flag = FALSE ; tmp = 1. ;
	BSpl_nor_tc( &rc, bvlCrv, &mpar, &flag, &tmp, plnPnt, plnNorm, NULL);
	if( rc != BSSUCC ) goto wrapup ;

	// Project neatPnt to mid plane to get projected point pnt
	BSproj1( &rc, neatPnt, plnNorm, plnPnt, pnt ) ;
	if( rc != BSSUCC ) goto wrapup ;

	// Make a unit vector, &orient[3], from bvlMidPnt to pnt, 
	BSmkvec (&rc, &orient[3], bvlMidPnt, pnt) ;	// make vector 
	if( rc != BSSUCC ) goto wrapup ;
	BSnorvec(&rc, &orient[3] ) ;			// normalize vector
	if( rc != BSSUCC ) goto wrapup ;

	// Make a unit vector, &orient[0], by cross product of &[3] and &[6]
	BScrossp( &rc, &orient[3], &orient[6], &orient[0] ) ;
	if( rc != BSSUCC ) { goto wrapup ; }

	__DBGpr_vec("orient 1", &orient[0]);
	__DBGpr_vec("orient 2", &orient[3]);
	__DBGpr_vec("orient 3", &orient[6]);

	// Set label point along &orient[2] to bvlCrv with distance fontSize
	for( i = 0; i < 3; i = i+1 ) {
	   lblPnt[i] = bvlMidPnt[i] + orient[i]*offsetVal 
				    + orient[i+3]*VSbvl_font_size ;
	}

	/*
	 * Check if the label point is ON the surface.
	 */
        inside = FALSE;
        VSisPointOnSurface( &msg, &srfOE.mod_env, &srfOE.obj_id, FALSE,
                            lblPnt, &inside );
        if( inside == FALSE )
        {
           for( i = 0; i < 3; i = i+1 ) {
               lblPnt[i] = bvlMidPnt[i] - orient[i]*offsetVal
                                    - orient[i+3]*VSbvl_font_size ;
           }
        }

	/*
	 * If not, Put the label back to its original position.
         */
        inside = FALSE;
        VSisPointOnSurface( &msg, &srfOE.mod_env, &srfOE.obj_id, FALSE,
                            lblPnt, &inside );
        if( inside == FALSE )
        {
           for( i = 0; i < 3; i = i+1 ) {
               lblPnt[i] = bvlMidPnt[i] + orient[i]*offsetVal
                                    + orient[i+3]*VSbvl_font_size ;
           }
        }

	// Construct label point
	VDsupInitCnst( &cst ) ;
	geom.num_points = 1 ;
	geom.points     = lblPnt ;
	cst.geometry    = (char *)&geom ;

	lblPntOE->mod_env = mod_env ;
	lblPntOE->obj_id.osnum = mod_env.md_id.osnum ;

	sts = om$construct (	classname = "GR3dpoint" ,
				osnum     =  lblPntOE->obj_id.osnum ,
				p_objid   = &lblPntOE->obj_id.objid );
	if ( !(sts&1) || lblPntOE->obj_id.objid == NULL ) {
		printf("Can not construct GR3dpoint obj\n");
		goto wrapup ;
	}

	sts = om$send(msg     = message GR3dpoint.GRaltconstruct (&cst),
		     senderid = NULL_OBJID ,
		     targetid = lblPntOE->obj_id.objid,
		     targetos = lblPntOE->obj_id.osnum );
	cst.geometry    = NULL ;
	if ( ! ( sts & 1 ) ) {
		printf("GR3dpoint.GRaltconstruct failed\n");
		lblPntOE->obj_id.objid = NULL_OBJID;
		goto wrapup ;
	}

	__DBGpr_obj("lblPntOE->obj_id", lblPntOE->obj_id);

	retFlag = 1 ;
wrapup:
	_FREE(srfGeom) ;
End
	return retFlag ;
}




/*****************************************************************/
IGRstat  ConstTextLabel (
IGRint		 pos,		// in, position, 0 or 1
IGRchar		*text ,		// in
TGRbsp_curve	*bvlCrv ,	// in
TGRobj_env	*plateOE ,	// in
TGRobj_env	*lblPntOE ,	// in
TGRobj_env	*lblTxtOE )	// out
{
	IGRstat		retFlag, sts ;
	IGRlong		msg ;
	IGRint		i ;
	TGRmd_env	mod_env ;
	IGRint		fontSize ;
	IGRdouble	pnt[3];
	IGRdouble	lblPnt[3];
	IGRdouble	bvlMidPnt[3] ;
	IGRdouble	plnNorm[3], plnPnt[3] ;
	IGRdouble	tmp, dist, mpar, par[2] ;
	IGRboolean	flag ;
	BSrc		rc ;
	IGRint		txtLen, txtBytes, bytesRet ;
	IGRint		properties ;
	IGRdouble	orient[9] ;
	IGRdouble	rotMatrix[16] ;
	TGRplane	plane ;
	TGRpolyline	geom ;
	TGRobj_env	srfOE ;
	TGRbsp_surface	*srfGeom ;

	TGRsymbology	symb ;
struct	GRdpb_text_symb	txtSymb ;

SetProc( ConstTextLabel ); Begin;

	retFlag = 0 ;
	srfGeom = NULL ;

	sts = gr$get_module_env(buffer = &mod_env) ;

	// Get point geom
	gr$get_endpoints (	msg       = &msg ,
				md_env    = &lblPntOE->mod_env ,
				object_id = &lblPntOE->obj_id ,
				point1    = lblPnt ,
				point2    = pnt ) ;
	if ( !(msg & 1) || lblPnt == NULL) {
		printf("Can not get lablPnt\n");
		goto wrapup;
	}

// First, make rotational matrix for text label

	// Get base surface and geom of the plate
	srfOE.obj_id.objid = NULL_OBJID ;
	vdobj$GetFoot (	objOE		= plateOE,
			footName	= "plate:base",
			footOE		= &srfOE);
	if (srfOE.obj_id.objid == NULL_OBJID) {
		printf("vdobj$GetFoot failed\n") ;
		goto wrapup;
	}
	__DBGpr_obj("srfOE", srfOE.obj_id);
	vs$get_geometry (	msg		= &msg ,
				grobjId		= &srfOE.obj_id ,
				grobjEnv	= &srfOE.mod_env ,
				geometry	= &srfGeom);
	if ( !(msg&1) || srfGeom == NULL ) {
		printf("vs$get_geometry failed\n") ;
		goto wrapup;
	}

	// find a point on srfGeom which has minimum distance to lblPnt
	BSmdistptsf( &rc, srfGeom, lblPnt, &par[0], &par[1], pnt, &dist) ;
	if(BSERROR (rc) ) {
		printf("BSmdistptsf() failed\n");
		goto wrapup ;
	}

	// Get srf normal &orient[6] at the point found from above
	vs$get_normal(	msg	= &msg ,
			sfId	= &srfOE.obj_id ,
			sfEnv	= &srfOE.mod_env ,
			parm	= par ,
			normal	= &orient[6] ) ;
	if ( !(msg&1) ) {
		printf("vs$get_normal failed\n") ;
		goto wrapup;
	}

	// Get projected point from lblPnt on bevel curve
	BSmdstptcv( bvlCrv, lblPnt, &mpar, bvlMidPnt, &dist, &rc) ;
	if( BSERROR (rc) ) goto wrapup ;

	// Make a unit vector, &orient[3], from bvlMidPnt to lblPnt, 
	BSmkvec (&rc, &orient[3], bvlMidPnt, lblPnt) ;	// make vector 
	if( BSERROR (rc) ) goto wrapup ;
	BSnorvec(&rc, &orient[3] ) ;			// normalize vector
	if( BSERROR (rc) ) goto wrapup ;

	// Make a unit vector, &orient[0], by cross product of &[3] and &[6]
	BScrossp( &rc, &orient[3], &orient[6], &orient[0] ) ;
	if( BSERROR (rc) ) { goto wrapup ; }

	// If set stock, move lblPnt above stock symbol
	if( pos ) {
		lblPnt[0] += 1.2*VSbvl_font_size*orient[3] ;
		lblPnt[1] += 1.2*VSbvl_font_size*orient[4] ;
		lblPnt[2] += 1.2*VSbvl_font_size*orient[5] ;
	}

	// Make a rotational matrix for label text
	rotMatrix[0]  = orient[0] ;
	rotMatrix[1]  = orient[1] ;
	rotMatrix[2]  = orient[2] ;
	rotMatrix[3]  = 0. ;
	rotMatrix[4]  = orient[3] ;
	rotMatrix[5]  = orient[4] ;
	rotMatrix[6]  = orient[5] ;
	rotMatrix[7]  = 0. ;
	rotMatrix[8]  = orient[6] ;
	rotMatrix[9]  = orient[7] ;
	rotMatrix[10] = orient[8] ;
	rotMatrix[11] = 0. ;
	rotMatrix[12] = lblPnt[0] ;
	rotMatrix[13] = lblPnt[1] ;
	rotMatrix[14] = lblPnt[2] ;
	rotMatrix[15] = 1. ;


	__DBGpr_vec("orient 1", &orient[0]);
	__DBGpr_vec("orient 2", &orient[3]);
	__DBGpr_vec("orient 3", &orient[6]);

// Construct text label

	// Get text symbology
	txtBytes = sizeof(text) ;
	txtLen   = strlen(text) ;
	gr$get_text_symb( msg	= &msg ,
			sizbuf	= &txtBytes ,
			buffer	= &txtSymb ,
			nret	= &bytesRet ) ;
	if( !(msg&1) ) {
		goto wrapup ;
	}

	lblTxtOE->mod_env = mod_env ;
	lblTxtOE->obj_id.osnum = mod_env.md_id.osnum ;
	lblTxtOE->obj_id.objid = NULL_OBJID ;
	sts = om$construct (	classname = "GR3dtext" ,
				osnum     =  lblTxtOE->obj_id.osnum ,
				p_objid   = &lblTxtOE->obj_id.objid );
	if( !(sts&1) || lblTxtOE->obj_id.objid == NULL_OBJID ) {
		printf("om$construct failed to construct lblTxtOE\n");
		goto wrapup ;
	}

	__DBGpr_vec("lblPnt", lblPnt);
	__DBGpr_str("text", text);

	fontSize = VSbvl_font_size ;
	if( !strcmp( text, "S" ) ) fontSize = 0.8*VSbvl_font_size ;

	txtSymb.Active_width  = fontSize ;
	txtSymb.Active_height = fontSize ;
	txtSymb.Active_just   = CENTER_CENTER ;
	txtSymb.Active_flags  = GRFILLED_TEXT ;
	properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	VDahGetActiveSymbology(&symb);

	co$place_text(	msg		= &msg ,
			text_string	= text ,
			text_length	= &txtLen ,
			rot_matrix	= rotMatrix ,
			ActiveDisplay	= &symb.display_attr ,
			ActiveLevel	= symb.level ,
			Properties	= &properties ,
			TextSymb	= &txtSymb ,
			ActiveAngle	= 0. ,
			ModuleInfo      = &mod_env,
			origin		= lblPnt ,
			flags		= 1 ,
			buffer		= &lblTxtOE->obj_id ) ;

	if( !(msg&1) ) {
		printf("co$place_text failed\n");
		goto wrapup ;
	}
	//vdobj$Print(objOE = lblTxtOE );

	retFlag = 1 ;
wrapup:
	_FREE( srfGeom ) ;
End
	return retFlag ;
}

/*****************************************************************/
IGRstat  ConstSymbLabel (
TGRbsp_curve	*bvlCrv ,	// in
TGRobj_env	*plateOE ,	// in
TGRobj_env	*lblPntOE ,	// in
TGRobj_env	*lblSymOE )	// out
{
	IGRstat		retFlag, sts ;
	IGRlong		msg ;
	IGRint		i ;
	TGRmd_env	mod_env ;
	IGRdouble	lblPnt[3], pnt[3];
	IGRdouble	bvlMidPnt[3] ;
	IGRdouble	tmp, dist, mpar, par[2] ;
	BSrc		rc ;
	IGRint		line_type ;
	IGRdouble	orient[9] ;
	IGRpoint	trianPnt[3] ;
	TGRplane	plane ;
	TGRbsp_curve	*trianCrv, *crvs[3] ;
	TGRvg_construct	cst ;
	TGRobj_env	srfOE ;
	TGRbsp_surface	*srfGeom ;

SetProc( ConstSymbLabel ); Begin;

	retFlag		= 0 ;
	trianCrv	= NULL ;
	crvs[0]		= NULL ;
	crvs[1]		= NULL ;
	crvs[2]		= NULL ;
	srfGeom		= NULL ;

	__DBGpr_obj("lblPntOE->obj_id", lblPntOE->obj_id);

	sts = gr$get_module_env(buffer = &mod_env) ;

// First, make rotational matrix for text label

	// Get point geom
	gr$get_endpoints (	msg       = &msg ,
				md_env    = &lblPntOE->mod_env ,
				object_id = &lblPntOE->obj_id ,
				point1    = lblPnt ,
				point2    = pnt ) ;
	if ( !(msg & 1) || lblPnt == NULL) {
		printf("Can not get lablPnt\n");
		goto wrapup;
	}

	// Get base surface and geom of the plate
	vdobj$GetFoot (	objOE		= plateOE,
			footName	= "plate:base",
			footOE		= &srfOE);
	if (srfOE.obj_id.objid == NULL_OBJID) {
		printf("vdobj$GetFoot failed\n") ;
		goto wrapup;
	}
	__DBGpr_obj("srfOE", srfOE.obj_id);
	vs$get_geometry (	msg		= &msg ,
				grobjId		= &srfOE.obj_id ,
				grobjEnv	= &srfOE.mod_env ,
				geometry	= &srfGeom);
	if ( !(msg&1) || srfGeom == NULL ) {
		printf("vs$get_geometry failed\n") ;
		goto wrapup;
	}

	// find a point on srfGeom which has minimum distance to lblPnt 
	BSmdistptsf( &rc, srfGeom, lblPnt, &par[0], &par[1], pnt, &dist) ;
	if(BSERROR (rc) ) {
		printf("BSmdistptsf() failed\n");
		goto wrapup ;
	}

	// Get srf normal, &orient[6], at the point found from above
	vs$get_normal(	msg	= &msg ,
			sfId	= &srfOE.obj_id ,
			sfEnv	= &srfOE.mod_env ,
			parm	= par ,
			normal	= &orient[6] ) ;
	if ( !(msg&1) ) {
		printf("vs$get_normal failed\n") ;
		goto wrapup;
	}

	// Get projected point from lblPnt on bevel curve
	BSmdstptcv( bvlCrv, lblPnt, &mpar, bvlMidPnt, &dist, &rc) ;
	if( BSERROR (rc) ) goto wrapup ;

	// Make a unit vector, &orient[3], from bvlMidPnt to lblPnt, 
	BSmkvec (&rc, &orient[3], bvlMidPnt, lblPnt) ;	// make vector 
	if( BSERROR (rc) ) goto wrapup ;
	BSnorvec(&rc, &orient[3] ) ;			// normalize vector
	if( BSERROR (rc) ) goto wrapup ;

	// Make a unit vector, &orient[0], by cross product of &[3] and &[6]
	BScrossp( &rc, &orient[3], &orient[6], &orient[0] ) ;
	if( BSERROR (rc) ) { goto wrapup ; }

	// Make three vetices of triangle
	tmp = sqrt( 3 ) ;
	for( i = 0; i < 3; i++ ) {
		trianPnt[0][i] = lblPnt[i] - orient[i+3]*VSbvl_font_size ;
		trianPnt[1][i] = lblPnt[i] + orient[i]  *VSbvl_font_size*.5*tmp
					   + orient[i+3]*VSbvl_font_size*.5;
		trianPnt[2][i] = lblPnt[i] - orient[i]  *VSbvl_font_size*.5*tmp
					   + orient[i+3]*VSbvl_font_size*.5;
		BSalloccv( 2, 4, 0, 2, &crvs[i], &rc ) ;
		if( rc != BSSUCC || crvs[i] == NULL ) goto wrapup ;
	}
	__DBGpr_vec("trianPnt[0]", trianPnt[0]);
	__DBGpr_vec("trianPnt[1]", trianPnt[1]);
	__DBGpr_vec("trianPnt[2]", trianPnt[2]);

	// Make triangle edges
	BSptlngen( &rc, trianPnt[0], trianPnt[1], crvs[0], &line_type ) ;
	if( BSERROR (rc) ) goto wrapup ;
	BSptlngen( &rc, trianPnt[1], trianPnt[2], crvs[1], &line_type ) ;
	if( BSERROR (rc) ) goto wrapup ;
	BSptlngen( &rc, trianPnt[2], trianPnt[0], crvs[2], &line_type ) ;
	if( BSERROR (rc) ) goto wrapup ;

	// Create triangle as a composite curve
	BSmergarrcv( 3, crvs, &trianCrv, &rc) ;
	if( BSERROR (rc) ) goto wrapup ;

	// Construct label symbol object
	VDsupInitCnst( &cst ) ;
	cst.env_info = &mod_env ;
	cst.geometry = (char*) (trianCrv) ;
	lblSymOE->mod_env = mod_env ;
	lblSymOE->obj_id.osnum = mod_env.md_id.osnum ;
	lblSymOE->obj_id.objid = NULL_OBJID ;

	sts = om$construct (	classid =  OPP_GRbcsubbc_class_id ,
				osnum   =  lblSymOE->obj_id.osnum ,
				p_objid = &lblSymOE->obj_id.objid ) ;
	if (!(sts & 1) || lblSymOE->obj_id.objid == NULL_OBJID) {
		printf("Failed to construct lblSymOE\n");
		goto wrapup;
	}

	sts = om$send(	msg      = message GRbcsubbc.GRconstruct(&cst),
			senderid = NULL_OBJID ,
			targetid = lblSymOE->obj_id.objid ,
			targetos = lblSymOE->obj_id.osnum ) ;
	cst.geometry = NULL ;
	if( !sts || lblSymOE->obj_id.objid == NULL_OBJID ) {
		printf("GRgraphics.GRconstruct failed\n");
		goto wrapup ;
	}

	//vdobj$Print(objOE = lblTxtOE );

	retFlag = 1 ;
wrapup:
End
	_FREE( srfGeom ) ;
	if( trianCrv) BSfreecv( &rc, trianCrv);
	if( crvs[0] ) BSfreecv( &rc, crvs[0] ); 
	if( crvs[1] ) BSfreecv( &rc, crvs[1] ); 
	if( crvs[2] ) BSfreecv( &rc, crvs[2] ); 

	return retFlag ;
}


/*************************************************************************/
IGRstat	CreateCollector ( 
		struct	ACrg_coll	*collAttrs , 	// in
			IGRint		attrCnt , 	// in
			IGRchar		*inName , 	// in
			TGRobj_env	*outOE )	// out
{
	IGRstat		retFlag = 0 ;
	IGRint		sts;
	IGRlong		msg;

SetProc(CreateCollector) ; Begin

	sts = gr$get_module_env(buffer = &outOE->mod_env) ;
	if( !sts ) {
		printf("gr$get_module_env failed\n");
		goto wrapup ;
	}
	outOE->obj_id.osnum = outOE->mod_env.md_id.osnum ;

	sts = om$construct (	classname = "ACrg_collect" ,
				osnum     = outOE->mod_env.md_id.osnum ,
				p_objid   = &outOE->obj_id.objid );
	if( !sts ) {
		printf("Constructing ACrg_collect failed\n");
		goto wrapup ;
	}

	if( strcmp( inName, "") ){
		sts = om$send(	msg	= message GRgraphics.GRputname (
						&msg,
						inName),
				senderid = NULL_OBJID ,
				targetid = outOE->obj_id.objid,
				targetos = outOE->obj_id.osnum );
		if( !(sts&msg&1) ) {
			printf("GRgraphics.GRputname failed\n");
			goto wrapup ;
		}
	}

	sts = om$send(  msg      = message ACrg_collect.ACset_list_attribute(
						&msg, attrCnt, collAttrs),
			senderid = NULL_OBJID ,
			targetid = outOE->obj_id.objid ,
			targetos = outOE->obj_id.osnum ) ;
	if( !(sts&msg&1) ) {
		printf("ACadd_list_attribute failed\n");
		goto wrapup ;
	}

	retFlag = 1 ;
wrapup:
End
	return retFlag;
}
/********************************************************/

IGRstat CreateInputCollector (	Form		form ,		// in
				IGRint		attrCnt ,	// in
				IGRchar		*inName ,	// in
				IGRchar		*lblPntFlag ,	// in
				TGRobj_env	*outOE )	// out
{
	IGRstat		retFlag = 0 ;
	IGRint		sts, toggle, i ;
	IGRchar		macStr[128], msgStr[128], inStr[128] ;
	IGRdouble	offsetVal, thickness, stockVal ;
struct	ACrg_coll	collAttrs[MAX_ATTRS] ;

SetProc(CreateInputCollector); Begin

	msgStr[0] = '\0' ;
	inStr[0] = '\0' ;
	outOE->obj_id.objid = NULL_OBJID ;

	i = 0 ;
	FIg_get_text( form, MACRO_TYPE, macStr );
	if( !strcmp(macStr, "") ) {
		strcpy( msgStr, "Macro Type not input yet") ;
		goto wrapup ;
	}
	strcpy( collAttrs[i].name, "macro_type" );
	collAttrs[i].desc.type = 1;
	strcpy(collAttrs[i].desc.value.att_txt, macStr) ;
	

	if( macStr[0] != 'F' ) {
		i = i + 1 ;	inStr[0] = '\0' ;	// i = 1
		FIg_get_text( form, BEVEL_TYPE, inStr );
/*
		if( !strcmp(inStr, "") ) {
			strcpy( msgStr, "Bevel Type not input yet") ;
			goto wrapup ;
		}
*/
		strcpy(collAttrs[i].name, "bevel_type");
		collAttrs[i].desc.type = 1;
		strcpy(collAttrs[i].desc.value.att_txt, inStr) ;
	}

	i = i + 1 ;	inStr[0] = '\0' ;	// i = 2
	FIg_get_text( form, PROCESS_TYPE, inStr );
	strcpy(collAttrs[i].name, "process_type");
	collAttrs[i].desc.type = 1;
	strcpy(collAttrs[i].desc.value.att_txt, inStr) ;

	i = i + 1 ;				// i = 3
	FIg_get_value( form, STOCK_VALUE, &stockVal );
	strcpy(collAttrs[i].name, "stock_value");
	collAttrs[i].desc.type = 2;
	collAttrs[i].desc.value.att_exp = stockVal ;

	i = i + 1 ;				// i = 4
	FIg_get_value( form, OFFSET_VALUE, &offsetVal );
	strcpy(collAttrs[i].name, "offset_value");
	collAttrs[i].desc.type = 2;
	collAttrs[i].desc.value.att_exp = offsetVal ;

	if( macStr[0] == '1' ) {		// i = 5
		i = i + 1 ;
		collAttrs[i].desc.type = 2;
		strcpy(collAttrs[i].name, "adjacent_plate_thickness");
		FIg_get_state( form, EJ_TOGGLE_INPUT, &toggle ) ;
		if( toggle ) {
			FIg_get_value( form, EJ_THICK_IN, &thickness );
		} else {
			FIg_get_value( form, EJ_PLATE_IN, &thickness );
		}
		if( thickness <= 0 ) {
			strcpy( msgStr, "Missing adjacent plate thickness") ;
			goto wrapup ;
		}
		collAttrs[i].desc.value.att_exp = thickness ;
	}

	i++ ;
	strcpy( collAttrs[i].name, "label_flag" ) ;
	collAttrs[i].desc.type = 1;
	collAttrs[i].desc.value.att_txt[0] = lblPntFlag[0] ;
	collAttrs[i].desc.value.att_txt[1] = lblPntFlag[1] ;
	collAttrs[i].desc.value.att_txt[2] = '\0' ;

	i++ ;

	sts = CreateCollector ( collAttrs, i, "", outOE ) ;

	if ( !sts ) goto wrapup ;

	retFlag = 1 ;
wrapup:
End
	if( strcmp(msgStr, "" ) )  {
		UI_status( msgStr ) ;
		FIg_set_text( form, MESSAGE_BAR, msgStr ) ;
	}
	return retFlag;
}


IGRstat UpdateMacroParent(
TGRobj_env *macOE,
TGRobj_env *oldOE,
TGRobj_env *newOE,
IGRboolean stateFlag)
{
        IGRstat retFlag ;
        IGRstat sts ;
        TGRid   oldSrcID, newSrcID ;

        retFlag = 0 ;

        oldSrcID.osnum = macOE->obj_id.osnum ;
        oldSrcID.objid = NULL_OBJID ;
        sts = as$make_source (  go_grid =  oldOE->obj_id ,
                                mod_env = &oldOE->mod_env ,
                                as_grid = &oldSrcID ) ;
        if ((!(sts & 1)) || (oldSrcID.objid == NULL_OBJID)) {
                printf("Problem sourcing parent \n");
                goto wrapup ;
        }

        newSrcID.osnum = macOE->obj_id.osnum ;
        newSrcID.objid = NULL_OBJID ;
        sts = as$make_source (  go_grid =  newOE->obj_id ,
                                mod_env = &newOE->mod_env ,
                                as_grid = &newSrcID ) ;
        if ((!(sts & 1)) || (newSrcID.objid == NULL_OBJID)) {
                printf("Problem sourcing parent \n");
                goto wrapup ;
        }

        if( stateFlag ) {
                sts = om$send ( msg      = message NDnode.NDchg_state (
                                                ND_DEL_NO_CH|ND_WAIT_DEL,
                                                ND_DEL_NO_CH|ND_WAIT_DEL ),
                                senderid = NULL_OBJID,
                                targetid = newSrcID.objid,
                                targetos = newSrcID.osnum );
                if( !(sts & 1) ) {
                        printf("NDnode.NDchg_state failed\n") ;
                        goto wrapup ;
                }
        }
        sts = om$send(  msg     = message NDnode.NDchange_connect (
                                        1,
                                        &oldSrcID,
                                        &newSrcID),
                        senderid = NULL_OBJID,
                        targetid = macOE->obj_id.objid,
                        targetos = macOE->obj_id.osnum);
        if( !(sts & 1) ) {
                printf("NDnode.NDchange_connect failed\n") ;
                goto wrapup ;
        }

        retFlag = 1 ;
wrapup:
        return retFlag ;
}


/**********************************************************************/
IGRstat CreateBevelMacro (	IGRchar		*macName ,	// in
				TGRobj_env	*objOEs ,	// in
				IGRint		 objCnt ,	// in
				IGRchar		*lblPntFlag ,	// in
				TGRobj_env	*bvlMacOE )	// out
{
	IGRlong		msg ;
	IGRint		sts, msgMac, i ;
	IGRstat		retFlag = 0 ;
	TGRid		srcIDs[20], pntID1, pntID2 ;
	IGRint		srcCnt ;
	IGRint		symbFlag = 0 ;
	TGRsymbology	symb, symb0 ;
	IGRchar		bvlName[80] ;

SetProc(CreateBevelMacro); Begin

	sts = 1 ;
	msg = 1 ;
	msgMac = 1 ;

	gr$get_module_env(buffer = &bvlMacOE->mod_env);
	bvlMacOE->obj_id.osnum = bvlMacOE->mod_env.md_id.osnum ;
	bvlMacOE->obj_id.objid = NULL_OBJID ;

	if( objCnt < 1 || objOEs == NULL ) {
		printf("No templates input\n");
		goto wrapup ; 
	}

	// Source everything
	if( objCnt > 20 ) {
		printf("Too many templates\n") ;
		goto wrapup ;
	}
	__DBGpr_int("objCnt", objCnt);

	srcCnt = objCnt ;
	for( i = 0;  i < srcCnt;  i++) {
		srcIDs[i].osnum = bvlMacOE->obj_id.osnum ;
		srcIDs[i].objid = NULL_OBJID ;
		sts = as$make_source (	go_grid =  objOEs[i].obj_id ,
					mod_env = &objOEs[i].mod_env ,
					as_grid = &srcIDs[i] ) ;
		if ((!(sts & 1)) || (srcIDs[i].objid == NULL_OBJID)) {
			printf("Problem sourcing parent \n");
			vdobj$Print(objOE = &objOEs[i]);
			goto wrapup ;
		}
		__DBGpr_obj("make source: objOEs", objOEs[i].obj_id);
		__DBGpr_obj("make source: srcIDs", srcIDs[i]);
	}

	// Set source point state to deletable if points were from computing 
	// instead of input from user
	pntID1.objid = pntID2.objid = NULL_OBJID ;
	switch( macName[0] ) {
		case 'E':
		case 'F':
			pntID1 = srcIDs[E_POINT] ;
			break ;
		case 'B':
			pntID1 = srcIDs[POINT1] ;
			pntID2 = srcIDs[POINT2] ;
			break ;
		case 'V':
			pntID1 = srcIDs[V_POINT] ;
			break ;
	}
	if( lblPntFlag[0] == '0' ) {
		sts = om$send ( msg	 = message NDnode.NDchg_state ( 
						ND_DEL_NO_CH|ND_WAIT_DEL, 
						ND_DEL_NO_CH|ND_WAIT_DEL ),
				senderid = NULL_OBJID,
				targetid = pntID1.objid,
				targetos = pntID1.osnum );
	}
	if( lblPntFlag[1] == '0' ) {
		sts = om$send ( msg	 = message NDnode.NDchg_state ( 
						ND_DEL_NO_CH|ND_WAIT_DEL, 
						ND_DEL_NO_CH|ND_WAIT_DEL ),
				senderid = NULL_OBJID,
				targetid = pntID2.objid,
				targetos = pntID2.osnum );
	}

	// Construct macro ID
	om$construct (	classid = OPP_nci_macro_class_id,
			osnum   =  bvlMacOE->obj_id.osnum,
			p_objid = &bvlMacOE->obj_id.objid);
	if( bvlMacOE->obj_id.objid == NULL_OBJID ) {
		printf("Failed to construct bvlMacOE\n");
		goto wrapup ;
	}

	// Set symbology
	VDahGetActiveSymbology(&symb) ;
	VDahGetActiveSymbology(&symb0) ;

	symb.display_attr.weight = 2 ;
	VDahSetActiveSymbology(&symb) ;
	symbFlag = 1 ;

	sts = om$send(  msg     = message  ci_macro.init(
						&msgMac,
						0,
						macName,
						srcCnt ,
						srcIDs,
						NULL,
						&bvlMacOE->mod_env),
			mode     = OM_e_wrt_message ,
			senderid = NULL_OBJID ,
			targetid = bvlMacOE->obj_id.objid ,
			targetos = bvlMacOE->obj_id.osnum ) ;

	if( !(sts & msgMac & 1) ) {
	  printf("Error placing bevel macro. sts = %d, msgMac = %d\n",sts,msgMac);
	  goto wrapup ;
	}
	else {
		sprintf(bvlName,"M%d%d",
			bvlMacOE->obj_id.objid, bvlMacOE->obj_id.osnum);
		sts = om$send(  msg = message GRvg.GRputname( &msg, bvlName),
				senderid = NULL_OBJID ,
				targetid = bvlMacOE->obj_id.objid,
				targetos = bvlMacOE->obj_id.osnum);
		if( !(sts & msg & 1) ) {
			printf("Error macro name\n");
		}
	}

	retFlag = 1 ;
wrapup:
	if( symbFlag ) {
		VDahSetActiveSymbology( &symb0 ) ;
	}
End
	return retFlag ;
}


/**********************************************************************/
IGRstat	GetMacroParents(	TGRobj_env	*macOE ,	// in
				TGRobj_env	*parentOEs ,	// out
				IGRint		*parentCnt )	// out
{
	IGRstat		retFlag = 0;
	IGRstat		sts = 1 ;
	IGRlong		msg = 1 ;
	IGRint		i = 0 ;
	TGRid		tempID ;
	TGRmd_env	objENV ;

SetProc(GetMacroParents); Begin

	gr$get_module_env (buffer = &objENV);

	*parentCnt = 0 ;
	while( (sts&msg&1) ) {
		tempID.objid = NULL_OBJID ;
		sts = om$send ( msg = message ACcpx.ACfind_exp_temp_obj
					( (int *)&msg, i, &tempID ),
				senderid = NULL_OBJID ,
				targetid = macOE->obj_id.objid,
				targetos = macOE->obj_id.osnum );
		if( !(sts&msg&1) ) break ;

		parentOEs[i].obj_id.objid == NULL_OBJID ;
		sts = vd_$return_foot ( msg     = &msg,
					objId   = &tempID,
					objEnv  = &objENV,
					footId  = &parentOEs[i].obj_id,
					footEnv = &parentOEs[i].mod_env );
		if( !(sts&msg&1) ) break ;

		__DBGpr_obj("tempID ", tempID);
		__DBGpr_obj("parentOEs", parentOEs[i].obj_id);

		i++ ;
	}
	*parentCnt = i ;

	retFlag = 1 ;
wrapup:
End
	return retFlag ;
}


/**********************************************************************/
IGRstat VSsetGlobalFontSize( TGRobj_env *macOE )
{
        IGRstat         retFlag = 0;
        IGRlong         sts, msg ;
        TGRobj_env      labelOE ;
        IGRshort        txtlen ;
struct  IGRestx         txtAttr ;
        IGRuchar                *text ;

SetProc(VSsetGlobalFontSize); Begin

        text = NULL ;
        labelOE.obj_id.objid = NULL_OBJID ;
	// if( VSbvl_font_size > 0 ) goto wrapup ;

	/* ---------------------------------------
	 * Use the new routine until this goes away
	 */
	VSbevelSetFontSize(0,macOE);
	
        vdobj$GetFoot(  objOE    = macOE,
                        footName = "label" ,
                        footOE   = &labelOE);
        if( labelOE.obj_id.objid == NULL_OBJID ) {
		vdobj$GetFoot(  objOE    = macOE,
				footName = "label1" ,
				footOE   = &labelOE);
        	if( labelOE.obj_id.objid == NULL_OBJID && !VSbvl_font_size ) {
			VSbvl_set_font_size( 25 ) ;
			goto wrapup ;
		}
        }
        __DBGpr_obj("labelOE", labelOE.obj_id);
        sts = om$send ( msg      = message GRtext.GRgettxattr
                                        ( &msg, &txtAttr, &txtlen, &text ),
                        senderid = NULL_OBJID ,
                        targetid = labelOE.obj_id.objid ,
                        targetos = labelOE.obj_id.osnum ) ;
        if( !(msg&1) ) {
        	if( !VSbvl_font_size ) VSbvl_set_font_size( 25 ) ;
                goto wrapup ;
        }

        VSbvl_set_font_size( (int) txtAttr.width ) ;

        retFlag = 1 ;
wrapup:
        _FREE( text ) ;
        End
}


/**********************************************************************/
IGRstat	VScomputeFab_Stock2(	TGRobj_env	*macOE ,	// in
				IGRint		tempCnt ,	// in
				IGRint		*feetCnt ,	// out
				TGRid		*feetIDs )	// out
{
	IGRstat		retFlag = 0;
	IGRstat		sts;
	IGRlong		msg;
	IGRint		i ;
	IGRdouble       offsetVal ;
	IGRint		attrCnt ;
	TGRbsp_curve	*bvlCrv ;
	TGRobj_env	bvlOE ;
	TGRobj_env	outAttrOE ;
	TGRobj_env	lblTxtOE, lblSymOE ;
	TGRobj_env	objOEs[20], newOE ;
	IGRchar		lblText[40] ;
	TGRmd_env	objENV ;
	TGRsymbology	symb ;
struct	ACrg_coll	collAttrs[MAX_ATTRS] ;

SetProc(VScomputeFab_Stock); Begin

	bvlCrv = NULL;
	gr$get_module_env (buffer = &objENV);

	GetMacroParents(macOE, objOEs, &tempCnt ) ;

	if( !VSbvl_font_size) VSsetGlobalFontSize( macOE ) ;

	VDahGetActiveSymbology(&symb);
	vd_$grCopy (	msg	= &msg , 
			frEnv	= &objOEs[E_CURVE].mod_env ,
			frObj	= &objOEs[E_CURVE].obj_id ,
			toEnv	= &objENV ,
			symb	= &symb ,
			toObj	= &bvlOE.obj_id ) ;
	if( !(msg&1) ) {
		printf("vd_$grCOpy failed\n") ;
		goto wrapup ;
	}
	bvlOE.mod_env = objENV ;

	vs$get_geometry(msg      = &msg ,
			grobjId  = &bvlOE.obj_id ,
			grobjEnv = &bvlOE.mod_env ,
			geometry = &bvlCrv ) ;
	if( !(msg&1) ) {
		printf("vs$get_geometry failed\n") ;
		goto wrapup ;
	}

	sts = om$send (	msg      = message  ACrg_collect.AClist_attribute(
						&msg ,
                                                MAX_ATTRS ,
                                                collAttrs ,
                                                &attrCnt ) ,
			senderid = NULL_OBJID ,
			targetid = objOEs[E_ATTR].obj_id.objid ,
			targetos = objOEs[E_ATTR].obj_id.osnum ) ;
	if( !(sts&msg&1) ) {
		printf("ACrg_collect.AClist_attribute failed\n");
		goto wrapup ;
	}

	outAttrOE.obj_id.objid = NULL_OBJID ;
	sts = CreateCollector ( collAttrs, attrCnt-1, "", &outAttrOE ) ;
	if( !sts ) {
		printf("CreateCollector() failed\n");
		goto wrapup ;
	}

        // recompute label point for updating macro
        if( collAttrs[F_label_flag].desc.value.att_txt[0] == '0' ) {
                offsetVal = collAttrs[F_offset_value].desc.value.att_exp ;
                newOE.obj_id.objid = NULL_OBJID ;
                sts = GetLabelPoint (   &objOEs[E_PLATE],
                                        bvlCrv,
                                        offsetVal,
                                        &newOE ) ;
                if( !sts ) {
                        printf("GetLabelPoint failed to get E_POINT\n") ;
                        goto wrapup ;
                }

                sts = UpdateMacroParent( macOE, &objOEs[E_POINT], &newOE, TRUE);
                if( !(sts & 1) ) {
                        printf("UpdateMacroParent() failed\n") ;
                        goto wrapup ;
                }

                objOEs[E_POINT] = newOE ;
        }

	lblTxtOE.obj_id.objid = NULL_OBJID ;
	sts = ConstTextLabel (	0,
				"S" , 
				bvlCrv , 
				&objOEs[E_PLATE] ,
				&objOEs[E_POINT] ,
				&lblTxtOE ) ;
	if( !sts ) {
		printf("Faile to construct label\n");
		goto wrapup ;
	}

	lblSymOE.obj_id.objid = NULL_OBJID ;
	sts = ConstSymbLabel (	bvlCrv , 
				&objOEs[E_PLATE] ,
				&objOEs[E_POINT] ,
				&lblSymOE ) ;
	if( !sts ) {
		printf("Faile to construct label\n");
		goto wrapup ;
	}

	*feetCnt = 0 ;
	feetIDs[*feetCnt] = outAttrOE.obj_id ;

	(*feetCnt)++ ;
	feetIDs[*feetCnt] = bvlOE.obj_id ;

	(*feetCnt)++ ;
	feetIDs[*feetCnt] = lblTxtOE.obj_id ;

	(*feetCnt)++ ;
	feetIDs[*feetCnt] = lblSymOE.obj_id ;

	(*feetCnt)++ ;

	retFlag = 1 ;
wrapup:
	_FREE( bvlCrv ) ;
	if (retFlag == 0) {
	  printf("*** VScomputeFab_Stock Failed for Bevel %d,%d\n",
		 macOE->obj_id.osnum,
		 macOE->obj_id.objid);
	}
	
	End
	return retFlag ;
}

/**********************************************************************/
IGRstat	VScomputeEJ_Bevel2(	TGRobj_env	*macOE ,	// in
				IGRint		tempCnt ,	// in
				IGRint		*feetCnt ,	// out
				TGRid		*feetIDs )	// out
{
	IGRstat		retFlag = 0;
	IGRstat		sts;
	IGRlong		msg;
	IGRint		i, pos ;
	IGRint		attrCnt ;
	IGRdouble       offsetVal ;
	TGRbsp_curve	*bvlCrv ;
	TGRobj_env	bvlOE ;
	TGRobj_env	outAttrOE ;
	TGRobj_env	lblTxtOE, stockSymbOE, stockOE ;
	TGRobj_env	objOEs[20], newOE ;
	IGRchar		lblText[40] ;
	TGRmd_env	objENV ;
	TGRsymbology	symb ;
struct	ACrg_coll	collAttrs[MAX_ATTRS] ;

	SetProc(VScomputeEJ_Bevel); Begin

	bvlCrv = NULL;
	gr$get_module_env (buffer = &objENV);

	GetMacroParents(macOE, objOEs, &tempCnt ) ;
	__DBGpr_int("tempCnt", tempCnt);

	if( !VSbvl_font_size) VSsetGlobalFontSize( macOE ) ;

	VDahGetActiveSymbology(&symb);
	bvlOE.obj_id.objid = NULL_OBJID ;
	vd_$grCopy(	msg	= &msg , 
			frObj	= &objOEs[E_CURVE].obj_id ,
			frEnv	= &objOEs[E_CURVE].mod_env ,
			toEnv	= &objENV ,
			symb	= &symb ,
			toObj	= &bvlOE.obj_id ) ;
	if( !(msg&1) ) {
		printf("vd_$grCopy failed\n") ;
		goto wrapup ;
	}
	bvlOE.mod_env = objENV ;

        /*
         * Set the display/locate on ; Parent could have been consumed.
         */
        {
          IGRshort s_action = 1;
          IGRshort s_mask   = GRIS_LOCATABLE|GRIS_DISPLAYABLE;
          sts =
          om$send( msg = message GRgraphics.GRchgprops(&msg,&s_action,&s_mask),
                   targetid = bvlOE.obj_id.objid,
                   targetos = bvlOE.obj_id.osnum,
                   senderid = bvlOE.obj_id.objid );
        }

	vs$get_geometry(msg      = &msg ,
			grobjId  = &bvlOE.obj_id ,
			grobjEnv = &bvlOE.mod_env ,
			geometry = &bvlCrv ) ;
	if( !(msg&1) ) {
		printf("vs$get_geometry failed\n") ;
		goto wrapup ;
	}


	attrCnt = 0 ;
	sts = om$send (	msg      = message  ACrg_collect.AClist_attribute(
						&msg ,
                                                MAX_ATTRS ,
                                                collAttrs ,
                                                &attrCnt ) ,
			senderid = NULL_OBJID ,
			targetid = objOEs[E_ATTR].obj_id.objid ,
			targetos = objOEs[E_ATTR].obj_id.osnum ) ;
	if( !(sts&msg&1) ) {
		printf("ACrg_collect.AClist_attribute failed\n");
		goto wrapup ;
	}

	strcpy( lblText, collAttrs[1].desc.value.att_txt ) ;
/*
	if( !strcmp( lblText, "" ) ) {
		strcpy( lblText, "Unknown");
	}
*/

	outAttrOE.obj_id.objid = NULL_OBJID ;
	sts = CreateCollector ( collAttrs, attrCnt-3, "", &outAttrOE ) ;
	if( !sts ) {
		printf("CreateCollector failed\n");
		goto wrapup ;
	}

        // recompute label point for updating macro
        if( collAttrs[E_label_flag].desc.value.att_txt[0] == '0' ) {
                offsetVal = collAttrs[offset_value].desc.value.att_exp ;
                newOE.obj_id.objid = NULL_OBJID ;
                sts = GetLabelPoint (   &objOEs[E_PLATE],
                                        bvlCrv,
                                        offsetVal,
                                        &newOE ) ;
                if( !sts || newOE.obj_id.objid == NULL_OBJID ) {
                        printf("GetLabelPoint failed to get E_POINT\n") ;
                        goto wrapup ;
                }

                sts = UpdateMacroParent( macOE, &objOEs[E_POINT], &newOE, TRUE);
                if( !(sts & 1) ) {
                        printf("UpdateMacroParent() failed\n") ;
                        goto wrapup ;
                }

                objOEs[E_POINT] = newOE ;
        }

	__DBGpr_str("collAttrs[stock_value].name", collAttrs[stock_value].name);
	if( collAttrs[stock_value].desc.value.att_exp > 0.001 ) {
		pos = 1 ;
	}
	else {
		pos = 0 ;
	}

	lblTxtOE.obj_id.objid = NULL_OBJID ;
	sts = ConstTextLabel (	pos ,
				lblText , 
				bvlCrv , 
				&objOEs[E_PLATE] ,
				&objOEs[E_POINT] ,
				&lblTxtOE ) ;
	if( !sts ) {
		printf("Faile to construct label\n");
		goto wrapup ;
	}

	*feetCnt = 0 ;
	feetIDs[*feetCnt] = outAttrOE.obj_id ;
	__DBGpr_obj("outAttrOE.obj_id", outAttrOE.obj_id);

	(*feetCnt)++ ;
        feetIDs[*feetCnt] = bvlOE.obj_id ;
        __DBGpr_obj("bvlOE.obj_id", bvlOE.obj_id);

	(*feetCnt)++ ;
	feetIDs[*feetCnt] = lblTxtOE.obj_id ;
	__DBGpr_obj("lblTxtOE.obj_id", lblTxtOE.obj_id);

	stockSymbOE.obj_id.objid = NULL_OBJID ;
	stockOE.obj_id.objid = NULL_OBJID ;
	if( pos ) {
		sts = ConstSymbLabel (	bvlCrv ,
					&objOEs[E_PLATE] ,
					&objOEs[E_POINT] ,
					&stockSymbOE ) ;
		if( !sts ) {
			printf("ConstSymbLabel failed\n");
			goto wrapup ;
		}
		(*feetCnt)++ ;
		feetIDs[*feetCnt] = stockSymbOE.obj_id ;
	__DBGpr_obj("stockSymbOE.obj_id", stockSymbOE.obj_id);

		sts = ConstTextLabel (	0,
					"S" , 
					bvlCrv , 
					&objOEs[E_PLATE] ,
					&objOEs[E_POINT] ,
					&stockOE ) ;
		if( !sts ) {
			printf("Faile to construct label\n");
			goto wrapup ;
		}
		(*feetCnt)++ ;
		feetIDs[*feetCnt] = stockOE.obj_id ;
	__DBGpr_obj("stockOE.obj_id", stockOE.obj_id);
	}
	(*feetCnt)++ ;
	__DBGpr_int("feetCnt", *feetCnt);


	retFlag = 1 ;
wrapup:
	if (retFlag == 0) {
	  printf("*** VScomputeEJ_Bevel Failed, %d,%d\n",
		 macOE->obj_id.osnum,
		 macOE->obj_id.objid);
	}
	
	_FREE( bvlCrv ) ;

	End
	return retFlag ;
}

/**********************************************************************/
IGRstat	VScomputeBevel2(TGRobj_env	*macOE ,	// in
			IGRint		tempCnt ,	// in
			IGRint		*feetCnt ,	// out
			TGRid		*feetIDs )	// out
{
	IGRstat		retFlag = 0;
	IGRstat		sts;
	IGRlong		msg;
	IGRint		i, pos ;
	IGRint		attrCnt ;
	IGRdouble	offsetVal ;
	TGRbsp_curve	*bvlCrv ;
	TGRobj_env	bvlOE ;
	TGRobj_env	outAttrOE ;
	TGRobj_env	lblTxtOE1,	lblTxtOE2 ;
	TGRobj_env	stockOE1,	stockOE2 ;
	TGRobj_env	stockSymbOE1,	stockSymbOE2 ;
	TGRobj_env	objOEs[20], newOE ;
	IGRchar		lblText[40] ;
	TGRmd_env	objENV ;
struct	ACrg_coll	collAttrs[MAX_ATTRS] ;
	BSrc		rc;

SetProc(VScomputeBevel); Begin

	bvlCrv = NULL ;
	gr$get_module_env (buffer = &objENV);

	GetMacroParents(macOE, objOEs, &tempCnt ) ;

	if( !VSbvl_font_size) VSsetGlobalFontSize( macOE ) ;

	__DBGpr_obj("objOEs[EDGE1]", objOEs[EDGE1].obj_id);
	__DBGpr_obj("objOEs[EDGE2]", objOEs[EDGE2].obj_id);
	bvlOE.obj_id.objid = NULL_OBJID ;
	sts = ConstructBevel (	&objOEs[EDGE1] , 
				&objOEs[EDGE2] , 
				&bvlOE , 
				&bvlCrv ) ;
	if( !sts ) {
		printf("ConstructBevel() failed\n") ;
		UI_status("Edges or plates may not be closed enough");
		goto wrapup ;
	}

	sts = om$send (	msg      = message  ACrg_collect.AClist_attribute(
						&msg ,
                                                MAX_ATTRS ,
                                                collAttrs ,
                                                &attrCnt ) ,
			senderid = NULL_OBJID ,
			targetid = objOEs[ATTRIN].obj_id.objid ,
			targetos = objOEs[ATTRIN].obj_id.osnum ) ;
	if( !(sts&msg&1) ) {
		printf("ACrg_collect.AClist_attribute failed\n");
		goto wrapup ;
	}

	strcpy( lblText, collAttrs[bevel_type].desc.value.att_txt ) ;
	if( !strcmp( lblText, "" ) ) {
		strcpy( lblText, "Unknown");
	}

	outAttrOE.obj_id.objid = NULL_OBJID ;
	sts = CreateCollector ( collAttrs, attrCnt-2, "", &outAttrOE ) ;
	if( !sts ) {
		printf("CreateCollector() failed\n");
		goto wrapup ;
	}

        // recompute label point for updating macro
        if( collAttrs[label_flag].desc.value.att_txt[0] == '0' ) {
                offsetVal = collAttrs[offset_value].desc.value.att_exp ;
                newOE.obj_id.objid = NULL_OBJID ;
                sts = GetLabelPoint (   &objOEs[PLATE1],
                                        bvlCrv,
                                        offsetVal,
                                        &newOE ) ;
                if( !sts || newOE.obj_id.objid == NULL_OBJID ) {
                        printf("GetLabelPoint failed to get POINT1\n") ;
                        goto wrapup ;
                }

                sts = UpdateMacroParent( macOE, &objOEs[POINT1], &newOE, TRUE);
                if( !(sts & 1) ) {
                        printf("UpdateMacroParent() failed\n") ;
                        goto wrapup ;
                }

                objOEs[POINT1] = newOE ;
        }
        if( collAttrs[label_flag].desc.value.att_txt[1] == '0' ) {
                offsetVal = collAttrs[offset_value].desc.value.att_exp ;
                newOE.obj_id.objid = NULL_OBJID ;
                sts = GetLabelPoint (   &objOEs[PLATE2],
                                        bvlCrv,
                                        -offsetVal,
                                        &newOE ) ;
                if( !sts || newOE.obj_id.objid == NULL_OBJID ) {
                        printf("GetLabelPoint failed to get POINT2\n") ;
                        goto wrapup ;
                }

                sts = UpdateMacroParent( macOE, &objOEs[POINT2], &newOE, TRUE);
                if( !(sts & 1) ) {
                        printf("UpdateMacroParent() failed\n") ;
                        goto wrapup ;
                }

                objOEs[POINT2] = newOE ;
        }


	if( collAttrs[stock_value].desc.value.att_exp > 0.001 ) {
		pos = 1 ;
	}
	else {
		pos = 0 ;
	}

	lblTxtOE1.obj_id.objid = NULL_OBJID ;
	sts = ConstTextLabel (	pos,
				lblText , 
				bvlCrv , 
				&objOEs[PLATE1] ,
				&objOEs[POINT1] ,
				&lblTxtOE1 ) ;
	if( !sts ) {
		printf("Faile to get construct label 1\n");
		goto wrapup ;
	}

	lblTxtOE2.obj_id.objid = NULL_OBJID ;
	sts = ConstTextLabel (	pos,
				lblText, 
				bvlCrv, 
				&objOEs[PLATE2] , 
				&objOEs[POINT2] , 
				&lblTxtOE2 ) ;
	if( !sts ) {
		printf("Faile to get construct label 2\n");
		goto wrapup ;
	}

	*feetCnt = 0 ;
	feetIDs[*feetCnt] = outAttrOE.obj_id ;

	(*feetCnt)++ ;
	feetIDs[*feetCnt] = bvlOE.obj_id ;

	(*feetCnt)++ ;
	feetIDs[*feetCnt] = lblTxtOE1.obj_id ;

	(*feetCnt)++ ;
	feetIDs[*feetCnt] = lblTxtOE2.obj_id ;

	if( pos ) {
		stockSymbOE1.obj_id.objid = NULL_OBJID ;
		sts = ConstSymbLabel (	bvlCrv ,
					&objOEs[PLATE1] ,
					&objOEs[POINT1] ,
					&stockSymbOE1 ) ;
		if( !sts ) {
			printf("ConstSymbLabel failed\n");
			goto wrapup ;
		}
		(*feetCnt)++ ;
		feetIDs[*feetCnt] = stockSymbOE1.obj_id ;

		stockOE1.obj_id.objid = NULL_OBJID ;
		sts = ConstTextLabel (	0,
					"S" , 
					bvlCrv , 
					&objOEs[PLATE1] ,
					&objOEs[POINT1] ,
					&stockOE1 ) ;
		if( !sts ) {
			printf("Faile to construct label\n");
			goto wrapup ;
		}
		(*feetCnt)++ ;
		feetIDs[*feetCnt] = stockOE1.obj_id ;

		stockSymbOE2.obj_id.objid = NULL_OBJID ;
		sts = ConstSymbLabel (	bvlCrv ,
					&objOEs[PLATE2] ,
					&objOEs[POINT2] ,
					&stockSymbOE2 ) ;
		if( !sts ) {
			printf("ConstSymbLabel failed\n");
			goto wrapup ;
		}
		(*feetCnt)++ ;
		feetIDs[*feetCnt] = stockSymbOE2.obj_id ;

		stockOE2.obj_id.objid = NULL_OBJID ;
		sts = ConstTextLabel (	0,
					"S" , 
					bvlCrv , 
					&objOEs[PLATE2] ,
					&objOEs[POINT2] ,
					&stockOE2 ) ;
		if( !sts ) {
			printf("Failed to construct label\n");
			goto wrapup ;
		}
		(*feetCnt)++ ;
		feetIDs[*feetCnt] = stockOE2.obj_id ;

	}

	(*feetCnt)++ ;

	
	retFlag = 1 ;
wrapup:
	if( bvlCrv ) BSfreecv( &rc, bvlCrv);
	if (retFlag == 0) { 
	  printf("*** VScomputeBevel Failed, %d,%d\n",
		 macOE->obj_id.osnum,
		 macOE->obj_id.objid);
	}

End
	return retFlag ;
}

/**********************************************************************/
IGRstat	VScomputeVariable_Bevel2(TGRobj_env	*macOE ,	// in
				 IGRint		tempCnt ,	// in
				 IGRint		*feetCnt ,	// out
				 TGRid		*feetIDs )	// out
{
	IGRstat		retFlag = 0;
	IGRstat		sts;
	IGRlong		msg;
	IGRint		i, pos ;
	IGRint		attrCnt ;
	IGRdouble	offsetVal ;
	TGRbsp_curve	*crv ;
	TGRobj_env	baseCrvOE ;
	TGRobj_env	offsetCrvOE ;
	TGRobj_env	outAttrOE ;
	TGRobj_env	lblTxtOE, stockOE, stockSymbOE ;
	TGRobj_env	objOEs[20], newOE ;
	IGRchar		lblText[40] ;
	TGRmd_env	objENV ;
	TGRsymbology	symb ;
struct	ACrg_coll	collAttrs[MAX_ATTRS] ;

	SetProc(VScomputeVariable_Bevel); Begin

	crv = NULL ;
	__DBGpr_obj( "macOE", macOE->obj_id);
	gr$get_module_env (buffer = &objENV);

	GetMacroParents(macOE, objOEs, &tempCnt ) ;

	if( !VSbvl_font_size) VSsetGlobalFontSize( macOE ) ;

	VDahGetActiveSymbology(&symb);
	baseCrvOE.mod_env = objENV ;
	vd_$grCopy(	msg	= &msg , 
			frEnv	= &objOEs[V_BASE_CRV].mod_env ,
			frObj	= &objOEs[V_BASE_CRV].obj_id ,
			toEnv	= &objENV ,
			symb	= &symb ,
			toObj	= &baseCrvOE.obj_id ) ;
	if( !(msg&1) ) {
		printf("vd_$grCopy failed to copy base crv\n") ;
		goto wrapup ;
	}

	offsetCrvOE.mod_env = objENV ;
	offsetCrvOE.obj_id.objid = NULL_OBJID ;
	vd_$grCopy(	msg	= &msg , 
			frEnv	= &objOEs[V_OFF_CRV].mod_env ,
			frObj	= &objOEs[V_OFF_CRV].obj_id ,
			toEnv	= &objENV ,
			symb	= &symb ,
			toObj	= &offsetCrvOE.obj_id ) ;
	if( !(msg&1) ) {
		printf("vd_$grCopy failed to copy offset crv\n") ;
		goto wrapup ;
	}

	vs$get_geometry(msg      = &msg ,
			grobjId  = &baseCrvOE.obj_id ,
			grobjEnv = &baseCrvOE.mod_env ,
			geometry = &crv ) ;
	if( !(msg&1) ) {
		printf("vs$get_geometry failed\n") ;
		goto wrapup ;
	}


	sts = om$send (	msg      = message  ACrg_collect.AClist_attribute(
						&msg ,
                                                MAX_ATTRS ,
                                                collAttrs ,
                                                &attrCnt ) ,
			senderid = NULL_OBJID ,
			targetid = objOEs[V_ATTR].obj_id.objid ,
			targetos = objOEs[V_ATTR].obj_id.osnum ) ;
	if( !(sts&msg&1) ) {
		printf("ACrg_collect.AClist_attribute failed\n");
		goto wrapup ;
	}

	strcpy( lblText, collAttrs[1].desc.value.att_txt ) ;
	if( !strcmp( lblText, "" ) ) {
		strcpy( lblText, "Unknown");
	}

        // recompute label point for updating macro
        if( collAttrs[V_label_flag].desc.value.att_txt[0] == '0' ) {
                offsetVal = collAttrs[offset_value].desc.value.att_exp ;
                newOE.obj_id.objid = NULL_OBJID ;
                sts = GetLabelPoint (   &objOEs[V_PLATE],
                                        crv,
                                        offsetVal,
                                        &newOE ) ;
                if( !sts || newOE.obj_id.objid == NULL_OBJID ) {
                        printf("GetLabelPoint failed to get V_POINT\n") ;
                        goto wrapup ;
                }

                sts = UpdateMacroParent( macOE, &objOEs[V_POINT], &newOE, TRUE);
                if( !(sts & 1) ) {
                        printf("UpdateMacroParent() failed\n") ;
                        goto wrapup ;
                }

                objOEs[V_POINT] = newOE ;
        }

	outAttrOE.obj_id.objid = NULL_OBJID ;
	sts = CreateCollector ( collAttrs, attrCnt-2, "", &outAttrOE ) ;
	if( !sts ) {
		printf("CreateCollector() failed\n");
		goto wrapup ;
	}

	if( collAttrs[stock_value].desc.value.att_exp > 0.001 ) {
		pos = 1;
	}
	else {
		pos = 0 ;
	}

	lblTxtOE.obj_id.objid = NULL_OBJID ;
	sts = ConstTextLabel (	pos,
				lblText , 
				crv , 
				&objOEs[V_PLATE] ,
				&objOEs[V_POINT] ,
				&lblTxtOE ) ;
	if( !sts ) {
		printf("Faile to construct label\n");
		goto wrapup ;
	}

	*feetCnt = 0 ;
	feetIDs[*feetCnt] = outAttrOE.obj_id ;

	(*feetCnt)++ ;
	feetIDs[*feetCnt] = baseCrvOE.obj_id ;

	(*feetCnt)++ ;
	feetIDs[*feetCnt] = offsetCrvOE.obj_id ;

	(*feetCnt)++ ;
	feetIDs[*feetCnt] = lblTxtOE.obj_id ;

	if( pos ) {
		stockSymbOE.obj_id.objid = NULL_OBJID ;
		sts = ConstSymbLabel (	crv ,
					&objOEs[V_PLATE] ,
					&objOEs[V_POINT] ,
					&stockSymbOE ) ;
		if( !sts ) {
			printf("ConstSymbLabel failed\n");
			goto wrapup ;
		}
		(*feetCnt)++ ;
		feetIDs[*feetCnt] = stockSymbOE.obj_id ;

		stockOE.obj_id.objid = NULL_OBJID ;
		sts = ConstTextLabel (	0,
					"S" , 
					crv , 
					&objOEs[V_PLATE] ,
					&objOEs[V_POINT] ,
					&stockOE ) ;
		if( !sts ) {
			printf("Faile to construct label\n");
			goto wrapup ;
		}
		(*feetCnt)++ ;
		feetIDs[*feetCnt] = stockOE.obj_id ;

	}

	(*feetCnt)++ ;

	retFlag = 1 ;
wrapup:
	_FREE(crv) ;
	if (retFlag == 0) {
	  printf("*** VScomputeVariable_Bevel Failed for Bevel %d,%d\n",
		 macOE->obj_id.osnum,
		 macOE->obj_id.objid);
	}
	
	End
	return retFlag ;
}

/**********************************************************************/
IGRboolean CheckForProperName (	TGRobj_env	*objOE ,	// in
				IGRint		check ,		// in
				IGRchar		*objName ,	// out
				IGRchar		*msgStr )	// out
{
	IGRstat		sts ;
	IGRlong		msg ;
	IGRboolean	ret = FALSE ;
	IGRchar		tmpName[1024] ;
	TGRid		srcID ;

	SetProc(CheckForProperName); Begin

	msgStr[0]	= '\0' ;
        objName[0]	= '\0';
	tmpName[0]	= '\0' ;

	vdobj$Get (	objOE	= objOE, 
			objName = objName ) ;

	__DBGpr_str("objName", objName ) ;
        if( strcmp(objName,"") ) return TRUE ;

	// if no name returned try to get foot name
	sts = as$make_source (	go_grid =  objOE->obj_id ,
				mod_env = &objOE->mod_env ,
				as_grid = &srcID ) ;
	if ((!(sts & 1)) || (srcID.objid == NULL_OBJID)) {
		__DBGpr_com("as$make_source failed") ;
	}

	sts = om$send (	msg	 = message ACpretend.ACgive_downscan
						(tmpName),
			senderid = NULL_OBJID,
			targetid = srcID.objid,
			targetos = srcID.osnum);

	if (!(sts & 1)) {
		__DBGpr_com("ACpretend.ACgive_downscan failed") ;
		strcpy(tmpName, "");
	}
	__DBGpr_str("tmpName", tmpName ) ;

	if( !strcmp( tmpName, "" ) ) {
		UI_status("This object is not named");
		strcpy( objName, "Unknown" ) ;
		strcpy(msgStr, "This object is not named");
		//return FALSE;
	}
	else strcpy( objName, tmpName ) ;

        //if ( check ) do something

	ret = TRUE ;
wrapup:
End
        return TRUE;
}


/****************************************************************************/
IGRboolean GetMacroName (
		TGRid	macID,		// in,  macro id
	 	IGRchar	*macName ,	// out, macro name
		IGRchar	*msgStr	)	// out, return message
{
	IGRboolean	retFlag = FALSE ;
	IGRint		sts ; 
	IGRlong		msg ;
	TGRid		tempID, defID ;
	IGRchar		fullName[80] ;
	IGRchar		stripName[80] ;

SetProc(GetMacroName) ; Begin

	fullName[0]	= '\0'  ;
	stripName[0]	= '\0' ;
	macName[0]	= '\0' ;
	msgStr[0]	= '\0' ;

	sts = om$send(	msg      = message ci_macro.find_macro ( &tempID ) ,
			senderid = NULL_OBJID ,
			targetid = macID.objid ,
			targetos = macID.osnum ) ;
	if( !(sts & 1) ) {
		printf("Can't find tempID from macro ID\n");
		goto wrapup ;
	}
	__DBGpr_obj( "tempID", tempID);

	sts = om$send(  msg      = message GRvg.GRgetname( &msg, fullName ) ,
			senderid = NULL_OBJID ,
			targetid = tempID.objid ,
			targetos = tempID.osnum ) ;
	if( !(sts & msg & 1) ) {
		printf("Can't find macro name\n");
		goto wrapup ;
	}
	__DBGpr_str("fullName from GRgetname", fullName ) ;
	
	di$split (	pathname = fullName,
			dirname  = NULL,
			name	 = stripName );

	sts = ac$find_macro_defn( action	= ACfind_load ,
				macro_name	= stripName,
				p_macro_defn_id	= &defID);
	if( !(sts & 1) ) {
		printf("ac$find_macro_defn failed\n");
		goto wrapup ;
	}

	__DBGpr_str("stripName", stripName ) ;
	strcpy( macName, stripName ) ;
	if( !strcmp( macName, "") ) {
		sprintf( msgStr, "No macro name found") ;
		UI_status(msgStr);
		retFlag = FALSE ;
	}
	else {
		retFlag = TRUE ;
	}

wrapup:
End
	return retFlag ;
	
}


/************************************************************************
 * Check if a Bevel/Fab_Stock already exists as a child of the plate.
 */
IGRboolean  CheckMacroBy2parents (	TGRobj_env	*parentOE1 ,	// in
					TGRobj_env	*parentOE2 ,	// in
					IGRchar		*msgStr )	// out
{
	IGRboolean		retFlag ;
	IGRstat			sts ;
	IGRlong			msg ;
	IGRint			i ,j ;
	IGRchar			macName[128] ;
	GRclassid		classid ;
	IGRint			foundCnt1,  foundCnt2 ;
	TGRid			*foundIDs1, *foundIDs2 ;
	TGRid			srcID1, srcID2 ;
struct	OM_sd_chanselect	chn ;

SetProc( CheckMacroBy2parents ); Begin

	retFlag    = FALSE ;
	foundIDs1  = NULL ;
	foundIDs2  = NULL ;
	foundCnt1  = 0 ;
	foundCnt2  = 0 ;
	msgStr[0]  = '\0' ;
	macName[0] = '\0' ;

	// get channel
	sts = om$make_chanselect( channame	= "NDchildren.children" ,
				  p_chanselect	= &chn ) ;
	if( !(sts & 1) ) {
		printf("om$make_chanselect failed\n") ;
		goto wrapup;
	}

	sts = as$make_source (  go_grid = parentOE1->obj_id ,
				mod_env = &parentOE1->mod_env,
				as_grid = &srcID1 ) ;
	if ( !(sts & 1) || srcID1.objid == NULL_OBJID ) {
		__DBGpr_com("Problem sourcing parentOE");
		srcID1 = parentOE1->obj_id ;
	}

	sts = as$make_source (  go_grid = parentOE2->obj_id ,
				mod_env = &parentOE2->mod_env,
				as_grid = &srcID2 ) ;
	if ( !(sts & 1) || srcID2.objid == NULL_OBJID ) {
		__DBGpr_com("Problem sourcing parentOE");
		srcID2 = parentOE2->obj_id ;
	}


	// get parent1's children from the channel
	classid = OPP_nci_macro_class_id ;

	sts = VDGetGridsFromChan_of_Class (
                                        &msg,
                                        srcID1,
                                        &chn,
                                        classid,
                                        &foundCnt1,
                                        &foundIDs1 ) ;
	__DBGpr_int("foundCnt1", foundCnt1) ;

	// get parent2's children from the channel
	sts = VDGetGridsFromChan_of_Class (
                                        &msg,
                                        srcID2,
                                        &chn,
                                        classid,
                                        &foundCnt2,
                                        &foundIDs2 ) ;
	__DBGpr_int("foundCnt2", foundCnt2) ;

	for( i = 0; i < foundCnt1; i++ ) {
	  for( j = 0; j < foundCnt2; j++ ) {
	     if( ObjsIdentical( foundIDs1[i], foundIDs2[j] ) ) {
		GetMacroName ( foundIDs1[i], macName, msgStr ) ;
		if(
		    !strcmp( macName, "Bevel"    ) ||
		    !strcmp( macName, "EJ_Bevel" ) || 
		    !strcmp( macName, "Fab_Stock") ||
		    !strcmp( macName, "VA_Bevel" ) )
		{
			sprintf( msgStr, 
			      "Macro %s already exists", macName);
			retFlag = TRUE ;
			goto wrapup ;
		}
	     }
	  }	// for j
	}	// for i

wrapup:
	if( foundIDs1 ) _FREE( foundIDs1 ) ;
	if( foundIDs2 ) _FREE( foundIDs2 ) ;
End
	return retFlag ;
	
}


/************************************************************************
 * Check if a Bevel/Fab_Stock already exists on the curve,
 * but it won't work well if objs are in different files !
 */
IGRboolean  CheckMacroByParent( TGRobj_env	*parentOE ,	// in
				IGRchar		*msgStr )	// out
{
	IGRboolean		retFlag ;
	IGRstat			sts ;
	IGRlong			msg ;
	IGRint			i ;
	IGRchar			macName[128] ;
	GRclassid		classid ;
	IGRint			foundCnt ;
	TGRid			*foundIDs ;
	TGRid			srcID ;
struct	OM_sd_chanselect	chn ;

SetProc( CheckMacroByParent ); Begin

	retFlag    = FALSE ;
	foundIDs   = NULL ;
	foundCnt   = 0 ;
	msgStr[0]  = '\0' ;
	macName[0] = '\0' ;

	sts = as$make_source (  go_grid = parentOE->obj_id ,
				mod_env = &parentOE->mod_env,
				as_grid = &srcID ) ;
	if ( !(sts & 1) || srcID.objid == NULL_OBJID ) {
		__DBGpr_com("Problem sourcing parentOE");
		srcID = parentOE->obj_id ;
	}
	__DBGpr_obj("parentOE", parentOE->obj_id);
	__DBGpr_obj("srcID", srcID);


	// get channel
	sts = om$make_chanselect( channame	= "NDchildren.children" ,
				  p_chanselect	= &chn ) ;
	if( !(sts & 1) ) {
		__DBGpr_com("om$make_chanselect failed") ;
		goto wrapup;
	}

	// get objs from the channel
	classid = OPP_nci_macro_class_id ;
	sts = VDGetGridsFromChan_of_Class (
                                        &msg,
                                        srcID,
                                        &chn,
                                        classid,
                                        &foundCnt,
                                        &foundIDs ) ;
	__DBGpr_int("foundCnt", foundCnt) ;
	for( i = 0; i < foundCnt; i = i+1 ) {
		GetMacroName ( foundIDs[i], macName, msgStr ) ;
		if( !strcmp( macName, "Bevel"    ) )  continue;

		if(
		    !strcmp( macName, "Bevel"    ) ||
		    !strcmp( macName, "EJ_Bevel" ) || 
		    !strcmp( macName, "Fab_Stock") ||
		    !strcmp( macName, "VA_Bevel" ) )
		{
			sprintf( msgStr, 
			      "Macro %s already exists", macName);
			retFlag = TRUE ;
			goto wrapup ;
		}
	}

wrapup:
	if( foundIDs ) _FREE( foundIDs ) ;
End
	return retFlag ;
	
}


/************************************************************************
 * Check if the curve is from an edge of neat plate for EJ_Bevel and
 * Fab_Stock	
 */
IGRboolean  CheckEJcurve (	TGRobj_env	*neatPltOE ,	// in
				TGRobj_env	*crvOE,		// in
				IGRchar		*msgStr )	// out
{
	IGRboolean		retFlag ;
	IGRstat			sts ;
	IGRlong			msg ;
	IGRint			i ;
	IGRchar			macName[128] ;
	GRclassid		classid ;
	IGRint			foundCnt ;
	TGRid			*foundIDs ;
struct	OM_sd_chanselect	chn ;

SetProc( CheckEJcurve ); Begin

	retFlag    = FALSE ;
	foundIDs   = NULL ;
	foundCnt   = 0 ;
	msgStr[0]  = '\0' ;
	macName[0] = '\0' ;

	__DBGpr_obj("crvOE", crvOE->obj_id);
	__DBGpr_obj("neatPltOE", neatPltOE->obj_id);

     // Fisrt check if a bevel/Fab_Stock already exists on the curve,
	if( CheckMacroByParent( crvOE, msgStr ) ) {
		strcat( msgStr, " as curve's child");
		goto wrapup ;
	}

     // Then, check if the curve is from the neat plate
	__DBGpr_obj("crvOE", crvOE->obj_id);
	__DBGpr_obj("neatPltOE", neatPltOE->obj_id);

	// get channel
	sts = om$make_chanselect( channame	= "GRconnector.to_owners" ,
				  p_chanselect	= &chn ) ;
	if( !(sts & 1) ) {
		printf("om$make_chanselect failed\n") ;
		goto wrapup;
	}

	// get objs from the channel
	classid = OPP_nci_macro_class_id ;
	sts = VDGetGridsFromChan_of_Class (
                                        &msg,
                                        crvOE->obj_id,
                                        &chn,
                                        classid,
                                        &foundCnt,
                                        &foundIDs ) ;
	__DBGpr_int("foundCnt", foundCnt) ;
	if( !(sts&msg&1) || foundCnt < 1 ) {
		strcpy( msgStr, "Not an edge of neat plate") ;
		goto wrapup;
	}

	for( i = 0; i < foundCnt; i = i+1 ) {
		if( ObjsIdentical( neatPltOE->obj_id, foundIDs[i] ) ) {
			retFlag = TRUE ;
			goto wrapup ;
		}
	}

	strcpy( msgStr, "Invalid curve") ;
wrapup:
	if( foundIDs ) _FREE( foundIDs ) ;
	if( !retFlag ) {
		crvOE->obj_id.objid = NULL_OBJID ;
	}
End
	return retFlag ;
}


/****************************************************************/
/* Check if the curve is on designated surface of the plate	*/
IGRboolean  CheckCurve( IGRchar		*onSurf ,	// in
			TGRobj_env	*plateOE , 	// in
			TGRobj_env	*crvOE , 	// in
			IGRchar		*msgStr )	// out
{
	IGRboolean	retFlag ;
	IGRstat		sts ;
	IGRlong		msg ;
	TGRobj_env	surfOE ;
	TGRbsp_curve	*crv = NULL;
	TGRbsp_surface	*surfGeom = NULL;

	BSrc		rc ;
	IGRdouble	u, par1, par2, dist, delta ;
	IGRpoint	pnt[4],pt;
	IGRint		i, num_pts,cnt;

SetProc(CheckCurve); Begin
	
	retFlag		= FALSE ;
	crv		= NULL ;
	surfGeom	= NULL ;
	msgStr[0]	= '\0' ;
	num_pts		= 20 ;
	surfOE.obj_id.objid = NULL_OBJID ;

	vdobj$GetFoot (	objOE    = plateOE ,
			footName = onSurf,
			footOE   = &surfOE);

	if( surfOE.obj_id.objid == NULL_OBJID ) {
		printf("vdobj$GetFoot faile\n");
		goto wrapup;
	}

	vs$get_geometry (	msg		= &msg ,
				grobjId		= &surfOE.obj_id ,
				grobjEnv	= &surfOE.mod_env ,
				geometry	= &surfGeom);
	if ( !(msg&1) || surfGeom == NULL ) {
		printf("vs$get_geometry failed\n") ;
		goto wrapup;
	}

	vs$get_geometry (	msg		= &msg ,
				grobjId		= &crvOE->obj_id ,
				grobjEnv	= &crvOE->mod_env ,
				geometry	= &crv ) ;
	if( !(msg&1) ) {
		printf("vs$get_geometry failed\n");
		goto wrapup ;
	}

	delta = 1.0/(num_pts - 1) ;

	/* ---------------------------------------
	 * This tries to make sure have a curve near a plate surface
	 * But it gives really stange results in shell plates
	 * TR17770XXXX for test case, Unit 3372 
	 *
	 * Three of the 20 points return invalid nearest points
	 *
	 * As long as most are close then accept it
	 */
        cnt = 0;
	
	for( i = 0; i < num_pts; i++ ) {
		u = i*delta ;
		BScveval( crv, u, 0, pnt, &rc ) ;
		if ( BSERROR(rc) ) {
			goto wrapup ;
		}

		BSmdistptsf( &rc, surfGeom, pnt[0], &par1, &par2, pt, &dist) ;
		if ( BSERROR(rc) ) {
			goto wrapup ;
		}

		if( dist > GAP_TOL ) {
		//sprintf(msgStr,"Distance Curve Surface %.4f %.4f", dist,GAP_TOL);
		//printf("Distance %.2f\n",dist);
		//printf("Point 0 %8.2f %8.2f %8.2f\n",pnt[0][0],pnt[0][1],pnt[0][2]);
		//printf("Point 1 %8.2f %8.2f %8.2f\n",pt [0],   pt[1],    pt[2]);
		cnt++;
		
		// goto wrapup ;
		}

	}
	if (cnt > 10) {
	  sprintf(msgStr,"Curve not near plate");
	  // printf("Points out %d %d\n",cnt,i);
	  goto wrapup;
	}
	

	// Check if a bevel/Fab_Stock already exists on the curve,
	if( CheckMacroByParent( crvOE, msgStr ) ) {
		strcat( msgStr, " as curve's child");
		goto wrapup ;
	}

	retFlag = TRUE ;
wrapup:
	_FREE(crv) ;
	_FREE(surfGeom) ;
	if( !retFlag ) {
		crvOE->obj_id.objid = NULL_OBJID ;
	}
End
	return retFlag ;
 
}


/*****************************************************************/
void	DisplayGadgets( Form	form, 		// in
			IGRchar	*macStr )	// in
{
	IGRint	toggle ;
	IGRchar	macType ;

SetProc(DisplayGadgets); Begin

	macType = macStr[0] ;
	VSbvl_set_bevel_type( macType );

	switch( macType ) {

	case '1' :
	case 'F' :
		FIg_erase( form, PLATE1_BTN ) ;
		FIg_erase( form, PLATE1_FLD ) ;
		FIg_erase( form, PLATE2_BTN ) ;
		FIg_erase( form, PLATE2_FLD ) ;
		FIg_erase( form, EDGE1_BTN ) ;
		FIg_erase( form, EDGE1_FLD ) ;
		FIg_erase( form, EDGE2_BTN ) ;
		FIg_erase( form, EDGE2_FLD ) ;
		FIg_erase( form, POINT1_BTN ) ;
		FIg_erase( form, POINT2_BTN ) ;

		FIg_erase( form, VA_PLATE_BTN ) ;
		FIg_erase( form, VA_PLATE_FLD ) ;
		FIg_erase( form, VA_BASE_CRV_BTN ) ;
		FIg_erase( form, VA_BASE_CRV_FLD ) ;
		FIg_erase( form, VA_OFF_CRV_BTN ) ;
		FIg_erase( form, VA_OFF_CRV_FLD ) ;
		FIg_erase( form, VA_POINT_BTN ) ;

		FIg_display( form, EJ_PLATE_BTN ) ;
		FIg_display( form, EJ_PLATE_FLD ) ;
		FIg_display( form, EJ_CURVE_BTN ) ;
		FIg_display( form, EJ_CURVE_FLD ) ;
		FIg_display( form, EJ_POINT_BTN ) ;
		if( macType == '1' ) {
			FIg_set_text( form, MACRO_TYPE, "1 Plate" ) ;
			FIg_display( form, EJ_THICK_TEXT ) ;
			FIg_display( form, EJ_TOGGLE_INPUT ) ;
			FIg_get_state( form, EJ_TOGGLE_INPUT, &toggle ) ;
			if( toggle ) {
				FIg_erase  ( form, EJ_PLATE_IN ) ;
				FIg_erase  ( form, EJ_ADJPLATE_BTN ) ;
				FIg_display( form, EJ_THICK_IN ) ;
			}
			else {
				FIg_erase  ( form, EJ_THICK_IN ) ;
				FIg_display( form, EJ_PLATE_IN ) ;
				FIg_display( form, EJ_ADJPLATE_BTN ) ;
			}
		}
		else {
			FIg_set_text( form, MACRO_TYPE, "Fabrication Stock" ) ;
			FIg_erase ( form, EJ_THICK_TEXT ) ;
			FIg_erase ( form, EJ_TOGGLE_INPUT ) ;
			FIg_erase ( form, EJ_PLATE_IN ) ;
			FIg_erase ( form, EJ_ADJPLATE_BTN ) ;
			FIg_erase ( form, EJ_THICK_IN ) ;
		}

		break ;

	case '2' :
		FIg_set_text( form, MACRO_TYPE, "2 Plates" ) ;
		FIg_erase( form, EJ_PLATE_BTN ) ;
		FIg_erase( form, EJ_PLATE_FLD ) ;
		FIg_erase( form, EJ_CURVE_BTN ) ;
		FIg_erase( form, EJ_CURVE_FLD ) ;
		FIg_erase( form, EJ_THICK_TEXT ) ;
		FIg_erase( form, EJ_TOGGLE_INPUT ) ;
		FIg_erase( form, EJ_THICK_IN ) ;
		FIg_erase( form, EJ_PLATE_IN ) ;
		FIg_erase( form, EJ_ADJPLATE_BTN ) ;
		FIg_erase( form, EJ_POINT_BTN ) ;

		FIg_erase( form, VA_PLATE_BTN ) ;
		FIg_erase( form, VA_PLATE_FLD ) ;
		FIg_erase( form, VA_BASE_CRV_BTN ) ;
		FIg_erase( form, VA_BASE_CRV_FLD ) ;
		FIg_erase( form, VA_OFF_CRV_BTN ) ;
		FIg_erase( form, VA_OFF_CRV_FLD ) ;
		FIg_erase( form, VA_POINT_BTN ) ;

		FIg_display( form, PLATE1_BTN ) ;
		FIg_display( form, PLATE1_FLD ) ;
		FIg_display( form, PLATE2_BTN ) ;
		FIg_display( form, PLATE2_FLD ) ;
		FIg_display( form, EDGE1_BTN ) ;
		FIg_display( form, EDGE1_FLD ) ;
		FIg_display( form, EDGE2_BTN ) ;
		FIg_display( form, EDGE2_FLD ) ;
		FIg_display( form, POINT1_BTN ) ;
		FIg_display( form, POINT2_BTN ) ;

		break ;

	case 'V' :
	case 'v' :

		FIg_set_text( form, MACRO_TYPE, "Variable Plate" ) ;
		FIg_erase( form, EJ_PLATE_BTN ) ;
		FIg_erase( form, EJ_PLATE_FLD ) ;
		FIg_erase( form, EJ_CURVE_BTN ) ;
		FIg_erase( form, EJ_CURVE_FLD ) ;
		FIg_erase( form, EJ_THICK_TEXT ) ;
		FIg_erase( form, EJ_TOGGLE_INPUT ) ;
		FIg_erase( form, EJ_THICK_IN ) ;
		FIg_erase( form, EJ_PLATE_IN ) ;
		FIg_erase( form, EJ_ADJPLATE_BTN ) ;
		FIg_erase( form, EJ_POINT_BTN ) ;

		FIg_erase( form, PLATE1_BTN ) ;
		FIg_erase( form, PLATE1_FLD ) ;
		FIg_erase( form, PLATE2_BTN ) ;
		FIg_erase( form, PLATE2_FLD ) ;
		FIg_erase( form, EDGE1_BTN ) ;
		FIg_erase( form, EDGE1_FLD ) ;
		FIg_erase( form, EDGE2_BTN ) ;
		FIg_erase( form, EDGE2_FLD ) ;
		FIg_erase( form, POINT1_BTN ) ;
		FIg_erase( form, POINT2_BTN ) ;

		FIg_display( form, VA_PLATE_BTN ) ;
		FIg_display( form, VA_PLATE_FLD ) ;
		FIg_display( form, VA_BASE_CRV_BTN ) ;
		FIg_display( form, VA_BASE_CRV_FLD ) ;
		FIg_display( form, VA_OFF_CRV_BTN ) ;
		FIg_display( form, VA_OFF_CRV_FLD ) ;
		FIg_display( form, VA_POINT_BTN ) ;

		break ;
		
	}

	if( macType == 'F' ) {
		FIg_erase( form, BEVEL_TEXT ) ;
		FIg_erase( form, BEVEL_TYPE ) ;
	}
	else {
		FIg_display( form, BEVEL_TEXT ) ;
		FIg_display( form, BEVEL_TYPE ) ;
	}
	FIg_display( form, PROCESS_TEXT ) ;
	FIg_display( form, PROCESS_TYPE ) ;
	FIg_display( form, OFFSET_TEXT ) ;
	FIg_display( form, OFFSET_VALUE ) ;
	FIg_display( form, STOCK_TEXT ) ;
	FIg_display( form, STOCK_VALUE ) ;
	FIg_display( form, SHOW_BEVEL_BTN ) ;
	FIg_display( form, FONT_TEXT ) ;
	FIg_display( form, FONT_SIZE ) ;
End
	return ;
}


/************************************************************************/
/* Can be used to place EJ_Bevel or Fab_Stock macro			*/

IGRstat PlaceEJ_BevelMacro (	Form		form ,		// in
				TGRobj_env	*objOEs ,	// in
				IGRchar		*lblPntFlag,	// in
				TGRobj_env	*bvlMacOE, 	// out
				IGRchar		*msgStr )	// out
{
	IGRstat		retFlag, sts ;
	IGRlong		msg ;
	IGRint		attrCnt, i ;
	IGRchar		macName[128], macType[128] ;
	IGRdouble	offsetVal ;
	TGRbsp_curve	*bvlCrv ;
        struct GRid	crvID;
	BSrc		rc ;

SetProc(PlaceEJ_BevelMacro); Begin

	retFlag = 0 ;
	msgStr[0] = '\0' ;
	macName[0] = '\0' ;
	macType[0] = '\0' ;
	bvlCrv 	= NULL ;
	bvlMacOE->obj_id.objid = NULL_OBJID ;

	FIg_get_text( form, MACRO_TYPE, macType ) ;

	// Check input
	if( objOEs[E_PLATE].obj_id.objid == NULL_OBJID ) { 
		strcpy( msgStr, "Plate not input yet" ) ;
		goto wrapup ;
	}
	
	if( objOEs[E_CURVE].obj_id.objid == NULL_OBJID ) { 
		strcpy( msgStr, "Curve not input yet" ) ;
		goto wrapup ;
	}
	
	// Create attribute collector
	if( macType[0] == '1' ) attrCnt = MAX_ATTR1 ;
	else			attrCnt = MAX_ATTRf ;

	__DBGpr_str("lblPntFlag", lblPntFlag ) ;
	sts = CreateInputCollector (	form, 
					attrCnt, 
					"", 
					lblPntFlag, 
					&objOEs[E_ATTR] ) ;
	if( !sts || objOEs[E_ATTR].obj_id.objid == NULL_OBJID ) {
		printf("CreateInputCollector failed\n");
		goto wrapup ;
	}

	// Get offset value
	FIg_get_value( form, OFFSET_VALUE, &offsetVal ) ;

	// Get bevel curve to compute label points if user not input point
	if( lblPntFlag[0] == '0' ) {
		// get curve geometry
		vs$get_geometry(msg      = &msg ,
				grobjId  = &objOEs[E_CURVE].obj_id ,
				grobjEnv = &objOEs[E_CURVE].mod_env ,
				geometry = &bvlCrv ) ;

		VSbevelCheckForPartialCurve( objOEs[E_CURVE],
				bvlCrv, objOEs[E_CURVE].mod_env, &crvID );
		_FREE( bvlCrv ) ;

                vs$get_geometry(msg      = &msg ,
                                grobjId  = &crvID,
                                grobjEnv = &objOEs[E_CURVE].mod_env,
                                geometry = &bvlCrv ) ;

		vd_$bulk_delete( grids  = &crvID, 
				 theEnv = &bvlMacOE->mod_env  );

		sts = GetLabelPoint (	&objOEs[E_PLATE], 
					bvlCrv, 
					offsetVal, 
					&objOEs[E_POINT] ) ;
		if( !sts ) {
			printf("GetLabelPoint failed to get E_POINT\n") ;
			goto wrapup ;
		}
		__DBGpr_obj("objOEs[E_POINT]", objOEs[E_POINT].obj_id);
	}

	// Create Bevel macro
	if( macType[0] == '1' ) {
		strcpy( macName, "EJ_Bevel" ) ;
	}
	else if( macType[0] == 'F' ) {
		strcpy( macName, "Fab_Stock" ) ;
	}
	else {
		strcpy(msgStr, "Error for placing macro");
		printf("Error for placing macro\n");
		goto wrapup;
	}

	sts = CreateBevelMacro(macName,objOEs,MAX_TEMP1,lblPntFlag,bvlMacOE);
	if( !sts || bvlMacOE->obj_id.objid == NULL_OBJID ) {
		printf("CreateEJ_BevelMacro failed\n");
		strcpy(msgStr, "Failed to place EJ_BevelMacro");
		goto wrapup ;
	}
	__DBGpr_obj("bvlMacOE", bvlMacOE->obj_id);

	retFlag = 1 ;
wrapup:
	if( bvlCrv )  _FREE( bvlCrv ) ;
End
	return retFlag ;
}

/*****************************************************************/
IGRstat PlaceBevelMacro(Form		form ,		// in
			TGRobj_env	*objOEs ,	// in
			IGRchar		*lblPntFlag ,	// in
			TGRobj_env	*bvlMacOE, 	// out
			IGRchar		*msgStr )	// out
{
	IGRstat		retFlag, sts ;
	IGRlong		msg ;
	IGRint		i ;
	IGRdouble	offsetVal = 0;
	TGRobj_env	neatPltOE1,	neatPltOE2 ;
	TGRobj_env	*edgOEs1,	*edgOEs2 ;
	IGRint		edgCnt1,	edgCnt2 ;
	IGRint		attrCnt ;
	TGRobj_env	bvlCrvOE ;
	TGRbsp_curve	*bvlCrv ;
	BSrc		rc ;
struct	ACrg_coll	collAttrs[MAX_ATTRS] ;

SetProc(PlaceBevelMacro); Begin

	retFlag = 0 ;
	msgStr[0] = '\0' ;
	edgOEs1 = NULL ;
	edgOEs2 = NULL ;
        bvlCrv  = NULL ;
        bvlCrvOE.obj_id.objid = NULL_OBJID ;

	// check input objects

	if( objOEs[PLATE1].obj_id.objid == NULL_OBJID ) { 
		strcpy( msgStr, "Plate 1 not input yet" ) ;
		goto wrapup ;
	}
	
	if( objOEs[PLATE2].obj_id.objid == NULL_OBJID ) { 
		strcpy( msgStr, "Plate 2 not input yet" ) ;
		goto wrapup ;
	}
	
	if( ObjsIdentical (	objOEs[PLATE1].obj_id, 
				objOEs[PLATE2].obj_id ) ) {
		strcpy( msgStr, "2 identical plates not allowed." ) ;
		goto wrapup ;
	}
/*	
	if( CheckMacroBy2parents(&objOEs[PLATE1], &objOEs[PLATE2], msgStr)) {
		strcat( msgStr, " as a child of plate1 and plate2");
		goto wrapup ;
	}
*/

	if( objOEs[POINT1].obj_id.objid != NULL_OBJID &&
	    !PointIsOnPlane( &objOEs[POINT1], &objOEs[PLATE1] ) ) {
		strcpy( msgStr, "Point 1 is not on plate 1" );
		goto wrapup ;
	}

	if( objOEs[POINT2].obj_id.objid != NULL_OBJID &&
	    !PointIsOnPlane( &objOEs[POINT2], &objOEs[PLATE2] ) ) {
		strcpy( msgStr, "Point 2 is not on plate 2" );
		goto wrapup ;
	}

	sts = CreateInputCollector (	form ,
					attrCnt, 
					"", 
					lblPntFlag ,
					&objOEs[ATTRIN] ) ;
	if( !sts || objOEs[ATTRIN].obj_id.objid == NULL_OBJID ) {
		printf("CreateInputCollector failed\n");
		goto wrapup ;
	}

	// Get neat plates
	GetNeatPlate( &objOEs[PLATE1], &neatPltOE1) ;
	GetNeatPlate( &objOEs[PLATE2], &neatPltOE2) ;

	// Get neat edges  if needed
	if( objOEs[EDGE1].obj_id.objid == NULL_OBJID ) {
                sts = GetNeatEdges( &neatPltOE1, &edgOEs1, &edgCnt1 ) ;
                if( !sts )  {
			printf("GetNeatEdges() failed\n");
			goto wrapup ;
		}
        }
        else {
		edgOEs1 = _CALLOC( 1, TGRobj_env ) ;
		if( edgOEs1 == NULL ) goto wrapup ;
                edgOEs1[0] = objOEs[EDGE1] ;
                edgCnt1 = 1 ;
        }

	if( objOEs[EDGE2].obj_id.objid == NULL_OBJID ) {
                sts = GetNeatEdges( &neatPltOE2, &edgOEs2, &edgCnt2 ) ;
                if( !sts )  {
			printf("GetNeatEdges() failed\n");
			goto wrapup ;
		}
        }
        else {
		edgOEs2 = _CALLOC( 1, TGRobj_env ) ;
		if( edgOEs2 == NULL ) goto wrapup ;
                edgOEs2[0] = objOEs[EDGE2] ;
                edgCnt2 = 1 ;
        }

	// Get bevel edges if not input from user
	if( edgCnt1 > 1 || edgCnt2 > 1 ) {
                sts = VScreateMultipleBevels( form,
                                              objOEs, lblPntFlag,
                                              edgCnt1, edgOEs1,
                                              edgCnt2, edgOEs2 );

		sts = GetBevelEdges(	edgOEs1, edgCnt1, 
					edgOEs2, edgCnt2, 
					&objOEs[EDGE1], &objOEs[EDGE2] ) ;
		if( !sts ) {
			printf("GetBevelEdges() failed\n") ;
			strcpy(	msgStr,
			"No overlap found between edges or plates");
			objOEs[EDGE1].obj_id.objid = NULL_OBJID ;
			objOEs[EDGE2].obj_id.objid = NULL_OBJID ;
			goto wrapup ;
		}
	}

	if( ObjsIdentical( objOEs[EDGE1].obj_id, objOEs[EDGE2].obj_id) ) {
		gr$get_module_env (buffer = &objOEs[EDGE2].mod_env);
		vd_$grCopy(	msg	= &msg , 
				frObj	= &objOEs[EDGE1].obj_id ,
				frEnv	= &objOEs[EDGE1].mod_env ,
				toEnv	= &objOEs[EDGE2].mod_env ,
				toObj	= &objOEs[EDGE2].obj_id ) ;
		if( !(msg&1) ) {
			printf("vd_$grCopy failed\n") ;
			goto wrapup ;
		}
	}
	__DBGpr_obj("objOEs[EDGE1]", objOEs[EDGE1].obj_id) ;
	__DBGpr_obj("objOEs[EDGE2]", objOEs[EDGE2].obj_id) ;

	// Get bevel curve to compute label points if user not input point
	if ( lblPntFlag[0] == '0' || lblPntFlag[1] == '0' ) {
		sts = ConstructBevel (	&objOEs[EDGE1], 
					&objOEs[EDGE2], 
					&bvlCrvOE, 
					&bvlCrv ) ;
		if( !sts || bvlCrvOE.obj_id.objid == NULL_OBJID) {
			printf("ConstructBevel failed\n") ;
			strcpy(msgStr,
			"Edges or plates may not adjoin within tolerance");
			objOEs[EDGE1].obj_id.objid = NULL_OBJID ;
			objOEs[EDGE2].obj_id.objid = NULL_OBJID ;
			goto wrapup ;
		}
		// Delete bvlCrvOE, since we only need bvCrv so far and 
		// bvlCrvOE will be built in macro as macro input
		vdobj$Delete( objOE = &bvlCrvOE ) ;
		bvlCrvOE.obj_id.objid  = NULL_OBJID ;
	}

	// Get offset value
	FIg_get_value( form, OFFSET_VALUE, &offsetVal ) ;

	if( lblPntFlag[0] == '0' ) {
		sts = GetLabelPoint (	&objOEs[PLATE1], 
					bvlCrv, 
					offsetVal, 
					&objOEs[POINT1] ) ;
		if( !sts ) {
			printf("GetLabelPoint() failed\n") ;
			goto wrapup ;
		}
		__DBGpr_obj("objOEs[POINT1]", objOEs[POINT1].obj_id);
	}

	if( lblPntFlag[1] == '0' ) {
		sts = GetLabelPoint (	&objOEs[PLATE2], 
					bvlCrv, 
					-offsetVal, 
					&objOEs[POINT2] ) ;
		if( !sts ) {
			printf("GetLabelPoint() failed\n") ;
			goto wrapup ;
		}
		__DBGpr_obj("objOEs[POINT2]", objOEs[POINT2].obj_id);
	}

	sts = CreateBevelMacro("Bevel",objOEs,MAX_TEMP2,lblPntFlag,bvlMacOE);
	if( !sts || bvlMacOE->obj_id.objid == NULL_OBJID ) {
		printf("CreateBevelMacro() failed\n");
		goto wrapup ;
	}
	__DBGpr_obj("bvlMacOE", bvlMacOE->obj_id);


	retFlag = 1 ;
wrapup:
	_FREE( bvlCrv ) ;
	if( edgOEs1 ) _FREE( edgOEs1 ) ;
	if( edgOEs2 ) _FREE( edgOEs2 ) ;
End
	return retFlag ;
}

/****************************************************************************/
IGRstat PlaceVariable_BevelMacro (	Form		form ,		// in
					TGRobj_env	*objOEs ,	// in
					IGRchar		*lblPntFlag ,	// in
					TGRobj_env	*bvlMacOE ,	// out
					IGRchar		*msgStr )	// out
{
	IGRstat		retFlag ;
	IGRstat		sts ;
	IGRlong		msg ;
	IGRint		i ;
	IGRdouble	offsetVal ;
	IGRint		edgCnt1,	edgCnt2 ;
	TGRbsp_curve	*bvlCrv ;
	BSrc		rc ;

SetProc(PlaceVariable_BevelMacro); Begin

	retFlag = 0 ;
	msgStr[0] = '\0' ;
	bvlCrv  = NULL ;

	// Create attribute collector
	sts = CreateInputCollector (	form ,
				MAX_ATTRv, 
				"" , 
				lblPntFlag ,
				&objOEs[V_ATTR] ) ;
	if( !sts || objOEs[V_ATTR].obj_id.objid == NULL_OBJID ) {
		printf("CreateInputCollector() failed\n");
		goto wrapup ;
	}

	// Get offset value
	FIg_get_value( form, OFFSET_VALUE, &offsetVal ) ;

	// Get base curve to compute label points if user not input point
	if( lblPntFlag[0] == '0' ) {
		// get curve geometry
		vs$get_geometry(msg      = &msg ,
				grobjId  = &objOEs[V_BASE_CRV].obj_id ,
				grobjEnv = &objOEs[V_BASE_CRV].mod_env ,
				geometry = &bvlCrv ) ;

		sts = GetLabelPoint (	&objOEs[V_PLATE], 
					bvlCrv, 
					offsetVal, 
					&objOEs[V_POINT] ) ;
		if( !sts ) {
			printf("GetLabelPoint() failed to get V_POINT\n") ;
			goto wrapup ;
		}
		__DBGpr_obj("objOEs[V_POINT]", objOEs[V_POINT].obj_id);
	}

	sts = CreateBevelMacro("VA_Bevel",objOEs,MAX_TEMPv,lblPntFlag,bvlMacOE);
	if( !sts || bvlMacOE->obj_id.objid == NULL_OBJID ) {
		printf("CreateVariable_BevelMacro() failed\n");
		goto wrapup ;
	}
	__DBGpr_obj("bvlMacOE", bvlMacOE->obj_id);

	retFlag = 1 ;
wrapup:
	if( bvlCrv )  _FREE( bvlCrv ) ;
End
	return retFlag ;
}



/*****************************************************************/
FillInFormWithAttrs (	Form		form ,		// in
			TGRobj_env	*attrOE ,	// in
			IGRboolean	local ,		// in
		struct	ACrg_coll	*collAttrs ) 	// out
{
	IGRstat		retFlag = 0 ;
	IGRlong		msg ;
	IGRint		sts ;
	IGRint		attrCnt, i ;
	IGRint		toggle ;
	IGRchar		msgStr[128], macStr[128] ;

	SetProc(FillInFormWithAttrs); Begin

	msgStr[0] = '\0' ;
	macStr[0] = '\0' ;

        sts = om$send ( msg      = message  ACrg_collect.AClist_attribute (
                                                &msg ,
                                                MAX_ATTRS ,
                                                collAttrs ,
                                                &attrCnt ) ,
			senderid = NULL_OBJID ,
                        targetid = attrOE->obj_id.objid ,
                        targetos = attrOE->obj_id.osnum ) ;

        if( !(sts&msg&1) ) {
                printf("ACrg_collect.AClist_attribute failed\n");
                goto wrapup ;
        }

	i = 0 ;
	FIg_set_text( form, MACRO_TYPE, collAttrs[i].desc.value.att_txt) ;
	strcpy( macStr, collAttrs[i].desc.value.att_txt ) ;

      if( macStr[0] != 'F' ) {
        i = i + 1 ;
	FIg_set_text( form, BEVEL_TYPE, collAttrs[i].desc.value.att_txt) ;
      }

        i = i + 1 ;
	FIg_set_text( form, PROCESS_TYPE, collAttrs[i].desc.value.att_txt) ;

        i = i + 1 ;
	FIg_set_value( form, STOCK_VALUE, collAttrs[i].desc.value.att_exp) ;

        i = i + 1 ;
	FIg_set_value( form, OFFSET_VALUE, collAttrs[i].desc.value.att_exp) ;
	__DBGpr_str("collAttrs[i].name", collAttrs[i].name);
	__DBGpr_dbl("collAttrs[i].desc.value.att_exp", 
			collAttrs[i].desc.value.att_exp);
	__DBGpr_str("collAttrs[offset_value].desc.value.att_txt",
			collAttrs[i].desc.value.att_txt);
		
      if( macStr[0] == '1' ) {
        i = i + 1 ;
	FIg_get_state( form, EJ_TOGGLE_INPUT, &toggle ) ;
	if( toggle ) {
	   FIg_set_value( form, EJ_THICK_IN, collAttrs[i].desc.value.att_exp) ;
	}
	else {
	   FIg_set_value( form, EJ_PLATE_IN, collAttrs[i].desc.value.att_exp) ;
	}
      }

	DisplayGadgets( form, macStr ) ;

	if( !local ) {
		FIg_disable( form, FI_RESET ) ;
		FIg_disable( form, FI_EXECUTE ) ;
		FIg_disable( form, FI_ACCEPT ) ;
		FIg_disable( form, SHOW_BEVEL_BTN ) ;
		FIg_disable( form, MACRO_TYPE ) ;
		FIg_disable( form, BEVEL_TYPE ) ;
		FIg_disable( form, PROCESS_TYPE ) ;
		FIg_disable( form, STOCK_VALUE ) ;
		FIg_disable( form, OFFSET_VALUE ) ;
		FIg_disable( form, EJ_TOGGLE_INPUT) ;
		FIg_disable( form, EJ_THICK_IN) ;
		FIg_disable( form, EJ_PLATE_IN) ;
	}

	retFlag = 1 ;
wrapup: 
End
	return retFlag ;
}

/********************************************************************/
IGRstat FillInFormForEJ_Bevel (	Form		form ,		// in
				TGRobj_env	*bvlMacOE,	// in
			struct	ACrg_coll	*collAttrs,	// out
				TGRobj_env	*oldOEs,	// out
				IGRchar		*oldPntFlag )	// out
{
	IGRstat		retFlag ;
	IGRint		sts ;
	IGRint		i, tempCnt ;
	IGRint		attrCnt ; 
	IGRchar		msgStr[128], macStr[128], tmpStr[128] ;
	TGRmd_env	objENV ;
	IGRboolean	local ;

SetProc(FillInFormForEJ_Bevel); Begin

	retFlag	= 0 ;
	msgStr[0] = '\0' ;
	macStr[0] = '\0' ;

	gr$get_module_env (buffer = &objENV);

	GetMacroParents(bvlMacOE, oldOEs, &tempCnt ) ;

	tmpStr[0] = '\0' ;
	CheckForProperName( &oldOEs[E_PLATE], FALSE, tmpStr, msgStr ) ;
	FIg_set_text( form, EJ_PLATE_FLD, tmpStr ) ;

	tmpStr[0] = '\0' ;
	CheckForProperName( &oldOEs[E_CURVE], FALSE, tmpStr, msgStr ) ;
	FIg_set_text( form, EJ_CURVE_FLD, tmpStr ) ;

	local = ( bvlMacOE->obj_id.osnum == 2 ) ;
	sts = FillInFormWithAttrs ( form, &oldOEs[E_ATTR], local, collAttrs) ;
	strcpy( oldPntFlag, collAttrs[E_offset_value].desc.value.att_txt ) ;

	if( !local ) {
		FIg_disable( form, EJ_PLATE_BTN );
		FIg_disable( form, EJ_PLATE_FLD );
		FIg_disable( form, EJ_CURVE_BTN );
		FIg_disable( form, EJ_CURVE_FLD );
		FIg_disable( form, EJ_POINT_BTN );
	}

	retFlag = 1 ;
wrapup: 
End
	return retFlag ;
}

/*****************************************************************/
IGRstat FillInFormForBevel (	Form		form ,		// in
				TGRobj_env	*bvlMacOE,	// in
			struct	ACrg_coll	*collAttrs,	// out
				TGRobj_env	*oldOEs ,	// out
				IGRchar		*oldPntFlag )	// out
{
	IGRstat		retFlag ;
	IGRint		sts ;
	IGRint		i, tempCnt ;
	IGRint		attrCnt ; 
	IGRchar		msgStr[128], macStr[128], tmpStr[128] ;
	TGRmd_env	objENV ;
	IGRboolean	local ;

SetProc(FillInFormForBevel); Begin

	retFlag = 0 ;
	msgStr[0] = '\0' ;
	macStr[0] = '\0' ;
	tmpStr[0] = '\0' ;

	gr$get_module_env (buffer = &objENV);

	GetMacroParents(bvlMacOE, oldOEs, &tempCnt ) ;

	CheckForProperName( &oldOEs[PLATE1], FALSE, tmpStr, msgStr ) ;
	FIg_set_text( form, PLATE1_FLD, tmpStr ) ;

	CheckForProperName( &oldOEs[PLATE2], FALSE, tmpStr, msgStr ) ;
	FIg_set_text( form, PLATE2_FLD, tmpStr ) ;

	CheckForProperName( &oldOEs[EDGE1], FALSE, tmpStr, msgStr );
	FIg_set_text( form, EDGE1_FLD, tmpStr ) ;

	CheckForProperName( &oldOEs[EDGE2], FALSE, tmpStr, msgStr ) ;
	FIg_set_text( form, EDGE2_FLD, tmpStr ) ;

	local = ( bvlMacOE->obj_id.osnum == 2 ) ;
	sts = FillInFormWithAttrs ( form, &oldOEs[ATTRIN], local, collAttrs ) ;
	strcpy( oldPntFlag, collAttrs[offset_value].desc.value.att_txt ) ;
	__DBGpr_str("PntFlag", collAttrs[offset_value].desc.value.att_txt);

	if( !local ) {
		FIg_disable( form, PLATE1_BTN );
		FIg_disable( form, PLATE1_FLD );
		FIg_disable( form, PLATE2_BTN );
		FIg_disable( form, PLATE2_FLD );
		FIg_disable( form, EDGE1_BTN );
		FIg_disable( form, EDGE1_FLD );
		FIg_disable( form, EDGE2_BTN );
		FIg_disable( form, EDGE2_FLD );
		FIg_disable( form, POINT1_BTN );
		FIg_disable( form, POINT2_BTN );
	}

	retFlag = 1 ;
wrapup: 
End
	return retFlag ;
}

/****************************************************************************/
IGRstat FillInFormForVariable_Bevel (	Form		form ,		// in
					TGRobj_env	*bvlMacOE,	// in
				struct	ACrg_coll	*collAttrs,	// out
					TGRobj_env	*oldOEs ,	// out
					IGRchar		*oldPntFlag )	// out
{
	IGRstat		retFlag ;
	IGRint		sts ;
	IGRint		i, tempCnt ;
	IGRint		attrCnt ; 
	IGRchar		msgStr[128], macStr[128], tmpStr[128] ;
	TGRmd_env	objENV ;
	IGRboolean	local ;

SetProc(FillInFormForVariable_Bevel); Begin

	retFlag = 0 ;
	msgStr[0] = '\0' ;
	macStr[0] = '\0' ;
	tmpStr[0] = '\0' ;

	gr$get_module_env (buffer = &objENV);

	GetMacroParents(bvlMacOE, oldOEs, &tempCnt ) ;

	CheckForProperName( &oldOEs[V_PLATE], FALSE, tmpStr, msgStr ) ;
	FIg_set_text( form, VA_PLATE_FLD, tmpStr ) ;

	CheckForProperName( &oldOEs[V_BASE_CRV], FALSE, tmpStr, msgStr ) ;
	FIg_set_text( form, VA_BASE_CRV_FLD, tmpStr ) ;

	CheckForProperName( &oldOEs[V_OFF_CRV], FALSE, tmpStr, msgStr );
	FIg_set_text( form, VA_OFF_CRV_FLD, tmpStr ) ;

	local = ( bvlMacOE->obj_id.osnum == 2 ) ;
	sts = FillInFormWithAttrs ( form, &oldOEs[V_ATTR], local, collAttrs) ;
	strcpy( oldPntFlag, collAttrs[V_offset_value].desc.value.att_txt ) ;

	if( !local ) {
		FIg_disable( form, VA_PLATE_BTN );
		FIg_disable( form, VA_PLATE_FLD );
		FIg_disable( form, VA_BASE_CRV_BTN );
		FIg_disable( form, VA_BASE_CRV_FLD );
		FIg_disable( form, VA_OFF_CRV_BTN );
		FIg_disable( form, VA_OFF_CRV_FLD );
		FIg_disable( form, VA_POINT_BTN );
	}

	retFlag = 1 ;
wrapup: 
End
	return retFlag ;
}

/*****************************************************************/
IGRstat UpdateMacro(	TGRobj_env      *bvlMacOE ,	// in
			TGRobj_env	*objOEs ,	// in
			IGRint		 objCnt ,	// in
			IGRchar		*lblPntFlag ) 	// in
{
	IGRstat		retFlag ;
	IGRint		sts, msg, i;
	IGRint      	cn_type;
	IGRint      	tempCnt;
	TGRid		oldTempIDs[MAX_TEMPS] ;
	TGRid		newTempIDs[MAX_TEMPS] ;
	TGRid		pntID1, pntID2 ;
	IGRchar		macName[128], msgStr[128] ;
	TGRmd_env	objENV ;


SetProc(UpdateMacro); Begin

	retFlag = 0 ;
	msgStr[0] = '\0' ;
	macName[0] = '\0' ;
	cn_type = ND_COMP ;
	sts = gr$get_module_env(buffer = &objENV ) ;

	GetMacroName ( bvlMacOE->obj_id, macName, msgStr ) ;

	__DBGpr_obj("bvlMacOE", bvlMacOE->obj_id ) ;

	for( i = 0;  i < objCnt;  i++ ) {
                oldTempIDs[i].objid = NULL_OBJID ;
		sts = om$send ( msg = message ACcpx.ACfind_exp_temp_obj ( 
						&msg , 
						 i , 
						&oldTempIDs[i] ) ,
				senderid = NULL_OBJID ,
				targetid = bvlMacOE->obj_id.objid,
				targetos = bvlMacOE->obj_id.osnum );
		if ( !(sts&msg&1) || oldTempIDs[i].objid == NULL_OBJID ) {
                        printf("Problem to get parents of macro \n");
                        goto wrapup ;
                }

                newTempIDs[i].objid = NULL_OBJID ;
                sts = as$make_source (  go_grid =  objOEs[i].obj_id ,
                                        mod_env = &objOEs[i].mod_env,
                                        as_grid = &newTempIDs[i] ) ;
                if ( !(sts & 1) || newTempIDs[i].objid == NULL_OBJID ) {
                        printf("Problem sourcing parent \n");
                        goto wrapup ;
                }
        }

	// Set source point state to deletable if points were from computing 
	// instead of input from user
	pntID1.objid = pntID2.objid = NULL_OBJID ;
	switch( macName[0] ) {
		case 'E':
		case 'F':
			pntID1 = newTempIDs[E_POINT] ;
			break ;
		case 'B':
			pntID1 = newTempIDs[POINT1] ;
			pntID2 = newTempIDs[POINT2] ;
			break ;
		case 'V':
			pntID1 = newTempIDs[V_POINT] ;
			break ;
	}
	if( lblPntFlag[0] == '0' ) {
		sts = om$send ( msg	 = message NDnode.NDchg_state ( 
						ND_DEL_NO_CH|ND_WAIT_DEL, 
						ND_DEL_NO_CH|ND_WAIT_DEL ),
				senderid = NULL_OBJID,
				targetid = pntID1.objid,
				targetos = pntID1.osnum );
	}
	if( lblPntFlag[1] == '0' ) {
		sts = om$send ( msg	 = message NDnode.NDchg_state ( 
						ND_DEL_NO_CH|ND_WAIT_DEL, 
						ND_DEL_NO_CH|ND_WAIT_DEL ),
				senderid = NULL_OBJID,
				targetid = pntID2.objid,
				targetos = pntID2.osnum );
	}

	sts = om$send(msg = message  NDnode.NDchange_connect(
					objCnt ,
					oldTempIDs ,
					newTempIDs ) , 
			senderid = NULL_OBJID ,
			targetid = bvlMacOE->obj_id.objid ,
			targetos = bvlMacOE->obj_id.osnum ) ;
	if( !sts ) {
		printf("NDnode.NDchange_connect failed\n");
	}

	/* Put the modified occurence in the batch */
	nd$wait_batch ( type       = GR_GEOM_POSTED,
                        nb_obj     = 1,
                        l_object   = &bvlMacOE->obj_id,
                        l_obj_info = &cn_type );

	/* Execute immediately */
	nd$exec_batch();

	sts = om$send(msg = message GRgraphics.GRxform(
					(long*)&msg ,
					&objENV,
					&bvlMacOE->mod_env.md_env.matrix_type ,
					bvlMacOE->mod_env.md_env.matrix ,
					&bvlMacOE->obj_id.objid ) ,
			senderid = NULL_OBJID ,
			targetid = bvlMacOE->obj_id.objid ,
			targetos = bvlMacOE->obj_id.osnum ) ;

	if( !(sts&msg&1) || bvlMacOE->obj_id.objid == NULL_OBJID ) {
		printf("GRgraphics.GRxform failed\n");
		goto wrapup ;
	}


	retFlag = 1 ;
wrapup:
End
	return retFlag ;
}

/****************************************************************************/
IGRstat	ShowBevel (	IGRchar		*macType,	// in
			TGRobj_env	*objOEs,	// in
			IGRchar		*msgStr )	// out
{
	IGRstat		retFlag = 0, sts ;
	TGRobj_env	neatPltOE1,	neatPltOE2 ;
	TGRobj_env	edgeOE1,	edgeOE2 ;
	TGRobj_env	*edgOEs1,	*edgOEs2 ;
	IGRint		edgCnt1,	edgCnt2 ;
	TGRobj_env	bvlCrvOE ;
	TGRbsp_curve	*bvlCrv ;
	TGRsymbology	symb, symb0 ;
	IGRint		symbFlag = 0 ;
	BSrc		rc ;

SetProc(ShowBevel); Begin

	bvlCrvOE.obj_id.objid = NULL_OBJID ;
	bvlCrv  = NULL ;
	edgOEs1 = NULL ;
	edgOEs2 = NULL ;
	msgStr[0] = '\0';

	if( !strcmp( macType, "" ) ) {
		strcpy(msgStr, "Missing Macro Type") ;
		goto wrapup ;
	}

	VDahGetActiveSymbology(&symb0);
	VDahGetActiveSymbology(&symb);
	symb.display_attr.weight = 2 ;
	VDahSetActiveSymbology(&symb) ;
	symbFlag = 1 ;

	__DBGpr_str("macro type", macType);

	switch( macType[0] ) {

	case '1':
	case 's':
	case 'S':
		if( objOEs[E_CURVE].obj_id.objid == NULL_OBJID ) { 
			strcpy( msgStr, "Missing Curve input" ) ;
			goto wrapup ;
		}
		bvlCrvOE = objOEs[E_CURVE] ;
	
		break ;
	case '2':
		if (	objOEs[PLATE1].obj_id.objid == NULL_OBJID || 
			objOEs[PLATE2].obj_id.objid == NULL_OBJID ) {
			strcpy( msgStr, "Missing plates");
			goto wrapup ;
		}
	
		if( ObjsIdentical (	objOEs[PLATE1].obj_id, 
					objOEs[PLATE2].obj_id ) ) {
			strcpy( msgStr, "2 identical plates not allowed." ) ;
			goto wrapup ;
		}
	
		// Get neat plates
		GetNeatPlate( &objOEs[PLATE1], &neatPltOE1) ;
		GetNeatPlate( &objOEs[PLATE2], &neatPltOE2) ;

		// Get neat edges  if needed
		if( objOEs[EDGE1].obj_id.objid == NULL_OBJID ) {
			sts = GetNeatEdges( &neatPltOE1, &edgOEs1, &edgCnt1 ) ;
			if( !sts )  {
				printf("GetNeatEdges() 1 failed\n");
				goto wrapup ;
			}
        	}
		else {
			edgOEs1 = _CALLOC( 1, TGRobj_env );
			if( edgOEs1 == NULL ) goto wrapup ;
			edgOEs1[0] = objOEs[EDGE1] ;
			edgCnt1 = 1 ;
		}

		if( objOEs[EDGE2].obj_id.objid == NULL_OBJID ) {
			sts = GetNeatEdges( &neatPltOE2, &edgOEs2, &edgCnt2 ) ;
			if( !sts )  {
				printf("GetNeatEdges() 2 failed\n");
				goto wrapup ;
			}
		}
		else {
			edgOEs2 = _CALLOC( 1, TGRobj_env );
			if( edgOEs2 == NULL ) goto wrapup ;
			edgOEs2[0] = objOEs[EDGE2] ;
			edgCnt2 = 1 ;
		}

		// Get bevel edges if not input from user
		if( edgCnt1 > 1 || edgCnt2 > 1 ) {
			sts = GetBevelEdges(	edgOEs1, edgCnt1, 
						edgOEs2, edgCnt2, 
						&edgeOE1, &edgeOE2);
			if( !sts ) {
				printf("GetBevelEdges() failed\n") ;
				strcpy(	msgStr,
				"No overlap found between edges or plates");
				goto wrapup ;
			}
		}

		sts = ConstructBevel (	&edgeOE1, 
					&edgeOE2, 
					&bvlCrvOE, 
					&bvlCrv ) ;
		if( !sts || bvlCrvOE.obj_id.objid == NULL_OBJID) {
			printf("ConstructBevel() failed in commad\n") ;
			strcpy(msgStr,
			"Edges or plates may not adjoin within tolerance");
			goto wrapup ;
		}

		break ;
	case 'v':
	case 'V':
		if( objOEs[V_BASE_CRV].obj_id.objid == NULL_OBJID ) { 
			strcpy( msgStr, "Missing Base Curve" ) ;
		}
		bvlCrvOE = objOEs[V_BASE_CRV] ;

		if( objOEs[V_OFF_CRV].obj_id.objid == NULL_OBJID ) { 
			strcpy( msgStr, "Missing Offset Curve" ) ;
		}

		gr$display_object (	object_id = &objOEs[V_OFF_CRV].obj_id,
					md_env    = &objOEs[V_OFF_CRV].mod_env,
					mode      = GRhd ) ;
		break ;
	default:
		strcpy(msgStr, "Invalid Macro Type") ;
		goto wrapup ;
	}

	gr$display_object (	object_id = &bvlCrvOE.obj_id ,
				md_env    = &bvlCrvOE.mod_env ,
				mode      = GRhd ) ;

	if( macType[0] == '2' ) vdobj$Delete( objOE = &bvlCrvOE ) ;

	retFlag = 1 ;
wrapup:
	if(symbFlag) VDahSetActiveSymbology(&symb0) ;
	if( edgOEs1 ) _FREE( edgOEs1 ) ;
	if( edgOEs2 ) _FREE( edgOEs2 ) ;

	_FREE( bvlCrv );
End
	return retFlag ;
}

/****************************************************************************/
IGRstat CheckIfCurveBelongsToNeatPlate( struct GRobj_env	*Edge,
					struct GRobj_env	*NeatPlate )
{
IGRlong			sts;
IGRint 			retFlag=0 ;
struct GRid		source_obj;
struct GRobj_env 	parent;

  as$make_source ( go_grid = Edge->obj_id,
		   mod_env = &Edge->mod_env,
		   as_grid = &source_obj );

  if( !vd_$is_ancestry_valid( object  = &source_obj,
                              classid = OPP_ACpretend_class_id ) )
     goto wrapup;

  sts = om$send( msg      = message ACpretend.ACfind_parent(
			&parent.obj_id,
			&parent.mod_env.md_env.matrix_type,
			parent.mod_env.md_env.matrix ),
	senderid = NULL_OBJID,
	targetid = source_obj.objid,
	targetos = source_obj.osnum  );
  if( !(sts&1) ) goto wrapup;

  if( parent.obj_id.objid == NeatPlate->obj_id.objid &&
      parent.obj_id.osnum == NeatPlate->obj_id.osnum	)  retFlag = 1 ;

wrapup:
 return retFlag;
}


IGRlong VSbev_ReadSetupFile( Form       form )
{
IGRlong       retFlag = 0;
FILE          *fileptr;
IGRint        col, rowThk, rowStk, rowFont, pos, sts, nrows, i;
IGRchar       buf[256], *p=NULL, text[MAX_FLD_LEN];

  VSbev_ReadSetupProcessSpec( form, BEVEL_TYPE, PROCESS_TYPE );

  rowThk  = 0;
  rowStk  = 0;
  rowFont = 0;

  // Get the active column
  FIfld_set_list_num_rows( form, EJ_THICK_IN, 0, rowThk );
  FIfld_set_list_num_rows( form, STOCK_VALUE, 0, rowStk );
  FIfld_set_list_num_rows( form, FONT_SIZE, 0, rowFont );

  fileptr = NULL ;
  fileptr = VSbev_OpenBevelSetupFile();
  if(fileptr == NULL) goto wrapup;

  // Cycle through
  while(fgets(buf,sizeof(buf),fileptr)) {

#ifdef  vdsDEBUG
        printf(" >%s\n", buf );
#endif

      if(!strncmp(buf,"@ADJTHK ", 8)){

        buf[strlen(buf)-1] = '\0';
        strcpy(buf,buf+1);
        for(i=0;buf[i]!=' ' && i<250 ;i++);
        p = &buf[i+1];

        vdfrm$SetListText(form   = form,
                          gadget = EJ_THICK_IN,
                          row    = rowThk,
                          txt    = p);
        rowThk++;
        continue ;
      }

      if(!strncmp(buf,"@STOCK ", 7)){

        buf[strlen(buf)-1] = '\0';
        strcpy(buf,buf+1);
        for(i=0;buf[i]!=' ' && i<250 ;i++);
        p = &buf[i+1];

        vdfrm$SetListText(form   = form,
                          gadget = STOCK_VALUE,
                          row    = rowStk,
                          txt    = p);
        rowStk++;
        continue ;
      }

      if(!strncmp(buf,"@FONTSIZE ", 10)){

        buf[strlen(buf)-1] = '\0';
        strcpy(buf,buf+1);
        for(i=0;buf[i]!=' ' && i<250 ;i++);
        p = &buf[i+1];

#ifdef  vdsDEBUG
        printf("S>%s\n", buf );
#endif

        vdfrm$SetListText(form   = form,
                          gadget = FONT_SIZE,
                          row    = rowFont,
                          txt    = p);
        rowFont++;
        continue ;
      }
  }

  FIfld_set_list_num_rows( form, STOCK_VALUE, 0, rowStk );
  FIfld_set_list_num_rows( form, FONT_SIZE, 0, rowFont );
  FIfld_set_list_num_rows( form, EJ_THICK_IN, 0, rowThk );

  fclose(fileptr);
  retFlag = 1;

wrapup:

  if(retFlag == 0)
    printf("Reading setup file failed\n");
  return retFlag;

} // VSbev_ReadSetupFile


IGRlong	  VSbvlChange_feet( struct GRid		*Bevel,
			    int			attr_index    )
{
IGRlong			sts, msg, ind=OM_K_MAXINT;
IGRint 			i, feet_count = 0 ;
struct GRid		Comp, *feet_list=NULL;
OM_S_OBJECT_LINKAGE     *Clist=NULL;

  sts = om$get_channel_count ( osnum        = Bevel->osnum,
                               objid        = Bevel->objid,
                               p_chanselect = &AS_to_comp,
                               count        = ( OMuint * )&feet_count );

  if( !feet_count ) goto wrapup;
  if( !(feet_list = _MALLOC( feet_count, struct GRid )) ) 
		vd_$mem_fail(msg=&msg);

  if( !( Clist = _CALLOC( feet_count, OM_S_OBJECT_LINKAGE )) )
                vd_$mem_fail(msg=&msg);


  om$get_channel_objects ( osnum        = Bevel->osnum,
			   objid	= Bevel->objid,
			   p_chanselect = &AS_to_comp,
			   list         = Clist,
			   size         = feet_count,
			   count        = (OMuint *)&feet_count );
  for( i=0; i<feet_count; ++i )
  {
	feet_list[i].objid = Clist[i].S_objid;	
	feet_list[i].osnum = Clist[i].osnum ;
  }

  if( !vd_$is_ancestry_valid( object  = &feet_list[0],
			      classid = OPP_ACrg_collect_class_id ) )
     goto wrapup;

  for( i=0; i<feet_count; ++i )
  {
        sts = om$send(msg = message GRconnector.GRdisconn(
                                        &msg, Bevel ),
                        senderid = NULL_OBJID,
                        targetid = feet_list[i].objid,
                        targetos = feet_list[i].osnum  );
  }

  for( i=0; i<attr_index; ++i )
  {
     sts = om$send(msg = message GRconnector.GRrigidconn(
                                &msg, Bevel, &ind ),
                        senderid = NULL_OBJID,
                        targetid = feet_list[i+1].objid,
                        targetos = feet_list[i+1].osnum  );
  }
  sts = om$send(msg = message GRconnector.GRrigidconn(
                                &msg, Bevel, &ind ),
                        senderid = NULL_OBJID,
                        targetid = feet_list[0].objid,
                        targetos = feet_list[0].osnum  );

  for( i=attr_index+1; i<feet_count; ++i )
  {
     sts = om$send(msg = message GRconnector.GRrigidconn(
                                &msg, Bevel, &ind ),
                        senderid = NULL_OBJID,
                        targetid = feet_list[i].objid,
                        targetos = feet_list[i].osnum  );
  }

wrapup:
  _FREE( feet_list );
  _FREE( Clist     );
  return 1;
}

IGRlong   VSbvlAllChangeFeet()
{
IGRint		i, index, nb_mac=0;
IGRlong 	sts, msg;
IGRchar         *macDef=NULL;
GRspacenum	cur_osnum;
GRclassid	cls_id=OPP_nci_macro_class_id;
GRobjid		*macro_list=NULL;
struct GRid	bevelId, defId;

  ex$get_cur_mod ( osnum = &cur_osnum );
  sts = VDpms_findall_ancestryobjects( 	cur_osnum, 1, &cls_id,
					&nb_mac, NULL );
  if( !nb_mac ) return 0;

  if( !(macro_list = _MALLOC( nb_mac, GRobjid )) )
                vd_$mem_fail(msg=&msg)  ;

  sts = VDpms_findall_ancestryobjects(  cur_osnum, 1, &cls_id,
                                        &nb_mac, macro_list );

  for( i=0; i<nb_mac; ++i )
  {
      bevelId.objid = macro_list[i] ;
      bevelId.osnum = cur_osnum ;

      sts = om$send(  msg      = message ACcpx.find_macro( &defId ),
                     senderid = NULL_OBJID,
                     targetid = bevelId.objid,
                     targetos = bevelId.osnum  );
      if( !(sts&1) ) continue;

      sts = om$send(  msg      = message ACcpx_defn.ACgive_name( &macDef ),
                     senderid = NULL_OBJID,
                     targetid = defId.objid,
                     targetos = defId.osnum  );
      if( !(sts&1) )  continue;

      if( !strcmp( macDef, "Bevel" ) ) 			index = 1 ;
      else if( !strcmp( macDef, "EJ_Bevel" ) )		index = 1 ;
      else if( !strcmp( macDef, "VA_Bevel" ) )  	index = 2 ;
      else if( !strcmp( macDef, "Fab_Stock" ) )		index = 1 ;
      else continue;	

      VSbvlChange_feet( &bevelId, index );
  }

wrapup:
  _FREE( macro_list );
  return sts;
}

end implementation Root;

