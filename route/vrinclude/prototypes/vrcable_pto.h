/* $Id: vrcable_pto.h,v 1.1.1.1 2001/01/04 21:12:56 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrcable_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrcable_pto.h,v $
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
 * Revision 1.2  1996/01/17  00:33:42  pinnacle
 * Replaced: vrinclude/prototypes/vrcable_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:49:12  pinnacle
 * Created: vrinclude/prototypes/vrcable_pto.h by tlbriggs for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/11/96   tlb		created
 *	01/12/96   tlb		Add include files
 *
 *************************************************************************/
#include <standards.h>
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "parametric.h"

/* VRcabchabrad.I */

/* VRcabdelbrad.I */

/* VRcabgetprop.I */

extern ang_v1v2 	__((	IGRdouble *v1,
				IGRdouble *v2,
				IGRdouble *vz,
				IGRdouble *angle ));
extern int eval_length 	__((	 IGRlong *msg,
				 IGRdouble *btable,
				 struct GRid GO_STR,
				 struct GRmd_env *md_env,
				 IGRdouble *tot_length ));
/* VRcabinsbrad.I */

/* VRcable_gr.I */

/* VRcablei.I */

extern int inspect_line __((	IGRlong *msg,
				 IGRdouble *iline,
				IGRint npts,
				IGRdouble *oline,
				IGRdouble brad,
				struct ret_struct ref_st1,
				struct ret_struct ref_st2 ));
