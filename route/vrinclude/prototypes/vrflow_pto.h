/* $Id: vrflow_pto.h,v 1.1.1.1 2001/01/04 21:12:56 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vrflow_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrflow_pto.h,v $
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
 * Revision 1.2  1996/01/17  00:35:32  pinnacle
 * Replaced: vrinclude/prototypes/vrflow_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:50:38  pinnacle
 * Created: vrinclude/prototypes/vrflow_pto.h by tlbriggs for route240
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
#include "GMlist.h"
#include "ACrg_collect.h"
#include "VRsize.h"



/* VRExpKludge.I */
extern VRconcatenate_down 		__((struct GRid parent_in ,
						 char *down_in ,
						struct GRid *parent_out ,
						char *down_out ));
extern int VRfind_cons_condit 		__((	struct GRid *occ ,
						 struct GRid *condit ,
						struct GRid *cons_condit ));
extern int VRparent_in_feet 		__((	char *down_in ,
						 struct GRid macro_in ,
						struct GRid *parent_out ,
						struct GRid *macro_out ,
						char *down_out ));
extern int VRparent_in_template 	__((	struct GRid macro_in ,
						 int index ,
						char *downscan ,
						struct GRid *parent_out ,
						struct GRid *macro_out ,
						char *down_out ));
extern int VRretrieve_real_parent 	__((	struct GRid parent_in ,
						 struct GRid macro_in ,
						char *down_in ,
						struct GRid *parent_out ,
						struct GRid *macro_out ,
						char *down_out ));
extern int VRgive_formula 		__((	struct GRid *occurence ,
						 char *name ,
						char *formula ,
						int len ));
extern int VRgive_recursive_formula 	__((struct GRid parent_in ,
						struct GRid macro_in ,
						char *formula ,
						int len ));

/* VRWriteHdTl.C */
extern IGRint VRWriteNozResInfoHdr 	__((	void ));
extern IGRint VRWriteNozResInfoTail 	__((	void ));

/* VRflow.I */
extern int VRget_diconnect 		__((	struct GRid *p_object ,
						 struct VRgrinfo *p_info ,
						struct GRid **pl_connect ,
						int *p_nb_connect ));
extern int VRcompute_flow 		__((	struct GRid *p_object ,
						 struct VRgrinfo *p_info ));
extern int VRdisplay_elmt 		__((	struct GRid *p_object ,
						 struct VRgrinfo *p_info ));
extern int VRinject_flow 		__((	struct GRid *p_object ,
						 struct GRmd_env *p_md_env ));
extern IGRint VRSetCorCmpFlow 		__((	struct GRid *p_object ,
						 struct VRgrinfo *p_info ));
extern IGRint VRcheck_database 		__((	struct GRid *p_object ,
						 struct VRgrinfo *p_info ));

/* VRinterf.I */
extern int VRret_database 		__((	char *filename_a ,
						 struct GMlist *p_data_list ));
extern int VRget_resinfo 		__((	struct GRid *p_object ,
						 int cpt_ind ,
						struct GRmd_env *p_md_env ,
						struct VRres_info *p_resinfo ,
						IGRboolean *call_wrt_equa ));
extern int VRis_outlet 			__((	struct GRid *p_object ,
						 struct GRmd_env *p_md_env ,
						int *p_resp ));
extern int VRstore_flow 		__((	struct GRmd_env *p_md_env ,
						 IGRshort index ,
						IGRshort *p_direct ,
						double *p_flow ,
						struct GRid *p_object ));

/* VRsize.I */
extern int VRfind_value 		__((	struct VRres_info *p_spec ,
						 struct sim_havcdb *p_base ,
						struct COdatab_hvac *p_data ));
extern int VRget_fixobj 		__((	struct GRid *p_object ,
						 struct VRgrinfo *p_info ,
						struct GRid **pl_connect ,
						int *p_nb_connect ));
extern IGRint VRmodify_body 		__((	struct GRid *p_object ,
						 struct VRgrinfo *p_info ));
extern int VRadd_batch 			__((	struct GRid *p_object ,
						 struct VRgrinfo *p_info ));
extern IGRint VREquiDiamFV 		__((	IGRdouble dAirFlow ,
						 IGRdouble dVelocity ,
						IGRdouble *dEquiDiam ));
extern IGRint VREquiDiamWD 		__((	IGRdouble dWidth ,
						 IGRdouble dDepth ,
						IGRdouble *dEquiDiam ));
extern IGRint VRUpdSegLength 		__((	struct GRid *p_object ,
						 struct VRgrinfo *p_info ));

/* VRsolve.I */
extern int VRwrite_equation 		__((	IGRshort index ,
						 char *attr_name ,
						double value ,
						struct GRid *p_object ,
						char equation []));
extern int VRsplit_equation 		__((	char equation [],
						 char identifier [],
						double *p_value ));
extern int VRsolve_equation 		__((	int nb_maxunkn ,
						 int nb_equa ,
						char *l_equa [],
						int *p_nb_unkn ));
extern int VRinit_solver 		__((	int nb_unkn ,
						 int nb_equa ,
						struct VRslv_inf *p_solver ));
extern int VRupdate_solver 		__((	int nb_unkn ,
						 int nb_equa ,
						struct VRslv_inf *p_solver ));
extern int VRfree_solver 		__((	struct VRslv_inf *p_solver ));
extern int VRgive_index 		__((	char name [],
						 struct VRslv_inf *p_solver ,
						int *p_index ));
extern int VRadd_in_mat 		__((	double value ,
						 struct VRslv_inf *p_solver ,
						int index ));
extern int VRnumber 			__((	char string []));
extern int VRconst_formula 		__((	char formula []));
extern int VRparse_linear 		__((	char equa [],
						 struct VRslv_inf *p_solver ));
extern int VRclean_string 		__((	char string [],
						 char l_char []));
extern int VRcmp_name 			__((	struct VRind_name *p_ext_key ,
						 struct VRind_name *p_int_key ));

