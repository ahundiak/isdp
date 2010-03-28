#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/grmacrosi.I */
extern int GRdisplay_object __((struct GRid *object_id, struct GRmd_env *md_env, enum GRdpmode mode));
extern int GRchange_properties __((struct GRid *object_id, IGRshort action, IGRshort property_mask));
extern int GRget_properties __((struct GRid *object_id, IGRshort *props));
extern int GRsymbology_options __((struct GRid *object_id, IGRint flag, struct GRsymbology *symb));
extern int GRdelete_object __((IGRlong *msg, struct GRmd_env *md_env, struct GRid *object_id, IGRint display_flag));
extern int GRcopyobject __((IGRlong *msg, struct GRid *object_id, struct GRmd_env *md_env, struct GRmd_env *new_env, struct GRid *new_id, IGRint display_flag));
extern int GRput_name __((IGRlong *msg, struct GRid *object_id, IGRchar *name));
extern int GRget_coordinate_data __((IGRlong *msg, struct GRid *object_id, struct GRmd_env *md_env, IGRdouble *origin, IGRdouble *x_vector, IGRdouble *y_vector, IGRdouble *z_vector, IGRdouble *scale, IGRmatrix *matrix));
extern int GRproject_point_on_element __((IGRlong *msg, struct GRid *object_id, struct GRmd_env *md_env, IGRdouble *point, IGRdouble *proj_pt, IGRdouble *u_parm, IGRdouble *v_parm));
extern int GRcreate_graphic_group __((IGRlong *msg, IGRint flag, struct GRid *object_ids, IGRint num_objects, struct GRid *gg_id));

#if defined(__cplusplus)
}
#endif


#undef __
