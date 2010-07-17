/* $Id: vrconstr_pto.h,v 1.1.1.1 2001/01/04 21:12:56 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrconstr_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrconstr_pto.h,v $
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
 * Revision 1.2  1996/01/17  00:35:00  pinnacle
 * Replaced: vrinclude/prototypes/vrconstr_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:50:00  pinnacle
 * Created: vrinclude/prototypes/vrconstr_pto.h by tlbriggs for route240
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
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "ex.h"
#include "dpstruct.h"
#include "parametric.h"
#include "ACrg_collect.h"


/* VRcompointi.I */

/* VRconci.I */

/* VRcons_node.I */

/* VRcons_solve.I */
extern int ASplane_set_equation __((	double *coef ,
					 struct GRid *plane ,
					 struct GRmd_env *md_env ));
extern int ASplane_get_equation __((	double *coef ,
					 struct GRid *plane ,
					 struct GRmd_env *md_env ));

/* VRconsdisti.I */

/* VRconsi.I */
extern VRstart_modify 		__((	void ));
extern int VRend_modify 	__((	void ));
extern int VRreturn_solver 	__((	struct GRid *solver ,
					 GRspacenum osnum ));

/* VRsimp_old.C */
extern int VRsimplex_old 	__((	int nb_unkn ,
					 int nb_constr ,
					 double *matrix ,
					 double *vector ));
extern int find_col 		__((	double matrix [],
					 int nb_constr ,
					 int nb_col ,
					 int row_pivot ,
					 int *l_elig ,
					 int *p_index ));
extern int find_row 		__((	double matrix [],
					 int nb_constr ,
					 int nb_col ,
					 int col_pivot ,
					 int *l_elig ,
					 int *p_index ));
extern int find_random 		__((	int max_value ));
extern int pivot 		__((	double array [],
					 int nb_constr ,
					 int nb_column ,
					 int row_pivot ,
					 int col_pivot ));

/* VRsimplex.C */
extern int determination_an 	__((	double a [],
					 double *cn ,
					 int *n_base ,
					 double *an ,
					 int m ,
					 int n ));
extern int cout_reduit 		__((	double *d ,
					 double *an ,
					 double *cb ,
					 double *cn ,
					 int m ,
					 int n ,
					 int *probleme ,
					 int *s ,
					 double *pi ,
					 double *pi_bar ,
					 double *cn_bar ));
extern int rentre 		__((	double a [],
					 double *d ,
					 double *b_bar ,
					 double *as_bar ,
					 int *s ,
					 int m ,
					 int n ,
					 int *r ,
					 int *n_base ));
extern int change 		__((	double *d ,
					 double *b_bar ,
					 double *as_bar ,
					 int *r ,
					 int *s ,
					 int n ,
					 int *base ,
					 int *n_base ,
					 double *cb ,
					 double *cn ,
					 int *probleme ,
					 double *db ));
extern int VRsimplex 		__((	int nb_unkn ,
					 int nb_constr ,
					 double *Matrix ,
					 double *vector ));

