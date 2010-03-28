#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUotype24.C */
extern int GUotype24 __((IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, IGRchar *igds, IGRint *igds_size, IGRchar class_name[], struct IGRbsp_surface *geometry, GRrange range, struct GRsymbology *symbology, struct GRprops *geometric_props, IGRshort *properties, struct IGResbs *bss_attr, IGRboolean *has_name, IGRchar *name));

#if defined(__cplusplus)
}
#endif


#undef __
