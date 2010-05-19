/* $Id: VDvalLike.h,v 1.11 2002/03/08 17:00:14 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDvalLike.h
 *
 * Description: Data structures for like part processing
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDvalLike.h,v $
 *      Revision 1.11  2002/03/08 17:00:14  ahundiak
 *      ah
 *
 *      Revision 1.10  2002/03/08 16:25:00  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/11/16 14:25:43  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/11/09 15:36:57  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/11/09 14:17:55  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/10/16 15:06:52  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/08/24 19:58:34  ahundiak
 *      ah
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/23/01  ah      Created
 ***************************************************************************/

#ifndef VDvalLike_include
#define VDvalLike_include

/* ----------------------------------------------
 * Usual header
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* -----------------------------------------------
 * Surface Transformation information
 * Keep in sync with VDefp
 */
#ifndef VDefpSrf_include
typedef struct 
{
  TGRbsp_curve **bsps;
  IGRint         cnt;
} TVDgeomListBsps;
#endif
  
typedef struct {

  /* 
   * This is a single outer contour bspline made from
   * natural edges for (plate base surface or beam left web)
   */
  struct 
  {
    TGRbsp_curve *crv;
    IGRdouble     area;
    IGRdouble     len;
  } contour;

  IGRdouble center_minor_distance;
  IGRdouble center_major_distance;
  IGRdouble  minor_major_distance;

  IGRpoint center;
  IGRpoint major;
  IGRpoint minor;

  IGRpoint material; /* Material direction from center */

  IGRvector center_major_vec;
  IGRvector center_minor_vec;
  IGRvector normal;
  IGRdouble angle;

  IGRdouble cutout_distance;
  
  TVDgeomListBsps inner;
  TVDgeomListBsps flange1;
  TVDgeomListBsps flange2;
  TVDgeomListBsps other;

} TVDvalSrfTranInfo;

extern void VDvalInitSrfTranInfo __((TVDvalSrfTranInfo *info));
extern void VDvalFreeSrfTranInfo __((TVDvalSrfTranInfo *info));

extern IGRstat VDvalGetSrfTranInfo __((TGRobj_env *pieceOE, TVDvalSrfTranInfo *info));

extern IGRstat VDvalCompareSrfTranInfo __((TVDvalSrfTranInfo *info1,
					   TVDvalSrfTranInfo *info2,
					   IGRdouble      bs_tol,
					   TVDgeomMat3x3  mat));

/* ----------------------------------------------
 * vdval/x3/VDvalGeom.c
 */
extern IGRstat VDvalGenerateLikePartInfo __((TGRid *pieceID));

extern IGRstat VDvalCompareNodeGeometry __((TGRid         *node1ID,
					    TGRid         *node2ID,
					    IGRdouble      tol,
					    TVDgeomMat3x3  mat));
  
/* ----------------------------------------------
 * vdval/x3/VDvalPiece.c
 */
extern IGRstat VDvalValidateTwoStdPieces __((TGRid *node1ID, 
					     TGRid *node2ID, 
					     IGRdouble tol, 
					     IGRint *errCnt));
  
extern  void VDvalValidateStdPieces __((TGRid    *treeID, 
					IGRint    flag,
					IGRdouble tol,
					IGRint    *errCnt));

/* ----------------------------------------------
 * vdval/om/VDvalAtr.c
 */
extern IGRstat VDvalAddModelCompPathAttribute  __((TGRobj_env *modelOE, TGRid *nodeID));
extern IGRstat VDvalAddModelClassNameAttribute __((TGRobj_env *modelOE, TGRid *nodeID));
extern IGRstat VDvalAddModelSymbologyAttribute __((TGRobj_env *modelOE, TGRid *nodeID));
extern IGRstat VDvalAddModelTagAttribute       __((TGRobj_env *modelOE, TGRid *nodeID));
extern IGRstat VDvalAddModelRepAttribute       __((TGRobj_env *modelOE, TGRid *nodeID));

extern void VDvalGetXmlPieceRep __((IGRint *rep));
extern void VDvalSetXmlPieceRep __((IGRint  rep));
  
extern IGRstat VDvalAddCoordMatrixAttribute __((TGRobj_env *csOE, TGRid *nodeID));
  

/* ----------------------------------------------
 * vdval/om/VDvalStdPc.c
 */
extern IGRstat VDvalGetStdPcmk1Key   __((TGRobj_env *pieceOE, IGRchar *key));
extern IGRstat VDvalGetStdPcmk2Info  __((TGRobj_env *pieceOE, IGRchar *geom_key, IGRchar *grade, IGRchar *thick));
extern IGRstat VDvalTestStdPcmk2Info __((TGRobj_env *pieceOE, IGRchar *results));

/* ----------------------------------------------
 * vdval/om/VDvalGenEqp.I
 */
extern void VDvalCreateEqpTreeForOS __((VDosnum osnum,TGRid *treeID));
  

extern void VDvalCreateEqpTreeTest __((TVDtestTestInfo *info));

extern IGRstat VDvalGenProcessParent __((TGRobj_env *modelOE, 
					 TGRobj_env *parentOE,
					 IGRchar    *parentType,
					 TGRid      *nodeID));

/* ----------------------------------------------
 * vdval/om/VDvalParent.I
 */
extern IGRstat VDvalGenProcessParentCollector __((TGRobj_env *childOE, 
						  TGRobj_env *parentOE,
						  IGRchar    *parentType,
						  TGRid      *domID));

/* ----------------------------------------------
 * vvval/om/VDvalGenComp.I
 */

extern void VDvalCreateComponentTreeForOS __((VDosnum osnum,TGRid *treeID));
  

extern void VDvalCreateComponentTreeTest __((TVDtestTestInfo *info));

/* ----------------------------------------------
 * vdval/om/VDvalComputePiece.c
 */
extern IGRstat VDvalComputePiece __((TGRobj_env *macOE,
				     IGRint     opFlag,
				     IGRint     *feetCntx,
				     TGRid      *feetIDs));

extern void VDvalCreateStdPieceTreeForOS __((VDosnum osnum,TGRid *treeID));

extern void VDvalCreateStdPieceTree __((TGRid *treeID));

extern void VDvalCreatePieceTreeForOS __((VDosnum osnum,TGRid *treeID));

extern void VDvalCreatePieceTree __((TGRid *treeID));

/* ----------------------------------------------
 * vdval/om/VDvalCompEqp.I
 */
extern IGRstat VDvalComputeXmlEqp __((TGRobj_env *macOE,
				      IGRint     opFlag,
				      IGRint     *feetCntx,
				      TGRid      *feetIDs));

/* ----------------------------------------------
 * vdval/om/VDvalCompComp.I
 */
extern IGRstat VDvalComputeXmlComponent __((TGRobj_env *macOE,
					    IGRint     opFlag,
					    IGRint     *feetCntx,
					    TGRid      *feetIDs));

/* ----------------------------------------------
 * vdval/om/VDvalCmdStdPcmks.c
 */

/* ----------------------------------------------
 * Cleanup
 */
#if defined(__cplusplus)
}
#endif

#endif

