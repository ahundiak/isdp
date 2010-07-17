/* $Id: vrplane_pto.h,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrplane_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrplane_pto.h,v $
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
 * Revision 1.2  1996/01/17  00:37:14  pinnacle
 * Replaced: vrinclude/prototypes/vrplane_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:51:34  pinnacle
 * Created: vrinclude/prototypes/vrplane_pto.h by tlbriggs for route240
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


/* VRDepPlanei.I */

/* VRplaneVer.I */

/* VRplanei.I */

extern VRmatpoint 		__((	IGRlong *p_msg,
					 IGRmatrix matrix,
					 IGRpoint point,
					 IGRpoint res_point,
					 IGRdouble last_value ));
extern disp_dummy_plan 		__((	IGRlong *p_msg,
					IGRdouble origin[],
					IGRdouble vector[],
					 enum GRdpmode mode,
					 struct DP_information *sp_info ));
extern VRplan_matrix 		__((	IGRlong *p_msg,
					 IGRdouble origin[],
					 IGRdouble vector[],
					 IGRdouble matrix[] ));
  
/* VRplanetmp.I */
