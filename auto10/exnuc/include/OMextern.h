#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern char *som_calloc __((OMuint number, OMuint size));
extern int som_cancel_intercept __((OMuword osnum, OM_S_OBJID objid));
extern int som_change_class __((OMuword osnum, OM_S_OBJID objid,
		char *classname, OMuint sd_override));
extern int som_change_os_name __((OMuword OSnum, char *name,
		OM_e_OVRWRT_FLG overwrite));
extern int som_change_os_name_by_name __((char *curr_name, char *name,
		OM_e_OVRWRT_FLG overwrite));
extern int som_change_tag_version __((OMuword osnum, OM_S_OBJID objid,
		OMuword version, OMbyte flag));
extern int som_channel_preset __((OMuword os, OM_S_OBJID oid,
		OM_p_CHANSELECT p_chansel, OMuint size));
extern int som_channel_unpreset __((OMuword os, OM_S_OBJID oid,
		OM_p_CHANSELECT p_chansel, int collapse_flag));
extern int som_checkFileTimeStamp __((OMuword osnum));
extern int som_cleanup_cluster __((OM_p_LCD lcd));
extern int som_coalesce __((OM_p_PCD p_pcd, OM_p_CLUSTFHDR p_instance));
extern int som_collapse_channel __((OMuword os, OM_S_OBJID oid,
		OM_p_CHANNEL_HDR *pp_chan, OM_p_CHANNEL_DEFN chdef,
		int *p_chandata, OM_p_BIG_TAIL p_tail, OM_p_CLASSDEF p_acld));
extern int som_connect_add_tail __((OM_p_CHANNEL_HDR p_chan, int *p_chandata,
		OM_p_BIG_TAIL p_tail));
extern int som_connect_build_side __((OMuword os, OM_S_OBJID oid,
		OM_p_CHANSELECT chsel, int relidx, OM_p_CONNECT_SIDE s1));
extern int som_connect_chan_alloc __((OM_p_CONNECT_SIDE s1, int num_ents));
extern int som_connect_check_classlist __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_complete_sides __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_disconnect __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_doconnect __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_get_chent __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_if_connected __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_insert_rel __((OM_p_CONNECT_SIDE s1));
extern int som_connect_move_check __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2, int copy_flag));
extern int som_connect_pside __((OM_p_CONNECT_SIDE s1, OM_p_CONNECT_SIDE s2));
extern int som_connect_release_side __((OM_p_CONNECT_SIDE s1));
extern int som_connect_return_chent __((OM_p_CONNECT_SIDE s1));
extern int som_construct_and_copy __((OM_p_OBJECTHDR p_object,
		OM_S_OBJID objid, OMuword obj_osnum, OMuword osnum,
		char *osname, OM_S_NEIGHBOR neighbor, OM_p_OBJID p_objid,
		OMuint *p_tag));
extern int som_construct_object __((char *classname, OMuword classid,
		OM_S_OBJID objid, OM_p_OBJECTHDR p_object, OMuword obj_osnum,
		OMuword osnum, char *osname, OM_p_OBJID p_objid,
		OM_p_MESSAGE msg, OM_S_NEIGHBOR neighbor, OMuint *p_tag));
extern int som_construct_os __((OMuint classid, uword *osnum, char *osname,
		OM_p_OBJID p_objid, OMuint initcount, OMuint extcount,
		OMuint *resultcount, OMuint maxobjsize, OMuint loadmode,
		char sameosflag, char *di_logical));
extern int som_construct_os_by_name __((char *classname, uword *osnum,
		char *osname, OM_p_OBJID p_objid, OMuint initcount,
		OMuint extcount, OMuint *resultcount, OMuint maxobjsize,
		OMuint loadmode, char sameosflag, char *di_logical));
extern int som_convert_internal_osname_to_number __((char *name,
		OMuword *OSnum));
extern int som_convert_number_to_internal_osname __((OMuword OSnum,
		char *name));
