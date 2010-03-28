#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPsavvwcons.I */
extern IGRint DPsavevw_cons __((IGRlong *msg, GRspacenum *osnumber, IGRchar *vw_name, struct GRid *gg_id, IGRshort inflags, IGRchar *struct_pass, IGRchar *descript, IGRdouble *origin));

#if defined(__cplusplus)
}
#endif


#undef __
