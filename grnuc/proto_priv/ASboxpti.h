#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/AStext/ASboxpti.I */
extern void ASbox_pt_eval __((struct ret_struct *lbs_struct, IGRdouble *xbar, IGRdouble *point));

#if defined(__cplusplus)
}
#endif


#undef __
