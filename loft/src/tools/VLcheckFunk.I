/* $Id: VLcheckFunk.I,v 1.5 2001/08/25 22:24:21 ramarao Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:	src/tools/VLcheckFunk.I
 *
 * Description:
 *     The file is used in "unwrap surface" when object are selected 
 *	automatically .
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLcheckFunk.I,v $
 *	Revision 1.5  2001/08/25 22:24:21  ramarao
 *	Implemented CR# 4044.
 *	
 *	Revision 1.4  2001/02/20 01:06:29  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.3  2001/01/29 21:04:17  jayadev
 *	VDdrawingExtractFeatures() moved from VLcheckFunk.I to here
 *	
 *	Revision 1.2  2001/01/16 19:44:09  ramarao
 *	*** empty log message ***
 *	
# Revision 1.8  2000/11/02  21:09:32  pinnacle
# Replaced: loft/src/tools/VLcheckFunk.I for:  by rchennup for Service Pack
#
# Revision 1.7  2000/10/31  23:59:42  pinnacle
# Replaced: loft/src/tools/VLcheckFunk.I for:  by rchennup for Service Pack
#
# Revision 1.5  2000/08/26  16:26:46  pinnacle
# Replaced: loft/src/tools/VLcheckFunk.I for:  by jpulapar for Service Pack
#
# Revision 1.4  2000/05/19  18:37:24  pinnacle
# Replaced: loft/src/tools/VLcheckFunk.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/22  23:45:12  pinnacle
# Created: loft/src/tools/VLcheckFunk.I by rchennup for Service Pack
#
# Revision 1.14  2000/04/03  21:05:32  pinnacle
# Replaced VLcheckFunk.I by jpulapar
#
# Revision 1.13  2000/03/30  15:40:34  pinnacle
# Replaced: src/tools/VLcheckFunk.I for:  by impd252 for loft
#
# Revision 1.11  2000/02/18  16:41:34  pinnacle
# (No comment)
#
# Revision 1.9  2000/02/15  19:34:54  pinnacle
# (No comment)
#
# Revision 1.8  2000/02/10  21:48:22  pinnacle
# (No comment)
#
# Revision 1.7  2000/01/19  23:10:50  pinnacle
# (No comment)
#
# Revision 1.6  1999/12/30  12:36:22  pinnacle
# Replaced VLcheckFunk.I for TR179900775 by jpulapar for loft
#
# Revision 1.5  1999/07/28  15:51:14  pinnacle
# tr179900775
#
# Revision 1.4  1999/06/01  14:55:52  pinnacle
# Fix integrated for Jayadev.
#
# Revision 1.3  1999/04/09  21:24:54  pinnacle
# Rama Rao SP08
#
# Revision 1.2  1998/11/05  07:52:44  pinnacle
# Replaced: src/tools/VLcheckFunk.I for:  by manoj for loft
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/10/98  Manoj   1. header added 
 *		     2. VLcurve_on_surface() modified. 
 *					   Earlier cases of straight line 
 *					   and curve were handled separately.
 *					   There was a bug in case of 
 *					   straight line.
 *					   Now, the algo is independent of 
 *					   straight line or curve case.	
 *					   Earlier, the distance between nodal 
 *					   point of curve and surface was being
 *					   found. It was changed ( by calling 
 *					    a different bsmath function ) to
 *				           finding distance between curve 
 *					  and surface. 
 *				          Then parameters of the minimum 
 *					  distance point is examined. If the 
 *				          minimum distance point is at the 
 *					   boundary of the surface, another 
 *	                                   points at +NEXT_PT and -NEXT_PT  parametr value
 *					   is selected and distance from 
 *					   surface is calculated.  
 * 04/09/99  ah  Rama Rao SP08 Fixes
 * 06/01/99  Jayadev  TR#179900638         Tolerance value changed from plate
 *					   thickness to zero
 *
 * 07/26/99  Jayadev  Some plates not      SURF_BOUND value changed from 0.02 to
 *                    marking in testcase  0.0001. Tolerance value changed from
 *                    for TR#179900775     plate thickness to zero inside the 
 *                                         function VLcheckStiffOnPlate
 * 10/04/99  Jayadev                       VLcurve_on_surface modified to take
 *                                         care of closed bspline curves
 * 11/10/99  Jayadev  for TR179900910      changes made for curved surfaces
 * 12/22/99  RamaRao  for dup markings     Avoid consumed entities from marking
 *                    check employed inside VLcheckStiffOnPlate function
 * 01/19/00  RamaRao  for ProfileCards	   In VLgetOperName, hard coded PartMark
 * 02/10/00  RamaRao  Performance fixes.
 * 02/15/00  RamaRao  TR#179901061 & 62    If the minimum distance between curve *					   and surface is 0, then num=1
 * 04/03/00  Jayadev  marking problems     VLcurve_on_surface notified whether 
 *		      of unit 2131         the stiffener is a plate/beam
 * 04/22/00  Jayadev  cleanup of waste graphics
 * 01/29/00  Jayadev  VDdrawingExtractFeatures() and VLfindAndExtract()
 *		      moved to VDgetownobj.I 
 ***************************************************************************/
class implementation GRvg ;

#include <stdio.h>
#include "math.h"
#include "vlprototype.h"
#include "madef.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "godef.h"
#include "grgsdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "comiscmac.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "ACattrib.h"
#include "parametric.h"
#include "bserr.h"

#include "VDobj.h"
#include "vdprdmacros.h"
#include "v_drwprocess.h"
#include "vsattr.h"
#include "vsplatedef.h"
#include "vsplate.h"
#include "vsstrngproto.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"
#include "vsoptdef.h"

#include "v_geommacros.h"
#include "vsmiscmacros.h"

#include "vlglinedef.h"
#include "vlquerydef.h"

#include "bsparameters.h"
#include "bsbasisvect.h"
#include "bsbx2.h"
#include "bscveval.h"
#include "bsdotp.h"
#include "bsmdistptcv.h"
#include "bsnorvec.h"

#include "maidmx.h"
#include "mainvmx.h"
#include "mamulmx.h"

#include "DIdef.h"
#include "macro.h"
#include "acmacros.h"
#include "vsgeommacros.h"
#include "vsedgedef.h"
#include "vsedgemacros.h" // ref TR 179801431: for get-surface_edges
#include "bscvarrev0.h" // ref TR 179801431
#include "bsmdistptsf.h" //ref TR 179801431
#include "bsxtractpar.h" // ref TR 179801431
#include "vldbgmacros.h" // ref TR 179801431

#define vdsDEBUG    1
#define vdserrDEBUG 1

#define SURF_TOL 4 // dist less than this is called touching

/* TR179900775 Changed from .02 */
#define SURF_BOUND  0.0001 // fraction of length/width of plate.
			 // if a curve entirelybelongs to this strip ,
			 // it is considered to be on the boundary of the plate.

#define NEXT_PT 0.05 // the parametric fraction of a curve that must 
		    // touch the surface, in order to qualify the object 
		    // for marking. MUST BE BETWEEN 0 and 1

from	ACcpx		import	find_macro;
from	ACcpx_defn	import	ACgive_name;
from	NDmacro		import	ACgive_structure,ACtest_consumed;
from	GRreffile	import	GRgetenvironment;
from	EMSgenbs	import	EMplace_skinning_surface;
from	NDmacro		import	ACreturn_foot;

from    VSfeature       import  VSgetSupportedElements;
from    VSfeature       import  VSforwardToOriginal;
from    VSbeam		import  VSgetSupportAxis;
from    EMSsubbs	import  EMget_boundaries;

