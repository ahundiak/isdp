#ifndef __PALfunkpro_h
#define __PALfunkpro_h

#if defined(__STDC__) || defined(__cplusplus)
#define __PDU(s) s
#else
#define __PDU(s) ()
#endif


/* GRpuldwnlst.c */
extern int pull_main __PDU((int form_label, Form pform_ptr, int g_label, int posi, int colu, char *fields[], int rows, int mcf_flags, int row_ind, int maxi_rows, int *sts, int *ind));
extern int SGcreate_pull_down_list __PDU((int form_label, Form form, int field1, int mcf_flag1, int row1, int pos1, int col1, int field2, int mcf_flag2, int row2, int pos2, int col2, int max_rows, int num_vis_rows, char *text_strings[], int num_text_strings, int position, int *form_id));
extern int PALgetassocpos __PDU((Form form, int field, int mcf_flag, int row, int pos, int col, int num_vis_rows, int max_rows, int position, int *new_form_x_pos, int *new_form_y_pos, int *new_form_x_size, int *new_form_y_size));
void PALasfmbntevent __PDU((Form form, int xpos, int ypos, int button_number, int transition, int time_tag));
void PALasfmwinevent __PDU((int form_label, int event, Form form));
void PALlist_notify_routine __PDU((int form_label, int gadget_label, double value, Form form));
extern int PALproc_pull_down_list __PDU((int form_no, int *sel_row));
extern int PALchange_pull_down_text __PDU((int form_no, char **text, int num_text));
extern int PALdelete_pull_down_list __PDU((int form_no));
/* PALmacintf.c */
extern int PlprtThruMacro __PDU((char *cat, char *id, char *rev, struct GRmd_env *md_env, struct GRid *gridlst, int no, char **attrs, char **types, char **vals, int noattrs));
/*CC
extern int AddDynattrsToColl __PDU((struct stemp *temp_desc, struct GRid *dyncol, int num_coll, int num_org_temp, int num_loc, struct GRid **gridlist, int *numtemp));*/
/* PALmodsplatr.c */
extern int PALretrieve_dyn_info __PDU((char *catalog, char *partid, char *partrev));
extern int PALset_attribute_type __PDU((int no_dyn_attr, char **dyn_attr_list, char **dyn_attr_desc, int dyn_star_type[], Form fp, int glabel, int start_row));
extern int PALget_coresp_col_indx __PDU((char *dyn_attr_name, int *cnt));
extern int process_dyn_attrs_mcf __PDU((int form_num, Form fp, int glabel, int row, int indx, int *dyn_star_type, char *atrname));
/* PALtools.c */
extern int remove_blanks __PDU((char *st));
extern int Get_text __PDU((Form fp, int g_lable, int trow, int tcol));
extern int pull_down __PDU((Form fp, int form_no, int mcf_label, int mcf_row, int mcf_col, int out_col, char **param_val, int no_of_entries, int pos, int *status));
extern int add_quotes __PDU((char *str));
char *to_lower __PDU((char *st));
extern int insert_additional_columns __PDU((Form fp, int glabel, int tot_num));
extern int add_level_button __PDU((Form fp, int ind, int *lab));
extern int is_a_new_entry __PDU((char *entry, char **ent_list, int ent_no));
extern int FreeArray __PDU((char **text_array, int no_rows));
extern int FreeArrayPtr __PDU((char **ary_list, int arsize));
extern int remove_brackets __PDU((char str[]));
extern int RIS_box __PDU((int err_code));
extern int PALglbs_init __PDU((void));
/* PDMClsCats.c */
extern int DispClsAndCtlgs __PDU((Form fp, int form_no, int *cur_level, char **lclcatpath, int glabel));
/* PDMpdmparams.c */
extern int GetStatAndDynAttribs __PDU((char *catalog_name, int *no_stat, char ***stat_attr, char ***stat_type, char ***stat_desc, char ***stat_unit, int *no_dyn, char ***dyn_attr, char ***dyn_type, char ***dyn_desc));
/* PDMselprt.c */
extern int SelectOrPlacePart __PDU((int flag, IGRboolean flag1, Form lfp));
extern int init_selprt __PDU((void));
extern int update_form_with_current_catalog __PDU((void));
extern int select_part_fun_init __PDU((void));
extern int selprt_notification __PDU((int f_label, int g_label, double value, Form fp));
extern int update_catalog __PDU((Form fp, int flabel, int *curlevel, int glabel, int lab[]));
extern int rest_on_cat_selection __PDU((Form fp, int flag));
extern int acc_data __PDU((int glab));
extern int LoadLib_N_PrepareAttribs __PDU((struct GRmd_env *lenv, Form fp, struct GRid **list_coll, struct GRid *hdr, int *num_coll));
extern int SetDynAttrs __PDU((struct GRid *list_coll, int num_coll, struct GRid **grid_list, int *numtemp));
extern int Instance_Macro __PDU((Form fp, struct GRmd_env *env, struct GRid *hdr, struct GRid *rg_grid, int numgrids, int numcol));
extern int Add_slct_crit __PDU((Form fp, int mcf, struct GRid *rg_grid, struct GRmd_env *env, char **cat_attr, char **cat_desc, int no_cat_attr, char *catalog_name));
extern int get_index_of_attr __PDU((char **list_of_attr, char **attr_desc, int ind));
extern int CreRgcolAddStdAttribs __PDU((struct GRid *rg_collect_grid, int numocll, char *partno, char *catalog_name, char *n_itemno, char *n_revision, struct GRmd_env *lenv, char *child_no));
extern int AddStdAttribsToColl __PDU((struct GRid *rg_collect_grid, int num_coll, char *catalog_name, char *n_itemno, char *n_revision, struct GRmd_env *lenv));
extern int get_mac_hdr __PDU((char *macname, struct GRid *hdr, struct GRmd_env *lenv));
extern int PALerase_form __PDU((void));
extern int get_feet_num_for_symb __PDU((char *src_dir, char *filename, int *numft));
extern int select_project __PDU((Form fp));
extern int mystrcpy __PDU((char **str1, char *str2));
extern int GetAttribindx __PDU((char *colname));
extern int UpdateRefreshStr __PDU((Form fp, int glabel));
extern int BreakLocAndNonLocDYn __PDU((int num_coll, int **loc, char ***prompts, int *numloc));
extern int SetDynTemp __PDU((struct GRid *rg_grid, int num_coll, int flg, struct GRmd_env *lenv));
extern int disable_gadgets __PDU((Form fp));
extern int enable_gadgets __PDU((Form fp));
extern int GetParamVal __PDU((int no_vals, char *param_vals[], double **vals_in_formula, char *string));
extern int ProcessMCF __PDU((Form fp, int g_label, int row, int col, int pos));
extern int CallSmartViewSearch __PDU((Form fp, int g_label, int row));
extern int SelectCatalog __PDU((Form fp, int g_label));
extern int switch_off_gdgs __PDU((Form fp));
extern int SaveCriteria __PDU((Form fp, char *search_name, int noattrs));
extern int RestoreCriteria __PDU((Form fp, char *search_name, int noattrs));
extern int get_fp __PDU((Form *fp));
extern int PALgfname __PDU((void));
extern int UpdatePartType __PDU((Form fp, int glabel, char *catname));
extern int ret_fromGpart __PDU((void));
extern int mystrncpy __PDU((char *str1, char *str2, int no));
extern int UpdateCatPath __PDU((Form fp, char *catname));
extern int BreakupAndAddToList __PDU((char *attr_desc, struct GRid **list, int *no, struct GRmd_env *lenv));
extern int ReadStatAttribsonForm __PDU((char *ctlgname, Form fp, int glab, char **attribs, char **types, char **units, int numattr, struct GRid *rg_grid));
/* PLM_functs.c */
extern int init_forms __PDU((int form1_id, int form2_id, Form *fp1, Form *fp2, int flag));
extern int add_to_puldwn_list __PDU((Form fp, char *output_string, int num_rows));
extern int display_few __PDU((Form fp, int form_num, int mcf_label, int mcf_row, int mcf_col, int pos, int *sel_flg));
extern int set_table_field __PDU((Form fp, char *table_name, int glabel, int starting_row, MEMptr data_bufr));
extern int exp_list_notification __PDU((int f_label, int g_label, double value, Form fp));
extern int get_row_from_mcf __PDU((int row, int no_of_fields, Form sub_fp, int MCF_LABEL));
extern int set_active_form_ptr __PDU((Form fp));
extern int get_active_form_ptr __PDU((Form *fp));
extern int set_sub_form_params __PDU((Form fp, int parameters, char **cat_attr, char **attr_name, int no_cat_attr, int flag));
extern int reset_forms __PDU((Form fp1, Form fp2, int mcf, char *catname, char *project, int numattr, char **attrdesc, char **attrlist));
extern int remove_path __PDU((char str[]));
extern int from_cat_to_work_units __PDU((int i, char des_units[], char formula[]));
extern int from_work_to_cat_units __PDU((int i, char des_units[], char formula[]));
extern int get_conv_factor __PDU((char des_units[]));
void define_Aoperator __PDU((char *ope_str, char *ordering_type));
void define_Foperator __PDU((char *ope_str));
extern int input_operator __PDU((Form fp, int posi, int mcf_row, char *type));
extern int warn_box __PDU((char *w_message));
void warn_notification __PDU((int f_label, int g_label, double value, Form fp));
extern int AddToPuldwnList __PDU((char **list_of_vals, int list_len));
extern int copy_and_load_macro_lib __PDU((char *catname));
extern int GetValsForAttribs __PDU((Form fp, int glabel, int col));
extern int SetCatAttribs __PDU((Form fp, int glabel));
extern int display_attribs __PDU((Form fp, int glabel, int numattr, char **attrsyn, char **attrlst));
extern int puldwn_menu __PDU((int mcf_or_not, int list_len, int display_len, Form form, int g_label, char *list[], int *ndx));
extern int gname_notif __PDU((int f_label, int g_label, double value, Form fp));
extern int GetSelectedRow __PDU((Form fp, int glabel, int *srow));
/* parsit.c */
extern int hash __PDU((char *s));
struct part_struct *lookup __PDU((char *s));
struct part_struct *install __PDU((char *name));
extern int free_ptrs __PDU((void));
extern int parse_all_expr __PDU((int nexp, char *exparry[], int *nfld, char *arry[]));
extern int parse_expr __PDU((char *exp_str, int *nfld, char *arry[]));
char *parsetok __PDU((char *s1));

