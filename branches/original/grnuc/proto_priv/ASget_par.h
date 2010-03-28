#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/ASget_par.I */
extern IGRint ASctl_parent_type __((IGRchar *act_parms, struct GRlc_info *new_entry, struct LC_action_args *locate_args, IGRchar *action));
extern IGRint ASget_parent __((IGRlong *ret_code, IGRint TokenList[], struct GRevent *event1, struct GRevent *event2, IGRlong *locate_mask, IGRlong *input_mask, IGRint *event_size, IGRlong *display_flag, IGRint *response, IGRchar *response_data, IGRchar *locate_prompt, IGRchar *acc_prompt, IGRchar *relocate_prompt, struct GRlc_locate *attributes, struct GRlc_stack *stack, IGRint type_generic, struct GRid *located_obj, struct GRid *context, struct ret_struct *obj_struct));
extern IGRint ASget_var_parent __((IGRlong *ret_code, IGRint TokenList[], struct GRevent *event1, struct GRevent *event2, IGRlong locate_mask, IGRlong input_mask, IGRint event_size, IGRlong display_flag, IGRint *response, IGRchar *response_data, IGRchar *locate_prompt, IGRchar *acc_prompt, IGRchar *relocate_prompt, struct GRlc_locate *attributes, struct GRlc_stack *stack, IGRint type_generic, char *macro_name, int nb_eligible, struct GRid *eligible, int nb_non_eligible, struct GRid *non_eligible, struct GRid *located_obj, struct GRid *context, struct ret_struct *obj_struct));
extern IGRint ASctl_param __((IGRchar *act_parms, struct GRlc_info *new_entry, struct LC_action_args *locate_args, IGRchar *action));
extern IGRint ASget_all_param __((IGRlong *ret_code, IGRint TokenList[], struct GRevent *event1, struct GRevent *event2, IGRlong *locate_mask, IGRlong *input_mask, IGRint *event_size, IGRlong *display_flag, IGRint *response, IGRchar *response_data, IGRchar *locate_prompt, IGRchar *acc_prompt, IGRchar *relocate_prompt, struct GRlc_locate *attributes, struct GRlc_stack *stack, int type_generic, struct GRid *located_obj, double *param_value));
extern IGRint ASget_param __((IGRlong *ret_code, IGRint TokenList[], struct GRevent *event1, struct GRevent *event2, IGRlong *locate_mask, IGRlong *input_mask, IGRint *event_size, IGRlong *display_flag, IGRint *response, IGRchar *response_data, IGRchar *locate_prompt, IGRchar *acc_prompt, IGRchar *relocate_prompt, struct GRlc_locate *attributes, struct GRlc_stack *stack, struct GRid *located_obj, double *param_value));
extern int NDctl_parent_type __((long *msg, int type, char *info, struct GRid *object, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
