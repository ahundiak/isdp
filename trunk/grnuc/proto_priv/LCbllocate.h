#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCbllocate.C */
extern int LCbllocate __((IGRlong *rc, struct GRevent *event1, struct GRevent *event2, IGRlong *eventmask, IGRint *eventsize, IGRlong *display_flag, IGRint *response, IGRchar *response_data, IGRchar *locate_prompt, IGRchar *acc_prompt, IGRchar *relocate_prompt, struct GRlc_locate *attributes, struct GRlc_stack *stack, struct GRmd_env *mod, IGRdouble *tolerance, IGRchar (*action_handler )(), struct GRlc_dynamics *dyn, IGRchar *act_args, GRlc_classptrs classptr, IGRchar *locate_args));

#if defined(__cplusplus)
}
#endif


#undef __
