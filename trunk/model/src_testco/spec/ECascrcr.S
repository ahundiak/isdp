/* ###################   APOGEE COMPILED   ################## */
class specification ECascrcr (1:0) of ECelement;
                    

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
#include "ecascrcr.h"



instance ECascrcr
   {
    IGRint XXXXX;
   IGRboolean dist_opts_form;
   IGRboolean curv_opts_form;
   IGRboolean knot_opts_form;
   IGRboolean pole_opts_form;
   IGRboolean to_next_linestring;
   IGRboolean reference_curve;
   IGRboolean wrong_element;
   IGRboolean from_curve_creation;
   IGRboolean locate_on;
   IGRboolean ls_is_visible;
   IGRboolean show_curvature;
   IGRboolean show_distance;
   IGRboolean show_poles;
   IGRboolean show_knots;
   IGRboolean commandstate;
   IGRboolean command;
   IGRboolean error_flag;
   IGRboolean init_on;
   IGRboolean is_associative; /* associativity flag */
   IGRboolean optform_requested;
   IGRboolean cvraform_requested;
   IGRboolean distform_requested;
   IGRboolean spolform_requested;
   IGRboolean skntform_requested;
   IGRboolean mainform_requested;
   IGRboolean edtform_requested;
   IGRboolean curvature_on_screen;
   IGRboolean first_point;
   IGRboolean tangent_on_screen;
   IGRboolean linestring_was_modified;
   IGRboolean blank_row;
   IGRboolean delete_row;
   IGRboolean form_event_handling;
   IGRboolean curve_exists;
   IGRboolean new_curve_created;
   IGRboolean something_done;
   IGRboolean all_fixpts_set;
   IGRboolean assoc_delay_set;
   IGRboolean free_para_type;
   IGRboolean free_knot_type;
   IGRboolean free_type_on;
   IGRboolean inter_knot_manip;
   IGRboolean cvra_gr_on;
   IGRboolean dist_ls_on, dist_gr_on;
   IGRboolean spol_ls_on, spol_gr_on;
   IGRboolean sknt_ls_on, sknt_gr_on;
   IGRuint    info_type;
   OMuint     num_comps;
   IGRint nlcids;
   IGRint undo_type;
   IGRint undo_num;
   IGRint blank_row_no;
   IGRint delete_row_no;
   IGRint fcolor;
   IGRint fweight;
   IGRint  no_pts;
   IGRlong ncon; /* total no of consttaints */
   IGRlong nvx; /* no of points in vertex table */
   IGRlong nta; /* no of tangent constraints in vertex table */
   IGRlong nfp; /* no of fix point constraints in vertex table */
   IGRint  ncuv; /* no of curvature constraints */
   IGRlong nfa; /* no of weight conditions in vertex table */
   IGRint  nknot; /* no of knots in knots vector */
   IGRint  npara; /* no of parameters in parameter vector */
   short unsigned sptco;
   IGRuchar sptwt;
   IGRint edt_row;
   IGRint edt_pos;
   IGRint edt_col;
   IGRint edt_row_col_selected;
   IGRint lsname;
   IGRint vaction;
   IGRint fxpos;
   IGRint fypos;
   IGRint vix;
   IGRdouble sknot;
   IGRdouble ls_length;
   IGRdouble rho;
   IGRchar old_knot_type[12];
   IGRchar old_para_type[12];
   IGRchar errmsg[30]; 
   struct GRid highl_pt;
   struct GRid curve_id; /* the associated curve */
   struct GRid ref_curve_id;
   struct GRid ls_id;
   struct GRid cvra_gr;
   struct GRid dist_ls, dist_gr;
   struct GRid spol_ls, spol_gr;
   struct GRid sknt_ls, sknt_gr;
   IGRpoint sel_pt;
   IGRchar marker[10];
   struct GRlc_info ls_info; /* linestring */
   struct GRevent accev; /* accept event */
   struct GRevent ev[3];
   struct GRparms vxparms; /* parameters of selected vertex (segment2) */
   Form optform; /* option form */
   Form cvraform;
   Form distform;
   Form spolform;
   Form skntform;
   Form mainform; /* main form */
   Form edtform; /* table form */
   struct mainform_par mfp; /* main form parameter */
   struct IGRpolyline opl; /* old polyline */
   struct cv_struct {
             struct cvra_frm cvra_fm;           /* curvature radius  */
             struct dist_frm dist_fm;           /* curvature radius  */
             struct spol_frm spol_fm;           /* show poles        */
             struct sknt_frm sknt_fm;           /* show knots        */
   } cv;
   variable struct vertex_tbl utbl[10]; /* undo table */
   variable IGRdouble opts[60]; /* old polypoints */
   variable struct vertex_tbl vxt[20]; /* vertex table */
   variable struct ta_tbl tat[10]; /* tangent info */
   variable struct fxp_tbl fxt[60]; /*  fixpoint info */
   variable struct fac_tbl fat[10]; /* factor info */
   variable IGRdouble knots[1]; /* knot vector */
   variable struct eknot_tbl ekt[1]; /* knot vector interactive edit table */
   variable struct GRid lcids[5];
   variable struct pts {
               IGRboolean cdir;
               IGRdouble *lcptrs;
               IGRint npts;
                   } s[5];
   variable IGRdouble paras[1]; /* parameter vector */
   };

