/* $Id: vrpdu_pto.h,v 1.2 2001/01/22 16:24:01 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude/prototypes/vrpdu_pto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrpdu_pto.h,v $
 *	Revision 1.2  2001/01/22 16:24:01  anand
 *	SP merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:56  cvs
 *	Initial import to CVS
 *
 * Revision 1.1  2000/07/10  19:03:54  pinnacle
 * Created: route/vrinclude/prototypes/vrpdu_pto.h by apazhani for Service Pack
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.3  1997/12/05  21:01:06  pinnacle
 * Replaced: vrinclude/prototypes/vrpdu_pto.h for: AXFAN crash in 02.04.03.04 by aharihar for route
 *
 * Revision 1.2  1997/08/15  20:06:22  pinnacle
 * Replaced: vrinclude/prototypes/vrpdu_pto.h for:  by hverstee for route
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.3  1996/04/22  13:44:04  pinnacle
 * Replaced: vrinclude/prototypes/vrpdu_pto.h for:  by hverstee for route240
 *
 * Revision 1.2  1996/01/17  00:36:58  pinnacle
 * Replaced: vrinclude/prototypes/vrpdu_pto.h for:  by r240_int for route240
 *
 * Revision 1.1  1996/01/11  15:51:30  pinnacle
 * Created: vrinclude/prototypes/vrpdu_pto.h by tlbriggs for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/11/96   tlb		created
 *	01/12/96   tlb		Add include files, externs
 *	12/06/97   tlb		Add include files, externs
 *	07/10/00   Alwin	Added VRaccess_rway_noz_db
 *
 *************************************************************************/
#include <standards.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "ex.h"
#include "dpstruct.h"
#include "parametric.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
#include "VREquipment.h"


/* RISexec.c */
extern void VR_DbC_ClRIS 	__((	void ));

extern int RISexecute_query 	__((	char *ris_string ,
					 struct VRrisdat out_data [],
					 int *rows ,
					 int *cols ,
					 int *dat_cnt ));
extern int RISprepare_query 	__((	char *ris_string ,
					 int stmt_id ));
extern int RISexecute_query1 	__((	int stmt_idx ,
					 char inp_buf [10 ][20 ],
					 int inp_cnt ,
					 struct VRrisdat out_data [],
					 int *rows ,
					 int *cols ,
					 int *dat_cnt ));
extern int take_trailing_blanks_off 	
				__((	char *sqlstring ,
					 int sqllen ));

/* VREquipLst.c */
extern IGRint VRdbGetEqOccList 	__((	IGRlong *msg ,
					 IGRchar *catalog ,
					 IGRchar *select_crit ,
					 IGRchar **EqNumber ,
					 IGRint *NbOcc ,
					 struct VRdbEquipDesc *occlst ,
					 IGRchar *err_ptr ));
extern IGRint VRdbGetEqOccur 	__((	IGRlong *msg ,
					 IGRchar *catalog ,
					 IGRchar *select_crit ,
					 IGRchar *MacroName ,
					 struct VRdbEquipPart *occlst ,
					 IGRchar *err_ptr ));

/* VRHinfo.c */

/* VRdbCache.c */
extern int VR_DbC_Clear 	__((	void ));

extern void VRdbInitCacheIdx 	__((	void ));
extern int VRdbCheckCacheIndx 	__((	int index ,
					 int *value ,
					 char *string ));

/* VRdberrmsg.I */
extern int VRdb_err_msg 	__((	long msgnum ,
					 char *err_ptr ,
					 char *var1 ,
					 char *var2 ,
					 char *var3 ));

/* VRdbpb.I */
extern IGRint VRaccess_db_1 	__((	IGRlong *msg ,
					 IGRchar *spec_name ,
					 IGRchar *comp_name ,
					 IGRdouble size_1 ,
					 IGRdouble size_2 ,
					 IGRshort option ,
					 IGRchar *fam_name ,
					 IGRshort *comp_topo ,
					 IGRshort *comp_type ,
					 struct GRid *pbid ,
					 IGRchar *err_ptr ));
extern IGRint VRget_branch 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRchar *spec_name ,
					 IGRdouble size_1 ,
					 IGRdouble size_2 ,
					 IGRdouble angle ,
					 IGRint comp_type ,
					 IGRchar *comp_code ,
					 IGRchar *err_ptr ));

