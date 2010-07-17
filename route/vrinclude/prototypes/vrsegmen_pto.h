/* $Id: vrsegmen_pto.h,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrsegmen_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrsegmen_pto.h,v $
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
 * Revision 1.2  1996/01/17  00:37:32  pinnacle
 * Replaced: vrinclude/prototypes/vrsegmen_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:51:58  pinnacle
 * Created: vrinclude/prototypes/vrsegmen_pto.h by tlbriggs for route240
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

/* VRCSVerify.I */

/* VRCnrlSegi.I */

/* VRassoc_over.I */

/* VRcsfunk.I */
extern int VRget_segment_geom 	__((	IGRint *retcode ,
					 struct IGRplane plane [],
					 IGRdouble *pt1 ,
					 IGRdouble *pt2 ));
extern int VRget_segment_to_notify 	
				__((	IGRlong *p_retmsg ,
					 IGRint nb_sup ,
					 struct GRid *list_sup ,
					 struct GRid *seg_id ,
					 struct GRid *not_seg ,
					 struct GRmd_env *md_env ,
					 IGRboolean *Merge ));
extern int VRGetAttrFromCpt 	__((	IGRshort product ,
					 IGRshort cmp_index ,
					 IGRdouble *section_matrix ,
					 struct GRid *cmp_param_id ,
					 struct GRid *user_param_id ,
					 struct GRid *cmp_id ,
					 struct GRid *seg_id ,
					 struct GRmd_env *md_env ));

/* VRgraph_over.I */

