#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCandclass.C */
extern int LCandclass __((IGRlong *rc, OM_p_CLASSLIST dpb_class, OM_p_CLASSLIST command_class));

#if defined(__cplusplus)
}
#endif


#undef __
