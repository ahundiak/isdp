/* $Id: VLunwBndFunk.I,v 1.3 2001/02/20 01:07:16 build Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	src/unwext/VLunwBndFunk.I
 *
 * Description:	Miscellaneous Boundary functions.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLunwBndFunk.I,v $
 *	Revision 1.3  2001/02/20 01:07:16  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:01:08  ramarao
 *	*** empty log message ***
 *	
# Revision 1.8  2000/11/20  21:50:22  pinnacle
# Replaced: loft/src/unwext/VLunwBndFunk.I for:  by rchennup for Service Pack
#
# Revision 1.6  2000/07/06  19:33:38  pinnacle
# Replaced: loft/src/unwext/VLunwBndFunk.I for:  by rchennup for Service Pack
#
# Revision 1.5  2000/06/28  23:23:12  pinnacle
# Replaced: loft/src/unwext/VLunwBndFunk.I for:  by rchennup for Service Pack
#
# Revision 1.4  2000/05/05  20:22:14  pinnacle
# Replaced: loft/src/unwext/VLunwBndFunk.I for:  by rchennup for Service Pack
#
# Revision 1.3  2000/04/24  22:45:20  pinnacle
# Replaced: loft/src/unwext/VLunwBndFunk.I for:  by rchennup for Service Pack
#
# Revision 1.11  2000/04/03  17:29:46  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by impd252 for loft
#
# Revision 1.10  2000/03/24  18:45:48  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by impd252 for loft
#
# Revision 1.9  2000/03/22  16:52:10  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by impd252 for loft
#
# Revision 1.8  2000/03/14  20:29:54  pinnacle
# Added code to Process Bevel macros.
#
# Revision 1.7  1999/12/30  12:54:20  pinnacle
# Replaced VLunwBndFunk.I for unwrapTR by jpulapar for loft
#
# Revision 1.5  1999/06/01  22:23:30  pinnacle
# (No comment)
#
# Revision 1.4  1999/06/01  16:35:22  pinnacle
# (No comment)
#
# Revision 1.3  1999/05/21  21:58:28  pinnacle
# Fixed Orientation Problem.
#
# Revision 1.2  1998/09/04  07:58:32  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by smpathak for loft
#
# Revision 1.13  1998/04/27  15:44:12  pinnacle
# ah
#
# Revision 1.12  1998/04/26  16:52:16  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by impd for loft
#
# Revision 1.9  1998/04/23  21:08:46  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by azuurhou for loft
#
# Revision 1.8  1998/04/23  08:36:30  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by rchennup for loft
#
# Revision 1.7  1998/04/16  11:34:36  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by smpathak for loft
#
# Revision 1.6  1998/04/13  10:34:24  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by rchennup for loft
#
# Revision 1.5  1998/03/31  11:50:48  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by rchennup for loft
#
# Revision 1.4  1998/03/24  09:12:24  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by smpathak for loft
#
# Revision 1.3  1998/03/02  08:15:24  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by rchennup for loft
#
# Revision 1.2  1998/01/22  20:00:08  pinnacle
# Replaced: src/unwext/VLunwBndFunk.I for:  by rchennup for loft
#
# Revision 1.1  1997/10/28  15:31:30  pinnacle
# Created: src/unwext/VLunwBndFunk.I by rchennup for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	10/28/97   Rama Rao     File Creation
 *	04/23/98   adz		Correction for the Bounded Option.
 *	04/24/98   adz		AngTol Invalid Setting.
 *	04/26/98   adz          Change SortAndBuildCrv -> BuildCrv
 *      04/27/98   ah           Last minute change by Rama Rao
 *                              Deals with orientation problem
 *      08/27/98   pathak	For TR#179801539
 *	03/14/00   Rama Rao	Added code to Process Bevel macros
 *************************************************************************/

class implementation VLabstract;

#include <stdio.h>
#include <math.h>
#include "vlprototype.h"

#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"
#include "exmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "maerr.h"
#include "bs.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "EMSssprops.h"
#include "EMSdpb.h"
#include "EMSopt.h"
#include "grmacros.h"
#include "dpezmac.h"
#include "igr.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "nddef.h"
#include "asmacros.h"
#include "parametric.h"
#include "csdef.h"
#include "values.h"
#include "v_pplslc.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsgeommacros.h"
#include "vsplatedef.h"
#include "vlunfold.h"
#include "vlmark.h"
#include "vsattr.h"
#include "vsplate.h"
#include "vsoptdef.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "bsvalues.h"
#include "vledgeattr.h"
#include "vlstifftpl.h"
#include "vlglinedef.h"
#include "vlquerydef.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "vldbgmacros.h"

#define vdsDEBUG 	1
#define vdserrDEBUG	1

from	ASindexcv	import  ASget_uvwdef;
from	EMSboundary	import	EMcount_edges, EMget_edges;
from    EMSedge		import	EMgetbcgeom, EMget_bcxyz_geom;
from	EMSloopset      import	EMget_loops;
from   	GRcompcurve	import  EMmakecomp;
from	GRcurve		import  GRmidpoint;
from    GRcurve         import  GRendpts;
from	IGEgragad	import	DPinrot;
from	ACrg_collect	import	AClist_attribute;
from    ACpretend       import  ACfind_parent;
from    EMSsubbs	import  EMget_props;

extern GRclassid	OPP_GR3dlinestr_class_id;
extern GRclassid	OPP_GRcompcurve_class_id;
extern GRclassid        OPP_EMSgenbs_class_id;
extern GRclassid        OPP_GRgencs_class_id;
extern GRclassid        OPP_GRbcsubbc_class_id;
extern GRclassid        OPP_GR3dcirarc_class_id;
extern GRclassid        OPP_GRcirarc_class_id;
extern GRclassid	OPP_ACpretend_class_id;

extern   OM_S_CHANSELECT AS_to_owner;

extern 			BSchtptstsf();
extern 			BSchtptstso();
extern 			BSsfarrevn();
extern 			BSkts_f_fit();
extern 			BSkts_f_app();
extern 			BSrev_cv();
extern  IGRboolean	BSfreesf();
extern			GRdpb_get();
extern			GRdpb_put();
extern	IGRdouble	BSdistptpt();
extern	IGRboolean	BScrossp();
extern	IGRdouble	BSdotp();
extern	IGRdouble	BSlenvec();
extern  IGRboolean	BSnorvec();
extern  void		BSchtptstcv();
extern	void		BSalloccv(), BSallocsf();
extern	IGRboolean	BSfreecv(), BSfreesf();
extern  IGRchar		*memcpy();
extern  void		BSsfeval();
extern			GRdisplay_object();
extern	IGRdouble	cos(),fabs();
extern			ASmake_source_from_env();
extern IGRint 		MAinvmx();
extern IGRint 		MAmulmx();
extern IGRboolean	MAtypemx();
extern IGRint 		BSmdistptsf();
extern IGRint 		VLfindOrientation();
extern IGRint 		VLlongHorzOrTrans();
extern void		__DBGpr_double();
extern			SortAndBuildCrv();
extern long		VSdoCurvesOverlap();
extern void             FAevPtSfFaDr();
extern GRclassid        OPP_VLmrkLine_class_id;

#define ANGLE (cos(M_PI/4))

static int isReverse;
/*
# ifndef DEBUG
# define DEBUG 1
# endif
*/

/*========================================================================*/
void	VLisDirValid( 

IGRdouble *refDir,	/*I normalized direction considered as referencen */
IGRdouble *curDir,	/*I Normalized vector that we check */
IGRdouble angTol2,      /*I the tolerance */
IGRlong   *rc ){	/*O return code BSSUCC if fit constraints else BSFAIL */

/*d This function check if the angle between the 2 vectors is less 
    than angTol2.
    In fact we check if sin(refDir,curDir less than angTol2 or 
    if the 2 direction are reversed
*/

	IGRdouble crossv[3], sinAng, dirVec;
	
	BScrossp( rc, refDir, curDir, crossv );
	sinAng = BSdotp( rc, crossv, crossv );
	dirVec = BSdotp( rc, refDir, curDir );

#ifdef	DEBUG
	printf("\tVLisDirValid(%f):\t\t%f\t%f \n", angTol2, sinAng, dirVec );
#endif

	*rc = BSSUCC;
	if( sinAng < angTol2 ){
		if ( dirVec < 0.0 )  *rc = BSSDGENRAT;
		else		     *rc = BSSUCC;
	}
	else	*rc = BSFAIL;
#ifdef	DEBUG
	printf(" VLisDirValid == %d \n", *rc );
#endif
}

/*========================================================================*/
IGRlong VLevPtNor( rc, srf, uv, iCur, maxPts, angTol2, refNor, curPt, curNor)
IGRlong		     *rc ;     /*O  return code BSSUCC, BSFAIL */
struct IGRbsp_surface *srf;    /*I  surface on which we evalute pt and normal */
IGRdouble	     *uv;      /*I  u and v parametres */
IGRint 	             iCur;     /*I  index in the uv array of the point to */
			       /*      be evaluated */
IGRint		     maxPts;   /*I   upper bound in the uv array */
IGRdouble	     angTol2;  /*I   angular Tolerance, see VLisDirValid */
IGRdouble	     *refNor;  /*IO  if OK then refNor becomes curNor */
IGRdouble	     *curPt;    /*O  the evaluated point */
IGRdouble	     *curNor;   /*O  the normal */
{

	IGRdouble u, v, P0[3], N0[6], P1[3], N1[6];
	IGRint	  j;
	IGRlong   suc;

/*d This function evaluate the point and more important the proper normale
    to be later in position to project this point into the tessalated surface.
    In fact, we try to solve the degenrated case, when the normal does 
    not exist or turns too quickly.
    Think what appening at the apex of a cone, you got infinite number of 
    normals  as a solution.
*/


/*h 20 April  98 JLL creation date */

/*c Beginning of function */

/* evaluate the current point. You may be surprize by this uv setting, it's
   just because in some case the calling function is calling the same array
   in input and output.
*/

v = uv[iCur+1];
u = uv[iCur];
BSsfevaln(srf,u,v,1,&j,curPt,curNor,rc);
*rc = MSSUCC ;

#ifdef	DEBUG
	printf("-- u  : %f --- v : %f \n", u, v );
	printf("-- Pnt: %f, %f, %f \n", curPt[0], curPt[1], curPt[2] );
	printf("-- Nor: %f, %f, %f \n", curNor[0], curNor[1], curNor[2] );
#endif

if( iCur == 0 ){

/* We check first like for anyother points, when it fail we test two potential
   situations.

	   case 1            case 2                      case 0
           ------            ------			 ------

             + P0           curPt +
            / \       	           \			     P0
     curPt +   +       OR           +--+       OR  CurPt +--+--+
	       P1                 P0    P1                      P1
*/

	if( maxPts < 9 ){ 
#ifdef	DEBUG
		printf("Error in VLevPtNor\n");
#endif
		goto wrapup;
	}

	u = uv[3];
	v = uv[4];
	BSsfevaln( srf, u, v, 1, &j, P0, N0, &suc );
	VLisDirValid( curNor, N0, angTol2, &suc );
	if( suc == BSSUCC ){

		/* case 0 */
		for( j=0; j<3; j++ ) refNor[j] = curNor[j];
		goto okok;
	}
	else{
		u = uv[6];
		v = uv[7];
		BSsfevaln( srf, u, v, 1, &j, P1, N1, &suc );
		VLisDirValid( curNor, N1, angTol2, &suc );
		if( suc == BSSUCC ){

			/* case 1 */
			for( j=0; j<3; j++ ) refNor[j] = curNor[j];
			goto okok;
		}
		else{
			/* case 2 */
			VLisDirValid( N0, N1, angTol2, &suc );
			if( suc == BSSUCC ){
				for( j=0; j<3; j++ ){
					 refNor[j] = N0[j];
					 curNor[j] = N0[j];
				}
				goto okok;
			}
		}
	}
#ifdef	DEBUG
	printf(" VLevPtNor ... goto wrapup:%d \n", iCur );
#endif
	goto wrapup;

}
else{
	VLisDirValid( refNor, curNor, angTol2, &suc );
	if( suc == BSSUCC ){
		for( j=0; j<3; j++ ) refNor[j] = curNor[j];
	}
	else{
#ifdef	DEBUG
		printf(" VLevPtNor: VLisDirValid failed:%d \n", iCur );
#endif
		for( j=0; j<3; j++ ) curNor[j] = refNor[j];
	}
}

okok:
	*rc = suc;
	return MSSUCC;

wrapup:
      	*rc = suc;
      	return MSFAIL;
}

/*========================================================================*/

