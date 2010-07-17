/* $Id: vrproduc_pto.h,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrproduc_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrproduc_pto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  20:06:08  pinnacle
 * Replaced: vrinclude/prototypes/vrproduc_pto.h for:  by hverstee for route
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.2  1996/01/17  00:37:26  pinnacle
 * Replaced: vrinclude/prototypes/vrproduc_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:51:54  pinnacle
 * Created: vrinclude/prototypes/vrproduc_pto.h by tlbriggs for route240
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

/* VRHinfo.I */

/* VRPinfo.I */

/* VRRinfo.I */

/* VRTables.I */
extern IGRint VRcint_piping 	__((	IGRlong *msg ,
					 IGRshort item_num ,
					 IGRchar *AABBCCcode ));
extern IGRint VRcint_hvac 	__((	IGRlong *msg ,
					 IGRshort item_num ,
					 IGRchar *AABBCCcode ));
extern IGRint VRcint_rway 	__((	IGRlong *msg ,
					 IGRshort item_num ,
					 IGRchar *AABBCCcode ));

