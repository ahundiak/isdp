#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/fencego/GRfnpass.I */
extern IGRint GRpass_on_to_fence __((OMuword osnum, GRobjid objid, OM_p_MESSAGE pass_msg));

#if defined(__cplusplus)
}
#endif


#undef __