/* MOlocate.I */
/*CC
extern int spl_highlight  __PDU((
	 IGRlong  *msg1 ,
	 struct LC_select_args  *select_args ,
	 char  *usdata 
	));
*/
extern int plane_locate  __PDU((
	 IGRchar  *response_data ,
	 char  *prompt_l ,
	 struct GRid  *loc_obj 
	));
extern int set_weight_of_plane  __PDU((
	 struct GRid  *grid ,
	 int  wt
	));
extern int highlight_obj  __PDU((
	 struct GRid  *obj,
	 struct GRmd_env  *gmdenv ,
	 IGRlong  mode
	));

/* PDMattach.I */
extern int PDMattach  __PDU((
	 void
	));
extern int attach_macro_libraries  __PDU((
	 struct GRid  *part_grid
	));

/* PDMchekin.I */
extern int PALchekin  __PDU((
	 struct GRmd_env  *lenv 
	));
extern int update_part_list_bufr  __PDU((
	 struct GRid  *part_grid,
	 char  *attr_name
	));
extern int Process_feet_of_assbly  __PDU((
	 struct GRid  *part_grid,
	 char  *catname,
	 char  *partname,
	 char  *partrev 
	));
extern int GetACrgAttribVal  __PDU((
	 struct GRid  *rg_grid ,
	 char  *attr_name,
	 char  **buff,
	 int  *alloc_size 
	));
