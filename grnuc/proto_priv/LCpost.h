#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCpost.C */
extern int LCpost_function __((void));
extern int LCcommand_function __((int mode));
extern int LCadd_criteria __((IGRlong display_flag, struct GRlc_locate *attributes, OM_p_CLASSLIST rtree_classes, OM_p_CLASSLIST eligible_classes, IGRint regex, IGRint hilite_mode, IGRint unhilite_mode));
extern int LCfree_criteria __((struct LC_sd_node *t, IGRint all));
extern int LCdel_criteria __((void));
extern int LCget_prev_criteria __((IGRlong *display_flag, struct GRlc_locate *attributes, OM_p_CLASSLIST rtree_classes, OM_p_CLASSLIST eligible_classes, IGRint *regex, IGRint *hilite_mode, IGRint *unhilite_mode));
extern int LCmark_node __((int mode));
extern int LCmark_locate __((int mode));
extern int print_criteria_list __((void));
extern int print_criteria_node __((struct LC_sd_node *node));

#if defined(__cplusplus)
}
#endif


#undef __
