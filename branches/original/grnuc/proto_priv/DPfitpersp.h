#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPfitpersp.C */
extern IGRint DPfitpersp __((IGRlong *msg, IGRint in_flag, IGRdouble *vw_vol, IGRdouble *act_z, IGRdouble *wld_to_view, IGRdouble *old_coi, IGRdouble *old_vrp, IGRdouble angle, IGRdouble *vrp, IGRdouble *eye_pt, IGRdouble *new_coi, IGRdouble *near, IGRdouble *far, IGRdouble *new_act_z));

#if defined(__cplusplus)
}
#endif


#undef __
