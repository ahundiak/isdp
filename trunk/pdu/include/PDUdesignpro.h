#ifndef PDU_PROTO_H_DESIGNPRO
#define PDU_PROTO_H_DESIGNPRO

#include "igrtypedef.h" // Same file under BS/include and EXNUC/include
#include "OMminimum.h"  // Order is important
#include "OMindex.h"

#include "igetypedef.h" // exnuc/include, very similiar to GRtypedef also in exnuc/include
#include "igr.h"
#include "gr.h"
#include "DIdef.h"
#include "ref.h"

#include "FI.h"

#include "MEMstruct.h"

#include "PDUgrpart.h"
#include "PDUint.h"
#include "PDUintdef.h"
#include "PDUconvert.h"
#include "PDUnode.h"
#include "PDUmac_struc.h"

#if defined(__STDC__) || defined(__cplusplus) || 1
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./design/EXfile_form.c */
#ifndef ENTRY
typedef  char  ENTRY[OM_K_MAXOSNAME_LEN];
#endif

extern char *EXgetcwd       __PDU((char *buf,   int size));
extern int   EXget_file     __PDU((char *title, char *startdir, char *in_file, char *pat, int file_type[], char *returned_filename, char *seedfile, int form_type, int *response, char *response_data));
extern int   strcmp_ls      __PDU((char *name,  char *pattern));
extern char  EXnull_test    __PDU((void));
extern int   EX_qsort_list  __PDU((int lower, int upper, ENTRY list[], ENTRY list2[]));
extern int   EX_swap_string __PDU((char *a, char *b, char *aa, char *bb));

/* ./design/PDUatt_list.c */
extern int attach_single_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUattach_single_list_form              __PDU((char title_str[40 ], char msg_str[80 ]));
extern int PDUattach_single_list_form_single       __PDU((char title_str[40 ], char msg_str[80 ]));

/* kcmk - 19mar97 */
/* ./design/PDUassyfile.c */
extern int PDUdisplay_omfile_list_form      __PDU((char *title_str, char *msg_str));
extern int omfile_list_notification_routine __PDU(( int f_label, int g_label, double value, Form fp ));

/* ./design/PDUatt_orig.c */
extern int origin_list_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUdisplay_origins               __PDU((void));
extern int PDUload_origins                  __PDU((void));

/* ./design/PDUdebug.c */
extern void _pdm_debug      __PDU((char *message, char *variable));
extern void _pdm_rstatus    __PDU((char *meth, int sts1));
extern void _pdm_rstatus2   __PDU((char *meth, int sts1, int sts2));
extern void _pdm_status     __PDU((char *meth, int sts1));
extern void _pdm_status2    __PDU((char *meth, int sts1, int sts2));
extern void _pdm_debug_list __PDU((char *name, char **list, int rows, int cols));
extern char *_pdm_colptr    __PDU((MEMptr buffptr, int row, int col));
extern short PDUnullstr     __PDU((char *x));

/* ./design/PDUdsgn_frm.c */
extern int design_form_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int design_form                      __PDU((void));
extern int PDUdesign_form                   __PDU((void));
extern int PDUupdate_design_form            __PDU((void));
extern int PDUsetup_design_struct           __PDU((void));
extern int PDUcheck_file_for_parts          __PDU((void));
extern int PDUcheck_file_for_origins        __PDU((void));
extern int PDUdisplay_design_form           __PDU((void));
extern int PDUcheck_if_file_an_assembly     __PDU((void));
extern int PDUupdate_active_part_info       __PDU((void));

/* ./design/PDUdsgn_list.c */
extern int design_parts_notification_routine   __PDU((int f_label, int g_label, double value, Form fp));
extern int design_parts_listing_form           __PDU((void));
extern int PDUdesign_parts_listing_form        __PDU((void));
extern int PDUupdate_design_parts_listing_form __PDU((void));
extern int PDUload_design_parts_listing_form   __PDU((void));
extern int PDUload_list_parts_info             __PDU((void));

/* ./design/PDUdsgnapi.c */
extern int PDUformat_buffer           __PDU((int type, MEMptr *buffer));
extern int PDUdealloc                 __PDU((char **variable));
extern int PDUstrcpy                  __PDU((char **variable, char *value));
extern int PDUset_debug               __PDU((char *env_var, short on_off_flag));
extern int PDUwork_controller         __PDU((char *command_string));
extern int PDUvalidate_api_data_value __PDU((char *attr_text1, char *attr_value, MEMptr attr_buffer, MEMptr list_buffer));
extern int PDUcheck_for_function      __PDU((char *attr_name, char **func_name, MEMptr func_buffer));
extern int PDUis_cyclic_placement     __PDU((char *catalog, char *number, char *revision, MEMptr *asm_struct_bufr));

/* ./design/PDUdsp_att.c */
extern void PDUdisplay_views         __PDU((void));
extern void PDUdisplay_views_single  __PDU((void));
extern void PDUdisplay_files         __PDU((void));
extern void PDUdisplay_checkin_files __PDU((void));

/* ./design/PDUdyn_form.c */
extern int dynamic_attr_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUadd_dyn_data                   __PDU((char *attr_name, char *data, MEMptr dyn_attr, MEMptr *dyn_data));
extern int dynamic_attr_form                 __PDU((void));
extern int PDUdynamic_attr_form              __PDU((void));
extern int PDUdisplay_dynamic_form           __PDU((void));
extern int PDUdynamics_for_part              __PDU((MEMptr input_bufr, MEMptr filter_bufr, MEMptr default_bufr));
extern int PDUmerge_dynamic_attribute_bufrs  __PDU((MEMptr input_bufr));
extern int PDUfilter_dynamic_attribute_bufrs __PDU((MEMptr filter_bufr));
extern int PDUadd_static_dyn_attributes      __PDU((MEMptr *dyn_bufr, MEMptr *dyn_data, char *usageid, char *quantity, char *tagno, char *alttagno));
extern int PDUupdate_dynamics                __PDU((void));
extern int PDUcheck_for_required_data        __PDU((MEMptr attr_bufr, MEMptr data_bufr, char *msg));
extern int PDUcheck_display_dynamic_attr     __PDU((MEMptr attr_bufr, MEMptr data_bufr));
extern int PDUdefault_values_for_copy_parametric_part __PDU((MEMptr attr_bufr, MEMptr *data_bufr, MEMptr default_bufr));

/* ./design/PDUexec.c */
extern int PDUinternal __PDU((void));
extern int PDUexternal __PDU((void));

/* ./design/PDUexfrm_tls.c */
extern int  PDUprocess_ex_file_form                 __PDU((Form fp, int label));
extern int  PDUprocess_ex_file_form_after_select    __PDU((void));
extern void PDUprocess_ex_file_form_after_login     __PDU((void));
extern void PDUprocess_ex_file_form_after_seed_file __PDU((void));

