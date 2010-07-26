#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpcliprng.C */
extern IGRint DPintr_clp_rng __((IGRlong *msg, IGRdouble *old_range, IGRdouble *range, struct DP_information *dp_info));
extern void DPreset_clp_rng __((IGRlong *msg, IGRdouble *old_range, struct DP_information *dp_info));
extern IGRint DPintr_rng __((IGRlong *msg, IGRdouble *wld_range, IGRdouble *dit_range, IGRdouble *matrix, IGRdouble *new_dit_range));
extern IGRint DPintr_2_rng __((IGRlong *msg, IGRdouble *range1, IGRdouble *range2, IGRdouble *new_range));

#if defined(__cplusplus)
}
#endif


#undef __
