#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/GRlcptlocate.C */
extern int GRlcptlocate __((IGRlong *rc, struct GRevent *event1, struct GRevent *event2, IGRlong *eventmask1, IGRlong *eventmask2, IGRint *eventsize, IGRlong *display_flag, IGRint *response, IGRchar *response_data, IGRchar *locate_prompt, IGRchar *acc_prompt, IGRchar *relocate_prompt, struct GRlc_locate *attributes, struct GRlc_stack *stack, struct GRlc_dynamics *dyn, IGRint (*act_handler )(), IGRchar *act_args, struct GRevent *event3, IGRchar *temp_arg5));

#if defined(__cplusplus)
}
#endif


#undef __