/* ./design/PDUextern.c */
extern int PDUext_get_children     __PDU((void));
extern int PDUext_list_saved_views __PDU((char *catalog, char *partid, char *revision, MEMptr *view_buffer));
extern int PDUcopy                 __PDU((MEMptr file_bufr, int command, int type));
extern int PDUcopy_file            __PDU((void));
extern int PDUlogout               __PDU((void));
extern int PDUconnect              __PDU((void));

/* ./design/PDUglobal.c */
extern int PDUnfs_toggle  __PDU((void));
extern int PDUtree_toggle __PDU((void));

/* ./design/PDUmath.c */
extern int PDUfix_orientation __PDU((char **orient_string));
extern int PDUstring_to_point __PDU((char *input_string, struct PDUpoint *point));
extern int PDUdump_point      __PDU((double point[3 ]));

/* ./design/PDUopt_form.c */
extern int design_options_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int design_options_form                 __PDU((void));
extern int PDUdesign_options_form              __PDU((void));

/* ./design/PDUplpart.c */
extern int PDUconvert_dir_to_exp __PDU((void));

/* ./design/PDUrefresh.c */
extern int PDUalloc_refresh   __PDU((void));
extern int PDUdealloc_refresh __PDU((void));
extern int PDUread_refresh    __PDU((void));
extern int PDUwrite_refresh   __PDU((void));
extern int PDUload_refresh    __PDU((void));
extern int PDUunload_refresh  __PDU((void));

/* ./design/PDUtdseed.c */
extern void PDUtopdown_seed_form_init        __PDU((void));
extern int  PDUtopdown_cancel_seedfile_form  __PDU((void));
extern int  PDUtopdown_accept_seed_file_form __PDU((Form fp, char *seedfile));
extern int  PDUtopdown_seed_file_toggle      __PDU((void));
extern int  PDUtopdown_catalog_field         __PDU((Form fp));
extern int  PDUtopdown_part_field            __PDU((Form fp));
extern int  PDUtopdown_revision_field        __PDU((Form fp));
extern int  PDUtopdown_filename_field        __PDU((Form fp));
extern int  PDUtopdown_desc_field            __PDU((Form fp));
extern int  PDUtopdown_catalog_btn           __PDU((Form fp));
extern int  PDUtopdown_part_btn              __PDU((Form fp));
extern int  PDUtopdown_revision_btn          __PDU((Form fp));
extern int  PDUtopdown_filename_btn          __PDU((Form fp));
extern int  PDUtopdown_search_btn            __PDU((Form fp));

/* ./design/PDUtools.c */
extern int   PDUget_search_path           __PDU((char *search_key, char *path_name));
extern int   PDUunquote                   __PDU((char *input_string));
extern int   PDUlstrcmp                   __PDU((char *string1, char *string2));
extern int   PDUget_date                  __PDU((char *date));
extern int   PDUsetlevels                 __PDU((int *level_mask));
extern int   PDUextract_dir_value         __PDU((char *dir_path, char *dir_name, char **dir_value));
extern int   PDUcheck_expression_value    __PDU((char **value));
extern int   PDUmodify_assy_entry         __PDU((char *entry_name, char *old_dir_name, char *new_dir_name, char **modified_entry));
extern int   PDUprocess_pulldown_list     __PDU((char *name, MEMptr attr_buffer, MEMptr list_buffer));
extern int   PDUprocess_dyn_pulldown_list __PDU((char *catalog, char *name, MEMptr attr_buffer));
extern int   PDUfill_attribute_list       __PDU((MEMptr attr_bufr, MEMptr data_bufr, MEMptr list_bufr));
extern int   PDUfill_attribute_list1      __PDU((MEMptr attr_bufr, MEMptr data_bufr));
extern int   PDUvalidate_data_value       __PDU((char *attr_text1, char *attr_value, MEMptr attr_buffer, MEMptr list_buffer));
extern int   PDUvalidate_dyn_data_value   __PDU((char *attr_text1, char *attr_value, char *catalog, MEMptr attr_buffer, MEMptr data_bufr));
extern int   PDUcheck_file_permissions    __PDU((void));
extern int   PDUget_param_data            __PDU((char *catalog));
extern void  PDUstrip_dir_entry           __PDU((char *entry));
extern int   convert_tolower              __PDU((char *string, char *string1));
extern int   PDUchmod                     __PDU((char *path, mode_t mode));
extern int   PDUget_seed_file             __PDU((char **seed_file));
extern int   PDUcopyOS_file               __PDU((char *copyOS_path, char *source_path, char *dest_path));
extern int   PDUconvert_form_to_win       __PDU((Form form));
extern int   PDUcheck_PDU_form_display    __PDU((void));
extern void  Check_displayed_forms        __PDU((void));
extern short PDUis_part_in_buffer         __PDU((char *cat, char *part, char *rev, MEMptr buffer));

/* ./design/PDUtopdown.c */
extern int topdown_notification_routine   __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUtopdown_form                __PDU((void));
extern int PDUcheck_topdown_files         __PDU((void));
extern int PDUload_parts_list             __PDU((void));

/* ./design/PDUvalid.c */
extern int PDUvalidate_quantity __PDU((char *quantity));
extern int PDUvalid_filename    __PDU((char *catalog, char *part, char *revision, char *filename));

/* ./design/PDUverify.c */
extern int PDUverify_login      __PDU((void));
extern int PDUverify_command    __PDU((int command));
extern int PDUverify_part       __PDU((int verify_flag));
extern int PDUverify_file       __PDU((char *part_os));
extern int PDUtopdown_terminate __PDU((void));

/* ./design/invischkover.c */
extern void Set_invis_check_override   __PDU((void));
extern void Clear_invis_check_override __PDU((void));
extern int Invis_check_override        __PDU((void));

/* ./design/COpdui.I */

/* ./design/PDUasmfrm.I */
extern void assembly_display_notification_routine  __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUassembly_display_form                __PDU((struct GRmd_env *mod_env, MEMptr assembly_buffer, short put_queue, int call_command));
extern int PDUhighlight_assembly_rows              __PDU((void));
extern int PDUprocess_assembly_mcf                 __PDU((MEMptr assy_bufr, double display_level));
extern int PDUtoggle_assembly_display              __PDU((int sel_flag));
extern int PDUprocess_assembly_display_information __PDU((MEMptr assembly_bufr, double display_level));
extern int PDUfind_display_level                   __PDU((MEMptr assembly_buffer, double *display_level));
extern int PDUload_assembly_display_mcf            __PDU((MEMptr assembly_buffer, double display_level));
extern int PDUmanage_assembly_on_located_part      __PDU((char *refid_string));
extern int PDUfind_matching_refids                 __PDU((MEMptr assembly_bufr, double display_level, int act_row, char *display_text));
extern int PDUfind_nested_assemblies               __PDU((MEMptr assembly_bufr, double display_level, int act_row, char *display_text, int num_assem_rows));

