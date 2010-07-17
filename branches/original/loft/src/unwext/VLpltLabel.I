/* $Id: VLpltLabel.I,v 1.5 2001/10/23 19:05:34 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        loft/src/pcard/VLpltLabel.I
 *
 * Description: plate_label macro implementation.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLpltLabel.I,v $
 *      Revision 1.5  2001/10/23 19:05:34  ramarao
 *      Fixed TR# 5499.
 *
 *      Revision 1.4  2001/04/22 17:29:31  ramarao
 *      Changed all IBs to OB, if the plate crosses the centerline.
 *
 *      Revision 1.2  2001/04/17 21:32:46  ramarao
 *      Get the active text size for labels placement.
 *
 *      Revision 1.1  2001/04/16 17:00:32  ramarao
 *      Implemented CR#4086 on Auto Labeling.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/16/01        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include <math.h>
#include "bserr.h"
#include "bscvmidpt.h"
#include "bsmdstptcv.h"
#include "bscveval.h"
#include "bsmdistptsf.h"
#include "bspl_nor_tc.h"
#include "bsproj1.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "bsarclen.h"

#include "DIprims.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "EMSmsgdef.h"
#include "emsmapdef.h"
#include "VDobj.h"
#include "VDefp.h"
#include "VDmem.h"
#include "VDsa.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_pplslc.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vlquerydef.h"
#include "vllblloft.h"
#include "vldbgmacros.h"

extern GRclassid	OPP_VSplate_class_id, OPP_GRpoint_class_id;

extern IGRint	VLgetMacrosAtStep();

from ACpretend	import	ACfind_parent;

static IGRchar* GetProperDir( IGRint    ind )
{
   switch( ind )
   {
        case 1: return "AFT" ;
        case 2: return "FWD" ;
        case 3: return "IB"  ;
        case 4: return "OB"  ;
        case 5: return "DOWN"  ;
        case 6: return "UP";
   }
}

#define MAX_POINTS      10

IGRlong	  VLcheckIfCurveIsLyingOnSurface( struct GRobj_env   *plateOE,
					  struct GRobj_env   *crvOE,
					  struct GRmd_env    *cur_env  )
{
BSrc			rc;
IGRlong			sts, msg, num_pts;
IGRint			i, j, num_crv=0;
IGRchar			name[40];
IGRdouble		start_par, end_par, mid_par, par, mdist, cht_tol,
			points[30];
IGRpoint		start_pt, end_pt, mid_pt, pt;
GRobjid			*CURVES=NULL;
struct GRid		inter_cv;
struct GRobj_env	srfOE;
struct GRvg_construct	cst;
struct IGRpolyline 	polyLine;
struct IGRbsp_curve	*crvGeom=NULL;

   sts = MSFAIL;

   VDsupInitCnst( &cst );

   for( i=0; i<2; ++i )
   {
      if( i == 0 ) strcpy( name, VS_K_plBotSfPath );
      else	   strcpy( name, VS_K_plTopSfPath );

      vdobj$GetFoot( objOE    = plateOE,
                     footName = name,
                     footOE   = &srfOE );

      num_crv = 0;
      _FREE( CURVES );
      cst.geometry = NULL;

      VLproject_curve( &srfOE, crvOE, &cst, &num_crv, &CURVES );
      if( !num_crv ) continue;

      inter_cv.objid = CURVES[0];
      inter_cv.osnum = cst.env_info->md_id.osnum;

      if( vd_$is_ancestry_valid( object   = &inter_cv,
			      classid  = OPP_GRpoint_class_id ) ) continue;

      _FREE( crvGeom );
      vs$get_geometry( msg      = &msg, grobjId  = &inter_cv,
                       grobjEnv = cst.env_info, geometry = &crvGeom );
      MAbcendpts( &msg, crvGeom, start_pt, end_pt );
      BSmdstptcv( crvGeom, start_pt, &start_par, pt, &mdist, &rc );
      BSmdstptcv( crvGeom, end_pt, &end_par, pt, &mdist, &rc );

      mid_par = ( start_par + end_par ) * 0.5;
      BScveval( crvGeom, mid_par, 1, (IGRpoint *)mid_pt, &rc );

      polyLine.points = points;

      num_pts = MAX_POINTS;
      if( ! GRpybcueqspace( &rc, crvGeom, &num_pts, start_pt, end_pt, mid_pt,
			 &start_par, &end_par, &mid_par, &polyLine ) ) 
	continue;

      _FREE( crvGeom );
      vs$get_geometry( msg      = &msg, grobjId  = &crvOE->obj_id,
                       grobjEnv = &crvOE->mod_env, geometry = &crvGeom );

      vdgeom$GetTolerance( cht = &cht_tol );

      for( j=0; j<num_pts; ++j )
      {
         __DBGpr_vec( "Point", &points[3*j] );
         BSmdstptcv( crvGeom, &points[3*j], &par, pt, &mdist, &rc );
         __DBGpr_dbl( "Minimum Distance", mdist );
         if( mdist > cht_tol ) break;
      }
      vd_$bulk_delete( count=num_crv, objids = CURVES, theEnv = cst.env_info );
      num_crv = 0;
      _FREE( CURVES );
      if( j == num_pts ) 
      {
	 sts = MSSUCC;
	 break;
      }
   }

wrapup:
   if( num_crv )
     vd_$bulk_delete( count=num_crv, objids = CURVES, theEnv = cst.env_info );

   _FREE( crvGeom );
   _FREE( CURVES  );

   return sts;
}

static void 	VScheckAxisMostFollowed( IGRdouble	*vector,
					 GRrange	range,
					 IGRboolean	use_range,
					 IGRboolean	*reverse )
{
BSrc			rc;
IGRint			i, imax;
IGRdouble		tempVal, axis[3];
IGRboolean		y_positive;

   /*
    * Find the axis most followed.
    */
   tempVal = 0.0;
   for( i=0; i<3; ++i )
   {
     if( fabs( vector[i] ) > tempVal )
     {
        tempVal = fabs( vector[i] );
        imax = i;
     }
   }

   *reverse = FALSE;
   switch( imax )
   {
     case 0:       /* X - axis */
       axis[0] = 1.0; axis[1] = 0.0; axis[2] = 0.0;
       if( BSdotp( &rc, vector, axis ) < 0.0 )  *reverse = TRUE;
       break;

     case 1:       /* Y - axis */

       axis[0] = 0.0; axis[1] = 1.0; axis[2] = 0.0;

       if( use_range == TRUE )
       {
          __DBGpr_vec( "Low Range Point", &range[0] );
          __DBGpr_vec( "High Range Point", &range[3] );

          if( ( range[1] > 1e-3 ) && ( range[4] > 1e-3 ) )  y_positive = TRUE;
          else						 y_positive = FALSE;

          if( BSdotp( &rc, vector, axis ) < 0.0 && !y_positive )  
		*reverse = TRUE;
          if( BSdotp( &rc, vector, axis ) > 0.0 &&  y_positive )  
		*reverse = TRUE;
       }
       else
       {
	 if( BSdotp( &rc, vector, axis ) < 0.0 )  *reverse = TRUE;
       }
       break;

     case 2:       /* Z - axis */
       axis[0] = 0.0; axis[1] = 0.0; axis[2] = 1.0;
       if( BSdotp( &rc, vector, axis ) < 0.0 )  *reverse = TRUE;
       break;
   }
   __DBGpr_vec( "Orientation Vector", vector );
   __DBGpr_int( "Reverse?", *reverse );

   return;
}

