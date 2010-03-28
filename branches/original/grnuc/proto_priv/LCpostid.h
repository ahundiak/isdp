#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCpostid.C */
extern IGRint LC_post_id __((IGRlong *rc, OM_S_OBJID objid, OMuword osnum, IGRint mode));

#if defined(__cplusplus)
}
#endif


#undef __
