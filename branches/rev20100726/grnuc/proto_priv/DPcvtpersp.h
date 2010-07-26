#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPcvtpersp.I */
extern int DPcvtpersp __((IGRlong *msg, struct GRid *gg_id, IGRint in_flags));

#if defined(__cplusplus)
}
#endif


#undef __
