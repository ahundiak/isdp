/* $Id: VDatCompare.c,v 1.9 2002/05/02 15:59:28 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatCompare.c
 *
 * Description: One last try for some reusable compare routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatCompare.c,v $
 *      Revision 1.9  2002/05/02 15:59:28  ahundiak
 *      ah
 *
 *      Revision 1.8  2002/05/01 19:56:15  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/10/19 18:22:33  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/04/13 19:49:25  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/03/22 18:45:51  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/03/22 14:41:47  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/19 16:03:29  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/18 23:46:08  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/18 22:50:17  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/16 17:10:45  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDctx.h"
#include "VDss.h"
#include "VDat.h"
#include "VDat2Pcmk.h"

VDASSERT_FFN("vdat/pcmk2/VDatCompare.c");

/* -----------------------------------------------
 * Know that going from 1 to 3 makes a difference
 * Try 2 for now
 */
#define VDAT2_GEOMETRY_TOL     2.00

/* -----------------------------------------------
 * Know that .001 rejects some collar plates which
 * pass a 3.0 mm geometry check
 */
#define VDAT2_AREA_PERCENT_TOL 0.01

/* -----------------------------------------------
 * Give the calling routine a bit of control
 */

static int s_verbose;
static int s_place_macro;
static int s_order_exact;

void VDat2SetCompareFlags(IGRint a_verbose, 
			  IGRint a_place_macro,
			  IGRint a_order_exact) 
{ 
  s_verbose     = a_verbose;
  s_place_macro = a_place_macro;
  s_order_exact = a_order_exact;
}

/* -----------------------------------------------
 * Master error routine
 * If verbose is set it tries to show what caused the like
 * compare to fail
 */
