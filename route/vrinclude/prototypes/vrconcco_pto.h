/* $Id: vrconcco_pto.h,v 1.1.1.1 2001/01/04 21:12:56 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrconcco_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrconcco_pto.h,v $
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
 * Revision 1.2  1996/01/17  00:34:46  pinnacle
 * Replaced: vrinclude/prototypes/vrconcco_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:49:50  pinnacle
 * Created: vrinclude/prototypes/vrconcco_pto.h by tlbriggs for route240
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
#include "igr.h"
#include "gr.h"
#include "igrtypedef.h"


/* VRCCVerify.I */

/* VRCCompCons.I */

/* VRCCompInfo.I */

/* VRCCompMod.I */

/* VRCCompOver.I */

/* VRCCompfunk.I */
extern int VRBuildTemp 		__((	IGRlong *retmsg ,
					 struct GRid *CompId ,
					 IGRint TopoIdsSize ,
					 struct GRid *TopoIds ,
					 IGRint IndexTableSize ,
					 IGRshort *IndexTable ,
					 struct GRmd_env *md_env ,
					 IGRint *NbPlanes ));
extern int VRMatchConstPlanes 	__((	IGRlong *retmsg ,
					 IGRint NbCpts ,
					 struct GRid *TopoIds ,
					 IGRshort *IndexTable ,
					 struct GRmd_env *md_env ));

/* VRCConcLoc.I */
