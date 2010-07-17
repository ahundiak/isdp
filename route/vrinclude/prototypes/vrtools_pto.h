/* $Id: vrtools_pto.h,v 1.3 2001/01/26 14:24:14 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrtools_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrtools_pto.h,v $
 *	Revision 1.3  2001/01/26 14:24:14  build
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/22 16:24:01  anand
 *	SP merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *	Initial import to CVS
 *
 * Revision 1.4  2000/10/16  14:51:40  pinnacle
 * Replaced: route/vrinclude/prototypes/vrtools_pto.h for:  by aharihar for Service Pack
 *
 * Revision 1.3  2000/09/06  23:18:56  pinnacle
 * Replaced: route/vrinclude/prototypes/vrtools_pto.h for:  by apazhani for Service Pack
 *
 * Revision 1.2  2000/07/20  16:26:18  pinnacle
 * Replaced: route/vrinclude/prototypes/vrtools_pto.h for:  by apazhani for Service Pack
 *
 * Revision 1.1  2000/07/13  22:48:02  pinnacle
 * Created: route/vrinclude/prototypes/vrtools_pto.h by apazhani for Service Pack
 *
 * Revision 1.5  2000/03/15  18:58:56  pinnacle
 * Replaced: vrinclude/prototypes/vrtools_pto.h for:  by apazhani for route
 *
 * Revision 1.4  2000/02/21  20:53:22  pinnacle
 * Replaced: vrinclude/prototypes/vrtools_pto.h for:  by lawaddel for route
 *
 * Revision 1.3  1999/05/28  14:00:44  pinnacle
 * Replaced: vrinclude/prototypes/vrtools_pto.h for:  by apazhani for route
 *
 * Revision 1.2  1999/04/19  20:32:40  pinnacle
 * Replaced: vrinclude/prototypes/vrtools_pto.h for:  by lawaddel for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.3  1997/05/23  13:58:18  pinnacle
 * Replaced: vrinclude/prototypes/vrtools_pto.h for:  by apazhani for route
 *
 * Revision 1.2  1997/04/15  22:08:04  pinnacle
 * Replaced: vrinclude/prototypes/vrtools_pto.h for:  by hverstee for route
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.3  1996/01/17  23:37:20  pinnacle
 * Replaced: vrinclude/prototypes/vrtools_pto.h for:  by r240_int for route240
 *
 * Revision 1.2  1996/01/17  00:38:08  pinnacle
 * Replaced: vrinclude/prototypes/vrtools_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:52:08  pinnacle
 * Created: vrinclude/prototypes/vrtools_pto.h by tlbriggs for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/11/96   tlb		created
 *	01/12/96   tlb		Add include files, externs, 
 *				Remove prototypes declared in other files
 *	01/17/96   tlb		Remove vrtoolsdef include
 *	05/28/99   Alwin	Added the function VRGetShapeFrmCompCode.
 *	02/18/00   law		Added product arg to VRGetShapeFrmCompCode
 *	03/15/00   Alwin	Added the function VRGetCorrectionFromLineSeg.
 *	07/13/00   Alwin	Added the functions VRUpdate_ACST_User_Param 
 *				and VRCopyDuctParams
 *	07/20/00   Alwin	Added the function VRPGetInsulThkFromType 
 *	09/06/00   Alwin	Added the functions VRCopyDuctParams and
 *				VRFillUpNozzleAttrForm
 *	10/11/2k   Anand	Added prototype for VRkeyFltrInCDLdbFlds
 *
 *************************************************************************/

#include <standards.h>
#include <stdio.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"		/* struct IGRdisplay */
#include "gr.h"
#include "ex.h"
#include "FI.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "dpstruct.h"		/* struct DPele_header */
#include "parametric.h"
#include "ACrg_collect.h"
#include "VDScheckdef.h"	/* struct VDConnEntity */
#include "VRverify.h"		/* struct VRvfy_file */
#include "VRRwDimen.h"
#include "VRSttopo.h"
#include "VRpriv_attr.h"
#include "VRstructs.h"

#define DI_PATH_MAX 1024

/* VRAttributes.I */
extern IGRint VRGetParameterType __((	IGRlong *pMsg ,
					 struct GRid *CompId ,
					 IGRchar *AttrName ,
					 IGRint *AttrType ,
					 struct GRmd_env *pMdEnv ));
	/* VRReviewParameters	declared in vrmacros.h */
	/* VRGetCptProp		declared in vrmacros.h */

/* VRConnect.I */
extern IGRint VRConnect 	__((	IGRlong *msg ,
					 struct GRid *CmpId ,
					 IGRshort *nCptNum ,
					 IGRint NbCpts ,
					 struct GRid *SegmentIds ,
					 IGRint NbSeg ,
					 IGRshort *nIndex ,
					 struct GRmd_env *md_env ));

/* VRCreate.I */
	/* VRPlaceCmpByItemName	declared in VRprivmacros.h */


/* VRDefSegPl.I */
extern int cre_plan 		__((	IGRdouble *origin ,
					 IGRdouble *normal ,
					 struct GRmd_env *md_env ,
					 struct GRid *GRid_plan ));
