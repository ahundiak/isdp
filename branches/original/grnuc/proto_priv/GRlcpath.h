#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRlcpath.C */
extern struct GRlc_path *GRlc_get_path __((void));
extern IGRint GRlc_add_path __((struct GRlc_path *path_ptr, IGRint *path_position, GRobjid objid, GRspacenum osnum));
extern IGRint GRlc_remove_path __((struct GRlc_path path[], IGRint *path_position));

#if defined(__cplusplus)
}
#endif


#undef __