extern int som_convert_os_name_to_number __((char *name, OMuword *OSnum));
extern int som_convert_os_number_to_name __((OMuword OSnum, char *name));
extern int som_create_class __((OM_p_CREATECLASS_ARGS p_arglist,
		OMuword *p_classid));
extern void som_dealloc __((void *ptr));
extern int som_delete_object __((OMuword OSnum, OM_p_OBJECTHDR p_instance,
		OM_S_OBJID objid));
extern int som_disable_intercept __((OMuword osnum, OM_S_OBJID objid));
extern int som_dload_class __((char **file_list, char **product_list,
                char **product_path_list));
extern int som_dynamic_class __((char *p_parent_class[], OMuword num_parents,
		OMuword maj_version, OMuword min_version,
		char *p_dynamic_class));
extern int som_dynamic_load __((char *object_file));
extern int som_enough_disk_space __((OMuword input_osnum, char *osname,
		char *filename, int filesize));
#ifdef SOL10_SKIPS
extern int som_find_space_in_lcd __((OM_p_LCD lcd, OMuint align_size,
		OM_p_OBJECTHDR *p_instance, OM_p_CSD *p_csd));
#endif
extern int som_flagged_tag_connects __((OMuword osnum, OMuword tag_osnum,
		OMuint *p_count, OMuint size, OM_p_TAG_CON_INFO p_tag_info,
		OMuword mask));
extern int som_free_space __((OM_p_LCD lcd, OM_p_OBJECTHDR p_instance,
		OMuint flag, OMuword OSnum, OM_p_PCD pcd));
extern int som_getClusterFromObject __((OMuword *pClustNum, OMuint objid,
		OMuword osnum));
extern int som_get_all_parents __((OMuword classid, char *classname,
		OMuword parent_list[], OMuint size, OMuint *count));
extern int som_get_any_instance __((OMuword OSnum, OM_S_OBJID objid,
		OM_p_RIP p_rip));
extern int som_get_channel __((OMuword osnum, OM_S_OBJID objid,
		OM_p_OBJECTHDR p_object, OM_p_CHANSELECT p_chanselect,
		OM_p_CHANNEL_HDR **ppp_channel, OM_p_CHANNEL_DEFN *pp_chandef,
		int **pp_chandata, OM_p_BIG_TAIL p_tail,
		OM_p_CHANNUM p_channum));
extern int som_get_channel_count __((OMuword osnum, OM_S_OBJID objid,
		OM_p_OBJECTHDR p_object, OM_p_CHANSELECT p_chanselect,
		OMuint *count));
extern int som_get_channel_name __((char *channame, OM_S_CHANNUM channum));
extern int som_get_channel_number __((char *channame, OM_p_CHANNUM p_channum));
extern int som_get_channel_objects __((OMuword osnum, OM_S_OBJID objid,
		OM_p_OBJECTHDR p_object, OM_p_CHANSELECT p_chanselect,
		OM_S_OBJECT_LINKAGE list[], OMuint size, OMuint *count));
extern int som_get_class __((OMuword OSnum, char *classname, OM_S_OBJID objid,
		OM_p_OBJECTHDR p_object, OMuword *p_classid,
		OM_p_CLASSDEF *pp_cld));
extern int som_get_classid __((OMuword OSnum, char *classname,
		OM_S_OBJID objid, OM_p_OBJECTHDR p_object, OMuword *p_classid));
extern int som_get_classname __((OMuword OSnum, OMuword classid,
		OM_S_OBJID objid, OM_p_OBJECTHDR p_object, char *classname));
extern int som_get_index __((OMuword osnum_c, OM_S_OBJID objid_c,
		OM_p_OBJECTHDR p_object_c, OM_p_CHANSELECT p_chanselect,
		OM_S_OBJID objid, OMuword osnum2, OMuint *index));
extern int som_get_instance __((OM_p_RIP p_rip, OM_S_OBJID objid));
extern int som_get_intercept __((OMuword osnum, OM_S_OBJID objid,
		OMuword *p_target_osnum, OM_p_OBJID p_target_objid));
