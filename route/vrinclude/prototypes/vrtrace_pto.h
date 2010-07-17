/* $Id: vrtrace_pto.h,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrtrace_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrtrace_pto.h,v $
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
 * Revision 1.2  1996/01/17  00:38:16  pinnacle
 * Replaced: vrinclude/prototypes/vrtrace_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:52:14  pinnacle
 * Created: vrinclude/prototypes/vrtrace_pto.h by tlbriggs for route240
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


/* GMndg.C */
extern int GMndg_activate 	__((	int modulo ,
					 int size ,
					 struct GMndgraph *p_graph ));
extern int GMndg_disactivate 	__((	struct GMndgraph *p_graph ));
extern int GMndg_clear 		__((	struct GMndgraph *p_graph ));
extern int GMndg_depth_first 	__((	struct GMndgraph *p_graph ,
					 struct GRid *p_object ));
extern int GMndg_getgraph 	__((	struct GRid *l_root ,
					 int nb_root ,
					 int (*f_get_connex )(),
					 char *p_connex_info ,
					 struct GMndgraph *p_graph ));

/* VRtrace.I */
extern int VRget_connect 	__((	struct GRid *p_object ,
					 struct GRmd_env *p_md_env ,
					 struct GRid **pl_connect ,
					 int *p_nb_connect ));
extern int VRget_allow_connect 	__((	struct GRid *p_object ,
					 struct VRgrinfo *p_info ,
					 struct GRid **pl_connect ,
					 int *p_nb_connect ));

