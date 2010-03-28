#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_conv/conv_linear.I */
extern IGRint DM13_linear_roots_attr __((IGRint *msg, IGRint version, struct GRid prev, IGRboolean prev_dropped, struct DMid *dmgraph_id, struct DMconstruct *dmcnst_lis, IGRmatrix matrix, IGRdouble axis[3 ], IGRdouble trak_pt[3 ], struct GRmd_env *md_env, struct GRas *assoc_lis, GRclassid *dim_classid));

#if defined(__cplusplus)
}
#endif


#undef __