extern int place_cons 		__((	IGRlong *sts ,
					 struct GRid *GRid_end_pl ,
					 struct GRmd_env *md_env ,
					 IGRint num_equi_pl ,
					 IGRint *equi_pl ));
extern int check_coin 		__((	IGRlong *sts ,
					 IGRint num_pl ,
					 struct IGRplane *master_pl ,
					 struct IGRplane *slave_pl ,
					 IGRint *num_com_pl ,
					 IGRint *ind_com_pl ));
extern int seg_belong_planes 	__((	IGRdouble *str ,
					 IGRint num_planes ,
					 struct IGRplane *planes ,
					 IGRint *WitchPlanes ));
extern int is_founded 		__((	IGRint *array ,
					 IGRint start_search ,
					 IGRint end_search ,
					 IGRint ind_to_search ,
					 IGRint *ind_founded ));
extern int free_free 		__((	IGRlong *sts ,
					 struct GRid *GRid_end_pl ,
					 struct GRmd_env *md_env ,
					 IGRdouble *string ,
					 struct GRid *GRid_new_pl ));
extern int dang_free 		__((	IGRlong *sts ,
					 struct GRid *GRid_end_pl ,
					 struct GRmd_env *md_env ,
					 IGRdouble *string ,
					 IGRboolean cre_flag ,
					 struct GRid *GRid_new_pl ));
extern int CheckCoinc_WithExtent 	
				__((	IGRlong *sts ,
					 struct GRid *GRid_end_pl ,
					 struct GRid *GRid_new_pl ,
					 struct GRmd_env *md_env ,
					 struct IGRplane *n_plans ,
					 IGRdouble *trav_string ,
					 IGRboolean SlaveExtent ));
extern int dang_dang 		__((	IGRlong *sts ,
					 struct GRid *GRid_end_pl ,
					 struct GRmd_env *md_env ,
					 IGRdouble *string ,
					 struct GRid *GRid_new_pl ,
					 IGRboolean ext_flag ,
					 IGRboolean ext_cre_flag ));
	/* VRDefineSegPlanes	declared in VRprivmacros.h */

/* VREval.I */
extern IGRint VRTestGeom 	__((	IGRlong *msg ,
					 struct GRid *pCmpId ,
					 IGRint NbCpts ,
					 IGRint *Type ,
					 struct GRmd_env *md_env ));
	/* VREvaluateCmp -	declared in VRmacros.h */


/* VREvalEquip.I */
extern IGRint VREvaluateEquip 	__((	IGRlong *msg ,
					 IGRchar *EquiNumber ,
					 struct GRsymbology *Symb ,
					 IGRchar cRep ,
					 struct GRid *StatParamId ,
					 struct GRid *DynParamId ,
					 struct GRid *MissingParamId ,
					 struct GRid *EquipId ,
					 IGRint *NbMissingExp ,
					 struct ACrg_coll **Missings ,
					 struct GRmd_env *md_env ));

/* VREvalNoz.I */
	/* VREvaluateNozz - declared in VRnozzmacros.h  */


/* VRExtNozz.I */
extern IGRint VRExtNozzles 	__((	struct GRid *pEquipId ,
					 IGRchar cRep ,
					 struct GRid *pNozHoldId ,
					 IGRchar *pcPath ,
					 struct GRvg_construct *pCnstList ,
					 struct GRid *pNozzleId ,
					 struct GRmd_env *pMdEnv ));

/* VRFIutil.I */
extern IGRint VRFI_listgen 	__((	IGRchar *form_ptr ,
					 IGRint gadget_label ,
					 IGRint default_num ,
					 IGRint NbRows ,
					 IGRchar **Buffer ));
extern IGRint VRFI_dblistgen 	__((	IGRchar *form_ptr ,
					 IGRint gadget_label ,
					 IGRint default_num ,
					 IGRchar *selkey ,
					 IGRchar *where ,
					 IGRchar *tabnam ));
extern IGRint VRFI_stlistgen 	__((	IGRchar *form_ptr ,
					 IGRint gadget_label ,
					 IGRint default_num ,
					 IGRint Prodkey ,
					 IGRint Listid ,
					 IGRchar *ParName ,
					 struct GRid *CollId ));

/* VRFormUtil.I */
extern int VRDisplayFormUnits 	__((	Form formPtr ,
					 int metGroup ,
					 int impGroup ));
extern IGRint VRDispCollAttr 	__((	Form pForm ,
					 struct GRid *pCollId ,
					 IGRint GadgetNum ,
					 IGRchar *pAttrName ));
extern IGRint VRDispCollList 	__((	Form pForm ,
					 IGRint GadgetNum ,
					 IGRint Row ,
					 IGRint *pNbAttr ,
					 struct GRid *pCollId ));

/* VRGlobFun.I */
extern IGRdouble VRcompute_angle 
				__((	IGRdouble *v1 ,
					 IGRdouble *v2 ,
					 IGRdouble *vz ));
extern IGRboolean bVRTestVect 	__((	IGRlong *msg ,
					 IGRdouble *dVect1 ,
					 IGRdouble *dVect2 ,
					 IGRshort nTest ));
extern int VRMkTransShape 	__((	IGRint Shape1 ,
					 IGRint Shape2 ,
					 IGRint *TrShape ));
