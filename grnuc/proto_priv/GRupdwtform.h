#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRupdwtform.C */
extern IGRint GRupdweightform __((IGRlong *msg, IGRuchar active_weight, Form form_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