IGRlong  VLgetLowerEdge(  struct unw_obj_plat    *dev,
			  IGRboolean 		 isThDirRev,
                          IGRdouble              *point1,
                          IGRdouble              *point2,
			  IGRboolean		 *is_lbhd,
			  IGRboolean		 *is_tbhd,
			  IGRboolean		 *is_deck   )
{
  IGRlong    	     rc;
  IGRint     	     i, j, ind, tmp, ref_axis=2, pt_to_use, vec_pos1, vec_pos2;
  IGRdouble  	     prod1, prod2, low_refval, points[12], axis[3],
		     vec1[3], vec2[3];
  IGRboolean	     isLong = FALSE, isTrans = FALSE, isOffset=FALSE;
  
	*is_deck = *is_lbhd = *is_tbhd = FALSE;
	
	isOffset= (dev->side_of_plate)%2;

	j=0;
  	axis[0] = 0.0;  axis[1] = 0.0;  axis[2] = 1.0;

  	BSsfeval( dev->surface, 0.0, 0.0, 0, &points[0], &rc);
 	if (rc!=BSSUCC) {  printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }

  	BSsfeval( dev->surface, 0.0, 1.0, 0, &points[3], &rc);
 	if (rc!=BSSUCC) {  printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }

  	BSsfeval( dev->surface, 1.0, 1.0, 0, &points[6], &rc);
 	if (rc!=BSSUCC) {  printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }

  	BSsfeval( dev->surface, 1.0, 0.0, 0, &points[9], &rc);
 	if (rc!=BSSUCC) {  printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }

	for( i=0; i<3; ++i )
	{
	   if( fabs(points[3] - points[0]) < 0.01 &&
	       fabs(points[6] - points[0]) < 0.01 &&
	       fabs(points[3] - points[0]) < 0.01       )   
	   {
		*is_tbhd = TRUE;
		isTrans = TRUE;
	   }

	   if( fabs(points[4]  - points[1]) < 0.01 &&
	       fabs(points[7]  - points[1]) < 0.01 &&
	       fabs(points[10] - points[1]) < 0.01       )  
	   {
		*is_lbhd = TRUE;
		isLong  = TRUE;
	   }

	   if( fabs(points[5]  - points[2]) < 0.01 &&
	       fabs(points[8]  - points[2]) < 0.01 &&
	       fabs(points[11] - points[2]) < 0.01       )  
	   {
		*is_deck  = TRUE;
  		axis[0] = 0.0;  axis[1] = 1.0;  axis[2] = 0.0;
	   }

	}

	// ref_axis is 2 for z-axis, 1 for y-axis and 0 for x-axis
	if( *is_deck )  	ref_axis = 1;
	else			ref_axis = 2;

	#ifdef DEBUG
	printf("\n ref_axis = %d", ref_axis );
	#endif

  	low_refval = 10000000.0;  
	ind=-1;

  	for( i=0; i<4; ++i )
  	{
      	   if( points[3*i+ref_axis] <= low_refval )
      	   {
        	low_refval = points[3*i+ref_axis];
        	ind = i;
      	   }
  	}

	#ifdef DEBUG
	for( i=0; i<12; i+=3 )
	   printf("\n Point[%d] = %lf, %lf, %lf", i, points[i], points[i+1], points[i+2] );
	#endif

  	if( ind == 3 ) vec_pos1 = 0;
  	else           vec_pos1 = ind+1;

  	if( ind == 0 ) vec_pos2 = 3;
  	else           vec_pos2 = ind-1;

  	BSmkvec ( &rc, vec1, &points[3*ind], &points[3*vec_pos1] );
 	if (rc!=BSSUCC) {  printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }

  	BSnorvec( &rc, vec1 );
 	if (rc!=BSSUCC) {  printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }

  	BSmkvec ( &rc, vec2, &points[3*ind], &points[3*vec_pos2] );
 	if (rc!=BSSUCC) {  printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }

  	BSnorvec( &rc, vec2 );
 	if (rc!=BSSUCC) {  printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }

  	prod1 = BSdotp ( &rc, axis, vec1 );
 	if (rc!=BSSUCC) {  printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }

  	prod2 = BSdotp ( &rc, axis, vec2 );
 	if (rc!=BSSUCC) {  printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }

	#ifdef DEBUG
	printf("\n prod1 = %lf, prod2 = %lf", prod1, prod2 );
	#endif

  	if( prod1 <= prod2 )   pt_to_use = vec_pos1;
  	else                   pt_to_use = vec_pos2;

	if( ( points[3*ind] - points[3*pt_to_use]) > 0.01 )
	{
      	    tmp  = ind;
	    ind  = pt_to_use;
	    pt_to_use = tmp;
	}

	if( isTrans  && (points[3*ind+1] > points[3*pt_to_use+1]) )
	{
      	    tmp  = ind;
	    ind  = pt_to_use;
	    pt_to_use = tmp;
	}

	if( isOffset )
        {
            tmp  = ind;
            ind  = pt_to_use;
            pt_to_use = tmp;
        }

	if( dev->side_of_plate == OFFSET_FLIP ||
	    dev->side_of_plate == BASE_FLIP      )
	{
      	    tmp  = ind;
	    ind  = pt_to_use;
	    pt_to_use = tmp;
	}

	if( isLong )
	{
      	    tmp  = ind;
	    ind  = pt_to_use;
	    pt_to_use = tmp;
	}

	if( isTrans && isThDirRev )
	{
      	    tmp  = ind;
	    ind  = pt_to_use;
	    pt_to_use = tmp;
	}

  	switch ( ind )
  	{
      	    case 0: 
		BSsfeval( dev->devsrf, 0.0, 0.0, 0, &point1[0], &rc );
 		if (rc!=BSSUCC) {  
			printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }
		break;

      	    case 1:
		BSsfeval( dev->devsrf, 0.0, 1.0, 0, &point1[0], &rc );
 		if (rc!=BSSUCC) {  
			printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }
                break;

      	    case 2:
        	BSsfeval( dev->devsrf, 1.0, 1.0, 0, &point1[0], &rc );
 		if (rc!=BSSUCC) {  
			printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }
                break;

      	    case 3:
        	BSsfeval( dev->devsrf, 1.0, 0.0, 0, &point1[0], &rc );
 		if (rc!=BSSUCC) {  
			printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }
                break;
	    default:
 		if (rc!=BSSUCC) {  
			printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }
  	}

	#ifdef DEBUG
        printf("\n ind = %d, point1 = %lf, %lf, %lf", ind, point1[0],
		point1[1], point1[2] );
	#endif

  	switch ( pt_to_use )
  	{
      	    case 0: 
		BSsfeval( dev->devsrf, 0.0, 0.0, 0, &point2[0], &rc );
 		if (rc!=BSSUCC) {  
			printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }
		break;

      	    case 1:
		BSsfeval( dev->devsrf, 0.0, 1.0, 0, &point2[0], &rc );
 		if (rc!=BSSUCC) {  
			printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }
                break;

      	    case 2:
        	BSsfeval( dev->devsrf, 1.0, 1.0, 0, &point2[0], &rc );
 		if (rc!=BSSUCC) {  
			printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }
                break;

      	    case 3:
        	BSsfeval( dev->devsrf, 1.0, 0.0, 0, &point2[0], &rc );
 		if (rc!=BSSUCC) {  
			printf(" VLgetLowerEdge Failed\n"); return MSFAIL; }
                break;
  	}

	#ifdef DEBUG
        printf("\n pt_to_use = %d, point2 = %lf, %lf, %lf", pt_to_use, point2[0],
		point2[1], point2[2] );
	#endif

  return OM_S_SUCCESS;

}

IGRlong VL_unw_matchBevelEdgeWithAtt (
struct  unw_obj_plat    *dev,    /*I  from which we retrieve the surface ID */
        IGRint          numAtt,  /*I  number of nci_macros edge_att */
struct  GRid            *attIds, /*I  array of nci_macros edge_att */
        IGRint          numEdge, /*I  number of edges */
struct  EdgeMatch       *edgeIds, /*IO the structure containing edgeIds as
                                      input and depending on SUCCESS or not
                                      edgeIds->EdgeMac = attIds[i] or NULL */

        IGRlong         *msg     /*O  MSSUCC or MSFAIL  */
)
{
IGRlong 		sts;
IGRint			i, j, loc_suc, tmp;
IGRdouble		thick=0.0;
IGRchar            	attrName[40];
struct ret_struct       attrVal;
struct GRid		solid_id, plate;
struct GRobj_env	curve_env;
struct IGRbsp_curve     **xyzCrvAtt, cv;

    SetProc( VL_unw_matchBevelEdgeWithAtt ); Begin

    __DBGpr_obj("dev->surf_id ", dev->surf_id.obj_id );
    __DBGpr_int("Number of Bevel macros ", numAtt );
    if( !numAtt || !numEdge ) return MSSUCC;

    __DBGpr_objlist("Bevel Macro ", numAtt, attIds );
    __DBGpr_int("Number of Edges ", numEdge );

    xyzCrvAtt  = NULL;
    cv.poles   = NULL;
    cv.weights = NULL;
    cv.knots   = NULL;
    cv.bdrys= NULL;

    xyzCrvAtt = (struct IGRbsp_curve **)
                 om$malloc ( size = numAtt * sizeof(IGRchar *) );
    if( xyzCrvAtt == NULL ) {
          printf("Error in VLmatchBevelEdgeWithAtt\n");
          printf("Error in om$malloc of xyzCrvAtt\n");
          goto wrapup;
    }

    // try to get the VLunwObj macro on the consuming child
    sts = om$get_objid_at_index(  osnum        = dev->surf_id._osnum,
                                  objid        = dev->surf_id._objid,
                                  p_chanselect = &AS_to_owner,
                                  index        = 0,
                                  objidaddr    = &solid_id.objid,
                                  osnumaddr    = &solid_id.osnum);
    __CheckRC( sts, 1, "om$get_objid_at_index", wrapup ) ;
    __DBGpr_obj("EMS Solid ID ", solid_id );

    sts = om$get_objid_at_index( osnum        = solid_id.osnum,
                                 objid        = solid_id.objid,
                                 p_chanselect = &AS_to_owner,
                                 index        = 0,
                                 objidaddr    = &plate.objid,
                                 osnumaddr    = &plate.osnum);
   __CheckRC( sts, 1, "om$get_objid_at_index", wrapup ) ;
   __DBGpr_obj("Plate in the model ", plate );

   strcpy( attrName, VS_K_plThcknsAttr );

   sts = om$send( msg = message NDmacro.ACgive_structure( 
				&loc_suc , &tmp, attrName, &attrVal, NULL ),
                        senderid = NULL_OBJID,
                        targetid = plate.objid,
                        targetos = plate.osnum  );
   __CheckRC( sts, loc_suc, "ACgive_structure:Thickness", wrapup ) ;

   thick = attrVal.var.root_pm_st.value;
   __DBGpr_dbl("Plate Thickness ", thick );

   for(i=0;i<numAtt;i++)
   {
       xyzCrvAtt[i] = NULL;
       sts = om$send( msg      = message NDmacro.ACreturn_foot(
				msg, "curve", &curve_env.obj_id,
				&curve_env._matrix_type, curve_env._matrix ),
		  senderid = NULL_OBJID,
		  targetid = attIds[i].objid,
		  targetos = attIds[i].osnum );
       __CheckRC( sts, *msg, "ACreturn_foot:curve", wrapup ) ;
       __DBGpr_obj("Curve Foot ", curve_env.obj_id );

       curve_env._md_os = attIds[i].osnum;
       sts = ex$get_modid( mod_osnum = curve_env._md_os,
			   mod_id    = &curve_env._md_id );

       sts = VLgetGeometry( &curve_env, FALSE, NULL_OBJID, 
			    (IGRchar **)&xyzCrvAtt[i], msg );
       __CheckRC( sts, *msg, "VLgetGeometry", wrapup ) ;
   }

   for(i=0; i<numEdge; i++)
   {
      sts = om$send ( msg = message EMSedge.EMget_bcxyz_geom(
				msg, NULL, NULL, dev->surface, 0, OM_K_MAXINT,
				FALSE, NULL, &cv ),
                         senderid = NULL_OBJID,
                         targetid = edgeIds[i].EdgeId.objid,
                         targetos = edgeIds[i].EdgeId.osnum );
      __CheckRC( sts, *msg, "EMSedge.EMget_bcxyz_geom", wrapup ) ;

      for( j=0; j<numAtt; j++)
      {
	edgeIds[i].EdgeMac.objid = NULL_OBJID;
	if( xyzCrvAtt[j] != NULL )
	{
	    if( VLcheck3DCrvThk( xyzCrvAtt[j], &cv,thick) == TRUE )
	    {
		edgeIds[i].EdgeMac = attIds[j];
		__DBGpr_obj("Bevel Matched ", attIds[j] );
		om$dealloc( ptr = xyzCrvAtt[j] );
		xyzCrvAtt[j] = NULL;
		break;
	    }
	}
      }
      if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
      if( cv.knots ){ free( cv.knots ); cv.knots = NULL; }
      if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
      if( cv.bdrys ){ free( cv.bdrys ); cv.bdrys   = NULL; }
   }
   sts = *msg = MSSUCC;

wrapup:

   if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
   if( cv.knots ){ free( cv.knots ); cv.knots = NULL; }
   if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
   if( cv.bdrys ){ free( cv.bdrys ); cv.bdrys   = NULL; }

   for(i=0;i<numAtt;i++)
   {
       if( xyzCrvAtt[i] != NULL ) 
       {
            om$dealloc( ptr = xyzCrvAtt[i] );
            xyzCrvAtt[i] = NULL;
       }
   }

   if( xyzCrvAtt != NULL )
   {
       om$dealloc( ptr = xyzCrvAtt );
       xyzCrvAtt = NULL;
   }

   End
   return sts;
}

/*========================================================================*/
IGRlong	VL_unw_matchEdgeWithAtt (

	IGRshort	checkOpt,/*I  test according 2D space or 3D space */
				 /*   0 --> 2D else 3D */
struct 	unw_obj_plat	*dev,	 /*I  from which we retrieve the surface ID */
	IGRint		numAtt,  /*I  number of nci_macros edge_att */
struct	GRid		*attIds, /*I  array of nci_macros edge_att */
	IGRint		numEdge, /*I  number of edges */
struct	EdgeMatch	*edgeIds, /*IO the structure containing edgeIds as
				      input and depending on SUCCESS or not
				      edgeIds->EdgeMac = attIds[i] or NULL */

	IGRlong		*suc     /*O  MSSUCC or MSFAIL	*/
)

/*d 	VLmatchEdgeWithAtt is the function that performs the real geometric
	edge matching. */

