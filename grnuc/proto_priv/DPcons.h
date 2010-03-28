#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPcons.I */
extern void DPset_default_zclip_flags __((IGRboolean front, IGRboolean back));

#if defined(__cplusplus)
}
#endif


#undef __