extern	GRclassid	OPP_GRgraphics_class_id, OPP_ACncpx_class_id,
			OPP_GRreffile_class_id,  OPP_EMSgenbs_class_id,
			OPP_GR3dcircle_class_id, OPP_VSbeam_class_id,
			OPP_VSplate_class_id,    OPP_GRcurve_class_id,
			OPP_VLmrkLine_class_id,  OPP_VLwatLine_class_id,
			OPP_GRlineseg_class_id;

extern	IGRdouble	fabs();

int VLcheckIfPtInBndry( struct IGRbsp_surface   *surf,
			IGRdouble		u,
			IGRdouble		v )
{
IGRlong			msg;
IGRint			i, ind, inBoundary = 0;
IGRboolean		orient;
IGRdouble		pt[3], num_pt, *bnd_pts = NULL;
struct IGRpolyline	polyline;

   SetProc( VLcheckIfPtInBndry  ); Begin 

   if( !surf ) goto wrapup;

   __DBGpr_int("Boundary Count ", surf->num_boundaries );
   if( surf->num_boundaries < 1 ) goto wrapup;
   num_pt = surf->bdrys[0].num_points;
   __DBGpr_int("Number of points in Boundary ", num_pt );

   pt[0] = u;
   pt[1] = v;
   pt[2] = 0.0;

   if( !( bnd_pts = _MALLOC( 3*num_pt, IGRdouble )) ) goto wrapup;

   for( i=0; i<num_pt; ++i )
   {
      bnd_pts[3*i]   = surf->bdrys[0].points[2*i] ;
      bnd_pts[3*i+1] = surf->bdrys[0].points[2*i+1] ;
      bnd_pts[3*i+2] = 0.0;
   }

   polyline.num_points = num_pt;
   polyline.points     = bnd_pts;

   BSpt_in_plg( polyline, pt, FALSE, &orient, &ind, &msg );
   if( msg != BSSUCC ) goto wrapup;

   __DBGpr_int( "BSpt_in_plg returns ", ind );

   if( ind == 1 )  inBoundary = 1;

wrapup:
   _FREE( bnd_pts );
   __DBGpr_int("VLcheckIfPtInBndry returns ", inBoundary );
   End
   return inBoundary;
}

int VLcurve_on_surface( long		 *msg,
			struct GRobj_env *crv,
			struct GRobj_env *srf,
  			double		  tol,
			IGRboolean        is_stif_plate, // stiff is a plate
  			BSrc		 *rc )

{
  int			 sts, result = FALSE;
  double		 bastol= 0.0, 
			 chtol= 0.0, 
			 max_tol = tol;
  struct IGRbsp_curve   *org_curve = NULL, *curve=NULL;
  struct IGRbsp_surface *surf  = NULL;
   IGRdouble             *part =NULL;
   IGRdouble             *paruv =NULL;
   IGRpoint              *cpt =NULL,
                         *sfpt =NULL;
   IGRint                i, is_planar = TRUE;

  *msg    = MSSUCC;
  *rc     = BSSUCC;

  BSxtractpar( rc, BSTOLBASIS, &bastol );
  BSxtractpar( rc, BSTOLCHRDHT, &chtol );

  if ( tol <  0.0 ) tol = fabs (tol);

  if ( tol == 0.0 ) {
    tol = chtol ;
  } else if ( tol < bastol )
  {
    tol = bastol ;
  }
  /*
   * If max_tol is too large ==>> problems on CLIX with function BSmdptbssf(), so adjust if necessary
   */
  if ( max_tol / bastol > 1000. ){
	max_tol = bastol * 1000.;
	}

  /*
   * Check if surface is really a surface
   */
  if ( ! vs$is_ancestry_valid ( object  = &srf->obj_id, 
				 classid = OPP_EMSsubbs_class_id ) )
  {
    printf ( "Selected object is not a surface\n" );
    *msg = MSFAIL ;
    goto wrapup;
  } else {
     /*
      * Get the geometry data for the surface
      */
/*
     sts = vd_$get_geometry ( msg      =  msg,
			   grobjId  = &srf->obj_id,
			   grobjEnv = &srf->mod_env,
			   geometry = &surf );
*/
        sts = VLgetGeometry( srf, TRUE, NULL_OBJID,
                             (IGRchar **)&surf, msg );
        __CheckRC( sts, *msg, "VLgetGeometry", wrapup );

        if ( ! ( sts & *msg & 1 ) )
        {
          //printf("Problem with getting surface geometry\n"); //debug
          *msg = MSFAIL ;
          //printf(" Going to wrapup %d \n", __LINE__);
          goto wrapup;
        }

     }
   // check if the surface is planar or not - TR179900910
   if(srf->obj_id.objid != NULL_OBJID)
   {
	   is_planar = vs$is_surface_planar( msg = msg,
				     surfId  = &srf->obj_id,
				     surfEnv = &srf->mod_env ) ;
										   }

  /*
   * Check if curve is really a curve
   */
  if ( ! vs$is_ancestry_valid ( object  = &crv->obj_id, 
				classid = OPP_GRcurve_class_id ) ){
    printf ( "Selected object is not a curve\n" );
    *msg = MSFAIL ;
    //printf(" Going to wrapup \n");
    goto wrapup;
  }
 
  /*
   * Get the geometry data for the curve
   */
  sts = vd_$get_geometry ( msg      =  msg,
			   grobjId  = &crv->obj_id,
			   grobjEnv = &crv->mod_env,
			   geometry = &org_curve );

  if ( ! ( sts & *msg & 1 ) ) {
    //printf("Problem with getting curve geometry\n");
    *msg = MSFAIL ;
    //printf(" Going to wrapup %d \n", __LINE__);
    goto wrapup;
  }
  
   { 
    IGRint                num = 0;
    IGRdouble             dist=0;

    if( org_curve->num_poles > 400 )
    {
        IGRint                  tanl, tanr;
        IGRboolean              option ;
        IGRdouble               maxerr, avgerr, par, apar;
        IGRpoint                pt, apt;
        IGRvector               tangentl, tangentr;

        tanl   = 1 ;
        tanr   = 1 ;
        option = TRUE ;

        BSdta_rducv( org_curve, tanl, tanr, tangentl, tangentr, option, &maxerr,
                     &avgerr, &par, pt, &apar, apt, &curve, rc ) ;
    }
    else
    {
        BSalloccv( org_curve->order, org_curve->num_poles, org_curve->rational,
                   org_curve->num_boundaries, &curve, rc );

        BScv_copy( rc, org_curve, curve );
    }

//  printf(" result = %d \n", result); //debug
    BSmdistcvsf(curve,surf,&num,&part,&paruv,&cpt,&sfpt,&dist,rc);
    if( dist < 1e-4 ) num = 1;
//    printf (" \n dist = %f \n", dist ); // debug
 //   printf (" \n paruv[0] = %f \n", paruv[0] ); // debug
  //  printf (" \n paruv[1] = %f \n", paruv[1] ); // debug

    if ( BSSUCC != *rc ) {
       *msg = MSFAIL ;
       //printf(" Going to wrapup %d \n", __LINE__);
       goto wrapup ; 
    }

    if(!is_planar) num = 1; // for curved surfaces skip this check TR179900910
	if ( dist < tol && num == 1 ){
    	    IGRdouble           pars[2],tmp_par=0.0; 
    	    IGRint              num_pars = 2;
    	    IGRdouble           *points;
	    int i;
	    points = _MALLOC(6, IGRdouble); 

	    pars[0] = part[0]- NEXT_PT; 
	    pars[1] = part[0]+ NEXT_PT; 
	    //  closed bspline curves considered
	    if ( pars[0] < 0 ) {
	      if(curve->phy_closed)
	      {
                tmp_par = pars[1];
                pars[1] = 1-NEXT_PT;
                pars[0] = tmp_par;
	      }
	      else
	      {
		pars[0] = pars[1];
                num_pars = 1;
	      }
	    }
	    if ( pars[1] > 1 ) {
	      if(curve->phy_closed)
	      {
		tmp_par = pars[0];
		pars[0] = NEXT_PT;
		pars[1] = tmp_par;
	      }
	      else
	      {
                num_pars = 1;
	      }
	    }
	    
	    //printf(" num_pars = %d \n", num_pars);
	    BScvarrev0(rc,curve,pars,num_pars,points);
    	    if ( BSSUCC != *rc ) {
       	    	    *msg = MSFAIL ;
       	   	     //printf(" Going to wrapup %d \n", __LINE__);
       	   	     goto wrapup ; 
	    }

	    for ( i = 0 ; i < num_pars ; i++ ) {
                IGRdouble u, v  ;
		IGRdouble base[3],dist1= 0.0;
       	   	    // printf(" line %d \n", __LINE__);
		 BSmdistptsf(rc, surf,points + 3*i, &u,&v,base,&dist1); 
    	         if ( BSSUCC != *rc ) {
       	    	    *msg = MSFAIL ;
//       	   	     printf(" Going to wrapup %d \n", __LINE__); //debug
       	   	     goto wrapup ; 
	         }
//		 printf(" dist1 = %f \n", dist1); // debug
//		 printf(" tol = %f \n", tol); // debug
	         if ( dist1 < tol ) {
			// The following  cases would be true 
		        // if the curve is on the boundary of the surface
		if(is_stif_plate){
			if( paruv[0] < SURF_BOUND && u < SURF_BOUND) 
			      goto wrapup;
			if( paruv[0] >  1 - SURF_BOUND && u > 1- SURF_BOUND) 
			      goto wrapup;
			if( paruv[1] < SURF_BOUND && v < SURF_BOUND) 
			      goto wrapup;
			if( paruv[1] >  1 - SURF_BOUND && v > 1- SURF_BOUND) 
			      goto wrapup;
			result = TRUE ;
		}
			else result = TRUE;
		 //printf(" Made true   \n"); // debug
		   }
		   else 
		   {
			if(is_stif_plate){
			if( VLcheckIfPtInBndry( surf, paruv[0], paruv[1] ) )
				result = TRUE ;
			}
			else result = TRUE;
		   }
	   } 
     
     _FREE(points);
     } else {
	// num1 > 1  means the curve is panetarting the surface
	//??in case of marking 
	__DBGpr_com(" Penetrating through the surface\n");
     }
  
 } //scope  
    


wrapup : 
  _FREE( org_curve ) ;
  if( curve ) { BSfreecv( rc, curve ); curve = NULL; }
  for( i=0; i<surf->num_boundaries; ++i ) _FREE( surf->bdrys[i].points );
  _FREE( surf->bdrys );
  _FREE( surf  ) ;
  _FREE(part);
  _FREE(paruv);
  _FREE(cpt);
  _FREE(sfpt);
  //printf(" result = %d \n", result); //debug

  return result ;
}/* VLcurve_on_surface */


