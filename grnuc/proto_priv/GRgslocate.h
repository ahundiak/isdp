#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/grsetgo/GRgslocate.I */
extern int GRgslocate __((IGRlong *msg, struct GRevent *event1, 
struct GRevent *event2, struct GRevent *locate_event, IGRlong mask1, 
IGRlong mask2, IGRint eventsize, IGRlong display_flag, IGRint *response, 
IGRchar *response_data, IGRchar *locate_prompt, IGRlong locate_key, 
IGRchar *acc_prompt, IGRlong acc_key, IGRchar *relocate_prompt, 
IGRlong relocate_key, struct GRlc_locate *attributes, 
struct GRlc_stack *stack, struct GRlc_dynamics *dyn, IGRint type,
IGRint (*act_handler )(), IGRchar *action_args, OM_p_CLASSLIST rtree_classes, 
OM_p_CLASSLIST eligible_classes, IGRchar (*select )(), IGRchar *select_args,
IGRint stack_size, IGRint regex, IGRint *locate_state, IGRint num_inputs,
IGRlong input1_mask, IGRlong input2_mask, IGRchar *input1_prompt,
IGRlong input1_key, IGRchar *input2_prompt, IGRlong input2_key, 
GRobjid senderid, GRspacenum senderos, OM_p_CHANSELECT chansel,
IGRint hilight_mode, IGRint unhilight_mode, IGRint *nbytes1, IGRint *nbytes2,
IGRint (*range_handler )(), IGRchar *range_args, IGRint value_type1,
IGRint vaule_type2, IGRint scale_flag));

#if defined(__cplusplus)
}
#endif


#undef __
