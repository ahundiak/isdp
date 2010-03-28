#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_root/groverride.I */
extern int DMget_text_rotation_matrix __((IGRdouble *dp_rotation, IGRdouble *lbsys_matrix, IGRdouble *text_matrix, IGRdouble txt_offset, OM_S_OBJID dim_id, OMuword dim_os, IGRshort *mx_type, IGRdouble *matrix, IGRshort *new_type, IGRdouble *new_env));

#if defined(__cplusplus)
}
#endif


#undef __
