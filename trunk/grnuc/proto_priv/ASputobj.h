#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/ASputobj.C */
extern long ASputobj __((long *msg, OM_S_OBJID objid, OMuword osnum, struct GRmd_env *env));

#if defined(__cplusplus)
}
#endif


#undef __