void VDat2CompareNodesError(TGRid *node1ID, TGRid *node2ID, IGRchar *msg)
{
  VDASSERT_FN("VDat2CompareNodesError");
  
  TVDfld flds1[128];
  TVDfld flds2[128];

  TVDfld *fld1;
  TVDfld *fld2;
  
  IGRint cnt1,cnt2;
  
  IGRint i1,i2;
  IGRint flag;
  
  IGRchab buf;
  
  TGRobj_env parentOEs[2];
  TGRobj_env macOE;

  // Arg check
  VDASSERTW(node1ID && node1ID->objid != NULL_OBJID);
  VDASSERTW(node2ID && node2ID->objid != NULL_OBJID);
  
  // Dont care unless verbose it set
  if (s_verbose == 0) goto wrapup;

  // Get real dangerous and place a macro
  if (s_place_macro) {
    
    VDctxGetModelObject(node1ID,&parentOEs[0]);
    VDctxGetModelObject(node2ID,&parentOEs[1]);
  
    VDefpPlaceMacro(NULL,"crv_tran2",0,2,parentOEs,&macOE);
  }
  
  // Try to present why it failed
  VDlogPrintFmt(VDLOG_ERROR,1,"*** ----------------------------------------");
  if (msg) VDlogPrintFmt(VDLOG_ERROR,1,"*** compareLikeNodesError %s",msg);
  else     VDlogPrintFmt(VDLOG_ERROR,1,"*** compareLikeNodesError");

  VDctxGetFldAtrs(node1ID,&cnt1,flds1);
  VDctxGetFldAtrs(node2ID,&cnt2,flds2);

  // Just to be safe
  if ((cnt1 < 4) || (cnt2 < 4)) 
  {
    VDlogPrintFmt (VDLOG_ERROR,1,"*** Big attribute problem ***");
    VDctxPrintLog(node1ID,VDLOG_ERROR,1);
    VDctxPrintLog(node2ID,VDLOG_ERROR,1);
    goto wrapup;
  }
  
  VDlogPrintFmt(VDLOG_ERROR,1,"1   %s",flds1[1].val.txt);
  VDlogPrintFmt(VDLOG_ERROR,1,"2   %s",flds2[1].val.txt);
  VDlogPrintFmt(VDLOG_ERROR,1,"1   %s",flds1[2].val.txt);
  VDlogPrintFmt(VDLOG_ERROR,1,"2   %s",flds2[2].val.txt);
  VDlogPrintFmt(VDLOG_ERROR,1,"1   %s",flds1[3].val.txt);
  VDlogPrintFmt(VDLOG_ERROR,1,"2   %s",flds2[3].val.txt);

  // Cycle through
  for(i1 = 4; i1 < cnt1; i1++) {
    fld1 = &flds1[i1];
    flag = 1;
    for(i2 = 0; (i2 < cnt2) && (flag); i2++) {
      fld2 = &flds2[i2];
      if (!strcmp(fld1->name,fld2->name)) {
	flag = 0;
	if (!strcmp(fld1->val.txt,fld2->val.txt)) {
	  VDlogPrintFmt(VDLOG_ERROR,1,"    %-16s %-20s",fld1->name,fld1->val.txt);
	}
	else {
	  VDlogPrintFmt(VDLOG_ERROR,1,"#A  %-16s %-20s %-20s",
			fld1->name,
			fld1->val.txt,
			fld2->val.txt);
	}
      }
    }
    if (flag) VDlogPrintFmt(VDLOG_ERROR,1,"#B  %-16s %-20s",fld1->name,fld1->val.txt);    
  }

  // List those in node2 but not in node1
  for(i2 = 4; i2 < cnt2; i2++) {
    fld2 = &flds2[i2];
    flag = 1;
    for(i1 = 0; (i1 < cnt1) && (flag); i1++) {
      fld1 = &flds1[i1];
      if (!strcmp(fld1->name,fld2->name)) flag = 0;
    }
    if (flag) VDlogPrintFmt(VDLOG_ERROR,1,"#C   %-16s %-20s",fld2->name,fld2->val.txt);    
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * This compares two piece areas 
 * Areas withing 1% of each other are considered equal
 * Going to .1% does knock out some collar that can pass the
 * geometry check
 *
 * Wonder if the tolerance in the geometry needs to be reduces???
 */
IGRint VDat2ComparePieceArea(const void *v1, const void *v2)
{
  VDASSERT_FN("VDat2ComparePieceArea");
  
  IGRint cmp = 0;

  IGRchar *area1x = (IGRchar*)v1;
  IGRchar *area2x = (IGRchar*)v2;
  
  IGRdouble area1,area2;
  IGRdouble diff1,diff2;
  IGRdouble delta;
  
  // Arg check
  VDASSERTW(area1x);
  VDASSERTW(area2x);
  
  // get the data
  area1 = atof(area1x);
  area2 = atof(area2x);
  delta = fabs(area1 - area2);
  diff1 = delta / area1;
  diff2 = delta / area2;

  // Compare
  if ((diff1 < VDAT2_AREA_PERCENT_TOL) && 
      (diff2 < VDAT2_AREA_PERCENT_TOL)) goto wrapup;
#if 0
  printf("Piece Area %12.2f %12.2f %10.4f %10.4f %10.4f\n",
	 area1,area2,delta,diff1,diff2);
#endif  
  if (area1 < area2) cmp = -1;
  else               cmp =  1;

 wrapup:
  return cmp;
}

/* -----------------------------------------------
 * Compare common piece attributes
 */
IGRint VDat2ComparePieceAttributes(const void *v1, const void *v2) 
{
  TGRid *node1ID = (TGRid *)v1;
  TGRid *node2ID = (TGRid *)v2;

  IGRchab buf1;
  IGRchab buf2;
  
  IGRint cmp;
  
  // The type
  VDctxGetNodeTypeSuffix(node1ID,buf1);
  VDctxGetNodeTypeSuffix(node2ID,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,"Different piece types");
    goto wrapup;
  }
  
  // Family
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_FAMILY,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_FAMILY,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,"Different families");
    goto wrapup;
  }

  // part_num
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_PART_NUM,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_PART_NUM,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,"Different part_nums");
    goto wrapup;
  }

  // material
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_MATERIAL,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_MATERIAL,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,"Different materials");
    goto wrapup;
  }

  // grade
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_GRADE,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_GRADE,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,"Different grades");
    goto wrapup;
  }

  // They match
  cmp = 0;
  
 wrapup:
  return cmp;
}


/* -----------------------------------------------
 * Compare common plate attributes
 */