override init, wakeup, sleep, execute, status_disp;

message main_disp ();
message edt_disp ();
message cvra_disp();
message dist_disp();
message spol_disp();
message sknt_disp();

message opt_do_form  ( IGRlong   *msg        ; 
                       IGRint    form_label  ; 
                       IGRint    gadget_label; 
                       IGRdouble value        );
message cvra_do_form ( IGRlong   *msg        ; 
                       IGRint    form_label  ; 
                       IGRint    gadget_label; 
                       IGRdouble value       );
message dist_do_form ( IGRlong   *msg        ;
                       IGRint    form_label  ;
                       IGRint    gadget_label;
                       IGRdouble value       );
message spol_do_form ( IGRlong   *msg        ;
                       IGRint    form_label  ;
                       IGRint    gadget_label;
                       IGRdouble value       );
message sknt_do_form ( IGRlong   *msg        ;
                       IGRint    form_label  ;
                       IGRint    gadget_label;
                       IGRdouble value       );
message cvra_exec    ( IGRlong *msg ); 
message dist_exec    ( IGRlong *msg ); 
message spol_exec    ( IGRlong *msg ); 
message sknt_exec    ( IGRlong *msg ); 
message set_defaults ( IGRlong *msg );
message find_max_angle(IGRlong *msg);
message putpolyline(IGRlong *msg);
message draw_curve_and_tools(IGRlong *msg);
message determine_dist_length(IGRlong *msg; IGRdouble *d);
message det_neighbours(IGRlong *msg; IGRpoint p; struct IGRline *boreline; IGRint *no_pts; IGRpoint pnts);
message det_neighb2(IGRlong *msg; IGRlong row;  IGRint *no_pts; IGRpoint pnts);
message erase_analysis_tools(IGRlong *msg);
message draw_knot(IGRlong *msg; IGRboolean dpmode);
message comp_knot_vector(IGRlong *msg);
message comp_para_vector(IGRlong *msg);
message comp_and_disp_tangent(IGRlong *msg; IGRint row;IGRpoint cveval);
message comp_and_disp_curvat(IGRlong *msg; IGRint row; IGRpoint cveval;IGRpoint tang);
message delete_tangent(IGRlong *msg; IGRint row);
message delete_curvature(IGRlong *msg; IGRint row);
message search_for_curve(IGRlong *msg;  IGRchar **pasinfo);
message create_as_curve(IGRlong *msg);
message draw_vector (IGRlong *msg; IGRpoint p; enum GRdpmode dpmode;IGRboolean dir; IGRvector v);
message process_edit(IGRlong *msg);
message process_delete(IGRlong *msg; IGRint *row; IGRint *pos);
message select_ls_point (IGRlong *msg; IGRpoint p; IGRint *row; IGRint *pos);
message select_cv_point (IGRlong *msg; IGRpoint p; IGRdouble *knotpu; IGRpoint mvp; IGRint *vix);
message project_point (IGRlong *msg; IGRpoint p; IGRpoint pp);
message delete_vertex(IGRlong *msg);
message undo_last_edit(IGRlong *msg);
message highl_point(IGRlong *msg; IGRpoint p);
message get_poly_instances(IGRlong *msg);
message fill_tables(IGRlong *msg; struct v_info *asinfo);
message fill_form_tbl(IGRlong *msg);
message insert_vertex(IGRlong *msg; IGRpoint p;IGRint ptno;struct IGRline *boreline;IGRint *p1seg);
message main_do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label; IGRdouble value);
message edt_do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label; IGRdouble value);

end specification ECascrcr;
