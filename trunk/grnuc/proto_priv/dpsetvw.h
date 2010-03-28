#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpsetvw.I */
extern IGRint DPset_view_rot __((IGRlong *msg, GRspacenum osnum, IGRdouble *p_rotation, IGRchar *vw_name));

#if defined(__cplusplus)
}
#endif


#undef __