/* ********************* FCT VLinterCvSf() ************************	*/
long VLinterCvSf (	struct	GRobj_env	*cv,
			struct	GRobj_env	*sf,
				short		trimSf,
			struct	GRmd_env	*locEnv,
				int		*count,
			struct	GRid		**inter	)

{
BSrc			bsrc;
long			sts, msg;
struct	IGRbsp_curve	*cvGeom;
IGRdouble		cvEval[6];
IGRdouble		xyz[9];
struct	GRvg_construct	cnst;
struct	GRid		arcId, skinId;
struct	GRlc_info	trcobj,	crsobj;
int			i;
struct IGRellipse	cirGeom;
IGRint			size_buf, size;
IGRdouble		activ_cht;


	/* Initialization */
	arcId.objid	= NULL_OBJID;
	skinId.objid	= NULL_OBJID;
	*count		= 0;
	*inter		= NULL;

	// get fisrt point cv position and tangent 
	sts = om$send(	msg	 = message GRvg.GRgenabsg(
						&msg,
						&cv->mod_env.md_env.matrix_type,
						cv->mod_env.md_env.matrix,
						(IGRchar**) &cvGeom ),
			targetid = cv->obj_id.objid,
			targetos = cv->obj_id.osnum,
			senderid = NULL_OBJID );
	if( ! (sts&msg&1))	return	MSFAIL;

	BScveval( cvGeom, 0., 1, (IGRpoint *)cvEval, &bsrc ); 

	BSbasisvect(&bsrc, &cvEval[3], &xyz[0], &xyz[3], &xyz[6]);

	// get cht
	size_buf = sizeof( IGRdouble );
	gr$get_chord_height_tolerance(	msg 	= &msg,
					sizbuf	= &size_buf,
					buffer	= &activ_cht,
					nret	= &size );
	activ_cht *= 10;

	cirGeom.prim_axis	= activ_cht;
	cirGeom.sec_axis	= cirGeom.prim_axis;
	for(i=0;i<3;i++)	cirGeom.origin[i] = cvEval[i];

	MAidmx(&msg, cirGeom.rot_matrix);
	cirGeom.rot_matrix[0] = xyz[3];
	cirGeom.rot_matrix[1] = xyz[6];
	cirGeom.rot_matrix[2] = xyz[0];

	cirGeom.rot_matrix[4] = xyz[4];
	cirGeom.rot_matrix[5] = xyz[7];
	cirGeom.rot_matrix[6] = xyz[1];

	cirGeom.rot_matrix[8] = xyz[5];
	cirGeom.rot_matrix[9] = xyz[8];
	cirGeom.rot_matrix[10] = xyz[2];

	VLinitCnst( &cnst );
	cnst.env_info	= locEnv;
	cnst.geometry   = (char *)&cirGeom;

	arcId.objid = NULL_OBJID;
	arcId.osnum = locEnv->md_id.osnum;

	sts = om$construct(     classid = OPP_GR3dcircle_class_id,
				osnum   = arcId.osnum,
				p_objid = &arcId.objid );

	sts = om$send(	msg 	 = message GRgraphics.GRaltconstruct(&cnst),
			targetid = arcId.objid,
			targetos = arcId.osnum,
			senderid = NULL_OBJID );
	if( ! (sts&1)){ sts = MSFAIL; goto wrapup; }

	// creation of skining sf
	cnst.geometry 	= NULL;
	skinId.objid	= NULL_OBJID;
	skinId.osnum 	= locEnv->md_id.osnum;

	crsobj.located_obj	= 	arcId;
	crsobj.module_info	= 	*locEnv;
	trcobj.located_obj	= 	cv->obj_id;
	trcobj.module_info	= 	cv->mod_env; 
	trcobj.geom_parms.polygon_inx = FALSE;

        sts = om$construct(     classid = OPP_EMSgenbs_class_id,
                                osnum   = skinId.osnum,
                                p_objid = &skinId.objid );

