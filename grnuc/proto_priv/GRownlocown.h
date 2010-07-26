#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ownergo/GRownlocown.I */
extern IGRint GRowner_locate_processing __((IGRlong *msg, struct GRlc_cvl *cvl, struct GRlc_path *path, IGRint *path_position, IGRint *owner_eligible, IGRint *component_eligible, GRobjid objid, GRspacenum osnum, IGRint properties));
extern IGRint GRowner_locate_processing1 __((IGRlong *msg, struct GRlc_cvl *cvl, struct GRlc_path *path, IGRint *path_position, IGRint *owner_eligible, IGRint *component_eligible, GRobjid objid, GRspacenum osnum, IGRint properties, IGRint local_cmp_eligible, IGRint local_eligible));
extern IGRint GRprocess_component __((struct GRlc_cvl *cvl, struct GRlc_path path[], IGRint *path_position, IGRint properties));

#if defined(__cplusplus)
}
#endif


#undef __
