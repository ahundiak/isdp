/* $Id: vrco_pto.h,v 1.1.1.1 2001/01/04 21:12:56 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrco_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrco_pto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:56  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.3  1996/03/19  19:55:12  pinnacle
 * Replaced: vrinclude/prototypes/vrco_pto.h for:  by hverstee for route240
 *
 * Revision 1.2  1996/01/17  00:34:36  pinnacle
 * Replaced: vrinclude/prototypes/vrco_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:49:40  pinnacle
 * Created: vrinclude/prototypes/vrco_pto.h by tlbriggs for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/11/96   tlb		created
 *	01/12/96   tlb		Add include files, externs
 *
 *************************************************************************/
#include <standards.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "ex.h"
#include "dpstruct.h"
#include "parametric.h"
#include "VRdimdef.h"
#include "VRco.h"
#include "ACrg_collect.h"


/* VRCOHvaci.I */

/* VRCOPFunc1i.I */
extern IGRint VRGetShapeString 	__((	IGRint Code ,
					 IGRchar *szCode ));
extern IGRint VRGetShapeCode 	__((	IGRchar *szCode ,
					 IGRint *Code ));
extern IGRint VRUpdateGeometry 	__((	IGRlong *msg ,
					 struct tagCompSegDesc *pCompSegDesc ,
					 struct GRid *pCompId ,
					 struct GRmd_env *pMdEnv ));
extern int VRBuildUserFromForm 	__((	IGRchar *form_ptr ,
					 IGRint gadget_label ,
					 struct GRid *UserId ,
					 struct GRid *MissId ));
extern int VRIsTopoCompatible 	__((	IGRshort nProduct ,
					 IGRshort nTopoLocated ,
					 IGRshort nTopoNew ));
extern int VRSpecialCorrectionProcessing 	
				__((	IGRlong *msg ,
					 IGRint TopoReturnCode ,
					 struct GRid *SupportId ,
					 struct GRid *CompId ,
					 struct GRmd_env *MdEnv ));
extern int VRUndisplayComponent	__((	struct GRid *CompId ,
					 struct GRmd_env *MdEnv ));
extern int VRProcessingMessage 	__((	void ));
extern int VRBlankMessage 	__((	void ));
extern int VRCircularTreatment 	__((	IGRshort nProduct ,
					 struct GRid *FormSysParamId ,
					 struct GRmd_env *MdEnv ));
extern int VRUpgradeUserForm 	__((	IGRchar *form_ptr ,
					 IGRint NbColl ,
					 struct GRid *CollId ,
					 IGRint gadget_label ));
extern int VRGetOptionCode 	__((	IGRlong *retmsg ,
					 IGRchar *AABBCCcode ,
					 struct GRid *ParamId ,
					 IGRint gadget_label ,
					 IGRchar *FormPtr ,
					 struct GRmd_env *MdEnv ));

/* VRCOPFunc2i.I */
extern IGRint VRCheckSupportOrientation 	
				__((	IGRlong *msg ,
					 struct GRid *pCompId ,
					 IGRdouble *dOrientationVector ,
					 struct GRmd_env *pMdEnv ));
extern IGRint VRGetParamBoxClone 	__((	IGRlong *msg ,
					 struct GRid *ParamBox ,
					 struct GRid *ParamBoxCopy ));
extern IGRint VRTrimRightLeftSpace 	__((	IGRchar *szStringIn ));
extern IGRint VRGetLocatedPocketMenuName 	
					__((	IGRshort nProduct ,
					 IGRint nCompType ,
					 IGRint nCompTopo ,
					 IGRchar *PocketMenuName ));

/* VRCOPFunc3i.I */
extern int VRUpdateParameterBox 	__((	IGRlong *msg ,
					 struct ACrg_coll *Collection ,
					 struct GRid *ParameterBoxId ));
extern IGRint VRCheckReducingConsistency 	
					__((	IGRshort nProduct ,
					 struct GRid *ParamBoxId ,
					 struct GRmd_env *pMdEnv ));
extern IGRint VRGetSpecialInformations 	__((	IGRlong *msg ,
					 IGRshort *nCompTopo ,
					 IGRshort *nCompType ,
					 struct GRid *CompId ,
					 struct GRmd_env *MdEnv ));

extern IGRint VREqualSizeForce __((IGRshort    nProduct,
                            struct GRid       *ParamBoxId,
                            struct GRmd_env   *pMdEnv));

/* VRCOPipingi.I */

/* VRCOProduc1i.I */

/* VRCOProduc2i.I */

/* VRCOProduc3i.I */

/* VRCORwayi.I */

/* VRCmpMgri.I */

/* VRHReplacei.I */

/* VRHvFrPli.I */

/* VRLnDynamic.I */
extern IGRint VRBlinear 	__((	IGRdouble *LastPt ,
					 struct IGRdisplay *display ));

/* VRNReplacei.I */

/* VROrienti.I */

/* VRPReplacei.I */

/* VRPidPasCmdi.I */

/* VRPlHangeri.I */

/* VRPlNozzlei.I */

/* VRRReplacei.I */

/* VRUpEvent.I */
extern IGRint VRUpdateEvent 	__((	IGRlong *sts ,
					 IGRdouble *Point ,
					 struct GRevent *Event ));

/* VRfunc.I */
extern IGRint VRTestCmpPosition __((	struct GRid *CmpId ,
					 IGRint NbCpts ,
					 IGRint NbSupports ,
					 IGRdouble *SupDirection ,
					 IGRboolean *Flag ,
					 struct GRmd_env *MdEnv ));
extern IGRint VRGetCmpInfo 	__((	IGRlong *msg ,
					 IGRchar *szCode ,
					 IGRchar *szNumber ,
					 IGRchar *szNotes ,
					 IGRshort *nOption ,
					 struct GRid *CmpId ,
					 struct GRmd_env *MdEnv ));
extern IGRint VRGetCmpType 	__((	IGRlong *msg ,
					 IGRshort *nCompType ,
					 struct GRid *CompId ,
					 struct GRmd_env *MdEnv ));
	/* VRIsCmpOrientable - declared in VRcptmacros.h */
extern IGRint VRResetTagNum 	__((	struct GRid *CmpId ));

/* func.I */
extern int VRUpdOrAddAttr 	__((	struct GRid *CollId ,
					 struct GRid *SysId ,
					 struct GRid *UserId ,
					 struct GRid *MissId ));