	sts = om$send(	msg	 = message EMSgenbs.EMplace_skinning_surface(
								&msg ,
								&cnst,
								1,
								&trcobj,
								1,
								&crsobj,
								TRUE,
								NULL,
								TRUE,
								FALSE,
								NULL,
								NULL ),
			targetid = skinId.objid,
			targetos = skinId.osnum,
			senderid = NULL_OBJID  );
	if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }

	// create intersection between skin and sf
	sts = VLcreateAllInter(	&msg,
				&sf->obj_id,
				&sf->mod_env,
				trimSf,
				&skinId,
				locEnv,
				1,
				count,
				inter,
				locEnv );

	sts = MSSUCC;

wrapup :

	if( arcId.objid != NULL_OBJID )
		om$send( msg	  = message GRgraphics.GRdelete( &msg, locEnv ),
			 targetid = arcId.objid,
			 targetos = arcId.osnum,
			 senderid = NULL_OBJID );
	if( skinId.objid != NULL_OBJID )
		om$send( msg	  = message GRgraphics.GRdelete( &msg, locEnv ),
			 targetid = skinId.objid,
			 targetos = skinId.osnum,
			 senderid = NULL_OBJID );

return	sts;
}

/* ******************** FCT VLcheckAngle() **********************	*/
/* control l'angle entre 2 courbes					*/

long VLcheckAngle( cv1, cv2, par1 )

struct GRobj_env	*cv1, *cv2;
double			par1;

{
long			sts, msg;
struct	IGRbsp_curve	*cvGeom;
double			cv1Eval[6];
double			cv2Eval[6];
short			nbInt, nbPars;
double			*pars, mdist, *intpars;
BSrc			bsrc;

	/* Initialization */
	pars	= NULL;
	intpars	= NULL;
	mdist	= 0;

	sts = om$send(	msg	 = message GRvg.GRgenabsg(
						&msg,
						&cv1->mod_env.md_env.matrix_type,
						cv1->mod_env.md_env.matrix,
						(IGRchar**) &cvGeom ),
			targetid = cv1->obj_id.objid,
			targetos = cv1->obj_id.osnum,
			senderid = NULL_OBJID );
	if( ! (sts&msg&1))	return	MSFAIL;

	BScveval( cvGeom, par1, 1, (IGRpoint *)cv1Eval, &bsrc ); 

	sts = om$send(	msg	 = message GRvg.GRgenabsg(
						&msg,
						&cv2->mod_env.md_env.matrix_type,
						cv2->mod_env.md_env.matrix,
						(IGRchar**) &cvGeom ),
			targetid = cv2->obj_id.objid,
			targetos = cv2->obj_id.osnum,
			senderid = NULL_OBJID );
	if( ! (sts&msg&1))	return	MSFAIL;
	
	BSmdistptcv( cvGeom, &cv1Eval[0], &nbInt, &nbPars, &pars, &mdist,
					&intpars, &bsrc );   
	if( bsrc != BSSUCC ){ sts = MSFAIL; goto wrapup; }

	BScveval( cvGeom, pars[0], 1, (IGRpoint *)cv2Eval, &bsrc ); 
	if( bsrc != BSSUCC ){ sts = MSFAIL; goto wrapup; }

	BSnorvec( &bsrc, &cv1Eval[3] );
	BSnorvec( &bsrc, &cv2Eval[3] );
 
	/* acos(0.999) = 2.56 Degrees */
	if (fabs(BSdotp(&bsrc, &cv1Eval[3], &cv2Eval[3])) > 0.999)
		sts = MSSUCC;
	else 	sts = MSFAIL;

wrapup :

	if( ! pars )	free( pars );
	if( ! intpars )	free( intpars );

return	sts;
}

/* ***************** FCT VLcheckGenLine() ************************	*/
/* This function check is the given genline lies on the plate.
/*
/* FCT RETURN : MSSUCC if anwers is Yes  else MSFAIL
/* */

long VLcheckGenLine( plate, genLine, locEnv )

struct	GRobj_env	*plate;		/* I  : Plate			*/
struct	GRobj_env	*genLine;	/* I  : genLine			*/
struct	GRmd_env	*locEnv;	/* I  : Observation Environment	*/

{
long			sts, msg;
struct	GRobj_env	sf, cv;
int			count;
struct	GRid		*inter;
short			four = 4;
double			tmp_mat[16];
int			i;

	/* Initialization */
	inter	= NULL;

	// get line
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
					&msg,
					MAN_GR_FEET,
					&cv.obj_id,
					&cv.mod_env.md_env.matrix_type,
					cv.mod_env.md_env.matrix ),
			targetid = genLine->obj_id.objid,
			targetos = genLine->obj_id.osnum,
			senderid = NULL_OBJID );
	cv.mod_env.md_id = genLine->mod_env.md_id;
	if( genLine->mod_env.md_env.matrix_type != MAIDMX ){

		for(i=0; i<16; i++) tmp_mat[i] = cv.mod_env.md_env.matrix[i];
		MAmulmx( &msg, &four, &four, &four,
			genLine->mod_env.md_env.matrix,
			tmp_mat,
			cv.mod_env.md_env.matrix );
	}

	// test with base
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
					&msg,
					VS_K_plBotSfPath,
					&sf.obj_id,
					&sf.mod_env.md_env.matrix_type,
					sf.mod_env.md_env.matrix ),
			targetid = plate->obj_id.objid,
			targetos = plate->obj_id.osnum,
			senderid = NULL_OBJID );
	sf.mod_env.md_id = plate->mod_env.md_id;
	if( plate->mod_env.md_env.matrix_type != MAIDMX ){

		for(i=0; i<16; i++) tmp_mat[i] = sf.mod_env.md_env.matrix[i];
		MAmulmx( &msg, &four, &four, &four,
			plate->mod_env.md_env.matrix,
			tmp_mat,
			sf.mod_env.md_env.matrix );
	}

	// check inter
	VLinterCvSf( &cv, &sf, 1, locEnv, &count, &inter );
	if( count ){
           struct  GRobj_env       cvRes;
           int                     j, k;
           for( j=0; j<count; ++j )
           {
                cvRes.mod_env   = *locEnv;
                cvRes.obj_id    = inter[j];

                // check angle
                for( k=0; k<11; ++k )
                {
                   sts = VLcheckAngle( &cvRes, &cv, k*0.1 );
                   if( sts == MSSUCC ) goto wrapup;
                }
           }
           goto wrapup;
	}

	// test with offset
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
					&msg,
					VS_K_plTopSfPath,
					&sf.obj_id,
					&sf.mod_env.md_env.matrix_type,
					sf.mod_env.md_env.matrix ),
			targetid = plate->obj_id.objid,
			targetos = plate->obj_id.osnum,
			senderid = NULL_OBJID );
	sf.mod_env.md_id = plate->mod_env.md_id;
	if( plate->mod_env.md_env.matrix_type != MAIDMX ){

		for(i=0; i<16; i++) tmp_mat[i] = sf.mod_env.md_env.matrix[i];
		MAmulmx( &msg, &four, &four, &four,
			plate->mod_env.md_env.matrix,
			tmp_mat,
			sf.mod_env.md_env.matrix );
	}

	// check inter
	VLinterCvSf( &cv, &sf, 1, locEnv, &count, &inter );
        if( count ){
           struct  GRobj_env       cvRes;
           int                     j, k;
           for( j=0; j<count; ++j )
           {
                cvRes.mod_env   = *locEnv;
                cvRes.obj_id    = inter[j];

                // check angle
                for( k=0; k<11; ++k )
                {
                   sts = VLcheckAngle( &cvRes, &cv, k*0.1 );
                   if( sts == MSSUCC ) goto wrapup;
                }
           }
           goto wrapup;
        }

	sts = MSFAIL;

