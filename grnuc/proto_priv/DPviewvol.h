#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPviewvol.I */
extern int DPviewvol __((IGRlong *msg, IGRshort in_flags, IGRshort *ret_flags, struct GRid *gg_id, IGRdouble *origin, IGRdouble *rotation, IGRdouble *vw_vol, IGRdouble *display_depths, IGRdouble *active_z, IGRshort *defaults_vol, IGRshort *def_dis_depths, IGRdouble *new_vw_vol, IGRdouble *new_display_depths, IGRdouble *new_active_z, IGRdouble *new_coor_vol, IGRboolean update));

#if defined(__cplusplus)
}
#endif


#undef __