extern int UpdateGrandChild  __PDU((
	 struct GRid  *glist ,
	 char  *pn_catname,
	 char  *pn_partname,
	 char  *pn_partrev 
	));
/*CC
extern int GetFeetDesc  __PDU((
	 struct GRid  *grid ,
	 int  *nofeet ,
	 struct myfeet  **feetdesc
	));
*/
extern int add_data_togrand_child  __PDU((
	 struct GRid  *acdyn_col ,
	 char  *pn_catname,
	 char  *pn_partname,
	 char  *pn_partrev ,
	 char  **catname,
	 char  **partname,
	 char  **partrev 
	));
extern int get_nblines_in_dir  __PDU((
	 int  *nb_lines ,
	 char  ***lines ,
	 struct GRid  *dir_grid ,
	 int  osnum 
	));


/* PDMcpyprt.I */
extern void PALcopy_part  __PDU((
	 Form  frfp
	));
extern int copy_prpart  __PDU((
	 struct GRid  *part
	));
extern int set_static_attributes  __PDU((
	 int  nstat,
	 char  **stat_attr,
	 char  **stat_type ,
	 struct GRid  *fromrg_grid,
	 struct GRid  *torg_grid 
	));
extern int Make_copy  __PDU((
	 struct GRid  *grid ,
	 struct GRid  *hdr,
	 struct GRid  **coll_list,
	 int  *num_coll
	));
