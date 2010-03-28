#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRrfemptytx.I */
extern IGRint GRrf_empty_text_display __((IGRlong *msg, struct GRid *ref_obj, struct GRfunction_info *usr_info));

#if defined(__cplusplus)
}
#endif


#undef __
