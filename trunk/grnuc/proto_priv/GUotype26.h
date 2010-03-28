#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUotype26.C */
extern int GUotype26 __((IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, IGRchar *igds, IGRint *igds_size, IGRchar class_name[], struct IGRbsp_curve *geometry, GRrange range, struct GRsymbology *symbology, struct GRprops *geometric_props, IGRshort *properties, IGRdouble knots[], IGRlong *num_knots));

#if defined(__cplusplus)
}
#endif


#undef __
