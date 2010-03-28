#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPfitrng.I */
extern IGRint DPfit_range __((IGRlong *msg, IGRint in_flags, GRobjid module_id, GRspacenum module_os, IGRdouble *wld_to_view, IGRdouble *range));

#if defined(__cplusplus)
}
#endif


#undef __