wrapup :

	if( inter ){

		for(i=0; i<count; i++)
		 om$send( msg = message GRgraphics.GRdelete( &msg, locEnv ),
			 targetid = inter[i].objid,
			 targetos = inter[i].osnum,
			 senderid = NULL_OBJID );
		free( inter );
	}

return	sts;
}

/* *********************** FCT VLcheckStiffMac() *********************	*/
/*
/* This function check if the main foot of Macro is coplanar to the
/* web_left side of the stiffner.
/*
/* FCT RETURN : MSSUCC if macro is on striffner else MSFAIL
/*
/* */ 
 
long VLcheckStiffMac( 

struct	GRobj_env	*mac,
struct	GRobj_env	*stiff )

{
long			sts, msg;
struct	GRobj_env	sf;
double			point[18];
BSrc			bsrc;
struct	IGRbsp_surface	*sfGeom;
double			u, v, dist;
IGRint			size_buf, size;
IGRdouble		activ_cht;
char			footName[DI_PATH_MAX];
int			dirIndex = -1;
struct	ret_struct	str;


	// get web_left
	sts = VLgetVSbeamFace ( stiff, VS_K_nmWebL, VL_Q_TOP_SOURCE, &sf, &msg);
	if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }

	// get coordinate system
	if( ! (VLgetOperName("",&mac->obj_id,"~~orientation",footName) & 1))
		{ sts = MSFAIL; goto wrapup; }

	sts = om$send(	msg	 = message NDmacro.ACgive_structure(
					(int *) &msg,
					&dirIndex,
					footName,
					&str,
					&mac->mod_env ),
			targetid = mac->obj_id.objid,
			targetos = mac->obj_id.osnum,
			senderid = NULL_OBJID );
	if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }
	if( ref_generic != str.type ){ sts = MSFAIL; goto wrapup; }

	point[0] = str.var.ref_st.t[3];
	point[1] = str.var.ref_st.t[7];
	point[2] = str.var.ref_st.t[11];
	point[3] = str.var.ref_st.t[2];
	point[4] = str.var.ref_st.t[6];
	point[5] = str.var.ref_st.t[10];

	// project point on surface.
	sts = om$send(	msg	 = message GRvg.GRgenabsg(
						&msg,
						&sf.mod_env.md_env.matrix_type,
						sf.mod_env.md_env.matrix,
						(IGRchar**) &sfGeom ),
			targetid = sf.obj_id.objid,
			targetos = sf.obj_id.osnum,
			senderid = NULL_OBJID );
	if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }

	BSmdistptsf( &bsrc, sfGeom, &point[0], &u, &v, &point[6], &dist );
	if( BSSUCC != bsrc ){ sts = MSFAIL; goto wrapup; }

	// get cht
	size_buf = sizeof( IGRdouble );
	gr$get_chord_height_tolerance(	msg 	= &msg,
					sizbuf	= &size_buf,
					buffer	= &activ_cht,
					nret	= &size );
	activ_cht *= 10;
	if( activ_cht < dist ){ sts = MSFAIL; goto wrapup; }

	BSsfeval( sfGeom, u, v, 1, &point[6], &bsrc );
	if( BSSUCC != bsrc ){ sts = MSFAIL; goto wrapup; }

	// compute nornal
	BSnorvec( &bsrc, &point[9] );
	BSnorvec( &bsrc, &point[12] );
	BScrossp( &bsrc,  &point[9], &point[12], &point[15] );

	BSnorvec( &bsrc, &point[3] );
	BSnorvec( &bsrc, &point[15] );
 
	/* acos(0.999) = 2.56 Degrees */
	if (fabs(BSdotp(&bsrc, &point[3], &point[15])) > 0.999)
		sts = MSSUCC;
	else 	sts = MSFAIL;

wrapup :


return	sts;
}

/* ********************* FCT VLgetOperName() **********************	*/

long	VLgetOperName( macName, macId, selector, operName )

char		*macName;
struct	GRid	*macId;
char		*selector;
char		*operName;

{
long			sts, msg;
struct	GRid		defCol;
char			defName[DI_PATH_MAX];
int			dirIndex;
struct	ret_struct	str;
char			*macDef	= NULL;

	/* initialization */

	if( macName == NULL || macName[0] == NULL ){


		sts = om$send(	msg	 = message ACcpx.find_macro( &defCol ),
				targetid = macId->objid,
				targetos = macId->osnum,
				senderid = NULL_OBJID );
		if( ! (sts&1))	return MSFAIL;

		sts = om$send(	msg 	= message ACcpx_defn.ACgive_name( &macDef ),
				targetid = defCol.objid,
				targetos = defCol.osnum,
				senderid = NULL_OBJID );
		if( ! (sts&1))	return MSFAIL;

	} else	macDef = macName;

        if( !strcmp( macDef, "PartMark" ) )
        {
           if( !strcmp( selector, "~~marking0" ) )
           {
                if( operName )  strcpy(operName, "Geom");
                return  MSSUCC;
           }
        }

	sprintf( defName, "%s$def", macDef);

	defCol.objid	= NULL_OBJID;
	sts = ac$find_macro_defn(	action		= ACfind_no_load,
					macro_name	= defName,
					p_macro_defn_id = &defCol );
        if(!(sts&1)) return MSFAIL;

	/*| find form attribut */
	dirIndex = -1;
	sts = om$send(	msg	 = message NDmacro.ACgive_structure(
					(int *) &msg,
					&dirIndex,
					selector,
					&str,
					NULL ),
			targetid = defCol.objid,
			targetos = defCol.osnum,
			senderid = NULL_OBJID );
	if( ! (sts&msg&1))	return	MSFAIL;

	if( text_type != str.type ) return MSFAIL;

	if( operName )	strcpy(operName, str.var.text_st.text_string);

return	MSSUCC;
}

/* ***************** FCT VLcheckBorderLine() ************************	*/
/* This function check is the given genline lies on the border of the plate.
/*
/* FCT RETURN : MSSUCC if anwers is Yes  else MSFAIL
/* */

long VLcheckBorderLine( plate, genLine, locEnv )

struct	GRobj_env	*plate;		/* I  : Plate			*/
struct	GRobj_env	*genLine;	/* I  : genLine			*/
struct	GRmd_env	*locEnv;	/* I  : Observation Environment	*/

{
long			sts, msg;
struct	GRobj_env	sf, cv;
int			count1,count2;
struct	GRid		*inter1, *inter2;
short			four = 4;
double			tmp_mat[16];
int			i;

	/* Initialization */
	inter1	= NULL;
	inter2	= NULL;

