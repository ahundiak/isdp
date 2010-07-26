#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRfindown.I */
extern int GRfindowner __((IGRlong *msg, GRobjid *objid, GRspacenum *osnum, struct GRlc_cvl *cvl, struct GRlc_info *loc_parms, enum GRlocate_action *action, IGRint *action_taken));

#if defined(__cplusplus)
}
#endif


#undef __