/* ./design/PDUasmmgri.I */
extern IGRint PDUexecute_upon_save                              __PDU((void));
extern IGRint PDUcleanup_detached_parts_after_save              __PDU((void));
extern IGRint PDUexecute_upon_save_for_rev_assy                 __PDU((struct GRmd_env *mod_env));
extern IGRint PDUcleanup_detached_parts_after_save_for_rev_assy __PDU((void));

/* ./design/PDUassembly.I */
extern IGRint PDUadd_assy_struct_from_buffer           __PDU((struct GRmd_env *mod_env, IGRchar *child_no, IGRchar *file_name, MEMptr asm_struct_bufr, IGRshort add_mode));
extern IGRint PDUupdate_display_in_assembly            __PDU((struct GRmd_env *mod_env, MEMptr assy_struct_buffer));
extern IGRint PDUload_assy_struct_buffer               __PDU((struct GRmd_env *mod_env, MEMptr *assy_struct_buffer, IGRint max_level, IGRchar *path));
extern IGRint PDUload_copy_attach_buffer               __PDU((struct GRmd_env *mod_env, IGRint max_level, MEMptr *copy_attach_buffer));
extern IGRint PDUload_detach_buffer                    __PDU((struct GRmd_env *mod_env, IGRint max_level, IGRshort save, MEMptr *detach_buffer));
extern IGRint PDUload_delete_buffer                    __PDU((struct GRmd_env *mod_env, IGRint max_level, MEMptr *delete_buffer));
extern IGRint PDUflag_local_parts_in_assembly          __PDU((struct GRmd_env *mod_env, IGRchar *flag, MEMptr copy_attach_buffer));
extern IGRint PDUunflag_local_parts_in_assembly        __PDU((struct GRmd_env *mod_env));
extern IGRint PDUflag_deleted_parts_in_assembly        __PDU((struct GRmd_env *mod_env, IGRchar part_path[DI_PATH_MAX ]));
extern IGRint PDUdelete_flagged_parts_in_assembly      __PDU((struct GRmd_env *mod_env));
extern IGRint PDUflag_local_parts_for_save_in_assembly __PDU((struct GRmd_env *mod_env));
extern IGRint PDUload_child_buffer                     __PDU((MEMptr *child_buffer, struct GRmd_env mod_env));
extern IGRint PDUload_attach_buffer                    __PDU((MEMptr *attach_buffer, struct GRmd_env mod_env));
extern IGRint PDUremove_assembly                       __PDU((IGRchar assembly_path[DI_PATH_MAX ], struct GRmd_env *mod_env));
extern IGRint PDUextract_auto_assy_toggle              __PDU((OMuword osnum, IGRchar **toggle_value));
extern IGRint PDUupdate_auto_assy_toggle               __PDU((OMuword osnum, IGRchar *old_value, IGRchar *new_value));
extern IGRint PDUload_local_file_buffer                __PDU((IGRchar *cat_no, IGRchar *item_no, IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar *file_name, MEMptr *local_files));
extern IGRint PDUload_macrolibrary_copy_buffer         __PDU((IGRchar *catalog, IGRchar *number, IGRchar *revision, MEMptr *detached_parts));
extern IGRint PDUupdate_attach_info                    __PDU((struct GRmd_env mod_env, MEMptr attach_info_bufr));
extern IGRint PDUcreate_attach_info_buffer             __PDU((MEMptr *attach_info_bufr));
extern IGRint PDUappend_attach_list                    __PDU((struct GRmd_env *mod_env, struct PDUattach_node **attach_list));
extern IGRint PDUupdate_assembly_structure             __PDU((struct GRmd_env *mod_env, IGRshort invis_os, MEMptr assy_struct_bufr));
extern IGRint PDUgenerate_display_list                 __PDU((struct GRmd_env *mod_env, IGRshort load_refid, struct PDUdisplay_list **display_list));
extern IGRint PDUupdate_display_info                   __PDU((struct GRmd_env *mod_env, IGRshort update_refid, struct PDUdisplay_list *display_list));
extern IGRint PDUcleanup_new_OM_file                   __PDU(( IGRchar *file ));
extern IGRint PDU330load_delete_buffer                 __PDU(( struct GRmd_env *mod_env, IGRint max_level, MEMptr *detach_buffer ));

/* ./design/PDUbuffer.I */
extern IGRint PDUbuffer_data __PDU((IGRchar *description, MEMptr buffer));
extern IGRint PDUwrite_data  __PDU((MEMptr buffer, IGRchar **values, IGRshort size_flag));
extern IGRint PDUget_keyin   __PDU((IGRchar *keyin));

/* ./design/PDUcheckin.I */
extern IGRint PDUint_checkin __PDU((void));
/* KCMK-PDU330 */
extern IGRint PDU330int_checkin __PDU((void));
extern IGRint PDUselect_OM_file __PDU((IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar *active_filename));
extern IGRint PDUcleanup_non_assembly_files __PDU((struct GRmd_env mod_env));
extern IGRint PDUdelete_tree __PDU((IGRchar dir_name[DI_PATH_MAX], struct GRmd_env mod_env, IGRchar *regexpression));
extern IGRint PDUextract_reffile_desc __PDU((void));
extern IGRint PDUfind_PDU_design_file __PDU((MEMptr file_bufr, MEMptr attach_info_bufr));
extern IGRint PDUget_child_attach_bufrs __PDU((IGRchar *catalog, IGRchar *number, IGRchar *revision, MEMptr *attach_bufr, struct PDUcat_node **param_cat_list));
extern IGRint PDUload_dynamic_attrs __PDU((struct GRmd_env *mod_env, MEMptr *dyn_attr_bufr, MEMptr *dyn_data_bufr));
extern IGRint PDUprocess_part_dyn_attrs __PDU((struct GRmd_env *mod_env, struct PDUpart_node *part_ids, struct PDUpart_dyn_node **parts_dyn_attrs_list, IGRshort parts_type));
extern IGRint PDUcleanup_local_filemgr __PDU((void));
extern IGRint PDUprepare_param_cats_list __PDU((struct GRmd_env *mod_env, struct PDUcat_node **param_cat_list));
extern void PDUclear_checkin_buffers __PDU((void));
extern IGRint PDUload_active_checkin_info __PDU((void));
extern IGRint PDUselect_PDU_file __PDU((IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar *active_filename));
extern IGRint PDUcheck_if_graphic __PDU((IGRchar *filename));
extern IGRint PDUload_inactive_checkin_info __PDU((IGRchar *filename));
extern IGRshort PDUis_checkin_file_attached __PDU((struct GRmd_env *mod_env, IGRchar *checkin_file));

/* ./design/PDUcheckout.I */
extern IGRint PDUcheckout_part __PDU((MEMptr file_bufr, MEMptr assy_struct_bufr, IGRshort display_assembly));
extern IGRint PDU330checkout_part __PDU((MEMptr file_bufr, MEMptr assy_struct_bufr, IGRshort display_assembly));
extern IGRint PDUdisplay_assembly_before_retrieve __PDU((IGRchar *filename));
extern int PDUconvert_file_before_review __PDU((void));

