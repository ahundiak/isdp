#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCblptloc.I */
extern IGRint LCblptlocate __((IGRlong *rc, struct GRevent *event1, struct GRlc_locate *attributes, struct GRlc_stack *stack, struct GRmd_env *mod, IGRdouble *tolerance, IGRchar (*action_handler )(), IGRchar *act_args, GRlc_classptrs classptr, IGRchar *locate_args, IGRchar *user_arg));

#if defined(__cplusplus)
}
#endif


#undef __