	// get line
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
					&msg,
					MAN_GR_FEET,
					&cv.obj_id,
					&cv.mod_env.md_env.matrix_type,
					cv.mod_env.md_env.matrix ),
			targetid = genLine->obj_id.objid,
			targetos = genLine->obj_id.osnum,
			senderid = NULL_OBJID );
	cv.mod_env.md_id = genLine->mod_env.md_id;
	if( genLine->mod_env.md_env.matrix_type != MAIDMX ){

		for(i=0; i<16; i++) tmp_mat[i] = cv.mod_env.md_env.matrix[i];
		MAmulmx( &msg, &four, &four, &four,
			genLine->mod_env.md_env.matrix,
			tmp_mat,
			cv.mod_env.md_env.matrix );
	}

	// test with base
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
					&msg,
					VS_K_plBotSfPath,
					&sf.obj_id,
					&sf.mod_env.md_env.matrix_type,
					sf.mod_env.md_env.matrix ),
			targetid = plate->obj_id.objid,
			targetos = plate->obj_id.osnum,
			senderid = NULL_OBJID );
	sf.mod_env.md_id = plate->mod_env.md_id;
	if( plate->mod_env.md_env.matrix_type != MAIDMX ){

		for(i=0; i<16; i++) tmp_mat[i] = sf.mod_env.md_env.matrix[i];
		MAmulmx( &msg, &four, &four, &four,
			plate->mod_env.md_env.matrix,
			tmp_mat,
			sf.mod_env.md_env.matrix );
	}

	// check inter
	VLinterCvSf( &cv, &sf, 1, locEnv, &count1, &inter1 );

	if (count1 == 1) {

		struct	GRobj_env	cvRes;
		cvRes.mod_env	= *locEnv;
		cvRes.obj_id	= inter1[0];

		// check angle
		sts = VLcheckAngle( &cvRes, &cv, 0.5 );
		goto	wrapup;
	}

	// test with offset
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
					&msg,
					VS_K_plTopSfPath,
					&sf.obj_id,
					&sf.mod_env.md_env.matrix_type,
					sf.mod_env.md_env.matrix ),
			targetid = plate->obj_id.objid,
			targetos = plate->obj_id.osnum,
			senderid = NULL_OBJID );
	sf.mod_env.md_id = plate->mod_env.md_id;
	if( plate->mod_env.md_env.matrix_type != MAIDMX ){

		for(i=0; i<16; i++) tmp_mat[i] = sf.mod_env.md_env.matrix[i];
		MAmulmx( &msg, &four, &four, &four,
			plate->mod_env.md_env.matrix,
			tmp_mat,
			sf.mod_env.md_env.matrix );
	}

	// check inter
	VLinterCvSf( &cv, &sf, 1, locEnv, &count2, &inter2 );
	if (count2 == 1) {

		struct	GRobj_env	cvRes;
		cvRes.mod_env	= *locEnv;
		cvRes.obj_id	= inter2[0];

		// check angle
		sts = VLcheckAngle( &cvRes, &cv, 0.5 );
		goto	wrapup;
	}

	sts = MSFAIL;

wrapup :

	if( inter1 ){

		for(i=0; i<count1; i++)
		 om$send( msg = message GRgraphics.GRdelete( &msg, locEnv ),
			 targetid = inter1[i].objid,
			 targetos = inter1[i].osnum,
			 senderid = NULL_OBJID );
		free( inter1 );
	}

	if( inter2 ){

		for(i=0; i<count2; i++)
		 om$send( msg = message GRgraphics.GRdelete( &msg, locEnv ),
			 targetid = inter2[i].objid,
			 targetos = inter2[i].osnum,
			 senderid = NULL_OBJID );
		free( inter2 );
	}

return	sts;
}

IGRboolean VLchkNoMark( struct  GRobj_env       *Plate,
		  	struct  GRobj_env       *Stiff  )
{
IGRint			i, numObjects=0;
IGRboolean		no_mark=FALSE;
struct GRid		mark_plate;
struct GRobj_env	*list_obj=NULL;

   VLbrowseFctInTree( Stiff, VL_Q_TOP_ORIGINAL, NULL, VL_Q_DOWN_DIRECT,
                      VLgetMacrosAtStep, &numObjects, &list_obj );
   VLfilterDef( numObjects, list_obj, &numObjects, "no_mark" );
   if( !numObjects ) goto wrapup;

   for( i=0; i<numObjects; ++i )
   {
       vdobj$GetParent( objID    = &list_obj[i].obj_id,
                        idx      = 1,
                        parentID = &mark_plate );
       if( mark_plate.objid == NULL_OBJID ) break;

       if( mark_plate.objid == Plate->obj_id.objid &&
	   mark_plate.osnum == Plate->obj_id.osnum     )  break;
   }
   if( i != numObjects ) no_mark = TRUE;

wrapup:
   _FREE( list_obj );
   return no_mark;
}

long VLcheckStiffOnPlate(   
struct	GRobj_env 	*plate,		/* I  : Plate to be unwrapped 	*/
GRrange                  range,         /* I  : Range of the plate      */
struct	GRobj_env	*Stiff,		/* I  : Stiffener or Plate	*/
struct	GRmd_env	*locEnv)	/* I  : Observation Environment	*/
{
	IGRlong		      sts, msg,isConsumed;	
	struct GRobj_env      axis, plt_surf[2];
	struct GRobj_env      sfForEdges[2];
	VSpartAttr            PltAttr ;
	VSplateAttr           PltInfo ;

	__DBGpr_obj(" object to be tested ", Stiff->obj_id );

	if( Stiff->obj_id.objid == plate ->obj_id.objid  
	 && Stiff->obj_id.osnum == plate ->obj_id.osnum) { 
		__DBGpr_com("returning fail");
		return	MSFAIL;
	}

        /* If the Plate/Stiffener is consumed return failure */
	sts = om$send(  msg     = message NDmacro.ACtest_consumed( &isConsumed),
				senderid = NULL_OBJID,
				targetid = Stiff->obj_id.objid,
				targetos = Stiff->obj_id.osnum );
											__CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;

	if( isConsumed & 1 ) {
		return MSFAIL;
	}

	if( VLchkNoMark( plate, Stiff ) ) return MSFAIL;
	
	PltAttr.Iwant    = VS_m_Thickness;
	PltAttr.specific = (void *) &PltInfo ;

