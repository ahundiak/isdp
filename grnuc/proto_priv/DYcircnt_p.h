#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/DYcircnt_p.I */
extern IGRint DYcircnt_p __((struct GRid *param_id, struct ret_struct *obj_struct, IGRdouble *view_vect, struct IGRdisplay *display, struct GRmd_env *md_env));
extern IGRint DYccntdyn __((struct DYcircnt_params *DYinfo, struct EX_button *point, IGRdouble *matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar **in_dummy1, IGRchar **in_dummy2, IGRchar **in_dummy3, IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));
extern int AScircle_param __((struct ret_struct *obj_struct, IGRdouble *point, IGRdouble *view_vect, IGRdouble *first_view_vect, IGRdouble *snap, IGRdouble *param_val));

#if defined(__cplusplus)
}
#endif


#undef __