IGRint VDat2ComparePlateAttributes(const void *v1, const void *v2) 
{
  TGRid *node1ID = (TGRid *)v1;
  TGRid *node2ID = (TGRid *)v2;

  IGRchab buf1;
  IGRchab buf2;
  
  IGRint cmp;

  IGRdouble area1,area2;
  
  // Not going to worry about thickness until ppp issues are resolved

  // Area
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PLATE_AREA,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PLATE_AREA,buf2);

  /* ---------------------------------------------
   * When setting up for an initial piece mark generation
   * want to order by area exactly */
  if (s_order_exact) {
    area1 = atof(buf1);
    area2 = atof(buf2);
    cmp = 0;
    if (area1 < area2) cmp = -1;
    if (area1 > area2) cmp =  1;
    if (cmp) goto wrapup;
  }
  
  // Otherwise, use a tolerance
  cmp = VDat2ComparePieceArea(buf1,buf2);
  if (cmp) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,"Different plate area");
    goto wrapup;
  }

  // Planar
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PLATE_IS_PLANAR,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PLATE_IS_PLANAR,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,"Different planar values");
    goto wrapup;
  }

  // Not going to worry about checking for non-planar at this point

  // They match
  cmp = 0;
  
 wrapup:
  return cmp;
}
/* -----------------------------------------------
 * Compare common beam attributes
 */
IGRint VDat2CompareBeamAttributes(const void *v1, const void *v2) 
{
  TGRid *node1ID = (TGRid *)v1;
  TGRid *node2ID = (TGRid *)v2;

  IGRchab buf1;
  IGRchab buf2;
  
  IGRint cmp;

  IGRdouble area1,area2;
  
  // End treatments
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_BEAM_TREATMENTS,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_BEAM_TREATMENTS,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) {
    
    /* Not really sure if we need to bounce 1 end against the other
     * because of ordering issues?
     * implement later if need to
     */
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,"Different end treatments");
    goto wrapup;
  }

  // Area
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_BEAM_AREA,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_BEAM_AREA,buf2);

  /* ---------------------------------------------
   * When setting up for an initial piece mark generation
   * want to order by area exactly */
  if (s_order_exact) {
    area1 = atof(buf1);
    area2 = atof(buf2);
    cmp = 0;
    if (area1 < area2) cmp = -1;
    if (area1 > area2) cmp =  1;
    if (cmp) goto wrapup;
  }
  
  // Otherwise, use a tolerance
  cmp = VDat2ComparePieceArea(buf1,buf2);
  if (cmp) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,"Different beam left web area");
    goto wrapup;
  }

  /* ---------------------------------------------
   * Lots of problems getting cut lengths
   * But if web area and end treatments are identical then
   * it's pretty safe bet the the length will be the same as well
   */
#if 0    
  // Cut Length
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_BEAM_CUT_LENGTH,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_BEAM_CUT_LENGTH,buf2);
  dbl1 = atof(buf1);
  dbl2 = atof(buf2);
  del = fabs(dbl1 - dbl2);
  if (del > 3.0) {
    validateNodesError(node1ID,node2ID,errCnt,"Different beam cut lengths");
    goto wrapup;
  }
#endif

  // Stocks
#if 1
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_BEAM_STOCKS,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_BEAM_STOCKS,buf2);

  /* ---------------------------------------------------------------------
   * For backwards compatibility, if either beam has no stock values then
   * consider them to be equal.  This occurs when comparing a beam against an
   * earlier snapshot in which the stock attribute had not been generated
   */
  if (*buf1 && *buf2) {
    cmp = strcmp(buf1,buf2);
    if (cmp) {
      if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,"Different beam stocks");
      goto wrapup;
    }
  }
#endif

  // They match
  cmp = 0;
  
 wrapup:
  return cmp;
}

/* -----------------------------------------------
 * Compare some of the geometry attributes such as total length
 * This is a late add to the pload
 * it is only called from the Verify routine when trying to determine
 * which pieces have changed
 *
 * I think the CompareGeometry can safely call this but 
 * don't want to take the time to find out
 *
 */
