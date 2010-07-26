#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCcheckact.C */
extern int LCcheck_action __((IGRlong *msg, IGRint *action_handler));

#if defined(__cplusplus)
}
#endif


#undef __
