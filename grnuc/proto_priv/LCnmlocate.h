#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCnmlocate.I */
extern IGRint LCnmlocate __((IGRlong *rc, IGRchar *in_express, struct GRmd_env *modenv, struct GRlc_locate *attr, IGRint (*act_handler )(), struct LC_action_args *locate_args, struct GRlc_stack *stack, IGRint regex, IGRchar *act_parms, OM_p_CLASSLIST classes));

#if defined(__cplusplus)
}
#endif


#undef __
