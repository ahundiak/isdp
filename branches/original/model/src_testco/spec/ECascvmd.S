/* ###################   APOGEE COMPILED   ################## */
class specification ECascvmd (1:0) of ECelement;
                    

/*
HISTORY

   February 1994 dfl 	created;

*/

#include "emserr.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "FI.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpezmac.h"
#include "coplcmac.h"
#include "dpstruct.h"
#include "ECascvmd.h"



instance ECascvmd
   {
    IGRint XXXXX;
   IGRboolean command;
   IGRboolean common_dist;
   IGRboolean idls_req;
   IGRboolean ex_cmd_pressed;
   IGRboolean ex_pocket_pressed;
   IGRboolean cursor_sensitivity;
   IGRboolean range_mode;
   IGRboolean shape_mode;
   IGRboolean keep_planar;
   IGRboolean smooth;
   IGRboolean planar;
   IGRboolean stfix;
   IGRboolean stfree;
   IGRboolean stta;
   IGRboolean stcrv;
   IGRboolean efix;
   IGRboolean efree;
   IGRboolean eta;
   IGRboolean ecrv;
   IGRboolean display_status_form;
   IGRboolean dynamic;
   IGRboolean set_stpt;
   IGRboolean set_ept;
   IGRboolean old_command;
   IGRboolean esc_pressed;
   IGRboolean zoom_init;
   IGRboolean show_hedgehog;
   IGRboolean show_curvature;
   IGRboolean show_poles;
   IGRboolean show_distance;
   IGRboolean show_vertices;
   IGRboolean ls_found;
   IGRboolean crv_found;
   IGRboolean escaped;
   IGRboolean polypoints_allocated;
   IGRboolean error_flag;
   IGRboolean init_on;
   IGRboolean fromto;
   IGRboolean is_associative; /* associativity flag */
   IGRboolean optform_requested;
   IGRboolean left, right, symetric;
   IGRboolean form_event_handling;
   IGRboolean cvra_gr_on;
   IGRboolean dist_ls_on, dist_gr_on;
   short unsigned sptco;
   IGRuchar sptwt;   
   IGRint *response;
   IGRchar *response_data; 
   IGRint cvname;
   IGRint fxpos;
   IGRint fypos;
   IGRint shape_amount_left, shape_amount_right;
   IGRint shape, range;
   IGRint bed_a, bed_e, n_anf, n_end;
   IGRint   t_min, t_max, p_min, p_max, p_s, m_p;
   IGRint  nvx;
   IGRint cms;
   IGRdouble smfac;
   IGRdouble mark_px, mark_py, mark_pz;
   IGRdouble px_old, py_old, pz_old;
   IGRdouble plocp[3];
   IGRdouble *pols_x, *pols_y, *pols_z, *pol_x, *pol_y, *pol_z;
   IGRdouble *vec_x, *vec_y, *vec_z, *weigh, *bf, *p_par, 
             *pole, *ugpole, *opole, *knot;
   IGRdouble *ppt, *vx, *par_vec, *cv_pts, *dists;
   IGRdouble l_vek;
   IGRdouble pot_a, pot_e;
   IGRdouble prodist;
   IGRdouble point_t[3];
   IGRdouble u_par;
   IGRchar old_knot_type[12];
   IGRchar errmsg[30]; 
   IGRchar text_string[10];
   IGRshort text_length;
   struct IGRplane 	plane;
   IGRpoint 		plane_point;
   IGRvector 		plane_normal;
   struct istruct *infos;
   struct GRid l_o;
   struct GRid highl_pt;
   struct GRid mark_point_id;
   struct GRid curve_id; /* the associated curve */
   struct GRid cvra_gr;
   struct GRid dist_ls, dist_gr;
   struct GRlc_info cv_info; /* curve */
   struct GRlc_info ls_info; /* linestring for distance measurement */
   struct GRevent accev; /* accept event */
   struct GRevent baccev; 
   struct GRevent dyaccev; /* accept event */
   OM_S_OBJID window_objid;
   IGRdouble actcurp[3];
   IGRpoint from_pnt;
   IGRpoint to_pnt;
   IGRpoint pnt_lot;
   struct GRevent ev[3];
   struct IGRbsp_curve *crv;
   Form optform; /* options form */
/*   struct cv_struct {
             struct cvra_frm cvra_fm;     
             struct dist_frm dist_fm;     
   } cv; */
   };

override init, wakeup, sleep, execute, status_disp;

message opt_do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label; IGRdouble value);
message get_bsp_info(IGRlong *msg);
message det_crv_plane(IGRlong *msg);
message create_curve_dynamics_buffer(IGRlong *msg; IGRint *response);
end specification ECascvmd;