extern IGRboolean VRIsEccentricComp 	
				__((	IGRlong *pMsg ,
					 struct GRid *pCmpId ,
					 struct GRmd_env *pMdEnv ));
extern IGRboolean VRIsCenterJustified 	
				__((	struct GRid *pCmpId ,
					 struct GRid *pSegId ,
					 struct GRmd_env *pMdEnv ));
extern IGRboolean VRIsShXtionValid 	
				__((	IGRlong *pMsg ,
					struct GRid *pCmpId ,
					 struct GRmd_env *pMdEnv ));
	/* VRMakeSource - 	declared in VRmacros.h */
      	/* VRGetPath  - 	declared in VRGlobMac.h */
	/* VRGetCmpMatrix - 	delacred in VRmacros.h */
	/* VRSetCompInstanceInfo  declared in VRmacros.h */
	/* VRGetAttributes	decalared in VRmacros.h */
	/* VRGetCptInfo		decalred in VRmacros.h */
	/* VRSplitSegment 	declared in VRmacros.h */
	/* VRSplitCorrection	declared in VRmacros.h */

/* VRInfo.I */
	/* VRSelectClosestCpt - declared in VRcptmacros.h */

/* VRLnUtil.I */
extern int VR_colinear 		__((	IGRdouble *p1 ,
					 IGRdouble *p2 ,
					 IGRdouble *p3 ));
extern void VR_enforceMinDist 	__((	IGRdouble *p1 ,
					 IGRdouble *p2 ,
					 IGRdouble minDist ));
extern IGRboolean VR_snapAngleRad 	__((	IGRdouble *angleRad ,
					 IGRdouble deltaRad ));
extern void VR_lineSnap_mod45 	__((	IGRdouble *point1 ,
					 IGRdouble *point2 ));

/* VRModColl.I */
	/* VRModifyCollection	decalred in VRutilmacros.h */

/* VRNozColl.I */
extern IGRint VRGenericLink 	__((	IGRlong *msg ,
					 struct GRid CollId ,
					 struct ACrg_coll *Attr ,
					 struct GRmd_env *md_env ,
					 IGRint NbTemp ,
					 struct GRid *TempIds ,
					 IGRint *TempState ,
					 struct GRid Context ));
extern IGRint VRNozSysLink 	__((	IGRlong *msg ,
					 struct GRid CollId ,
					 struct ACrg_coll *Attr ,
					 struct GRmd_env *md_env ,
					 IGRint NbTemp ,
					 struct GRid *TempIds ,
					 IGRint *TempState ,
					 struct GRid Context ));
extern IGRint VRHNozSysLink 	__((	IGRlong *msg ,
					 struct GRid CollId ,
					 struct ACrg_coll *Attr ,
					 struct GRmd_env *md_env ,
					 IGRint NbTemp ,
					 struct GRid *TempIds ,
					 IGRint *TempState ,
					 struct GRid Context ));
extern IGRint VRBuildExp 	__((	IGRlong *msg ,
					 IGRchar ExpType ,
					 IGRchar *ExpName ,
					 IGRchar *ExpText ,
					 IGRdouble *ExpValue ,
					 struct GRid *Expression ,
					 struct GRmd_env *MdEnv ));
extern IGRint VRCheckExp 	__((	IGRlong *msg ,
					 IGRchar *ExpName ,
					 IGRchar *ExpValue ,
					 struct GRmd_env *MdEnv ));

/* VROrie.I */
extern IGRlong VRorient		__((	IGRshort product ,
					 IGRdouble *dOrigin ,
					 IGRdouble *dXaxis ,
					 IGRdouble *dYaxis ,
					 struct IGRdisplay *display ,
					 struct GRmd_env *md_env ));
extern IGRlong VRFollowCursor 	__((	struct GRid *CmpId ,
					 struct IGRdisplay *display ,
					 struct GRmd_env *md_env ));
	/* VROrientComp 	declared in VRmacros.h */

/* VRPlCor.I */
extern int VRPlaceCorrection 	__((	GRclassid ClassId ,
					 IGRshort CorType ,
					 struct GRid *ParentId ,
					 struct GRid *p_CorEntityId ,
					 struct GRmd_env *p_MdEnv ));
	/* VRComputeCorrection 	declared in VRmacros.h */


/* VRPlSeg.I */
	/* VRPlaceSegment 	declared in VRmacros.h */


/* VRPlace.I */
extern IGRint VRCompPosOnTopo 	__((	IGRint NbSegments ,
					 struct GRid *SegmentIds ,
					 IGRdouble *dOrig ,
					 IGRshort *nIndexList ,
					 struct GRmd_env *md_env ));
extern IGRint VRSelectOrie 	__((	IGRint NbAxes ,
					 IGRdouble *dAxes ,
					 IGRdouble *dXaxis ,
					 IGRdouble *dYaxis ,
					 IGRdouble *dZaxis ,
					 IGRshort *nXIndex ,
					 IGRshort *nYIndex ,
					 IGRshort *nZIndex ,
					 IGRdouble *dXOrie ,
					 IGRdouble *dYOrie ,
					 IGRdouble *dZOrie ));
	/* VRPlaceComponent -	declared in VRmacros.h */

