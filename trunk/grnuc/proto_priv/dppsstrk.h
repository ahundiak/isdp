#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dppsstrk.C */
extern IGRboolean DPpsstrk __((
   IGRint *message,
   struct IGRpointset *pt_set,
   struct IGResps *ele_attr,
   struct IGRdisplay *dis_attr,
   IGRint gpipe_id,
   IGRint win_no,
   IGRdouble *mat,
   IGRshort mtx_type,
   IGRint flags,
   IGRdouble *depths,
   int draw_opt ));

#if defined(__cplusplus)
}
#endif


#undef __
