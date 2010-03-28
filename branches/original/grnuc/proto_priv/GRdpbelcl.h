#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grdpb/grdpb/GRdpbelcl.I */
extern IGRint GRdpb_elig_class_init __((IGRint *msg, OM_S_OBJID objid, OMuword osnum));

#if defined(__cplusplus)
}
#endif


#undef __