extern int Copy_ppart  __PDU((
	 struct GRid  *hdr,
	 struct GRmd_env  *env,
	 int  numgrids
	));
extern int GetMacroNameFromInstance  __PDU((
	 struct GRid  *hdr,
	 int  *ismacro ,
	 char  *placement_type
	));
extern int get_acdyncol_temp  __PDU((
	 struct GRid  *part_grid,
	 struct GRid  *acdyn_coll,
	 int  coll_ndx
	));
extern void PALdel_part  __PDU((
	 Form  frfp 
	));
extern int delete_prpart  __PDU((
	 struct GRid  *grid ,
	 struct GRmd_env  *lenv
	));
extern int GetAttrCollAndFillCollList  __PDU((
	 int  flag,
	 char  **Attribs,
	 int  num_attr,
	 int  num_loc,
	 struct GRid  *coll_list
	));

/* PDMdyncmp.I */
extern int add_attribute  __PDU((
	 struct GRid  *dyn_grid ,
	 char  *val ,
	 char  *name,
	 int  attr_type 
	));
extern int mod_attribute  __PDU((
	 struct GRid  *dyn_grid ,
	 char  *name,
	 char  *val ,
	 int  attr_type 
	));
/*CC
extern int normal_cmpt  __PDU((
	 IGRlong  *rc,
	 struct GRid  dcol,
	 struct ACrg_coll  *attr,
	 struct GRmd_env  *md_env,
	 IGRint  nb_par ,
	 struct GRid  *list_temp,
	 IGRint  *state,
	 struct GRid  *context 
	));
extern int stdstatic_cmpt  __PDU((
	 IGRlong  *rc,
	 struct GRid  dcol,
	 struct ACrg_coll  *attr,
	 struct GRmd_env  *md_env,
	 IGRint  nb_par ,
	 struct GRid  *list_temp,
	 IGRint  *state,
	 struct GRid  *context 
	));
extern int selection_place  __PDU((
	 IGRlong  *rc ,
	 struct GRid  dcol,
	 struct ACrg_coll  *attr,
	 struct GRmd_env  *md_env
	));
extern int selection_compute  __PDU((
	 IGRlong  *rc ,
	 struct GRid  dcol,
	 struct ACrg_coll  *attr,
	 struct GRmd_env  *md_env,
	 IGRint  nb_par,
	 struct GRid  *list_temp,
	 IGRint  *status,
	 struct GRid  *context 
	));
*/
extern void DYNdelete_form  __PDU((
	 void
	));
extern int init_select_form  __PDU((
	 char  *temp_val[] 
	));
extern void f_notification  __PDU((
	 int  f_label,
	 int  g_label,
	 double  value,
	 Form  fp
	));
extern int SELacc_datadata  __PDU((
	 void
	));
extern int GetCriteria  __PDU((
	 int  stat_attr,
	 struct GRid  acdcol,
	 struct GRmd_env  *md_env,
	 char  ***crit_val,
	 int  cnt,
	 struct GRid  *list
	));
extern int clear_ptrs  __PDU((
	 void
	));
extern int ReadAtrsFromCols  __PDU((
	 struct GRid  *rg_grid ,
	 char  ***attrs,
	 char  ***types ,
	 char  ***vals ,
	 int  *num 
	));