/* ./design/PDUchkupdate.I */
extern IGRint PDUcompare_objects __PDU((MEMptr child_buffer, IGRint row, IGRint index, struct PDUserial *serial_array, IGRchar *orientation, struct PDUid object_found, struct GRmd_env *new_md_env));

/* ./design/PDUconvert.I */
extern IGRint PDUconvert_part_pointers __PDU((struct GRmd_env mod_env, IGRshort active, IGRshort *convert_flag));
extern IGRint PDUconvert_part_origins __PDU((struct GRmd_env mod_env, IGRshort active, IGRshort *convert_flag));
extern IGRint PDUprocess_BOM_attachments __PDU((struct GRmd_env mod_env, MEMptr *attach_info_bufr));
extern IGRint PDUadd_BOM_attachments_to_linklist __PDU((void));
extern IGRint PDUreplace_commas __PDU((IGRchar *string));
extern IGRint PDUcvt_20objspace __PDU((void));
extern IGRint PDUconvert_file_for_similar_mode __PDU((IGRchar **file_list, IGRint file_count));
extern IGRint PDUcvt_20objspace_for_checkout __PDU((struct GRmd_env mod_env));

/* ./design/PDUcoorsys.I */
extern IGRint PDUcreate_coorsys __PDU((struct GRmd_env mod_env, IGRchar *csname, IGRchar *csdesc, OM_S_OBJID csid));
extern IGRint PDUget_coord_sys_id __PDU((struct GRmd_env mod_env, IGRchar *csname, GRobjid *csid));
extern IGRint PDUload_view_info __PDU((OM_S_OBJID osid, OMuword osnum, MEMptr *view_buffer));
extern IGRint PDUcheck_default_view __PDU((void));
extern IGRint PDUdo_origins_exist __PDU((IGRshort invis_flag, OMuword osnum));
extern IGRint PDUdelete_origins __PDU((OM_S_OBJID osid, OMuword osnum));
extern IGRint PDUcreate_origin __PDU((IGRmatrix placement_matrix, struct GRmd_env mod_env, IGRchar *view_name, IGRchar *cs_desc, IGRdouble origin[3 ], IGRshort create_svview, struct GRid *csobj));
extern IGRint PDUcreate_part_pointer __PDU((IGRmatrix placement_matrix, struct GRmd_env mod_env, IGRchar *usage_id, IGRchar *cs_desc, struct GRid *csobj));
extern IGRint PDUdefine_origin __PDU((IGRlong *msg, IGRchar *view_name, IGRdouble origin_point[3 ], IGRchar *window_view));
extern IGRint PDUdelete_svview __PDU((IGRchar *view_name, struct GRmd_env *mod_env));
extern IGRint PDUrm_name __PDU((IGRchar *name));
extern IGRint PDUrmdir __PDU((IGRchar *name));

/* ./design/PDUcregra.I */
extern IGRint PDUclose_invis_file __PDU((IGRint index));
extern IGRint PDUretrieve_invis_file __PDU((struct GRid *newmod, IGRint *index));

/* ./design/PDUdirectory.I */
extern IGRint PDUcheck_uniqueness __PDU((IGRchar *alt_tag_value, OMuword osnum));
extern IGRint PDUget_tag_no __PDU((IGRchar **tag_value, OMuword osnum, IGRchar *catalog, IGRchar *partid, IGRchar *revision));
extern IGRint PDUget_alttag_no __PDU((IGRchar **alt_tag_value, OMuword osnum, IGRchar *catalog, IGRchar *partid, IGRchar *revision));
extern IGRint PDUget_dyn_attr_value __PDU((IGRchar *dir_name, OMuword osnum, IGRchar *attr_name, IGRchar **attr_value));
extern IGRint PDUcheck_tag_count __PDU((OMuword osnum, int *found));
extern IGRint PDUget_incbom __PDU((IGRchar **incbom_value, OMuword osnum, IGRchar *catalog, IGRchar *partid, IGRchar *revision, IGRchar *serial));
extern IGRint PDUget_incasm __PDU((IGRchar **incasm_value, OMuword osnum, IGRchar *catalog, IGRchar *partid, IGRchar *revision, IGRchar *serial));
extern IGRint PDUget_explodebom __PDU((IGRchar **explode_value, OMuword osnum, IGRchar *catalog, IGRchar *partid, IGRchar *revision, IGRchar *serial));
extern IGRint PDUupdate_dir_value __PDU((IGRchar path_name[DI_PATH_MAX ], OMuword osnum, IGRchar *attr_name, IGRchar *old_value, IGRchar *new_value));
extern IGRint PDUremove_tree __PDU((OMuword osnum, IGRchar path_name[DI_PATH_MAX ], IGRchar *dir_name));
extern IGRint PDUget_exp_objects __PDU((IGRchar *directory, IGRint exp_type, struct GRid **exp_objects, IGRint *object_count));
extern IGRint PDUevaluate_dyn_attr_expression __PDU((IGRchar *dir_name, OMuword osnum, IGRchar *exp_name, IGRchar **exp_value));
extern IGRint PDUconvert_dyn_attrs __PDU((IGRchar *catalog, IGRchar *partid, IGRchar *revision, IGRchar *dyn_name, IGRint dyn_type));
extern IGRint PDUextract_catpartrev_entries __PDU((IGRchar ***entries, IGRint *entry_count));
extern IGRint PDUcheck_if_need_conversion __PDU((void));
extern IGRint PDUflag_object_space __PDU((void));
extern IGRint PDU_remove_dir_tree __PDU((IGRchar start_path[DI_PATH_MAX ], struct GRmd_env *mod_env));

