#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/manipco/COcppsel.I */
extern IGRint COcppsel __((IGRlong *rc, struct LC_select_args *args, char *useless));
extern IGRint COcppselect __((IGRlong *msg, IGRlong *mask, IGRint *size, IGRlong *display_flag, IGRboolean *is_bore, IGRint *response, IGRchar *response_data, struct GRevent *accept_event, struct GRevent *acc_event1, IGRchar *obj_hilited, struct GRlc_stack *stack, struct GRlc_dynamics *dyn, IGRchar *acc_prompt, enum GRdpmode mode, enum GRdpmode hilight_mode, IGRlong acc_key));

#if defined(__cplusplus)
}
#endif


#undef __
