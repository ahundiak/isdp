#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPunitvwvec.C */
extern IGRboolean DPunit_vwvec __((IGRlong *msg, IGRdouble *rotation, IGRdouble *unit_vw_vec));
extern IGRboolean DPwld_z __((IGRlong *msg, IGRdouble view_z, IGRdouble *wld_to_view, IGRdouble *unit_vw_vec, IGRdouble *wld_z));

#if defined(__cplusplus)
}
#endif


#undef __
