#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/DYiterator.I */
extern IGRint DYiterdyn __((struct dyn_iter *info_para, struct EX_button *point, IGRdouble *matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffer, IGRint *num_buffers, IGRchar **in_dummy1, IGRchar **in_dummy2, IGRchar **in_dummy3, IGRchar *out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));
extern IGRint DYiterator __((struct GRid parent_grid, struct GRid param_grid, struct GRevent *event, struct GRmd_env *object_mod, struct GRmd_env *curr_mod));
extern int ASiterend __((struct GRid obj, struct GRid param, struct GRevent *event, GRobjid my_id, struct GRmd_env *md_env));
extern int ASdisptobj __((struct GRid obj, struct EX_button *point, IGRdouble end_value, IGRdouble mtx[4 ][4 ], IGRdouble *dist, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
