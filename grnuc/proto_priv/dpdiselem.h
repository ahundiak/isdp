#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpdiselem.C */
extern IGRint DPdiselem __((IGRint *msg, struct DPele_header *buffer, enum GRdpmode *mode, struct DP_information *dp_info));
extern void DPset_texture __((IGRint win_no, IGRint pattern));
extern void DPset_blendarea __((IGRint win_no, IGRint pattern));
extern void DPenable_stop_highlight __((void));
extern void DPdisable_stop_highlight __((void));
extern int DPconvert_xpattern_if_blend __((int count, int offset, unsigned char points[], int *new_count, unsigned char new_points[]));

#if defined(__cplusplus)
}
#endif


#undef __