extern int compute_dependents  __PDU((
	 struct GRid  *coll,
	 int  exec_flag 
	));


/* PDMdynpar.I */
extern int plane_dyn_pars  __PDU((
	 char  *desc,
	 int  incr 
	));
extern int graph_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr
	));
extern int ref_cs_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr 
	));
extern int solid_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr 
	));
extern int line_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr 
	));
extern int conic_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr 
	));
extern int gr_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr
	));
extern int macro_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr 
	));
extern int ref_or_ci_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr 
	));
extern int point_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr 
	));
extern int lbs_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr 
	));
extern int surf_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr 
	));
extern int curve_dyn_pars  __PDU((
	 char  *desc ,
	 int  incr 
	));
extern int get_object  __PDU((
	 char  *desc,
	 OM_S_CLASSLIST  *elig_classes,
	 int  incr 
	));
extern int locate_object  __PDU((
	 char  *prompt,
	 OM_S_CLASSLIST  *elig_classes,
	 int  incr 
	));
extern int PALlocate_by_keyin  __PDU((
	 int  *rc,
	 char  *string,
	 struct GRid  *grid
	));
extern int PALlocate_by_datapt  __PDU((
	 int  *rc,
	 int  *no_of_obj,
	 struct GRid  *grid,
	 struct GRmd_env  *obj_md_env,
	 int  no_of_gr_classes,
	 OMuword  *gr_classes,
	 int  locate_ref
	));

/* PDMgetrle.I */
extern int display_fig  __PDU((
	 int  form_label ,
	 Form  fp,
	 int  glabel ,
	 struct GRmd_env  *mod_env
	));
extern int GetRleFileName  __PDU((
	 char  *filename 
	));
extern int copy_rlefile  __PDU((
	 char  *filename
	));
extern int format_column  __PDU((
	 MEMptr  *in_buffr ,
	 char  *col_name ,
	 char  *col_type 
	));
extern int delete_window  __PDU((
	 Form  fp ,
	 int  glabel 
	));
extern int show_macro_view  __PDU((
	 Form  fp,
	 struct GRmd_env  *mod_env 
	));
extern int WaitForEvent  __PDU((
	 void
	));
extern int PALgetcsid  __PDU((
	 struct GRid  *csid 
	));
extern int PALcritfile  __PDU((
	 int  flag,
	 int  noattrs
	));


/* PDMmapcoll.I */
extern int CreateCollections  __PDU((
	 struct GRmd_env  *env,
	 struct GRid  **list_coll,
	 int  num_coll
	));
/*CC
extern int GetDyncolIndx  __PDU((
	 struct stemp  *temp_desc,
	 char  *attr,
	 int  num_org_temp,
	 int  num_loc_temp,
	 int  *dyn_num
	));
*/
extern int GetNamedAttribValue  __PDU((
	 struct GRid  *BOX ,
	 char  *att_name ,
	 char  *att_value ,
	 int  *attr_type 
	));
/*CC
extern int get_temp_index  __PDU((
	 struct stemp  *temp_desc,
	 char  temp_name[] ,
	 int  num_org_temp
	));

extern int GetMacroTempDesc  __PDU((
	 struct GRid  *hdr ,
	 struct stemp  **temp_desc,
	 int  *numtemp
	));
extern int GetNumLocatable  __PDU((
	 struct stemp  *temp_desc,
	 int  num_org_temp,
	 int  *numloc
	));
extern int GetOriginalMacroInfo  __PDU((
	 struct GRid  *hdr,
	 struct stemp  **temp_desc,
	 int  *num_org,
	 int  *num_loc,
	 int  *num_coll
	));
*/
/* PDMmodprt.I */
extern void ModifyPart  __PDU((
	 Form  frfp
	));
extern void PALstack_events  __PDU((
	 int  ctype ,
	 char  *com_str ,
	 int  evnt,
	 GRobjid  *lobjid 
	));
extern int PALmodprt  __PDU((
	 struct GRid  *loc_grid,
	 int  flg 
	));
extern int mdprt_notification  __PDU((
	 int  f_label,
	 int  g_label,
	 double  value,
	 Form  fp
	));
