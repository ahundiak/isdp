/* $Id: vrcompon_pto.h,v 1.1.1.1 2001/01/04 21:12:56 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrcompon_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrcompon_pto.h,v $
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
 * Revision 1.2  1996/01/17  00:34:40  pinnacle
 * Replaced: vrinclude/prototypes/vrcompon_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:49:44  pinnacle
 * Created: vrinclude/prototypes/vrcompon_pto.h by tlbriggs for route240
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
#include "ACrg_collect.h"



/* VRCompDel.I */

/* VRCompInfo.I */

/* VRCompLoc.I */

/* VRCompMod.I */

/* VRCompOver.I */

/* VRCompVerify.I */

/* VRfunk.I */
extern IGRint VRGetNodes 	__((	IGRlong *msg ,
					 IGRint ind_cmp ,
					 IGRint *list_len ,
					 struct GRid **cmp_list ,
					 IGRint *nb_cmp ,
					 GRclassid LeavesClassId ));
