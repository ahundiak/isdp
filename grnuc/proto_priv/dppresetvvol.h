#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dppresetvvol.C */
extern IGRboolean DPpresetvvol __((IGRlong *msg, IGRdouble *vw_vol, IGRint min_x_vwport, IGRint max_x_vwport, IGRint min_y_vwport, IGRint max_y_vwport, IGRdouble *wld_to_view_mtx));

#if defined(__cplusplus)
}
#endif


#undef __
