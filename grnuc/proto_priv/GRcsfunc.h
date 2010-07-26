#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/csgo/GRcsfunc.I */
extern IGRint GRcsget_mgr __((IGRlong *msg, GRspacenum osnum, GRobjid module, GRobjid *objid));
extern IGRint GRcsget_active_info __((IGRlong *msg, GRspacenum osnum, GRobjid module, GRobjid csmgr, IGRint namebuf_size, IGRchar *name, IGRint *namebytes_ret, IGRint descbuf_size, IGRchar *desc, IGRint *descbytes_ret, IGRshort *type, GRobjid *objid));
extern IGRint GRcsmake_active __((IGRlong *msg, GRobjid objid, struct GRmd_env *module, GRobjid csmgr, IGRint display_old, IGRint display_new));
extern IGRint GRcsget_scale __((IGRlong *msg, GRobjid cs_id, GRspacenum cs_os, IGRdouble *scale));
extern IGRint GRcsset_scale __((IGRlong *msg, IGRint abs_rel, GRobjid cs_id, GRspacenum cs_os, IGRdouble *scale));
extern IGRint GRcscvt_coords __((IGRlong *msg, IGRint to_world, GRobjid cs_id, GRspacenum cs_os, IGRchar *cstype, IGRint npts, IGRdouble *lcl, IGRdouble *wld));
extern IGRint GRcschange_type __((IGRlong *msg, GRobjid cs_id, GRspacenum cs_os, IGRshort *type, IGRchar *type_string));

#if defined(__cplusplus)
}
#endif


#undef __
