#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPphigsord.C */
extern IGRint DPphigsord __((IGRlong *msg, IGRint in_flag, IGRdouble *vrp, IGRdouble *vpn, IGRdouble *vup, IGRdouble *eye_pt, IGRdouble *coi, IGRdouble *ang_dis, IGRdouble *near, IGRdouble *far, IGRdouble *vw_vol, IGRdouble *act_z, IGRdouble *rotate, IGRdouble *origin));

#if defined(__cplusplus)
}
#endif


#undef __