/*h 19 January  93 JLL creation date */

/*c Beginning of function */

{

struct 	IGRbsp_curve	**xyzCrvAtt, cv;
	IGRint		i=0, j ,tmp=0;
	IGRlong		OmStat, msg;
	IGRint		loc_suc;
struct	GRid		AS_ELEM,source,srf_prt;
struct	GRobj_env	ELEM;
	IGRushort 	options;
        char            attrName[40];
struct  ret_struct      attrVal;
        IGRdouble       thick=0.0;



/*c retrieve all the xyz edge curves attached as parents of each edge_att 
    nci_macro */

	#ifdef DEBUG
	printf("---------- VLmatchEdgeWithAtt -------------\n");
	#endif

	xyzCrvAtt  = NULL;
	cv.poles   = NULL;
	cv.weights = NULL;
	cv.knots   = NULL;
	cv.bdrys= NULL;

	xyzCrvAtt = (struct IGRbsp_curve **) 
		    om$malloc ( size = numAtt * sizeof(IGRchar *) );
        if( xyzCrvAtt == NULL ) { 
	  printf("Error in VLmatchEdgeWithAtt\n");
	  printf("Error in om$malloc of xyzCrvAtt\n");
	  goto wrapup;
	}

        if( numAtt > 0)
        {

                OmStat = om$send( msg = message  ACcpx.ACfind_exp_temp_obj(
                                                                 &loc_suc,
                                                                 0,
                                                                 &srf_prt ),
                                  senderid = NULL_OBJID,
                                  targetid = attIds[0].objid,
                                  targetos = attIds[0].osnum );
                if(!(OmStat&loc_suc&1) ){
                        printf("Error in VLmatchEdgeWithAtt\n");
                        printf("Error in ACfind_exp_temp_obj = %d\n",i);
                        goto wrapup;
                }

		OmStat = om$send(msg = message ACpretend.ACfind_parent(
						&source,NULL,NULL),
                                  senderid = NULL_OBJID,
                                  targetid = srf_prt.objid,
                                  targetos = srf_prt.osnum);

                if(!(OmStat&1) ){
                        printf("Error in VLmatchEdgeWithAtt\n");
                        printf("Error in ACfind_exp_temp_obj = %d\n",i);
                        goto wrapup;
                }

        strcpy( attrName, VS_K_plThcknsAttr );

          OmStat = om$send( msg = message NDmacro.ACgive_structure (
                                                        &loc_suc ,
                                                        &tmp,
                                                        attrName,
                                                        &attrVal,
                                                        NULL),
                        senderid = NULL_OBJID,
                        targetid = source.objid,
                        targetos = source.osnum  );

          thick = attrVal.var.root_pm_st.value;
	}

	for(i=0;i<numAtt;i++){

		xyzCrvAtt[i] = NULL;

  		OmStat = om$send( msg = message  ACcpx.ACfind_exp_temp_obj(
								 &loc_suc, 
							         1, 
							         &AS_ELEM ),
				  senderid = NULL_OBJID,
                    		  targetid = attIds[i].objid,
	            		  targetos = attIds[i].osnum );
  		if(!(OmStat&loc_suc&1) ){
	  		printf("Error in VLmatchEdgeWithAtt\n");
	  		printf("Error in ACfind_exp_temp_obj = %d\n",i);
			goto wrapup;
		}

  		OmStat = om$send( msg      = message NDmacro.ACreturn_foot(	
					&msg ,
					"",
					&ELEM.obj_id, 
					&ELEM.mod_env.md_env.matrix_type, 
					ELEM.mod_env.md_env.matrix ),
				  senderid = NULL_OBJID,
	   			  targetid = AS_ELEM.objid,
	   			  targetos = AS_ELEM.osnum );
  		if(!(OmStat&msg&1) ){
	  		printf("Error in VLmatchEdgeWithAtt\n");
	  		printf("Error in ACreturn_foot = %d\n",i);
			goto wrapup;
		}

   		ELEM.mod_env.md_id.osnum = ELEM.obj_id.osnum;
		xyzCrvAtt[i] = NULL;
		OmStat = VLgetGeometry( &ELEM, (IGRboolean) FALSE, NULL_OBJID, 
 			       		 (IGRchar **)&xyzCrvAtt[i], &msg );
                if(!(OmStat&msg&1)) {
	  		printf("Error in VLmatchEdgeWithAtt\n");
	  		printf("Error in VLgetGeometry = %d\n",i);
 			goto wrapup;
		}

	}


/*c loop on all the edge_att nci_macros to get the 3D graphic edge att and
    then performes the comparaison test.
    if no edge_att is found the  edgeIds->EdgeMac.objid is set to NULL else
    we store the edge_att GRid */ 

	options = 0;

    	if( checkOpt == 0 ){

	    for(i=0; i<numEdge; i++){

		   OmStat = om$send ( msg      = message EMSedge.EMgetbcgeom(
							&msg,
            						(IGRint) 0,
            						(IGRint) OM_K_MAXINT,
							(IGRboolean) FALSE,
							NULL,
			     				&cv,
				        		NULL,
							options ),
			 senderid = NULL_OBJID,
	   		 targetid = edgeIds[i].EdgeId.objid,
			 targetos = edgeIds[i].EdgeId.osnum );

		   if( !(OmStat&msg&1) ){
	  		printf("Error in VLmatchEdgeWithAtt\n");
	  		printf("Error in EMSedge.EMgetbcgeom = %d\n",i);
 			goto wrapup;
		   }


	    }

    	}/* end checkOpt == 0, for edges in uv space */

    	else{

	    for(i=0; i<numEdge; i++){

		/*d retrieve the xyz bspline edge */

		OmStat = om$send ( msg = message EMSedge.EMget_bcxyz_geom( 
					&msg,
					(struct GRmdenv_info *) NULL,
					(struct GRid *) NULL,
					(struct IGRbsp_surface *)dev->surface,
            				(IGRint) 0,
            				(IGRint) OM_K_MAXINT,
					(IGRboolean) FALSE,
					(struct EMSpartedinfo  *)NULL,
			     		&cv ),

			 senderid = NULL_OBJID,
	   		 targetid = edgeIds[i].EdgeId.objid,
			 targetos = edgeIds[i].EdgeId.osnum );

		 if( !(OmStat&msg&1) ){
	  		printf("Error in VLmatchEdgeWithAtt\n");
	  		printf("Error in EMSedge.EMget_bcxyz_geom = %d\n",i);
 			goto wrapup;
		 }

		
		    #ifdef DEBUG
		    __DBGpr_bscv( "2D cv", &cv, &msg );	
		    #endif

		/* check which 2D edge is matching with the curve attribut */

		for(j=0; j<numAtt; j++){
		   edgeIds[i].EdgeMac.objid = NULL_OBJID;
		   if( xyzCrvAtt[j] != NULL ){

		        #ifdef DEBUG
		    	__DBGpr_bscv( "xyz cv", xyzCrvAtt[j], &msg );	
			#endif

//		        if( VLcheck3DCrv( xyzCrvAtt[j], &cv ) == TRUE ){
		        if( VLcheck3DCrvThk( xyzCrvAtt[j], &cv,thick) == TRUE ){
				#ifdef DEBUG
				printf("edge att = %d coincide with %d\n",j,i);
				#endif
				edgeIds[i].EdgeMac = attIds[j];
				om$dealloc( ptr = xyzCrvAtt[j] );
				xyzCrvAtt[j] = NULL;
				break;
			}
		   }
		}

		if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
		if( cv.knots ){	free( cv.knots ); cv.knots = NULL; }
		if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
		if( cv.bdrys ){	free( cv.bdrys ); cv.bdrys   = NULL; }

	    }/*end loop i */



    	}/*end checkOpt # 0, we check the coincidence against 3D edges*/





	for(i=0;i<numAtt;i++){
		if( xyzCrvAtt[i] != NULL ) {
			om$dealloc( ptr = xyzCrvAtt[i] );
			xyzCrvAtt[i] = NULL;
		}
	}

	if( xyzCrvAtt != NULL ){
		om$dealloc( ptr = xyzCrvAtt );
		xyzCrvAtt = NULL;
	}

	*suc = MSSUCC;
	return(MSSUCC);



wrapup:

	if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
	if( cv.knots ){	free( cv.knots ); cv.knots = NULL; }
	if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
	if( cv.bdrys ){	free( cv.bdrys ); cv.bdrys   = NULL; }

	for(i=0;i<numAtt;i++){
		if( xyzCrvAtt[i] != NULL ) {
			om$dealloc( ptr = xyzCrvAtt[i] );
			xyzCrvAtt[i] = NULL;
		}
	}

	if( xyzCrvAtt != NULL ){
		om$dealloc( ptr = xyzCrvAtt );
		xyzCrvAtt = NULL;
	}

	*suc = MSFAIL;
	return(MSFAIL);

}


/*=========================================================================*/

IGRlong	VL_unw_edgeMatch( dev, NumLoops, LoopIndex, NumEdges, EdgeList, suc )

/*d  VLedgeMatch  retrieves all the 2D edges forming
     a genbs surface and then performs the edge matching between
     3D edge_att and the 3D representaion of the 2D edges. */

/*h 18 January 93 JLL creation date */

struct 	unw_obj_plat	*dev;	    /*I from which we retrieve the surface ID */
	IGRint		*NumLoops;  /*O number of close loops */ 
	IGRint		**LoopIndex;/*O we store the nb of edges per loop */
	IGRint		*NumEdges;  /*O total number of edges */
struct  EdgeMatch	**EdgeList; /*O the edge list */
	IGRlong		*suc;       /*O MSSUCC, MSFAIL */

/*c Beginning of function */