/* VRPlaceAuto.I */
	/* VRPlaceAutoComponent - declared in VRMcplace.h */


/* VRPlaceNoz.I */
extern IGRint VRGetEquiShort 	__((	IGRchar *StringTab ,
					 IGRshort *ShortTab ,
					 IGRint SizeTab ,
					 IGRchar String [9 ],
					 IGRshort *Short ));
	/* VRPlaceNozz - declared in VRnozzmacros.h */

/* VRReConnect.I */
extern IGRint VRReConnect 	__((	IGRlong *msg ,
					 struct GRid *p_OldCmpId ,
					 struct GRid *p_NewCmpId ,
					 IGRshort *nCptNum ,
					 IGRint NbCpts ,
					 IGRint NbNewSegs ,
					 struct GRid *NewSegIds ,
					 struct GRmd_env *p_MdEnv ));

/* VRReplace.I */
	/* VRReplace -		decalared in VRmacros.h */

/* VRRptConnect.I */
extern int VDGetRouteConnection __((	struct GRid *EntityId ,
					 struct GRmd_env *pMdEnv ,
					 int nbSize ,
					 int *NbCpts ,
					 char **Cpts ,
					 struct VDConnEntity *Entities ));

/* VRSelect.I */
extern IGRint VRSelectByAttributes 
				__((	IGRlong *msg ,
					 struct GRid *CompId ,
					 struct GRfunction_info *f_info ));
extern int VRFreeStaticSelect 	__((	void ));
	/* VRSelectComponent	declared in vrmacros.h */
	/* VRReviewTopology	declared in vrmacros.h */
	/* VRReviewFlowdir	declared in vrmacros.h */

/* VRStubs.C */
extern int VDGetListOfIDs 	__((	char *SystemName ,
					 int CompCategory ,
					 int IdList []));
extern int VDLockSelectedID 	__((	char *SystemName ,
					 int CompCategory ,
					 int UsedID ));
extern int VDModifyID 		__((	char *SystemName ,
					 int CompCategory ,
					 int OldId ,
					 int NewId ));
extern int VDVerifyIfIDisUsed 	__((	char *SystemName ,
					 int CompCategory ,
					 int ID ));
extern int VDGetNewID 		__((	char *SystemName ,
					 int CompCategory ,
					 int OldId ,
					 int *NewId ));
extern int VDUnLockID 		__((	char *SystemName ,
					 int CompCategory ,
					 int UsedID ));
extern IGRint VRdbGetCompCat 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRchar *comp_code ,
					 IGRint *comp_cat ,
					 IGRint *comp_behvr ,
					 IGRchar *err_ptr ));

/* VRTestColl.I */
extern int VRTestColl 		__((	IGRlong *p_msg ,
					 struct GRid *p_FirstCollectionId ,
					 struct GRid *p_SecondCollectionId ,
					 IGRboolean *Result ));

/* VRVerifyFunk.I */
	/* VRPrintVerify	declared in VRverifymac.h */
	/* VRPrintErrHead	declared in VRverifymac.h */
	/* VRPrintVerHead 	declared in VRverifymac.h */
	/* VRPrintVerObj	declared in VRverifymac.h */

/* VRget_params.I */
extern IGRlong VRinit_attributes __((	IGRint VRproduct ,
					 struct ACrg_coll *Attr ,
					 IGRint *NbAttr ));
extern IGRlong VRInitAttributes __((	IGRint Product ,
					 struct GRid *CollectId ,
					 IGRchar attribute_name [DI_PATH_MAX ]));
	/* VRactive_params - declaraed in VRact_params.h */
extern int VRAsciiToAttr 	__((	IGRchar *attribute_name ,
					 IGRchar *attribute_value ,
					 struct ACrg_coll *attr ));
extern IGRint VRinit_symbology 	__((	IGRlong *msg ,
					 struct GRsymbology *symbology ));
	/* VRsymbology 	- declared in VRclsymb.h */


/* VRhcfunk.I */
extern int VRSkGetHvacCmpParams 	__((	union VRparam_attr *cmp_param ,
					 struct GRid *ParentList ,
					 IGRdouble *orient_section ,
					 struct GRmd_env *md_env ,
					 IGRdouble *orient_angle ));
extern int VRSkUpdateParams 	__((	IGRshort Product ,
					 struct GRid *p_OldActParamId ,
					 struct GRid *p_NewActParamId ,
					 IGRdouble *p_ActSection ,
					 struct GRmd_env *p_MdEnv ));
extern int VRskComputeCmpAngle 	__((	IGRdouble *CmpOrientSection ,
					 struct GRid *ParentId ,
					 IGRdouble *CmpAngle ,
					 struct GRmd_env *ModuleEnv ));
	/* VRModifyHvacSection	declared in VRprivmacros.h */


/* VRlibfunk.I */
extern IGRlong make_ref 	__((	IGRlong *msg ,
					 IGRdouble *vx0 ,
					 IGRdouble *vy0 ,
					 IGRdouble *vz0 ,
					 IGRdouble *vy ,
					 IGRdouble *vz ));
extern int VRget_active_symb 	__((	IGRshort *level ,
					 struct IGRdisplay *display ));