/* ./design/PDUdispasm.I */
extern IGRint PDUupdate_load_in_assembly __PDU((struct GRmd_env *mod_env));
extern void PDUadd_path_node __PDU((IGRchar *path));
extern IGRint PDUupdate_part_display __PDU((struct GRmd_env *mod_env));
extern IGRint PDUupdate_1st_level_detached_parts_display __PDU((struct GRmd_env *mod_env));
extern void PDUadd_refid_node __PDU((IGRint level, IGRchar refid[20 ], IGRshort PDUpart));
extern IGRint PDUget_GRpart_from_refid __PDU((struct GRmd_env *mod_env, struct GRid *ref_id, struct GRid *part_id));
extern IGRint PDUconstruct_refid_string __PDU((struct GRid *ref_id, struct GRid *context_id, IGRchar refid_string[20 ]));
extern IGRint PDUread_refid_string __PDU((IGRchar *refid_string, struct GRid *ref_id, struct GRid *context_id));
extern IGRboolean PDMset_reffile_display __PDU((IGRboolean construct, IGRchar *mount_name, struct GRid *ref_id, struct GRid *context_id, IGRint depth, IGRboolean *displayed, IGRboolean *loaded));
extern IGRint PDUmap_refid_to_assembly __PDU((struct GRmd_env *mod_env, IGRchar refid_string[20 ], struct GRid *part_id, IGRboolean *displayed, IGRboolean *loaded, IGRint depth));
extern IGRint PDUfind_refid_parent __PDU((IGRchar child_id[20 ], IGRchar parent_id[20 ]));
extern void PDUfree_path_list __PDU((void));
extern void PDUfree_refid_list __PDU((void));
extern IGRint PDUprocess_assembly_display __PDU((struct GRmd_env *mod_env, MEMptr assy_struct_bufr, IGRshort display, IGRshort display_mode, IGRshort update_display));
extern IGRint PDUupdate_local_flag_in_assembly __PDU((struct GRmd_env *mod_env));
extern IGRint PDUget_context_from_refid __PDU((struct GRid *ref_id, struct GRid *context_id));
extern IGRint PDUprint_parent_child_list __PDU((void));
extern IGRint PDUconstruct_asm_mgr_object __PDU((struct GRmd_env *mod_env, struct GRid *super_object));
extern IGRint PDUdetect_assembly_change __PDU((struct GRmd_env *mod_env));
extern IGRint PDUis_filename_to_be_loaded __PDU((char *assy_path, char *file_name));
extern IGRint PDUupdate_refids_in_assembly __PDU((struct GRmd_env *mod_env, char *filename, char *refid_string));
extern IGRint PDUfind_next_parent __PDU((IGRchar parent_id[20 ], IGRint depth));
extern IGRint PDUchange_parentid_of_refid __PDU((IGRchar child_id[20 ], IGRchar parent_id[20 ]));

/* ./design/PDUemshooks.I */
extern IGRint PDUexit_save __PDU((IGRchar *file_name, IGRint flag));
extern IGRint PDUexit_nosave __PDU((IGRchar *file_name, IGRint flag));
extern IGRboolean PDMloaded __PDU((void));
extern IGRboolean PDMpre_delete __PDU((struct GRid *part_id, struct GRmd_env *mod_env));
extern IGRboolean PDMpost_copy __PDU((struct GRid *part_id, struct GRid *new_part_id, struct GRmd_env *from_env, struct GRmd_env *to_env));

/* ./design/PDUexp.I */
extern IGRint PDUcreate_exp      __PDU((IGRint exp_type, IGRchar *dir_path, IGRchar *exp_name, IGRchar *exp_value, OMuword osnum));
extern IGRint PDUmodify_exp      __PDU((IGRint exp_type, IGRchar *dir_path, IGRchar *exp_name, IGRchar *new_exp_value, OMuword osnum));
extern IGRint PDUdelete_exp      __PDU((struct PDUid exp_id, struct GRmd_env mod_env));
extern IGRint PDUevaluate_exp    __PDU((IGRchar *dir_path, IGRchar *exp_name, IGRchar **exp_value));
extern IGRint PDUextract_exp_RHS __PDU((IGRchar *dir_path, IGRchar *exp_name, IGRchar RHS[EXP_MAX_LEN ], OMuword osnum));
extern IGRint PDUget_exp_type    __PDU((IGRchar *dir_path, IGRchar *exp_name, IGRchar **exp_type));