{

  IGRlong		stat, retMsg;
  IGRint 		i, j, ie;

  GRobjid		*LoopIds;
  IGRint		buf_size;
  IGRboolean		is_bevel=FALSE;
  struct	GRid    *EdgesId;
  OM_S_CHANSELECT 	chanloopset;
  IGRuint		nb_loopset;
  IGRlong		option;
  IGRint		depth;
  IGRint		CurNumEdges;
  	IGRushort 	options;
  OM_S_OBJECT_LINKAGE	listLOOPSET;
  	IGRushort	*props;
  IGRint		*locLoopIndex;
  struct EdgeMatch	*locEdgeList;
  IGRint		numMacros;
  struct GRid		*macrosId;
  struct GRid	        GObj;
  struct GRmd_env       EnvGObj;
  struct GRobj_env	TravId;



	#ifdef DEBUG
	printf("--------------VLedgeMatch ------------\n");
	#endif

  	stat = OM_S_SUCCESS;
	locLoopIndex = NULL;
	locEdgeList  = NULL;
	LoopIds      = NULL;
	props	     = NULL;
	EdgesId	     = NULL;
	macrosId     = NULL;

 	/*c We look for the EMSloopset , first check if have one */ 

	chanloopset.type		= OM_e_num;
	stat = om$get_channel_number ( channame  = "EMSsubbs.to_loopset",
				       p_channum = &chanloopset.u_sel.number );
	if ( ! (stat&1)) {
	  printf("Error in VLedgeMatch \n");
	  printf("Error get_channel_number loopset\n"); 
	  goto wrapup;
	}


   GObj.objid = NULL_OBJID;

   stat = om$send( msg      = message NDnode.ASreturn_go( 
					&GObj,
					&EnvGObj.md_env.matrix_type,
    					EnvGObj.md_env.matrix ),
    		senderid = NULL_OBJID, 
   		targetid = dev->surf_id.obj_id.objid, 
   		targetos = dev->surf_id.obj_id.osnum );
 
  if( !( 1 & stat ) ){
	GObj.objid = dev->surf_id.obj_id.objid;
	GObj.osnum = dev->surf_id.obj_id.osnum;
  }

	/*c retrieve the loopset id */

	listLOOPSET.S_objid = NULL_OBJID;
	stat = om$get_channel_objects(    
				osnum	        = GObj.osnum,
				objid	        = GObj.objid,
				p_chanselect	= &chanloopset,
				size		= 1,
				count		= &nb_loopset,
				list		= &listLOOPSET );
	if ( ! (stat&1)) {
	  printf("Error in VLedgeMatch \n");
	  printf("Error No loopset to this element : No a surface with bnd\n");
	  goto wrapup;
	}

	#ifdef DEBUG
	printf("nb_loopset=%d\n",nb_loopset);
	#endif
	
	/*c retrieve the number of loops */

	option  = EMS_OPT_ALL;
  	LoopIds = NULL;
  	props   = NULL;
	depth   = OM_K_MAXINT;
	buf_size = 0;

	stat = om$send ( msg = message EMSloopset.EMget_loops( 	&retMsg,
								option,
								&depth,
								&LoopIds,
								&props,
								&buf_size,
								NumLoops ),
		    senderid = NULL_OBJID,
		    targetid = listLOOPSET.S_objid,
		    targetos = listLOOPSET.osnum );

	if ( !(stat&retMsg&1)) {
	  printf("Error in VLedgeMatch \n");
	  printf("Error in EMSloopset.EMget_loops\n");
	  goto wrapup;
	}
	
	#ifdef DEBUG
	printf("Total NumLoops=%d\n",(*NumLoops));
	#endif 

	/*c malloc the array containing the number of edges per loop */

 	locLoopIndex = (IGRint *) 
			om$malloc( size = (*NumLoops) * sizeof(IGRint) );
 	if( locLoopIndex == NULL ){
	  	printf("Error in VLedgeMatch \n");
		printf(" malloc locLoopIndex : Failed\n");
		goto wrapup;
	}




	/*c find the maximun number of edges in loops */

	j = 0;
	options = 0;

	stat = om$send ( msg = message EMSboundary.EMcount_edges(
							&retMsg, option, &j ),
	            senderid = NULL_OBJID,
		    targetid = listLOOPSET.S_objid,
		    targetos = listLOOPSET.osnum );
	if ( !(stat&retMsg&1)) {
	 	printf("Error in VL_unw_edgematch \n");
	  	printf("Error in EMSboundary.EMcount_edges\n");
	  	goto wrapup;
	}


	#ifdef DEBUG
	printf(" num edges  = %d\n",j);
	#endif

	option = EMS_OPT_ALL;

	/* malloc the array to build the 2D edges match structure */

 	locEdgeList = (struct  EdgeMatch *) 
        om$malloc( size = j * (*NumLoops) * sizeof( struct  EdgeMatch ) );
 	if( locEdgeList == NULL ){
		printf(" malloc locEdgeList : Failed\n");
		goto wrapup;
	}

	EdgesId = NULL;
	depth = 1;
	CurNumEdges = 0;
	buf_size = 0;
	*NumEdges = 0;


	/*c here we store for each loop the number of edges in LoopsIndex.
	    edgesId are store sequentially in EdgeList. */
	

	
	for(i=0;i<(*NumLoops);i++){

		#ifdef DEBUG
		printf("enter EMget_edges = LoopIds[%d]=%d\n",i,LoopIds[i]);
		#endif

		CurNumEdges = 0;

		stat = om$send ( msg = message EMSboundary.EMget_edges( 
						&retMsg,
						depth,
						option,
						&EdgesId,
						&buf_size,
						&CurNumEdges ),
			    senderid = NULL_OBJID,
		            targetid = LoopIds[i],
			    targetos = listLOOPSET.osnum  );

		if ( !(stat&retMsg&1)) {
	 		printf("Error in VLedgeMatch \n");
	  		printf("Error in EMSboundary.EMget_edges\n");
	  		goto wrapup;
		}

		#ifdef DEBUG
		printf("CurNumEdges=%d\n",CurNumEdges);
		#endif

	   	for(ie=0;ie<CurNumEdges;ie++){

		    #ifdef DEBUG
		    	printf("EdgesId[%d] =%d,%d\n",ie, EdgesId[ie].objid,
					                  EdgesId[ie].osnum);
		    #endif

		    locEdgeList[*NumEdges].EdgeId = EdgesId[ie]; 
		    *NumEdges	+= 1;


		}

		locLoopIndex[i] = CurNumEdges;

		CurNumEdges = 0;
		buf_size = 0;
		if( EdgesId != NULL ){ 
			om$dealloc( ptr = EdgesId ); 
			EdgesId = NULL;
		}

	}


	*LoopIndex = locLoopIndex;
	*EdgeList  = locEdgeList;
	if( props != NULL )        om$dealloc( ptr = props );
 	if( EdgesId != NULL )	   om$dealloc( ptr = EdgesId ); 
 	if( LoopIds != NULL )      om$dealloc( ptr = LoopIds );


	/*d We retieve now all the nci_macros edge_attr attach to the surface */
        as$make_source(go_grid = dev->surf_id.obj_id,
                       mod_env = &dev->surf_id.mod_env,
                       as_grid = &TravId.obj_id);

	stat = VLgetChildrenMacro( TravId, "edge_att", 
				    &numMacros, &macrosId, &dev->res_id );
	if( stat != MSSUCC ){
	 	printf("Error in VLedgeMatch \n");
	  	printf("VLgetChildrenMacro Failed\n");
		goto wrapup;
	}

        if( numMacros == 0 )
        {
            stat = VLgetChildrenMacro( TravId, "VSedge3Datt",
                                   &numMacros, &macrosId, &dev->res_id );
            if( stat != MSSUCC ){
                 printf("Error in VLedgeMatch \n");
                 printf("VLgetChildrenMacro Failed\n");
            }
	    __DBGpr_int("Number of VSedge3Datt macros ", numMacros );

	    if( numMacros == 0 )
	    {
                IGRint        loc_nb_mac=0;
                struct GRid   *loc_mac=NULL;

		numMacros = 0;
		_FREE( macrosId ) ;
		stat = VLgetChildrenMacro( TravId, "Bevel",
				  &loc_nb_mac, &loc_mac, &dev->res_id );
		if( stat != MSSUCC ){
		    printf("Error in VLedgeMatch \n");
		    printf("VLgetChildrenMacro Failed\n");
		}
		__DBGpr_int("Number of Bevel macros ", loc_nb_mac );
		if( loc_nb_mac )
		{
		    is_bevel = TRUE;
		    if( macrosId ) macrosId = _REALLOC( macrosId, 
				(numMacros+loc_nb_mac), struct GRid );
		    else  macrosId = _MALLOC( loc_nb_mac, struct GRid ) ;

		    for( i=0; i<loc_nb_mac; ++i )
		  	macrosId[numMacros+i] = loc_mac[i] ; 

		    numMacros += loc_nb_mac;
		    loc_nb_mac = 0;
		    _FREE( loc_mac );
		}
                stat = VLgetChildrenMacro( TravId, "EJ_Bevel",
                                  &loc_nb_mac, &loc_mac, &dev->res_id );
                if( stat != MSSUCC ){
                    printf("Error in VLedgeMatch \n");
                    printf("VLgetChildrenMacro Failed\n");
                }
                __DBGpr_int("Number of EJ_Bevel macros ", loc_nb_mac );
                if( loc_nb_mac )
                {
                    is_bevel = TRUE;
                    if( macrosId ) macrosId = _REALLOC( macrosId, 
                                (numMacros+loc_nb_mac), struct GRid );
                    else  macrosId = _MALLOC( loc_nb_mac, struct GRid ) ;

                    for( i=0; i<loc_nb_mac; ++i )
                        macrosId[numMacros+i] = loc_mac[i] ;

                    numMacros += loc_nb_mac;
                    loc_nb_mac = 0;
                    _FREE( loc_mac );
                }
                stat = VLgetChildrenMacro( TravId, "VA_Bevel",
                                  &loc_nb_mac, &loc_mac, &dev->res_id );
                if( stat != MSSUCC ){
                    printf("Error in VLedgeMatch \n");
                    printf("VLgetChildrenMacro Failed\n");
                }
                __DBGpr_int("Number of VA_Bevel macros ", loc_nb_mac );
                if( loc_nb_mac )
                {
                    is_bevel = TRUE;
                    if( macrosId ) macrosId = _REALLOC( macrosId, 
                                (numMacros+loc_nb_mac), struct GRid );
                    else  macrosId = _MALLOC( loc_nb_mac, struct GRid ) ;

                    for( i=0; i<loc_nb_mac; ++i )
                        macrosId[numMacros+i] = loc_mac[i] ;

                    numMacros += loc_nb_mac;
                    loc_nb_mac = 0;
                    _FREE( loc_mac );
                }
                stat = VLgetChildrenMacro( TravId, "Fab_Stock",
                                  &loc_nb_mac, &loc_mac, &dev->res_id );
                if( stat != MSSUCC ){
                    printf("Error in VLedgeMatch \n");
                    printf("VLgetChildrenMacro Failed\n");
                }
                __DBGpr_int("Number of Fab_Stock macros ", loc_nb_mac );
                if( loc_nb_mac )
                {
                    is_bevel = TRUE;
                    if( macrosId ) macrosId = _REALLOC( macrosId, 
                                (numMacros+loc_nb_mac), struct GRid );
                    else  macrosId = _MALLOC( loc_nb_mac, struct GRid ) ;

                    for( i=0; i<loc_nb_mac; ++i )
                        macrosId[numMacros+i] = loc_mac[i] ;

                    numMacros += loc_nb_mac;
                    loc_nb_mac = 0;
                    _FREE( loc_mac );
                }
		__DBGpr_int("Total Number of Bevel macros ", numMacros );
		__DBGpr_objlist("Bevel Macros ", numMacros, macrosId );
            }
        }

	#ifdef DEBUG
	printf("numMacros edge_att = %d\n",numMacros);	
	#endif

	if( numMacros == 0 ){
		for(ie=0;ie<(*NumEdges);ie++)
			locEdgeList[ie].EdgeMac.objid = NULL_OBJID;
	}
	else{
		/*d edge_att exist so we perform matching between 
		    3D and 2D edges */
		if( is_bevel )
		{
		  VL_unw_matchBevelEdgeWithAtt( dev, numMacros, macrosId,
					(*NumEdges), locEdgeList, &retMsg );
		  if( retMsg != MSSUCC ) goto wrapup;
		}
		else
		{
		   VL_unw_matchEdgeWithAtt( 1, dev, numMacros, macrosId, 
					(*NumEdges), locEdgeList, &retMsg );
		   if( retMsg != MSSUCC ) goto wrapup;
		}
	}

	if( macrosId != NULL ) om$dealloc( ptr = macrosId );

	*suc = MSSUCC;
	return(MSSUCC);


wrapup:
	*suc = MSFAIL;
	*NumEdges  = 0;
	*NumLoops = 0;
	if( locLoopIndex != NULL ) om$dealloc( ptr = locLoopIndex );
	if( locEdgeList != NULL)   om$dealloc( ptr = locEdgeList );
	if( props != NULL )        om$dealloc( ptr = props );
 	if( EdgesId != NULL )	   om$dealloc( ptr = EdgesId ); 
 	if( LoopIds != NULL )      om$dealloc( ptr = LoopIds );
	if( macrosId != NULL ) 	   om$dealloc( ptr = macrosId );
	*LoopIndex = NULL;
	*EdgeList  = NULL;

	return(MSFAIL);
}	

/*==========================================================================*/
IGRlong VL_unw_buildUnwrapEdge( dev, uvEdgeId, activCht, cht, cst, 
			    UnwrapEdgeId, suc )

/*d this fucntion evaluates the 2D unwraped edge according his uv 
    representation in the uv space. the idea his to say that between the
    the 3D surface and the 2D unwraped surface the space is no modifyed.
    This for sure an approximation that looks valid in pratical case */

/*h 25 January 93 JLL creation date */

struct 	unw_obj_plat	*dev;		/*I dev structure to use the 3D surface
					    and its 2D unwraped evaluation */
struct	GRid		*uvEdgeId;	/*I the edge in uv space */
	IGRdouble	activCht;	/*I the 3d active cht use as a backup */
	IGRdouble	cht;		/*  cht that you want to apply to
					    perfom the stroking */
struct	GRvg_construct	*cst;		/*I construction  */
struct	GRobj_env	*UnwrapEdgeId;  /*O the 2D unwraped edge */
	IGRlong		*suc;		/*O MSSUCC or MSFAIL */

/*c Beginning of function */