extern int VRGetConstructionList __((	IGRlong *p_retmsg ,
					 struct GRmd_env *md_env ,
					 short unsigned *properties ,
					 struct GRsymbology *Symbology ,
					 struct IGRdisplay *act_display ,
					 IGRchar *class_attr ,
					 struct GRvg_construct *cst ));
extern int VRprint_user_attr 	__((	struct GRid *user_attr_id ));
extern int VRGetAttrFromDB 	__((	IGRchar *form_ptr ,
					 IGRint Product ));
extern IGRint VRMissingPbId 	__((	IGRlong *msg ,
					 struct GRid *CompId ,
					 struct GRid *PbId ,
					 struct GRid *MissingPbId ,
					 struct GRmd_env *md_env ));
extern int VRGetUserColl 	__((	IGRchar *form_ptr ,
					 IGRint gadget_label ,
					 struct GRid *UserId ));
extern int VRchg_attributes 	__((	IGRshort chg_type ,
					 struct GRid attribute_id ,
					 IGRint number ,
					 IGRchar **attribute_names ,
					 IGRchar **attribute_values ));
extern int VRSplitNetWork 	__((	IGRlong *msg ,
					 struct GRid *SegmentToSplitId ,
					 IGRdouble *SplitPoint ,
					 struct GRmd_env *md_env ,
					 struct GRid *CmpId ,
					 struct GRid *NewSegmentId ));
extern int VRChgCmpAttr 	__((	IGRlong *msg ,
					 struct ACrg_coll *NewAttr ,
					 struct GRid *CmpId ,
					 struct GRmd_env *md_env ));
extern int VRGetCmpClass 	__((	struct GRid *CmpId ,
					 IGRshort *Product ));
extern int VRDeleteObjects 	__((	IGRint NbObjects ,
					 struct GRid *p_ObjectsList ,
					 struct GRmd_env *p_MdEnv ));
extern int VRCheckCompTopo 	__((	IGRint *p_CompTopo ,
					 struct GRid *p_CompId ,
					 struct GRmd_env *p_MdEnv ));
extern int VRCreateDepPlanes 	__((	IGRint InPutFlag ,
					 IGRint NbTemp ,
					 struct GRid *p_TempId ,
					 struct GRmd_env *p_TempMdEnv ,
					 struct GRmd_env *p_MdEnv ,
					 IGRint NbDepPlanes ,
					 struct GRid *p_DepPlanesId ));
extern int VRChangePocketMenu 	__((	IGRchar *szPocketMenuName ));
extern IGRint VRGetAABBCC 	__((	IGRlong *msg ,
					 struct GRevent *event ,
					 IGRchar *szAABBCC ,
					 IGRboolean *bFlag ));
extern int VRCopyWithOutSpace 	__((	IGRchar *szStringIn ,
					 IGRchar *szStringOut ));
extern int VRBuildCompPlanes 	__((	IGRlong *p_retmsg ,
					 struct GRid *p_ComponentId ,
					 IGRshort CptNum ,
					 struct GRmd_env *p_CompMdEnv ,
					 struct GRid *p_PlaneIds ,
					 struct GRmd_env *p_PlanesMdEnv ));

/* VRprivfunk.I */
extern int VRUpdateConstruction	__((	IGRlong *msg ,
					 IGRint NbCmp ,
					 struct GRid *CmpId ,
					 struct GRmd_env *md_env ));
	/* VRGetCmpAttributes 	declared in VRprivmacros.h */
	/* VRGetDimensionAttributes	declared in VRprivmacros.h */

/* VRskcon_funk.I */
extern int VRskget_all_sol 	__((	IGRshort dim ,
					 IGRshort which_plane ,
					 IGRdouble *pts ,
					 IGRdouble *lcl_pt1 ,
					 IGRdouble *pt2 ,
					 IGRdouble *lcl_pt2 ));
extern int VRskget_way 		__((	IGRshort dim ,
					 IGRshort which_plane ,
					 IGRdouble *pts ,
					 IGRdouble *pt1 ,
					 IGRdouble *lcl_pt1 ,
					 IGRdouble *pt2 ,
					 IGRdouble *lcl_pt2 ));
extern int VRskprint_segments_lengh __((	IGRdouble *tab1 ,
					 IGRdouble *tab2 ,
					 IGRint nb_case ));
extern IGRboolean VRSkIsPipeConnectionValid 	
				__((	IGRshort Product ,
					 struct GRid *PipeId ,
					 IGRdouble *FirstPt ,
					 IGRdouble *NextPt ,
					 struct GRmd_env *MdEnv ));
extern IGRboolean VRSkIsDanglingConnectionValid 	
				__((	IGRshort IndexOfDangling ,
					 IGRdouble *pt1 ,
					 IGRdouble *pt2 ,
					 IGRdouble *pt3 ,
					 IGRdouble *pt4 ));

/* VRskfunk.I */
extern int VRskget_active_cs 	__((	struct GRmd_env *mod_env ,
					 struct GRid *active_cs_id ,
					 IGRdouble *active_cs_matrix ,
					 IGRchar *cstype ));
extern int VRis_next_pt_valid 	__((	IGRint AcceptExtend ,
					 IGRint *IsValidPoint ,
					 IGRdouble *prev_pt ,
					 IGRdouble *first_pt ,
					 IGRdouble *next_pt ,
					 IGRint NbOfImpDirection ,
					 IGRdouble *imp_direct ));