extern int som_get_mem_info __((int *avail_swap, int *total_swap,
		int *phys_mem, int *avail_om, int *total_om, int *total_free));
extern int som_get_message_name __((char *classname, OMuword classid,
		OMuword method_index, char *msg_name));
extern int som_get_mychan __((int myme, OM_p_CLASSDEF p_acld, int p_chan,
		OM_p_CHANNEL_DEFN *pp_chandef, OM_p_CHANNUM p_channum));
extern int som_get_objid_at_index __((OMuword osnum_c, OM_S_OBJID objid_c,
		OM_p_OBJECTHDR p_object_c, OM_p_CHANSELECT p_chanselect,
		OMuint index, OM_S_OBJID *objid, OMuword *osnum2));
extern int som_get_os_senddepth __((OMuword OSnum, OMuint *depth));
extern int som_get_parent_classid __((OMuword classid, char *classname,
		OMuword *parent_classid));
extern int som_get_parent_classname __((OMuword classid, char *classname,
		char *parent_classname));
extern int som_get_parent_count __((OMuword classid, char *classname,
		OMuword *parent_count));
extern int som_get_senddepth __((OMuword osnum, OM_S_OBJID objid,
		OMuword *p_depth));
extern int som_inquire_os __((OMuword osnum, OM_p_DUPINTOS *pp_dup));
extern int som_is_ancestry_valid __((OMuword sub_classid,
		OMuword super_classid, char *sub_classname,
		char *super_classname));
extern int som_is_objid_on_channel __((OMuword osnum_c, OM_S_OBJID objid_c,
		OM_p_OBJECTHDR p_object_c, OM_p_CHANSELECT p_chanselect,
		OM_S_OBJID objid, OMuword osnum2));
extern int som_is_objid_valid __((OMuword OSnum, OM_S_OBJID objid));
extern int som_is_oper_equal __((OMuword osnum1, OMuword osnum2,
		OM_S_OBJID objid1, OM_S_OBJID objid2,
		OM_S_CHANSELECT chanselect1, OM_S_CHANSELECT chanselect2,
		OMbyte *equal));
extern int som_make_chanselect __((char *channame, OM_S_CHANNUM channum,
		OM_p_CHANNEL_HDR *chanaddr, OM_p_CHANSELECT p_chanselect));
extern int som_make_message __((char *class_name, OMuword classid,
		char *meth_name, OMuword size, void *p_arglist,
		OM_p_MESSAGE p_msg));
extern int som_make_neighbor __((OMuword osnum, OM_S_OBJID objid,
		OM_p_NEIGHBOR p_neighbor));
extern char *som_malloc __((OMuint size));
extern int som_move_tag __((OMuword osnum, OM_S_OBJID old_objid,
		OM_S_OBJID new_objid));
extern int som_object_alloc __((OM_p_OSD p_osd, OM_S_NEIGHBOR neighbor,
		OMuint size, OM_p_OBJECTHDR *p_instance, OMuword *p_sdi));
extern int som_objid_to_tag __((OMuword osnum, OM_S_OBJID objid,
		OMuint *p_tag, OMuword *p_version, OMuint *p_index,
		void *tag_rec, OMuint *p_free, OMuword **pp_version));
extern int som_ordered_send __((OM_E_WRT_FLAG wrt_flag, OM_p_MESSAGE msg,
		OM_S_OBJID senderid, OM_p_CHANNEL_HDR *pp_chan_hdr,
		OM_p_CHANNEL_DEFN p_chandef, OM_p_BIG_TAIL p_tail,
		int *p_chandata, int index1, int index2));
extern int som_osnum_to_oso_objid __((OMuword osnum, OM_p_OBJID p_objid));
extern int som_parse_channame __((char *channame, char *s_class,
		char *s_channel));
extern char *som_realloc __((char *ptr, OMuint size));
extern int som_recognize_class __((char *cur_class, char *rec_class,
		char *sub_class, char *mth_class, char *mth_name));
extern int som_remove_object_tag __((OMuword osnum, OM_p_OBJECTHDR p_object,
		OM_S_OBJID objid));
