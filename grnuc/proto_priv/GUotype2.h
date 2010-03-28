#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUotype2.I */
extern int GUotype2 __((IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, struct cell *igds, IGRint *igds_size, IGRchar class_name[], struct IGRlbsys *lbsys, GRrange range, struct GRsymbology *symbology, struct GRprops *geometric_props, IGRshort *properties, struct GRid *cell, IGRboolean *flag, struct GRmd_env *env, IGRchar *bs_buf, IGRchar *name, IGRchar *has_name, IGRboolean *ele_name));
extern void Set_Electronics_flag __((int action));

#if defined(__cplusplus)
}
#endif


#undef __