{

	 IGRlong	OmStat;
struct 	 IGRpolyline	lst;
struct   IGRbsp_curve	cv;
	 IGRushort 	options;
	 IGRdouble	*P;
	 IGRint		MaxPts;
	 IGRdouble	*pars, u, v;
	 IGRint		k;
  	 IGRint		size_buf;
         double         ptDr[3],vecDr[6], refNor[3], angTol2 ;
static   int            bound_count=0; /* used in the case of ARC_LENGTH 
                                          tesselation option. this the 
                                          number of the edge of the plate */

#ifdef DEBUG
	printf("------------------ VLbuildUnwrapEdge --------------\n");
#endif

        if (bound_count == 4) bound_count = 0;

	options = 0;
	angTol2    = 0.1 ;
 	cv.poles   = NULL;
 	cv.knots   = NULL;
 	cv.weights = NULL;
 	cv.bdrys   = NULL;
	UnwrapEdgeId->obj_id.objid = NULL_OBJID;
	UnwrapEdgeId->obj_id.osnum = cst->env_info->md_id.osnum;
	pars       = NULL;
	lst.num_points = 0 ;
	lst.points = NULL;

#ifdef DEBUG
	printf("cht = %f, activCht = %f\n", cht, activCht);
	printf("Edge: %d, %d\n", uvEdgeId->objid, uvEdgeId->osnum );
#endif

	/*c retrieve the uv space definition of the edge  */
	OmStat = om$send ( msg      = message EMSedge.EMgetbcgeom(
							suc,
            						(IGRint) 0,
            						(IGRint) OM_K_MAXINT,
							(IGRboolean) FALSE,
							NULL,
			     				&cv,
				        		NULL,
							options ),
		 senderid = NULL_OBJID,
		 targetid = uvEdgeId->objid,
		 targetos = uvEdgeId->osnum );
	if( !(OmStat & *suc & 1) ){
	  	printf("Error in VLbuildUnwrapEdge \n");
	  	printf("EMSedge.EMgetbcgeom Failed\n");
		goto wrapup;
	}

#ifdef DEBUG 
	printf(" num_poles = %d, order=%d\n",cv.num_poles, cv.order);
	__DBGpr_bscv( "2d cv", &cv, suc ); 
#endif 

	if( cv.num_poles == 2 ){

          if (dev->tesselation_option == ARC_LENGTH) {
           /* by construction, we computed dev->Param_u and dev->Nb_u
              on this two edges */
#ifdef	DEBUG
	    printf(" tesselation : %d \n", dev->tesselation_option );
	    printf(" bound_count : %d \n", bound_count );
	    printf(" dev->Nb_u   : %d \n", dev->Nb_u  );
	    printf(" dev->Nb_v   : %d \n", dev->Nb_v  );
#endif
            if (bound_count == 0 || bound_count == 2) {
              	P = dev->Param_u;
              	MaxPts = dev->Nb_u;
            }
            else {
              /* by construction, we computed dev->Param_v and dev->Nb_v
                 on this two edges */
              	P = dev->Param_v;
              	MaxPts = dev->Nb_v;
            }
#ifdef	DEBUG
	    printf(" MaxPts : %d \n", MaxPts );
#endif
	    lst.num_points = MaxPts ;
            lst.points = NULL;
            lst.points = (IGRdouble *)
            		om$malloc( size = 3*MaxPts*sizeof(IGRdouble));
            if( lst.points == NULL ){
                    printf("Error in VLbuildUnwrapEdge \n");
                    goto wrapup;
            }

            for(k=0;k<MaxPts;k++){
#ifdef	DEBUG
		printf("Param[%d]: %f \n", k, P[k] ); 
#endif
                lst.points[3*k]   = (1.0-P[k])*cv.poles[0] + P[k]*cv.poles[3];
                lst.points[3*k+1] = (1.0-P[k])*cv.poles[1] + P[k]*cv.poles[4];
            }

            MaxPts = 3 * MaxPts;

#ifdef	DEBUG
	    printf(" Num Poles: %d\n", lst.num_points );
	    for( k=0 ; k<lst.num_points ; k++ )
	       printf("Pole[%d]: %f, %f, %f\n", k, lst.points[3*k],
				lst.points[3*k+1], lst.points[3*k+2] );
#endif

            for(k=0;k<MaxPts;k+=3){
                u = lst.points[k];
                v = lst.points[k+1];
                OmStat = VLevPtNor( suc, dev->surface, lst.points, k, MaxPts,
                                angTol2, refNor, ptDr, vecDr );
#ifdef	DEBUG
	        printf("vecDr[%d]= %f, %f, %f \n",k,vecDr[0],vecDr[1],vecDr[2]);
                if( *suc != BSSUCC ){ printf(" BSsfevaln 1 (suc)\n"); }
                if( OmStat != MSSUCC ){ printf(" BSsfevaln 1 (OMstat)\n"); }
#endif 
                FAevPtSfFaDr((IGRshort) 3,dev->P,dev->devsrf,
                            dev->def, ptDr, vecDr, u,v,
                            &(lst.points[k]),suc);
		if( *suc != 0 ){ printf(" FAevPtSfFaDr 1 \n"); }
             }
          }
          else {
		
		/*c check if it an iso curve in u or in v */
		/*c if true then MaxPts, the number of points to evaluate
		    along the iso will be equal to the number of points
		    for the tessalation 
		    else the MaxPts will be set to the sup between the number
		    in u and v.  */

		if( fabs((cv.poles[0]-cv.poles[3]) ) < 1.0E-10 ){

#ifdef DEBUG
			printf("constant in u\n");
#endif
                        P = dev->Param_v;
                        MaxPts = dev->Nb_v;

			lst.points = NULL;
 			lst.points = (IGRdouble *)
			om$malloc( size = 3*MaxPts*sizeof(IGRdouble));
 			if( lst.points == NULL ){
	  			printf("Error in VLbuildUnwrapEdge \n");
				printf(" malloc 1 lst.points : Failed\n");
				goto wrapup;
 			}
				
			for(k=0;k<MaxPts;k++){
			    u = (1.0-P[k])*cv.poles[0] + P[k]*cv.poles[3];
			    v = (1.0-P[k])*cv.poles[1] + P[k]*cv.poles[4];
			    BSsfeval( dev->devsrf,u,v,0,&(lst.points[3*k]),suc);
			}
		}
		else if(fabs((cv.poles[1]-cv.poles[4])) < 1.0E-10){

#ifdef DEBUG
			printf("constant in v\n");
#endif

                        P = dev->Param_u;
                        MaxPts = dev->Nb_u;

			lst.points = NULL;
 			lst.points = (IGRdouble *)
				om$malloc( size = 3*MaxPts*sizeof(IGRdouble));
 			if( lst.points == NULL ){
	  			printf("Error in VLbuildUnwrapEdge \n");
				printf(" malloc 2 lst.points : Failed\n");
				goto wrapup;
 			}

			for(k=0;k<MaxPts;k++){
			    u = (1.0-P[k])*cv.poles[0] + P[k]*cv.poles[3];
			    v = (1.0-P[k])*cv.poles[1] + P[k]*cv.poles[4];
			    BSsfeval( dev->devsrf,u,v,0,&(lst.points[3*k]),suc);
                        }
		}
		else{

			/*c we got a lineseg in the uv space that is not
			    parallel to the axis. We should have done a
			    stroking according the 3D cht to get the real
			    uv list. Because no approximation in the uv
			    space, this case appears just if the surface is
			    a plane */
		
			MaxPts = 6;
			lst.points = NULL;
 			lst.points = (IGRdouble *)
			om$malloc( size = MaxPts*sizeof(IGRdouble));
 			if( lst.points == NULL ){
	  			printf("Error in VLbuildUnwrapEdge \n");
				printf(" malloc 3 lst.points : Failed\n");
				goto wrapup;
 			}

			for(k=0;k<MaxPts;k+=3){
			    BSsfeval( dev->devsrf,cv.poles[k], cv.poles[k+1],
				      0,&(lst.points[k]),suc);
                        }
			
			MaxPts = 2;
		}
                lst.num_points = MaxPts;
          }
	}/* we got a BSedge with just two poles */
	else{

		if( cv.order == 2 ){
		    MaxPts = 3 * cv.num_poles;
		    lst.points = NULL;
 		    lst.points = (IGRdouble *)
				  om$malloc( size = MaxPts*sizeof(IGRdouble));
 		    if( lst.points == NULL ){
	  		printf("Error in VLbuildUnwrapEdge \n");
			printf(" malloc 4 lst.points : Failed\n");
			goto wrapup;
 		    }

                    if (dev->tesselation_option == PARAMETRIC){
		      for(k=0;k<MaxPts;k+=3) {
			 BSsfeval( dev->devsrf,cv.poles[k],cv.poles[k+1],
				          0,&(lst.points[k]),suc);
                      }
                    }
		    else{
		      for(k=0;k<MaxPts;k+=3) {
                         OmStat = VLevPtNor( suc, dev->surface, cv.poles, k,
                                        MaxPts, angTol2, refNor, ptDr, vecDr );
#ifdef	DEBUG
	        	 printf(" vecDr[%d] = %f, %f, %f \n",
					k,vecDr[0], vecDr[1], vecDr[2]);
			 if(*suc != BSSUCC){ printf(" BSsfevaln 2 (suc)\n"); }
                	 if(OmStat != MSSUCC){ 
					printf(" BSsfevaln 2 (OMstat)\n"); }
#endif 
                         FAevPtSfFaDr((IGRshort)3,dev->P,dev->devsrf,dev->def,
                                      ptDr, vecDr, cv.poles[k],cv.poles[k+1],
                                      &(lst.points[k]),suc);
			 if( *suc != 0 ){ printf(" FAevPtSfFaDr 2 \n"); }
                      }
                    }

		    lst.num_points = cv.num_poles;

		} /* the BSedge is a linestring with more than 2 poles */
		else{
			size_buf = sizeof(IGRdouble);
     			gr$put_chord_height_tolerance (
						msg = suc,
			 			sizbuf= &size_buf,
			 			buffer= &cht );

#ifdef DEBUG
			printf("Enter BSchtptstcv\n");
#endif
			BSchtptstcv(&cv,&lst.num_points,&(lst.points),
					&pars, suc);
#ifdef DEBUG
			printf("Exit BSc lst.num_points = %d\n",lst.num_points);
#endif
     			gr$put_chord_height_tolerance (
						msg = suc,
			 			sizbuf= &size_buf,
			 			buffer= &activCht );
	
			MaxPts = 3 * lst.num_points;

                        if (dev->tesselation_option == PARAMETRIC){
			  for(k=0;k<MaxPts;k+=3){
			       u = lst.points[k];
			       v = lst.points[k+1];
			       BSsfeval(dev->devsrf,u,v,0,&(lst.points[k]),suc);
                          }
			}
		        else{
			  for(k=0;k<MaxPts;k+=3){
			       u = lst.points[k];
			       v = lst.points[k+1];
                               OmStat =
                               VLevPtNor( suc, dev->surface, lst.points, k,
                                        MaxPts, angTol2, refNor, ptDr, vecDr );
#ifdef	DEBUG
	        printf("vecDr[%d]= %f, %f, %f \n",k,vecDr[0],vecDr[1],vecDr[2]);
                if( *suc != BSSUCC ){ printf(" BSsfevaln 3 (suc)\n"); }
                if( OmStat != MSSUCC ){ printf(" BSsfevaln 3 (OMstat)\n"); }
#endif 
                               FAevPtSfFaDr((IGRshort) 3,dev->P,dev->devsrf,
                                            dev->def, ptDr, vecDr, u,v,
                                            &(lst.points[k]),suc);
			       if( *suc != 0 ){ printf(" FAevPtSfFaDr 3 \n"); }
                          }
			}
		}/* the order of this BSedge is > 2 */

	}/* we got a BSedge with more than two poles */

	/* Remove all the duplicate points, if there are any - RR 03/21/00 */
        OmStat = VLunwRemoveDuplicatePoints( cv.phy_closed,
					&lst.num_points, &lst.points );

	/*c construct the linestring */
     	memcpy ( (IGRchar *)&UnwrapEdgeId->mod_env,
		 (IGRchar *)cst->env_info,
	         (IGRint) sizeof( struct GRmd_env) );

 	cst->geometry	= (IGRchar *) &lst;

#ifdef	DEBUG
	printf(" Num Poles : %d\n", lst.num_points );
	for( k=0 ; k<lst.num_points ; k++ )
	  printf("Pole[%d]: %f, %f, %f\n", k, lst.points[3*k],
				lst.points[3*k+1], lst.points[3*k+2] );
	printf("\n\n-----------------\n\n");
#endif
  	OmStat=om$construct( classid = OPP_GR3dlinestr_class_id, 
	                     p_objid = &UnwrapEdgeId->obj_id.objid, 
         	             osnum   = UnwrapEdgeId->obj_id.osnum,
		             msg     = message GRgraphics.GRaltconstruct(cst) );
	if( !(OmStat&1) ){
	  	printf("Error in VLbuildUnwrapEdge \n");
	  	printf(" om$construct Failed\n");
		goto wrapup;
	}
        if (dev->tesselation_option == ARC_LENGTH) bound_count++;

	if(pars){ om$dealloc( ptr = pars ); pars = NULL; }
	if(lst.points){ om$dealloc( ptr = lst.points ); lst.points = NULL;}
	if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
	if( cv.knots ){	free( cv.knots ); cv.knots = NULL; }
	if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
	if( cv.bdrys ){	free( cv.bdrys ); cv.bdrys   = NULL; }

 	cst->geometry	= NULL;
	*suc = MSSUCC;
	return(MSSUCC);


wrapup:
 	cst->geometry	= NULL;
	if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
	if( cv.knots ){	free( cv.knots ); cv.knots = NULL; }
	if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
	if( cv.bdrys ){	free( cv.bdrys ); cv.bdrys   = NULL; }

	if(pars){ om$dealloc( ptr = pars ); pars = NULL; }
	if(lst.points){ om$dealloc( ptr = lst.points ); lst.points = NULL;}
	*suc = MSFAIL;
	return(MSFAIL);

}

/*==========================================================================*/

IGRlong VL_unw_creBoundWithOff (

struct 	unw_obj_plat	*dev,	    /*I structure containing the informations */
struct	GRvg_construct	*cst,	    /*I construction list */
        IGRboolean	DisOpt,	    /*I display needed or not */
	IGRboolean      add_stock,  /*I Add Stock? */
	IGRint		*NumObj,    /*O number of loop objects return */
struct  GRobj_env	**ObjRet,   /*O loop objects return */
	IGRint		**LoopIndex,/*O gives the nb of edges in each loop */
	IGRint		*NumEdges,  /*O total number of edges */
struct  EdgeMatch	**EdgeList, /*O the edge list  containing the unwraped
					edge ID and the edge_attribut macro
					matching with */
        int		*surf_type, /*O : type of the surface (Port,
                                          Starboard or Middle). */
struct  GRid		*line,      /*O : will contain the two unwrapping 
                                           edges corresponding to the plate's
                                           closest edges to the Middle, Front 
                                           or Down of the boat */
	int             *nb_old_crvs,
	struct  GRid    **old_crvs,
	IGRlong		*suc        /*O MSSUCC, MSFAIL */
)	

/*d  This function evaluates the unwraped edge of a unwraped surface 
    taking into account the edge attributs that could be attached to
    the parent surface.  */

/*h 3 January 93 JLL creation date */
/*h 16 May    94 JLL set objRet and lcCv to NULL_OBJID after malloc */