extern int som_report_class_version __((OMuword classid, char *classname,
		OMuword *major, OMuword *minor));
extern void som_report_error __((OMulong sts));
extern int som_report_version __((OMuword *major, OMuword *minor));
#ifdef SOL10_SKIPS
extern int som_rtree_get_op __((OM_S_RTREE_OP **rtree_op_pp));
#endif
extern int som_rtree_ops_init __((int count));
extern int som_runtime_init __((int paramc, char *param_list[]));
extern int som_send_channel __((OM_E_WRT_FLAG WRT_flag, OM_p_MESSAGE msg,
		OMuword osnum, OM_S_OBJID senderid, OM_p_CHANSELECT p_chansel,
		int frm, int to));
extern int som_send_foreign __((OM_E_WRT_FLAG WRT_flag, OM_p_MESSAGE msg,
		OM_S_OBJID senderid, OM_S_OBJID targetid, OMuword osnum,
		OM_S_CHANNUM in_channum));
extern int som_send_object __((OM_E_WRT_FLAG wrt_flag, OM_p_MESSAGE msg,
		OM_S_OBJID senderid, OM_S_OBJID targetid,
		OM_S_CHANNUM channum));
extern int som_set_dynamic_defaults __((int paramc, char *param_list[]));
extern int som_set_intercept __((OMuword osnum, OM_S_OBJID objid,
		OMuword target_osnum, OM_S_OBJID target_objid));
extern int som_set_tag_os __((OMuword *p_prev_osnum, OMuword osnum));
extern void som_set_os_type __((OMuword osnum, int *p_num, unsigned char flag));
extern int som_sibling_send __((OM_E_WRT_FLAG WRT_flag, OM_p_MESSAGE msg,
		OM_S_OBJID senderid, OM_p_CHANSELECT p_chansel,
		OM_E_INC_FLAG inclusive));
extern char *som_sm_calloc __((unsigned nelem, unsigned elsize));
extern void som_sm_dealloc __((void *ptr));
extern char *som_sm_malloc __((unsigned request));
extern char *som_sm_realloc __((char *ptr, unsigned nbytes));
extern int som_tag_object __((OMuword osnum, OM_p_OBJECTHDR p_object,
		OM_S_OBJID objid, OMuint *p_tag));
extern int som_tag_to_objid __((OMuword osnum, OMuint tag, OM_p_OBJID p_objid,
		OMuword *p_version));
extern int som_test_connection __((OMuword osnum, OM_S_OBJID objid,
		OM_p_CHANSELECT csel, OMuword tag_osnum, OM_S_OBJID tag_objid,
		OM_p_CHANSELECT tag_csel, OMuword *p_version,
		OMuword *p_tag_version, int force_flag));
extern int som_validate_cluster __((OM_p_LCD lcd));
extern int som_vla_collapse_copy __((OM_p_OBJECTHDR p_orig_object,
		OM_p_OBJECTHDR p_copy, OM_p_SPAMAPENT p_copy_spacemap,
		OM_p_CLASSDEF classdef));
extern int som_vla_find_initial_size __((OM_p_CLASSDEF p_acld, OMuint *size));
extern int som_vla_fixup __((OM_p_OBJECTHDR p_object, char type));
extern int som_vla_get_size_of_object __((OM_p_OBJECTHDR myme,
		OM_p_CLASSDEF classdef, int *p_fixed_size, int *p_size));
extern int som_vla_initialize_offsets __((OM_p_CLASSDEF p_acld,
		OM_p_OBJECTHDR p_instance));
extern int som_vla_remove_outriggers __((OMuword osnum,
		OM_p_SPAMAPENT p_spacemap, OM_p_CLASSDEF p_acld,
		OM_p_LCD p_clustcmp));
extern int som_vla_set_dimension __((int *p_offset, unsigned int *p_count,
                OMuint dim, OMuword osnum, OM_S_OBJID objid,
                OM_p_CLASSDEF p_acld, int move_data));

#if defined(__cplusplus)
}
#endif

