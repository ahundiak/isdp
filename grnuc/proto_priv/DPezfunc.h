#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grwindow/DPezfunc.C */
extern int DP_inq_win_nam __((IGRlong *mesg, GRspacenum osnumber, IGRchar *win_name, IGRdouble *vw_origin, IGRdouble *vw_rot, IGRdouble *view_vol, IGRdouble *world_vol, IGRdouble *act_z, IGRdouble *wld_to_vw));
extern int DP_inq_win_oid __((IGRlong *mesg, GRspacenum osnumber, GRobjid win_id, IGRdouble *vw_origin, IGRdouble *vw_rot, IGRdouble *view_vol, IGRdouble *world_vol, IGRdouble *act_z, IGRdouble *wld_to_vw));
extern int dpinq_sd_vwname __((IGRlong *mesg, GRspacenum osnumber, IGRchar *vw_name, IGRchar *sav_name, IGRchar *desc, IGRint *size_desc, IGRint *view_ty));
extern int dpinq_sd_vwoid __((IGRlong *mesg, GRspacenum osnumber, GRobjid vw_objid, IGRchar *sav_name, IGRchar *desc, IGRint *size_desc, IGRint *view_ty));

#if defined(__cplusplus)
}
#endif


#undef __
