#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCcselect.C */
extern IGRint LCcselect __((IGRlong *rc, struct LC_select_args *args));

#if defined(__cplusplus)
}
#endif


#undef __
