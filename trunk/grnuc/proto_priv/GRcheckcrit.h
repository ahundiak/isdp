#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRcheckcrit.C */
extern int GRcheckcrit __((IGRlong *msg, GRobjid *objid, OM_p_CLASSLIST classes, struct GRlc_path *path, IGRint *path_position, IGRint *comp_eligible, IGRint *eligible_flag, IGRint *check_geom));

#if defined(__cplusplus)
}
#endif


#undef __
