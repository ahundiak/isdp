#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro/ACdb_infoi.I */
extern IGRint ACdb_info_get_objects __((GRspacenum os_osnum, struct GRid **p_obj_list, IGRint *p_count));
extern IGRint ACdb_info_get_objects_1 __((GRspacenum os_osnum, struct GRid **p_obj_list, IGRint *p_count));
extern IGRint ACdb_info_get_specific_objects __((GRspacenum os_osnum, struct GRid **p_obj_list, IGRint *p_count, IGRint chk_flag));
static compar __((struct ACobj_info *p_obj_info1, struct ACobj_info *p_obj_info2));

#if defined(__cplusplus)
}
#endif


#undef __
