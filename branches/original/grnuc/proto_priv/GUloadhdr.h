#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUloadhdr.C */
extern void GUload_IGDSheader __((IGRlong *msg, IGRchar class_name[], IGRshort *type, struct GRsymbology *symbology, IGRushort *properties, GRrange range, struct GUcommon_header_info *header));

#if defined(__cplusplus)
}
#endif


#undef __
