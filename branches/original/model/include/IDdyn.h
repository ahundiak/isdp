#ifndef IDdyn_include
#define IDdyn_include

#include "dpstruct.h"

/* define a structures used in performing dynamics */

struct DP_sfisocv
{
  struct DPele_header header[2];
  struct GRlc_info *loc_obj;
  struct IGRbsp_surface *bspsf;
  IGRshort pole_direction;
  IGRdouble u_par, v_par;
  IGRpoint proj_pt;
};

struct DP_sfinspls
{
  struct DPele_header header[2];
  struct IGRbsp_surface *surf;
  IGRdouble *ins_poles;
  IGRint num_poles, index;
  IGRpoint cur_pt;
  IGRshort pole_direction;
};

/* define curve draw type */
#define CV_POINTS_UNIFM 1	/* uniform curve by points */
#define CV_POINTS_NONUNIFM 2	/* nonuniform curve by points */
#define CV_POLES_UNIFM 3	/* unifomr curve by poles */
#define CV_POLES_NONUNIFM 4	/* nonuniform curve by poles */

struct DPbspcv
{
  struct DPele_header header[2];
  IGRint num_points;
  IGRdouble *points;
  IGRboolean draw_curve;
  IGRshort cv_order;
  IGRboolean cv_periodic;
  IGRint mytype;
  IGRdouble lenvec_tol;
  IGRboolean have_tan;
  IGRvector tan;
};

struct DPaddnl_info
{
  struct DPbspcv dyn_cv;
  IGRint num_stat_elem;
  struct DPele_header stat_elem_buf[2];
};

#endif