/*c Beginning of function */
{

  	IGRint		i, j, k, ie;
  	IGRlong		OmStat;
struct	IGRbsp_curve	cv;
struct  GRobj_env	*LcCv;

struct	GRobj_env	StrID;
	IGRdouble	activCht, cht;
	IGRint		size_buf;
	IGRdouble	*OfVal;
	IGRint		OuiNon;

struct  GRid 		edgeC,edgeF,edgeD; /* closest edges to the Middle,
                                              Front and Down of the boat */
struct  GRid 		lineC,lineF,lineD; /* unwrapping edges corresponding to
                                              the closest edges to the Middle,
                                              Front and Down of the boat */
        int 		orient;            /* Horizontal, transversal or
                                              longitudinal */
struct  GRid		*CmpLst;
        IGRint		ii,NumCmp;
        IGRint		ii0,ii1,ii2;
        IGRint		iiC,iiF,iiD;
struct IGRbsp_curve	**edgeCv,**CmpCv; 

IGRshort		TypeOfCurve;
struct	GRid		*ConCrvs;
IGRint			NumConCrvs;
IGRdouble		info[4], bid[6], xaxis[3];
IGRboolean		bool,bool0;
IGRuchar        	props;
IGRboolean		isRevNorm=FALSE, isInsideOut1 = TRUE, isInsideOut2 = FALSE;
struct GRid        	plt_surf;
struct GRobj_env   	par_plate;
VSpartAttr         	pltAttr ;
VSplateAttr        	pltInfo ;
struct IGRplane		plane;

  #ifdef DEBUG
   printf("------------------------ VL_unw_creBoundWithOff --------------------\n");
  #endif

  ConCrvs    = NULL;
  *ObjRet    = NULL;
  *LoopIndex = NULL;
  *EdgeList  = NULL;
  CmpLst     = NULL;
  CmpCv      = NULL;
  edgeCv     = NULL;
  cv.poles   = NULL;
  cv.weights = NULL;
  cv.knots   = NULL;
  LcCv       = NULL;
  OfVal	     = NULL;
  iiF = iiC = iiD = 0;
  ii0 = ii1 = ii2 = 0;
  NumConCrvs = 0;
  bool = FALSE;
  bool0 = FALSE;
  xaxis[0] = 1.0; xaxis[1] = 0.0; xaxis[2] = 0.0;

  isReverse = FALSE;

  VL_unw_edgeMatch( dev, NumObj, LoopIndex, NumEdges, EdgeList, suc );
  if( *suc != MSSUCC ){
  	printf("Error in VL_unw_creBoundWithOff\n");
  	printf("VL_unw_edgeMatch Failed\n");
	goto wrapup;
  }
#ifdef DEBUG
  printf("return VL_unw_edgeMatch NumObj=%d,NumEdges%d\n",(*NumObj),(*NumEdges));
#endif
  /*c malloc the array to return the unwraped composite curve */

  (*ObjRet) = (struct  GRobj_env *)
	  om$malloc( size = (*NumObj) * sizeof(struct GRobj_env) );
  if( *ObjRet == NULL ){
  	printf("Error in VL_unw_creBoundWithOff\n");
	printf(" om$malloc ObjRet : Failed\n");
	goto wrapup;
  }

  for(i=0;i<(*NumObj);i++) (*ObjRet)[i].obj_id.objid = NULL_OBJID;

  /*c malloc the GRlc_info structure to build composite curve */
  /*c set the object ID to NULL_OBJID */

  LcCv = (struct  GRobj_env *)
	  om$malloc( size = (*NumEdges) * sizeof(struct GRobj_env) );
  if( LcCv == NULL ){
  	printf("Error in VL_unw_creBoundWithOff\n");
	printf(" om$malloc LcCv : Failed\n");
	goto wrapup;
  }

  for(i=0;i<(*NumEdges);i++) LcCv[i].obj_id.objid = NULL_OBJID;


  /*c get the active cht */

  size_buf = sizeof(cht);
  gr$get_chord_height_tolerance ( 	msg 	= suc,
				  	sizbuf	= &size_buf,
					buffer	= &activCht,
					nret	= &size_buf	);
  cht = activCht / 10000;
  if( cht < 0.0001 ) cht = 0.0001;

  if (!VLlongHorzOrTrans(&dev->surf_id,&orient)) {
    printf("Error in VL_unw_creBoundWithOff\n");
    goto wrapup;
  }

  if((*suc = VLfindOrientation(&dev->surf_id,&edgeC,&edgeF,
                                 &edgeD,surf_type))!= MSSUCC){
    printf("Error in VL_unw_creBoundWithOff\n");
    printf("VLfindOrientation : Failed\n");
    goto wrapup;
  }

  ie = 0;

  for(i=0; i<(*NumObj); i++ ){
	
	for(j=0; j<(*LoopIndex)[i]; j++){

//#ifdef BBB
          if (dev->developpable == 1){


		/*c the surface is planar then we just copy the edges and
		    set the active level */

		#ifdef DEBUG
		printf("surface is planar\n");
		#endif

		OmStat = vs$get_graphic_edge( msg    = suc,
                                             edId   = &((*EdgeList)[ie].EdgeId),
                                             edEnv  = &(dev->surf_id.mod_env),
                                             copy   = TRUE,
                                             copyEnv= cst->env_info,
                                             grEdge = &(StrID.obj_id)) ;
                if( !( OmStat & 1 & *suc) ) {
    		    printf("Error in VL_unw_creBoundWithOff\n");
                    printf( "vs$get_graphic_edge Failed\n" ) ;
                }

                StrID.mod_env = *(cst->env_info);

		OmStat = om$send( msg = message GRvg.GRchglevel( 
						suc,
						(IGRshort *) &(cst->level) ),
                                senderid = NULL_OBJID,
                                targetid = StrID.obj_id.objid,
	                        targetos = StrID.obj_id.osnum ) ;
        	if (!(OmStat&(*suc)&1)) {
    		    	printf("Error in VL_unw_creBoundWithOff\n");
          		printf("GRchglevel Failed\n");
        	}
          }/* end case if the surface is planar */

          else {
//#endif

		/*c the surface is not planar */
  		/*c for each 3D edge build the corresponding unwraped edge */

#ifdef DEBUG
		  printf("enter VLbuildUnwrapEdge\n");
		  printf("EdgeList[%d]=%d,%d\n",ie,(*EdgeList)[ie].EdgeId.objid,
			(*EdgeList)[ie].EdgeId.osnum);
#endif

		VL_unw_buildUnwrapEdge( dev, &(*EdgeList)[ie].EdgeId, activCht, 
				    cht, cst, &StrID, suc );
		if( *suc != MSSUCC ){
  			printf("Error in VL_unw_creBoundWithOff\n");
			printf(" VLbuildUnwrapEdge : Failed\n");
			goto deldel;

		}
          }

          if (i==0 & line != NULL) { /* Find the unwrapped edges 
                                        corresponding to edgeC, edgeF
                                        et edgeD */
       
           	if( edgeC.objid == (*EdgeList)[ie].EdgeId.objid &&
               	    edgeC.osnum == (*EdgeList)[ie].EdgeId.osnum) {
             		lineC = StrID.obj_id; 
             		iiC = ie;
          	}

          	if( edgeF.objid == (*EdgeList)[ie].EdgeId.objid &&
               	    edgeF.osnum == (*EdgeList)[ie].EdgeId.osnum) {
             		lineF = StrID.obj_id;
             		iiF = ie;
          	}

           	if( edgeD.objid == (*EdgeList)[ie].EdgeId.objid &&
               	    edgeD.osnum == (*EdgeList)[ie].EdgeId.osnum) {
             		lineD = StrID.obj_id;
             		iiD = ie;
           	}
          }

	  LcCv[j].obj_id = StrID.obj_id;
	  (*EdgeList)[ie].EdgeId = StrID.obj_id;

     	  memcpy ( (IGRchar *)&LcCv[j].mod_env,
	  	   (IGRchar *)cst->env_info, 
		   (IGRint)sizeof( struct GRmd_env) );

	  ie += 1;

	}/* we built the unwrap edge j of the each edges i */

	/*c construct a composite curve if the loop contains more than
	    one edge */

#ifdef DEBUG

	printf("(*LoopIndex)[%d]=%d, ie=%d\n",i,(*LoopIndex)[i], ie);
	for(j=0; j<(*LoopIndex)[i];j++)
	   printf("LcCv[%d] = %d,%d\n",j, LcCv[j].obj_id.objid,
		  LcCv[j].obj_id.osnum);
#endif

	if( (*LoopIndex)[i] > 1 ){

		cst->geometry = NULL;
		(*ObjRet)[i].obj_id.objid = NULL_OBJID;
		(*ObjRet)[i].obj_id.osnum = cst->env_info->md_id.osnum;

		TypeOfCurve = 3;

	    	if( 0 ){
		  SortAndBuildCrv( LcCv, (*LoopIndex)[i], TypeOfCurve, cst, 
		     		 &ConCrvs, &NumConCrvs, suc );
	    	}
	    	else{
			/* Composite from individuals... */
			IGRshort		Orient[60];
			struct GRid		newCrv ;
			struct GRlc_info	outCrvs[60];
			IGRint			o ;
			IGRboolean		adjNeeded = TRUE,
						phyClosed = FALSE ;
#ifdef	DEBUG
			printf("NumConCrvs = %d\n",NumConCrvs);
#endif
			/*
			 * Retry with BuildCrv
			 */
			for( o=0 ; o<(*LoopIndex)[i]; o++ ) Orient[o]=1;
			TypeOfCurve = 3;
#ifdef	DEBUG
			printf("Call BuildCrv ... \n");
#endif
			newCrv.objid = NULL ;
			BuildCrv( TypeOfCurve,
				  LcCv,
				  (*LoopIndex)[i], Orient,
				  adjNeeded, phyClosed,
				  outCrvs, 
				  cst,
				  &newCrv,
				  suc );
#ifdef	DEBUG
			printf(" newCrv: %d,%d\n", newCrv.objid, newCrv.osnum);
#endif
			if( *suc == BSSUCC ){
				(*ObjRet)[i].obj_id  = newCrv ;
				(*ObjRet)[i].mod_env = *(cst->env_info);
			}
			else{
#ifdef	DEBUG
				printf(" BuildCrv failed ...\n");
#endif
				goto deldel;
		
			}
			continue ;
		}

		if( NumConCrvs == 0 ) {
#ifdef	DEBUG
	  		printf("Error in VL_unw_creBoundWithOff\n");
		     	printf( "SortAndBuildCrv Failed for loop=%d: \n",i );
#endif
			(*ObjRet)[i].obj_id.objid = NULL_OBJID;
			goto deldel;
		}
		else if( NumConCrvs == 1 ){
			if( ConCrvs[0].objid == NULL_OBJID ){
#ifdef	DEBUG
	  		   printf("Error in VL_unw_creBoundWithOff\n");
		     	   printf( "SortAndBuildCrv Failed for loop=%d: \n",i );
#endif
			   goto deldel;
			}

			(*ObjRet)[i].obj_id = ConCrvs[0];
			(*ObjRet)[i].mod_env = *(cst->env_info);

		}
		else{
                        printf("NumConCrvs = %d\n",NumConCrvs);
                        (*ObjRet)[i].obj_id.objid = NULL_OBJID;
			goto deldel;
		}
	}
	else{
		(*ObjRet)[i].obj_id  = LcCv[0].obj_id;
		(*ObjRet)[i].mod_env = *(cst->env_info);
	}

#ifdef	DEBUG
 	gr$display_object ( object_id = (struct GRid *)&(*ObjRet)[i].obj_id,
		     	    mode      = GRbd );
#endif
	if( DisOpt == TRUE )
 	gr$display_object ( object_id = (struct GRid *)&(*ObjRet)[i].obj_id,
		     	    mode      = GRbd );

  }/* end of loop i */

 if (line != NULL) {
	switch (orient) {

      		case VL_HORZ : // horizontal
        	   if (*surf_type == VL_MIDDEL) {//if the surface cut shipaxis
                                               // we just need the closest edge
                                               // to the front.
          			line[0].objid = NULL_OBJID;
          			line[1] = lineF;
          			line[2] = lineC;// it will be needed for
                                                // several choices by
                                               // the function VLget_mac_names.
          			ii0 = -1;
          			ii1 = iiF;
          			ii2 = iiC;
        		}
        		else {
        			line[2] = line[0] = lineC;
          			line[1] = lineF;
          			ii0 = ii2 = iiC;
          			ii1 = iiF;
        		}
        		break;

      		case VL_TRANS : // transversal
        	     if (*surf_type == VL_MIDDEL) {//if the surface cut shipaxis
                                               // we just need the closest edge
                                               // to the DOWN.
          			line[0].objid = NULL_OBJID;
          			line[1] = lineD;
          			line[2] = lineC;// it will be needed for
                                                // several choices by
                                               // the function VLget_mac_names.
          			ii0 = -1;
          			ii1 = iiD;
          			ii2 = iiC;
        		}
        		else {
          			line[2] = line[0] = lineC;
          			line[1] = lineD;
          			ii0 = ii2 = iiC;
          			ii1 = iiD;
        		}
        		break;

       		case VL_LONG : // longitudinal
         		line[0] = lineF;
         		line[1] = lineD;
          		ii2 = ii0 = iiF;
          		ii1 = iiD;
       			break;

       		default : goto deldel; 
    	}

#ifdef DEBUG
	printf("LES LINES=%d %d %d %d %d %d\n", line[0].objid,line[0].osnum,
						line[1].objid,line[1].osnum,
						line[2].objid,line[2].osnum);
	fflush(stdout);
#endif
  }
  

  /*c retrieve the offset values strored in the edge_att */

  OfVal = (IGRdouble *)
	  om$malloc( size = (*NumEdges) * sizeof(IGRdouble) );
  if( OfVal == NULL ){
  	printf("Error in VL_unw_creBoundWithOff\n");
	printf(" malloc OfVal : Failed\n");
	goto deldel;
  }

  for(i=0;i<(*NumEdges);i++){
	if( (*EdgeList)[i].EdgeMac.objid != NULL_OBJID && add_stock ){
  		VLretOfVal( &((*EdgeList)[i].EdgeMac),
			     &(OfVal[i]), suc );
  		if( (*suc) != MSSUCC ){
  			printf("Error in VL_unw_creBoundWithOff\n");
	     		printf( "VLretOfVal Failed for loop=%d: \n",i );
			goto deldel;
		}
	}
	else OfVal[i] = 0.0;
  }

  #ifdef DEBUG
  __DBGpr_double("OfVal",OfVal,1,(*NumEdges));
  #endif


  as$make_source(go_grid = dev->surf_id.obj_id,
                 mod_env = &dev->surf_id.mod_env,
                 as_grid = &plt_surf		);

  if( vs$is_ancestry_valid( object  = &plt_surf,
                                   classid = OPP_ACpretend_class_id )){

      OmStat   = om$send(  msg     = message ACpretend.ACfind_parent(
                                 	&par_plate.obj_id,
                                 	&par_plate.mod_env.md_env.matrix_type,
                                  	par_plate.mod_env.md_env.matrix ),
		 senderid = NULL_OBJID,
                 targetid = plt_surf.objid,
                 targetos = plt_surf.osnum ) ;
  }

  pltAttr.Iwant    = VS_m_Orientation ;
  pltAttr.specific = (void *) &pltInfo ;
  OmStat = om$send(  msg     = message GRvg.GRgetattr( suc, 
						       (char *) &pltAttr ),
			senderid = NULL_OBJID,
                        targetid= par_plate._objid,
                        targetos= par_plate._osnum ) ;

  if( pltInfo.orientation == VS_K_USE_REV_NORM ) isRevNorm = TRUE;

  plane.point  = (IGRdouble *)&bid[0];
  plane.normal = (IGRdouble *)&bid[3];

  bid[3] = bid[4] = bid[5] = 0. ;

  OmStat = om$send( msg = message GRvg.GRdetplane(
                                        suc,
                                        &(*ObjRet)[0]._matrix_type,
                                        (*ObjRet)[0]._matrix,
                                        &plane ),
                         senderid = NULL_OBJID,
                         targetid = (*ObjRet)[0]._objid,
                         targetos = (*ObjRet)[0]._osnum );

  OmStat = om$send ( msg = message EMSsubbs.EMget_props
                                         ( suc, &props ),
                      senderid = NULL_OBJID,
                      targetid = dev->surf_id.obj_id.objid,
                      targetos = dev->surf_id.obj_id.osnum );

  if( !(props & EMSIS_NRML_REVERSED) || isRevNorm )
  {
      if( (fabs(bid[3])-1) < 0.001 &&
	   fabs(bid[4])    < 0.001 &&
	   fabs(bid[5])    < 0.001    )
      {
          if (BSdotp ( suc, &bid[3], xaxis) < 0.0) {
	     isReverse = TRUE;
	     // isInsideOut1 = FALSE;
	     // isInsideOut2 = TRUE;
	  }
      }
      else 
      {
	  isReverse = TRUE;
      }
  }

  /*c apply the offset values on each loop if needed */

  j  = 0;
  ie = 0;
  for(i=0; i<(*NumObj); i++ ){
	
	ie += (*LoopIndex)[i];

	VLisOffNeeded( /*&((*EdgeList)[0])*/OfVal, j, ie, &OuiNon );

	#ifdef DEBUG
	printf("exit VLisOffNeeded j = %d, ie = %d, OuiNon = %d\n", 
		j,ie,OuiNon);
	#endif

/* Added to take care of internal loops for holes and cutouts
     for TR#179800473 */

        if( i>0 )
        {
            GRobjid tmp_id;

            OmStat = om$send(msg = message GRgraphics.GRcopy(
                                                suc,
                                                &(*ObjRet)[i].mod_env,
                                                cst->env_info,
                                                &tmp_id ),
                                senderid = NULL_OBJID,
                                targetid = (*ObjRet)[i].obj_id.objid,
                                targetos = (*ObjRet)[i].obj_id.osnum );
            if (!(OmStat&(*suc)&1)) {
                goto wrapup;
            }
            (*ObjRet)[i].obj_id.objid = tmp_id;
            (*ObjRet)[i].obj_id.osnum = cst->env_info->md_id.osnum;
            (*ObjRet)[i].mod_env = *cst->env_info;
            OuiNon = FALSE;
        }

/* End TR#179800473             */

	if( OuiNon == TRUE ){
          bool = TRUE;

          if (i==0) {
		VLoffset_Cv( &(*ObjRet)[i], cst, (IGRboolean)isInsideOut1, 
		   (IGRdouble *)NULL, (*LoopIndex)[i], &(OfVal[j]), 
		   info, (IGRboolean)FALSE, &StrID, nb_old_crvs, old_crvs, suc);
                bool0 = TRUE;
          }
          else
		VLoffset_Cv( &(*ObjRet)[i], cst, (IGRboolean)isInsideOut2, 
		   (IGRdouble *)NULL, (*LoopIndex)[i], &(OfVal[j]), 
                   NULL, (IGRboolean)FALSE, &StrID, nb_old_crvs, old_crvs, suc);

 		if( (*suc) != MSSUCC ){
	  		printf("Error in VL_unw_creBoundWithOff\n");
			printf( "VLoffset_Cv Failed for loop=%d: \n",i );
			goto deldel;
		} 

		(*ObjRet)[i] = StrID;
	}

	j = ie;

  }

  if (bool == TRUE) {
  j=0;
  for(i=0; i<(*NumObj); i++ ){
     if ((*LoopIndex)[i] > 1) {
        OmStat = om$send( msg      = message GRowner.GRget_number_components(
                                                                suc,
                                                                &NumCmp ),
                          senderid = NULL_OBJID,
                          targetid = (*ObjRet)[i].obj_id.objid,
                          targetos = (*ObjRet)[i].obj_id.osnum );
        if (!(OmStat&(*suc)&1)) {
                printf("Error in VL_unw_creBoundWithOff\n");
                printf( "GRget_number_components\n");
                goto deldel;
        }
     }
     else NumCmp = 1;
        
        if (j < NumCmp) j = NumCmp;
   }

   CmpLst = (struct  GRid *)
                  om$malloc( size =  j * sizeof( struct GRid ) );
   if( CmpLst == NULL ){
           printf("Error in VL_unw_creBoundWithOff\n");
           printf("malloc CmpLst : Failed\n");
           goto deldel;
   }
   CmpCv = (struct  IGRbsp_curve **)
                  om$malloc( size =  j * sizeof( struct IGRbsp_curve *) );
   if( CmpCv == NULL ){
           printf("Error in VL_unw_creBoundWithOff\n");
           printf("malloc CmpCv : Failed\n");
           goto deldel;
   }
   edgeCv = (struct  IGRbsp_curve **)
                  om$malloc( size =  j * sizeof( struct IGRbsp_curve *) );
   if( edgeCv == NULL ){
           printf("Error in VL_unw_creBoundWithOff\n");
           printf("malloc edgeCv : Failed\n");
           goto deldel;
   }
   for (k=0;k<j;k++) edgeCv[k] = CmpCv[k] = NULL;

  k = 0;
  for(i=0; i<(*NumObj); i++ ){
    if (i==0) {
      OmStat = VLreparameter_off_curve(&(*ObjRet)[i],(*LoopIndex)[i], 
                                       &((*EdgeList)[k]), &OfVal[k],info,
                                       CmpLst,CmpCv,edgeCv,cst,TRUE);
      if (bool0) {
           for (ii=0; ii<(*LoopIndex)[0];ii++)
     	   om$send( msg = message GRgraphics.GRdelete(suc,cst->env_info),
             	     targetid = LcCv[ii].obj_id.objid,
		     targetos = LcCv[ii].obj_id.osnum,
		     senderid = NULL_OBJID ) ;
   
      }
    }
    else {
      OmStat = VLreparameter_off_curve(&(*ObjRet)[i],(*LoopIndex)[i], 
                                       &((*EdgeList)[k]), &OfVal[k],NULL,
                                       CmpLst,CmpCv,edgeCv,cst,FALSE);
      }
    // if (!(OmStat&1)) goto deldel;
    k += (*LoopIndex)[i];
  }

  if (line != NULL) {
    if (ii0 >= 0) line[0] = (*EdgeList)[ii0].EdgeId;
    line[1] = (*EdgeList)[ii1].EdgeId;
    line[2] = (*EdgeList)[ii2].EdgeId;
  }
  }

#ifdef DEBUG
	printf("LES OFFSET LINES :\n");
	if (ii0 >=0) 
  		printf("0 et 1 et 2 = %d %d %d %d %d %d\n",
				line[0].objid,line[0].osnum,
				line[1].objid,line[1].osnum,
				line[2].objid,line[2].osnum);
	else
		printf("1 et 2 = %d %d %d %d\n",
				line[1].objid,line[1].osnum,
				line[2].objid,line[2].osnum);
	fflush(stdout);
#endif

 cst->geometry = NULL;

 if( OfVal )	   { om$dealloc( ptr = OfVal );        OfVal        = NULL; }
 if( CmpLst ) 	   { om$dealloc( ptr = CmpLst );       CmpLst       = NULL; }
 if( CmpCv ) 	   { om$dealloc( ptr = CmpCv );        CmpCv        = NULL; }
 if( edgeCv ) 	   { om$dealloc( ptr = edgeCv );       edgeCv       = NULL; }
 if( LcCv )        { om$dealloc( ptr = LcCv ); 	       LcCv         = NULL; }
 /*** Check added for  #179801539 ***/
 if(NumConCrvs>0)
    if( ConCrvs )     { om$dealloc( ptr = ConCrvs );      ConCrvs      = NULL; }

#ifdef DEBUG
	printf(" exit VL_unw_creBoundWithOff with SUCCESS\n");
#endif

	*suc = MSSUCC;
	return(MSSUCC);

deldel:

	/*c delete the composite curve which could have been already evaluated*/
	for( k=0; k<(*NumObj); k++ ){
	if( (*ObjRet)[k].obj_id.objid != NULL_OBJID )
     	OmStat = om$send( msg = message GRgraphics.GRdelete(suc,cst->env_info),
             	     targetid = (*ObjRet)[k].obj_id.objid,
		     targetos = (*ObjRet)[k].obj_id.osnum,
		     senderid = NULL_OBJID ) ;
	}

	/*c delete the edge components of the current loop which failed */
/****
	for( k=0; k<(*NumEdges); k++ ){
	if( LcCv[k].obj_id.objid != NULL_OBJID )
     	OmStat = om$send( msg = message GRgraphics.GRdelete(suc,cst->env_info),
             	     targetid = LcCv[k].obj_id.objid,
		     targetos = LcCv[k].obj_id.osnum,
		     senderid = NULL_OBJID ) ;
	}
 ****/

wrapup:

 if( OfVal )	   { om$dealloc( ptr = OfVal );        OfVal        = NULL; }
 if( CmpLst ) 	   { om$dealloc( ptr = CmpLst );       CmpLst       = NULL; }
 if( CmpCv ) 	   { om$dealloc( ptr = CmpCv );       CmpCv       = NULL; }
 if( edgeCv ) 	   { om$dealloc( ptr = edgeCv );       edgeCv       = NULL; }
 if( LcCv )        { om$dealloc( ptr = LcCv ); 	       LcCv         = NULL; }
 if( (*ObjRet) )   { om$dealloc( ptr = (*ObjRet) );    (*ObjRet)    = NULL; }
 if( (*LoopIndex) ){ om$dealloc( ptr = (*LoopIndex) ); (*LoopIndex) = NULL; }
 if( (*EdgeList) ) { om$dealloc( ptr = (*EdgeList) );  (*EdgeList)  = NULL; }
 /*** Check added for #179801539   ****/
 if(NumConCrvs>0)
    if( ConCrvs )     { om$dealloc( ptr = ConCrvs );      ConCrvs      = NULL; }


 *NumEdges = 0;
 *NumObj   = 0;

#ifdef DEBUG
	printf(" exit VL_unw_creBoundWithOff with FAILURE\n");
#endif

	*suc = MSFAIL;
	return(MSFAIL);
}

