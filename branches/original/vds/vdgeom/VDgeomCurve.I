/* $Id: VDgeomCurve.I,v 1.3 2001/01/26 19:45:57 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgeomCurve.I
 *
 * Description:	Geometry Curve Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomCurve.I,v $
 *      Revision 1.3  2001/01/26 19:45:57  ramarao
 *      Fix for TR# MP4532 for merging process.
 *
 *      Revision 1.2  2001/01/11 18:41:18  art
 *      sp merge
 *
# Revision 1.8  2001/01/03  21:15:32  pinnacle
# ah TR MP4392
#
# Revision 1.7  2000/11/27  17:11:30  pinnacle
# ah
#
# Revision 1.6  2000/10/24  20:45:38  pinnacle
# Replaced: vds/vdgeom/VDgeomCurve.I for:  by jpulapar for Service Pack
#
# Revision 1.5  2000/05/28  16:54:30  pinnacle
# Replaced: vds/vdgeom/VDgeomCurve.I for:  by rchennup for Service Pack
#
# Revision 1.4  2000/05/23  13:16:10  pinnacle
# Replaced: vds/vdgeom/VDgeomCurve.I for:  by rchennup for Service Pack
#
# Revision 1.3  2000/04/28  19:32:24  pinnacle
# ah
#
# Revision 1.2  2000/04/25  16:15:56  pinnacle
# ah
#
# Revision 1.1  2000/04/11  17:14:28  pinnacle
# ah
#
# Revision 1.3  2000/03/31  17:00:56  pinnacle
# ah
#
# Revision 1.2  2000/03/27  21:29:22  pinnacle
# ah
#
# Revision 1.1  2000/03/24  17:16:32  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/22/00  ah      Creation, Broke up geom routines
 * 05/23/00  Jayadev supporting function VDfillCompCrvGaps for ext_bound macro
 * 10/24/00  Jayadev supportion function VDplane_crv_pro_v for pla_encomp
 * 01/03/01  ah      TR MP4392 Fix rounding function
 * 01/16/00  RR	     TR MP4532 Fix for Merging Process
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDgeom.h"
#include "VDobj.h"
#include "VDmem.h"
#include "v_miscmacros.h"
#include "gocmacros.h"
#include "bsarclnparc.h"

static int traceFlag;
extern  GRclassid OPP_nci_macro_class_id,OPP_GRbcsubbc_class_id;
extern  GRclassid OPP_GRcompcurve_class_id;
from  ci_macro          import  init;
from  NDmacro           import  ACreturn_foot;
from GRgraphics         import GRcopy,GRconstruct,GRdelete;
from GRowner		import GRget_number_components, GRget_components;
from GRcompcurve	import EMmakecomp;
//#define DEBUG 1

/* -----------------------------------------------------
 * Make a line from two points
 * If *crv points somewhere then it is assumes that it is big
 * enough for a line buffer
 */
