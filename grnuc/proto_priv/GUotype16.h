#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUotype16.C */
extern int GUotype16 __((IGRlong *msg, IGRlong *file_des, IGRchar *dgn_buf, struct type16_element *igds, IGRlong *igds_size, IGRchar class_name[], struct IGRarc *geometry, GRrange range, struct GRsymbology *symbology, int geometric_props, IGRshort *properties, IGRboolean *has_name, IGRchar *name, IGRboolean *fill_bit));

#if defined(__cplusplus)
}
#endif


#undef __
