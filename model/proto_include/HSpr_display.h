/*
 *  HSpr_display.h: The prototype file for the 
 *                  hsurf/src/display_func directory
 */
 

#if defined(__cplusplus)
extern "C" {
#endif

#include "igrtypedef.h"
#include "igewindow.h"

/*---HSd_af_ifb.c---------------------------------------------*/

extern void HSarea_fill_ifb ( struct trapezoid *);

/*---HSd_af_op.c----------------------------------------------*/

extern void HSarea_fill_opaque ( struct trapezoid *);

/*---HSd_af_tn.c----------------------------------------------*/

extern void HSarea_fill_trans ( struct trapezoid *);

/*---HSd_af_op_rp.c-------------------------------------------*/

extern void HSarea_fill_opaque_ramp ( struct trapezoid *);

/*---HSd_af_tn_rp.c-------------------------------------------*/

extern void HSarea_fill_trans_ramp ( struct trapezoid *);

/*---HSd_co_ifb.c---------------------------------------------*/

extern void HSconstant_shade_ifb ( struct trapezoid *);

/*---HSd_co_op.c-------------------------------------------*/

extern void HSconstant_shade_opaque ( struct trapezoid *);

/*---HSd_co_tn.c-------------------------------------------*/

extern void HSconstant_shade_trans ( struct trapezoid *);

/*---HSd_co_op_dm.c-------------------------------------------*/

extern void HSconstant_shade_opaque_direct ( struct trapezoid *);

/*---HSd_co_op_ht.c-------------------------------------------*/

extern void HSconstant_shade_opaque_half ( struct trapezoid *);

/*---HSd_co_tn_dm.c-------------------------------------------*/

extern void HSconstant_shade_trans_direct ( struct trapezoid *);

/*---HSd_co_tn_ht.c-------------------------------------------*/

extern void HSconstant_shade_trans_half ( struct trapezoid *);

/*---HSd_ctbl.c-----------------------------------------------*/

extern int display_colortable ( int, int, int, int, int );

/*---HSd_drawtrap.c-------------------------------------------*/

extern void HSdraw_trapezoid  ( struct trapezoid *);

/*---HSd_dzine.c----------------------------------------------*/

extern void HSstart_dzine    ( struct polyline_vertex *);
extern void HScontinue_dzine ( struct polyline_vertex *);

/*---HSd_fem_dir.c--------------------------------------------*/

extern void HSfem_direct ( struct hsfem_trapezoid *);

/*---HSd_fem_dirR.c-------------------------------------------*/

extern void HSfem_direct_ramp ( struct hsfem_trapezoid *);

/*---HSd_fem_dith.c-------------------------------------------*/

extern void HSfem_dithered ( struct hsfem_trapezoid *);

/*---HSd_fem_ditR.c-------------------------------------------*/

extern void HSfem_dithered_ramp ( struct hsfem_trapezoid *);

/*---HSd_fixedpt.c--------------------------------------------*/

extern int fixed_divide (int, int, int *, int *, int *);

/*---HSd_paint.c----------------------------------------------*/

extern void HSpaint                 ( IGRint );
extern void HSpaint_screen_ROP      ( void );
extern void HSpaint_screen_putpixel ( void );
extern void HSpaint_screen_stub     ( void );
extern void HSpaint_screen_merge24  ( void );
extern void HSpaint_screen_merge    ( void );
extern void HSpaint_screen_IFB      ( void );

/*---HSd_pl_ln.c----------------------------------------------*/

extern void HSstart_polyline_rop    ( struct polyline_vertex *);
extern void HScontinue_polyline_rop ( struct polyline_vertex *);

extern void HSstart_polyline_ifb    ( struct polyline_vertex *);
extern void HScontinue_polyline_ifb ( struct polyline_vertex *);

/*---HSd_pt.c-------------------------------------------------*/

extern void HSdraw_point_ROP ( struct polyline_vertex *);
extern void HSdraw_point_IFB ( struct polyline_vertex *);

/*---HSd_radge.c----------------------------------------------*/

extern void HSstart_pline_radge_delete    ( struct polyline_vertex *);
extern void HSstart_pline_radge           ( struct polyline_vertex *);
extern void HScontinue_pline_radge_delete ( struct polyline_vertex *);
extern void HScontinue_pline_radge        ( struct polyline_vertex *);
extern void HStrap_radge_delete           ( struct trapezoid *);
extern void HStrap_radge                  ( struct trapezoid *);
extern void HStrap_radge_filled           ( struct trapezoid *);

/*---HSd_repaint.c--------------------------------------------*/

extern void HSrepaint ( struct IGEdit_range * );

/*---HSd_sm_op.c------------------------------------------*/

extern void HSsmooth_shade_opaque ( struct trapezoid *);

/*---HSd_sm_tn.c------------------------------------------*/

extern void HSsmooth_shade_trans ( struct trapezoid *);

/*---HSd_sm_fmtri.c------------------------------------------*/

extern void HSsmooth_shade_fem_tritrap ( struct trapezoid *);


/*---HSd_sm_ifb.c--------------------------------------------*/

extern void HSsmooth_shade_ifb ( struct trapezoid *);

/*---HSd_sm_op_dm.c------------------------------------------*/

extern void HSsmooth_shade_opaque_direct ( struct trapezoid *);

/*---HSd_sm_op_ht.c------------------------------------------*/

extern void HSsmooth_shade_opaque_half ( struct trapezoid *);

/*---HSd_sm_tn_dm.c------------------------------------------*/

extern void HSsmooth_shade_trans_direct ( struct trapezoid *);

/*---HSd_sm_tn_ht.c------------------------------------------*/

extern void HSsmooth_shade_trans_half ( struct trapezoid *);

/*---HSd_swine.c---------------------------------------------*/

extern void HSstart_swine    ( struct polyline_vertex *);
extern void HScontinue_swine ( struct polyline_vertex *);

/*---HSd_vedge.c-------------------------------------------- */

extern void   HSdraw_span            ( double, short );			
extern void   HSclose_old_line       ( void );
extern double HSget_u                ( struct polyline_vertex *);
extern void   HSstart_pline_vedge    ( struct polyline_vertex *);
extern void   HScontinue_pline_vedge ( struct polyline_vertex *);
extern void   HStrap_vedge           ( struct trapezoid *);
extern void HScreate_2nd_order_curve ( IGRint, IGRpoint *, struct IGRbsp_curve *, IGRdouble, IGRdouble );
extern void HScreate_pline           ( struct IGRpolyline *);

/*---HSd_ztrap.c---------------------------------------------*/

extern void HSzbuf_trap_ifb ( struct trapezoid *);

#if defined(__cplusplus)
}
#endif
