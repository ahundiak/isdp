#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCevent.I */
extern IGRint LCevent __((IGRlong *rc, struct GRevent *event, struct GRlc_locate *attributes, IGRchar *act_handler, struct LC_action_args *act_args, struct GRmd_env *mod, OM_p_CLASSLIST eligible_classes, struct GRlc_stack *stack, IGRint *size, IGRlong display_flag));

#if defined(__cplusplus)
}
#endif


#undef __
