/* $Id: vrprdcmp_pto.h,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrprdcmp_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrprdcmp_pto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
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
 * Revision 1.2  1996/01/17  00:37:20  pinnacle
 * Replaced: vrinclude/prototypes/vrprdcmp_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:51:40  pinnacle
 * Created: vrinclude/prototypes/vrprdcmp_pto.h by tlbriggs for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/11/96   tlb		created
 *	01/12/96   tlb		Add include files,
					 externs
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
#include "VRStSect.h"


/* VRHCCgive.I */

/* VRHCCinfo.I */

/* VRHCgive.I */

/* VRHCinfo.I */

/* VRHNinfo.I */

/* VRPCCgive.I */

/* VRPCCinfo.I */

/* VRPCgive.I */

/* VRPCinfo.I */

/* VRPNinfo.I */

/* VRPreDrop.I */
extern IGRint VRRepPreDropRes 	__((	struct VRSection *pSection ,
					 IGRint NbSections ,
					 IGRchar *pcFileName ,
					 struct GRmd_env *pMdEnv ));
extern IGRint VREquiDiam 	__((	IGRint Shape ,
					 IGRdouble dWidth ,
					 IGRdouble dDepth ,
					 IGRdouble *dEquiDiam ));
extern IGRint VRWriteSectHeader	__((	FILE *FilePtr ,
					 IGRint Section ));
extern IGRint VRWriteSectTerminator 	
				__((	FILE *FilePtr ));
extern IGRint VRWriteSectError 	__((	FILE *FilePtr ));
extern IGRint VRWritePDHeader 	__((	FILE *FilePtr ));
extern double VRGetVelPre 	__((	IGRdouble dVelocity ));
extern IGRint VRCalPreDrop 	__((	struct GRid *pCmpId ,
					 IGRshort nCptNum ,
					 IGRdouble *pdPreDrop ,
					 struct GRmd_env *pMdEnv ));

/* VRRCCinfo.I */

/* VRRCinfo.I */

/* VRRNinfo.I */

/* VRSection.I */
extern IGRint VRGetSections 	__((	struct GRid *pStartCmp ,
					 IGRshort nStartCpt ,
					 struct VRSection *pSection ,
					 IGRint *pIndex ,
					 struct GRmd_env *pMdEnv ));
extern IGRint VRGetSectCmps 	__((	struct GRid *pStartCmp ,
					 IGRshort nStartCpt ,
					 struct GRid *pEndCmp ,
					 IGRshort nEndCpt ,
					 struct GRid *pCmpIds ,
					 IGRint *pNbCmps ,
					 struct GRmd_env *pMdEnv ));
extern IGRboolean VRProcessCmp 	__((	struct GRid *pCmpId ,
					 IGRshort nCpt ,
					 IGRboolean bIsStart ,
					 struct GRmd_env *pMdEnv ));
extern IGRint VRGetSectInfo 	__((	struct VRSection *pSection ,
					 IGRint NbSections ,
					 struct VRSectInfo *pSectInfo ,
					 struct GRmd_env *pMdEnv ));
extern IGRboolean VRCheckCptAttr __((	struct VRcp_attr *pRefCptAttr ,
					 struct VRcp_attr *pCptAttr ,
					 IGRboolean bTwist ));
extern IGRboolean VRIsTwisted 	__((	struct GRid *pRefId ,
					 IGRshort nRefCpt ,
					 struct GRid *pCmpId ,
					 IGRshort nCmpCpt ,
					 struct GRmd_env *pMdEnv ));

/* VRWriteRes.I */
