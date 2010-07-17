/* $Id $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSmkcontedges.I
 *
 * Description: Contains a function to retrieve the external edges of
 *		a set of plates and their directions.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY   AUTHOR       		DESCRIPTION
 *      07/18/00   Rama Rao / Jayadev          	File Creation
 *      10/16/00   ah                           Added env to VDdrawCurve
 *************************************************************************/

class implementation VDSroot;

#include <math.h>
#include "bserr.h"
#include "bsmdstptcv.h"
#include "bscveval.h"
#include "bscv_copy.h"
#include "bsdistptpt.h"
#include "bspartofcv.h"
#include "bsbasisvect.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include  "AS_status.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDsa.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "vsplatedef.h"
#include "v_geommacros.h"
#include "vsdbgmacros.h"

#define vdsDEBUG        1
#define vdserrDEBUG     1

/* #define DEBUG 1 */

/* Edge Plane */
#define XY 0
#define YZ 1
#define ZX 2

/* Edge parallel to */
#define X 0
#define Y 1
#define Z 2

/* Directions */
#define AFT     	1
#define FWD     	2
#define IB      	3
#define OB      	4
#define DWN     	5
#define UPP     	6

extern  void            qsort();
extern  int		VSvertexCmp();
extern  GRclassid       OPP_EMSplane_class_id, OPP_VSplate_class_id;

from    GRlinear        import  GRgetpolyline;	 
from    EMSplane        import  EMplane;

static IGRint VSgmSame_point( IGRdouble  *pt1,
		     	      IGRdouble  *pt2,
		     	      IGRdouble  tol   )
{
  if (
      ((pt1[0] - pt2[0] <= tol) && (pt1[0] - pt2[0] >= -tol)) &&
      ((pt1[1] - pt2[1] <= tol) && (pt1[1] - pt2[1] >= -tol)) &&
      ((pt1[2] - pt2[2] <= tol) && (pt1[2] - pt2[2] >= -tol))
     ) {
      return 1;
    }
  else return 0;
}

IGRlong	  VSdotProduct( IGRlong			*msg,
			struct GRobj_env	*crv1,
			struct GRobj_env        *crv2,
			IGRdouble		gap_tol,
			IGRdouble		*dotp )
{
IGRlong			sts, rc;
IGRdouble		mdist, par1, par2;
IGRpoint		spt1, ept1, spt2, ept2, pt1, pt2, base, vec1[2],vec2[2];
struct IGRbsp_curve	*cv1_geom=NULL, *cv2_geom=NULL;

   sts = vd_$get_geometry( msg      = msg,
                           grobjId  = &crv1->_grid,
                           grobjEnv = &crv1->mod_env,
                           geometry = &cv1_geom ) ;
   if( !(sts&1&(*msg)) ) goto wrapup;

   sts = vd_$get_geometry( msg      = msg,
                           grobjId  = &crv2->_grid,
                           grobjEnv = &crv2->mod_env,
                           geometry = &cv2_geom ) ;
   if( !(sts&1&(*msg)) ) goto wrapup;

   MAbcendpts( &rc, cv1_geom, spt1, ept1 );
   MAbcendpts( &rc, cv2_geom, spt2, ept2 );

   if( VSgmSame_point( spt1, spt2, gap_tol ) )          
   { dblcpy( pt1, spt1, 3 );  dblcpy( pt2, spt2, 3 ); }
   else if( VSgmSame_point( spt1, ept2, gap_tol ) )   
   { dblcpy( pt1, spt1, 3 );  dblcpy( pt2, ept2, 3 ); }
   else if( VSgmSame_point( ept1, spt2, gap_tol ) )   
   { dblcpy( pt1, ept1, 3 );  dblcpy( pt2, spt2, 3 ); }
   else if( VSgmSame_point( ept1, ept2, gap_tol ) ) 
   { dblcpy( pt1, ept1, 3 );  dblcpy( pt2, ept2, 3 ); }

   BSmdstptcv( cv1_geom, pt1, &par1, base, &mdist, &rc );
   if( rc != BSSUCC ) goto wrapup;

   BScveval( cv1_geom, par1, 1, vec1, &rc );
   if( rc != BSSUCC ) goto wrapup;

   BSmdstptcv( cv2_geom, pt2, &par2, base, &mdist, &rc );
   if( rc != BSSUCC ) goto wrapup;

   BScveval( cv2_geom, par2, 1, vec2, &rc );
   if( rc != BSSUCC ) goto wrapup;

   BSnorvec( &rc, vec1[1] );
   BSnorvec( &rc, vec2[1] );

   *dotp = BSdotp( &rc, vec1[1], vec2[1] ); 

wrapup:
   _FREE( cv1_geom );
   _FREE( cv2_geom );
   return sts;
}

static void     VSgetNextIndex( IGRint                  *num_edges,
                                struct IGRbsp_curve     **edgeGeom,
                                IGRint                  *index )
{
IGRint          i;

    for( i=0; i<*num_edges; ++i )
    {
        if( edgeGeom[i] == NULL )
        {
           *index = i;
           break;
        }
    }
    if( i == (*num_edges) )
    {
        *index = *num_edges;
        (*num_edges)++;
    }
}

typedef  struct
{
   IGRint edge_plane; // XY or YZ or ZX
   IGRint parallel_to;// X or Y if edge_plane is XY
   IGRint orientation;  // UPP or DWN if parallel to X

} EdgeAttr;