extern int VRget_project_pt 	__((	IGRdouble *first_pt ,
					 IGRdouble *next_pt ,
					 IGRdouble *projpt ,
					 IGRdouble *win_direction ,
					 IGRdouble *imp_direction ));
extern IGRint VRskgetpt_in_active_cs 	
				__((	IGRdouble *base_pt ,
					 IGRdouble *active_pt ,
					 struct GRmd_env *mod_env ));
extern IGRlong VRskgetendpt 	__((	IGRlong *msg ,
					 IGRboolean pt_type ,
					 IGRdouble *end_pt ,
					 struct GRid *seg_id ,
					 struct GRmd_env *md_env ));
extern int VRis_change_param 	__((	IGRshort product ,
					 struct GRid *buf_param_id ,
					 struct GRid *act_param_id ,
					 IGRshort twist_orient ,
					 IGRshort twist_save ,
					 IGRshort *is_change ,
					 IGRshort *placement_type ,
					 struct GRmd_env *MdEnv ));
extern IGRint Cursor_Pos 	__((	IGRdouble pt []));
extern int VRSkIsConElbowValid 	__((	IGRint *msg ,
					 IGRdouble *first_pt ,
					 IGRdouble *next_pt ,
					 IGRdouble *elbow_direct1 ,
					 IGRdouble *elbow_direct2 ));
extern int VRSkGetAttrToConnect	__((	IGRshort product ,
					 struct GRid *act_param_id ,
					 struct GRid *user_param_id ,
					 struct GRid *cmp_id ,
					 struct GRid *seg_id ,
					 struct GRid *buf_param_id ,
					 struct GRid *seg1_id ,
					 struct GRmd_env *md_env ));
extern int VRskxform 		__((	IGRlong *msg ,
					 IGRdouble *xform_matrix ,
					 struct GRid *plane_to_move ,
					 struct GRmd_env *md_env ));
extern int VRGetIfConnectable 	__((	IGRboolean *connectable ,
					 struct GRid *ObjId ,
					 struct GRmd_env *md_env ));
extern int VRskUpdateConnection 	__((	struct GRid *SrcPlanesId ,
					 struct GRid *NewPlanesId ,
					 IGRint NbPlanes ));
extern int VRSkSetFormMode 	__((	IGRshort Product ,
					 IGRint Mode ));
extern int VRskdisplay_angle 	__((	IGRdouble angle ,
					 IGRdouble *prev_pt ,
					 IGRdouble *first_pt ,
					 IGRdouble *projpt ,
					 IGRdouble *z_win ));
extern int VRSkGetJustif 	__((	IGRshort Product ,
					 struct GRid *p_MyParamId ,
					 struct GRmd_env *p_MdEnv ));
extern int VRSkUpdateForm 	__((	IGRint product ,
					 IGRchar *formPtr ,
					 IGRint *ShapeGadget ,
					 struct GRid *ParamId ,
					 IGRchar *AABBCCode ,
					 IGRint *active_cpt,
					 struct VRRwCptDetails  *RWcptdata,
					 struct GRmd_env         *md_env,
					 IGRshort SketchMode ));
extern IGRint VRResetOptionCode __((     IGRlong *msg,
                                         Form form_ptr,
                                         struct GRid CorId ));
extern int VRNozUpdateForm 	__((	IGRint product ,
					 IGRchar *formPtr ,
					 struct GRid *ParamId ));
extern int VRMakeConstraints 	__((	IGRint NbPlanes ,
					 struct GRid *PlanesId ,
					 struct GRid *CopyPlane ,
					 struct GRmd_env *p_PlMdEnv ,
					 struct GRmd_env *p_CurMdEnv ));
extern IGRdouble VRGetAngle 	__((	IGRlong *p_msg ,
					 struct GRid *p_AxisList ,
					 IGRdouble PrimaryOrient ,
					 IGRdouble SecondaryOrient ,
					 struct GRmd_env *p_MdEnv ));
extern int VRGetCompPlanes 	__((	IGRlong *p_retmsg ,
					 struct GRid *p_CompId ,
					 IGRint CompCpt ,
					 IGRdouble *p_GivenPt ,
					 struct GRmd_env *p_CompMdEnv ,
					 struct GRmd_env *p_CurMdEnv ,
					 struct GRid *p_CompPlanesId ,
					 struct GRid *p_DepPlanesId ));
extern int VRGetCompFunction 	__((	IGRshort product ,
					 struct GRid *p_CompId ,
					 IGRint *p_CmpFunction ,
					 union VRparam_attr *p_CmpParam ,
					 struct GRmd_env *p_MdEnv ));
extern int VRAddConcPlanes 	__((	IGRlong *retmsg ,
					 struct GRid *CompId ,
					 struct GRmd_env *md_env ));
extern IGRint VRGetTopology 	__((	IGRlong *msg ,
					 struct VRTopo *pTopo1 ,
					 struct VRTopo *pTopo2 ,
					 IGRdouble *pdAngle ,
					 IGRdouble *pd16Matrix ,
					 struct GRmd_env *p_MdEnv ));
	/* VRGetCompGenInfo	decalred in VRutilmacros.h */
	/* VRMergeSegments	declared in VRmacos.h */

