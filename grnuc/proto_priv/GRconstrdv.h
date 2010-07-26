#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/GRconstrdv.I */
extern int GRconstruct_dv __((long *msg, struct GRmd_env *mod_env, unsigned int properties, struct IGRdisplay *display, int level, char name[], char desc[], int *orientation, struct GRrf_info *ref_info, char classname[], IGRmatrix rot_matrix, IGRpoint origin, char *scale, struct GRid *dv_id, struct GRid *cs_id));

#if defined(__cplusplus)
}
#endif


#undef __
