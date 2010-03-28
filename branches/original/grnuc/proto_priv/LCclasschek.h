#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCclasschek.I */
extern int LCclasschek __((IGRlong *rc, OMuword classid_to_check, OM_p_CLASSLIST eligible_classes, IGRint mode));
extern int LCcheck __((IGRlong *rc, OMuword classid_to_check, OM_p_CLASSLIST eligible_classes, IGRint mode));

#if defined(__cplusplus)
}
#endif


#undef __
