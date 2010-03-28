#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ownergo/GRptlnproc.I */
extern IGRint GRownptlnproc __((IGRlong *msg, OM_S_OBJID objid, OM_p_MESSAGE proc_msg));

#if defined(__cplusplus)
}
#endif


#undef __
