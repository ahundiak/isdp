#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRlocsupport.C */
extern IGRint GRcomponent_eligibility __((IGRlong *msg, struct GRlc_cvl *cvl, struct GRlc_path path[], IGRint *path_position, OM_S_OBJID objid, OMuword osnum, IGRint properties));
extern IGRint GRowner_eligibility __((IGRlong *msg, struct GRlc_cvl *cvl, struct GRlc_path path[], IGRint *path_position, OM_S_OBJID objid, OMuword osnum, IGRint properties));

#if defined(__cplusplus)
}
#endif


#undef __
