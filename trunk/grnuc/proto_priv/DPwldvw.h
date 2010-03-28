#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPwldvw.C */
extern IGRboolean DPwld_to_vw_mtx __((IGRlong *msg, IGRint in_flags, IGRdouble *origin, IGRdouble *rotation, IGRdouble *wldvw_mtx, IGRdouble *vw_wld_mtx));

#if defined(__cplusplus)
}
#endif


#undef __