static IGRlong	VSGetEdgeDirections(	IGRlong			*msg,
					IGRint			num_edges,
					struct GRobj_env	*edge_list,
					struct GRmd_env		*cur_env, 
					struct GRobj_env        *csOE,
					int			*edge_dir)
{
IGRlong			sts,loc_msg;
IGRint			i, edgeCnt=0, retStat = 0;
struct GRobj_env	compCurve;
struct IGRbsp_curve	*edgeGeom[100];
EdgeAttr		*edge_attrs = NULL;
struct GRid             *curves = NULL;

   SetProc( VSGetEdgeDirections ); Begin

   sts = *msg = MSSUCC;

   for( i=0; i<num_edges; ++i )
   {	
      vd_$get_geometry( msg	= msg,
		        grobjId  = &edge_list[i].obj_id,
		        grobjEnv = &edge_list[i].mod_env,
		        geometry = &edgeGeom[i] );
   }
   if( !( curves = _MALLOC(num_edges,struct GRid) ) ) vd_$mem_fail();
   edgeCnt = num_edges;

   for( i=0; i<edgeCnt; ++i ) 
   {
	__DBGpr_obj("Edge",  edge_list[i].obj_id );
	
	edge_list[i]._md_os = edge_list[i]._osnum;
   	sts = ex$get_modid( mod_osnum = edge_list[i]._md_os,
       	                    mod_id    = &edge_list[i]._md_id );

            sts = om$send(msg = message GRgraphics.GRcopy(
                                             &loc_msg,
                                             &edge_list[i].mod_env,
                                             cur_env,
                                             &curves[i].objid ),
                             senderid = NULL_OBJID,
                             targetid = edge_list[i].obj_id.objid,
                             targetos = edge_list[i].obj_id.osnum );

	curves[i].osnum = cur_env->md_id.osnum;
   }
   // create the composite curve
   __DBGpr_com("create the composite curve");
   __DBGpr_int("Num Edges ",edgeCnt);

   retStat = VDfillCompCrvGaps(curves,cur_env,&compCurve.obj_id,edgeCnt);
   if(!(retStat&1))
   {
	printf("\n failed to create the composite curve \n");
	sts = OM_W_ABORT;
	*msg= MSFAIL;
	goto wrapup;
   } 
   compCurve.mod_env = *cur_env;
   edge_attrs = _MALLOC(edgeCnt, EdgeAttr);
    __DBGpr_obj("compCurve ",compCurve.obj_id);
	
   retStat = VSEdgeOrientation(edgeGeom,compCurve,edgeCnt,csOE,edge_attrs);
   if(!(retStat&1))
   {
        printf("\n failed to get edges' orientation\n");
	sts = OM_W_ABORT;
	*msg= MSFAIL;
	goto wrapup;
   }

   for(i=0;i<num_edges;i++)
   {
	edge_dir[i] = edge_attrs[i].orientation;
	__DBGpr_int("Edge Number",i);
        switch(edge_attrs[i].orientation)
        {
            case 1: __DBGpr_com("FWD"); break;
            case 2: __DBGpr_com("AFT"); break;
            case 3: __DBGpr_com("IB"); break;
            case 4: __DBGpr_com("OB"); break;
            case 5: __DBGpr_com("UPP"); break;
            case 6: __DBGpr_com("DWN"); break;

        } 
   }
		 
wrapup:
   om$send( msg      = message GRgraphics.GRdelete( msg, cur_env ),
                senderid = NULL_OBJID,
                targetid = compCurve._objid,
                targetos = compCurve._osnum );

   for( i=0; i<num_edges; ++i ){ 
       om$send( msg      = message GRgraphics.GRdelete( msg, cur_env ),
                senderid = NULL_OBJID,
                targetid = curves[i].objid,
                targetos = curves[i].osnum );
	_FREE( edgeGeom[i] );
   }
   _FREE( curves ); 
   _FREE( edge_attrs );
   End
   return sts;
}

/*
static IGRlong	VSncTrimEdges(	IGRlong			*msg,
				IGRint			*num_edges,
				struct GRobj_env	*edge_list,
				IGRint			*index	     )
{
IGRlong			sts;
IGRint			i;

   for( i=0; i<(*num_edges); ++i )
   {
      if( index[i]
   }

wrapup:
   End
   return sts;
}
*/

static IGRlong  VStrimEdgesToSelectedCurves( IGRlong            *msg,
					     IGRint		num_pl,
					     struct GRobj_env	*pltOE,
                                             IGRint             *num_edges,
                                             struct GRobj_env   *edge_list,
					     IGRint		cnt_trim,
					     struct GRobj_env   *crv_trim,
                                             struct GRmd_env    *cur_env,
					     IGRdouble		gap_tol   )
{
BSrc			rc;
IGRlong			sts;
IGRint			i, j, num_pts=0, edgeCnt, nb_prj=0;
IGRshort		Orie[100];
IGRboolean		index[100], adj, clo;
IGRdouble		bastol, param, start_par, end_par, mdist, base[600];
IGRpoint		endpts[2];
struct GRid		*prjCrv=NULL;
struct GRobj_env	crv_obj, Ocrv[100];
struct GRvg_construct   cst;
struct IGRbsp_curve	*trimGeom=NULL, *edgeGeom=NULL, *crvGeom=NULL;

    SetProc( VStrimEdgesToSelectedCurves ); Begin

    __DBGpr_int( "Number Of Edges", *num_edges );
    __DBGpr_int( "Number Of Trimming Curves", cnt_trim );

    vdgeom$GetTolerance( basis = &bastol );
    VDsupInitCnst( &cst );

    if( cnt_trim )
	if( !( prjCrv = _MALLOC( cnt_trim, struct GRid )) ) vd_$mem_fail();

    for( i=0; i<cnt_trim; ++i )
    {
        sts = VScreateMultipleProj( msg, num_pl, pltOE, VS_K_plBotSfPath, 
			&crv_trim[i], &cst, &prjCrv[nb_prj] );
        if( sts&1&(*msg) )  nb_prj++;
    }
    __DBGpr_int( "Number of Projected Curves", nb_prj );

    for( i=0; i<nb_prj; ++i )
    {
	_FREE( trimGeom ) ;
        sts = vd_$get_geometry( msg      = msg,
                           	grobjId  = &prjCrv[i],
                           	grobjEnv = cst.env_info,
                           	geometry = &trimGeom ) ;
   	__CheckRC( sts, *msg, "vd_$get_geometry", wrapup );

	num_pts = 0;

	for( j=0; j<*num_edges; ++j )
	{
	   _FREE( edgeGeom ) ;
	   index[j] = FALSE;
           sts = vd_$get_geometry( msg      = msg,
                                   grobjId  = &edge_list[j]._grid,
                                   grobjEnv = &edge_list[j].mod_env,
                                   geometry = &edgeGeom ) ;
           __CheckRC( sts, *msg, "vd_$get_geometry", wrapup );

           MAbcendpts( &rc, edgeGeom, endpts[0], endpts[1] );
           __DBGpr_vec( "Start Point", endpts[0] );
           __DBGpr_vec( "End Point", endpts[1] );

           BSmdstptcv( 	trimGeom, endpts[0], &param, &base[3*num_pts], 
			&mdist, &rc );
           if( rc != BSSUCC || mdist  > gap_tol ) continue;
	   __DBGpr_com("Start Point is near to trim curve" );

           BSmdstptcv( 	trimGeom, endpts[1], &param, &base[3*(num_pts+1)], 
			&mdist, &rc );
           if( rc != BSSUCC || mdist  > gap_tol ) continue;
	   __DBGpr_com("End Point is near to trim curve" );

	   index[j] = TRUE;
	   num_pts += 2;
        }

	qsort( (char *) base, num_pts, sizeof( IGRpoint ), VSvertexCmp ) ;
	__DBGpr_vec( "Start Trim Point", &base[0] );
	__DBGpr_vec( "End Trim Point", &base[3*(num_pts-1)] );
	BSmdstptcv(  trimGeom, &base[0], &start_par, endpts[0], &mdist, &rc );
	BSmdstptcv(  trimGeom, &base[3*(num_pts-1)], &end_par, 
		     endpts[1], &mdist, &rc );
	param = ( start_par + end_par ) / 2.0 ;
	__DBGpr_dbl( "Start Parameter", start_par );
	__DBGpr_dbl( "End Parameter", end_par );

	if( crvGeom ) { BSfreecv( &rc, crvGeom ); crvGeom = NULL; }
        BSalloccv ( trimGeom->order, trimGeom->num_poles+2*trimGeom->order-1,
                    trimGeom->rational, trimGeom->num_boundaries,
                    &crvGeom, &rc );
	
	BSpartofcv( &rc, trimGeom, start_par, param, end_par, crvGeom );

        VDdrawCurve( crvGeom, cur_env, &crv_obj.obj_id );
        crv_obj.mod_env = *cur_env;
	__DBGpr_obj("Resulting Curve", crv_obj.obj_id );

        edgeCnt = 0;
	for( j=0; j<(*num_edges); ++j )
	{
	   if( index[j] ) 
	   {
	      vd_$bulk_delete( objenvs = &edge_list[j] );
	      edge_list[j]._objid = NULL_OBJID;
	   }	
	   else edge_list[edgeCnt++] = edge_list[j];
	}
	edge_list[edgeCnt++] = crv_obj;

        sts = OrderCrv ( edge_list, edgeCnt, gap_tol, bastol,
                         Ocrv, Orie, &adj, &clo, msg );
        if ((*msg) == BSSUCC)   *msg = MSSUCC;
        else                    *msg = MSFAIL;
        __CheckRC( sts, *msg, "OrderCrv", wrapup ) ;

	for( j=0; j<edgeCnt; ++j ) edge_list[j] = Ocrv[j];
	*num_edges = edgeCnt;
    }

wrapup:
    vd_$bulk_delete( count = nb_prj, grids = prjCrv, theEnv = cst.env_info );
    _FREE( prjCrv  );
    _FREE( trimGeom );
    _FREE( edgeGeom );
    if( crvGeom ) { BSfreecv( &rc, crvGeom ); crvGeom = NULL; }

    End
    return sts;
}