        sts = om$send(  msg     = message GRvg.GRgetattr( &msg,
                                                        (char *) &PltAttr),
                        senderid = NULL_OBJID,
                        targetid = plate->obj_id.objid,
                        targetos = plate->obj_id.osnum );
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup at line %d\n",__LINE__);
		goto wrapup; 
	}


         ///get the bottom surface of the plate
        sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &msg,
                                      VS_K_plBotSfPath,
                                      &plt_surf[0].obj_id,
                                      &plt_surf[0]._matrix_type,
                                      plt_surf[0]._matrix ),
                               senderid = NULL_OBJID,
                               targetid = plate->obj_id.objid,
                               targetos = plate->obj_id.osnum ) ;
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup at line %d\n",__LINE__);
		goto wrapup; 
	}

	plt_surf[0]._md_os = plate->_md_os;
        sts = ex$get_modid( mod_osnum = plt_surf[0]._md_os,
			     mod_id   = &plt_surf[0]._md_id );

         ///get the top surface of the plate
        sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &msg,
                                      VS_K_plTopSfPath,
                                      &plt_surf[1].obj_id,
                                      &plt_surf[1]._matrix_type,
                                      plt_surf[1]._matrix ),
                               senderid = NULL_OBJID,
                               targetid = plate->obj_id.objid,
                               targetos = plate->obj_id.osnum ) ;
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup %d at line \n",__LINE__);
		goto wrapup; 
	}

	plt_surf[1]._md_os = plate->_md_os;

        sts = ex$get_modid( mod_osnum = plt_surf[1]._md_os,
			     mod_id   = &plt_surf[1]._md_id );

     if( vs$is_ancestry_valid( object  = &Stiff->obj_id,
		classid = OPP_VSbeam_class_id ) == OM_S_SUCCESS ) {

	IGRchar			faceName[50];
	struct GRobj_env	stiffFaceObj;
	
	// Check if the Beam has inferior falnge surface
	sprintf( faceName, "%s:%s:%s", VS_K_bmGrCmpName, 
					VS_K_bmBody, VS_K_nmFlgInfE );
        sts = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg    ,
                                        faceName,
                                        &stiffFaceObj.obj_id,
                                        &stiffFaceObj._matrix_type,
                                        stiffFaceObj._matrix ),
                         senderid = NULL_OBJID,
                         targetid = Stiff->_objid,
                         targetos = Stiff->_osnum ) ;
        if( ! (sts&msg&1))  {
                //printf(" Going to wrapup \n");
                goto wrapup;
        }

	sts = om$send( msg = message VSbeam.VSgetSupportAxis( 
					&msg,
					&Stiff->mod_env,
					&axis ),
			senderid = NULL_OBJID,
			targetid = Stiff->_objid,
			targetos = Stiff->_osnum  );
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup \n");
		goto wrapup; 
	}

	if( VLcurve_on_surface( &sts, &axis, &plt_surf[0], 
				PltInfo.thickness, FALSE,&msg ) ) {
		return MSSUCC;
	}


	if( VLcurve_on_surface( &sts, &axis, &plt_surf[1], 
				PltInfo.thickness, FALSE,&msg ) ) {
		return MSSUCC;
	}

     } else  

     if ( vs$is_ancestry_valid( object  = &Stiff->obj_id,
	 	classid = OPP_VSplate_class_id ) == OM_S_SUCCESS ) {

	__DBGpr_com(" Examining plate ");
	// find surface of plate(Stiff variable in this case).
	// Then all the curve 
	// forming the boundary of the plate
	// Now check whther these curves are lying on either of the
	// surfaces      of plate.  
	// Stff : the plate to be tested.


        sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &msg,
                                      VS_K_plBotSfPath,
                                      &sfForEdges[0].obj_id,
                                      &sfForEdges[0]._matrix_type,
                                      sfForEdges[0]._matrix ),
                               senderid = NULL_OBJID,
                               targetid = Stiff->obj_id.objid,
                               targetos = Stiff->obj_id.osnum ) ;
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup %d\n",__LINE__);
		goto wrapup; 
	}

	sfForEdges[0]._md_os = Stiff->_md_os;

        sts = ex$get_modid( mod_osnum = sfForEdges[0]._md_os,
			     mod_id   = &sfForEdges[0]._md_id );
	//Now get the Top surface of the plate that
	// has to tested
        sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &msg,
                                      VS_K_plTopSfPath,
                                      &sfForEdges[1].obj_id,
                                      &sfForEdges[1]._matrix_type,
                                      sfForEdges[1]._matrix ),
                               senderid = NULL_OBJID,
                               targetid = Stiff->obj_id.objid,
                               targetos = Stiff->obj_id.osnum ) ;
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup %d\n",__LINE__);
		goto wrapup; 
	}

	sfForEdges[1]._md_os = Stiff->_md_os;
        sts = ex$get_modid( mod_osnum = sfForEdges[1]._md_os,
			     mod_id   = &sfForEdges[1]._md_id );
	__DBGpr_obj(" surface 0", sfForEdges[0].obj_id);
	__DBGpr_obj(" surface 1", sfForEdges[1].obj_id);


	{
	    int i ,j,k;

	     // for( i = 0 ; i < 2 ; i++){

		for( j = 0 ; j < 2 ; j++){
		IGRint		 	count;
		IGRlong                 sts, msg;
		struct GRid		*listID = NULL, edgeID;

	         vs$make_natural_boundary( msg        = &msg,
					   surfaceEnv = &sfForEdges[j].mod_env, 
					   surfaceId  = &sfForEdges[j].obj_id    );

	          sts = vs$get_surface_edges ( msg	= &msg,
		          		     sfId	= &sfForEdges[j].obj_id,
			          	     sfEnv	= &sfForEdges[j].mod_env,
				             edgeType	= VS_K_CONTOUR_EDGES,
				             edCount	= &count,
				             edList	= &listID );
	          //printf("\n Edge Count = %d", count );
	          if (!count)	{ __DBGpr_com("Error 0"); }


	          for ( k=0; k<count; k=k+1 ) {
		      BSrc		rc;
                      IGRshort          world=TRUE;
                      GRrange           crv_range;
                      struct GRobj_env  ed;
		      sts = vs$get_graphic_edge ( msg	    = &msg,
					    edId    = &listID[k],
					    edEnv   = &sfForEdges[j].mod_env,
					    copy    = TRUE,
					    copyEnv = locEnv,
					    grEdge  = &edgeID );

                       sts = om$send(  msg  = message GRgraphics.GRgetrang(
                                                &msg,
                                                &locEnv->md_env.matrix_type,
                                                locEnv->md_env.matrix,
                                                &world,
                                                crv_range ),
                                        senderid = NULL_OBJID,
                                        targetid= edgeID.objid,
                                        targetos= edgeID.osnum ) ;
                        if( !(BSbxint( &rc, &range[0], &range[3], &crv_range[0], &crv_range[3] )) )
	{
			sts = om$send(  msg     = message GRgraphics.GRdelete(
						&msg, locEnv ),
			 		senderid = NULL_OBJID,
                                        targetid= edgeID.objid,
                                        targetos= edgeID.osnum ) ;
                        continue;
	}

			ed.obj_id.objid = edgeID.objid;
			ed.obj_id.osnum = edgeID.osnum;
			ed.mod_env      = *locEnv;
 			if( VLcurve_on_surface( &sts,&ed,
				 		&plt_surf[1], 
						0.0,TRUE,&msg ) ){
     				_FREE(listID);
				sts = om$send(  msg     = message GRgraphics.GRdelete(&msg, locEnv ),
			 		senderid = NULL_OBJID,
                                        targetid= edgeID.objid,
                                        targetos= edgeID.osnum ) ;

				return MSSUCC;
			}
 			if( VLcurve_on_surface(  &sts,&ed,
				 	         &plt_surf[0], 
						 0.0, TRUE,&msg ) ){
     				_FREE(listID);
				sts = om$send(  msg     = message GRgraphics.GRdelete(&msg, locEnv ),
			 		senderid = NULL_OBJID,
                                        targetid= edgeID.objid,
                                        targetos= edgeID.osnum ) ;
     				//printf(" line %d \n", __LINE__);
				return MSSUCC;
			}
			sts = om$send(  msg     = message GRgraphics.GRdelete(
						&msg, locEnv ),
			 		senderid = NULL_OBJID,
                                        targetid= edgeID.objid,
                                        targetos= edgeID.osnum ) ;

                   } //for each edge
     			_FREE(listID);
	           }//for each edge
	     // } for each surface of the plate that has to tested 
     } // force scope to call  vs$findEdgeSurfaceMatch
   } // if plate ends
wrapup:
     //printf(" line %d \n", __LINE__);
     return	MSFAIL;
}/*VLcheckStiffOnPlate */

IGRint VLcheckPlateSideToMark(   
struct	GRobj_env 	*plate,		/* I  : Plate to be unwrapped 	*/
struct	GRobj_env	*Stiff,		/* I  : Stiffener or Plate	*/
struct	GRmd_env	*locEnv)	/* I  : Observation Environment	*/

{
	IGRlong		      sts, msg;	
	struct GRobj_env      axis, plt_surf[2];
	struct GRobj_env      sfForEdges[2];
	VSpartAttr            PltAttr ;
	VSplateAttr           PltInfo ;

	__DBGpr_obj(" object to be tested ", Stiff->obj_id );

	if( Stiff->obj_id.objid == plate ->obj_id.objid  
	 && Stiff->obj_id.osnum == plate ->obj_id.osnum) { 
		__DBGpr_com("returning fail");
		return	0;
	}

	PltAttr.Iwant    = VS_m_Thickness;
	PltAttr.specific = (void *) &PltInfo ;