/* VRdbpid.c */
extern void VR_DbC_Clpid 	__((	void ));

extern IGRint VRdbGetPidSym 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRshort free_flg ,
					 IGRchar *code ,
					 IGRchar *macro ,
					 IGRchar *err_ptr ));
extern IGRint VRdbGetCompCat 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRchar *comp_code ,
					 IGRint *comp_cat ,
					 IGRint *comp_behvr ,
					 IGRchar *err_ptr ));

/* VRfunc.I */
extern IGRint VRget_straight 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRchar *spec_name ,
					 IGRchar *comp_code ,
					 IGRchar *err_ptr ));
extern IGRint VRget_bend 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRchar *spec_name ,
					 IGRdouble angle ,
					 IGRint comp_type ,
					 IGRchar *comp_code ,
					 IGRchar *err_ptr ));
extern IGRint VRget_reducer 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRchar *spec_name ,
					 IGRint comp_type ,
					 IGRchar comp_code ,
					 IGRchar *err_ptr ));
extern IGRint VRget_adapter 	__((	IGRlong *msg ,
					 IGRchar *spec_name ,
					 IGRint end_prep_1 ,
					 IGRint end_prep_2 ,
					 IGRchar *comp_code ,
					 IGRchar *err_ptr ));
extern IGRint VRget_transition 	__((	IGRlong *msg ,
					 IGRchar *spec_name ,
					 IGRint shape_code ,
					 IGRchar *comp_code ,
					 IGRchar *err_ptr ));
extern IGRint VRget_codelist 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRint list_num ,
					 IGRint code_num ,
					 IGRchar *short_txt ,
					 IGRchar *long_txt ,
					 IGRchar *err_ptr ));
extern IGRint VRget_label 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRint label_num ,
					 IGRchar *label_text ,
					 IGRchar *err_ptr ));

/* VRhvacdb.c */
extern void VR_DbC_Clhdb 	__((	void ));

extern int VRDbParseSel 	__((	char *crit_str ,
					 struct VRSelectAttr seldata [],
					 short *crit_no ));
extern int VRdbget_hvac_select_codes 	
				__((	int code_num ,
					 char *param_name ,
					 short *param_type ,
					 short *type ,
					 char *err_ptr ));
extern int VRdbform_hvac_dyn_search_str 	
				__((	struct VRSelectAttr seldata [],
					 short *crit_no ,
					 char *search ));
extern int VRdbacc_hvac_catalog 	
				__((	char *catalog ,
					 char *search ,
					 char *macro_name ,
					 struct ACrg_coll mac_pm [],
					 int *pm_no ,
					 char *err_ptr ));
extern int VRdbGetRisColType 	__((	char *table_name ,
					 char *param_name ,
					 short *range ,
					 short *param_type ,
					 short *type ,
					 char *err_ptr ));

extern int VRdbRisCol           __((    IGRlong    *msg ,
                                        IGRchar    *table_name ,
                                        IGRint     *nCol,
                                 struct VRriscol  **RSC ));

/* VRhvdbpb.I */
extern IGRint VRaccess_hvac_db 	__((	IGRlong *msg ,
					 IGRchar *spec_name ,
					 IGRchar *comp_name ,
					 IGRshort option ,
					 IGRchar *fam_name ,
					 IGRshort *comp_topo ,
					 IGRshort *comp_type ,
					 struct GRid *pbid ,
					 struct VRSelectAttr seldat [],
					 IGRshort *crit_no ,
					 IGRchar *err_ptr ));
extern IGRint VRdbaccess_hvac 	__((	IGRlong *mesg ,
					 IGRchar *comp_name ,
					 IGRchar *catalog ,
					 IGRchar *cat_occ ,
					 struct VRSelectAttr seldata [],
					 IGRshort *crit_no ,
					 IGRchar *fam_name ,
					 IGRshort *comp_topo ,
					 IGRshort *comp_type ,
					 struct GRid *pbid ,
					 IGRchar *err_ptr ));
extern IGRint VRdbGetHvCatOccList 	
				__((	IGRlong *msg ,
					 IGRchar *catalog ,
					 IGRchar ***occlst ,
					 IGRshort *listsize ,
					 IGRchar *err_ptr ));

