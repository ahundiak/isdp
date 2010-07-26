#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/xhatch/GRnester.I */
extern IGRlong GRxhbuild_cvprism __((IGRlong *msg, struct GRid window_id, struct IGRbsp_curve *curve, struct IGRcv_prism *prism, GRrange range));
extern IGRlong GRauto_nester __((IGRlong *msg, struct GRlc_info *lc_info, struct GRid window, struct GRlc_locate *attributes, OM_S_CLASSLIST *eligible_classes, struct GRlc_info **ret_objects, IGRlong *num_entries));
extern IGRint GRnester_action_hndlr __((IGRchar *args, struct GRlc_info *new_entry, struct LC_action_args *locate_args, enum GRlocate_action *action));

#if defined(__cplusplus)
}
#endif


#undef __