extern int CreateExpForm  __PDU((
	 void
	));
extern int InitModify  __PDU((
	 void
	));
extern int GetMacroHeaderGivenGrid  __PDU((
	 struct GRid  grid ,
	 struct GRid  *mac_hdr
	));
extern int ProcessData  __PDU((
	 void
	));
extern int GetCatalogTemplateValue  __PDU((
	 struct GRid  *macro ,
	 int  no_temps,
	 char  **catalog_name
	));
extern int get_obj_name  __PDU((
	 struct GRid  grid ,
	 char  partname[]
	));
extern int get_loc_obj  __PDU((
	 int  *type
	));
extern int set_new_obj  __PDU((
	 struct GRid  *grid
	));
extern int HiLiteObject  __PDU((
	 int  mode,
	 struct GRid  obj
	));
extern int get_exp_name  __PDU((
	 Form  fp ,
	 int  glabel,
	 int  row 
	));
extern int plane_dyn_params  __PDU((
	 struct GRid  *grid 
	));
extern int GetTemp_N_AttrValues  __PDU((
	 struct GRid  located_part 
	));
extern int update_cat_val  __PDU((
	 char  *partno,
	 char  *partrev 
	));
extern int MODsleep  __PDU((
	 void
	));
extern int set_gadgets  __PDU((
	 Form  fp 
	));
/*CC
extern int GetACrgAttribList  __PDU((
	 struct GRid  *acdyncol,
	 struct ACrg_coll  **list_attr,
	 int  *nb_attr
	));

extern int GetAllTheAttributes  __PDU((
	 int  flag,
	 char  *catalog_name,
	 struct attributes  *mac,
	 char  *macroname
	));
*/
extern int NewMacroSelected  __PDU((
	 void
	));
extern int SetActionUponAccept  __PDU((
	 char  *macro_name,
	 struct GRid  *machdr
	));
extern int Terminate  __PDU((
	 void
	));
extern int delete_grpart  __PDU((
	 void
	));
extern int FreeMem  __PDU((
	 void
	));
extern int GetDynAttrValsOnForm  __PDU((
	 void
	));
extern int GetCatAttrCriteriaAndFormat  __PDU((
	 char  ***temp_val,
	 struct GRid  selci_tempid[],
	 int  *num_exp_objs,
	 struct GRmd_env  *my_env
	));
extern int GetChildNumber  __PDU((
	 char  **child_no,
	 struct GRid  *acdyn_col_obj
	));
extern int CreateTemplatesToACdyncol  __PDU((
	 int  *num_temps,
	 struct GRid  **exp_list,
	 int  num_exp_objs,
	 char  **temp_val,
	 struct GRid  *sel_grid,
	 struct GRmd_env  *lenv
	));
extern int GetACdyncolExpTempls  __PDU((
	 struct GRid  *dyncolid,
	 int  *cnt ,
	 struct GRid  **list 
	));
/*CC
extern int ExtractDynamicAttributes  __PDU((
	 struct GRid  *acdyncol,
	 struct ACrg_coll  *acdyncol_attribs,
	 int  no_acdyncol_attribs
	));
*/
extern int ProcessNewCat  __PDU((
	 void
	));
extern int grpart_update  __PDU((
	 void
	));
extern int processgrpart  __PDU((
	 void
	));
/*CC
extern int memset_mac  __PDU((
	 struct attributes  *mac
	));
*/
extern int free_omac  __PDU((
	 void
	));
extern int update_dynnames  __PDU((
	 void
	));
extern int set_dynnames  __PDU((
	 void
	));
extern int set_stddyn_attrval  __PDU((
	 int  *i,
	 int  end_attr
	));
extern int CheckACrgAttribVal  __PDU((
	 struct GRid  *acdyn_col,
	 char  *attribname,
	 char  **val
	));

/* PDMplprt.I */
extern int PDUcreat_rgbox  __PDU((
	 char  *pl_name ,
	 struct GRmd_env  *md_env ,
	 struct GRid  *rg_collect_grid
	));
extern int add_static_attributes  __PDU((
	 struct GRid  *rg_collect_grid ,
	 char  *value,
	 char  *attr_name
	));
