#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpclpstack.C */
extern IGRint DPpush_clip __((
   IGRlong *msg,
   IGRboolean rect,
   IGRboolean front,
   IGRboolean back,
   IGRdouble range[6],
   IGRint gpipe_id,
   IGRdouble vw_volume[6] ));

#if defined(__cplusplus)
}
#endif


#undef __
