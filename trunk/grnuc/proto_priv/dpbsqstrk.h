#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpbsqstrk.C */
extern IGRboolean DPbsqstrk __((
   IGRint *message,
   struct IGRbsp_surface *bsp_s,
   struct IGResqbs *ele_attr,
   struct IGRdisplay *dis_attr,
   IGRint gpipe_id, IGRint win_no,
   IGRint flags, IGRint blend, int draw_opt ));

extern int TSwriteRLT __((FILE *wfp, struct IGResqbs *r));

#if defined(__cplusplus)
}
#endif


#undef __
