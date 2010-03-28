#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/COnishovar.C */
extern IGRlong CO_ni_show_variable __((IGRint *ReturnMsg, struct GRevent *Events[]));

#if defined(__cplusplus)
}
#endif


#undef __
