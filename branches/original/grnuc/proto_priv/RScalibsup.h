#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/raster/RScalibsup.c */
extern int RSloadvlt __((int vsno, struct vlt_slot *vlt, int nslots));
extern IGRboolean RScalccalib __((IGRlong *message, IGRdouble *red_exponent, IGRdouble *green_exponent, IGRdouble *blue_exponent));
extern IGRboolean RSloadcalib __((IGRlong *message, IGRushort *red_table, IGRushort *green_table, IGRushort *blue_table));
extern IGRboolean RSretcalib __((IGRlong *message, IGRushort *red_table, IGRushort *green_table, IGRushort *blue_table));

#if defined(__cplusplus)
}
#endif


#undef __
