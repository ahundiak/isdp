#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/node/batch.I */
extern int NDget_mod_batch __((int *p_mode));
extern int NDput_mod_batch __((int mode));
extern int NDwait_batch __((int type, struct GRmd_env *p_fr_env, struct GRmd_env *p_to_env, struct GRid *l_object, char **l_name, struct GRid *l_clone, char **l_info, int nb_obj));
extern int NDexec_batch __((IGRint mode));
extern int NDmodify_batch __((IGRint mode));
extern int NDdelete_batch __((void));
extern int NDin_buffer __((struct GRid object, struct ext_list *p_buff));
extern int NDin_buffer_var __((struct GRid object, struct ext_list *p_buff, int starting_index));
extern int NDdef_size __((int nb_obj, struct ext_list *p_buff, char **p_add_info, int size_of_add_info, int size_of_name));
extern int NDcompress_list __((unsigned int nb_in, struct GRid *list1, char *list2, int sizeof2, unsigned short *nb_out));
extern int NDsort_per_OS __((unsigned int nb_in, struct GRid *list1, char *list2, int sizeof2, unsigned short *nb_out));
extern int ND_mod_graph __((IGRint request, IGRint req_mode, IGRint *p_ret_mode));
extern int NDis_waiting __((int type, int starting_index, struct GRid *l_object, int *waiting_index, char **waiting_name, char **waiting_info, int nb_obj));
extern int NDget_batch_list __((int type, struct ext_list **active_list));
extern int NDadd_start_modif __((int (*user_func )()));
extern int NDadd_end_modif __((int (*user_func )()));

#if defined(__cplusplus)
}
#endif


#undef __