IGRint VDat2CompareGeomAttributes(const void *v1, const void *v2) 
{
  VDASSERT_FN("VDat2CompareGeomAttributes");

  TGRid *node1ID = (TGRid*)v1;
  TGRid *node2ID = (TGRid*)v2;
  
  IGRdouble delta;
  IGRdouble dbl1,dbl2;
  IGRdouble tol = VDAT2_GEOMETRY_TOL;

  IGRint cnt1,cnt2;
  
  IGRint cmp = 0;
  
  // Arg check
  VDASSERTW(node1ID && node1ID->objid != NULL_OBJID);
  VDASSERTW(node2ID && node2ID->objid != NULL_OBJID);
  
  // Edge length
  VDctxGetDblAtr(node1ID,VDCTX_ATR_SS_SRF_EDGE_LEN,&dbl1);
  VDctxGetDblAtr(node2ID,VDCTX_ATR_SS_SRF_EDGE_LEN,&dbl2);
  delta = fabs(dbl1 - dbl2);  
  if (delta > tol) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,VDCTX_ATR_SS_SRF_EDGE_LEN);
    if (dbl1 < dbl2) cmp = -1;
    else             cmp =  1;    
    goto wrapup;
  }

  // Min dist cen to edge
  VDctxGetDblAtr(node1ID,VDCTX_ATR_SS_SRF_CENTER_MIN,&dbl1);
  VDctxGetDblAtr(node2ID,VDCTX_ATR_SS_SRF_CENTER_MIN,&dbl2);
  delta = fabs(dbl1 - dbl2);  
  if (delta > tol) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,VDCTX_ATR_SS_SRF_CENTER_MIN);
    if (dbl1 < dbl2) cmp = -1;
    else             cmp =  1;    
    goto wrapup;
  }

  // Number of cutouts need to match
#if 0
  VDctxGetIntAtr(node1ID,VDCTX_ATR_SS_SRF_CUTOUT_CNT,&cnt1);
  VDctxGetIntAtr(node2ID,VDCTX_ATR_SS_SRF_CUTOUT_CNT,&cnt2);
  if (cnt1 != cnt2) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,VDCTX_ATR_SS_SRF_CUTOUT_CNT);
    if (cnt1 < cnt2) cmp = -1;
    else             cmp =  1;    
    goto wrapup;
  }
#endif

  // Total cutout distance
  VDctxGetDblAtr(node1ID,VDCTX_ATR_SS_SRF_CUTOUT_DIS,&dbl1);
  VDctxGetDblAtr(node2ID,VDCTX_ATR_SS_SRF_CUTOUT_DIS,&dbl2);
  delta = fabs(dbl1 - dbl2);  
  if (delta > tol) {
    if (s_verbose) VDat2CompareNodesError(node1ID,node2ID,VDCTX_ATR_SS_SRF_CUTOUT_DIS);
    if (dbl1 < dbl2) cmp = -1;
    else             cmp =  1;    
    goto wrapup;
  }
   
  // Done
  cmp = 0;
  
 wrapup:
  return cmp;
}

/* -----------------------------------------------
 * Compare actual geometry
 * of two parts which have passed all the attribute checks
 * Kind of hard to actually sort geomrtry but do a bit anyways
 * 
 * 0 Means matched
 */
