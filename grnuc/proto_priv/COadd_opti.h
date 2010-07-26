#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/COadd_opti.I */
extern int ASstart_fence __((struct GRid set_grid, GRspacenum osnum, IGRint *nb_obj, struct GRid **p_obj, IGRlong *response, IGRchar *response_data));
extern int ASstart_var_fence __((struct GRid *set_grid, GRspacenum osnum, IGRint *nb_obj, struct GRid **p_obj, IGRlong *response, IGRchar *response_data, int make_source, int type_generic, char *macro_name));
extern int ASend_fence __((void));

#if defined(__cplusplus)
}
#endif


#undef __