/* ./design/PDUgrpart.I */
extern IGRint PDUcreate_GRpart __PDU((struct GRmd_env *mod_env, IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar *child_no, IGRchar *quantity, IGRchar *alt_tagno, IGRchar *usage_id, IGRchar *view_name, IGRchar *history, IGRchar *part_type, IGRchar *incbom, IGRchar *incstr, IGRchar *explode, IGRshort attach, struct GRid *part_id));
extern IGRint PDUget_GRpart __PDU((struct GRmd_env mod_env, IGRchar *catalog, IGRchar *number, IGRchar *revision, struct GRid part_id));
extern IGRint PDUmodify_GRpart __PDU((struct GRmd_env mod_env, IGRchar *catalog, IGRchar *number, IGRchar *revision, struct GRid part_id, IGRchar *attribute, IGRchar *value, IGRint attribute_type, IGRint number_or_id));
extern IGRint PDUremove_GRpart_attr __PDU((struct GRmd_env mod_env, IGRchar *catalog, IGRchar *number, IGRchar *revision, struct GRid part_id, IGRchar *attribute, IGRchar number_or_id));
extern IGRint PDUextract_GRpart_attr_value __PDU((struct GRmd_env mod_env, IGRchar *catalog, IGRchar *number, IGRchar *revision, struct GRid part_id, IGRchar *attribute, IGRint number_or_id, IGRchar value[MAX_VALUE ], IGRint attribute_type));
extern IGRint PDUget_GRpart_all_attrs __PDU((struct GRmd_env mod_env, IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar ***attributes, IGRchar ***values, IGRint **attribute_types, IGRint *attribute_count, struct GRid *part_id, IGRint number_or_id));
extern IGRint PDUget_GRparts __PDU((struct GRmd_env mod_env, IGRchar *catalog, IGRchar **numbers, IGRchar **descriptions, IGRchar **revisions, IGRint *quantities, IGRint list_size, struct GRid *part_ids));
extern IGRint PDUpass_GRparts __PDU((struct GRmd_env mod_env, IGRchar *catalog, IGRchar *number, IGRchar *revision, OM_p_MESSAGE pass_msg, GRobjid senderid, GRspacenum senderos));
extern IGRint PDUgenerate_instance_number __PDU((IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRint *instance_no, struct GRmd_env *mod_env));
extern IGRint PDUgenerate_tag_no __PDU((IGRchar **tag_value, OMuword osnum));
extern IGRint PDUgenerate_child_no __PDU((IGRchar **child_value, OMuword osnum));
extern IGRint PDUincrement_tag_no __PDU((OMuword osnum));
extern IGRint PDUincrement_child_no __PDU((OMuword osnum));
extern IGRint PDUdisplay_GRpart __PDU((struct GRid part_id, IGRshort display_flag));
extern IGRint PDUattach_ref_to_GRpart __PDU((struct GRmd_env *mod_env, struct GRid part_id, IGRmatrix placement_matrix, IGRchar *view_name, IGRchar *file_name, IGRchar *catalog_no, IGRchar *item_no, IGRshort display, IGRshort drawing, IGRshort background, IGRmatrix rot_matrix, IGRpoint origin, struct GRid *cs_id, struct GRid *refobj));
extern IGRint PDUalign_GRpart               __PDU((IGRmatrix src_alignment_matrix, IGRmatrix dst_alignment_matrix, struct GRid src_objid, struct GRmd_env mod_env));
extern IGRint PDUget_reffile_objects        __PDU((OMuword osnum, struct PDUid **ref_objects, IGRint *ref_count));
extern IGRint PDUget_all_reffile_objects    __PDU((OMuword osnum, IGRshort include_nth_level, struct PDUnth_ref_objects **ref_list));
extern IGRint PDUget_coordsys_objects       __PDU((OMuword osnum, struct PDUid **coord_objects, IGRint *coord_count));
extern IGRint PDUturn_off_part_pointers     __PDU((void));
extern IGRint PDUis_usage_unique            __PDU((IGRchar *usage_id));
extern IGRint PDUis_alt_tag_unique          __PDU((IGRchar *alt_tag));
extern IGRint PDUis_PDU_file                __PDU((struct GRmd_env mod_env));
extern IGRint PDUget_GRparts_ids            __PDU((IGRchar part_entry[DI_PATH_MAX ], struct GRid **part_ids, IGRint *count));
extern IGRint PDUget_all_GRpart_ids         __PDU((OMuword osnum, struct PDUpart_node **part_ids, IGRint *total_count));
extern IGRint PDUextract_coord_orientation  __PDU((struct GRid coord_id, IGRchar **origin, IGRchar **x_point, IGRchar **y_point));
extern IGRint PDUgenerate_coord_orientation __PDU((IGRchar *origin, IGRchar *x_point, IGRchar *y_point, IGRmatrix trans_matrix));
extern IGRint PDUcheck_assembly_consistency __PDU((MEMptr assy_struct_bufr, struct GRmd_env *mod_env));
extern IGRint PDUget_all_ref_file_names __PDU((struct GRmd_env *mod_env));
extern IGRint PDUget_all_catalogno_itemno_pairs __PDU((void));
extern IGRint PDUdo_parts_exist __PDU((IGRshort invis_flag, OMuword osnum));
extern IGRint PDUdoes_part_exist __PDU((IGRchar *catalog, IGRchar *number, IGRchar *revision));
extern IGRint PDUdo_positionless_parts_exist __PDU((void));
extern IGRint PDUinitialize_replace_pointers __PDU((void));
extern IGRint PDUlist_catalogs_in_obj_space __PDU((OMuword osnum, MEMptr *disp_bufr));
extern IGRint PDUlist_parts_in_obj_space __PDU((IGRchar *catalog, MEMptr *disp_bufr));
extern IGRint PDUlist_revisions_in_obj_space __PDU((OMuword osnum, IGRchar *catalog, IGRchar *number, MEMptr *disp_bufr));
extern IGRint PDUlist_usage_ids_in_obj_space __PDU((MEMptr *disp_bufr));
extern IGRint PDUlist_part_usage_ids_in_obj_space __PDU((IGRchar *catalog, IGRchar *number, IGRchar *revision, MEMptr *disp_bufr));
extern IGRint PDUextract_part_type_from_obj_space __PDU((IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar **part_type));
extern IGRint PDUremove_non_existent_parts_from_assy_struct __PDU((struct GRmd_env mod_env));
extern IGRint PDUprocess_ref_files __PDU((IGRlong *msg, struct GRinquire_list inquire_requests[2 ], IGRchar *processor_info, IGRint *nest_indicator));
extern IGRint PDUextract_ref_file_description __PDU((IGRlong *msg, struct GRinquire_list inquire_requests[2 ], IGRchar *processor_info, IGRint *nest_indicator));
extern IGRint PDUremove_PDU_file_stamp __PDU((struct GRmd_env mod_env));
extern IGRint PDUstamp_PDU_design_file __PDU((struct GRmd_env mod_env));
extern IGRint PDUget_ref_instance_data __PDU((struct GRid ref_id, struct GRref_instance_data *ref_instance));
extern IGRint PDUlist_all_parts_in_os __PDU((IGRshort flag, MEMptr *parts_bufr));
extern IGRint PDUlist_all_origins_in_os __PDU((MEMptr *origins_bufr));
extern IGRint PDUdelete_part_placement __PDU((IGRlong *msg, struct GRid part_id));
extern IGRint PDUget_PDU_part_id __PDU((IGRlong *msg, IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar *usage_id, struct GRid *part_id));
extern IGRint PDUdelete_PDU_GRpart __PDU((struct GRmd_env mod_env, struct GRid part_id));
extern IGRint PDUupdate_parametric_tag __PDU((OMuword osnum, IGRchar *tag_value));
extern IGRint PDUis_PDU_part __PDU((struct GRid *part_id, struct GRmd_env *mod_env));
extern IGRint PDUextract_GRpart_modify_info __PDU((struct GRid *part_id, struct GRmd_env *mod_env, IGRchar **catalog, IGRchar **number, IGRchar **revision, IGRchar ***dyn_attrs, IGRchar ***dyn_syns, IGRchar ***dyn_types, IGRchar ***dyn_values, IGRint *num_attrs));
extern IGRint PDUget_all_parametric_ids __PDU((OMuword osnum, struct PDUpart_node **parametric_ids, IGRint *count));
extern IGRint PDUis_parametric_part __PDU((struct GRid *part_id));
extern IGRint PDUupdate_active_object_space __PDU((struct GRmd_env *mod_env, IGRchar *catalog, IGRchar *partid, IGRchar *revision));
extern IGRint PDUretrieve_placement_attrs __PDU((IGRchar *usage_id));
extern IGRint PDUget_default_usage_id __PDU((IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar *usage_id));
extern IGRint PDUget_ref_file_name __PDU((struct GRid ref_id, struct GRmd_env ref_mod_env, IGRchar *ref_file_name));
extern IGRint PDUgenerate_instance_number_cvt __PDU((IGRchar *catalog, IGRchar *catalogno, IGRchar *number, IGRchar *itemno, IGRchar *revision, IGRint *instance_no, struct GRmd_env *mod_env));
extern IGRint PDUis_background __PDU((struct GRid *ref_id, struct GRmd_env mod_env));
extern IGRint PDUload_local_file_info __PDU((IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar *child_no, MEMptr asm_bufr, MEMptr *file_bufr));
extern IGRint PDUdisplay_files_and_origins __PDU((IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar **filename, IGRchar **viewname));
extern IGRshort PDUis_active_file_a_part __PDU((void));
extern IGRint PDUis_part_positionless __PDU((struct GRmd_env *mod_env, struct PDUpart_node *part_ids, IGRchar *usage_id));
extern IGRint PDUis_file_open __PDU((IGRchar *pathname));

/* ./design/PDUloadhooks.I */
extern IGRint PDUload_PDUexit_save   __PDU((void));
extern IGRint PDUload_PDUexit_nosave __PDU((void));

/* ./design/PDUparm_part.I */
extern int PDUget_module_env __PDU((GRobjid objid, GRspacenum osnum));
extern IGRint PDUedit_macro_library __PDU((void));
extern IGRint PDUcvt_macro_library __PDU((IGRchar *macro_name));
extern IGRint PDUattach_macro_library __PDU((IGRchar *catalog, IGRchar *part, IGRchar *rev, IGRchar *part_cat, IGRchar **macro_lib));
extern int PDUvalidate_expression __PDU((IGRchar *text));
extern IGRint PDUrun_ppl __PDU((IGRchar *filename));
extern IGRint PDUis_macro_library __PDU((IGRchar *filename));
extern IGRint PDUis_cell_library __PDU((IGRchar *filename));
extern IGRint PDUis_grraster __PDU((void));
extern IGRint PDUexecute_ppl __PDU((IGRchar *filename, IGRchar *argument));
extern int PDUupdate_ref_files_for_rev_assy __PDU((IGRchar *old_master_file, IGRchar *new_master_file, IGRchar old_file_list[10 ][15 ], IGRchar new_file_list[10 ][15 ], IGRint file_count));

