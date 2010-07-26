#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dptxstrk.C */
extern int DPtxstrk __((
   IGRint *msg,
   struct IGRlbsys *lbsys,
   struct IGResintx *txt_ele,
   struct IGRdisplay *dis_attr,
   IGRint win_no,
   IGRint gpipe_id,
   struct DPfnt_os_tbl *os_tbl_ptr,
   IGRint flags,
   IGRuint disp_flags,
   IGRdouble vw_scale,
   IGRint drawplanes,
   IGRdouble *strk_buf,
   IGRint *num_points,
   int draw_opt ));

#if defined(X11)
extern void DPdrawtext __((Display *mydisplay, struct DPoutldraw *outldraw, GC mygc, Real64 x, Real64 y, Outl3DVertex vertices[], int numverts[], int numpolys, OutlCharInfo *charInfo));
extern void DPbmapdrawtext __((Display *mydisplay, int myscreen, struct DPoutldraw *outldraw, GC mygc, int x, int y, int width, int height, BmapBitmap *bitmap, Real64 bx, Real64 by, BmapCharInfo *charInfo));
#else
extern void DPdrawtext __((struct DPoutldraw *outldraw, Real64 x, Real64 y, Outl3DVertex vertices[], int numverts[], int numpolys, OutlCharInfo *charInfo ));
extern void DPbmapdrawtext __((struct DPoutldraw *outldraw, int x, int y, int width, int height, BmapBitmap *bitmap, Real64 bx, Real64 by, BmapCharInfo *charInfo));
#endif

extern void DPenable_fill_text __((void));
extern void DPdisable_fill_text __((void));
extern void DPbmap_display __((int flag));

#if defined(__cplusplus)
}
#endif


#undef __
