#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPlvldiri.I */
extern int strip_blanks __((char *buffer));
extern IGRint DPlev_num_to_name __((IGRlong *msg, IGRchar one_to_all_flag, IGRshort number, IGRchar **ptr_to_next, IGRshort *ret_nlev, IGRlong *size_name, IGRchar *name, GRobjid mod_objid, GRobjid objid, GRspacenum osnum));
extern IGRint DPlevel_to_number __((IGRlong *msg, IGRchar *name, IGRshort *level, GRobjid mod_objid, GRobjid objid, GRspacenum osnum));

#if defined(__cplusplus)
}
#endif


#undef __
