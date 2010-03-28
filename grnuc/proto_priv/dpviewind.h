#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpviewind.I */
extern IGRint DPsetviewind __((IGRint type, IGRdouble *point, struct DP_information *dp_info, struct DPviewinfo *old));
extern IGRint DPresetviewind __((struct DP_information *dp_info, struct DPviewinfo *old));
extern void DPinq_vi_info __((IGRint *flag, IGRint *type, IGRdouble *point));

#if defined(__cplusplus)
}
#endif


#undef __