/*VRrwdbpb.I */
extern IGRint VRaccess_rway_db  __((    IGRlong *msg ,
                                         IGRchar *spec_name ,
                                         IGRchar *comp_name ,
                                         IGRdouble  dWidth1,
                                         IGRdouble  dDepth1,
                                         IGRdouble  dWidth2,
                                         IGRdouble  dDepth2,
                                         IGRshort nShape ,
                                         IGRchar *fam_name ,
                                         IGRshort *comp_topo ,
                                         IGRshort *comp_type ,
                                         struct GRid *pbid ,
                                         struct VRSelectAttr seldat [],
                                         IGRshort *crit_no ,
                                         IGRchar *err_ptr ));
extern IGRint VRdbaccess_rway   __((    IGRlong *mesg ,
                                         IGRchar *comp_name ,
                                         IGRdouble  dWidth1,
                                         IGRdouble  dDepth1,
                                         IGRdouble  dWidth2,
                                         IGRdouble  dDepth2,
                                         IGRchar *catalog ,
                                         IGRchar *cat_occ ,
                                         struct VRSelectAttr seldata [],
                                         IGRshort *crit_no ,
                                         IGRchar *fam_name ,
                                         IGRshort *comp_topo ,
                                         IGRshort *comp_type ,
                                         struct GRid *pbid ,
                                         IGRchar *err_ptr ));
extern IGRint VRdbGetRwCatOccList
                                __((    IGRlong *msg ,
                                         IGRchar *catalog ,
                                         IGRchar **occlst ,
                                         IGRshort *listsize ,
                                         IGRchar *err_ptr ));

extern void VR_DbC_Clrdb        __((    void ));

/* VRnozdb.I */
extern void VR_DbC_Clnoz 	__((	void ));

extern IGRint VRaccess_noz_db 	__((	IGRlong *mesg ,
					 IGRdouble size ,
					 IGRchar *end_prep ,
					 IGRchar *rating ,
					 IGRchar *end_std ,
					 struct GRid *pbid ,
					 IGRchar *err_msg ));
extern IGRint VRget_spec_list 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRshort *listsize ,
					 IGRchar **speclist ,
					 IGRchar *err_ptr ));
extern IGRint VRget_param_list 	__((	IGRlong *msg ,
					 IGRchar *family_name ,
					 IGRshort *listsize ,
					 IGRchar **paramlist ,
					 IGRchar *err_ptr ));
extern IGRint VRget_code_list_set 	
				__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRshort list_num ,
					 IGRshort *listsize ,
					 IGRchar **codelist ,
					 IGRshort **code_num ,
					 IGRchar *err_ptr ));
extern int process_npd 		__((	double size_g ,
					 char *npd_str ));

/* VRreperr.I */
extern IGRint VRReportError 	__((	IGRlong *msg ,
					 struct GRid *CmpId ,
					 IGRchar *ErrMsgStr ));

/* access_db.c */
extern int access_db 		__((	char *fam_name ,
					 char *part_num ,
					 short comp_type ,
					 struct ACrg_coll mac_pm [],
					 int *pm_no ,
					 char *err_ptr ,
					 int *flag ));

/* acchvac.c */
extern void VR_DbC_Clhvc 	__((	void ));

extern int access_hvac 		__((	char *class ,
					 char *compname ,
					 int shape ,
					 char *macro_name ,
					 short *topology ,
					 short *type ,
					 struct ACrg_coll mac_pm [],
					 int *pm_no ,
					 struct VRSelectAttr seldat [],
					 short *crit_no ,
					 char *err_ptr ));

/* accpip.c */
extern void VR_DbC_Clpip 	__((	void ));

extern int access_piping 	__((	char *name ,
					 char *compname ,
					 double siz_1 ,
					 double siz_2 ,
					 int option ,
					 char *fam_name ,
					 char *partnum ,
					 short *topology ,
					 short *type ,
					 int *comp_numcp ,
					 int *comp_seccp ,
					 struct ACrg_coll mac_pm [],
					 int *pm_no ,
					 char *err_ptr ));
extern int extract_num 		__((	char *str1 ,
					 char *str2 ));

