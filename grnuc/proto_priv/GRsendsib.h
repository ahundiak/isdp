#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRsendsib.C */
extern IGRint GRsend_to_next_sibling __((GRspacenum chan_osnum, GRobjid chan_objid, GRspacenum osnum, GRobjid objid, OM_p_MESSAGE pass_msg));

#if defined(__cplusplus)
}
#endif


#undef __
