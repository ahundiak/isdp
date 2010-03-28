#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpmacerahil.I */
extern IGRint DPerase_hilite __((IGRlong *msg, GRobjid objid, GRspacenum osnum));

#if defined(__cplusplus)
}
#endif


#undef __