/* ./design/PDUpart.I */
extern IGRint PDUget_objects __PDU((struct PDUid *target, OM_S_CHANSELECT *target_channel, struct PDUid *objects_found, IGRint *obj_count));
extern IGRint PDUprocess_selected_parts_in_os __PDU((void));
extern IGRint PDUprocess_selected_origins_in_os __PDU((void));
extern IGRint PDUget_exnuc_path __PDU((IGRchar *path_name));
extern IGRint PDUget_ems_path __PDU((IGRchar *path_name));
extern IGRint PDUget_model_path __PDU((IGRchar *path_name));
extern IGRint PDUget_pdu_path __PDU((IGRchar *path_name));
extern IGRint PDUget_grnuc_path __PDU((IGRchar *path_name));
extern void PDUdeactivate_stop_sign __PDU((void));
extern void PDUactivate_stop_sign __PDU((void));

/* ./design/PDUpath.I */
extern IGRint PDUprocess_function __PDU((IGRchar *filename));

/* ./design/PDUpointer.I */
extern IGRint PDUset_invis_vwname __PDU((IGRchar *rot_mat_string, IGRchar **vw_rot_name));
extern IGRint PDUget_attr __PDU((struct PDUid *ptr, struct PDUreport *list));
extern IGRint PDUset_default_file __PDU((void));
extern IGRint PDUvalidate_alt_tag __PDU((IGRchar *alttag_no));
extern IGRint PDUextract_dyn_attr_value __PDU((IGRchar *dir_path, IGRchar *attr_name, OMuword osnum, IGRchar **attr_value));
extern IGRint PDUcreate_expression __PDU((IGRint exp_type, IGRchar *dir_path, IGRchar *exp_name, IGRchar *exp_value));
extern IGRint PDUmodify_expression __PDU((IGRint exp_type, IGRchar *dir_path, IGRchar *exp_name, IGRchar *new_exp_value));
extern IGRint PDUdelete_expression __PDU((IGRint byname_or_byid, IGRchar *dir_path, IGRchar *exp_name, OM_S_OBJID exp_id));
extern IGRint PDUevaluate_expression __PDU((IGRchar *dir_path, IGRchar *exp_name, IGRchar **exp_value));
extern IGRint PDUextract_expression_RHS __PDU((IGRchar *dir_path, IGRchar *exp_name, IGRchar RHS[EXP_MAX_LEN ]));
extern IGRint PDUcopy_expression __PDU((IGRchar *src_dir_path, IGRchar *dst_dir_path, OMuword osnum));
extern int PDUapoint_to_matrix __PDU((struct PDUpoint *point, IGRmatrix matrix));
extern IGRint PDUmatrix_to_point __PDU((IGRmatrix matrix, struct PDUpoint *point));
extern IGRint PDUadd_points __PDU((IGRmatrix matrix, struct PDUpoint point, struct PDUpoint *point2, IGRint i, IGRint j, IGRint k));
extern IGRint PDUxform_string __PDU((IGRchar **orient_string, IGRmatrix delta));
extern IGRint PDUmatrix_to_string __PDU((IGRint type, IGRmatrix matrix, IGRchar *output_string));
extern IGRint PDUpoint_to_string __PDU((IGRpoint point, IGRchar *output_string));
extern IGRint PDUstring_to_matrix __PDU((IGRchar *input_string, IGRmatrix matrix));
extern IGRint PDUdump_matrix __PDU((IGRmatrix matrix));

/* ./design/PDUpost_db.I */
extern long PDUpost_to_database __PDU((char *cpr_catalogname, char *cpr_itemname, char *cpr_itemrev, short wr_active_flag));
extern int PDUfind_PDU_stamp_files __PDU((MEMptr filenames, char *act_file, MEMptr *om_files, struct GRmd_env *spr_mod_env, int *index));
extern int PDUis_PDU_design_file __PDU((struct GRmd_env *spr_mod_env));
extern int PDUopen_design_file_invisibly __PDU((char *filename, int *index, OMuword *osnum, GRobjid *objid));
extern int PDUdisplay_list_of_om_files __PDU((MEMptr om_files, char **filename));
extern int PDUload_file_assembly_information __PDU((struct GRmd_env spr_mod_env));

/* ./design/PDUtext.I */
extern IGRint PDUmake_text __PDU((IGRchar **text_fields, IGRint field_count, IGRchar **new_text, IGRint *text_len));
extern IGRint PDUextract_text __PDU((IGRchar **text_string, IGRshort *text_len));
extern IGRint PDUexamine_string __PDU((IGRchar *input_string, IGRshort text_len));

/* ./design/PMdlprto.I */
extern IGRlong pdmoDeleteMacroLibraryEntry __PDU((OMuword osnum, char *macrolibrary));
extern IGRlong pdmoDeletePartOccurrence __PDU((IGRlong *lw_status, struct GRmd_env *spr_mod_env, struct GRid *spr_part));
extern IGRlong PDMDeletePartOccurrence __PDU((IGRlong *lw_status, struct GRmd_env *spr_mod_env, struct GRid *spr_part));
extern IGRlong pdmoDetachPart __PDU((struct GRmd_env *spr_mod_env, struct GRid *spr_part));
extern IGRlong pdmoDetachParametricPart __PDU((struct GRmd_env *spr_mod_env, struct GRid *spr_part));
extern IGRlong pdmoGetPartidGivenUsageid __PDU((IGRchar *cpr_usageid, struct GRmd_env *spr_mod_env, struct GRid *spw_part));
extern IGRlong pdmoCleanupMacroLibraryAttachment __PDU((struct GRmd_env *spr_mod_env, char *catalog, char *partnum, char *revision));