IGRlong		VScreateLabels( struct GRobj_env	plateOE,
				struct GRid		neat_cont,
				struct GRmd_env		*cur_env,
				IGRint			*numLabels,
				LabelInfo		**labelInfo )
{
BSrc			rc;
IGRlong			sts, msg;
IGRint                  i, j, edgeCnt=0, *edgeDir =NULL, txtLen, txtBytes,
			bytesRet, properties, numObjects=0, plateCount=0,
			feet_size;
IGRdouble		tol, mid_par, orient[9], tmp, dist, par[2], start_par,
			end_par, offsetVal=0.0, fontSize=25.0, arc_length;
IGRboolean      	flag, bool_stat, reverse, not_first, 
			world=TRUE, use_range;
IGRchar			text[40], footName[40];
IGRpoint		mid_pnt, pnt, plnNorm, plnPnt, lblPnt, center, 
			start_pt, end_pt;
IGRmatrix		rotMatrix;
GRrange			loc_range, range;
struct GRobj_env        srfOE, *edgeOEs=NULL, *list_obj=NULL,
			parentOE, *plateList=NULL;
struct GRsymbology    	symb ;
struct GRdpb_text_symb 	txtSymb ;
struct IGRbsp_curve     *edgeGeom[VDEFP_NEAT_EDGES_MAX];
struct IGRbsp_surface	*srfGeom=NULL;

   SetProc( VSassignLabels ); Begin

   sts = msg = MSSUCC;

   *numLabels = 0;
   (*labelInfo) = NULL;

   for( i=0; i<VDEFP_NEAT_EDGES_MAX; ++i )  edgeGeom[i] = NULL;

   __DBGpr_obj( "Input Plate", plateOE.obj_id );
   vdgeom$GetTolerance(cht = &tol);

   vdobj$GetFoot( objOE    = &plateOE,
                  footName = VS_K_plBotSfPath,
                  footOE   = &srfOE );
   if( srfOE.obj_id.objid == NULL_OBJID ) goto wrapup;
   srfOE.mod_env = plateOE.mod_env;
   __DBGpr_obj( "Base Surface", srfOE.obj_id );

   feet_size = 0;
   om$get_channel_count( osnum = neat_cont.osnum,
                         objid = neat_cont.objid ,
                         p_chanselect = &AC_mto_graf_chns,
                         count = (OMuint *)&feet_size );
   edgeCnt = feet_size / 2 ;
   __DBGpr_int("Number Of Neat Edges ", edgeCnt );

   if( !edgeCnt ) goto wrapup;

   if( !(edgeOEs = _MALLOC( edgeCnt, struct GRobj_env )) )
        vd_$mem_fail( msg = &msg );

   if( !(edgeDir = _MALLOC( edgeCnt, IGRint )) )
        vd_$mem_fail( msg = &msg );

   for( i=0; i<edgeCnt; ++i )
   {
      sprintf( footName, "Curve%d", i+1 );
      vdobj$GetFoot( objID    = &neat_cont,
		     footName = footName,
		     footOE   = &edgeOEs[i] );
      sts = VLgetGeometry( &edgeOEs[i], FALSE, NULL_OBJID, 
			   (IGRchar **)&edgeGeom[i], &msg );

      sprintf( footName, "Dir%d", i+1 );
      vdsa$GetStruct( objID = &neat_cont,
		      name  = footName,
		      jnt   = &edgeDir[i]  ); 
   }

   not_first = FALSE ;
   for( i=0; i<edgeCnt; ++i )
   {
      sts = om$send ( msg = message GRvg.GRgetrang( &msg,
                                &cur_env->md_env.matrix_type,
                                 cur_env->md_env.matrix, &world, loc_range ),
                        senderid = NULL_OBJID,
                        targetid = edgeOEs[i]._objid,
                        targetos = edgeOEs[i]._osnum );
      if( !(sts&1&msg) ) continue;
      if( not_first ) GRaccumulate_range( &msg, loc_range, range );
      else
      {
          not_first = TRUE ;
          dblcpy( range, loc_range, 6 );
      }
   }

   /*
    * Check if the plate is crossing the centerline.
    * Change all IB to OB.
    */
   if( range[1] < 1e-3 && range[4] > 1e-3 )
   {
      for( i=0; i<edgeCnt; ++i )
	if( edgeDir[i] == 3 ) edgeDir[i] = 4;
   }

   if( edgeCnt == 1 && edgeGeom[0]->phy_closed )
   {
      sts = om$send(msg     = message GRvg.GRcenter (
                              &msg, &edgeOEs[0]._matrix_type,
                              edgeOEs[0]._matrix, center ),
                senderid = NULL_OBJID ,
                targetid = edgeOEs[0].obj_id.objid,
                targetos = edgeOEs[0].obj_id.osnum );
   }
   else
   {
      for( j=0; j<3; ++j ) center[j] = 0.0;

      for( i=0; i<edgeCnt; ++i )
      {
	 BScvmidpt( edgeGeom[i], &mid_par, mid_pnt, &rc ) ;
	 if( rc != BSSUCC ) continue ;
	 for( j=0; j<3; ++j ) center[j] += mid_pnt[j];
      }
      for( j=0; j<3; ++j ) center[j] /= edgeCnt;
   }
   __DBGpr_vec( "Edges Center Point", center );

   VLbrowseFctInTree( &plateOE, VL_Q_TOP_SOURCE, NULL, VL_Q_DOWN_DIRECT,
                      VLgetMacrosAtStep, &numObjects, &list_obj );
   VLfilterDef(numObjects,list_obj,&numObjects,"Mark");

   plateCount = 0;
   if( numObjects )
   {
      if( !(plateList = _MALLOC( numObjects, struct GRobj_env )) )
          vd_$mem_fail( msg = &msg );

      for( i=0; i<numObjects; ++i )
      {
	 vdobj$GetParent( objOE    = &list_obj[i], 
			  idx      = 2, 
			  parentID = &parentOE.obj_id );

	 if(  parentOE._objid == plateOE.obj_id.objid  &&
              parentOE._osnum == plateOE.obj_id.osnum  )
	 {
            vdobj$GetTemplate( objOE      = &list_obj[i],
                               nth        = 1,
                               templateOE = &parentOE );

            if( vd_$is_ancestry_valid( object  = &parentOE.obj_id,
                                       classid = OPP_ACpretend_class_id ))
	    {
		sts = om$send( msg     = message ACpretend.ACfind_parent(
					   &parentOE.obj_id,
					   &parentOE._matrix_type,
					   parentOE._matrix ),
			       senderid = parentOE._objid,
			       targetid = parentOE._objid,
			       targetos = parentOE._osnum  );
		parentOE._md_os = parentOE._osnum;
		ex$get_modid( mod_osnum = parentOE._md_os,
                              mod_id    = &parentOE._md_id ) ;
	    }
	    plateList[plateCount++] = parentOE;
	    __DBGpr_obj("Neighbouring Plate", parentOE.obj_id );
	 } 
      }
   }
   __DBGpr_int("Neighbour Plate Count", plateCount );

   vs$get_geometry( msg      = &msg,
                    grobjId  = &srfOE.obj_id,
                    grobjEnv = &srfOE.mod_env,
                    geometry = &srfGeom		);

   *numLabels = 0;
   if( !( (*labelInfo) = _MALLOC( edgeCnt, LabelInfo )) )
        vd_$mem_fail( msg = &msg );

   for( i=0; i<edgeCnt; ++i )
   {
       __DBGpr_int( "Checking Edge Index", i );
       __DBGpr_obj( "Edge Object", edgeOEs[i].obj_id );

       (*labelInfo)[*numLabels].edgeLength = 0;
       (*labelInfo)[*numLabels].hole = FALSE;
       (*labelInfo)[*numLabels].labelID.objid = NULL_OBJID;
       (*labelInfo)[*numLabels].edgeID.objid = NULL_OBJID;
       (*labelInfo)[*numLabels].plateOE._objid = NULL_OBJID;
       strcpy( (*labelInfo)[*numLabels].labelString, "" );

       MAbcendpts( &msg, edgeGeom[i], start_pt, end_pt );

       BSmdstptcv( edgeGeom[i], start_pt, &start_par, pnt, &dist, &rc );
       BSmdstptcv( edgeGeom[i], end_pt, &end_par, pnt, &dist, &rc );

       mid_par = ( start_par + end_par ) * 0.5;
       arc_length = 0.0;
       sts = BSarclen( &rc, &bool_stat, edgeGeom[i], &start_par, &end_par,
                       &mid_par, &arc_length );
       __DBGpr_dbl( "Arc Length", arc_length );

       if( arc_length < 300.0 ) continue;

       for( j=0; j<plateCount; ++j )
       {
	  if( VLcheckIfCurveIsLyingOnSurface( &plateList[j], &edgeOEs[i],
				cur_env ) == MSSUCC )
	  {
	      (*labelInfo)[*numLabels].plateOE = plateList[j];

	     __DBGpr_obj( "Plate Object", plateList[j].obj_id );
             vd$ppl_set_size( which_info = INPUT_INFO,
                              size       = 1 );

	     vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                               	     index      = 0,
                               	     type       = VD_object,
                               	     value      = &plateList[j] );

	     vd$ppl_exec( file_name = "COz_lblInfo",
			  func_name = "main" );

             vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
                                     index      = 0,
                                     value      = text );

	     vd$ppl_free_args( which_info = INPUT_INFO );
             vd$ppl_free_args( which_info = OUTPUT_INFO );

	     break;
	  }
       }
       if( j == plateCount ) strcpy( text, GetProperDir( edgeDir[i] ) );
       __DBGpr_str( "Label String for this Edge", text );

       BScvmidpt( edgeGeom[i], &mid_par, mid_pnt, &rc ) ;
       if( rc != BSSUCC ) continue ;

        // find a point on srfGeom which has minimum distance to Mid Point
        BSmdistptsf( &rc, srfGeom, mid_pnt, &par[0], &par[1], pnt, &dist ) ;
        if( rc != BSSUCC ) continue ;

        // Get srf normal at the point found from above
        vs$get_normal( msg    = &msg ,
                       sfId   = &srfOE.obj_id ,
                       sfEnv  = &srfOE.mod_env ,
                       parm   = par ,
                       normal = &orient[6] ) ;
        if ( !(msg&1) ) continue ;
	__DBGpr_vec( "Surface Normal", &orient[6] ) ;
        /*
         * Find the axis most followed.
         */
	reverse = FALSE;
	use_range = TRUE;
	VScheckAxisMostFollowed( &orient[6], range, use_range, &reverse );
        if( reverse )
        {
          for( j=0; j<3; ++j ) orient[6+j] *= -1.0;
	  __DBGpr_vec( "Surface Normal after reversal", &orient[6] ) ;
        }

        // Make a plane perpendicular to the edge at mid point
        flag = FALSE ; tmp = 1. ;
        BSpl_nor_tc( &rc, edgeGeom[i], &mid_par, &flag, 
		     &tmp, plnPnt, plnNorm, NULL);
        if( rc != BSSUCC ) goto wrapup ;

        // Project center to mid plane to get projected point pnt
        BSproj1( &rc, center, plnNorm, plnPnt, pnt ) ;
        if( rc != BSSUCC ) goto wrapup ;

	__DBGpr_vec( "Edge Mid Point", mid_pnt );
	__DBGpr_vec( "Center Point", pnt );

        // Make a unit vector, &orient[3], from edge MidPnt to pnt,
        BSmkvec (&rc, &orient[3], mid_pnt, pnt ) ;     // make vector
        if( rc != BSSUCC ) continue ;
        BSnorvec(&rc, &orient[3] ) ;                    // normalize vector
        if( rc != BSSUCC ) continue ;
	__DBGpr_vec( "Vector From edge mid point to projected point",
			&orient[3] );

        // Make a unit vector, &orient[0], by cross product of &[3] and &[6]
        BScrossp( &rc, &orient[3], &orient[6], &orient[0] ) ;
        if( rc != BSSUCC ) continue ;
	__DBGpr_vec("Cross Product", &orient[0] ) ;

        // Set label point along &orient[2] to edgeGeom with distance fontSize
        for( j=0; j<3; ++j )
          lblPnt[j] = ( mid_pnt[j] + orient[j]*offsetVal +
                        orient[j+3]*fontSize );
        __DBGpr_vec( "Label Point", lblPnt );

	/*
	 * Find the axis most followed.
	 */
        reverse = FALSE;
	use_range = FALSE;
        VScheckAxisMostFollowed( &orient[0], range, use_range, &reverse );
        if( reverse )
        {
	  for( j=0; j<3; ++j ) orient[j] *= -1.0;
	  BScrossp( &rc, &orient[6], &orient[0], &orient[3] ) ;	
	  __DBGpr_vec("Cross Product after reversal", &orient[3] );
	}

	dblcpy( (*labelInfo)[*numLabels].labelPoint,  lblPnt, 3 );

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

        // Get text symbology
        txtBytes = sizeof(text) ;
        txtLen   = strlen(text) ;
        gr$get_text_symb( msg   = &msg ,
                        sizbuf  = &txtBytes ,
                        buffer  = &txtSymb ,
                        nret    = &bytesRet ) ;
        if( !(msg&1) ) continue;

        (*labelInfo)[*numLabels].labelID.objid = NULL_OBJID ;
	(*labelInfo)[*numLabels].labelID.osnum = cur_env->md_id.osnum ;
        sts = om$construct( classname = "GR3dtext" ,
                       osnum     = (*labelInfo)[*numLabels].labelID.osnum,
                       p_objid   = &(*labelInfo)[*numLabels].labelID.objid );
        if( !(sts&1) || (*labelInfo)[*numLabels].labelID.objid == NULL_OBJID ) 
		continue;

        txtSymb.Active_just   = CENTER_CENTER ;
        txtSymb.Active_flags  = GRFILLED_TEXT ;
        properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        VDahGetActiveSymbology(&symb);

        co$place_text(  msg             = &msg ,
                        text_string     = text ,
                        text_length     = &txtLen ,
                        rot_matrix      = rotMatrix ,
                        ActiveDisplay   = &symb.display_attr ,
                        ActiveLevel     = symb.level ,
                        Properties      = &properties ,
                        TextSymb        = &txtSymb ,
                        ActiveAngle     = 0. ,
                        ModuleInfo      = cur_env,
                        origin          = lblPnt ,
                        flags           = 1 ,
                        buffer          = &(*labelInfo)[*numLabels].labelID );
	__DBGpr_obj( "Text ID", (*labelInfo)[*numLabels].labelID );
	strcpy( (*labelInfo)[*numLabels].labelString, text );
	(*labelInfo)[*numLabels].edgeLength = arc_length;
	(*labelInfo)[*numLabels].edgeID = edgeOEs[i].obj_id;
	(*numLabels)++;
   }
   __DBGpr_int( "Number of Labels", *numLabels );

wrapup:
   for( i=0; i<edgeCnt; ++i )   _FREE( edgeGeom[i] );
   _FREE( list_obj  );
   _FREE( plateList );
   _FREE( srfGeom   );
   _FREE( edgeOEs   );
   _FREE( edgeDir   );

   End
   return sts;
}

end implementation VDSroot;
