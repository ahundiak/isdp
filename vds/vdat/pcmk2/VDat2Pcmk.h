/* $Id: VDat2Pcmk.h,v 1.6 2001/04/12 19:12:26 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDat2Pcmk.h
 *
 * Description: Lower level piece mark routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDat2Pcmk.h,v $
 *      Revision 1.6  2001/04/12 19:12:26  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/04/05 14:16:25  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/04/03 16:51:04  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/22 18:45:51  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/22 14:41:47  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/18 22:49:45  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/16/01  ah      Creation
 ***************************************************************************/

#ifndef VDat2Pcmk_include
#define VDat2Pcmk_include

#ifndef   VDefpSrf_include
#include "VDefpSrf.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#define VDAT2_MIN_STD_PCMK 9000
#define VDAT2_MAX_STD_PCMK 9999

#define VDAT2_PCMK_MAX_LIKE_PLATE_AREA  300000
#define VDAT2_PCMK_MAX_LIKE_BEAM_HEIGHT    250

#define VDCTX_TREE_TYPE_SS_UNIT_PCMK  "ss_unit_pcmk"

#define VDCTX_ATR_SS_SRF_EDGE_LEN   "srf_edge_len"
#define VDCTX_ATR_SS_SRF_CENTER_MIN "srf_center_min"
#define VDCTX_ATR_SS_SRF_CUTOUT_CNT "srf_cutout_cnt"
#define VDCTX_ATR_SS_SRF_CUTOUT_DIS "srf_cutout_dis"

/* -----------------------------------------------
 * Just need to break down and define a pcmk oriented
 * data structure bringing together the surface info
 * and the nodeID info and maybe a few other things
 *
 * Bit of a pain but just do it.
 */
typedef struct
{
  TGRid  nodeID;
  IGRint group;
  IGRint isNotLike;
  IGRint isStd;
  TVDefpSrfTranInfo srfTranInfo;
} TVDat2PcmkInfo;

typedef struct
{
  TGRid  treeID;
  IGRint i,cnt,size,max;
  TVDat2PcmkInfo *pcmkInfos;
} TVDat2PcmkInfoList;


/* -----------------------------------------------
 * VDatInfo.c
 */
extern void VDat2FillSrfTranInfo __((TVDat2PcmkInfo *info));

extern void VDat2InitPcmkInfoList __((TVDat2PcmkInfoList *listPI));
extern void VDat2FreePcmkInfoList __((TVDat2PcmkInfoList *listPI));

extern void VDat2FillPcmkInfoList __((TGRid              *treeID, 
				      TVDctxNodeList     *listPM, 
				      TVDat2PcmkInfoList *listPI));

/* -----------------------------------------------
 * VDatTree.c
 */
extern void VDat2CreatePcmkTree         __((TGRid *atSetID, TGRid *domTreeID, TGRid *ssID, 
					    IGRint *errCnt));

extern void VDat2UpdateStagingTreePcmks __((TGRid *atSetID, TGRid *domTreeID, TGRid *ssID, 
					    IGRint saveSS,  IGRint risNextPcmk, IGRint *errCnt));

extern void VDat2ReportChangedPcmks     __((TGRid *atSetID, TGRid *domTreeID, TGRid *ssID));

/* -----------------------------------------------
 * VDatValidate.c
 */
extern void VDat2ValidateExistingPcmks __((TVDat2PcmkInfoList *listPI));


/* -----------------------------------------------
 * VDatGenerate.c
 */
extern void VDat2GeneratePcmks __((TVDat2PcmkInfoList *listPI, IGRint nextPcmk));

/* -----------------------------------------------
 * VDatVerify.c
 */
extern void VDat2VerifyPcmks __((TGRid *treeID, TGRid *ssID, IGRint nextPcmk));


/* -----------------------------------------------
 * VDatVerStd.c
 */
extern void VDat2VerifyStdPcmks __((TVDctxNodeList *listPM, IGRint *cnt));
extern void VDat2VerifyStdPcmk  __((TGRid *nodeID, IGRint isLoggedIn, IGRint *cnt));


/* -----------------------------------------------
 * VDatVerNot.c
 */
extern IGRstat VDat2IsNotLike      __((TGRid *nodeID));
extern void    VDat2VerifyNotLikes __((TVDctxNodeList *listPM, IGRint *changeCnt));

/* -----------------------------------------------
 * VDatVerLike.c
 */
extern void VDat2VerifyLikes __((TVDat2PcmkInfoList *listPM, 
				 TGRid  *ssID,
				 IGRint *nextPcmk,
				 IGRint *changeCnt));

extern IGRstat VDat2VerifyLikeProcessGroup __((TVDat2PcmkInfoList *listPI, 
					       IGRint beg, 
					       IGRint num));


/* -----------------------------------------------
 * VDatVerLikeSS.c
 */
extern IGRstat VDat2VerifyLikeSnapshotGroup __((TVDat2PcmkInfoList *listPI, 
						IGRint beg, 
						IGRint num,
						TVDctxNodeList *listSS));

/* -----------------------------------------------
 * VDatVerLikeMisc.c
 */
extern void   VDat2VerifyLikePrintList __((TVDat2PcmkInfoList *listPI));
extern void   VDat2VerifyLikePrintNode __((IGRint nth, IGRint group,TGRid *nodeID));
extern IGRint VDat2VerifyLikeCompare1  __((const void *v1, const void *v2));
extern IGRint VDat2VerifyLikeCompare2  __((const void *v1, const void *v2));

/* -----------------------------------------------
 * VDatStd.c
 */
extern IGRstat VDat2IsStdPcmk __((IGRchar *pcmkc, IGRint pcmki));

extern void VDat2GetStdPcmkForKey __((IGRint createFlag, IGRchar *key, IGRchar *pcmk));

extern void VDat2SetStdPcmks      __((TVDctxNodeList *listPM, IGRint *cnt));
extern void VDat2SetStdPcmkKeys   __((TVDctxNodeList *listPM));

extern void VDat2SetNotLikeFlags  __((TVDctxNodeList *listPM));

/* -----------------------------------------------
 * VDatCompare.c
 */
extern IGRint VDat2ComparePieceAttributes __((const void *v1, const void *v2));
extern IGRint VDat2ComparePlateAttributes __((const void *v1, const void *v2));
extern IGRint VDat2CompareBeamAttributes  __((const void *v1, const void *v2));
extern IGRint VDat2CompareGeomAttributes  __((const void *v1, const void *v2));
extern IGRint VDat2CompareGeometry        __((const void *v1, const void *v2));
extern IGRint VDat2ComparePieceArea       __((const void *v1, const void *v2));
extern IGRint VDat2ComparePcmks           __((const void *v1, const void *v2));
extern IGRint VDat2ComparePcmksName       __((const void *v1, const void *v2));

extern void VDat2SetCompareFlags __((IGRint verbose, 
				     IGRint place_macro,
				     IGRint order_exact));

extern void VDat2CompareNodesError __((TGRid *node1ID, TGRid *node2ID, IGRchar *msg));


//Cleanup
#if defined(__cplusplus)
}
#endif

#endif
