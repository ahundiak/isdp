#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUotype25.C */
extern int GUotype25 __((IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, IGRchar *igds, IGRint *igds_size, IGRchar class_name[], int geometry, GRrange range, struct GRsymbology *symbology, int geometric_props, IGRshort *properties, IGRdouble bounds[], IGRlong *num_points, IGRlong *bound_num));

#if defined(__cplusplus)
}
#endif


#undef __
