/* $Id: vrcorrec_pto.h,v 1.1.1.1 2001/01/04 21:12:56 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrcorrec_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrcorrec_pto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:56  cvs
 *	Initial import to CVS
 *	
 * Revision 1.3  1998/09/25  19:33:14  pinnacle
 * Replaced: vrinclude/prototypes/vrcorrec_pto.h for:  by apazhani for route
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
 * Revision 1.2  1996/01/17  00:35:12  pinnacle
 * Replaced: vrinclude/prototypes/vrcorrec_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:50:08  pinnacle
 * Created: vrinclude/prototypes/vrcorrec_pto.h by tlbriggs for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/11/96   tlb		created
 *	01/12/96   tlb		Add include files, externs
 *	09/11/98   Alwin	Added definition for function VR_ChkFlangeCmps
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
#include "ACrg_collect.h"
#include "VRstructs.h"
#include "VRpriv_attr.h"

/* VRCorrVerify.I */

/* VRCorrecti.I */

/* VRHCorentiti.I */

/* VRPCorentiti.I */
/* added by alwin for TR179701247 */
extern IGRint VR_ChkFlangeCmps  __((
                                         IGRlong *retmsg,
					 IGRlong HaveToCorrectCmp0,
					 IGRlong HaveToCorrectCmp1,
                                         IGRint  *my_state,
                                         IGRint  *NbCorCmp,
                                         IGRint  nFirstParentType,
                                         IGRint  nSecondParentType,
                                         struct  VRcp_attr ConProp0,
                                         struct  VRcp_attr ConProp1,
                                         union  VRparam_attr *Father0Params,
                                         union  VRparam_attr *Father1Params,
                                         union  VRparam_attr *PipeParams ));

/* VRRCorentiti.I */

/* VRassoc_over.I */

/* VRcor_funk.I */
extern IGRboolean verify 	__((	IGRint end_treat1 ,
					 IGRint end_treat2 ));
extern IGRboolean VRInsertValid 	__((	IGRshort *CmpCptIndex ,
					 struct GRid *CmpId ,
					 struct GRmd_env *md_env ));
extern int VRChgCorCmpAttrs 	__((	IGRlong *retmsg ,
					 IGRshort Product ,
					 struct GRid *CorCmpId ,
					 union VRparam_attr *CorCmpParams ,
					 IGRchar Representation ,
					 struct GRmd_env *md_env ));
extern int VRGetTempAttr 	__((	IGRlong *retmsg ,
					 IGRshort ProductName ,
					 struct GRid *CmpId ,
					 struct GRid *ActParamId ,
					 struct GRid *UserParamId ,
					 union VRparam_attr *FatherParams ,
					 struct GRmd_env *md_env ));
extern int VRGetCmpParams 	__((	IGRshort ProductName ,
					 IGRshort CmpName ,
					 union VRparam_attr *Pipe ,
					 union VRparam_attr *Father ,
					 union VRparam_attr *Cmp ));
extern int VRGetTransCode 	__((	IGRshort Shape1 ,
					 IGRshort Shape2 ,
					 IGRshort *TransCode ));

/* VRcordir.I */

/* VRgraph_over.I */
