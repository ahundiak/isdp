#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dplocbrln.C */
extern IGRint DPlocbrln __((IGRlong *msg, IGRdouble *point, GRobjid id, GRspacenum osnum, struct IGRline *boreline));

#if defined(__cplusplus)
}
#endif


#undef __