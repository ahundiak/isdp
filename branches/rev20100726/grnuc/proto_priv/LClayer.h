#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LClayer.I */
extern IGRint LClayer __((IGRlong *layers, OM_S_OBJID module_id, OMuword module_os));

#if defined(__cplusplus)
}
#endif


#undef __
