#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dplevel.I */
extern IGRint DPlevel __((IGRlong *msg, IGRint *lev, IGRint num, IGRint *mask, IGRboolean on_off, IGRboolean update, GRobjid mod_objid, GRobjid objid, GRspacenum osnum));
extern IGRint DPinq_level __((IGRlong *msg, IGRint *num_of_levels, IGRshort *levels, IGRint on_off_flag, GRobjid objid, GRspacenum osnum));

#if defined(__cplusplus)
}
#endif


#undef __