/* accrway.c */
extern int access_rway 		__((	char *vendor_code ,
					 char *compname ,
					 double width1 ,
					 double depth1 ,
					 double width2 ,
					 double depth2 ,
					 int rway_type ,
					 char *macro_name ,
					 short *topology ,
					 short *type ,
					 struct ACrg_coll mac_pm [],
					 int *pm_no ,
					 struct VRSelectAttr seldat [],
					 short *crit_no ,
					 char *err_ptr ));

/* getcodenum.c */
extern IGRint VRget_code_num 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRshort list_num ,
					 IGRchar *short_text ,
					 IGRshort *code_num ,
					 IGRchar *err_ptr ));

/* gethvac.c */
extern int get_hvac_br_comp_code 	
				__((	char *class ,
					 double angle ,
					 char *comp_code ,
					 char *err_ptr ));
extern int get_transition 	__((	char *class ,
					 int shape_code ,
					 char *comp_code ,
					 char *err_ptr ));

/* getnpdlst.c */
extern void VR_DbC_Clnpd 	__((	void ));

extern IGRint VRget_npd_list 	__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRchar *specname ,
					 IGRshort *listsize ,
					 IGRdouble **npdlist ,
					 IGRchar *err_ptr ));
extern IGRint check_spec 	__((	IGRlong *msg ,
					 IGRshort app ,
					 IGRchar *spec ,
					 IGRchar *err_ptr ));

/* getoptcode.c */
extern IGRint VRget_opt_code_txt 	
				__((	IGRlong *msg ,
					 IGRshort application ,
					 IGRchar *comp_code ,
					 IGRchar *specname ,
					 IGRdouble size_g ,
					 IGRdouble size_r ,
					 IGRshort **opt_codes ,
					 IGRchar **opt_txt ,
					 IGRshort *opt_cnt ,
					 IGRchar *err_ptr ));

/* getpipe.c */
extern void VR_DbC_Cltab 	__((	void ));

extern int get_piping_br_comp_code 	
				__((	char *spec_name ,
					 double siz_1 ,
					 double siz_2 ,
					 double angle ,
					 char *comp_code ,
					 char *err_ptr ));
extern int get_adapter 		__((	char *spec_name ,
					 int prep_1 ,
					 int prep_2 ,
					 char *comp_code ,
					 char *err_ptr ));

/* getrway.c */
extern int get_rway_br_comp_code 
				__((	char *vendor_code ,
					 double angle ,
					 int comp_type ,
					 char *comp_code ,
					 char *err_ptr ));

/* setoffset.c */
extern int set_offset 		__((	int num_cp ,
					 struct ACrg_coll mac_pm [],
					 int *pm_no ));
extern int get_gtt 		__((	int prep ,
					 int *gen_type ));
extern int integral_gsk_chk 	__((	int prep ,
					 int *flag ));
extern int get_param 		__((	struct ACrg_coll mac_pm [],
					 int pm_no ,
					 char *par_name ,
					 double *val ));
extern int power 		__((	int base ,
					 int n ));

/* units.c */
extern void VR_DbC_Clunt 	__((	void ));

extern int Get_piping_spec_units
				__((	int proj_no ,
					 char *name ,
					 char *err_ptr ));
extern int Get_part_units 	__((	char *name ,
					 char *p_partnum ,
					 char *err_ptr ));
extern double converted_to_vds 	__((	char *par_name ,
					 int units_set_in ,
					 int units_set_out ,
					 double old_value ,
					 char *err_ptr ));
extern double get_allowed_npd 	__((	int prj_units_set ,
					 int pip_spec_units ,
					 double old_value ,
					 char *spec_name ,
					 int proj_no ,
					 char *err_ptr ));
extern int correct_wrt_resol 	__((	double new_value1 ,
					 double resolution ,
					 double *new_value ));
extern int VRenq_proj_units 	__((	void ));

extern void  VRDBstr            __((IGRchar     *Cout,
                                    IGRchar     *Cin));

extern IGRint     VRDBint          __((IGRchar     *Cin));
extern IGRdouble  VRDBdbl          __((IGRchar     *Cin));

extern IGRint	VRaccess_rway_noz_db __((	IGRlong		*msg,
						IGRchar		*vendor_name,
						IGRint		nShape,
						IGRdouble	dWidth,
						IGRdouble	dDepth,
						struct GRid	*PbId ));
