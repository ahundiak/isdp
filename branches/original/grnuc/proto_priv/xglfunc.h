#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/xglfunc.C */
extern int XGLRect __((int win_no, int color, double xlow, double xhi, double ylow, double yhi, double zhi, double zlow));
extern int XGLFillRectangle __((int win_no, int color, int xlow, int xhi, int ylow, int yhi));
extern int XGLStrokeBsplineCurve __((int win_no, int order, int numpoles, double *poles, int numknots, double *knots, double *weights, int rational, int num_boundaries, double *bdrys, Xgl_pt_list *xgl_crv_poles, float *xgl_crv_knots));
extern int FillRationalData __((Xgl_pt_f3h *ptr, double *poles, int numpoles, double *weights));
extern int FillNonRationalData __((Xgl_pt_f3d *ptr, double *poles, int numpoles));
extern int XGLInitCtx __((IGRint win_no));
extern int XGLDelCtx __((int win_no));
extern int XGL3DLinestr __((int win_no, double *points, int num_points));
extern int XGL3DPoint __((int win_no, double *points, int num_points));
extern int XGLCnvDbltoFloat __((float *flt, double *dbl, int n));
extern int XGLStrokeBsplineSurface __((int *msg, int win_no, struct IGRbsp_surface *surface, struct IGResqbs *ele_attr, IGRint options));
extern int XGLSetViewBound __((int win_no, double *range, int front, int back));
extern int XGLWinResizeProc __((int win_no));
extern int XGLClipView __((int win_no, double *range, int front, int back));
extern int XGLTransformWrite __((int win_no, double *trans_mtx, double tol, double tol_factor));
extern int XGLSetColor __((int win_no, int temp_color, int temp_wght, int temp_lstyle));
extern int XGLSetWeight __((int win_no, int temp_wght));
extern int Is_Xgl_in_use __((void));
extern int XGLGetWinfrGPnum __((int gp_num, int *win_no));
extern int XGLSetWinfrGPnum __((int gp_num, int win_no));
extern int XGLQuitOnError __((int win_no));
extern int XGLSetPlaneMask __((int win_no, int planes));
extern int XGLCtxPost __((int win_no, Xgl_boolean flag));
extern int qprintf __((void));
extern int XGLClearFrame __((int win_no));
extern short XGL_bbstroke __((int win_no, int u_order, int v_order, int u_num_poles, int v_num_poles, double *u_knots, double *v_knots, double *spoles, double *sweights, int rational, int bdry_size, double boundary[][2 ], int options, XGL_my_xyz *xyz_buffer, float *xyz_f_buf));
extern int XGLResetMtx __((int win_no));

#if defined(__cplusplus)
}
#endif


#undef __