/* added by alwin for handling the Shape transition components */
/* modified for tr179900985 */
extern int VRGetShapeFrmCompCode __((   IGRchar *comp_code,
                                        IGRboolean  *bIsTransition,
                                        IGRint *shape_code,
                                        IGRint product ));

/* VRskutilfunk.I */
extern int VRChangeSegLength 	__((	IGRshort Factor ,
					 IGRshort FittingType ,
					 struct GRid *seg_id ,
					 struct GRmd_env *md_env ));
extern int VRMergeCorrections 	__((	IGRlong *p_retmsg ,
					 IGRint NumCor ,
					 struct GRid *p_CorsId ,
					 struct GRmd_env *p_MdEnv ));
extern int VRDeleteCorrection 	__((	IGRlong *msg ,
					 struct GRid *SegId ,
					 struct GRid *OldCmpId ,
					 struct GRmd_env *md_env ));
extern int VRSkLocatePipe 	__((	IGRlong *msg ,
					 struct GRevent *LocatedEvent ,
					 IGRdouble *AcceptPoint ,
					 struct GRid *PipeLocatedId ,
					 struct GRmd_env *md_env ,
					 IGRdouble *ProjPoint ));
extern int VRSkGetPipeVirtualSupportInfo 
				__((	struct GRid *PipeLocatedId ,
					 IGRdouble *SplitPt ,
					 struct GRmd_env *md_env ,
					 struct GRid *SegId ,
					 IGRdouble *PipeDir ,
					 IGRdouble *EndPoint ));
extern int VRSkReplaceTeeByElbow __((	IGRshort Product ,
					 struct GRid *TeeId ,
					 struct GRmd_env *MdEnv ,
					 struct GRvg_construct *CnstList ));
extern int VRModifyParameterBox   __((	IGRlong *msg ,
					 IGRshort product ,
					 union VRparam_attr *Parameter ,
					 struct GRid *OldParameterBoxId ,
					 struct GRid *NewParameterBoxId ));
extern int VRGetPipeParams 	__((	IGRshort Product ,
					 struct GRid *LocatedPipeId ,
					 struct GRid *ActParamId ,
					 struct GRid *UserParamId ,
					 struct GRmd_env *MdEnv ));
extern int VRGetCorrection 	__((	IGRlong *msg ,
					 struct GRid *SegId ,
					 struct GRid *CmpId ,
					 struct GRmd_env *md_env ,
					 struct GRid *CorId ,
					 struct GRid *MyCmpId ));
extern int VRUpdateGraph 	__((	IGRlong *p_retmsg ,
					 IGRshort Product ,
					 IGRboolean *UpdateSegLen ,
					 struct GRid *p_SegId ,
					 struct GRid *p_CmpId ,
					 IGRshort CorType ,
					 IGRshort CopyType ,
					 struct GRmd_env *p_MdEnv ));
extern int VRUpdateSegLength 	__((	IGRlong *msg ,
					 struct GRid *Seg1Id ,
					 struct GRid *Seg2Id ,
					 struct GRmd_env *md_env ));
extern int VRGetCorrectionType 	__((	IGRlong *msg ,
					 struct GRid *CmpId ,
					 struct GRid *SegId ,
					 IGRshort *FittingType ,
					 struct GRmd_env *md_env ));
extern int VRSkGetElbowTopo 	__((	struct GRid *LocatedElbowId ,
					 IGRdouble *ElbowDirP ,
					 IGRdouble *ElbowDirS ,
					 IGRdouble *ElbowOrig ,
					 struct GRmd_env *MdEnv ));
extern int VRSkGetAttrFromCmp 	__((	IGRshort product ,
					 struct GRid *cmp_param_id ,
					 struct GRid *buf_param_id ,
					 struct GRid *user_param_id ,
					 struct GRid *cmp_id ,
					 struct GRid *seg1_id ,
					 struct GRid *seg2_id ,
					 struct GRmd_env *md_env ));
extern int VRGetCompInfo 	__((	IGRshort Product ,
					 struct GRid *CmpId ,
					 IGRint CmpType ,
					 IGRdouble *GivenPt ,
					 struct GRmd_env *md_env ,
					 IGRshort *CptNum ,
					 IGRdouble *CptPtCoord ,
					 IGRdouble *CptAxis ,
					 IGRdouble *OrientAxis ,
					 struct GRid *ActParamId ,
					 struct GRid *NewActParamId ));
extern int VRGetCCompInfo 	__((	IGRshort Product ,
					 struct GRid *CmpId ,
					 IGRdouble *GivenPt ,
					 struct GRmd_env *md_env ,
					 IGRshort *CptNum ,
					 IGRdouble *CptPtCoord ,
					 IGRdouble *CptAxis ,
					 IGRdouble *OrientAxis ,
					 struct GRid *ActParamId ,
					 struct GRid *NewActParamId ));
extern int VRDisplayCorrection 	__((	struct GRid *SegId ,
					 struct GRid *CmpId ,
					 struct GRmd_env *md_env ));