/* ./design/PMplprto.I */
extern int PDUget_description_for_part __PDU((char *catalog, char *partid, char *revision, char **description));
extern IGRint PDUvalidate_usageid __PDU((struct GRmd_env *spr_mod_env, IGRchar *cpr_usage_id));
extern IGRint PDUapi_default_usageid __PDU((struct GRmd_env *spr_mod_env, IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar *cpw_usage_id));
extern IGRlong PDUvalidate_alttagno __PDU((struct GRmd_env *spr_mod_env, IGRchar *catalog, IGRchar *itemname, IGRchar *revision, IGRchar *cpr_alt_tag));
extern IGRlong PDUvalidate_viewname __PDU((IGRchar *cpr_viewname, MEMptr view_buffer));
extern IGRlong pdmoAttachPart __PDU((struct GRmd_env *spr_mod_env, struct GRid *spr_part, IGRchar *cpr_ccatalogname, IGRchar *cpr_citemname, IGRchar *cpr_citemrev, IGRchar *cpr_cofilename, IGRchar *cpr_viewname, IGRchar *cpr_incstr, IGRchar *cpr_catno, IGRchar *cpr_itemno, IGRchar *cpr_childno, IGRchar *parent_parttype, IGRchar *display));
extern IGRint PDUfind_dynloc_name __PDU((IGRchar *cpr_dynloc_name, IGRchar **cpr_prompts, IGRint ir_numloc));
extern IGRlong pdmoPlacePart __PDU((IGRlong *lw_status, struct GRmd_env *spr_mod_env, struct GRid *spw_part, IGRchar *cpr_ccatalogname, IGRchar *cpr_citemname, IGRchar *cpr_citemrev, IGRchar *cpr_cofilename, IGRchar *cpr_usageid, IGRchar *cpr_viewname, IGRdouble cpr_quantity, IGRchar *cpr_explode, IGRchar *cpr_attach, IGRchar *cpr_alttagno, IGRchar *cpr_incstr, IGRchar *cpr_incbom, IGRint ir_dyn_count, IGRchar **cpr_dyn_names, IGRchar **cpr_dyn_values, IGRint ir_dynloc_count, IGRchar **cpr_dynloc_names, struct GRid *spr_dynloc_id, IGRdouble *dar_origin, IGRdouble *dar_x_point, IGRdouble *dar_y_point, struct GRid *spr_position_cs, IGRchar *edit_display));
extern IGRint PDUreplace_part_for_revise_assembly __PDU((char *catalog, char *partid, char *revision, char *parttype, char *file_list[10 ], int file_count, char *new_catalog, char *new_partid, char *new_revision, char *new_parttype, char *new_file_list[10 ], int new_file_count, char *p_attached, char *p_quantity, char *p_usageid, char *p_alttagno, char *p_incbom, char *p_incstr, char *p_explode, char *old_usageid, char *new_part));
extern IGRint PDUget_dynamic_data_for_rev_assy __PDU((struct GRmd_env mod_env, char *parttype));
extern IGRint PDUplace_part_for_revise_assembly __PDU((char *catalog, char *partid, char *revision, char *parttype, char *file_list[10 ], int file_count, char *new_catalog, char *new_partid, char *new_revision, char *new_parttype, char *new_file_list[10 ], int new_file_count, char *p_attached, char *p_quantity, char *p_usageid, char *p_alttagno, char *p_incbom, char *p_incstr, char *p_explode, char *new_part));
extern IGRint PDUcheck_part_files_for_PDU_parts __PDU((IGRchar *catalog, IGRchar *partid, IGRchar *revision));
extern IGRint PDUdelete_part_for_revise_assembly __PDU((char *file_list[10 ], int file_count, char *old_usageid, char *del_catalog, char *del_partid, char *del_revision));
extern int PDUclose_invis_module __PDU((short save_flag, int index));

/* ./design/Super_rfmgri.I */

/* ./design/EMpuldwnlst.C */
extern int pull_main __PDU((int form_label, Form pform_ptr, int g_label, int posi, int colu, char *fields[], int rows, int mcf_flags, int row_ind, int maxi_rows, int *sts, int *ind));
extern int PALcreate_pull_down_list __PDU((int form_label, Form form, int field1, int mcf_flag1, int row1, int pos1, int col1, int field2, int mcf_flag2, int row2, int pos2, int col2, int max_rows, int num_vis_rows, char *text_strings[], int num_text_strings, int position, int *form_id));
extern int PALgetassocpos __PDU((Form form, int field, int mcf_flag, int row, int pos, int col, int num_vis_rows, int max_rows, int position, int *new_form_x_pos, int *new_form_y_pos, int *new_form_x_size, int *new_form_y_size));
extern int PALasfmbntevent __PDU((Form form, int xpos, int ypos, int button_number, int transition, int time_tag));
extern int PALasfmwinevent __PDU((int form_label, int event, Form form));
extern int PALlist_notify_routine __PDU((int form_label, int gadget_label, double value, Form form));
extern int PALproc_pull_down_list __PDU((int form_no, int *sel_row));
extern int PALchange_pull_down_text __PDU((int form_no, char **text, int num_text));
extern int PALdelete_pull_down_list __PDU((Form form, int form_no));

/* ./design/PDUactdeact.C */
extern IGRint PDUactivate __PDU((void));
extern IGRint PDU330activate __PDU((void));
extern IGRint PDUcheck_os_tag_count __PDU((void));
extern IGRint PDUcheck_os_tag_count_for_create_graphics __PDU((OMuword osnum));
extern IGRint PDUdeactivate __PDU((void));
extern IGRint PDUprepare_queue __PDU((IGRint *responses, IGRchar **commands, IGRint count));
extern IGRint PDUput_queue __PDU((IGRint mode, IGRchar *cmd, IGRchar *cmd_key, IGRchar *string, IGRdouble point[3 ], IGRint *response, GRobjid *obj, IGRdouble *value, OMuword *osnum, IGRint *pos));
extern IGRint PDUfinish_activate __PDU((void));
extern IGRint PDUfree_attach_mac_list __PDU((void));
extern IGRint PDUchange_review_file_permissions __PDU((IGRchar *file, IGRshort flag));

/* ./design/PDUdsgnmsg.C */
extern IGRchar *PDUtranslate_message __PDU((IGRint msg_key));
extern IGRint PDUmsgs_to_attrs __PDU((IGRint msg_keys[], IGRint num_attr, IGRchar *attrs[]));
extern IGRint PDUmsgs_to_cols __PDU((MEMptr buffer, IGRint columns[], IGRint num_cols));
extern void PDUpercent_complete __PDU((IGRchar *task, IGRint percent));
extern IGRchar *PDUtranslate_message_and_vars __PDU((IGRint msg_key, IGRchar *output_var));
extern IGRint PDUinitialize_help __PDU((void));
extern int PDUtranslate_UMS_message __PDU((int key, char string[256 ], char *var));

/* ./design/PDUm_view_pt.C */
extern void PDUm_review_pt __PDU((IGRint *status, IGRchar *catalog, IGRchar *part_id, IGRchar *rev, struct PDUattribute_info **attrs, struct file_info **files));

/* ./design/PDUmessage.C */
extern IGRint PDUmessage_trans __PDU((IGRint msg_key, IGRchar wf));
extern IGRint PDUwf_check __PDU((IGRint msg_key));
extern IGRint PDUmessage __PDU((IGRint msg_key, IGRchar msg_field));
extern IGRint PDUget_var __PDU((IGRint msg_key, IGRchar *output_variable));

/* ./design/PDUmlibutil.C */
extern int PDUis_maclib_writable __PDU((char *mlibname));

/* ./design/PDUprocess.C */
extern IGRint PDUexternal_process __PDU((IGRint type, IGRchar **args, IGRint argc));


#if defined(__cplusplus)
}
#endif

#endif

