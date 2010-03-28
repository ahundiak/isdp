#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grdpb/grdpb/GRdpbfunc.I */
extern void GRset_dpb_objid __((OM_S_OBJID objid));
extern IGRint GRget_dpb_objid __((OM_S_OBJID *dpb_id, OMuword *mod_osnum));
extern IGRint GRgetactenv __((IGRlong *msg, struct EX_button *point, IGRint *sizbuf, struct GRmd_env *md_env, IGRint *nret));
extern IGRint GRdpb_get __((IGRint *msg, IGRint parameter, IGRint *sizbuf, IGRchar *buffer, IGRint *nret));
extern IGRint GRdpb_put __((IGRint *msg, IGRint parameter, IGRint *sizbuf, IGRchar *buffer));
extern IGRint GRsetinqcolcal __((IGRlong *msg, IGRint inq0_set1, IGRint *calibration_flag));

#if defined(__cplusplus)
}
#endif


#undef __
