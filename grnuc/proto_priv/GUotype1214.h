#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUotype1214.I */
extern int GUotype1214 __((IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, struct IGDS_complex *cpxstring, IGRint *igds_cpx_size, IGRchar class_name[], GRrange range, struct GRsymbology *symbology, struct GRprops *geometric_props, IGRshort *properties, struct GRid *obj, struct GRmd_env *env, IGRchar *bs_buf, IGRboolean *has_name, IGRchar *name));

#if defined(__cplusplus)
}
#endif


#undef __
