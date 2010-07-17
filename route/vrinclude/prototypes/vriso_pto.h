/* $Id: vriso_pto.h,v 1.1.1.1 2001/01/04 21:12:56 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes / vriso_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vriso_pto.h,v $
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
 * Revision 1.4  1996/04/22  13:27:26  pinnacle
 * Replaced: vrinclude/prototypes/vriso_pto.h for:  by hverstee for route240
 *
 * Revision 1.3  1996/01/18  20:03:00  pinnacle
 * Replaced: vrinclude/prototypes/vriso_pto.h for:  by r240_int for route240
 *
 * Revision 1.2  1996/01/17  00:36:16  pinnacle
 * Replaced: vrinclude/prototypes/vriso_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:51:02  pinnacle
 * Created: vrinclude/prototypes/vriso_pto.h by tlbriggs for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/11/96   tlb		created
 *	01/12/96   tlb		Add include files, externs
 *	01/18/96   tlb		Fix print_big_file prototype
 *
 *************************************************************************/
#include <standards.h>
#include "FI.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"		/* struct GRfunction_info */
#include "ex.h"
#include "dpstruct.h"
#include "parametric.h"
#include "ACrg_collect.h"


/* VRiso_fn.I */
extern int ISOinit_main 	__((	struct ISOform *isoform ));
extern int ISOinit_sub 		__((	struct ISOform *isoform ));
extern int ISOdefault_sub 	__((	int index ,
					 struct ISOform *isoform ));
extern int ISOupdate_main 	__((	Form form_ptr ,
					 struct ISOform *ISOattributes ));
extern int ISOupdate_sub 	__((	Form form_ptr ,
					 struct ISOform *ISOattributes ));

/* VRisoi.I */

/* VRtri_fn.I */
extern int TRIFLEXinit 		__((	struct ISOform *isoform ));
extern int TRIdefault 		__((	int index ,
					 struct ISOform *isoform ));
extern int TRIFLEXupdate 	__((	Form form_ptr ,
					 struct ISOform *TRIattributes ));

/* VRtriflexi.I */

/* db_ac.I */
extern int genentp 		__((	long *msg ,
					 struct GRid obj ,
					 struct buff_attr *buff_attr ,
					 int cur_occ ,
					 char *red_cp ,
					 struct GRid *cmp_err ));
extern int print_buff_attr 	__((	char *file_name ,
					 struct buff_attr *buff_attr ));
extern int buff_attr_init 	__((	struct buff_attr *buff_attr ,
					 int nb_lines ));
extern int buff_attr_dealloc 	__((	struct buff_attr *buff_attr ));

/* fill_big.I */
extern int TRIfill_big 		__((	long *msg ,
					 struct ISOcriter *criteria ,
					 short *node_number ,
					 int *nb_big ,
					 int *size_big ,
					 short **big ,
					 char *file ,
					 char *def ,
					 struct GRid *cmp_err ));
extern int ISfill_big 		__((	long *msg ,
					 struct ISOcriter *criteria ,
					 short *node_number ,
					 int *nb_big ,
					 int *size_big ,
					 short **big ,
					 char *file ,
					 char *seed ,
					 char *def ,
					 struct GRid *cmp_err ));
extern int ISfill_or_not 	__((	long *msg ,
					 struct GRid cmp ,
					 IGRboolean *yes ,
					 struct GRid *cmp_err ));
extern int ISfill_big_cmp 	__((	long *msg ,
					 struct GRid cmp ,
					 int occ ,
					 int *occ3000 ,
					 int *nb_big ,
					 int *size_big ,
					 short **big ,
					 struct GRid *cmp_err ));
extern int ISfill_big_con 	__((	long *msg ,
					 int frm ,
					 int to ,
					 short *node_number ,
					 int *nb_big ,
					 short *big ,
					 struct GRid *dash_cmp ,
					 int *nb_dash ,
					 int *con_flag ,
					 int triflex_flag ,
					 struct GRid *cmp_err ));
extern int ISget_cp_con 	__((	long *msg ,
					 struct GRid cmp ,
					 int *cp_con_number ,
					 int ncp_number ));
extern int ISget_cmp_cp_index 	__((	long *msg ,
					 struct GRid cmp ,
					 int cp_number ,
					 int nb_big ,
					 short *big ,
					 int frm ,
					 int to ,
					 int *index ));
extern int ISfill_big_attr 	__((	long *msg ,
					 int frm ,
					 int to ,
					 int nb_big ,
					 short *big ,
					 struct GRid *cmp_err ));
extern int ISfill_noz 		__((	long *msg ,
					 int frm ,
					 int to ,
					 int nb_big ,
					 short *big ));
extern int set_big 		__((	short *big ,
					 int row ,
					 int line ,
					 int col ,
					 int nb_word ,
					 short *attr_val ));
extern int set_big_mask 	__((	short *big ,
					 int row ,
					 int line ,
					 int col ,
					 short *attr_val ,
					 int mask ));
extern int get_big 		__((	short *big ,
					 int row ,
					 int line ,
					 int col ,
					 int nb_word ,
					 short *attr_val ));
extern int ISbig_alloc 		__((	long *msg ,
					 int nb_obj ,
					 int nb_big ,
					 int *size_big ,
					 short **big ));
extern int ISfill_ilks 		__((	long *msg ,
					 short *big ,
					 int line ,
					 short *ilks ,
					 struct GRid *cmp_err ));
extern int print_big 		__((	int frm ,
					 int to ,
					 short *big ));
extern int print_big1 		__((	int frm ,
					 int to ,
					 short *big ));
extern int print_big_file 	__((	long *msg ,
					 short **big,
					 int *nb_big ,
					 char *file_name ));
extern int ISget_cc 		__((	long *msg ,
					 struct ISOcriter *crit ,
					 int type ,
					 int *nb_cc ,
					 struct GRid **cc ));
extern IGRint ISvalid_cc 	__((	long *msg ,
					 struct GRid *obj ,
					 struct GRfunction_info *f_info ));
extern int ISshift 		__((	int value ,
					 int shift_nb ));
extern int big_dealloc 		__((	short **big ,
					 int nb_big ));

/* kick_iso.I */
extern int kick_iso 		__((	char *ems_pds ,
					 int nb_big ,
					 char *iso_name ,
					 int units ,
					 int triflex_flag ,
					 char *seed ,
					 char *def ));

