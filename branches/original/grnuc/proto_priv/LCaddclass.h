#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCaddclass.I */
extern IGRint LCadd_class __((IGRchar *owner_key, IGRint properties, IGRchar *ascii_key, OM_S_CLASSLIST classlist, OM_S_OBJID dpb_id, OMuword dpb_os));

#if defined(__cplusplus)
}
#endif


#undef __