/*========================================================================*/
IGRlong  VL_unw_newCreFromMat (

struct	GRid		RNG,	  /*I the linestring defining the minimum
				      rectangle */
struct	GRmd_env	*mod_env, /*I mod env the linetring */
struct  unw_obj_plat	*dev,     /*I to know if:
				      - the surface is flat.
						( dev->devellopable = 1 )
				      - to evaluate the good z axis of the
					matrix according on which side we see
					the plate */
				  /*I tells if regarding to the thickness of
				      the plate the z axis is reversed or not */
	IGRdouble	*fromMat, /*O the from matrix */
	IGRlong		*ret	  /*O return code MSSUCC or MSFAIL */
)

{

struct	IGRbsp_curve 	*cv;
	IGRlong		stat;
	IGRdouble	vx[3], vy[3], vz[3];
	IGRdouble	epaisseur, min_dist1, min_dist2, Dist1, Dist2, bid[6];
	IGRint		i, j, k, tmp, pt_closest1=-1, pt_closest2=-1, pole_pos=-1;
	IGRdouble	points[3], point1[3], point2[3], xaxis[3];
	IGRint		loc_sts, num, length_flag;
	IGRboolean 	is_lbhd=FALSE, is_tbhd=FALSE, is_shell=TRUE,
			is_deck=FALSE, isThDirRev=FALSE;
	unsigned char   props;
	struct IGRplane plane;
	struct GRid	plt_surf;
	struct GRobj_env        par_plate;
	struct ret_struct       ret_struct;

  	xaxis[0] = -1.0; xaxis[1] = 0.0; xaxis[2] = 0.0;
	k = 1;

	/*c retrieve the poles of the rectangle */

  	plane.point  = (IGRdouble *)&bid[0];
  	plane.normal = (IGRdouble *)&bid[3];

  	bid[3] = bid[4] = bid[5] = 0. ;

  	stat = om$send( msg = message GRvg.GRdetplane(
                                        ret,
                                        &dev->surf_id._matrix_type,
                                        dev->surf_id._matrix,
                                        &plane ),
                      senderid = NULL_OBJID,
                      targetid = dev->surf_id._objid,
                      targetos = dev->surf_id._osnum );

      	if (BSdotp ( ret, &bid[3], xaxis ) < 0.0) {
	    isThDirRev = TRUE;
	}

	cv = NULL;

        vs$get_geometry( msg = ret, grobjId = &RNG,
                         grobjEnv = mod_env, geometry = &cv );

	/* evaluate the normal of the unfold surface at the param(0.5,0.5) */

  	BSsfevaln(dev->devsrf,0.5,0.5,1,&num,points,vz,&stat);
  	if (stat != BSSUCC) {
		printf("Error in VLnewCreFromMat\n");
		printf("BSsfevaln Failed\n");
		goto wrapup;
  	}
  	BSnorvec(&stat,vz);
	
        as$make_source(go_grid = dev->surf_id.obj_id,
                       mod_env = &dev->surf_id.mod_env,
                       as_grid = &plt_surf);

	/* retrieve the thickness */

	if( vs$is_ancestry_valid( object  = &plt_surf,
                                   classid = OPP_ACpretend_class_id )){

      	   stat   = om$send(  msg     = message ACpretend.ACfind_parent(
                                 	&par_plate.obj_id,
                                 	&par_plate.mod_env.md_env.matrix_type,
                                  	par_plate.mod_env.md_env.matrix ),
		 senderid = NULL_OBJID,
                 targetid = plt_surf.objid,
                 targetos = plt_surf.osnum ) ;
  	}

	tmp = 0 ;
	stat = om$send( msg	= message NDmacro.ACgive_structure(
					&loc_sts,
					&tmp,
					VS_K_plThcknsAttr,
					&ret_struct,
					&par_plate.mod_env ),
                       senderid = NULL_OBJID,
	       	       targetid = par_plate.obj_id.objid,
	       	       targetos = par_plate.obj_id.osnum ) ;

	epaisseur = fabs(ret_struct.var.root_pm_st.value) ;
		
	/*
	 * check the orientation of the surface. 
	 */

	stat = om$send( msg	= message EMSsubbs.EMget_props( 
								ret,
								&props ),
                       senderid = NULL_OBJID,
	       	       targetid = dev->surf_id.obj_id.objid,
	       	       targetos = dev->surf_id.obj_id.osnum ) ;

	if( props & EMSIS_NRML_REVERSED ) epaisseur = - epaisseur;

	if( epaisseur > 0.0 ) for(i=0;i<3;i++) vz[i] = -vz[i];

	stat = VLgetLowerEdge ( dev, isThDirRev, &point1[0], &point2[0], 
				&is_lbhd, &is_tbhd, &is_deck );

	if( is_lbhd || is_tbhd || is_deck )  is_shell = FALSE;

	if( is_lbhd || is_deck )	k = 1;
	else if( is_tbhd )		k = -1;

	if( !is_shell && isReverse )
  	{
	   k *= -1;
  	}

	if( is_tbhd && isThDirRev )
  	{
	   k *= -1;
  	}

	if( is_shell && ( dev->side_of_plate == OFFSET_FLIP ||
	    		  dev->side_of_plate == BASE_FLIP    )  )
	{
	   k *= -1;
	}

	#ifdef DEBUG	
	printf("\n Point1 = %lf, %lf, %lf", point1[0], point1[1], point1[2] );
	printf("\n Point2 = %lf, %lf, %lf", point2[0], point2[1], point2[2] );
	#endif

	min_dist1 = 100000.0;
	min_dist2 = 100000.0;

        for(i=0;i<4;i++)
	{
		Dist1 = BSdistptpt(&stat, &point1[0], &cv->poles[3*i] );
		if( Dist1 <= min_dist1 )
		{
		   min_dist1 = Dist1;
		   pt_closest1 = i;
		}

		Dist2 = BSdistptpt(&stat, &point2[0], &cv->poles[3*i] );
		if( Dist2 <= min_dist2 )
		{
		   min_dist2 = Dist2;
		   pt_closest2 = i;
		}
	#ifdef DEBUG
	  printf("\n Pole[%d] = %lf, %lf, %lf", i, cv->poles[3*i],
			cv->poles[3*i+1], cv->poles[3*i+2] );
	#endif
	}

	if( pt_closest1 == pt_closest2 )
	{
	   if( pt_closest1 == 3 )  pt_closest2 = 0;
	   else			   pt_closest2 = pt_closest2+1;
	}

	pole_pos = 2*pt_closest1 - pt_closest2;
	if( pole_pos>3 )       pole_pos -= 4;
	else if( pole_pos<0 )  pole_pos += 4;

	for(i=0;i<3;i++){
		vx[i] = cv->poles[3*pt_closest2+i] - cv->poles[3*pt_closest1+i];
//		vy[i] = cv->poles[3*pole_pos+i] - cv->poles[3*pt_closest1+i];
	}

	BSnorvec(ret,vx);
        BScrossp(ret,vz,vx,vy);   // Added RR - 4/27/98
	BSnorvec(ret,vy);

	Dist1 = BSdistptpt(&stat, &cv->poles[3*pt_closest2], 
				  &cv->poles[3*pt_closest1] );

	Dist2 = BSdistptpt(&stat, &cv->poles[3*pole_pos], 
				  &cv->poles[3*pt_closest1] );

	if( Dist1 < Dist2 )    	length_flag = 0;
	else			length_flag = 1;

        vd$ppl_setarg_at_index( which_info = GLOBAL_INFO,
                                index      = 2,
                                type       = VD_int,
                                value      = &length_flag     );

	#ifdef DEBUG
	printf("\n pt_closest1 = %d, pt_closest2 = %d, pole_pos = %d",
		pt_closest1, pt_closest2, pole_pos );

	printf("\n Unwrap Origin = %lf, %lf, %lf", cv->poles[3*pt_closest1],
			cv->poles[3*pt_closest1+1], cv->poles[3*pt_closest1+2] );
	#endif

	for ( i=0; i<3; i++) {
		j = 4 * i;
		fromMat[j]   = vx[i];

		if( dev->side_of_plate == OFFSET_FLIP ||
	    	    dev->side_of_plate == BASE_FLIP     ) fromMat[j+1] = -vy[i];
		else fromMat[j+1] = vy[i];

		fromMat[j+2] = vz[i];
		fromMat[j+3] = cv->poles[3*pt_closest1+i];
	}

	fromMat[12] = fromMat[13] = fromMat[14] = 0.0;
	fromMat[15] = 1.0;

	*ret = MSSUCC;
	return(MSSUCC);

wrapup:
	*ret = MSFAIL;
	return( MSFAIL);
}