        sts = om$send(  msg     = message GRvg.GRgetattr( &msg,
                                                        (char *) &PltAttr),
                        senderid = NULL_OBJID,
                        targetid = plate->obj_id.objid,
                        targetos = plate->obj_id.osnum );
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup at line %d\n",__LINE__);
		goto wrapup; 
	}


         ///get the bottom surface of the plate
        sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &msg,
                                      VS_K_plBotSfPath,
                                      &plt_surf[0].obj_id,
                                      &plt_surf[0]._matrix_type,
                                      plt_surf[0]._matrix ),
                               senderid = NULL_OBJID,
                               targetid = plate->obj_id.objid,
                               targetos = plate->obj_id.osnum ) ;
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup at line %d\n",__LINE__);
		goto wrapup; 
	}

	plt_surf[0]._md_os = plate->_md_os;
        sts = ex$get_modid( mod_osnum = plt_surf[0]._md_os,
			     mod_id   = &plt_surf[0]._md_id );

         ///get the top surface of the plate
        sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &msg,
                                      VS_K_plTopSfPath,
                                      &plt_surf[1].obj_id,
                                      &plt_surf[1]._matrix_type,
                                      plt_surf[1]._matrix ),
                               senderid = NULL_OBJID,
                               targetid = plate->obj_id.objid,
                               targetos = plate->obj_id.osnum ) ;
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup %d at line \n",__LINE__);
		goto wrapup; 
	}

	plt_surf[1]._md_os = plate->_md_os;

        sts = ex$get_modid( mod_osnum = plt_surf[1]._md_os,
			     mod_id   = &plt_surf[1]._md_id );

     if( vs$is_ancestry_valid( object  = &Stiff->obj_id,
		classid = OPP_VSbeam_class_id ) == OM_S_SUCCESS ) {
	sts = om$send( msg = message VSbeam.VSgetSupportAxis( 
					&msg,
					&Stiff->mod_env,
					&axis ),
			senderid = NULL_OBJID,
			targetid = Stiff->_objid,
			targetos = Stiff->_osnum  );
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup \n");
		goto wrapup; 
	}


        /* Changes made for TR#179900638 */
	if( VLcurve_on_surface( &sts, &axis, &plt_surf[0], 0.0,FALSE, &msg ) ){
	 	//printf(" Returning from this place %d %s \n", __LINE__,__FILE__); //debug
		return 0;
	}

        /* Changes made for TR#179900638 */
	if( VLcurve_on_surface( &sts, &axis, &plt_surf[1], 0.0, FALSE,&msg ) ){
	 	//printf(" Returning from this place %d %s \n", __LINE__,__FILE__); //debug
		return 1;
	}

     } else  

     if ( vs$is_ancestry_valid( object  = &Stiff->obj_id,
	 	classid = OPP_VSplate_class_id ) == OM_S_SUCCESS ) {
	__DBGpr_com(" Examining plate ");
	// find surface of plate(Stiff variable in this case).
	// Then all the curve 
	// forming the boundary of the plate
	// Now check whther these curves are lying on either of the
	// surfaces      of plate.  
	// Stff : the plate to be tested.


        sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &msg,
                                      VS_K_plBotSfPath,
                                      &sfForEdges[0].obj_id,
                                      &sfForEdges[0]._matrix_type,
                                      sfForEdges[0]._matrix ),
                               senderid = NULL_OBJID,
                               targetid = Stiff->obj_id.objid,
                               targetos = Stiff->obj_id.osnum ) ;
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup %d\n",__LINE__);
		goto wrapup; 
	}

	sfForEdges[0]._md_os = Stiff->_md_os;

        sts = ex$get_modid( mod_osnum = sfForEdges[0]._md_os,
			     mod_id   = &sfForEdges[0]._md_id );
	//Now get the Top surface of the plate that
	// has to tested
        sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &msg,
                                      VS_K_plTopSfPath,
                                      &sfForEdges[1].obj_id,
                                      &sfForEdges[1]._matrix_type,
                                      sfForEdges[1]._matrix ),
                               senderid = NULL_OBJID,
                               targetid = Stiff->obj_id.objid,
                               targetos = Stiff->obj_id.osnum ) ;
	if( ! (sts&msg&1))  { 
		//printf(" Going to wrapup %d\n",__LINE__);
		goto wrapup; 
	}

	sfForEdges[1]._md_os = Stiff->_md_os;
        sts = ex$get_modid( mod_osnum = sfForEdges[1]._md_os,
			     mod_id   = &sfForEdges[1]._md_id );
	__DBGpr_obj(" surface 0", sfForEdges[0].obj_id);
	__DBGpr_obj(" surface 1", sfForEdges[1].obj_id);


	{
	    int i ,j,k;

	     for( i = 0 ; i < 2 ; i++){

		for( j = 0 ; j < 2 ; j++){
		IGRint		 	count;
		IGRlong                 sts, msg;
		struct GRid		*listID = NULL, edgeID;

	         vs$make_natural_boundary( msg        = &msg,
					   surfaceEnv = &sfForEdges[j].mod_env, 
					   surfaceId  = &sfForEdges[j].obj_id    );

	          sts = vs$get_surface_edges ( msg	= &msg,
		          		     sfId	= &sfForEdges[j].obj_id,
			          	     sfEnv	= &sfForEdges[j].mod_env,
				             edgeType	= VS_K_CONTOUR_EDGES,
				             edCount	= &count,
				             edList	= &listID );
	          //printf("\n Edge Count = %d", count );
	          if (!count)	{ __DBGpr_com("Error 0"); }


	          for ( k=0; k<count; k=k+1 ) {
		      struct GRobj_env  ed;
		      sts = vs$get_graphic_edge ( msg	    = &msg,
					    edId    = &listID[k],
					    edEnv   = &sfForEdges[i].mod_env,
					    copy    = TRUE,
					    copyEnv = locEnv,
					    grEdge  = &edgeID );
			ed.obj_id.objid = edgeID.objid;
			ed.obj_id.osnum = edgeID.osnum;
			ed.mod_env      = *locEnv;

                        /* Changes made for TR#179900638 */ 
 			if( VLcurve_on_surface( &sts,&ed,
				 		&plt_surf[1], 
						0.0,TRUE,&msg ) ){
     				_FREE(listID);
				sts = om$send(  msg     = message GRgraphics.GRdelete(&msg, locEnv ),
			 		senderid = NULL_OBJID,
                                        targetid= edgeID.objid,
                                        targetos= edgeID.osnum ) ;

				return 1;
			}
			/* Changes made for TR#179900638 */
 			if( VLcurve_on_surface(  &sts,&ed,
				 	         &plt_surf[0], 
						 0.0,TRUE, &msg ) ){
     				_FREE(listID);
				sts = om$send(  msg     = message GRgraphics.GRdelete(&msg, locEnv ),
			 		senderid = NULL_OBJID,
                                        targetid= edgeID.objid,
                                        targetos= edgeID.osnum ) ;
     				//printf(" line %d \n", __LINE__);
				return 0;
			}
			sts = om$send(  msg     = message GRgraphics.GRdelete(
						&msg, locEnv ),
			 		senderid = NULL_OBJID,
                                        targetid= edgeID.objid,
                                        targetos= edgeID.osnum ) ;

                   } //for each edge
     			_FREE(listID);
	           }//for each edge


	     } //for each surface of the plate that has to tested 

     } // force scope to call  vs$findEdgeSurfaceMatch
   } // if plate ends
wrapup:
     //printf(" line %d \n", __LINE__);
     return	0;
}/*VLcheckPlateSideToMark */

end implementation GRvg ;
