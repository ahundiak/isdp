#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/getevent/COepp.C */
extern IGRlong COexpression_preprocessor __((IGRlong *ReturnMsg, IGRchar *String, IGRshort NewStringSize, IGRchar *NewString));

#if defined(__cplusplus)
}
#endif


#undef __