IGRstat VDgeomMakeLineCurve(IGRpoint pt1, IGRpoint pt2, TGRbsp_curve **crv)
{
  IGRstat retFlag = 0;
  IGRint  type;
  BSrc    rc;
  
  // Arg check
  if (crv == NULL) goto wrapup;
  
  // Alloc or Partition Curve
  vdgeom$AllocCurve(order     = 2,
		    num_poles = 2,
		    rational  = 0,
		    crv       = crv,
		    buf       = (IGRchar*)*crv,
		    bufSize   = VDGEOM_SIZE_LINE);

  if (*crv == NULL) {
    printf("*** Problem allocating buffer when creating line geometry\n");
    goto wrapup;
  }
  
  // Do it
  type = 0;
  BSptlngen(&rc,pt1,pt2,*crv,&type);
  if (rc != BSSUCC) goto wrapup;
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Make an arc from three points
 * If *crv points somewhere then it is assumes that it is big
 * enough for an arc buffer
 */
IGRstat VDgeomMakeArcCurve(IGRpoint pt1, 
			   IGRpoint pt2, 
			   IGRpoint pt3, 
			   TGRbsp_curve **crv)
{
  IGRstat retFlag = 0;
  BSrc    rc;
  
  // Arg check
  if (crv == NULL) goto wrapup;
  
  // Alloc or Partition Curve
  vdgeom$AllocCurve(order     = 3,
		    num_poles = 7,
		    rational  = 1,
		    crv       = crv,
		    buf       = (IGRchar*)*crv,
		    bufSize   = VDGEOM_SIZE_ARC);

  if (*crv == NULL) {
    printf("*** Problem allocating buffer when creating arc geometry\n");
    goto wrapup;
  }
  
  // Do it
  BSarc3pts(&rc, pt1, pt2, pt3, *crv);
  if (rc != BSSUCC) goto wrapup;
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Merge two curves, really up to the calling routine to make
 * sure the curves should be merged
 */
IGRstat VDgeomMergeTwoCurves(TGRbsp_curve  *crv1,
			     TGRbsp_curve  *crv2,
			     TGRbsp_curve **crv3)
{
  IGRchar fn[]="VDgeomMergeTwoCurves";
  IGRstat retFlag = 0;
  
  IGRint    mergePoles = 0;
  IGRint    mergeOrder = 0;
  
  BSrc rc;

  IGRint traceFlagx;
  
  IGRint i,crv1i,crv2i;
  IGRpoint pt1,pt2,pt3;
  
  // Say hi
  traceFlagx = traceFlag;
  // traceFlagx = 1;
  if (traceFlagx) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  if (crv3 == NULL) goto wrapup;
  *crv3 = NULL;
  
  if (crv1 == NULL) goto wrapup;
  if (crv2 == NULL) goto wrapup;
  if (crv1->num_poles < 2) goto wrapup;
  if (crv2->num_poles < 2) goto wrapup;

  if (traceFlag) {
    vdgeom$Print(crv = crv1);
    vdgeom$Print(crv = crv2);
  }

  /* ---------------------------------------------
   * Know that the endpoints are withing production tolerance
   * Adjust them to be exactly the same to avoid base tolerance
   * issues when merging
   *
   * Copied from BuildCrv()
   */
  crv1i = 3 * (crv1->num_poles - 1);
  crv2i = 0;
  
  // Get the endpoints
  VDgeomGetCrvPt(crv1,1.0,pt1);
  VDgeomGetCrvPt(crv2,0.0,pt2);
  
  // Adjust
  for(i = 0; i < 3; i++) {
    pt3[i] = (pt1[i] + pt2[i]) * 0.5;
    crv1->poles[crv1i+i] = pt3[i];
    crv2->poles[crv2i+i] = pt3[i];    
  }

  // Watch out for weights
  if(crv1->rational ){
    for(i = 0; i < 3; i++) {
      crv1->poles[crv1i+i] *= crv1->weights[crv1i/3];
    }
  }
  if(crv2->rational ){
    for(i = 0; i < 3; i++) {
      crv2->poles[crv2i+i] *= crv2->weights[crv2i/3];
    }
  }

  // Allocate  
  if (crv1->order == crv2->order) {
    mergeOrder = crv1->order;
    mergePoles = crv1->num_poles + crv2->num_poles - 1;
  }
  
  if (crv1->order > crv2->order) {
    mergeOrder = crv1->order;
    mergePoles = crv1->num_poles + crv2->num_poles + 
               ((crv2->num_poles - crv2->order + 2) *
                (crv1->order     - crv2->order));
  }
  if (crv1->order < crv2->order) {
    mergeOrder = crv2->order;
    mergePoles = crv2->num_poles + crv1->num_poles + 
               ((crv1->num_poles - crv1->order + 2) *
                (crv2->order     - crv1->order));
  }

  vdgeom$AllocCrv(order     = mergeOrder,
		  num_poles = mergePoles,
		  rational  = 1,
		  crv       = crv3);

  if (*crv3 == NULL) {
    printf("*** Problem allocating merged curve\n");
  }  
  BSmerge_cv(&rc,crv1,crv2,*crv3);
  
  if (rc != BSSUCC) {
    printf("*** Problem with BSmerge_cv\n");
    _FREE(*crv3);
    *crv3 = NULL;
    goto wrapup;
  }
  if (*crv3 == NULL) {
    printf("*** Problem with BSmerge_cv, merge is NULL\n");
    goto wrapup;
  }

  /* 
   *  TR# MP4532 - Rama Rao
   *  Reparametrize this merged curve so that interior knots
   *  of multiplicity order-1 are arc length-distributed.
   */
  BSarclnparc( &rc, *crv3 );

  if (traceFlagx) {
    printf("Did the merge\n");
  }

  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlagx) {
    printf("<<< %s %d\n",fn,retFlag);
  }

  return retFlag;
}

/* -------------------------------------------------
 * Determines how much room a curve needs 
 */
IGRstat VDgeomGetCurveSize(IGRint order,
			   IGRint num_poles,
			   IGRint rational,
			   IGRint num_boundaries,
			   IGRint *crvSize)
{
  IGRstat retFlag = 1;
  IGRint  size;

  GRbc_size(order,num_poles,rational,num_boundaries,size);
  if (crvSize) *crvSize = size;
  
  return retFlag;
}

/* -------------------------------------------------
 * Allocates and partitions a curve
 * should be freed with _FREE() and NOT BSfreecv()
 *
 * If an optional buffer is passed then it will be used if
 * it is big enough
 */
IGRstat VDgeomAllocCurve(IGRint order,
			 IGRint num_poles,
			 IGRint rational,
			 IGRint num_boundaries,
			 IGRint flag,
			 TGRbsp_curve **crv,

			 IGRchar      *buf,
			 IGRint        bufSize,
			 IGRint       *crvSize)
{
  IGRstat retFlag = 0;
  IGRint  size;
  
  // Arg check
  if (crv == NULL) goto wrapup;
  *crv = NULL;
  
  // Get the size (this is a macro, hence no address for size)
  GRbc_size(order,num_poles,rational,num_boundaries,size);
#if 0
  printf("Order %d, poles %d, rational %d, boundaries %d, sixe %d\n",
	 order,num_poles,rational,num_boundaries,size);
#endif
  // If the buffer big enough?
  if ((buf) && (bufSize >= size)) {

    // Use the buffer
    *crv = (TGRbsp_curve *)buf;
    if (crvSize) *crvSize = bufSize;
    memset(buf,0,sizeof(TGRbsp_curve));
  }
  else {
    
    // Allocate it
    *crv = (TGRbsp_curve*)_CALLOC(size,char);
    if (*crv == NULL) {
      printf("*** Problem allocating memory for VDgeomAllocCrv\n");
      goto wrapup;
    }
    if (crvSize) *crvSize = size;
  }
  
  // Partition It
  GRbc_partition(*crv,order,num_poles,rational,num_boundaries);
  
  /* For now, leave the non-pointer fields as 0 (num_knots etc)
   * Just to be consistent with other software,
   * Really might make more sense to init these values
   */
  if (flag) {
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------------------------------
 * Transform curve given a matrix
 */
IGRstat VDgeomTransformCurve(TGRbsp_curve  *a_crv, 
                             TGRmdenv_info *a_mat, 
                             IGRvector      a_vec)
{
  IGRstat retFlag = 0;
  
  BSrc rc;
  
  TGRmdenv_info mat;
  
  // Arg check
  if (a_crv == NULL) goto wrapup;
  
  // Use passed matrix or idenity
  if (a_mat) mat = *a_mat;
  else {
    VDgeomSetMatToIdentity(&mat);
  }

  // Aply vector if passed
  if (a_vec) {
    mat.matrix[ 3] = a_vec[0];
    mat.matrix[ 7] = a_vec[1];
    mat.matrix[11] = a_vec[2];
    MAtypemx(&rc,mat.matrix,&mat.matrix_type);
  }
  
  // Transform
  if (a_crv->rational) {
    
    MArptsxform(&rc,
		&a_crv->num_poles,
		&a_crv->rational,
		 a_crv->weights,
		 mat.matrix,
		 a_crv->poles,
		 a_crv->poles);
  } 
  else {
    MAoptsxform(&rc,
		&a_crv->num_poles,
		&mat.matrix_type,
		 mat.matrix,
		 a_crv->poles,
		 a_crv->poles);
  }

  retFlag = 1;
  
wrapup:
  return retFlag;

}

/* -----------------------------------------------
 * Extracts curve between parameters
 */
IGRstat VDgeomExtractCurve(TGRbsp_curve  *crv1, 
			   IGRdouble      par1, 
			   IGRdouble      par2, 
			   TGRbsp_curve **crv2)
{
  IGRstat retFlag = 0;
  BSrc    rc;
  IGRdouble parM;
  
  // Arg check
  if (crv2 == NULL) goto wrapup;
  *crv2 = NULL;
  if (crv1 == NULL) goto wrapup;
  
  // Allocate
  vdgeom$AllocCrv(order     = 4,
		  num_poles = crv1->num_poles + (crv1->order * 2) - 1,
		  rational  = 1,
		  crv       = crv2);

  if (*crv2 == NULL) {
    printf("Problem allocating extract geometry\n");
    goto wrapup;
  }
  
  parM = (par1 + par2) * .5;
  BSpartofcv(&rc,crv1,par1,parM,par2,*crv2);

  if (rc != BSSUCC) {
    printf("Problem extracting part of curve\n");
  }
  
  retFlag = 1;
  
wrapup:  
  return retFlag;
}

/* -----------------------------------------------
 * Copies a curve, taking care of allocating stuff
 */
IGRstat VDgeomCopyCurve(TGRbsp_curve *crv1, TGRbsp_curve **crv2)
{
  IGRstat retFlag = 0;
  BSrc    rc;
    
  // Arg check
  if (crv2 == NULL) goto wrapup;
  *crv2 = NULL;
  if (crv1 == NULL) goto wrapup;

  //printf("Allocating curve, %d, %d\n",crv1->num_poles,crv1->order);
  
  // Allocate conservativily
  vdgeom$AllocCrv(order     = 4,
		  num_poles = crv1->num_poles + (crv1->order * 2) - 1,
		  rational  = 1,
		  crv       = crv2);

  if ((rc != BSSUCC) || (*crv2 == NULL)) {
    printf("Problem allocating curve copy geomotry\n");
    goto wrapup;
  }
 
  //printf("Curve Allocated\n");
  //return 1;
  
  BScv_copy(&rc,crv1,*crv2);

  //printf("Curve Copied\n");
  
  retFlag = 1;
  
wrapup:  
  return retFlag;
}

/* -------------------------------------------------
 * Allocates and partitions a curve
 * should be freed with _FREE() and NOT BSfreecv()
 */
IGRstat VDgeomAllocCrv(IGRint order,
		       IGRint num_poles,
		       IGRint rational,
		       IGRint num_boundaries,
		       IGRint flag,
		       TGRbsp_curve **crv)
{
  IGRstat retFlag = 0;
  IGRint  size;
  
  // Arg check
  if (crv == NULL) goto wrapup;
  *crv = NULL;
  
  // Get the size (this is a macro, hence no address for size)
  GRbc_size(order,num_poles,rational,num_boundaries,size);
  
  // Allocate it
  *crv = (TGRbsp_curve*)_CALLOC(size,char);
  if (*crv == NULL) {
    printf("*** Problem allocating memory for VDgeomAllocCrv\n");
    goto wrapup;
  }
  
  // Partition It
  GRbc_partition(*crv,order,num_poles,rational,num_boundaries);
  
  /* For now, leave the non-pointer fields as 0 (num_knots etc)
   * Just to be consistent with other software,
   * Really might make more sense to init these values
   */
  if (flag) {
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Force the curve to be physically closed by moving end points to
 * the mid point of a line drawn between them
 */
IGRstat VDgeomCloseCurve(TGRbsp_curve *crv)
{
  IGRchar fn[]="VDgeomCloseCurve";
  IGRstat retFlag = 0;
  
  BSrc rc;

  IGRint traceFlagx;
  
  IGRint   i,i1,i2;
  IGRpoint pt1,pt2,pt3;
  
  // Say hi
  traceFlagx = traceFlag;
  // traceFlagx = 1;
  if (traceFlagx) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  if (crv == NULL) goto wrapup;

  /* ---------------------------------------------
   * Know that the endpoints are withing production tolerance
   * Adjust them to be exactly the same to avoid base tolerance
   * issues when merging
   *
   * Copied from BuildCrv()
   */
  i1 = 0;
  i2 = 3 * (crv->num_poles - 1);
  
  // Get the endpoints
  VDgeomGetCrvPt(crv,0.0,pt1);
  VDgeomGetCrvPt(crv,1.0,pt2);
  
  // Adjust
  for(i = 0; i < 3; i++) {
    pt3[i] = (pt1[i] + pt2[i]) * 0.5;
    crv->poles[i1+i] = pt3[i];
    crv->poles[i2+i] = pt3[i];    
  }

  // Watch out for weights
  if(crv->rational){
    for(i = 0; i < 3; i++) {
      crv->poles[i1+i] *= crv->weights[i1/3];
      crv->poles[i2+i] *= crv->weights[i2/3];
    }
  }

  // Done
  crv->phy_closed = 1;
  retFlag = 1;
  
wrapup:

  if (traceFlagx) {
    printf("<<< %s %d\n",fn,retFlag);
  }

  return retFlag;
}

/* ----------------------------------------------------------------------
 * Force par 1.0 of crv1 to match par0 of curve 2 exactly
 * Adjust to mid point if necessary
 */
IGRstat VDgeomLinkCurves(TGRbsp_curve *crv1, TGRbsp_curve *crv2)
{
  IGRchar fn[]="VDgeomLinkCurves";
  IGRstat retFlag = 0;
  
  BSrc rc;

  IGRint traceFlagx;
  
  IGRint   i,i1,i2;
  IGRpoint pt1,pt2,pt3;
  
  // Say hi
  traceFlagx = traceFlag;
  // traceFlagx = 1;
  if (traceFlagx) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  if (crv1 == NULL) goto wrapup;
  if (crv2 == NULL) goto wrapup;

  /* ---------------------------------------------
   * Know that the endpoints are withing production tolerance
   * Adjust them to be exactly the same to avoid base tolerance
   * issues when merging
   *
   * Copied from BuildCrv()
   */
  i1 = 3 * (crv1->num_poles - 1);
  i2 = 0;
  
  // Get the endpoints
  VDgeomGetCrvPt(crv1,1.0,pt1);
  VDgeomGetCrvPt(crv2,0.0,pt2);
  
  // Adjust
  for(i = 0; i < 3; i++) {
    pt3[i] = (pt1[i] + pt2[i]) * 0.5;
    crv1->poles[i1+i] = pt3[i];
    crv2->poles[i2+i] = pt3[i];    
  }

  // Watch out for weights
  if(crv1->rational){
    for(i = 0; i < 3; i++) {
      crv1->poles[i1+i] *= crv1->weights[i1/3];
    }
  }
  if(crv2->rational){
    for(i = 0; i < 3; i++) {
      crv2->poles[i2+i] *= crv2->weights[i2/3];
    }
  }

  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlagx) {
    printf("<<< %s %d\n",fn,retFlag);
  }

  return retFlag;
}

/* -----------------------------------------------
 * Round a double
 * Note: Rounding to 4 messes up collar plate geometry
 * probably best to keep to base tolerance
 *
 * 03 Jan 2001 - TR MP4392
 * Note: Rounding to less than 10 can mess up some planar plates
 *       Use 12 just to be safe
 */
IGRstat VDgeomRoundDouble(IGRdouble *dbl)
{
  IGRchar buf[64];
  
  sprintf(buf,"%.12f",*dbl);
  *dbl = atof(buf);
  return 1;
}

/* -----------------------------------------------
 * Inspired by thet fact that curves that are debugged out
 * then debugged back in often work better than the original
 * curve, try rounding bsp stuff
 */
IGRstat VDgeomRoundCurve(TGRbsp_curve *crv)
{
  IGRstat retFlag = 0;
  IGRint i,j;
  
  // Arg check
  if (crv == NULL) goto wrapup;

  // Do Knots
  if (crv->knots == NULL) goto wrapup;
  for(i = 0; i < crv->num_knots; i++) {
    VDgeomRoundDouble(&crv->knots[i]);
  }
  
  // Do Poles
  if (crv->poles == NULL) goto wrapup;
  j = crv->num_poles * 3;
  for(i = 0; i < j; i++) {
    VDgeomRoundDouble(&crv->poles[i]);
  }

  // Weights
  if (crv->weights) {
    for(i = 0; i < crv->num_poles; i++) {
      VDgeomRoundDouble(&crv->weights[i]);
    }
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

// This is a wrapper function on top of crv_comp macro

IGRint VDfillCompCrvGaps(struct GRid *curves,struct GRmd_env *md_env,struct GRid *compCurve,int numCurves)
{
  IGRint retFlag =0;
  int    int_msg,ii;
  IGRint sts  =  OM_E_INVARG;
  IGRlong l_sts = MSFAIL,msg = MSFAIL,stat;
  struct GRid    *macTemp,mac,feetCurve;
  OM_S_OBJID    feetCopy;

  if((!curves)||(numCurves<=0)) goto wrapup;

  feetCurve.objid = NULL_OBJID; 
  macTemp = NULL;

  macTemp = _MALLOC(numCurves,struct GRid);
  for(ii=0;ii<numCurves;ii++){
	macTemp[ii].objid = curves[ii].objid;
	macTemp[ii].osnum = curves[ii].osnum;
  }

  mac.osnum = md_env->md_id.osnum ;
        l_sts = om$construct ( classid = OPP_nci_macro_class_id,
                               osnum   = mac.osnum,
                               p_objid = &mac.objid,
                               msg     = message ci_macro.init
                                             ( &int_msg,
                                               0,
                                               "crv_comp",
                                               numCurves,
                                               macTemp,
                                               NULL,
                                               md_env)) ;
         if( ! (l_sts&int_msg&1)){
          printf(" Macro placement fails : Can not initialize nci_macro\n");
                        sts = gr$delete_object ( msg       = &msg,
                                                 md_env    = md_env,
                                                 object_id = &mac );
                        goto wrapup;
                }
         sts = om$send(msg = message  NDmacro.ACreturn_foot(
                                                  &l_sts,
                                                  "rescrv",
                                                  &feetCurve,
                                                  &md_env->md_env.matrix_type,
                                                  md_env->md_env.matrix ),
                       senderid     = NULL_OBJID,
                       targetid     = mac.objid,
                       targetos     = mac.osnum);

        if ((!(sts&l_sts&1)) ||(feetCurve.objid == NULL_OBJID)) {
		printf("\nfailed to return composite curve from nci_macro \n");
       		goto wrapup;
        }
	// copy the macro feet
        sts = om$send( msg = message GRgraphics.GRcopy(
                                                &msg,
                                                md_env,
                                                md_env,
                                                &feetCopy ),
                        senderid= feetCurve.objid,
                        targetid= feetCurve.objid,
                        targetos= feetCurve.osnum ) ;
	// delete the nci_macro and the feet 
	sts = gr$delete_object ( msg       = &msg,
                         	 md_env    = md_env,
                         	 object_id = &mac );
	sts = gr$delete_object ( msg       = &msg,
                         	 md_env    = md_env,
                         	 object_id = &feetCurve );
              vd_$bulk_delete(count   = numCurves,
                              grids   = curves,
                              theEnv  = md_env ) ;
	compCurve->objid = feetCopy;
	compCurve->osnum = feetCurve.osnum; 
  //Done
  retFlag = 1;

wrapup:
  _FREE(macTemp); macTemp = NULL;
  return retFlag;
}
/* This function projects the given curve(bspline/compcurve/linestring/...) object
 * onto the plane(defined by point,normal) along vector and 
 * returns the projected object;
 */

IGRint VDplane_crv_pro_v(struct GRid curveObj,
			struct GRmd_env obj_env,
			struct IGRbsp_curve *curveGeom,
			IGRpoint pt,
			IGRvector normal,
			IGRvector vec,
			struct GRvg_construct *cst,
			struct GRobj_env *projCurve)
{
  IGRint retFlag = 0,stat,i;
  IGRlong msg,sts,suc,rotten_one;
  GRclassid clsID;
  IGRint NumComp = 0,numRet = 0,kk;
  struct GRid *ListIds = NULL,*edge_list = NULL;
  struct GRlc_info *pjList = NULL;
  BSrc    rc;
  struct IGRbsp_curve *cmpGeom = NULL;

  if(curveGeom == NULL) goto wrapup;
  
  om$get_classid(       osnum           = curveObj.osnum ,
                        objid           = curveObj.objid ,
                        p_classid       = &clsID      ) ;
  // check if the object is a composite curve
  // if so, we need to project each of the components and rebuild 
  // the compcurve from the projected entities
  if((om$is_ancestry_valid( superclassid  = OPP_GRcompcurve_class_id,
                            subclassid    = clsID ) == OM_S_SUCCESS ))
    {
      sts = om$send( msg = message GRowner.GRget_number_components(
								   &msg,
								   &NumComp ),
		     
		     senderid = NULL_OBJID,
		     targetid = curveObj.objid,
		     targetos = curveObj.osnum );
      if((!(sts&msg&1)) || (NumComp == 0))
	{
#ifdef DEBUG
	  printf("\n GRowner.GRget_number_components failed for[%d,%d] \n",curveObj.objid,curveObj.osnum );
#endif
	  goto wrapup;
	}
      
      ListIds = (struct GRid *)
	om$malloc( size =  NumComp * sizeof( struct GRid ) );
      if (ListIds == NULL) goto wrapup;
      pjList = (struct GRlc_info *)
	om$malloc( size =  NumComp * sizeof( struct GRlc_info ) );
      if (pjList == NULL) goto wrapup;
      edge_list = (struct GRid *)
	om$malloc( size =  NumComp * sizeof( struct GRid ) );
      if (edge_list == NULL) goto wrapup;
      sts = om$send( msg = message GRowner.GRget_components(
							    &msg,
							    &obj_env,
							    ListIds,
							    NumComp,
							    &numRet,
							    (IGRint) 0,
							    OM_K_MAXINT ),
		     
		     senderid = NULL_OBJID,
		     targetid = curveObj.objid,
		     targetos = curveObj.osnum );
      if((!(sts&msg&1)) || (NumComp == 0))
	{
#ifdef DEBUG
printf("\n GRowner.GRget_number_components failed for[%d,%d] \n",curveObj.objid,curveObj.osnum );
#endif
 goto wrapup;
	}
      //project each component onto the average plane to build the planar compcurve
      for(kk=0; kk<NumComp; kk++)
	{
	  _FREE(cmpGeom);
	  VD_get_geometry(&msg,&ListIds[kk],&obj_env,(IGRchar **)&cmpGeom);
	  if((!(msg&1)) || (cmpGeom == NULL))
	    {
#ifdef DEBUG
	      printf("\n VD_get_geometry failed [%d,%d]\n",ListIds[kk].objid,ListIds[kk].osnum); 
#endif
	      goto wrapup;
	    }
	  pjList[kk].located_obj.objid = NULL_OBJID;
	  pjList[kk].module_info = *cst->env_info;
	  
	  stat = VDproject_cv_on_plane(cmpGeom,pt,normal,vec,cst,&pjList[kk].located_obj);
	  if ((!(stat&1)) || (pjList[kk].located_obj.objid == NULL_OBJID))
	    {
#ifdef DEBUG
	      printf("\n VDproject_cv_on_plane function failed \n");
#endif
	      goto wrapup;
	    }  
	}
      for(kk=0; kk<NumComp; kk++)
	{
	  edge_list[kk].objid = pjList[kk].located_obj.objid;
	  edge_list[kk].osnum = pjList[kk].located_obj.osnum;
	}
      
      //make a compcurve out of the list of projected curves

/*    The following code has been commented 
 *
      cst->geometry = NULL;
      projCurve->obj_id.objid = NULL_OBJID;
      projCurve->obj_id.osnum = cst->env_info->md_id.osnum;
      projCurve->mod_env      = *cst->env_info;
      sts = om$construct ( msg       = message GRgraphics.GRconstruct( cst ),
			   classid = OPP_GRcompcurve_class_id,
			   p_objid = &projCurve->obj_id.objid,
			   osnum   = projCurve->obj_id.osnum );
      
      if ( !(sts&1)) {
#ifdef DEBUG
	printf(" GRgraphics.GRconstruct for comp : Failed\n");
#endif
	goto deldel;
      }
      
      sts = om$send( msg      = message GRcompcurve.EMmakecomp(
								&suc,
								cst->env_info,
								NumComp,
								pjList,
								&rotten_one  ),
		      targetid = projCurve->obj_id.objid,
		      targetos = projCurve->obj_id.osnum,
		      senderid = NULL_OBJID );
      
      if (! (sts & suc & 1)) {
#ifdef DEBUG
	printf( "GRcompcurve.EMmakecomp : Failed\n");
#endif
      deldel:
	for(i=0 ; i<NumComp; i++)
	  {
	    stat = om$send(msg      = message GRgraphics.GRdelete(
								  &suc, cst->env_info ),
			   targetid = pjList[i].located_obj.objid,
			   targetos = pjList[i].located_obj.osnum,
			   senderid = NULL_OBJID ) ;
	  }
	
	goto wrapup;
      }
*    The above code has been commented
*/ 
	// this function places the crv_comp macro and gets the feet
        stat = VDfillCompCrvGaps(edge_list,cst->env_info,&projCurve->obj_id,NumComp);
        if(!(stat&1)){
                printf("\n failed inside VDfillCompCrvGaps \n");
                VD_bulkDeleteByGRids(cst->env_info,NumComp,edge_list ) ;
                goto wrapup;
        }

#ifdef DEBUG
      printf("\n compcurve[%d,%d] successfully built\n",projCurve->obj_id.objid,projCurve->obj_id.osnum);
      
#endif
    }
  else
    {
      /* project the input curve onto average plane along vector and returns 
       * projected curve object
       */
      stat = VDproject_cv_on_plane(curveGeom,pt,normal,vec,cst,&projCurve->obj_id);
      if ((!(stat&1)) || (projCurve->obj_id.objid == NULL_OBJID))
	{
#ifdef DEBUG
	  printf("\n VDproject_cv_on_plane function failed \n");
#endif
	  goto wrapup;
	}
    }

  projCurve->mod_env = *cst->env_info;
  retFlag = 1;
 wrapup:
  _FREE(ListIds);
  _FREE(edge_list);
  _FREE(pjList);
  _FREE(cmpGeom);
#ifdef DEBUG
  printf("\n VDprojectedCurve retFlag %d \n",retFlag);
#endif
  return retFlag;
}
/* This function projects the given bspline curve geometry onto a plane 
 * along vector and returns the projected bspline object
 */
IGRint VDproject_cv_on_plane(struct IGRbsp_curve *cvGeom,
			     IGRpoint		 point,
			     IGRvector           normal,
			     IGRvector           vec,
			     struct GRvg_construct *cst,
			     struct GRid        *pjCurve)
{
  IGRint retFlag = 0;
  struct IGRbsp_curve *pjGeom = NULL;
  IGRlong msg,sts;
  BSrc    rc;

  pjCurve->objid = NULL_OBJID;

  BSalloccv( (IGRshort) cvGeom->order,
	     (IGRlong ) cvGeom->num_poles,
	     (IGRshort) cvGeom->rational,
	     (IGRshort) cvGeom->num_boundaries,
	     &pjGeom,
	     &rc );
  if (rc != BSSUCC)
    {
#ifdef DEBUG
      printf("\n BSalloccv function failed \n");
#endif
      goto wrapup;
    }
  
  BSprj_cv_pl( &rc, cvGeom, point, normal, vec, pjGeom);
  if(( rc != BSSUCC )|| (pjCurve == NULL)) {
#ifdef DEBUG
    printf("Error in BSprj_cv_pl for proj_crv1\n");
#endif
    goto wrapup;
  } 
  
  // Now construct the bspcurve object in the macroOS and post the geometry
  
  pjCurve->osnum = cst->env_info->md_id.osnum;;
  cst->geometry          = (char *)pjGeom;  
  
  sts = om$construct(     classid = OPP_GRbcsubbc_class_id ,
			  osnum   = pjCurve->osnum  ,
			  p_objid = &(pjCurve->objid) ,
			  );
  if(!(sts&1))
    {
#ifdef DEBUG
      printf("\n construct of OPP_GRbcsubbc_class_id failed \n");
#endif
      goto wrapup;
    }
#ifdef DEBUG
  printf("\n bspline curve[%d,%d] constructed\n",pjCurve->objid,pjCurve->osnum);
#endif
  sts = om$send( msg  =     message GRgraphics.GRconstruct( cst ),
		 senderid = NULL_OBJID,
		 targetid = pjCurve->objid,
		 targetos = pjCurve->osnum  );
  if(!(sts&*(cst->msg)&1))
    {
#ifdef DEBUG
      printf("\n construct of OPP_GRbcsubbc_class_id failed \n");
#endif
      goto wrapup;
    }
  
  
  retFlag = 1;
 wrapup:
  if( pjGeom != NULL ) BSfreecv(&rc,pjGeom); pjGeom = NULL;
#ifdef DEBUG
  printf("\n VDproject_cv_on_plane  retFlag %d \n",retFlag);
#endif
  return retFlag;
}
end implementation Root;

