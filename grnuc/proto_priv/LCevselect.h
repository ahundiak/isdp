#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCevselect.C */
extern int LCevselect __((IGRlong *rc, struct LC_select_args *args, struct IGRchar *user_args));

#if defined(__cplusplus)
}
#endif


#undef __
