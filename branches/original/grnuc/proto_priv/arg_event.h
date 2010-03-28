#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dcob/ceo_locate/arg_event.I */
extern void COB_process_GRevent_arg __((int addr_mode, struct GRevent *p_event, char *arg, COB_arg_union *data, int *ret_type, char *is_const));

#if defined(__cplusplus)
}
#endif


#undef __
