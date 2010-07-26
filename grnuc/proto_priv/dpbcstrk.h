#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpbcstrk.C */
extern int TSisGraphicsATP __((void));
extern int TSsetGraphicsATPflag __((int i));
extern int TSSetGraphicsATPFile __((char *fname));

extern IGRboolean DPbcstrk __((
   IGRint *message,
   struct IGRbsp_curve *bsp_c, 
   struct IGResbc *ele_attr,
   struct IGRdisplay *dis_attr,
   int gpipe_id,
   int win_no,
   int flags,
   int unsigned disp_flags,
   struct IGRdisplay **bound_att,
   int num_bound_att,
   int **bound_att_indices,
   int blend,
   int draw_opt));

#if defined(__cplusplus)
}
#endif


#undef __
