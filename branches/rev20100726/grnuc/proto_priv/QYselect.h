#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/query/sl/QYselect.I */
extern IGRint QYselect __((IGRlong *msg, struct LC_select_args *select_info, IGRchar *select_args));

#if defined(__cplusplus)
}
#endif


#undef __
