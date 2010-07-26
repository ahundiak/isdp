#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPordphigs.C */
extern IGRint DPordphigs __((IGRlong *msg, IGRint in_flag, IGRdouble *vw_vol, IGRdouble *act_z, IGRdouble *wld_to_view, IGRdouble *vrp, IGRdouble *vpn, IGRdouble *vup, IGRdouble *eye_pt, IGRdouble *coi, IGRdouble *ang_dis, IGRdouble *near, IGRdouble *far, IGRdouble *new_act_z));

#if defined(__cplusplus)
}
#endif


#undef __
