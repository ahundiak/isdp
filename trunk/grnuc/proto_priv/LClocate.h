#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LClocate.I */
extern IGRint LClocate __((IGRlong *rc, struct GRevent *event1, struct GRevent *event2, struct GRevent *event3, IGRlong eventmask1, IGRlong eventmask2, IGRint *eventsize, IGRlong display_flag, IGRint *response, IGRchar *response_data, IGRchar *locate_prompt, IGRchar *acc_prompt, IGRchar *relocate_prompt, struct GRlc_locate *attributes, struct GRlc_stack *stack, struct GRlc_dynamics *dyn, IGRint type, IGRint (*act_handler )(), IGRchar *act_args, OM_p_CLASSLIST rtree_classes, OM_p_CLASSLIST eligible_classes, IGRint (*select )(), IGRchar *select_args, IGRint max_entries, IGRint regex, IGRlong locate_key, IGRlong acc_key, IGRlong relocate_key, IGRint hilite_mode, IGRint unhilite_mode, IGRint *nbytes1, IGRint *nbytes2, IGRint (*range_handler ), IGRchar *range_args, IGRchar *value_type1, IGRchar *value_type2, IGRint scale_flag));

#if defined(__cplusplus)
}
#endif


#undef __