extern int VRSkGetCorVirtualSupport 
				__((	struct GRid *LocatedId ,
					 IGRdouble *SplitPt ,
					 struct GRmd_env *md_env ,
					 struct GRid *SegId ));
extern int VRGetCptNum_GivenCptCoord 
				__((	IGRlong *p_retmsg ,
					 struct GRid *p_CompId ,
					 IGRdouble *p_GivenPt ,
					 IGRshort *p_CptNum ,
					 struct GRmd_env *p_MdEnv ));
extern IGRint VRget_axis 	__((	IGRdouble *cur_pt ,
					 IGRdouble *origin ,
					 IGRdouble *normal ,
					 IGRdouble *y_axis ));
extern IGRint PointViewDependant __((	IGRdouble *dPoint ,
					 IGRdouble *dMatrix ,
					 IGRdouble *dNormal ,
					 IGRdouble *dOrig ));
extern int VRDisplayHvacOrientTee __((	IGRdouble *dOrigin ,
					 IGRdouble *dXaxis ,
					 IGRdouble *dYaxis ,
					 struct IGRdisplay *display ,
					 struct GRmd_env *pMdEnv ));

/* VRsplitnet.I */
extern int VRSplitNetwork 	__((	IGRlong *msg ,
					 struct GRid *component_id ,
					 struct GRmd_env *md_env ));
extern int VRdisconnect 	__((	IGRint *msg ,
					 struct GRid *seg1 ,
					 struct GRid *seg2 ,
					 struct GRmd_env *md_env ));
extern int VRget_connected 	__((	struct GRid *seg ,
					 struct GRid *seg1 ,
					 struct GRid *common ,
					 int ncom ,
					 struct GRid **p_connected ,
					 int *p_ncon ,
					 struct GRid **p_plane ,
					 int *p_nplane ,
					 struct GRmd_env *md_env ));

/* VRsym_cache.I */
extern int VRget_cache_attr 	__((	struct GRid *my_model ,
					 int num_pts ,
					 struct VRcp_attr *attr ));
extern int VRget_cp_attr 	__((	struct GRid *my_model ,
					 IGRshort nCpNum ,
					 struct VRcp_attr *attr ));
extern int VRget_cache_pnts 	__((	struct GRid *my_model ,
					 int *num_pts ,
					 IGRdouble *cpt_geom ,
					 struct GRmd_env *md_env ));
extern int VRnum_cpts 		__((	char *mac_name ,
					 int *num_pts ));
extern IGRint VRGetGeom 	__((	struct GRid *pGraphicsId ,
					 IGRint CpFrom ,
					 IGRint CpTo ,
					 IGRdouble *dCpCoors ,
					 struct GRmd_env *md_env ));
extern int VRedit_macro 	__((	char *mac_name ,
					 int num_up ,
					 struct GRid *temp_GRid ,
					 int *rep_test ,
					 struct GRmd_env *md_env ));
extern IGRint VRtest_macro 	__((	char *mac_name ,
					 int num_up ,
					 struct GRid *temp_GRid ,
					 int *failed_num ,
					 char ***failed_names ,
					 struct ret_struct **failed_default ,
					 struct GRmd_env *md_env ));
extern IGRint VRExtractExpStr 	__((	IGRlong *msg ,
					 IGRint NbObjs ,
					 IGRchar **ObjNames ,
					 struct ret_struct *ObjStr ,
					 IGRint *NbExps ,
					 struct ACrg_coll *ExpStr ));
extern IGRint VRGetTempNames 	__((	char *mac_name ,
					 int *NbTemp ,
					 IGRchar *TempNames []));
extern IGRint VRCptEncode 	__((	IGRint   nCP,
                                        IGRchar *szStr,
                                        IGRchar *szAdd));

/* ci_kludge.I */

extern kl_int_cnst 		__((	struct GRvg_construct *cst,
					 struct IGRdisplay *dis ));

/* This function would return the Common Correction Entity given the Line 
Segment. Alwin while implementing CR179900493 */
extern IGRlong VRGetCorrectionFromLineSeg __(( 
					    struct GRid lineSegId, 
					    struct GRid *CommonCorrId ));

extern IGRlong VRUpdate_ACST_User_Param __(( 
						IGRchar		*form_ptr,
						struct GRid	*UserParamId,
						struct GRid	*SysParamId ));

extern IGRlong VRCopyDuctParams 	__(( 
						IGRlong		*msg,
						struct GRid	*DuctId ));

extern IGRlong VRPGetInsulThkFromType 	__(( 
						Form		form_ptr,
						IGRint		gadget_label,
						IGRchar		*insul_type ));

extern IGRlong VRCopyPipeParams 	__(( 
						IGRlong		*msg,
						struct GRid	*PipeId ));

extern IGRlong VRFillUpNozzleAttrForm 	__(( 
						Form		form_ptr,
						IGRshort	Product,
						struct GRid	SysId ));

/* Prototype for VRkeyFltrInCDLdbFlds function (implemented in
 * vrtools/VRlibfunk.I) added by Anand for ETL 3825 */
extern IGRint VRkeyFltrInCDLdbFlds	__((	IGRshort	Product,
						IGRshort	ListNum,
						Form		FormPtr,
						IGRint		GadgetLbl,
						IGRuchar	*FldTxt ));