extern int PDUis_macro_edited  __PDU((
	 struct GRid  *hdr 
	));
extern int PDUedit_macro  __PDU((
	 struct GRid  *hdr ,
	 char  **dyn_list,
	 int  num_dyn
	));
extern int GetMacroHeaderGivenName  __PDU((
	 char  *macroname,
	 struct GRmd_env  *module_env,
	 struct GRid  *header
	));
/*CC
extern int change_symbology  __PDU((
	 struct GRid  *hdr ,
	 struct IGRdisplay  *dattr ,
	 short  active_level 
	));
*/
extern void GetMacroType  __PDU((
	 struct GRid  *header ,
	 int  *mtype 
	));
extern void do_clean_up  __PDU((
	 GRobjid  obj ,
	 struct GRid  *rggrid,
	 struct GRmd_env  *env 
	));
/*CC
extern int place_macro  __PDU((struct GRmd_env  *env,
	int  num_temp,
	struct GRid  *hdr,
	struct GRid  *grid_list,
	int  ismacro,
	char  plcmnt_mode,
	char  *mac_name,
	char*part_no ));
*/
extern int set_feet_symbology  __PDU((
	 GRobjid  macobj ,
	 struct GRmd_env  *env 
	));
extern void get_mod_info  __PDU((
	 struct GRmd_env  *gmd_env 
	));
extern void FlashMessage  __PDU((
	 int  msgnum
	));
extern void PALstatus_msg  __PDU((
	 int  msgnum
	));
extern int check_obj_class  __PDU((
	 struct GRid  grid 
	));
extern int define_temp_to_ACdyncol  __PDU((
	 int  no,
	 struct GRid  *templist,
	 struct GRid  *rggrid ,
	 struct GRmd_env  *md_env 
	));
extern int selection_temp_to_ACdyncol  __PDU((
	 int  no ,
	 struct GRid  *templist,
	 struct GRid  *rggrid ,
	 struct GRmd_env  *md_env,
	 int numcoll
	));
extern int create_expression  __PDU((
	 char  *expname,
	 char  *expval ,
	 struct GRid  *expgrid ,
	 int  exptype 
	));
extern int attach_macro_lib  __PDU((
	 char  *maclib
	));

/* SelMacUtil.I */
extern int change_text_to_index  __PDU((
	 int  num_stat,
	 char  *temp_val[] ,
	 struct GRid  sel_grid[] ,
	 int  *num_exp_objs ,
	 struct GRmd_env  *md_env 
	));
extern int change_index_to_text  __PDU((
	 char  *temp_val[] ,
	 int  num_stat ,
	 int  num_exps ,
	 struct GRid  grid ,
	 struct GRmd_env  *md_env 
	));
extern int get_pretends_name  __PDU((
	 struct GRid  *grid ,
	 char  crt_name[]
	));

/* feet_depend.I */
extern int ACindex_template  __PDU((
	 struct GRid  *mac_grid,
	 int  index,
	 char  *downscan,
	 struct GRid  *real_temp
	));
extern int ACname_template  __PDU((
	 struct GRid  *mac_grid,
	 char  *temp_name,
	 struct GRid  *real_parent
	));

/* parse_fun.I */
extern int parse_exp_and_get_value  __PDU((
	 char  **formula 
	));
extern int remove_quotes  __PDU((
	 char  *str 
	));
extern int get_exp_objid_list  __PDU((
	 int  num_stat ,
	 char  *temp_val[] ,
	 struct GRid  sel_grid[],
	 int  *num_exp_objs 
	));
extern int set_directory  __PDU((
	 struct GRmd_env  *mod_env 
	));
extern int reset_directory  __PDU((
	 struct GRmd_env  *mod_env 
	));
extern void clear_mem  __PDU((
	 char  **arg_list ,
	 short int  arg_num 
	));
extern int get_text_exp_value  __PDU((
	 char  **condition 
	));
extern int GetDefaultPlacementName  __PDU((
	 char  **name 
	));
extern int PALusage_id_unique  __PDU((
	 char  *usageid
	));
#undef __PDU
#endif     /* __PALfunkpro_h */

