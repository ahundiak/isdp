#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCgetinfo.I */
extern IGRint LCget_info __((OM_S_OBJID id, OMuword osnum, IGRchar *str));

#if defined(__cplusplus)
}
#endif


#undef __