IGRint VDat2CompareGeometry(const void *v1, const void *v2) 
{
  VDASSERT_FN("VDat2CompareGeometry");

  TVDat2PcmkInfo *pcmkInfo1 = (TVDat2PcmkInfo*)v1;
  TVDat2PcmkInfo *pcmkInfo2 = (TVDat2PcmkInfo*)v2;
  
  IGRstat sts;
  
  IGRdouble del;
  IGRdouble tol = VDAT2_GEOMETRY_TOL;

  IGRchab buf1, buf2;
  IGRchab pcmk1,pcmk2;

  TGRid *node1ID;
  TGRid *node2ID;
  
  TVDefpSrfTranInfo *srfInfo1;
  TVDefpSrfTranInfo *srfInfo2;

  IGRint cmp = 0;
  
  // Arg check
  VDASSERTW(pcmkInfo1);
  VDASSERTW(pcmkInfo2);

  // Pull some data
  node1ID  = &pcmkInfo1->nodeID;
  node2ID  = &pcmkInfo2->nodeID;
  srfInfo1 = &pcmkInfo1->srfTranInfo;
  srfInfo2 = &pcmkInfo2->srfTranInfo;

  /* ---------------------------------------------
   * In the normal course of events these will
   * already be filled in, might want to fill
   * them here but then the risk of an infinite loop
   * occurs, need a flag to see if already attempted
   * to fill and it failed
   */
  VDASSERTW(srfInfo1->edgeBsp);
  VDASSERTW(srfInfo2->edgeBsp);
  
  // Print each time piece is processed for crashes
  traceFlag = 0;

  // Take a chance and use the new routine
  cmp = VDat2CompareGeomAttributes(node1ID,node2ID);
  if (cmp) goto wrapup;
  
#if 0
  // Edge length
  del = fabs(srfInfo1->edgeLen - srfInfo2->edgeLen);
  if (del > tol) {
    VDat2CompareNodesError(node1ID,node2ID,"Edge Length");
    if (srfInfo1->edgeLen < srfInfo2->edgeLen) cmp = -1;
    else                                       cmp =  1;    
    goto wrapup;
  }

  // Center to minor
  del = fabs(srfInfo1->center_minor_distance - srfInfo2->center_minor_distance);
  if (del > tol) {
    VDat2CompareNodesError(node1ID,node2ID,"Center to minor distance");
    if (srfInfo1->center_minor_distance < srfInfo2->center_minor_distance) cmp = -1;
    else                                                                   cmp =  1;    
    goto wrapup;
  }

  // Total cutout distance
  del = fabs(srfInfo1->cutout_distance - srfInfo2->cutout_distance);
  if (del > tol) {
    VDat2CompareNodesError(node1ID,node2ID,"Total cutout distance");
    if (srfInfo1->cutout_distance < srfInfo2->cutout_distance) cmp = -1;
    else                                                       cmp =  1;    
    goto wrapup;
  }
#endif

  // The geometry
  if (traceFlag) {
    VDctxGetPieceMark(node1ID,pcmk1);
    VDctxGetPieceMark(node2ID,pcmk2);
    VDctxGetCompPath(node1ID,buf1);
    VDctxGetCompPath(node2ID,buf2);
    printf("-------------- VDefpCompareSrfTranInfo -------------\n");
    printf("%4s %s\n",pcmk1,buf1);
    printf("%4s %s\n",pcmk2,buf2);
  }
  sts = VDefpCompareSrfTranInfo(tol,srfInfo1,srfInfo2,NULL);
  if (traceFlag) {
    printf("<<< %d\n",sts);
  }
  
  if (!(sts == 1)) {
    VDat2CompareNodesError(node1ID,node2ID,"Actual Geometry");

    // This is where ordering does not work
    VDctxGetCompPath(node1ID,buf1);
    VDctxGetCompPath(node2ID,buf2);
    cmp = strcmp(buf1,buf2);

    // Should never happen since names should be unique
    if (cmp == 0) {
      cmp = -1;
      VDASSERTW(0);
    }
    goto wrapup;
  }
   
  // Done
  cmp = 0;
  
 wrapup:
  return cmp;
}

/* -----------------------------------------------
 * For organizing on piece marks
 */
IGRint VDat2ComparePcmksName(const void *v1, const void *v2) 
{
  TGRid *node1ID = (TGRid *)v1;
  TGRid *node2ID = (TGRid *)v2;
  
  IGRchab buf1,buf2;

  IGRint  pcmk1,pcmk2;

  IGRint cmp;

  // The piece marks
  VDctxGetPieceMark(node1ID,buf1);
  VDctxGetPieceMark(node2ID,buf2);
  pcmk1 = atoi(buf1);
  pcmk2 = atoi(buf2);
  if (pcmk1 < pcmk2) return -1;
  if (pcmk1 > pcmk2) return  1;

  // In case they do match, be a little consistent and do comp name as well
  VDctxGetCompName(node1ID,buf1);
  VDctxGetCompName(node2ID,buf2);
  cmp = strcmp(buf1,buf2);

  return cmp;
}
/* -----------------------------------------------
 * For organizing on piece marks
 */
IGRint VDat2ComparePcmks(const void *v1, const void *v2) 
{
  TGRid *node1ID = (TGRid *)v1;
  TGRid *node2ID = (TGRid *)v2;
  
  IGRchab buf1,buf2;

  IGRint  pcmk1,pcmk2;

  IGRint cmp = 0;

  // The piece marks
  VDctxGetPieceMark(node1ID,buf1);
  VDctxGetPieceMark(node2ID,buf2);
  pcmk1 = atoi(buf1);
  pcmk2 = atoi(buf2);
  if (pcmk1 < pcmk2) return -1;
  if (pcmk1 > pcmk2) return  1;

  return cmp;
}