IGRlong         VSgetExternalContour(   IGRlong                 *msg,
                                        IGRint                  num_pl,
                                        struct GRobj_env        *plate_list,
                                        struct GRmd_env         *cur_env,
					IGRchar			*side,
                                        IGRint                  *num_bnd_edges,
                                        struct GRobj_env        **bnd_edges,
					struct GRobj_env        *csOE,
					IGRint			**edge_dir  )
{
BSrc                    rc;
IGRlong                 sts;
IGRint                  i, j, k, ind, edgeCnt, num_edges=0, num_adj_crvs=0,
			order, num_poles, ovLapCode, numDistCvs1, numDistCvs2, 
			numOvCvs, cnt_trim = 0;
IGRshort                *Orie=NULL, action=1;
IGRboolean              adj, clo;
IGRdouble               tol, mdist, start_par, end_par, mid_par, one_par,
                        zero_par, dotp, thickness, max_thk, min_thk, gap_tol;
IGRpoint                spt, ept, mid_pt, base1, base2, mid_base;
struct GRobj_env        footOE, *crv_obj=NULL, *Ocrv=NULL, crv_trim[30];
struct GRvg_construct   cst;
struct IGRbsp_curve     **DCvs1=NULL, **DCvs2=NULL, **OCvs=NULL, 
			*cur_crv=NULL, *edgeGeom[200];
struct GRlc_info        *Mcrv=NULL;

   SetProc( VSgetExternalContour ); Begin

   vdgeom$GetTolerance(cht = &tol);
   VDsupInitCnst( &cst );

   __DBGpr_int( "Number Input Plates/Curves", num_pl );

   max_thk = -1.0e+30;
   min_thk =  1.0e+30;

   for( i=0; i<num_pl; ++i )
   {
     if( vd_$is_ancestry_valid( object  = &plate_list[i].obj_id,
				classid = OPP_VSplate_class_id ) )
     {
       edgeCnt = 0;
       vdobj$GetFoot( objOE     = &plate_list[i],
                      footName  = side,
                      footOE    = &footOE );

       vdsa$Get( objOE = &plate_list[i], 
		 name  = "plate_thk", 
		 dbl   = &thickness );
       if( thickness < min_thk )  min_thk = thickness ;
       if( thickness > max_thk )  max_thk = thickness ;

       sts = VDefpGetSurfaceEdgeBsps( &footOE, 200-num_edges, tol,
                                      &edgeCnt, &edgeGeom[num_edges] );
       num_edges += edgeCnt ;
     }
     else	
     {
	crv_trim[cnt_trim++] = plate_list[i];
     }
   }
   __DBGpr_int("Total Number Of Edges ", num_edges );

   gap_tol = max_thk - min_thk + 5.0 ;
   __DBGpr_dbl( "Gap Tolerance", gap_tol );

edge_loop:
   edgeCnt = num_edges;
   numDistCvs1 = 0;
   numDistCvs2 = 0;
   numOvCvs    = 0;

   for( i=0; i<num_edges; ++i )
   {
      for( j=0; j<num_edges; ++j )
      {
         _FREE( cur_crv );
	 if( numDistCvs1 )
	 {
	    for( k=0; k<numDistCvs1; ++k )	BSfreecv( &rc, DCvs1[k] );
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
         if( i == j || edgeGeom[i] == NULL || edgeGeom[j] == NULL ) continue;

	 BSchk2cvsov( edgeGeom[i], edgeGeom[j], gap_tol, 0, &ovLapCode, 
	   &numDistCvs1, &DCvs1, &numDistCvs2, &DCvs2, &numOvCvs, &OCvs, &rc );

	 if( rc == BSSUCC && ovLapCode == 5 && 
	     numDistCvs1 == 1 && numDistCvs2 == 1 )
	 {
	     order = edgeGeom[i]->order;
	     num_poles = edgeGeom[i]->num_poles;
	     _FREE( edgeGeom[i] );

             vdgeom$AllocCrv( order     = order,
                              num_poles = num_poles,
                              crv       = &edgeGeom[i]  );
             BScv_copy( &rc, DCvs1[0], edgeGeom[i] );

             order = edgeGeom[j]->order;
             num_poles = edgeGeom[j]->num_poles;
             _FREE( edgeGeom[j] );

             vdgeom$AllocCrv( order     = order,
                              num_poles = num_poles,
                              crv       = &edgeGeom[j]  );
             BScv_copy( &rc, DCvs2[0], edgeGeom[j] );
	     continue;
	 }

         MAbcendpts( &rc, edgeGeom[j], spt, ept );
         BSmdstptcv( edgeGeom[i], spt, &start_par, base1, &mdist, &rc );
         if( rc != BSSUCC || mdist  > gap_tol ) continue;

         if( BSdistptpt( &rc, spt, ept ) < gap_tol ) continue;

	 BScvmidpt( edgeGeom[j], &mid_par, mid_pt, &rc );
         if( rc != BSSUCC ) continue;

	 BSmdstptcv( edgeGeom[i], mid_pt, &mid_par, mid_base, &mdist, &rc );
	 if( rc != BSSUCC || mdist  > gap_tol ) continue;

         BSmdstptcv( edgeGeom[i], ept, &end_par, base2, &mdist, &rc );
         if( rc != BSSUCC || mdist  > gap_tol ) continue;

         vdgeom$AllocCrv( order     = edgeGeom[i]->order,
                          num_poles = edgeGeom[i]->num_poles,
                          crv       = &cur_crv  );
         BScv_copy( &rc, edgeGeom[i], cur_crv  );

         MAbcendpts( &rc, edgeGeom[i], spt, ept );

         if( BSdistptpt( &rc, spt, base2 ) < BSdistptpt( &rc, spt, base1 ) )
         {
            mdist     = start_par ;
            start_par = end_par ;
            end_par   = mdist ;
         }
         BSmdstptcv( cur_crv, spt, &zero_par, base1, &mdist, &rc );
         BSmdstptcv( cur_crv, ept, &one_par,  base2, &mdist, &rc );

         _FREE( edgeGeom[i] );
         _FREE( edgeGeom[j] );

         if( fabs( zero_par - start_par ) < 0.00001 &&
             fabs( one_par - end_par ) < 0.00001 )
         {
            _FREE( edgeGeom[i] );
            goto edge_loop;
         }

         if( fabs( zero_par - start_par ) > 0.00001 )
         {
            mid_par = ( zero_par + start_par ) / 2.0 ;

            VSgetNextIndex( &edgeCnt, edgeGeom, &ind );
            vdgeom$AllocCrv( order     = cur_crv->order,
                             num_poles = cur_crv->num_poles+2*cur_crv->order-1,
                             crv       = &edgeGeom[ind]  );

            BSpartofcv( &rc, cur_crv, zero_par, mid_par,
                        start_par, edgeGeom[ind]  );
         }

         if( fabs( one_par - end_par ) > 0.00001 )
         {
            mid_par = ( end_par + one_par ) / 2.0 ;

            VSgetNextIndex( &edgeCnt, edgeGeom, &ind );
            vdgeom$AllocCrv( order     = cur_crv->order,
                             num_poles = cur_crv->num_poles+2*cur_crv->order-1,
                             crv       = &edgeGeom[ind]  );

            BSpartofcv( &rc, cur_crv, end_par, mid_par,
                        one_par, edgeGeom[ind]  );
         }
         num_edges = edgeCnt ;
         goto edge_loop;
      }
   }

   edgeCnt = 0;
   for( i=0; i<num_edges; ++i )
	if( edgeGeom[i] != NULL )   edgeCnt++;

   if( !edgeCnt ) goto wrapup;

   if( !( crv_obj = _MALLOC( edgeCnt+1, struct GRobj_env )) ) vd_$mem_fail();
   if( !( Ocrv = _MALLOC( edgeCnt, struct GRobj_env )) ) vd_$mem_fail();
   if( !( Orie = _MALLOC( edgeCnt, IGRshort )) ) vd_$mem_fail();
   if( !( Mcrv = _MALLOC( edgeCnt, struct GRlc_info )) ) vd_$mem_fail();

   edgeCnt = 0;
   for( i=0; i<num_edges; ++i )
   {
        if( edgeGeom[i] != NULL )
        {
           VDdrawCurve( edgeGeom[i], cur_env, &crv_obj[edgeCnt].obj_id );
           crv_obj[edgeCnt].mod_env = *cur_env;
           edgeCnt++;
        }
   }
   crv_obj[edgeCnt] = crv_obj[0];

   vdgeom$GetTolerance( basis = &tol );
   sts = OrderCrv ( crv_obj, edgeCnt, gap_tol, tol,
                    Ocrv, Orie, &adj, &clo, msg );
   if ((*msg) == BSSUCC)   *msg = MSSUCC;
   else                    *msg = MSFAIL;
   __CheckRC( sts, *msg, "OrderCrv", wrapup ) ;

   for ( i=0; i<edgeCnt; i++ )
   {
	sts = VSdotProduct( msg, &Ocrv[i], &Ocrv[i+1], gap_tol, &dotp );
        if( fabs(dotp) < 0.9 ) { ind = i+1; break; }
   }

   for ( i=ind; i<edgeCnt; i++ )        crv_obj[i-ind] = Ocrv[i];
   for ( i=0; i<ind; i++ )              crv_obj[edgeCnt-ind+i] = Ocrv[i];
   crv_obj[edgeCnt] = crv_obj[0];

   ind = j = 0;
   action = 1 ;

   for ( i=0; i<edgeCnt; i++ )
   {
       sts = VSdotProduct( msg, &crv_obj[i], &crv_obj[i+1], gap_tol, &dotp );
       if( (sts&1) && ( fabs(dotp) < 0.9 ) )
       {
          num_adj_crvs = i-ind+1;

	  if( num_adj_crvs == 1 )
	  {
	     crv_obj[j] = crv_obj[ind];
	  }
	  else
	  {
	     sts = OrderCrv ( &crv_obj[ind], num_adj_crvs, gap_tol, tol,
			      Ocrv, Orie, &adj, &clo, msg );
	     if ((*msg) == BSSUCC)   *msg = MSSUCC;
             else                    *msg = MSFAIL;

	     for( k=0; k<num_adj_crvs; ++k )  crv_obj[ind+k] = Ocrv[k];
		
             sts = BuildCrv( action, &crv_obj[ind], num_adj_crvs, Orie, 
			     adj, clo, Mcrv, &cst, &footOE.obj_id, msg );
             if ((*msg) == BSSUCC)   *msg = MSSUCC;
             else                    *msg = MSFAIL;
             crv_obj[j].obj_id  = footOE.obj_id ;
             crv_obj[j].mod_env = *(cst.env_info);
	  }
          j++;  ind=i+1 ;
       }
   }

   if( ind != edgeCnt )
   {
       num_adj_crvs = i-ind;

       if( num_adj_crvs == 1 )
       {
	 crv_obj[j] = crv_obj[ind];
       } 
       else
       {
         sts = OrderCrv ( &crv_obj[ind], num_adj_crvs, gap_tol, tol,
                          Ocrv, Orie, &adj, &clo, msg );
         if ((*msg) == BSSUCC)   *msg = MSSUCC;
         else                    *msg = MSFAIL;

         for( k=0; k<num_adj_crvs; ++k )  crv_obj[ind+k] = Ocrv[k];

         sts = BuildCrv( action, &crv_obj[ind], num_adj_crvs, Orie, adj, 
		         clo, Mcrv, &cst, &footOE.obj_id, msg );
         if ((*msg) == BSSUCC)   *msg = MSSUCC;
         else                    *msg = MSFAIL;
         crv_obj[j].obj_id  = footOE.obj_id ;
         crv_obj[j].mod_env = *(cst.env_info);
       }
       j++; 
   }

   *num_bnd_edges = j ;
   
   if( cnt_trim )
   {
      sts = VStrimEdgesToSelectedCurves( msg, num_pl, plate_list, num_bnd_edges, 
			crv_obj, cnt_trim, crv_trim, cur_env, max_thk );
   }

   if( !( *bnd_edges = _MALLOC( j, struct GRobj_env )) ) vd_$mem_fail(); 

   for( i=0; i<(*num_bnd_edges); ++i )  (*bnd_edges)[i] = crv_obj[i];

   if( !(*edge_dir = _MALLOC( *num_bnd_edges, IGRint )) ) vd_$mem_fail();

   sts = VSGetEdgeDirections( msg, *num_bnd_edges, *bnd_edges, 
			      cur_env, csOE, *edge_dir );

wrapup:
   if( !(sts&1&(*msg)) ) vd_$bulk_delete( count=num_edges, objenvs=crv_obj );
   for( i=0; i<num_edges; ++i ) 	_FREE( edgeGeom[i] );
   _FREE( cur_crv );
   _FREE( crv_obj );
   _FREE( Ocrv );
   _FREE( Orie );
   _FREE( Mcrv );
   if( numDistCvs1 )
   {
       for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
       _FREE( DCvs1 );
   }
   if( numDistCvs2 )
   {
       for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
       _FREE( DCvs2 );
   }
   if( numOvCvs )
   {
       for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
       _FREE( OCvs );
   }

   End
   return sts;
}

struct  PntWork {
        IGRboolean              Idx;
        IGRdouble               Dist;
};

static IGRint VSsortEWByDist ( a, b)
struct  PntWork       *a, *b;
{
  return ((a->Dist == b->Dist) ? 0: (a->Dist < b->Dist)  ? -1 : 1);
}
  
/* This function construct an object EMSplane from a point and a normal. */
/*h 13/11/92 : creation by Marc FOURNIER (ISDC). */
IGRlong VSgeneratePlane ( Point, Normal, Env, cst, Plane, msg)
                IGRpoint        Point;        /*I Plane point         */
                IGRvector       Normal;       /*I Plane normal        */
        struct  GRmd_env        *Env;           /*I Current module env  */
        struct  GRvg_construct  *cst;           /*I Construction list   */
        struct  GRid            *Plane;         /*O Constructed plane   */
                IGRlong         *msg;           /*O Completion code     */

{

                IGRlong         sts=OM_S_SUCCESS;
                IGRint          suc=OM_S_SUCCESS;
                IGRvector       u, v, w;
                BSrc            rc;
                IGRdouble       pts[9];
                IGRint          i;

        /* Construct a set of orthonormal vectors */
        BSbasisvect( &rc, Normal, u, v, w );
        if (rc != BSSUCC) {     *msg = MSFAIL;
                                printf( "Error in BSbasisvect(%g,%g,%g)\n",
                                        Normal[0], Normal[1], Normal[2] );
                                goto wrapup;    }

        /* Construct 3 points of the plane */
        for ( i=0; i<3; i++) {
                pts[i+0] = Point[i];
                pts[i+3] = Point[i] + v[i];
                pts[i+6] = Point[i] + w[i];
        }

        /* Construct EMSplane */
        Plane->objid = NULL_OBJID;
        Plane->osnum = Env->md_id.osnum;
        sts = om$construct ( classid  = OPP_EMSplane_class_id,
                             osnum    = Env->md_id.osnum,
                             p_objid  = &Plane->objid,
                             msg     = message EMSplane.EMplane
                                                ( &suc, cst,
                                                  (IGRpoint *)pts, 3 ) );

        *msg = *(cst->msg);     // EMplane sets suc not cst->msg !

        as$status ( sts    = sts,
                    msg    = "om$construct(EMSplane.EMplane)",
                    test   = (!(sts & 0x00000001 & (*msg) & (suc) )),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup :
        return (sts);

/* End of function */
}
IGRint  VSEdgeOrientation( struct IGRbsp_curve  **edge_geom,
                           struct GRobj_env     compCurve,
                           IGRint               edgeCnt,
			   struct GRobj_env	*csOE,
                           EdgeAttr             *edge_attrs )
{
   BSrc                 rc;
   IGRlong		sts = OM_S_SUCCESS, loc_sts, loc_msg;
   IGRint               i, j, ii, retFlag=0,  action=1, nb_inter=0, 
			pt1_ind=0, pt2_ind=0;
   IGRdouble            ptDev[6],maxDist=0.0,  start_pt[6], end_pt[6],
			startpt_next[6], end_pt_next[6], cs_mat[16], 
                        *pntInt=NULL, *OrdPts=NULL, matVec[3], cos_alpha,
			cos_beta, cos_gamma, cos_alpha_plane, cos_beta_plane,
			cos_gamma_plane, range[6], loc_range[6], rev_mat[16];
   IGRboolean		x_positive, y_positive, z_positive, not_first; 
   IGRvector		edge_vector, next_edge_vector, crossp, x_axis,
			y_axis, z_axis;
   IGRchar		debugfile[50];
   IGRshort		mat_type;
   struct PntWork       *PW=NULL;
   struct GRlc_info     elem1Info, elem2Info;
   struct IGRpolyline   point;
   struct IGRplane      ref_plane;
   struct GRid          *pntsId=NULL;
   struct GRobj_env     infPlane, plane;

   struct GRvg_construct	cnst;

   VDsupInitCnst( &cnst );
   cnst.env_info   = &compCurve.mod_env;

   plane.obj_id.objid = NULL_OBJID;
   infPlane.obj_id.objid = NULL_OBJID;

   if( csOE )
   {
	IGRshort		cs_pl;
       	IGRuchar                props;
	
        if(!VDget_mat( 	&csOE->obj_id, &csOE->_matrix_type, csOE->_matrix, 
			cs_mat, &props, &cs_pl))
        {
            printf("Error in VDget_mat\n");
            goto wrapup;
        }

	#ifdef DEBUG
	   pr_mat( "CS Matrix", 4, 4, cs_mat );
	#endif
   }
   else MAidmx( &rc, cs_mat );

   not_first = FALSE ;
   for(ii=0;ii<edgeCnt;ii++)
   {
      BSbx2( &rc, &edge_geom[ii]->num_poles, edge_geom[ii]->poles,
	    edge_geom[ii]->weights, &loc_range[0], &loc_range[3] );
      if( not_first ) GRaccumulate_range( &loc_msg, loc_range, range );
      else
      {
	not_first = TRUE ;
	 for( i=0; i<6; i++ ) range[i] = loc_range[i];
      }
   }

   i = 4;
   MAinvmx( &loc_msg, &i, cs_mat, rev_mat );
   MAtypemx( &loc_msg, cs_mat, &mat_type );
   
   i = 2 ;
   sts = MAoptsxform( &loc_msg, (IGRlong *)&i, &mat_type,  
		      rev_mat, &range[0], &range[0] );
   if( !(sts&1) )  goto wrapup;

/*
   if( ( range[0] < 1e-3 ) && ( range[3] < 1e-3 ) )
	x_positive = FALSE;
   else x_positive = TRUE;
*/
   x_positive = z_positive = TRUE;

   if( ( range[1] < 1e-3 ) || ( range[4] < 1e-3 ) )
        y_positive = FALSE;
   else y_positive = TRUE;

/*

   if( ( range[2] < 1e-3 ) && ( range[5] < 1e-3 ) )
        z_positive = FALSE;
   else z_positive = TRUE;

   __DBGpr_int(" x_positive ",x_positive);
   __DBGpr_int(" y_positive ",y_positive);
   __DBGpr_int(" z_positive ",z_positive);
*/

   for(ii=0;ii<edgeCnt;ii++)
   {
        __DBGpr_com("################################################### ");
        __DBGpr_int(" Processing edge ",ii);
        plane.obj_id.objid = NULL_OBJID;
        infPlane.obj_id.objid = NULL_OBJID;

        // FIND THE PLANE AND AXIS OF THE EDGE (parallel to)
	MAbcendpts( &rc, edge_geom[ii], start_pt, end_pt ); 

	BSmkvec(&rc, edge_vector, start_pt, end_pt) ;
	if( rc != BSSUCC ) continue;

	__DBGpr_vec("edge Start point ",&start_pt[0]);
	__DBGpr_vec("edge end point ",&end_pt[0]);

	BSnorvec(&rc, edge_vector) ;
	if (rc != BSSUCC) goto wrapup ;
	__DBGpr_vec("normalized edge vector ",edge_vector);

	if(ii != (edgeCnt-1)){
	        MAbcendpts( &rc, edge_geom[ii+1], start_pt, end_pt );
		BSmkvec(&rc, next_edge_vector, start_pt, end_pt) ;
		if (rc != BSSUCC) goto wrapup ;
		BSnorvec(&rc, edge_vector) ;
		if (rc != BSSUCC) goto wrapup ;
	}
	else{
	        MAbcendpts( &rc, edge_geom[0], start_pt, end_pt );
                BSmkvec(&rc, next_edge_vector, start_pt, end_pt) ;
                if (rc != BSSUCC) goto wrapup ;
		BSnorvec(&rc, next_edge_vector) ;
		if (rc != BSSUCC) goto wrapup ;
	}		
	BScrossp(&rc,edge_vector,next_edge_vector,crossp) ;
	if (rc != BSSUCC) goto wrapup ;
	__DBGpr_vec("average plane normal ",crossp);

	if( BSlenvec( &rc, crossp ) < 1e-3 )
	{
	    IGRdouble		tol;
	    IGRdouble		pl_pt[3];
	    IGRpoint	        *pole_pts=NULL;
	    struct IGRplane	plane;

	    __DBGpr_vec( "Null Cross Product", crossp );
            BSxtractpar(&rc,BSTOLLENVEC,&tol);

            if( edge_geom[ii]->rational ) 
	    {
                pole_pts = _MALLOC( edge_geom[ii]->num_poles, IGRpoint ) ;
                BSunwght_p( &loc_msg, edge_geom[ii]->poles, 
		     	    edge_geom[ii]->weights,
			    &edge_geom[ii]->num_poles, (double *) pole_pts );
            } 
	    else 
	    {
                 pole_pts = (IGRpoint *) edge_geom[ii]->poles ;
            }

	    plane.point = pl_pt; plane.normal = crossp;

	    MAdetplane( &loc_msg, pole_pts,
		        &edge_geom[ii]->num_poles,&tol, &plane );
	    __DBGpr_vec("Average Plane normal ",crossp);
	   if( pole_pts && pole_pts != (IGRpoint *) edge_geom[ii]->poles ) 
	   {
                _FREE( pole_pts ) ;
           }
	}

	x_axis[0] = cs_mat[0] ; x_axis[1] = cs_mat[4] ; x_axis[2] = cs_mat[8];
	cos_alpha = fabs( BSdotp( &rc, x_axis, edge_vector ) );
	cos_alpha_plane = fabs( BSdotp( &rc, x_axis, crossp ) );

        y_axis[0] = cs_mat[1] ; y_axis[1] = cs_mat[5] ; y_axis[2] = cs_mat[9];
 	cos_beta  = fabs( BSdotp( &rc, y_axis, edge_vector ) );
	cos_beta_plane  = fabs( BSdotp( &rc, y_axis, crossp ) );

        z_axis[0] = cs_mat[2] ; z_axis[1] = cs_mat[6] ; z_axis[2] = cs_mat[10];
        cos_gamma = fabs( BSdotp( &rc, z_axis, edge_vector ) );
	cos_gamma_plane = fabs( BSdotp( &rc, z_axis, crossp ) );

	if( (cos_alpha_plane - cos_beta_plane)  > 1e-5 && 
	    (cos_alpha_plane - cos_gamma_plane) > 1e-5 ) 
		edge_attrs[ii].edge_plane = YZ;

        if( (cos_beta_plane - cos_alpha_plane) >  1e-5 &&
            (cos_beta_plane - cos_gamma_plane) >  1e-5 ) 
                edge_attrs[ii].edge_plane = ZX;

        if( (cos_gamma_plane - cos_alpha_plane) >  1e-5 &&
            (cos_gamma_plane - cos_beta_plane)  >  1e-5 ) 
                edge_attrs[ii].edge_plane = XY;

	// to what axis is the edge closest parallel to
	  if(edge_attrs[ii].edge_plane == XY){
	  	__DBGpr_com("edge_plane == XY");

		if( (cos_alpha - cos_beta) >  1e-5 )
					edge_attrs[ii].parallel_to = X;
		else		       	edge_attrs[ii].parallel_to = Y;
  	  }
	  if(edge_attrs[ii].edge_plane == ZX){
	  	__DBGpr_com("edge_plane == ZX");

		if( (cos_alpha - cos_gamma) >  1e-5 )
					edge_attrs[ii].parallel_to = X;
		else		       	edge_attrs[ii].parallel_to = Z;
  	  }
	  if(edge_attrs[ii].edge_plane == YZ){
	  	__DBGpr_com("edge_plane == YZ");

		if( (cos_beta - cos_gamma) >  1e-5 )
					edge_attrs[ii].parallel_to = Y;
		else		       	edge_attrs[ii].parallel_to = Z;
  	  }

   	// FIND THE MATERIAL DIRECTION

   	// Evaluate the point and derivative of the curve at 0.5
   	BScveval( edge_geom[ii], 0.5, 1, (IGRpoint *)ptDev, &rc );
	if (rc != BSSUCC) goto wrapup ;
   	__DBGpr_vec("First Point: Point at 0.5 parameter ", &ptDev[0] );
   	__DBGpr_vec("Derivative at 0.5 parameter ", &ptDev[3] );

	#ifdef DEBUG
		sprintf(debugfile,"edge%d.txt",ii);
		sts = VDdumpCurve(NULL,edge_geom[ii],debugfile);
		if(!(sts&1)) printf("\n debug of edge geometry failed \n");
	#endif 
 
        ref_plane.point  = &ptDev[0];
        ref_plane.normal = &ptDev[3];

        //create plane 
        sts = VSgeneratePlane( ref_plane.point, ref_plane.normal, 
		    &compCurve.mod_env, &cnst, &plane.obj_id, &loc_msg );
        if( ! (sts&loc_msg&1))  goto wrapup; 
	__DBGpr_obj("plane ",plane.obj_id);
        
	plane.mod_env = compCurve.mod_env ;
	
	// create an infinite plane
        sts = VSmakeInfinitePlane( &loc_msg,
                                   &plane,
                                   &cnst,
                                   &infPlane._grid );
        if( ! (sts&loc_msg&1))  goto wrapup; 
	__DBGpr_obj("Infinite plane ",infPlane.obj_id);

        infPlane.mod_env = compCurve.mod_env ;

	#ifdef DEBUG
		strcpy(debugfile,"compcurve.txt");
		sts = VDdumpCurve(&compCurve,NULL,debugfile);
		if(!(sts&1)) printf("\n debug of compcurve failed \n");
		strcpy(debugfile,"infplane.txt");
		sts = VDdumpSurface(&infPlane,NULL,debugfile);
		if(!(sts&1)) printf("\n debug of infinite plane failed \n");
	#endif  

   	// Intersect the infinite plane with the composite curve.
   	__DBGpr_com("Intersect the infinite plane with the composite curve");

   	elem1Info.located_obj   = compCurve.obj_id ;
   	elem1Info.module_info   = compCurve.mod_env ;
   	elem2Info.located_obj   = infPlane.obj_id;
   	elem2Info.module_info   = *cnst.env_info;

   	sts = EMintersect_two_element( &elem1Info,
       	                               &elem2Info,
       	                               TRUE,
       	                               &cnst,
       	                               &nb_inter,
       	                               &pntsId,
       	                               &loc_msg ) ;

   	// Delete the infinite plane 
   	loc_sts = om$send( msg = message GRgraphics.GRdelete( &loc_msg,
       	                                cnst.env_info),
       				        senderid = NULL_OBJID,
                 			targetid = infPlane.obj_id.objid,
                 			targetos = infPlane.obj_id.osnum  );
	infPlane.obj_id.objid = NULL_OBJID;

        loc_sts = om$send( msg = message GRgraphics.GRdelete( &loc_msg,
                                        cnst.env_info),
                                        senderid = NULL_OBJID,
                                        targetid = plane.obj_id.objid,
                                        targetos = plane.obj_id.osnum  );
        plane.obj_id.objid = NULL_OBJID;

   	if( nb_inter < 1 ) {
        	if( loc_msg == EMS_E_NoDynamicMemory ) {
                   	sts = OM_E_NODYNMEM ;
        	} else {
                   	loc_msg = EMS_W_NoSolution ;
                   	sts = OM_W_ABORT ;
        	}
        		goto wrapup ;
   	}
   	__DBGpr_int("Number of intersection points ", nb_inter );

   	// Allocate memory for resulting points
   	pntInt = (IGRdouble *)om$malloc( size =  (3*nb_inter) * 
						sizeof(IGRdouble));
   	OrdPts = (IGRdouble *)om$malloc( size =  (3*nb_inter) * 
						sizeof(IGRdouble));

   	// For each intersection point evaluate the coordinates
   	for( i=0; i<nb_inter; ++i )
   	{
       		point.points    = &pntInt[3*i];
       		point.num_points= 1 ;
       		sts = om$send( msg      = message GRlinear.GRgetpolyline(
                                             &loc_msg,
                                             &cnst.env_info->md_env.matrix_type,
                                             cnst.env_info->md_env.matrix,
                                             &action,
                                             &point ),
                 			senderid = pntsId[i].objid,
                 			targetid = pntsId[i].objid,
                 			targetos = pntsId[i].osnum ) ;
       		if( !(sts&1&(loc_msg)) ) goto wrapup;
		__DBGpr_vec("Intersection Point ", &pntInt[3*i] );
   	}

   	__DBGpr_com("evaluate the most distant points");
   	// From the list, evaluate the most distant points
   	maxDist = 0.0;
   	for( i=0; i<nb_inter; ++i )
   	{
       		for( j=i+1; j<nb_inter; ++j )
       		{
	   		IGRdouble	dist;
	   		dist = BSdistptpt( &rc, &pntInt[3*i], &pntInt[3*j] );
	   		if( dist > maxDist )
	   		{
	       			maxDist = dist;
	       			pt1_ind = i;
	       			pt2_ind = j;
	   		}
        	}
   	}
   	__DBGpr_vec("Most Distant First Point ", &pntInt[3*pt1_ind] );
   	__DBGpr_vec("Most Distant Second Point ", &pntInt[3*pt2_ind] );

   	/* Allocate and fill PntWork structure */
   	PW = om$calloc ( num = nb_inter, structure = struct PntWork );

   	j = 0;

   	// Store the indices and distances for each point from the lowest point
   	for( i=0; i<nb_inter; ++i )
   	{
	    PW[j].Idx = i;
	    PW[j++].Dist = BSdistptpt( &rc, &pntInt[3*pt1_ind], &pntInt[3*i] );
   	}

   	__DBGpr_com("Sort the points");
   	// Sort the points in an order based on the above distances
   	qsort( PW, nb_inter, sizeof(struct PntWork), 
	       (int (*)())VSsortEWByDist);

   	// Store the ordered points in another array in proper sequence
   	for( i=0; i<nb_inter; ++i )
   	{
		for( j=0; j<3; ++j )  OrdPts[3*i+j] = pntInt[3*(PW[i].Idx)+j];
		__DBGpr_vec("Ordered Point ", &OrdPts[3*i] );
   	}

   	__DBGpr_com("Check the closest point");
   	// Check the closest point
   	for( i=0; i<nb_inter; ++i )
   	{
                if (
   	((OrdPts[3*i+0] - ptDev[0] <= 0.0001) && (OrdPts[3*i+0] - ptDev[0] >= -0.0001)) &&
	((OrdPts[3*i+1] - ptDev[1] <= 0.0001) && (OrdPts[3*i+1] - ptDev[1] >= -0.0001)) &&
 	((OrdPts[3*i+2] - ptDev[2] <= 0.0001) && (OrdPts[3*i+2] - ptDev[2] >= -0.0001))
                ) break;
   	}
   	__DBGpr_int("Closest Point Index ", i );
   	__DBGpr_vec("Closest Point ", &OrdPts[3*i] );

   	if( i%2 )
   	{
      		/* If the index is odd, material direction vector is
	 		from Odd to the PREVIOUS Even index */
      		for(j=0;j<3;j++) matVec[j] = OrdPts[3*(i-1)+j] - ptDev[j];
      		__DBGpr_com("Index is Even ");
      		__DBGpr_vec("Start Point for material direction",ptDev);
   	}
   	else
   	{
      		/* If the index is even, material direction vector is 
	 		from Even to the NEXT Odd index. */
      		for(j=0;j<3;j++) matVec[j] = OrdPts[3*(i+1)+j] - ptDev[j];
      		__DBGpr_com("Index is Odd ");
      		__DBGpr_vec("Start Point for material direction",ptDev);
   	}
	BSnorvec(&rc, matVec) ;
	if (rc != BSSUCC) goto wrapup ;
   	__DBGpr_vec("Material Direction Vector ", matVec );

	if(edge_attrs[ii].edge_plane == ZX){ // XZ plane 
		if(edge_attrs[ii].parallel_to == X){ // parallel to X axis
		   __DBGpr_com("parallel to X axis");
		   if( z_positive )
		   {
			if( BSdotp( &rc, matVec, z_axis) > 0.0 ) 
				          edge_attrs[ii].orientation = DWN;
			else		  edge_attrs[ii].orientation = UPP; 
		   }
		   else
                   {
                        if( BSdotp( &rc, matVec, z_axis) > 0.0 ) 
                                          edge_attrs[ii].orientation = UPP;
                        else              edge_attrs[ii].orientation = DWN; 
                   }
		}
		if(edge_attrs[ii].parallel_to == Z){ // parallel to Z axis
			__DBGpr_com("parallel to Z axis");
                   if( x_positive )
                   {
                        if( BSdotp( &rc, matVec, x_axis) > 0.0 ) 
                                          edge_attrs[ii].orientation = AFT;
                        else              edge_attrs[ii].orientation = FWD; 
                   }
                   else
                   {
                        if( BSdotp( &rc, matVec, x_axis) > 0.0 ) 
                                          edge_attrs[ii].orientation = FWD;
                        else              edge_attrs[ii].orientation = AFT; 
                   }
		}
	}

	if(edge_attrs[ii].edge_plane == XY){ // XY plane 
		if(edge_attrs[ii].parallel_to == X){ // parallel to X axis
		   __DBGpr_com("parallel to X axis");
                   if( y_positive )
                   {
                        if( BSdotp( &rc, matVec, y_axis) > 0.0 ) 
                                          edge_attrs[ii].orientation = IB;
                        else              edge_attrs[ii].orientation = OB;
                   }
                   else
                   {
                        if( BSdotp( &rc, matVec, y_axis) > 0.0 )
                                     edge_attrs[ii].orientation = OB;
                        else         edge_attrs[ii].orientation = IB;
                   }
		}
		if(edge_attrs[ii].parallel_to == Y){ // parallel to Y axis
                   __DBGpr_com("parallel to Y axis");
		   __DBGpr_vec("x_axis ", x_axis );
		   __DBGpr_dbl( "Dot Product ", BSdotp( &rc, matVec, x_axis) );
                   if( x_positive )
                   {
                        if( BSdotp( &rc, matVec, x_axis) > 0.0 )
                                          edge_attrs[ii].orientation = AFT;
                        else              edge_attrs[ii].orientation = FWD;
                   }
                   else
                   {
                        if( BSdotp( &rc, matVec, x_axis) > 0.0 )
                                          edge_attrs[ii].orientation = FWD;
                        else              edge_attrs[ii].orientation = AFT;
                   }
                }
	}

	if(edge_attrs[ii].edge_plane == YZ){ // YZ plane 
		if(edge_attrs[ii].parallel_to == Z){ // parallel to Z axis
		   __DBGpr_com("parallel to Z axis");
                   if( y_positive )
                   {
                        if( BSdotp( &rc, matVec, y_axis) > 0.0 )
                                          edge_attrs[ii].orientation = IB;
                        else              edge_attrs[ii].orientation = OB;
                   }
                   else
                   {
                        if( BSdotp( &rc, matVec, y_axis) > 0.0 )
                                          edge_attrs[ii].orientation = OB;
                        else              edge_attrs[ii].orientation = IB;
                   }
		}
		if(edge_attrs[ii].parallel_to == Y){ // parallel to Y axis
		   __DBGpr_com("parallel to Y axis");
                   if( z_positive )
                   {
                        if( BSdotp( &rc, matVec, z_axis) > 0.0 )
                                          edge_attrs[ii].orientation = DWN;
                        else              edge_attrs[ii].orientation = UPP;
                   }
                   else
                   {
                        if( BSdotp( &rc, matVec, z_axis) > 0.0 )
                                          edge_attrs[ii].orientation = UPP;
                        else              edge_attrs[ii].orientation = DWN;
                   }
		}
	}
	__DBGpr_int("edge edge_plane ",edge_attrs[ii].edge_plane);
	__DBGpr_int("edge parallel_to ",edge_attrs[ii].parallel_to);
	__DBGpr_int("edge orientation ",edge_attrs[ii].orientation);
	__DBGpr_com("################################################### ");
   	// Delete all the intersection point objects.
   	for( i=0; i<nb_inter; ++i )
   	{
        	loc_sts = om$send( msg = message GRgraphics.GRdelete( &loc_msg,
               	                                           cnst.env_info),
                 			senderid = NULL_OBJID,
                 			targetid = pntsId[i].objid,
                 			targetos = pntsId[i].osnum  );
   	}
   } 

   // Done
   retFlag = 1;
wrapup:
        // Delete the planes, if there are any left
   if( infPlane.obj_id.objid != NULL_OBJID )
   {
        loc_sts = om$send( msg = message GRgraphics.GRdelete( &loc_msg,
                                        cnst.env_info),
                                        senderid = NULL_OBJID,
                                        targetid = infPlane.obj_id.objid,
                                        targetos = infPlane.obj_id.osnum  );
        infPlane.obj_id.objid = NULL_OBJID;
   }

   if( plane.obj_id.objid != NULL_OBJID )
   {
        loc_sts = om$send( msg = message GRgraphics.GRdelete( &loc_msg,
                                        cnst.env_info),
                                        senderid = NULL_OBJID,
                                        targetid = plane.obj_id.objid,
                                        targetos = plane.obj_id.osnum  );
        plane.obj_id.objid = NULL_OBJID;
   }

   if(!retFlag)  __DBGpr_com("VSEdgeOrientation Failed");

   // Free the memory for all arrays
   if( pntInt ) { om$dealloc( ptr = pntInt );  pntInt  = NULL;}
   if( OrdPts ) { om$dealloc( ptr = OrdPts );  OrdPts  = NULL;}
   if( pntsId ) { om$dealloc( ptr = pntsId );  pntsId  = NULL;}
   if( PW     ) { om$dealloc( ptr = PW     );  PW      = NULL;}
return retFlag;
}
end implementation VDSroot;
