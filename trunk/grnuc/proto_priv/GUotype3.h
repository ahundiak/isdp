#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUotype3.C */
extern IGRlong GUotype3 __((IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, struct type3_element *igds, IGRint *igds_size, IGRchar class_name[], struct IGRbsp_curve *geometry, GRrange range, struct GRsymbology *symbology, int geometric_props, IGRshort *properties, IGRboolean *has_name, IGRchar *name));

#if defined(__cplusplus)
}
#endif


#undef __