/* Given a plate, this function find the numbers of vertical and horizontal
   marking lines */ 
IGRlong VLgetNumHorVerLns (plate, opt_line, cur_env, num_hor_ln, num_ver_ln)
struct GRobj_env	*plate;      /* I  plate */
IGRint			opt_line;    /* I  0 - Butt Lines
					   1 - Marking Line  */
struct GRmd_env		*cur_env;    /* I  Local Environment */
IGRint			*num_hor_ln; /* O  number of horizental marking lines */
IGRint			*num_ver_ln; /* O  number of vertical marking lines */
{
IGRlong			msg,sts,loc_msg;
struct GRobj_env	*trav = NULL;
IGRint			nb,i,dim=4,plan_ind;
IGRpoint		startpt,endpt;
BSrc			rc;
IGRdouble		vect[3];
struct GRobj_env        obj;
IGRchar		 	foot_name[30];

  msg = MSFAIL;
  *num_hor_ln = 0;
  *num_ver_ln = 0;

  VLunwGetPlatePlane( &msg, plate, &plan_ind );

  if( opt_line )  
  {
        VLbrowseFctInTree( plate, VL_Q_TOP_SOURCE, NULL,
                     	   VL_Q_DOWN_DIRECT, VLgetMacrosAtStep,
                     	   &nb, &trav );

	VLfilterClass(nb,trav,&nb,OPP_VLmrkLine_class_id);
#ifdef DEBUG
printf("\n No. of stiffeners before filtering plates: %d \n",nb);
#endif
	VLfilterStiff( nb,trav, &nb );
#ifdef DEBUG
printf("\n No. of stiffeners after filtering plates :%d \n",nb);
#endif
	strcpy( foot_name, VLFirstMrkName );
  }
  else
  { 
        IGRdouble               RangTol,ChtTol;
	struct GRobj_env        *buf = NULL;
        VLquLine                Query[IDX_SC_SIZE];

  	BSxtractpar ( &loc_msg, BSTOLCHRDHT, &ChtTol);
  	RangTol = 5 * ChtTol;

       	VLqLineStfTpl (Query);
  
       	/* We need just Butt Lines */
       	for ( i=0; i<IDX_SC_SIZE; i++)  Query[i].query = 0;
       	Query[IDX_SC_BUTT].query = 1;
   
       	/* Query for lines in the range of plate surface */
       	sts = VLqueryStfTpl ( plate, NULL, Query, RangTol,
                              cur_env, &nb, &trav, &i,
                              &buf, &loc_msg);
       	if (!(sts&loc_msg&1)) goto quit;

	strcpy( foot_name, MAN_GR_FEET );
	_FREE( buf );
  }

  for (i=0;i<nb;i++)
  {
    sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                       &loc_msg,
                                       foot_name,
                                       &(obj.obj_id),
                                       &(obj.mod_env.md_env.matrix_type),
                                       obj.mod_env.md_env.matrix),
                      targetid        = trav[i].obj_id.objid,
                      targetos        = trav[i].obj_id.osnum,
                      senderid        = NULL_OBJID );
    if (!(sts&loc_msg&1))
      goto quit;

    if (trav[i].mod_env.md_env.matrix_type != MAIDMX) {
      MAmulmx(&loc_msg,&dim,&dim,&dim,trav[i].mod_env.md_env.matrix,
              obj.mod_env.md_env.matrix,obj.mod_env.md_env.matrix);
      MAtypemx( &loc_msg, obj.mod_env.md_env.matrix,
                                     &(obj.mod_env.md_env.matrix_type));
    }

    sts = om$send ( msg =  message GRcurve.GRendpts (
					&loc_msg,
					&(obj.mod_env.md_env.matrix_type),
					obj.mod_env.md_env.matrix,
					startpt,endpt),
		      targetid        = obj.obj_id.objid,
                      targetos        = obj.obj_id.osnum,
                      senderid        = NULL_OBJID );
    if (!(sts&loc_msg&1))
      goto quit;
      vect[0] = endpt[0] - startpt[0];
      vect[1] = endpt[1] - startpt[1];
      vect[2] = endpt[2] - startpt[2];
      BSnorvec(&rc,vect);
      if (rc != BSSUCC) goto quit;

      //if (fabs(vect[0]) < ANGLE) {
      if( ( plan_ind == 0 && fabs(vect[1]) < ANGLE ) ||
	  ( plan_ind == 1 && fabs(vect[0]) < ANGLE ) ||
          ( plan_ind == 2 && fabs(vect[0]) < ANGLE ) ) {
        (*num_ver_ln)++;
      }
      else {
        (*num_hor_ln)++;
      }
  }
  msg = MSSUCC;
quit :
  if (trav) free(trav);
  return msg;
}

/*==========================================================================*/

IGRint VLcheck3DCrvThk( xyzCvAtt, crv ,thick)

/*d this function checks if two object are coinciendent */


struct  IGRbsp_curve    *xyzCvAtt;
struct  IGRbsp_curve    *crv;
double                  thick;

/*c Beginning of function */

{
IGRlong         suc;
IGRint          i, j, k, strtIndex, endIndex, size_buf;
IGRboolean      is_rev;
IGRdouble       tol, activCht, cht, mid_par, mdist_par, mdist,
                mid_pt[3], mdist_pt[3];

  is_rev = FALSE;

  /*c get the active cht */

  size_buf = sizeof(cht);
  gr$get_chord_height_tolerance (       msg     = &suc,
                                        sizbuf  = &size_buf,
                                        buffer  = &activCht,
                                        nret    = &size_buf     );
  tol  = thick + 2.* activCht;

        for(i=0;i<3;i++)
        if( fabs( (xyzCvAtt->poles[i]-crv->poles[i]) ) > tol ){
           for(i=0;i<3;i++)
                if( fabs( (xyzCvAtt->poles[3*(xyzCvAtt->num_poles-1)+i] -
                           crv->poles[i] ) ) > tol ){
                #ifdef DEBUG
                 printf("Cht = %g\n", tol );
                 printf("VLcheck3DCrv: start poles #\n");
                 __DBGpr_double("xyzCvAtt",&xyzCvAtt->poles[0],3,3);
                 __DBGpr_double("crv",&crv->poles[0],3,3);
                #endif
                return(FALSE);
           }
           is_rev = TRUE;
           break;
        }

        if( is_rev )    strtIndex = 0;
        else            strtIndex = 3 * (xyzCvAtt->num_poles-1);

        endIndex = strtIndex + 3;
        j = 3*(crv->num_poles-1);

        for(i=strtIndex;i<endIndex;i++,j++)
        if(fabs( (xyzCvAtt->poles[i]- crv->poles[j]) ) > tol){
                    #ifdef DEBUG
                    printf("VLcheck3DCrv: end poles #\n");
                    __DBGpr_double("xyzCvAtt",&xyzCvAtt->poles[strtIndex],3,3);
                    __DBGpr_double("crv",&crv->poles[strtIndex],3,3);
                    #endif
                    return(FALSE);
        }

        BScvmidpt( xyzCvAtt, &mid_par, mid_pt, &suc );

        BSmdstptcv( crv, mid_pt, &mdist_par, mdist_pt, &mdist, &suc );
        if( mdist < tol )       return TRUE;
        else                    return FALSE;
}

end implementation VLabstract;
