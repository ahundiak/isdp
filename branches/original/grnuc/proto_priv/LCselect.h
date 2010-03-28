#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCselect.I */
extern IGRint LCselect __((IGRlong *msg, IGRlong *mask, IGRint *size, IGRlong *display_flag, IGRboolean *is_bore, IGRint *response, IGRchar *response_data, struct GRevent *accept_event, struct GRevent *acc_event1, IGRchar *obj_hilited, struct GRlc_stack *stack, struct GRlc_dynamics *dyn, IGRchar *acc_prompt, enum GRdpmode unhilite_mode, enum GRdpmode hilite_mode, IGRlong acc_key, IGRint *nbytes, IGRchar *value_type, IGRint scale_flag));

#if defined(__cplusplus)
}
#endif


#undef __
