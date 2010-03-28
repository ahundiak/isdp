#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpsetdsp.C */
extern void DPinq_style __((IGRshort index, unsigned short *style));
extern void DPdefine_style __((short index, unsigned short style));

#if defined(__cplusplus)
}
#endif


#undef __
