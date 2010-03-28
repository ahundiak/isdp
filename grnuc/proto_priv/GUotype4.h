#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUotype4.C */
extern int GUotype4 __((IGRlong *msg, IGRint *file_des, IGRchar *dgn_buf, struct IGDS_linestring *ele_buf, IGRint *ele_size, IGRchar class_name[], struct IGRbsp_curve *geometry, GRrange range, struct GRsymbology *symbology, int geometric_props, IGRushort *properties, IGRboolean *has_name, IGRchar *name, IGRboolean *fill_bit));

#if defined(__cplusplus)
}
#endif


#undef __
