 
class  implementation  ECblendsf;


# include "VCdef.h"              /*... test  ...*/

# include <stdio.h>
# include <math.h>  

# include "bsparameters.h"        /*  bspmath  */
# include "bstypes.h"             /*  bspmath  */

# include "EMSmsgdef.h"
# include "griomacros.h"
# include "exdef.h"
# include "igr.h"
# include "dp.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"
# include "grmsg.h"
# include "emserr.h"
# include "dpmacros.h"
# include "EMSasnuc.h"
# include "EMSasmacros.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "expression.h"
# include "expmacros.h"
# include "ASmsg.h"
# include "ECmsg.h"
# include "ecbls_macros.h"
# include "dpstruct.h"  
# include "igrtypedef.h" 
# include "igrdef.h"  
# include "msdef.h"           /*  MS message codes  */
# include "OMerrordef.h"      /*  OM error definitions  */
# include "msmacros.h"           
# include "emsmacros.h"
# include "igrdp.h"
# include "dpezmac.h"         /*  dp$inq_window   */
# include "dpdef.h"           /*  dynamic flag  */
# include "exmacros.h"        /*  ex$wait..  */

# include "gocmacros.h"       /*  GRgetabsg macro  */
# include "emsdef.h"
# include "EMSfrtdef.h"
# include "OMmacros.h"        /* For OM_BLOCK_MOVE */
# include "EMSmvpl.h"         /* For EMMOVE_POLE... */

# include "EMSblend_sf.h"
# include "ecbls_inf.h"

# include "bsdistptli.h"      /*  function prototype  */ 
# include "bsdistptpt.h"      /*  function prototype  */ 
# include "bsint2lns.h"       /*  function prototype  */ 
# include "bsdptseg2.h"       /*  function prototype  */ 
# include "bsproj0.h"         /*  function prototype  */
# include "bsptoldtnw.h"      /*  function prototype  */
# include "bsptnwtold.h"      /*  function prototype  */
# include "bsdotp.h"          /*  function prototype  */
# include "bscrossp.h"        /*  function prototype  */
# include "bsnorvec.h"        /*  function prototype  */
# include "bscveval.h"        /*  function prototype  */
# include "bsmdstptcv.h"      /*  function prototype  */
# include "bsmdistcvcv.h"     /*  function prototype  */
# include "bscveval.h"        /*  function prototype  */
# include "bssfeval.h"        /*  function prototype  */
# include "bssfevaln.h"       /*  function prototype  */
# include "bsconstprcv.h"     /*  function prototype  */
# include "bsbx2.h"           /*  function prototype  */
# include "bsmkcvscp.h"       /*  function prototype  */
# include "bsblndsrfg2.h"     /*  function prototype  */
# include "bssfeval1.h"       /*  function prototype  */
# include "bsmkvec.h"         /*  function prototype  */
# include "bsfndspnarr.h"     /*  function prototype  */

# include "bsalloccv.h"       /*  function prototype  */
# include "bsfreecv.h"        /*  function prototype  */
# include "bsallocsf.h"       /*  function prototype  */
# include "bsfreesf.h"        /*  function prototype  */

# include "bserr.h"                /*  For BSERROR  */
# include "bsconic.h"              /*  BSURIGHTBND...  */

# define MAX(x,y)    ((x) < (y) ? (y) :(x))
# define MIN(x,y)    ((x) < (y) ? (x) :(y))
# define ABS(x)      ((x) < 0 ? -(x) : (x))

 
#define NUM_DYN         13    /*  number of dynamic elements   */  
#define NUM_HH_POINTS  100    /*  number of hedgehog points    */  


#define CATCH          2.0    /*  bar sensitive faktor (in bar line width)  */
#define FAKQ          0.08    /*  bar display offset faktor, looks nice  */
#define FAKDARK       0.04    /*  zoom marker dark offset  */
#define FAKZOOM        2.0    /*  zoom bar marker offset faktor  */
#define FAK_INT_D     0.25    /*  int blend  marker distance faktor  */
#define FAK_INT_S     0.14    /*  int blend marker size faktor  */
#define FAK_MID        0.5    /*  mid bar position  */
#define WITH_FAKT       60    /*  bar leader line distance faktor  */
#define R_MIN_FAKT    0.04    /*  hedgehog size relativ to blend extend  */

#define P_WEIGHT_MIN     7    /*  min sensitiv point weight  */
#define P_WEIGHT_MAX    14    /*  max sensitiv point weight  */
#define P_WEIGHT_MED    10    /*  med sensitiv point weight  */
#define L_WEIGHT_MIN     1    /*  min sensitiv line weight   */
#define L_WEIGHT_MAX     4    /*  max sensitiv line weight   */
#define L_WEIGHT_MED     2    /*  med sensitiv line weight   */

#define WRK_TANG1        1    /*  work:  move tangent 1  */
#define WRK_TANG2        2    /*  work:  move tangent 2  */
#define WRK_INT_BLND1    3    /*  work:  move internal blend 1  */
#define WRK_INT_BLND2    4    /*  work:  move internal blend 2  */
#define WRK_ROT_VEC1     5    /*  work:  rotate int blend vector 1  */
#define WRK_ROT_VEC2     6    /*  work:  rotate int blend vector 2  */
#define WRK_HEDGEHOG     7    /*  work:  move hedgehog marker  */



#define RMAX     100000000    /*  max value  */
#define SIZE          1024    /*  respose buffer length  */
 
#define MINVAL       0.001    /*  minimum ratio value usable  */

#define NUM_U_V_LINES    21    /*  number of u and v lines  */
#define END_BY_MOVEON    3
#define END_BY_CMD       5


# define VCdebug_return   1                 /*... test on ...*/


extern OMuword  OPP_GRcurve_class_id;
extern OMuword  OPP_EMSsubbs_class_id;

from GRvg       import GRgetsize,
                       GRgenabsg,
                       GRgetgeom;

                from GRvg       import GRconstruct;   /*  test only  */



/* text for prompts and other messages */

/*                       "Select task to modify/options/terminate"  */
#define SELECT_NEXT_DYN   EMS_P_Se_Ta_Mo__Op__Te  
       
/*                       "Modify tangent 1/Accept"  */
#define DYN_TANGENT_1     EMS_P_Mo_Ta_1__Acc

/*                       "Modify tangent 2/Accept"  */
#define DYN_TANGENT_2     EMS_P_Mo_Ta_2__Acc

/*                       "Modify internal isocurve 1 position/Accept"  */
#define DYN_INT_POINT1    EMS_P_Mo_In_Is_1_Po__Acc 

/*                       "Modify internal isocurve 2 position/Accept"  */
#define DYN_INT_POINT2    EMS_P_Mo_In_Is_2_Po__Acc

/*                       "Modify vector on surface 1/Accept"  */
#define DYN_ROT_POINT1    EMS_P_Mo_Ve_Su_1__Acc     

/*                       "Modify vector on surface 2/Accept"  */
#define DYN_ROT_POINT2    EMS_P_Mo_Ve_Su_2__Acc    

/*                       "Select isocurve for curvature display/Accept"  */
#define DYN_HEDGEHOG      EMS_P_Se_Is_Cu_Di__Acc 



static IGRdouble  mat[3][3];              /*  view rotation matrix  */
static IGRvector  trans_vec;              /*  translate vector = none */

static IGRdouble  scale;
static IGRpoint   mouse_rot;
static IGRpoint   bore_base;                    

static IGRdouble  cor_sym_dir;            /* correction symmetric  direction */



struct bar_data
       {

         struct   IGRbsp_surface *sf;      /*  pointer to the base surface  */
         struct   IGRbsp_surface *sf_orig; /*  pointer to the base surface  */
         struct   IGRbsp_surface *csf;     /*  pointer to the  collar surface */

         IGRboolean zoom_activ;        /*  zoom activ for bar | old=zoom1    */
         IGRboolean dyn_vector;        /*  TRUE if dyn vector input          */
         IGRboolean dyn_bar;           /*  TRUE if dyn bar input             */
         IGRboolean dyn_iso;           /*  dynamic int blendscreen flag      */

         IGRshort   ind;               /*  uv-side index  */
         IGRdouble  cur_dir;           /*  current bar direction  +/- 1 */
         IGRdouble  aval_dir;          /*  abs direction value  */
         IGRdouble  base_dir;          /*  base bar direction  */
         IGRdouble  last_dir;          /*  last bar direction  +/-   */
         IGRint     cont;              /*  tangency/curvature switch  */
         IGRint     boundary_flag;     /*  blend generation switch  */

         IGRint     red_fakt;          /*  bar display reducing faktor */
         IGRdouble  cur_sensi;         /*  bar sensibility faktor */

         IGRdouble  bar_length_cur;   
         IGRdouble  dyn_bar_length;         
         IGRdouble  bar_length; 
         IGRdouble  bar_ratio;
         IGRdouble  last_ratio;
         IGRdouble  base_bar_ratio;
         IGRvector  bar_length_base;
         IGRdouble  w_dir;             /*  internal bar work direction  */

         IGRdouble  bar_length_rot;
         IGRdouble  bar_length_rot_2d;
         IGRdouble  bar_2d_factor;    
         IGRpoint   mid_linea_rot;
         IGRpoint   mid_lineb_rot;
         IGRdouble  line_2d[2][3];
         IGRpoint   proj_2d;
         IGRpoint   bar_base_dir;
         IGRdouble  bar_leng_2d;
         IGRvector  cur_vector; 


         /*  zoom  */
         IGRpoint   z_point_cur;
         IGRdouble  z_rel_bar_point; 
         IGRpoint   point_base;
         IGRpoint   z_point_base;      /*  basepoint bar if in zoom  */
         IGRdouble  fakt_dist_pos;     /*  cur used bar sensitiv pos (zoom) */
         IGRdouble  fakt_zoom_pos;     /*  cur zoom base base pos  */
         IGRdouble  z_offset[3];       /*  perpto bar normalized for zoom  */
         IGRdouble  zoom_length;
         IGRdouble  fak_mid;
         IGRdouble  sym_offset;        /*  real length of ratio bar  */
         IGRdouble  sym_dir;           /*  real direction of ratio bar  */

         /*  evaluation / direction  */
         IGRdouble cur_par_sf_s;       /*  current surfave start-parameter  */
         IGRdouble cur_par_sf_e;       /*  current surface end_parameter    */
         IGRdouble cur_par_sf_min;     /*  minimum surface parameter    */
         IGRdouble par1, par2;         /*  current surface bar point uv-par */
         IGRdouble b_par1, b_par2;     /*  current belnd surface bar point uv-par */

         IGRpoint  eval[4];            /*  dummy !!!  */
         IGRvector evaluv[4];          /*  first uv-partial pair (r/l)  */
         IGRpoint  evaln;              /*  combined uv-partial normalized  */
         IGRpoint  eval_t[4];          /*  surface midpoint and 1st derivate  */
         IGRpoint  evali[4];           /*  int blend point (bar) + tangent  */
         IGRpoint  evali_mouse;        /*  int blend point  mouse view  */
         IGRpoint  evaliv_mouse;       /*  int blend  1st derivate mouse view */
         IGRpoint  evali_2d;           /*  int blend point 2d  */
         IGRpoint  evaliv_2d;          /*  int blend vector 2d  */
         IGRvector offseti_2d;         /*  perpto int blend1 dir norm. rot.  */
         IGRvector offsetp_2d;         /*  perpto int blend1 dir norm. rot.  */
         IGRvector offseti;            /*  perpto int blend1 dir normalized  */

         IGRpoint  eval_rot;           /*  point rotated */
         IGRdouble offset[3];          /*  perpto bar normalized  */


         /*  internal blend  */
         IGRint     cv_flag;           /*  internal blend flag  */
         IGRpoint   last_int;          /*  last used int blendpoint  */
         IGRpoint   p_sensi_int;       /*  cur view dep int blend marker pos */
         IGRdouble  offsetx_2d[3];     /*  perpto int blend1 dir norm. rot.  */
         IGRdouble  offsetx[3];        /*  perpto int blend1 dir normalized  */
         IGRdouble  par_iso;           /*  parameter of iso-parametric curve */
         IGRint     col_dir;           /*  collar sfr gen direction type  */
         IGRvector  dir_vec[2];        /*  blend direction vector  */
         struct GRlc_info ib_crv;      /*  int blend curve locate info  */
         struct IGRbsp_curve *acv;     /*  ext blend dir curve  */
         

         /*  blendcurve generation variables  */
         IGRdouble valx;
         IGRdouble cur_par_cv;         /*  actual int blend param    */
         IGRdouble wrk_par_cv ;        /*  work int blend param      */
         struct IGRbsp_curve *cv;      /*  external blend curve      */ 
         struct IGRbsp_curve *cv_a;    /*  iso curve main dir        */ 
         struct IGRbsp_curve *cv_b;    /*  iso curve minor dir       */ 

         /*  bar display  */
         IGRpoint   point_cur;         /*  current 3d bar sensitive point  */
         IGRpoint   point_bar_end;     /*  current 3d bar end point  */
         IGRpoint   mid_linea;
         IGRpoint   mid_lineb;


         /*        main dynamic bar                                       */
         /* _c   = current dynamic end marker                             */
         /*        current work position is a dark dot in the zoom bar    */

         struct IGRpolyline line;
         struct IGRpolyline pntsc;
         struct IGRpolyline linei;     /*  internal blend sign  */ 
         struct IGRpolyline linev;     /*  int bl. vector sign  */

         IGRdouble  points[6];       /*  dynamic line  */          
         IGRdouble  pointsc[3];      /*  coord. of point/c buffer  */
         IGRdouble  pointi[18];      /*  coord. of int blend sign buffer */
         IGRdouble  pointv[18];      /*  coord. of int bl. vector sign buffer */

         };



static struct bar_data  bar1_data;         /*  basic surface 1  data  */
static struct bar_data  bar2_data;         /*  basic surface 2  data  */

static IGRboolean     leader_line;         /*  true if bar leaderline display  */
static IGRboolean     first_run;           /*  first dynamic step  */
static IGRint         last_activ_bar;      /*  last activ bar  (0 = none)  */
static IGRdouble      maxdist;             /*  max distance for dynamic reaction  */
static IGRdouble      eps;                 /*  general used work eps  */
static IGRint         ind_arr;             /*  current dyn display buffer number */
static IGRshort       last_wrk_sel;        /*  cuurent selected modify mode  */
static IGRlong        last_w_window;       /*  last mouse window used  */
                                           /*  -1 = initial            */
static OM_S_OBJID     last_w_objid;        /*  last mouse window objid used  */
static uword          last_w_osnum;        /*  last mouse window osnum used  */

static IGRdouble  dist_bar1_bar2;
static IGRdouble  dist_bar1_bar2_rot;
static IGRdouble  fakt2d3d;              /*  length faktor 2d/3d bar length */
static IGRdouble  fak_marker;            /*  sensitiv barpoint marker length */
static IGRdouble  disp_fakt;             /*  current work view zoom factor  */
static IGRdouble  offs_int_d;            /*  view dep int blend sign dist 1  */
static IGRdouble  offs_int_s;            /*  view dep int blend sign dist 2  */

/*  blend generation variables  */
static IGRboolean symmetric;              /*  symmetric surface build  */   
static IGRshort   blend_order;            /*  order of blend curve  */

static struct IGRbsp_surface  *blndsrf;    /* pointer to the blend surface */

static struct IGRbsp_curve *cvw;           /*  int blend select curve  */

static IGRdouble tolarr[3];              /*  [0]  same point tolerance       */
                                         /*  [1]  same angle tolerance       */
                                         /*  [2]  degeneracy of derivatives  */

static struct EMSblend_sf_end_condition  start_cond;
static struct EMSblend_sf_end_condition  ende_cond;

static struct IGRbsp_surface  *sf1;      /*  pointer to the work surface 1 */
static struct IGRbsp_surface  *sf2;      /*  pointer to the work surface 2 */
static IGRint     boundary_flag[2];
static IGRdouble  blend_pt_par[2][2];
static IGRdouble  pariso[2];
static IGRint     direction[2];
static IGRint     tangent_flag[2];
static IGRdouble  tangent_value[2];
static IGRint     curvature_flag[2];
static IGRint     approx_flag[2];
static IGRdouble  approx_fact[2];
static IGRint     inform;


  /*  commmon used dynamic values  */
  static struct DPele_header display_elements[NUM_DYN];  /*  display buffers */

  /*  Activate color, style, weight, ...  */
  static struct IGRdisplay dyn_bar_display;
  static struct IGRdisplay fix_bar_display;
  static struct IGRdisplay zoom_bar_display_d;
  static struct IGRdisplay zoom_bar_display_f;
  static struct IGRdisplay hedgehog_display;
  static struct IGRdisplay hd_base_display;
  static struct IGRdisplay pnt1_bar_display;
  static struct IGRdisplay pnt2_bar_display;
  static struct IGRdisplay int1_bar_display;
  static struct IGRdisplay int2_bar_display;
  static struct IGRdisplay dyn_vec1_display;
  static struct IGRdisplay dyn_vec2_display;
  static struct IGRdisplay hd_sgn_display;
  static struct IGRdisplay tsty_bar_display;


  static IGRpoint             mouse;          /*  mouse point 3d  */
  static IGRpoint             mouse_rot_2d;   /*  mouse point mouse view 2d  */ 
  static IGRdouble            rot_matrix[16]; /*  rotation matrix  */

  /*  hedgehog data  */
  static IGRboolean cv_diagnos;             /*  curvature diagnostics  */
  static IGRshort   hd_cur_opt;             /*  1: u = const / 2: u = const */
  static IGRint     hd_index;               /*  index iso curve in use      */
  static IGRdouble  hd_cur_uv;              /*  current hedgehog base curve */
  static IGRdouble  hd_cur_param;           /*  current sign pos iso param  */
  static IGRdouble  max_length;             /*  max length of offset        */
  static struct IGRbsp_curve *igel_edges[4];/*  surf blend curves           */
  static struct IGRbsp_curve *igel_projt[4];/*  surf blend curves projected */
  static struct IGRbsp_curve *igel_cur;     /*  iso curve blend surf cur. pos */
  static struct IGRbsp_curve *igel_sgn;     /*  current sign curve curve pointer  */
  static struct IGResbc      bc_attr;       /*  B-spline element specific attrib. */
  static struct IGRpolyline lineh;          /*  hedgehog display buffer   */
  static struct IGRpolyline lines;          /*  hedgehog pos sign buffer  */
  static IGRdouble pointss[12];             /*  hedgehog pos sign points */  
  static IGRdouble *orig_pointhh, *pointhh; /*  coord. of hedgehog buffer  */
  static IGRpoint   evalh[4];               /*  evaluated sign point + 3. deriv  */
  /*  hedgehog work buffers  */ 
  static IGRdouble   *hedge_buf;
  static IGRdouble   *nx, *ny, *nz, *rho, *p_x, *p_y, *p_z;




/*  dynamic surface display  */


  static struct IGRbsp_surface  *srf_disp;
  static struct IGResqbs         esqs;

  static IGRlong    u_end_pl, v_end_pl;
  static IGRlong    u_end_kt, v_end_kt;
  static IGRlong    u_np, v_np, u_nk, v_nk;
  static IGRlong    indx_u, indx_v;
  static IGRdouble  u_ktdel, v_ktdel;
 
  static IGRdouble  *p_u_rules;
  static IGRdouble  *p_v_rules;
  static IGRint     *p_u_bounds;
  static IGRint     *p_v_bounds;


/* ======================================================== */
/*  this routine initializes external blend curve handling  */
/* ======================================================== */

IGRint BLs_startup_exc(struct bar_data  *cur_bar,    /*  bar data array    */
                       IGRshort         work_step)   /*  0 , 1 , 2    */
                   /*  return = FALSE in case of error  */

{

  IGRlong     loc_msg;
  IGRlong     rc;                /*  BS return code    */
  IGRlong     sts;               /*  OM return status  */
  IGRlong     i;                 /*  loop index        */
  IGRpoint    result[4];
  IGRlong     num_bytes;         /*  used for allocation of memory purposes  */




  /*  handle internal blend by collar surface */

  IGRshort  u_order, v_order;
  IGRshort  u_num_poles, v_num_poles;
  IGRshort  num_bound = 0;
  struct IGRbsp_curve  *cv_dummy;    /*  external blend curve dummy */ 


  if (work_step == 0)
  {
    /*  save original surface data  */
    if (cur_bar->sf_orig == NULL)  cur_bar->sf_orig = cur_bar->sf;

    /*  get int blend curve data  */
    sts = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetsize (
                              &loc_msg,
                              &cur_bar->ib_crv.module_info.md_env.matrix_type,
			       cur_bar->ib_crv.module_info.md_env.matrix,
                              &num_bytes ),
                  senderid = NULL,
                  targetid = cur_bar->ib_crv.located_obj.objid,
                  targetos = cur_bar->ib_crv.located_obj.osnum);
    if (!(1&sts&loc_msg))  goto wrapup;

    cur_bar->cv = (struct IGRbsp_curve *) malloc(num_bytes);
    if (!cur_bar->cv)  goto wrapup;

    sts = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetgeom
                              (&loc_msg,
                              &cur_bar->ib_crv.module_info.md_env.matrix_type,
			      cur_bar->ib_crv.module_info.md_env.matrix,
                              (IGRchar *) cur_bar->cv),
                  senderid = NULL,
                  targetid = cur_bar->ib_crv.located_obj.objid,
                  targetos = cur_bar->ib_crv.located_obj.osnum);
    if (!(1&sts&loc_msg))  goto wrapup;

  }               /*   end of init  */


  if (work_step == 1)
  {
    if (cur_bar == &bar1_data)    cur_bar->acv = bar2_data.cv;  
    else                          cur_bar->acv = bar1_data.cv;  

    if (cur_bar->acv == NULL)
    {
      struct IGRbsp_surface  *sf_wrk;    /* pointer to the associated surface */
      struct IGRbsp_curve    *cv_iso;    /* pointer to the associated curve   */
      IGRint          cvx_flag;
      IGRdouble       edge_par;
      IGRboolean      tst_plan = FALSE; 
      IGRshort        opt;
      IGRshort        curve_order;
      IGRshort        curve_num_poles;

 
      /*  if no associated curve is there extract boundary edge curve  */
      if (cur_bar == &bar1_data) { sf_wrk = bar2_data.sf; cvx_flag = bar2_data.cv_flag;  }
      else                       { sf_wrk = bar1_data.sf; cvx_flag = bar1_data.cv_flag;  }
        
      if (cvx_flag == 2  ||  cvx_flag == 4)
      {  curve_order = sf_wrk->v_order; curve_num_poles = sf_wrk->v_num_poles; }
      else
      {  curve_order = sf_wrk->u_order; curve_num_poles = sf_wrk->u_num_poles; }

       BSalloccv(curve_order, curve_num_poles, sf_wrk->rational, NULL,
                 &cv_iso, &rc );  
      if (BSERROR(rc))  goto wrapup;  
      
      /*  extract iso parametric curves  */
      if (cvx_flag == 1)   {  opt = 2;  edge_par = 0.0;  }
      if (cvx_flag == 2)   {  opt = 1;  edge_par = 0.0;  }
      if (cvx_flag == 3)   {  opt = 2;  edge_par = 1.0;  }
      if (cvx_flag == 4)   {  opt = 1;  edge_par = 1.0;  }

      BSconstprcv(&rc, sf_wrk, &opt, &edge_par, &tst_plan, cv_iso);
      if (BSERROR(rc))  goto wrapup;
      cur_bar->acv = cv_iso;         /*  save replacement  */  
    }
  }

  if (work_step == 2)
  {  
    if (cur_bar->acv->order     != cur_bar->cv->order     
     || cur_bar->acv->num_poles != cur_bar->cv->num_poles)
    {
       struct IGRbsp_curve *b_curves[2];
       struct IGRbsp_curve *c_curves[2];

       b_curves[0] = cur_bar->cv;
       b_curves[1] = cur_bar->acv;

       BSmkcvscp(2, b_curves, c_curves, &rc);
       if (BSERROR(rc))  goto wrapup;
       if (b_curves[0])  {  free(b_curves[0]);  b_curves[0] = NULL;  }
       if (b_curves[1])  {  free(b_curves[1]);  b_curves[1] = NULL;  }

       cur_bar->cv  = c_curves[0];
       cur_bar->acv = c_curves[1];
       /*  exchance also on other block  */
       if (cur_bar == &bar1_data) { bar2_data.cv = cur_bar->acv;  bar2_data.acv = cur_bar->cv;  }
       else                       { bar1_data.cv = cur_bar->acv;  bar1_data.acv = cur_bar->cv;  }
    }
    u_order = cur_bar->cont + 1;
    v_order = cur_bar->cv->order;
    u_num_poles = cur_bar->cont + 1;
    v_num_poles = cur_bar->cv->num_poles;
    cv_dummy = NULL;

    BSallocsf (u_order, v_order, u_num_poles, v_num_poles, cur_bar->cv->rational,
               num_bound, &cur_bar->csf, &rc );
    if ( rc != BSSUCC ) goto wrapup;


    BScollarsf ( cur_bar->sf, cur_bar->cv, cur_bar->cont, cur_bar->col_dir,
                 cur_bar->acv, cur_bar->dir_vec[0], cur_bar->csf, &rc);
    if (rc != BSSUCC)   goto wrapup;
  
    cur_bar->sf = cur_bar->csf;    /*  replace surface by collar surface  */
 

    /*  evaluate basepoint  */
    cur_bar->par1 = 0.0;
    cur_bar->par2 = 0.5;
    BSsfeval(cur_bar->sf, cur_bar->par1, cur_bar->par2, 1, result, &rc);
    /*  EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);  */
    /*   result[1][i]          u-direction  */
    /*   result[2][i]          v-direction  */
    for (i=0; i<3; i++)
    {
      cur_bar->eval[0][i] = result[0][i];
      cur_bar->eval[1][i] = result[1][i];
    }

    /*  normalize the tangent  */
    BSnorvec(&rc, cur_bar->eval[1]);

    /*  set generation control flags  */
    cur_bar->par_iso = 0.0; 
    cur_bar->boundary_flag = 2;      
  }


  return(TRUE);


wrapup:
  return (FALSE);
}









/* ============================================================= */
/*  this routine prepares dynamic surface data for display       */
/* ============================================================= */

IGRint BLs_prep_sf_disp(

        IGRint                 task,          /*  task               */
                                              /*   0 = initialize    */
                                              /*   1 = calculate     */
                                        
        struct IGRbsp_surface  *base,         /* pointer to the base curve */
        struct IGRbsp_surface  *disp,         /* pointer to the display curve */

        IGRdouble              *p_u_rules,
        IGRdouble              *p_v_rules,
        IGRint                 *p_u_bounds,
        IGRint                 *p_v_bounds
                                            )


        /* return = FALSE in case of error  */


{
  IGRint    nr_u_disp_lines, nr_v_disp_lines;
  IGRlong    u, v, i, inx, inxk, inxw;

  nr_u_disp_lines = base->u_num_poles;
  nr_v_disp_lines = base->v_num_poles;

  if (task == 0)
  {
    u_end_pl = nr_u_disp_lines - 1;
    v_end_pl = nr_v_disp_lines - 1;
    if (u_end_pl > base->u_num_poles - 1)  u_end_pl = base->u_num_poles - 1;
    if (v_end_pl > base->v_num_poles - 1)  v_end_pl = base->v_num_poles - 1;

    u_np = u_end_pl + 1;
    v_np = v_end_pl + 1;

    u_end_kt = u_end_pl + base->u_order;
    v_end_kt = v_end_pl + base->v_order;

    u_nk = u_np + base->u_order;
    v_nk = v_np + base->v_order;

    /*  Copy control information  */
    disp->u_order       = base->u_order;
    disp->v_order       = base->v_order;
    disp->u_periodic    = base->u_periodic;
    disp->v_periodic    = base->v_periodic;
    disp->u_non_uniform = base->u_non_uniform;
    disp->v_non_uniform = base->v_non_uniform;
    disp->planar        = base->planar;
    disp->u_phy_closed  = base->u_phy_closed;
    disp->v_phy_closed  = base->v_phy_closed;

    disp->rational = base->rational;
                                
    disp->u_num_poles = u_np;
    disp->v_num_poles = v_np;

    disp->u_num_knots = u_nk;
    disp->v_num_knots = v_nk;

    disp->num_boundaries = 0;
    disp->bdrys          = NULL;


    esqs.u_rules = nr_u_disp_lines;
    esqs.v_rules = nr_v_disp_lines;
    esqs.is_polydis = FALSE;           /* no control point polygon  */
    esqs.is_surfdis = TRUE;
    esqs.is_slowdis = FALSE;  
              /*   esqs.is_slowdis = TRUE;  */
    esqs.type = IGRBS;
    esqs.rules_specified = TRUE;
    esqs.u_rule_values = p_u_rules;
    esqs.v_rule_values = p_v_rules;
    esqs.u_num_bound = p_u_bounds;
    esqs.v_num_bound = p_v_bounds;
    esqs.u_bdrys = NULL;
    esqs.v_bdrys = NULL;


  }      /*  end of initialize  */



  /*  Copy the relevant poles  */
  inx = inxw = 0;
  for (v=0; v<v_np; v++)
  {
    for (u=0; u<u_np; u++)
    {
     for (i=0; i<3; i++)
      disp->poles[inx++] = base->poles[(base->u_num_poles*v + u) * 3 + i];
                                
     if (disp->rational)
              disp->weights[inxw++] = base->weights[base->u_num_poles*v + u];      
    } 
  }        


  /*  Copy the relevant knots  u  */
  inxk = 0;
  
  for (u=0; u<base->u_order; u++)
    disp->u_knots[inxk++] = 0.0;

  for (u = base->u_order; u < u_nk-base->u_order; u++)
  {
    indx_u = base->u_order + u-base->u_order;
    disp->u_knots[inxk++] = base->u_knots[indx_u];
  }
  for (u = base->u_num_knots-base->u_order; u < base->u_num_knots; u++)
    disp->u_knots[inxk++] = 1.0;  

  /*  Copy the relevant knots  v  */

  inx = 0;
  for (v=0; v<base->v_order; v++)
    disp->v_knots[inx++] = 0.0;

  for (v = base->v_order; v < v_nk-base->v_order; v++)
  {
    indx_v = base->v_order + v-base->v_order;
    disp->v_knots[inx++] = base->v_knots[indx_v];
  }

  for (v = base->v_num_knots-base->v_order; v < base->v_num_knots; v++)
  {
    disp->v_knots[inx++] = 1.0;
  } 



  if (!disp->rational)  disp->weights = NULL;

  /*  The boundaries computed earlier for this patch should        */
  /*  be entered here. But for now, no boundaries are supported.   */


  if (task == 0)
  {
    /*  terminate preparation  */
    u_ktdel = (disp->u_knots[u_np] - disp->u_knots[disp->u_order-1]) /
                                            (IGRdouble) (nr_u_disp_lines - 1);
    v_ktdel = (disp->v_knots[v_np] - disp->v_knots[disp->v_order-1]) / 
                                            (IGRdouble) (nr_v_disp_lines - 1);

    p_u_rules[0] = disp->u_knots[disp->u_order-1];
    for (i=1; i<nr_u_disp_lines; i++)
      p_u_rules[i] = p_u_rules[i-1] + u_ktdel;
    p_u_rules[nr_u_disp_lines-1] = disp->u_knots[u_np];

    p_v_rules[0] = disp->v_knots[disp->v_order-1];
    for (i=1; i<nr_v_disp_lines; i++)
      p_v_rules[i] = p_v_rules[i-1] + v_ktdel;
    p_v_rules[nr_v_disp_lines-1] = disp->v_knots[v_np];
  
    for (i=0; i<nr_u_disp_lines; i++)
      p_u_bounds[i] = 0;

    for (i=0; i<nr_v_disp_lines; i++)
      p_v_bounds[i] = 0;

  }      /*  end of initialize  */        

  return (TRUE);

}







          

/* ============================================================= */
/*  this routine initializes dynamics data for one base element  */
/* ============================================================= */

IGRint BLs_startup(struct bar_data  *cur_bar)     /*  bar data array     */

                  /*  return = FALSE in case of error  */

{

  IGRlong     rc;                 /*  BS return code    */
  IGRlong     i;
  IGRpoint    result[4];






  /*  calculate dependent values  */

  cur_bar->cur_par_sf_min = MIN(cur_bar->cur_par_sf_s, cur_bar->cur_par_sf_e);

  if (cur_bar->cv_flag != 0)  cur_bar->boundary_flag = ABS(cur_bar->cv_flag);
  cur_bar->aval_dir = ABS(cur_bar->cur_dir);         /*  save absolute value  */
  cur_bar->cur_dir = (cur_bar->cur_dir < 0) ? -1.0 : 1.0;  /*  cur_dir can be +- 5  */
  cur_bar->last_dir = cur_bar->base_dir = cur_bar->cur_dir;

  cur_bar->zoom_activ     = cur_bar->cur_sensi < (1.0 - eps);
  cur_bar->base_bar_ratio = cur_bar->last_ratio = cur_bar->bar_ratio;
  cur_bar->red_fakt = cur_bar->bar_ratio + 0.5 + MAX(1,cur_bar->cur_sensi);

  if (cur_bar->zoom_activ)
  { 
    cur_bar->fakt_dist_pos = FAK_MID;                     /* start is middle */
    cur_bar->fak_mid       = FAK_MID*cur_bar->cur_dir;
    cur_bar->fakt_zoom_pos = cur_bar->base_bar_ratio / cur_bar->red_fakt;  /* start is ratio  */
  }
  else
  {
    cur_bar->fakt_dist_pos = cur_bar->base_bar_ratio / cur_bar->red_fakt;  /* start is ratio  */
    cur_bar->fakt_zoom_pos = 1.0;                    /* unused  */
  }

  cur_bar->fakt_dist_pos *= cur_bar->cur_dir;        /*  regard direction  */
  cur_bar->z_rel_bar_point = cur_bar->fakt_zoom_pos;

  if (cur_bar->sf == NULL)  goto wrapup;

  /*  evaluate start point and tangent  */

  cur_bar->ind = 2;                /*  preset for all other cases  */
  /*  decide basepoint  (use middle of iso line)  */
  if (cur_bar->cv_flag == 0)
      { cur_bar->par1 = 0.5;  cur_bar->par2 = 0.0;  cur_bar->ind = 1;  cur_bar->w_dir = 1.0; }
  else
  {
    if (cur_bar->boundary_flag == 1)
      { cur_bar->par1 = 0.5;  cur_bar->par2 = 0.0;  cur_bar->ind = 1;  cur_bar->w_dir = 1.0; }
    if (cur_bar->boundary_flag == 2)
      { cur_bar->par1 = 0.0;  cur_bar->par2 = 0.5;  cur_bar->ind = 2;  cur_bar->w_dir = 1.0; }
    if (cur_bar->boundary_flag == 3)
      { cur_bar->par1 = 0.5;  cur_bar->par2 = 1.0;  cur_bar->ind = 1;  cur_bar->w_dir = -1.0; }
    if (cur_bar->boundary_flag == 4)
      { cur_bar->par1 = 1.0;  cur_bar->par2 = 0.5;  cur_bar->ind = 2;  cur_bar->w_dir = -1.0; }
  }
  /*  update startpoint for internal blend */ 
  if (cur_bar->dyn_iso)
  { 
    if (cur_bar->par1 != 0.5)  cur_bar->par1 = cur_bar->par_iso; 
    if (cur_bar->par2 != 0.5)  cur_bar->par2 = cur_bar->par_iso;
    /*  set special mode for fix selected curve and screen pos  */ 
    cur_bar->boundary_flag = 4 + ABS(cur_bar->cv_flag);
  }

  /*  set adequate start u/v-parameter  */
  if (cur_bar->ind == 1)  cur_bar->wrk_par_cv = cur_bar->par2;
  else                    cur_bar->wrk_par_cv = cur_bar->par1;

  if (cur_bar->dyn_iso)
  {
    /*  correct for partial blend  */        
    if (cur_bar->par1 == 0.5)  cur_bar->par1 =
                         0.5 * (cur_bar->cur_par_sf_s + cur_bar->cur_par_sf_e);
    if (cur_bar->par2 == 0.5)  cur_bar->par2 =
                         0.5 * (cur_bar->cur_par_sf_s + cur_bar->cur_par_sf_e);
  }  
  /*  evaluate basepoint  */

  BSsfeval(cur_bar->sf, cur_bar->par1, cur_bar->par2, 1, result, &rc);
  if ( rc != BSSUCC )  goto wrapup;
  /*   result[1][i]          u-direction  */
  /*   result[2][i]          v-direction  */

  
  for (i=0; i<3; i++)                                                 
  {                                                                   
    cur_bar->eval[0][i] = result[0][i];                               
    cur_bar->eval[1][i] = result[3-cur_bar->ind][i]*cur_bar->w_dir;     
  }
 
  /*  normalize the tangent  */
  BSnorvec(&rc, cur_bar->eval[1]);
  if ( rc != BSSUCC )  goto wrapup;


   return(TRUE);


wrapup:
  return (FALSE);
}












/* ====================================== */
/*  this routine prepares basic bar data  */
/* ====================================== */

IGRint BLs_prep_basic_bar( struct bar_data  *cur_bar)
    
/*                   parameter:                          */            
/*                   cur_bar     activ bar definition    */   
 
                     /* return = FALSE in case of error  */                   


{

  IGRlong     sts;                     /*  OM return status  */
  IGRdouble   cur_length;
  IGRint      i;



  for (i=0; i<3; i++)
  {
    /*  Assign first point of line into dynamics buffer  */
    /*  set also midline start point  */
    cur_bar->points[i] = cur_bar->mid_linea[i] = cur_bar->eval[0][i];

    /*  set base length vector  */
    cur_bar->bar_length_base[i] = cur_bar->eval[1][i] * cur_bar->bar_length;
  }


  if (!cur_bar->zoom_activ)
    /*  position start-marker to  ratio faktor of bar length  */
    cur_length =  cur_bar->bar_ratio
                            * cur_bar->bar_length / cur_bar->red_fakt; 
  else
  {
    /*  position start-marker to the middle of the bar  */
    cur_length =  cur_bar->fakt_dist_pos  * cur_bar->bar_length
                                          * cur_bar->cur_dir;  /*  undo direction  */                    
  }

  for (i=0; i<3; i++)
  {
    /*  set base points  */

    cur_bar->point_cur[i]    = 
    cur_bar->points[3+i]     =     
    cur_bar-> point_base[i]  = cur_bar->eval[0][i] + cur_length
                                                     * cur_bar->eval[1][i]
                                                     * cur_bar->cur_dir;

    cur_bar->z_point_base[i] = cur_bar->eval[0][i] + cur_bar->fakt_zoom_pos 
                                                     * cur_bar->bar_length
                                                     * cur_bar->eval[1][i]
                                                     * cur_bar->cur_dir;
    /*  set midline end point  */  
    cur_bar->mid_lineb[i] = cur_bar->mid_linea[i] + cur_bar->bar_length
                                                    * cur_bar->eval[1][i]
                                                    * cur_bar->cur_dir;
  }

  /*  setup two parallel lines of tangent length  */
  sts = BLs_prep_bar_lines(cur_bar);

  /*  mark sensitiv end  */                               
  for (i=0; i<3; i++)
    cur_bar->pointsc[i]   =  cur_bar->point_cur[i];


  return(TRUE);

}










/* ======================================================== */
/*  this routine prepares bar data for current (new) view   */
/* ======================================================== */

IGRint BLs_prep_view( struct bar_data  *cur_bar)
    
/*                   parameter:                          */            
/*                   cur_bar     activ bar definition    */   

                     /* return = FALSE in case of error  */                    


{

  IGRlong     rc;                         /*  BS return code    */

  IGRpoint    work;
  IGRvector   work_2d;
  IGRvector   vecx;                       /*  dyn vector in mouse view  */

  IGRint      sts;
  IGRint      i;


 
  /*  map bar direction to mouse view  */  
  sts = BLs_map_vec_2d( cur_bar->eval[1],     /*  world view  */
                       work,                  /*  mouse view  */
                       work_2d,               /*  world view 2d    */
                       cur_bar->offset);      /*  world view 2d p  */
  if (!sts)  goto wrapup; 

  /*  calculate bar direction length in mouse view  */
  cur_bar->bar_length_rot = BSdistptpt(&rc, trans_vec, work);
  if (BSERROR(rc))  goto wrapup; 
  work[2] = 0.0;

  cur_bar->bar_length_rot_2d = BSdistptpt( &rc, trans_vec, work);
  if (BSERROR(rc))  goto wrapup; 

  cur_bar->bar_2d_factor = cur_bar->bar_length_rot / cur_bar->bar_length_rot_2d;
  cur_bar->bar_length_cur = cur_bar->bar_length * fakt2d3d * cur_bar->bar_2d_factor; 

  /*  correct for same small distance (view dependent) */
  for (i=0; i<3; i++)
    cur_bar->offset[i] *= FAKQ * disp_fakt;

  /*  map bar linepoint a to new mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->mid_linea,
               cur_bar->mid_linea_rot);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->mid_linea_rot[2] = 0.0;         /*  force 2D handling  */

  /*  map bar linepoint b to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->mid_lineb,
               cur_bar-> mid_lineb_rot);  
  if (BSERROR(rc))  goto wrapup; 

  cur_bar->mid_lineb_rot[2] = 0.0;          /*  force 2D handling  */

  /*  prepare 2d line  */
  for (i=0; i<2; i++)
  {
    cur_bar->line_2d[0][i] = cur_bar->mid_linea_rot[i];
    cur_bar->line_2d[1][i] = cur_bar->mid_lineb_rot[i];
  }
  cur_bar->line_2d[0][2] =
  cur_bar->line_2d[1][2] = 0.0;
 
  cur_bar->bar_leng_2d = BSdistptpt( &rc, cur_bar->line_2d[0],
                                      cur_bar->line_2d[1]); 
  if (BSERROR(rc))  goto wrapup; 

  /*  calculate bar dynamic end to new mouse view  */
  /*  (recalculate point_cur if zooming on )       */
  if (cur_bar->zoom_activ)
  {
    for (i=0; i<3; i++)
    {
       cur_bar->points[3+i] = cur_bar->point_cur[i] =
                              cur_bar->eval[0][i] + cur_bar->bar_length_cur
                                                    * cur_bar->fakt_dist_pos
                                                    * cur_bar->eval[1][i];
    }
  }


  /*  map bar base direction to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->bar_length_base,
               cur_bar->bar_base_dir);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->bar_base_dir[2] = 0.0;         /*  force 2D handling  */

  /*  position start-marker to  ratio faktor of bar length  */
  for (i=0; i<3; i++)
  {
    cur_bar->z_point_base[i] = cur_bar->eval[0][i] + cur_bar->z_rel_bar_point
                                                     * cur_bar->bar_length_cur
                                                     * cur_bar->eval[1][i]
                                                     * cur_bar->cur_dir;
  }


  /*  prepare other display  */
  sts = BLs_prep_basic_bar(cur_bar);
  if (!sts)  goto wrapup;   

  if (cur_bar->zoom_activ)
  {
    sts = BLs_prep_zoom(cur_bar);
    if (!sts)  goto wrapup;   
  }

  if (cur_bar->dyn_iso)
  {
    sts = BLs_prep_iblend(cur_bar);
    if (!sts)  goto wrapup;   
  }

  if (cur_bar->dyn_vector)
  {
    /*  map int blend direction vector to new mouse view  */
    BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->dir_vec[0], vecx);
    if (BSERROR(rc))  goto wrapup;  
  }


  return(TRUE);


wrapup:
  return (FALSE);
}







/* ======================================================= */
/*  this routine prepares zoom bar data for current view   */
/* ======================================================= */

IGRint BLs_prep_zoom( struct bar_data  *cur_bar )

/*                   parameter:                          */            
/*                   cur_bar     activ bar definition    */   

                     /* return = FALSE in case of error  */


{



  IGRdouble   work_offset, dark_offset, work_length;
  IGRint i;



  for (i=0; i<3; i++)
  {
    cur_bar->z_offset[i] = FAKZOOM * cur_bar->offset[i];
    dark_offset = FAKDARK * cur_bar->eval[1][i] * cur_bar->cur_dir;
    work_length = cur_bar->bar_length_cur * cur_bar->eval[1][i] * cur_bar->cur_dir;
    work_offset = FAK_MID * cur_bar->cur_sensi * work_length;

    /*  recalculate work position  */
    cur_bar->point_base[i] = cur_bar->z_point_base[i];
  }

      
  return(TRUE);

}








/* ============================================================= */
/*  this routine prepares internal blend data for current view   */
/* ============================================================= */

IGRint BLs_prep_iblend( struct bar_data  *cur_bar )   

/*                   parameter:                          */            
/*                   cur_bar     activ bar definition    */ 

                     /* return = FALSE in case of error  */  

{
  IGRint      sts;
  IGRlong     rc;                        /*  BS return code               */
  IGRshort    opt;                       /*  1: u = const / 2: u = const  */
  IGRboolean  tst_plan = FALSE;          /*  dont check for planar curve  */
  IGRshort    iso_num_bound = NULL;  
  IGRshort    curve_order;               /*  order used (max)      */
  IGRshort    curve_num_poles;           /*  num poles used (max)  */
  IGRint      i;                         /*  loop index  */
  


  /*  allocate iso_curve buffer if not yet there  */
  if (cur_bar->cv_a == NULL)
  {
    curve_order     = MAX(cur_bar->sf->u_order, cur_bar->sf->v_order);
    curve_num_poles = MAX(cur_bar->sf->u_num_poles, cur_bar->sf->v_num_poles);

    BSalloccv(curve_order, curve_num_poles, blndsrf->rational, iso_num_bound,
              &cur_bar->cv_a, &rc );  
    if (BSERROR(rc))  goto wrapup;
  }

  /*  extract iso parametric curves  */
  if (cur_bar->ind == 1)     opt = 1;          /* const v  */ 
  else                       opt = 2;          /* const u  */
  sts = BSconstprcv(&rc, cur_bar->sf, &opt, &cur_bar->cur_par_sf_min, &tst_plan,
                                                                 cur_bar->cv_a);
  if (BSERROR(rc))  goto wrapup;    

  /*  evaluate blend point from iso curve (+tangent) for blend position  */
  if (cur_bar->ind == 1)
    BSsfeval(cur_bar->sf, cur_bar->cur_par_sf_min, cur_bar->wrk_par_cv, 1,
                                                     cur_bar->evali, &rc);
  else
    BSsfeval(cur_bar->sf, cur_bar->wrk_par_cv, cur_bar->cur_par_sf_min, 1,
                                                     cur_bar->evali, &rc);
  if (BSERROR(rc))  goto wrapup;  

  /*  prepare and fill display buffer with internal blend marker  */
  sts = BLs_dis_ibl_sign(cur_bar);
  if (!sts)  goto wrapup; 
 
  /*  use tangent with respect to internal bar direction  */
  for (i=0; i<3; i++)
    cur_bar->evali[1][i] *= cur_bar->w_dir;

  return(TRUE);


wrapup:
  return (FALSE);
}










/* ================================================= */
/*  this routine handles internal blendpoint moving  */
/* ================================================= */

IGRint BLs_mov_iblend(
                     struct bar_data  *cur_bar,
                     IGRint           *new_display)
                                                  
/*                   parameter:                             */            
/*                   cur_bar         activ bar definition   */   
/*                   new_display     > 0 if update needed   */

                     /* return = FALSE in case of error  */

{

  IGRlong     rc;                        /*  BS return code    */
  IGRlong     sts;                       /*  OM return status  */
  IGRint      i;

  IGRdouble   dist;
  IGRpoint    base;                     /*  nearest point on curve  */
  IGRpoint    result[4];                /*  point and derivates on surface  */



  *new_display = 0;

  BSmdstptcv(cvw, bore_base, &cur_bar->wrk_par_cv, base, &dist, &rc);
  if (BSERROR(rc))  goto wrapup; 

  /*  get blend position basepoint and tangents from surface  */
  if (cur_bar->ind == 1)
    BSsfeval(cur_bar->sf, cur_bar->cur_par_sf_min, cur_bar->wrk_par_cv, 1,
                                                     cur_bar->evali, &rc);
  else
    BSsfeval(cur_bar->sf, cur_bar->wrk_par_cv, cur_bar->cur_par_sf_min, 1,
                                                     cur_bar->evali, &rc);
  if (BSERROR(rc))  goto wrapup; 
  
  sts = BLs_dis_ibl_sign(cur_bar);
  if (!sts)  goto wrapup; 

  /*  use tangent with respect to internal bar direction  */
  for (i=0; i<3; i++)
    cur_bar->evali[1][i] *= cur_bar->w_dir;
 
  /*  set new blend point parameter u/v  */
  cur_bar->par_iso = cur_bar->wrk_par_cv;  
  cur_bar->boundary_flag = 4 + ABS(cur_bar->cv_flag);

  *new_display = 1;                 /*  set update  */

  /*  recalculate tangent bar base  */
  if (cur_bar->ind == 1)
    BSsfeval(cur_bar->sf, cur_bar->par1, cur_bar->wrk_par_cv, 1, result, &rc);
  else
    BSsfeval(cur_bar->sf, cur_bar->wrk_par_cv, cur_bar->par2, 1, result, &rc);
  if (BSERROR(rc))  goto wrapup; 

  /*  copy base point and base tangent  */ 
  for (i=0; i<3; i++)
  {
    cur_bar->eval_t[0][i] = cur_bar->eval[0][i] = result[0][i];
    cur_bar->eval_t[1][i] = 
    cur_bar->eval[1][i]   = (result[3-cur_bar->ind][i]) * cur_bar->w_dir;
  }

  /*  normalize the base tangent  */
  BSnorvec(&rc, cur_bar->eval[1]);
          
  /*  map curve basepoint to mouse view for later bar direction control  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->eval[0], cur_bar->eval_rot);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->eval_rot[2] = 0.0;   

  /*  update tangent bar  */
  sts = BLs_prep_view( cur_bar );

  /*  map curve basepoint to mouse view for later bar direction control  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->eval[0], cur_bar->eval_rot);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->eval_rot[2] = 0.0;    



  return(TRUE);


wrapup:
  return (FALSE);
}







/* ========================================================== */
/*  this routine calculates new bar extend after mouse move   */
/* ========================================================== */

IGRint BLs_calc_new_bar( struct bar_data  *cur_bar )   

/*                   parameter:                          */            
/*                   cur_bar     activ bar definition    */  

                     /* return = FALSE in case of error  */ 

{

  IGRlong         rc;                           /*  BS return code    */
  IGRlong         sts;                          /*  OM return status  */

  IGRdouble       work_offset;
  IGRdouble       dark_offset;
  IGRdouble       work_length;

  IGRdouble       cur_d;
  IGRdouble       z_cur_d;  
  IGRdouble       z_cur_dif;  
  IGRdouble       work_dist;
  IGRdouble       cur_dot;
  IGRdouble       bar_dist;
  IGRvector       wrk_vector;
 
  IGRint          i;



  /*  project mouse point  */
  sts = BSproj0( &rc, mouse_rot_2d, cur_bar->line_2d, cur_bar->proj_2d);
  if (BSERROR(rc)) 
  {
    /*  bar perpto view  */
    cur_bar->proj_2d[0] = cur_bar->line_2d[1][0];
    cur_bar->proj_2d[1] = cur_bar->line_2d[1][1];
    goto skip;                        /*  skip other calculation  */
  } 
  cur_bar->proj_2d[2] = 0.0;


  /*  check for same direction as base vector  */
  cur_bar->cur_vector[0] = cur_bar->proj_2d[0] - cur_bar->eval_rot[0];
  cur_bar->cur_vector[1] = cur_bar->proj_2d[1] - cur_bar->eval_rot[1];
  cur_bar->cur_vector[2] = 0.0;

  cur_dot = BSdotp(&rc, cur_bar->bar_base_dir, cur_bar->cur_vector);
  if (BSERROR(rc))  goto wrapup; 

  /*  different direction handling if zooming on  */
  if (!cur_bar->zoom_activ)
  {
    cur_bar->cur_dir = 1;
    if (cur_dot < 0)  cur_bar->cur_dir = -1.0;
    if (cur_bar->cur_dir != cur_bar->last_dir)
    {
      cur_bar->last_dir = cur_bar->cur_dir;
      /*  toggle bar borders display  / setup two parallel lines  */
      sts = BLs_prep_bar_lines(cur_bar);
    }
  }

  /*  calculate work distance to get length of activ bar  */
  work_dist = BSdistptpt( &rc, cur_bar->line_2d[0], cur_bar->proj_2d);
  if (BSERROR(rc))  goto wrapup; 
  /*  observe work direction  */
  work_dist *=  cur_bar->cur_dir;    
  /*  dont toggle bar direction if zooming on  */
  if (cur_bar->zoom_activ && cur_dot*cur_bar->cur_dir < 0)  work_dist = -work_dist; 
  /*  save rel current offset  */
  cur_bar->fakt_dist_pos = work_dist / cur_bar->bar_leng_2d; 
 
  /*  calculate new dynamic bar pos in 3D  */      
  cur_d = work_dist * cur_bar->bar_length / cur_bar->bar_leng_2d; 
  cur_bar->sym_offset = ABS(cur_d);           /*  save for symmetric use  */
  for (i=0; i<3; i++)
  {
    cur_bar->points[3+i] = cur_bar->point_cur[i] = 
                           cur_bar->eval[0][i] + cur_d * cur_bar->eval[1][i];
    /*  mark sensitiv end  */                             
    cur_bar->pointsc[i]   =  cur_bar->point_cur[i];
  }

  bar_dist = BSdistptpt( &rc, cur_bar->eval[0], cur_bar->point_cur);
  if (BSERROR(rc))  goto wrapup; 

  if (!cur_bar->zoom_activ)
    cur_bar->bar_ratio = bar_dist*cur_bar->red_fakt / cur_bar->bar_length;  
  else
  {
    /*  correct tangent value and bar display if zoom on  */
    if (cur_dot*cur_bar->base_dir < 0)  bar_dist *= -1;

    cur_bar->bar_ratio = bar_dist / cur_bar->bar_length; 
    z_cur_dif = (cur_bar->bar_ratio-FAK_MID) * cur_bar->cur_sensi;

    /*  use same direction as base vector  */
    /*  observe bar reduction factor  */
    z_cur_d = z_cur_dif * cur_bar->cur_dir * cur_bar->red_fakt;     

    /*  calculate new basepoint  */
    for (i=0; i<3; i++)
    {
      cur_bar->z_point_cur[i] = cur_bar->z_point_base[i] + cur_bar->cur_sensi  *
           (cur_bar->fakt_dist_pos - cur_bar->fak_mid)
           * cur_bar->bar_length_cur * cur_bar->eval[1][i];
    }
    cur_bar->bar_ratio = cur_bar->base_bar_ratio + z_cur_dif * cur_bar->red_fakt;

    if (cur_bar->bar_ratio*cur_bar->last_ratio < 0)
    {
      cur_bar->cur_dir *= -1;
      cur_bar->last_dir = cur_bar->cur_dir;
      /*  toggle bar borders display / setup two parallel lines  */
      sts = BLs_prep_bar_lines(cur_bar);
    }
    cur_bar->last_ratio = cur_bar->bar_ratio;
  }

  if (cur_bar->zoom_activ)
  {
    /*  correct dark start/end pos  */
    for (i=0; i<3; i++)                            
    {
      cur_bar->z_offset[i] = FAKZOOM * cur_bar->offset[i];
      dark_offset = FAKDARK * cur_bar->eval[1][i] * cur_bar->cur_dir;
      work_length = cur_bar->bar_length_cur * cur_bar->eval[1][i]
                                            * cur_bar->cur_dir;
      work_offset = cur_bar->fakt_zoom_pos * cur_bar->cur_sensi * work_length;
    }

    /*  save real direction for symmetric usage  */
    wrk_vector[0] = cur_bar->points[3] - cur_bar->points[0];
    wrk_vector[1] = cur_bar->points[4] - cur_bar->points[1];
    wrk_vector[2] = cur_bar->points[5] - cur_bar->points[2];

    cur_dot = BSdotp( &rc, cur_bar->eval[1], wrk_vector);

    if (cur_dot < 0)  cur_bar->sym_dir = -1.0;
    else              cur_bar->sym_dir =  1.0;
  }
 

skip:
  return(TRUE);


wrapup:
  return (FALSE);
}








/* ========================================================= */
/*  this routine prepares blend surface boundary iso curves  */
/* ========================================================= */

IGRint BLs_prep_h_iso( IGRint   index)      

                     
/*                   input parameter:
                     int       index of iso curve (0-3) */
                     /* return = FALSE in case of error  */

{

  IGRlong     rc;                      /*  BS return code    */
  IGRshort    opt;                     /*  1: u = const / 2: u = const   */
  IGRboolean  tst_plan = FALSE;        /*  dont check for planar curve   */
  IGRdouble   uv_start = 0.0;          /*  start parameter value         */
  IGRdouble   uv_end   = 1.0;          /*  end parameter value           */
  IGRdouble   param;                   /*  current parameter value       */
 
  /*  re-extract iso curves  */
  opt = 1;                           /* const u   start/end/current  */
  BSconstprcv(&rc, blndsrf, &opt, &uv_start, &tst_plan, igel_edges[0]);
  BSconstprcv(&rc, blndsrf, &opt, &uv_end,   &tst_plan, igel_edges[1]);
  opt = 2;                           /* const v   start/end/current  */
  BSconstprcv(&rc, blndsrf, &opt, &uv_start, &tst_plan, igel_edges[2]);
  BSconstprcv(&rc, blndsrf, &opt, &uv_end,   &tst_plan, igel_edges[3]);


  /*  re-extract iso curve for hedgehog sign move  */
  if (index == 0)   {  opt = 1;  param = uv_start; }
  if (index == 1)   {  opt = 1;  param = uv_end;   }
  if (index == 2)   {  opt = 2;  param = uv_start; }
  if (index == 3)   {  opt = 2;  param = uv_end;   }
  BSconstprcv(&rc, blndsrf, &opt, &param, &tst_plan, igel_sgn);

  /*  re-extract iso curve for hedgehog display */
  opt = 3 - opt;
  BSconstprcv(&rc, blndsrf, &opt, &hd_cur_param, &tst_plan, igel_cur);

  return(TRUE);
}











/* ============================================= */
/*  this routine prepares hedgehog sign display  */
/* ============================================= */

IGRint BLs_dis_h_sign(IGRdouble            param,
                      IGRint               hd_index)
              
/*                    parameter:                                         */ 
/*                    param             curve parameter value on curve   */
/*                    hd_index          border number                    */

/*             return = FALSE in case of error                          */

{

  IGRlong     rc;                    /*  BS return code    */
  IGRint      i;
  IGRshort    jj;                    /*  u/v derivate index  */
  IGRpoint    evalh_2d;              /*  evaluated sign point 2d  */
  IGRpoint    evalhv_rot;            /*  evaluated sign point vector  */
  IGRpoint    offseth_2d;            /*  perpto direction 2d */
  IGRdouble   dir;
  IGRdouble   cur_dot;
  IGRdouble   param_u, param_v;
  IGRvector   srf_vect, sign_vect, dir_vect;


  
  /*  re-extract iso curve parameters for hedgehog sign move  */
  /*  hd_index == 0*/ {  param_u = 0.0;  param_v = param;  jj = 1; dir = -1;  }
  if (hd_index == 1)  {  param_u = 1.0;  param_v = param;  jj = 1; dir =  1;  }
  if (hd_index == 2)  {  param_v = 0.0;  param_u = param;  jj = 2; dir = -1;  }
  if (hd_index == 3)  {  param_v = 1.0;  param_u = param;  jj = 2; dir =  1;  }

  /*  evaluate surface direction for hedgehog sign  */
  BSsfeval(blndsrf, param_u, param_v, 1, evalh, &rc);
  if (BSERROR(rc))  goto wrapup; 

  /*  copy relevant vectors  */  
  for (i=0; i<3; i++)
  {
    dir_vect[i] = evalh[jj][i]; 
    srf_vect[i] = evalh[3-jj][i]; 
  }

  /*  map vectors to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, dir_vect, dir_vect);
  if (BSERROR(rc))  goto wrapup;
  dir_vect[2] = 0.0;                        /*  force 2D  */

  BSptoldtnw( &rc, trans_vec, mat, &scale, srf_vect, sign_vect);
  if (BSERROR(rc))  goto wrapup;
  sign_vect[2] = 0.0;
                        /*  force 2D  */
  BSnorvec(&rc, dir_vect);
  if (BSERROR(rc))  goto wrapup; 
  BSnorvec(&rc, sign_vect);
  if (BSERROR(rc))  goto wrapup; 

  /*  setup current perpto direction  */
  evalhv_rot[0] = -sign_vect[1];
  evalhv_rot[1] =  sign_vect[0];
  evalhv_rot[2] =  sign_vect[2];

  /*  map vectors back to world coordinates  */ 
  BSptnwtold( &rc, trans_vec, mat, &scale, evalhv_rot, evalh_2d);
  if (BSERROR(rc))  goto wrapup; 
  BSptnwtold( &rc, trans_vec, mat, &scale, dir_vect, dir_vect);
  if (BSERROR(rc))  goto wrapup; 

  /*  correct sign direction to be always outside surface  */
  cur_dot = BSdotp( &rc, evalh_2d, dir_vect);
  if (cur_dot < 0)  dir *= -1;

  /*  map offset vector back to world coordinates  */
  BSptnwtold( &rc, trans_vec, mat, &scale, sign_vect, offseth_2d);
  if (BSERROR(rc))  goto wrapup; 

  /*  update position sign   (world coordinates for display)  */
  for (i=0; i<3; i++)
  {
    pointss[9+i] = 
    pointss[0+i] = evalh[0][i];
    pointss[3+i] = pointss[0+i] + 2*offs_int_s*evalh_2d[i] * dir
                                + 2*0.577*offs_int_s*offseth_2d[i];
    pointss[6+i] = pointss[3+i] - 2*1.154*offs_int_s*offseth_2d[i];
  }
  return(TRUE);


wrapup:
  return (FALSE);
}










/* ================================================================ */
/*  this routine calculates new direction vector after mouse move   */
/* ================================================================ */

IGRint BLs_mov_vec( struct bar_data  *cur_bar,   
                    IGRint           *new_display)

/*                   parameter:                             */            
/*                   cur_bar         activ bar definition   */  
/*                   new_display     > 0 if update needed   */
/*                   return = FALSE in case of error        */ 

{

  IGRlong         rc;                         /*  BS return code    */
  IGRlong         sts;                        /*  OM return status  */
                   
  IGRint          i;                          /*  loop index  */
  IGRpoint        result[4];                  /*  evaluation result  */
  IGRint          opt = 1;                    /*  evaluation option  */
  IGRint          num_normals;
  IGRpoint        base_point;                 /*  normals base point  */
  IGRvector       normals[2];                 /*  opt = 1 (uleft + vleft )  */
  IGRdouble       cur_dot;
  IGRvector       vec0, vec2, vec3, vec4, vec5, vec6;


  *new_display = 0;         

  /*  build direction vector in mouse view (reverse direction) */
  for (i=0; i<2; i++)
                                                 /*.  mittw 20:45 */
    vec0[i] = (mouse_rot_2d[i] - cur_bar->eval_rot[i]) * -1;
  vec0[2] = 0.0;                  /*  make it planar to mouse_view */

  /*  normalize direction vector  */
  BSnorvec( &rc, vec0);   
  if (BSERROR(rc))  goto wrapup; 

  /*  map direction vector from mouse view to world  */
  BSptnwtold( &rc, trans_vec, mat, &scale, vec0, vec0);
  if (BSERROR(rc))  goto wrapup; 

  BSsfevaln(cur_bar->sf, 0.0, 0.5, opt, &num_normals, base_point, normals, &rc);
  if (BSERROR(rc))
  {
    /*  degenerated collar surface / use onother value and try again  */
    normals[0][0] = 1.123456;
    normals[0][1] = 1.234567;
    normals[0][2] = 1.345678;
    rc = 0;                           
  }

  /*  normalize normal vector  */
  BSnorvec( &rc, normals[0]);
  if (BSERROR(rc))  goto wrapup;

  for (i=0; i<3; i++)
    vec3[i] = normals[0][i];


  /*  project the vector to the surface  */
  cur_dot = BSdotp( &rc, vec3, vec0);
  if (BSERROR(rc))  goto wrapup; 

  for (i=0; i<3; i++)
    vec2[i] = vec0[i] - cur_dot*vec3[i];


  /*  project vector to surface in direction of mouse view  */

  BScrossp( &rc, vec0, mat[2], vec4);
  if (BSERROR(rc))  goto wrapup; 

  BScrossp( &rc, vec4, vec3, vec5);
  if (BSERROR(rc))  goto wrapup; 

  /*  normalize vector  */
  BSnorvec( &rc, vec5);
  if (BSERROR(rc))  goto wrapup; 

  /*  project the vector to the surface  */
  cur_dot = BSdotp( &rc, vec0, vec5);
  if (BSERROR(rc))  goto wrapup; 


  for (i=0; i<3; i++)
    vec6[i] =  cur_dot*vec5[i];

  BSnorvec( &rc, vec6);
  if (BSERROR(rc)) 
  {
    /*  skip normal work direction  */
    goto skip;
  } 
  
  /*  use correct work direction  */
  for (i=0; i<3; i++)
    vec6[i] *= cur_bar->cur_dir;


  /* ====================================================================== */
  BScollarsf(cur_bar->sf_orig, cur_bar->cv, cur_bar->cont, cur_bar->col_dir,
             cur_bar->acv, vec6, cur_bar->csf, &rc);
  if (rc != BSSUCC)  goto wrapup;
  /* ====================================================================== */

  cur_bar->sf = cur_bar->csf;         /*  replace surface by collar surface  */

  /*  evaluate basepoint  */
  cur_bar->par1 = 0.0;
  cur_bar->par2 = 0.5;
  BSsfeval(cur_bar->csf, cur_bar->par1, cur_bar->par2, 1, result, &rc);
  if (BSERROR(rc))  goto wrapup; 

  /*  normalize the new tangent  */
  BSnorvec(&rc, result[1]);
  if (BSERROR(rc))  goto wrapup; 

  for (i=0; i<3; i++)
  {
    cur_bar->eval_t[0][i]  = cur_bar->eval[0][i] = result[0][i];
    cur_bar->dir_vec[0][i] =
    cur_bar->eval_t[1][i]  =
    cur_bar->eval[1][i]    = result[1][i];
  }

  /*  map curve basepoint to mouse view for later bar direction control  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->eval[0], cur_bar->eval_rot);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->eval_rot[2] = 0.0;         /*  force 2D  */

  /*  update tangent bar  */
  sts = BLs_prep_view(cur_bar); 

  *new_display = 1;         /*  mark update  */

skip:
  return(TRUE);


wrapup:
  return (FALSE);
}









/* ===================================================== */
/*  this routine handles hedgehog position point moving  */
/* ===================================================== */

IGRint BLs_mov_h_sign(
                     IGRint              *nearest,
                     IGRdouble           *param,
                     IGRint              *new_display)
                                                  
                     /*  input:                                    */

                     /*  output:                                   */
                     /*    nearest = index nearest iso curve       */
                     /*    param  = curve parameter value          */ 
                     /*    new_display = 0: no action              */

                     /*  return = FALSE in case of error           */

{

  IGRlong     rc;                                /*  BS return code    */
  IGRint      i;

  IGRdouble   dist_cur;             /*  current distance to curve  */
  IGRdouble   dist_min;             /*  current minimum distance to curve  */
  IGRpoint    base;                 /*  nearest point on curve  */
  IGRdouble   parx;                 /*  parameter of nearest point on curve  */



  /*  find nearest point to local mouse point on projected curve  */
  dist_min = GRDGNLIMITS_MAX_D;
  for (i=0; i<4; i++)
  {
    BSmdstptcv(igel_projt[i], bore_base, &parx, base, &dist_cur, &rc);
    if (BSERROR(rc))  goto wrapup; 
    if (dist_cur < dist_min) 
    {
      dist_min = dist_cur; 
      *nearest = i;
      *param   = parx;
    } 
  } 

  /*  set update  */
  *new_display = TRUE;      
  return(TRUE);


wrapup:
  *new_display = FALSE;          
  return (FALSE);
}








/* =========================================== */
/*  this routine prepares basic bar line data  */
/* =========================================== */

IGRint BLs_prep_bar_lines( struct bar_data  *cur_bar)
    
/*                   parameter:                          */            
/*                   cur_bar     activ bar definition    */   
 
                     /* return = FALSE in case of error  */                   


{
  IGRlong     rc;                      /*  BS return code    */
  IGRint      i;
  IGRvector   m_vec_p, dir_p,
              m_vec_n, dir_n;





  if (cur_bar->dyn_vector)
  {
    /*  update int blend direction vector sign  */
    /*  update vector sign   (world coordinates for display)  */

    /*  map iso-vector to mouse view  (2d)  */
    BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->eval[1], m_vec_n);
    if (BSERROR(rc))  goto wrapup;
    m_vec_n[2] = 0.0;
  
    /*  normalize 3d vector  */
    BSnorvec( &rc, m_vec_n);
    if (BSERROR(rc))  goto wrapup;

    /*  make perpto vector  */

    m_vec_p[0] =  m_vec_n[1];
    m_vec_p[1] = -m_vec_n[0];
    m_vec_p[2] =  0.0;

    /*  map sign 2d vector back to world coord  */
    BSptnwtold( &rc, trans_vec, mat, &scale, m_vec_p, dir_p);
    if (BSERROR(rc))  goto wrapup;

    /*  map perpto 2d vector back to world coord  */
    BSptnwtold( &rc, trans_vec, mat, &scale, m_vec_n, dir_n);
    if (BSERROR(rc))  goto wrapup;

    /*  build vector sign  */   
    for (i=0; i<3; i++)
    {
      dir_n[i] *= cur_bar->cur_dir;                    
      cur_bar->point_bar_end[i] =
      cur_bar->pointv[12+i] =
      cur_bar->pointv[0+i]  = cur_bar->eval[0][i]       - 6*offs_int_s*dir_n[i];
      cur_bar->pointv[3+i]  = cur_bar->point_bar_end[i] - 4*offs_int_s*dir_n[i]
                                                        +   offs_int_s*dir_p[i];
      cur_bar->pointv[6+i]  = cur_bar->point_bar_end[i] - 3*offs_int_s*dir_n[i];
      cur_bar->pointv[9+i]  = cur_bar->point_bar_end[i] - 4*offs_int_s*dir_n[i]
                                                        -   offs_int_s*dir_p[i];
      /*             [12+i] = [i] */
      cur_bar->pointv[15+i] = cur_bar->eval[0][i]       - 1*offs_int_s*dir_n[i];
    }
  }

  return(TRUE);


wrapup: 
  return (FALSE); 
}









/* ============================================================= */
/*  this routine builds a curvature hedgehog for display         */
/* ============================================================= */

IGRint BLs_hedgehog(
         struct IGRbsp_curve  *cv_blend,     /* pointer to the blend curve */
         IGRdouble            max_length,    /* max length of prickle */
         IGRint               nr_pnt_blend,  /* number of points for blend */
         IGRdouble            *polyline_bl   /* polyline array blend */   
                                           )

         /* return = FALSE in case of error  */


/*	Original by Ulrich Walter   */



{

  IGRlong     rc;

  IGRint      j; 
  IGRint      n;
  IGRint      bound, ev_bound;
  IGRint      nd = 2;
  IGRdouble   max, rmin, curva_length;
  IGRdouble   par0; 
  IGRdouble   mx = 0, my = 0, mz = 0;
  IGRdouble   d_l[9], d_r[9];
  IGRdouble   tmp_a, tmp_b; 
  IGRdouble   fakt, fakt_rho;



  n =  nr_pnt_blend / 2;            /*  number of prickles for blend_curve  */

  /*  first loop to calculate the normal vectors, curvature (+max.)  */
  max = 0;

  for ( j=0; j<n; j++ )
  {
    par0 = (double)(j)/(double)(n-1);

    BScveval_b(&rc, cv_blend, &par0, &nd, &ev_bound, &bound, &d_l[0], &d_r[0]);
    if (BSERROR(rc))  goto wrapup; 

    mx = d_l[3]*d_l[3] + d_l[4]*d_l[4] + d_l[5]*d_l[5];
    my = d_l[6]*d_l[6] + d_l[7]*d_l[7] + d_l[8]*d_l[8];
    mz = d_l[3]*d_l[6] + d_l[4]*d_l[7] + d_l[5]*d_l[8]; 

    tmp_a = mx*mx*mx;
    tmp_b = mx*my - mz*mz;
    if (mx < 1e-8)
    {
      /*  printf("ERROR (hedgehog) rho < 1e8\n");  */      
      goto wrapup;
    }
    rho[j] = sqrt( ABS(tmp_b)/tmp_a );
    if (max < rho[j])  max = rho[j];          /*  set max curvature  */

    mx = d_l[4]*d_l[8] - d_l[5]*d_l[7];
    my = d_l[5]*d_l[6] - d_l[3]*d_l[8];
    mz = d_l[3]*d_l[7] - d_l[4]*d_l[6];
    nx[j] = my*d_l[5] - mz*d_l[4];
    ny[j] = mz*d_l[3] - mx*d_l[5];
    nz[j] = mx*d_l[4] - my*d_l[3];
    p_x[j] = d_l[0];
    p_y[j] = d_l[1];
    p_z[j] = d_l[2];
  }

  /*---  second loop to produce normal lines with curvature length  ---*/
  /*---  in dynamic display buffer                                  ---*/  
  fakt = max_length/max;
  if (fakt > 1.0)  fakt = sqrt(fakt);     /*  reduce for large values  */
  rmin = R_MIN_FAKT*max_length; 

  for ( j=0; j<n; j++ )
  {
    *polyline_bl++ = p_x[j];                         /*  base_point  */
    *polyline_bl++ = p_y[j];
    *polyline_bl++ = p_z[j];

    curva_length = sqrt(nx[j]*nx[j] + ny[j]*ny[j] + nz[j]*nz[j]);
    fakt_rho = fakt*rho[j] / curva_length;

    if (curva_length > rmin)
    {
      *polyline_bl++ = p_x[j] + fakt_rho*nx[j];
      *polyline_bl++ = p_y[j] + fakt_rho*ny[j];
      *polyline_bl++ = p_z[j] + fakt_rho*nz[j];
    }
    else      
    {
      *polyline_bl++ = p_x[j] + rmin;         /*  avoid zero length  */
      *polyline_bl++ = p_y[j];
      *polyline_bl++ = p_z[j];
    }
   }
  return (TRUE);


wrapup:
  return (FALSE);
}


 





/* ================================================== */
/*  this routine calculates 2D point for mouse view   */
/* ================================================== */

IGRint BLs_map_pnt_2d( IGRpoint pnt_world,
                      IGRpoint pnt_mouse,   
                      IGRpoint pnt_2d)   

/*                   parameter:                                    */
/*           IN         pnt_world   point  (world view)            */
/*           OUT        pnt_mouse   point  (mouse view)            */
/*           OUT        pnt_2d      point  (world view 2d)         */  

                     /* return = FALSE in case of error  */ 
                  
{

  IGRlong         rc;                           /*  BS return code    */

  IGRpoint        work;




  /*  map point to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, pnt_world, pnt_mouse);
  if (BSERROR(rc))  goto wrapup; 

  work[0] = pnt_mouse[0];
  work[1] = pnt_mouse[1];
  work[2] = 0.0;

  /*  map point back to world coord  */
  BSptnwtold( &rc, trans_vec, mat, &scale, work, pnt_2d);
  if (BSERROR(rc))  goto wrapup; 

     
  return (TRUE);


wrapup:
  return (FALSE);
}







/* ================================================== */
/*  this routine calculates 2D vector for mouse view  */
/* ================================================== */
 
IGRint BLs_map_vec_2d( IGRvector vec_world,
                      IGRvector vec_mouse,
                      IGRvector vec_2d,
                      IGRvector per_2d )   

                     /* return = FALSE in case of error  */ 

/*                   parameter:                                           */
/*           IN         vec_world   vector  (world view)                  */
/*           OUT         "    "     vector  (world view) (normalized)     */
/*           OUT        vec_mouse   vector  (mouse view) (normalized)     */
/*           OUT        vec_2d      vector        (world view 2d) (norm.) */  
/*           OUT        per_2d      perpto vector (world view 2d) (norm.) */  

                     /* return = FALSE in case of error  */ 
       
{

  IGRlong         rc;                           /*  BS return code    */
  IGRvector       vec;

                 
  /*  normalize 3d vector  */
  BSnorvec( &rc, vec_world);
  if (BSERROR(rc))  goto wrapup; 

  /*  map vector to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, vec_world, vec_mouse);
  if (BSERROR(rc))  goto wrapup; 

  vec[0] = vec_mouse[0];
  vec[1] = vec_mouse[1];
  vec[2] = 0.0;

  /*  normalize 2d vector  */
  BSnorvec( &rc, vec);
  if (BSERROR(rc))
  {
    vec[1] = 1.0;              /*  use yt  */
  } 

  /*  map 2d vector back to world coord  */
  BSptnwtold( &rc, trans_vec, mat, &scale, vec, vec_2d);
  if (BSERROR(rc))  goto wrapup; 

  /*  set 2d perpto direction  */
  per_2d[0] = -vec[1];
  vec[1]    =  vec[0];
  vec[0]    =  per_2d[0]; 

  /*  map perpto 2d vector back to world coord  */
  BSptnwtold( &rc, trans_vec, mat, &scale, vec, per_2d);
  if (BSERROR(rc))  goto wrapup; 



  return(TRUE);


wrapup:
  return (FALSE);
}








/* ===================================================== */
/*  this routine prepares dynamic internal blend marker  */
/* ===================================================== */
 
IGRint BLs_dis_ibl_sign( struct bar_data  *cur_bar)
                   


/*                    parameter: 
/*                      IN / OUT    cur_bar     activ bar definition      */  
  
                     /*  return = FALSE in case of error  */ 
       
{

  IGRlong         rc;                           /*  BS return code    */
  IGRint          i;
  IGRvector       vec_i,   vec_s;
  IGRvector       m_vec_i, m_vec_s, m_vec_i_p;
  IGRdouble       cur_dot;




  /*  define sign tangent (off from surface), perpto border  */ 

  for (i=0; i<3; i++)
  {
    vec_i[i] = cur_bar->evali[3-cur_bar->ind][i];    /*  vector on iso line  */
    vec_s[i] = (cur_bar->evali[cur_bar->ind][i]);    /*  vector to surface mid  */
  }

  /*  map iso-vector to mouse view  (2d)  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, vec_i, m_vec_i);
  if (BSERROR(rc))  goto wrapup;
  m_vec_i[2] = 0.0;
  
  /*  normalize 3d vector  */
  BSnorvec( &rc, m_vec_i);
  if (BSERROR(rc))  goto wrapup;

  /*  map in-surface-vector to mouse view  (2d)  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, vec_s, m_vec_s);
  if (BSERROR(rc))  goto wrapup;
  m_vec_s[2] = 0.0; 

  /*  make perpto vector  */
  m_vec_i_p[0] =  m_vec_i[1];
  m_vec_i_p[1] = -m_vec_i[0];
  m_vec_i_p[2] =  0.0;

  /*  check for same direction in mouse view  */
  cur_dot = BSdotp( &rc, m_vec_i_p, m_vec_s);
  if (BSERROR(rc))  goto wrapup; 

  /*  reverse if not outside surface side  */
  if (cur_dot > 0.0)   {  m_vec_i_p[0] *= -1.0;   m_vec_i_p[1] *= -1.0;  }

  /*  map sign 2d vector back to world coord  */
  BSptnwtold( &rc, trans_vec, mat, &scale, m_vec_i_p, cur_bar->evaliv_2d);
  if (BSERROR(rc))  goto wrapup;

  /*  map perpto 2d vector back to world coord  */
  BSptnwtold( &rc, trans_vec, mat, &scale, m_vec_i, cur_bar->offseti_2d);
  if (BSERROR(rc))  goto wrapup;

  /*  update position sign   (world coordinates for display)  */
  for (i=0; i<3; i++)
  {
    cur_bar->last_int[i]    =            /*  save last used base blend point  */
    cur_bar->pointi[i]      = cur_bar->evali[0][i];

    cur_bar->p_sensi_int[i] = cur_bar->pointi[i]      + offs_int_d *
                                                        cur_bar->evaliv_2d[i];
    cur_bar->pointi[3+i]    =
    cur_bar->pointi[15+i]   = cur_bar->p_sensi_int[i] - offs_int_s *
                                                        cur_bar->evaliv_2d[i];
    cur_bar->pointi[6+i]    = cur_bar->p_sensi_int[i] + offs_int_s *
                                                        cur_bar->offseti_2d[i];
    cur_bar->pointi[9+i]    = cur_bar->p_sensi_int[i] + offs_int_s *
                                                        cur_bar->evaliv_2d[i];
    cur_bar->pointi[12+i]   = cur_bar->p_sensi_int[i] - offs_int_s *
                                                        cur_bar->offseti_2d[i]; 
  }

  return(TRUE);


wrapup:
  return (FALSE);
}









                  
/*

Name

    Blend_dyn_bar
Abstract

    This is a dynamic function called every time the mouse is moved.

Synopsis
*/
    IGRint Blend_dyn_sf(
                         struct DPele_header   *DY1info,
                         struct EX_button      *point,
                         IGRdouble             *matrix,
                         struct GRid          **objects,
                         IGRint                *num_objects,
                         struct DPele_header  **buffers,
                         IGRint                *num_buffers,
                         IGRchar               *dummy_in1,
                         IGRchar               *dummy_in2,
                         IGRchar               *dummy_in3,
                         IGRchar              **dummy_out1,
                         IGRchar              **dummy_out2,
                         IGRchar              **dummy_out3)



/*

Description

    This function handle all dynamic blend tasks.

Return Value

    Returns..


History

    27 Sep 93   HOB     Creation
*/


{
   IGRlong       loc_msg;
   IGRlong       rc;                           /*  BS return code    */
   IGRlong       sts;                          /*  OM return status  */
   IGRint        dyn_update1, dyn_update2,     /*  > 0 if dynamic update needed  */
                 dyn_update3; 
   IGRint        i;                            /*  loop index  */
   IGRint        j, k;                         /*  loop index  */

   IGRdouble     mat_wtv[16];                  /*  world to view matrix  */
   IGRdouble     eps;                          /*  used tolerance */

   IGRpoint  zero_pnt = { 0.0, 0.0, 0.0 };     /*  plane base point  */





  if (first_run)
  {
    /*  set no more first run  */
    first_run = FALSE;
    last_activ_bar = 0;
    last_w_window = -1;

    /*  display preset buffer  */   
    *num_buffers = ind_arr;             
    *buffers = DY1info;

    return(TRUE);   
  }


  /*  check for window change  */
  if (last_w_window != point->window ||       
      last_w_objid  != point->objid  ||    
      last_w_osnum  != point->osnum) 
  {

    /* ----------------------- */
    /* ---- window change ---- */
    /* ----------------------- */

    last_w_window = point->window;       
    last_w_objid  = point->objid;    
    last_w_osnum  = point->osnum; 
    last_activ_bar = 0;
  
    /*  calculate new view dependent bar midline  */
    dp$inq_window_info(msg           = &loc_msg,
                       osnum         = last_w_osnum,
                       window_objid  = last_w_objid,
                       view_rotation = &rot_matrix,
                       world_to_view = &mat_wtv);
    if (!(1&loc_msg))  goto wrapup;

    /*  copy significant members for rotation matrix  */
    for (k = 0, j = 0; j < 3; j++)
    {    
      for (i = 0; i < 3; i++)                 
        mat[j][i] = rot_matrix[k+i]; 
      k = k + 4;
    }

    eps = 0.001;
    /*  calculate work view zoom faktor  */
    if   (ABS(rot_matrix[0]) > eps)  disp_fakt = mat_wtv[0] / rot_matrix[0];
    else
    {
      if (ABS(rot_matrix[1]) > eps)  disp_fakt = mat_wtv[1] / rot_matrix[1];
      else                           disp_fakt = mat_wtv[2] / rot_matrix[2];
    }

    if (last_wrk_sel == WRK_INT_BLND1)
    {
      /*  get space and data for projected int blend point search  */
      if (cvw)  {  BSfreecv(&rc, cvw); cvw = NULL; }
      BSalloccv(bar1_data.cv_a->order,    bar1_data.cv_a->num_poles,
                bar1_data.cv_a->rational, bar1_data.cv_a->num_boundaries,
                &cvw, &rc);
      if (BSERROR(rc))  goto wrapup; 
       
      BSprj_cv_pl(&rc, bar1_data.cv_a, zero_pnt, mat[2], mat[2], cvw);
      if (BSERROR(rc))  goto wrapup;      
    }


    if (last_wrk_sel == WRK_INT_BLND2)
    {
      /*  get space and data for projected int blend point search  */
      if (cvw)  {  BSfreecv(&rc, cvw); cvw = NULL; }
      BSalloccv(bar2_data.cv_a->order,    bar2_data.cv_a->num_poles,
                bar2_data.cv_a->rational, bar2_data.cv_a->num_boundaries,
                &cvw, &rc);
      if (BSERROR(rc))  goto wrapup; 
       
      BSprj_cv_pl(&rc, bar2_data.cv_a, zero_pnt, mat[2], mat[2], cvw);
      if (BSERROR(rc))  goto wrapup;                              
    }


    if (last_wrk_sel == WRK_HEDGEHOG)
    {
      for (i=0; i<4; i++)
      {
        BSprj_cv_pl(&rc, igel_edges[i], zero_pnt, mat[2], mat[2], igel_projt[i]);
        if (BSERROR(rc))  goto wrapup; 
      }      
    }


    disp_fakt  = WITH_FAKT / disp_fakt; 
    offs_int_d = FAK_INT_D * disp_fakt;  
    offs_int_s = FAK_INT_S * disp_fakt;  
    maxdist = CATCH * 2.0 * FAKQ * disp_fakt;  /*  take bar width as base distance  */
    fak_marker = 0.35 * FAKQ * disp_fakt;      /*  sensitiv barpoint marker length */

    /*  prepare bar view data  */

    /*  map curve1 basepoint to mouse view  */
    BSptoldtnw( &rc, trans_vec, mat, &scale, bar1_data.eval[0], bar1_data.eval_rot);
    if (BSERROR(rc))  goto wrapup; 
    bar1_data.eval_rot[2] = 0.0;
                           
    /*  map curve2 basepoint to mouse view  */
    BSptoldtnw( &rc, trans_vec, mat, &scale, bar2_data.eval[0],bar2_data.eval_rot);
    if (BSERROR(rc))  goto wrapup; 
    bar2_data.eval_rot[2] = 0.0; 

    dist_bar1_bar2_rot = BSdistptpt(&rc, bar1_data.eval_rot, bar2_data.eval_rot);
    if (BSERROR(rc))  goto wrapup; 

    fakt2d3d =  dist_bar1_bar2_rot/dist_bar1_bar2;       


    /*  prepare bar line  */
    sts = BLs_prep_view(&bar1_data);  
    if (!sts)  goto wrapup;  
 

    /*  prepare second line  */
    sts = BLs_prep_view(&bar2_data);
    if (!sts)  goto wrapup; 


    /*  prepare special  */
    if (cv_diagnos) 
    {              
      /*  prepare hedgehog sign points  */
      sts =  BLs_dis_h_sign(hd_cur_param, hd_index);
      if (!sts)  goto wrapup;   
    }
  } 
  /*  end of window change  */
  

  /******************************/
  /*   interpret mouse change   */  
  /******************************/

  /*  decide nearest bar to mouse */
  mouse[0] = point->x;
  mouse[1] = point->y;
  mouse[2] = point->z;

  /*  map mousepoint to new mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, mouse, mouse_rot);
  if (BSERROR(rc))  goto wrapup; 


  /*  calculate bore point on zero plane im world view  */
  bore_base[0] = mouse_rot[0];
  bore_base[1] = mouse_rot[1];   
  bore_base[2] = NULL;
  BSptnwtold( &rc, trans_vec, mat, &scale, bore_base, bore_base);
  if (BSERROR(rc))  goto wrapup;
 
  mouse_rot_2d[0] = mouse_rot[0];
  mouse_rot_2d[1] = mouse_rot[1];
  mouse_rot_2d[2] = 0.0;


  dyn_update1 = dyn_update2 = dyn_update3 = 0;



  switch (last_wrk_sel)
  {

    case WRK_TANG1:
    {
      sts =  BLs_calc_new_bar( &bar1_data );
      if (!sts)  goto wrapup; 
      if (symmetric)
      {
        bar2_data.bar_ratio = bar1_data.bar_ratio;  /* force same ratio     */
        bar2_data.cur_dir   = bar1_data.cur_dir * cor_sym_dir;    /* force same direction */ 
        if (!bar1_data.zoom_activ || !bar2_data.zoom_activ)
          sts = BLs_prep_view(&bar2_data);     /* force same display   */
        else
        {
          /*  set base points  */
          for (i=0; i<3; i++)
          {
            bar2_data.point_cur[i]  =
            bar2_data.points[3+i]   =
            bar2_data.pointsc[i]    = 
            bar2_data.point_base[i] = bar2_data.eval[0][i] + bar1_data.sym_offset
                                                           * bar1_data.sym_dir
                                                           * cor_sym_dir
                                                           * bar2_data.eval[1][i];
          }
        }
      }
      break;
    }



    case WRK_TANG2:
    {
      sts =  BLs_calc_new_bar( &bar2_data );
      if (!sts)  goto wrapup;
      if (symmetric)
      {
        bar1_data.bar_ratio = bar2_data.bar_ratio;  /* force same ratio     */
        bar1_data.cur_dir   = bar2_data.cur_dir * cor_sym_dir;    /* force same direction */ 
        if (!bar1_data.zoom_activ || !bar2_data.zoom_activ)
          sts = BLs_prep_view(&bar1_data);     /* force same display   */
        else
        {
          /*  set base points  */
          for (i=0; i<3; i++)
          {
            bar1_data.point_cur[i]  = 
            bar1_data.points[3+i]   = 
            bar1_data.pointsc[i]    = 
            bar1_data.point_base[i] = bar1_data.eval[0][i] + bar2_data.sym_offset
                                                           * bar2_data.sym_dir
                                                           * cor_sym_dir
                                                           * bar1_data.eval[1][i]; 
          }
        }  
      }
      break;   
    }


    case WRK_INT_BLND1:
    { 
      sts = BLs_mov_iblend( &bar1_data, &dyn_update1);
      if (!sts)  goto wrapup;    
      if (dyn_update1 > 0)
      {
        /*  start_cond.blend_pt_par = bar1_data.cur_par_cv;  */
        if (bar1_data.zoom_activ)
        {
          sts = BLs_prep_zoom( &bar1_data );
          if (!sts)  goto wrapup;
        }   
      }
      break;
    }


    case WRK_INT_BLND2:
    {
      sts = BLs_mov_iblend( &bar2_data, &dyn_update2); 
      if (!sts)  goto wrapup;   
      if (dyn_update2 > 0)
      {
        /*  ende_cond.blend_pt_par = bar2_data.cur_par_cv;  */
        if (bar2_data.zoom_activ)
          {
          sts = BLs_prep_zoom( &bar2_data );
          if (!sts)  goto wrapup; 
        }
        break;   
      }   
    }

    case WRK_HEDGEHOG:
    {
      sts =  BLs_mov_h_sign( &hd_index, &hd_cur_param, &dyn_update3); 
      if (dyn_update3)
      {
        /*  update hedgehog sign if any change  */
        sts =  BLs_prep_h_iso(hd_index); 
        sts =  BLs_dis_h_sign(hd_cur_param, hd_index);
      }
      break;
    }


    case WRK_ROT_VEC1:
    {
      sts = BLs_mov_vec(&bar1_data, &dyn_update1); 
      if (!sts)  goto wrapup; 
      break;
    }


    case WRK_ROT_VEC2:
    {
      sts = BLs_mov_vec(&bar2_data, &dyn_update2); 
      if (!sts)  goto wrapup;
      break; 
    }
 
  default:
    /*  update display  */
    if (dyn_update1 > 0 || dyn_update2 > 0)  goto dyndis;

    return(TRUE);           

  }


dyndis:

  /*-------------------------*/
  /*  call the math routine  */
  /*-------------------------*/

  if (last_wrk_sel != WRK_HEDGEHOG)
  {
    /*  dont need to recalculate in case of hedgehog move  */ 
    start_cond.boundary_flag    = bar1_data.boundary_flag;
    start_cond.tangent_value[1] = ABS(bar1_data.bar_ratio);
    start_cond.blend_pt_par[0]  = bar1_data.cur_par_sf_s;
    start_cond.blend_pt_par[1]  = bar1_data.cur_par_sf_e;
    start_cond.direction        = bar1_data.cur_dir * bar1_data.aval_dir;
    start_cond.pariso           = bar1_data.par_iso;

    ende_cond.boundary_flag     = bar2_data.boundary_flag;
    ende_cond.tangent_value[1]  = ABS(bar2_data.bar_ratio);
    ende_cond.blend_pt_par[0]   = bar2_data.cur_par_sf_s;
    ende_cond.blend_pt_par[1]   = bar2_data.cur_par_sf_e;
    ende_cond.direction         = bar2_data.cur_dir * bar2_data.aval_dir;
    ende_cond.pariso            = bar2_data.par_iso;

    sf1 = bar1_data.sf;
    sf2 = bar2_data.sf;
    boundary_flag[0] = start_cond.boundary_flag;
    boundary_flag[1] = ende_cond.boundary_flag;
    blend_pt_par[0][0] = start_cond.blend_pt_par[0];
    blend_pt_par[0][1] = start_cond.blend_pt_par[1];
    blend_pt_par[1][0] = ende_cond.blend_pt_par[0];
    blend_pt_par[1][1] = ende_cond.blend_pt_par[1];
    pariso[0] = start_cond.pariso;
    pariso[1] = ende_cond.pariso;
    direction[0] = start_cond.direction;
    direction[1] = ende_cond.direction;
    tangent_flag[0] = start_cond.tangent_flag[1];
    tangent_flag[1] = ende_cond.tangent_flag[1];
    tangent_value[0] = start_cond.tangent_value[1];
    tangent_value[1] = ende_cond.tangent_value[1];
    curvature_flag[0] = start_cond.curvature_flag;
    curvature_flag[1] = ende_cond.curvature_flag;
    approx_flag[0] = start_cond.approx_flag;
    approx_flag[1] = ende_cond.approx_flag;
    approx_fact[0] = start_cond.approx_fact;
    approx_fact[1] = ende_cond.approx_fact;

    XBSblndsrfg2(sf1,                
                sf2,              
                boundary_flag,
                blend_pt_par,
                pariso,
                direction,
                tangent_flag,
                tangent_value,
                curvature_flag,
                approx_flag,
                approx_fact,
                (IGRint )blend_order,
                tolarr,
                &blndsrf,
                &inform,
                &rc);
    if (BSERROR(rc))  goto wrapup;
  } 

  if (cv_diagnos)               
  {
    /*---------  update hedgehog  -------------*/
    /*  extract iso curves  */
    sts =  BLs_prep_h_iso(hd_index); 
    /*  update iso sign  */ 
    sts =  BLs_dis_h_sign(hd_cur_param, hd_index);
    /*  calculate curvature hegdgehog polyline  */
    pointhh = orig_pointhh;
    sts =  BLs_hedgehog(igel_cur, max_length, NUM_HH_POINTS, pointhh);
    if (!sts)  lineh.num_points = 0;
    else       lineh.num_points = NUM_HH_POINTS - 1;
               
  }

  /*  update dynamic surface data  */
  sts =  BLs_prep_sf_disp(1, blndsrf, srf_disp,
                          p_u_rules, p_v_rules, p_u_bounds, p_v_bounds); 


  /*  we are drawing dynamic graphic objects  */  
  return(TRUE);


wrapup:
  return(FALSE);

}









 


/* ================================================================ */
/*  this routine creates the storage for the dynamic modify   bbbb  */
/* ================================================================ */

IGRint ECblendsf_d(  
         IGRint                            bar_control,  /*  bar display control */
         IGRint                            *status,      /*  termination status */            
         IGRdouble                         sensi_fakt1,
         IGRdouble                         sensi_fakt2,
         IGRint                            dyn_bar,       /* 1 = bar1 / 2 = bar2 */
         IGRint                            dyn_iso,       /* 1 = bar1 / 2 = bar2 */
         IGRint                            dyn_vector,    /* 1 = bar1 / 2 = bar2 */
         IGRint                            *response,
         IGRchar                           *response_data,
         struct EMSblend_sf_end_condition  *b_start_cond,
         struct EMSblend_sf_end_condition  *b_ende_cond,
         struct HDbd_ext_inf               *b_start_inf,
         struct HDbd_ext_inf               *b_ende_inf,
         IGRboolean                        diagnos, 
         IGRshort                          blnd_order,                       
         IGRint                            *ext_hd_index,       
         IGRdouble                         *ext_hd_cur_param,
         IGRdouble                         *rot_mat,    
         IGRdouble                         *disp_fakt_init)


{

  IGRlong         loc_msg;
  IGRlong         rc;                    /*  BS return code  */
  IGRlong         sts;                   /*  OM return status  */
  IGRlong         size;
  IGRint          i, k, j, ii; 
  IGRint          n;                     /*  number of hedgehob peaks  */
  IGRlong         num_lines;             /*  max number of u/v-lines  */
  IGRshort        iso_num_bound = NULL;
  IGRshort        curve_order;           /*  order used (max)      */
  IGRshort        curve_num_poles;       /*  num poles used (max)  */
  IGRint          event_mask;
  struct GRevent  param_event;
  IGRdouble       epsw;
  IGRdouble       BSlenvec();
  IGRboolean      first_disp = TRUE;
  IGRdouble       *w_rot_mat;            /*  work pointer matrix  */  



  /********************/
  /*  Initialisation  */
  /********************/

  /*  reset all allocs  */
  srf_disp   = blndsrf    = NULL;
  p_u_rules  = p_v_rules  = NULL;
  p_u_bounds = p_v_bounds = NULL;

  bar1_data.csf = bar1_data.sf = bar1_data.sf_orig = NULL;
  bar2_data.csf = bar2_data.sf = bar2_data.sf_orig = NULL;

  bar1_data.cv =
  bar2_data.cv = NULL;

  cvw = NULL;

  pointhh   = NULL;
  hedge_buf = NULL;
  igel_cur  = igel_sgn = NULL;

  for (i=0; i<4; i++)
    igel_edges[i] = igel_projt[i] = NULL;



  *status = 0;
  if (bar_control != 0)  leader_line = FALSE;
  else                   leader_line = TRUE;

  blend_order = blnd_order;
                              
  /*  mark first step  */
  first_run = TRUE;
  last_wrk_sel = 0;

  /* copy main basic surface structure  */
  start_cond = *b_start_cond;
  bar1_data.sf = start_cond.surface;
  ende_cond  = *b_ende_cond;
  bar2_data.sf = ende_cond.surface;

  disp_fakt  = WITH_FAKT / *disp_fakt_init;  /*  preset with zoom fakt from locate  */
  offs_int_d = FAK_INT_D * disp_fakt; 
  offs_int_s = FAK_INT_S * disp_fakt; 
  maxdist = CATCH * 2.0 * FAKQ * disp_fakt;  /*  take bar width as base distance  */
  fak_marker = 0.35 * FAKQ * disp_fakt;      /*  sensitiv barpoint marker length */
 
  /*  get general tolerance values  */
  BSEXTRACTPAR (&rc,BSTOLBASIS,tolarr[0]); 
  if (BSERROR(rc))  goto wrapup; 
  eps = tolarr[0];
  BSEXTRACTPAR (&rc,BSTOLCOLLINVEC,tolarr[1]);
  if (BSERROR(rc))  goto wrapup;  
  BSEXTRACTPAR (&rc,BSTOLLENVEC,tolarr[2]);
  if (BSERROR(rc))  goto wrapup;  

  /*  set hedgehog start values to last used  */ 
  cv_diagnos = 1 & diagnos;             /*  save curvature diagnostic switch */
  symmetric  = 4 & diagnos;             /*  save surface  symmetric flag  */
  hd_cur_param  = *ext_hd_cur_param;    /*  initial start/end position  */
  hd_index      = *ext_hd_index;        /*  initial value               */

  /*  set basic matrix/vector  */
  scale = 1.0;                   /*  scale = 1  */

  for (i=0; i<3; i++)
  {
    trans_vec[i] = 0.0;          /*  translate vector = none */  
  }

  w_rot_mat = rot_mat;
  for (i=0; i<3; i++)
  {
    for (j=0; j<3; j++)
     mat[i][j] = *w_rot_mat++;
  }
 
  /*---  startup element 1  ---*/

  /*  preset bar1 array with basic work parameters  */
  bar1_data.cur_dir         = start_cond.direction;
  bar1_data.bar_ratio       = start_cond                                                .tangent_value[1];
  bar1_data.cur_sensi       = sensi_fakt1;
  bar1_data.cv_flag         = start_cond.boundary_flag;
  bar1_data.par_iso         = start_cond.pariso;
  bar1_data.cont            = start_cond.curvature_flag + 1;   
  bar1_data.cur_par_sf_s    = start_cond.blend_pt_par[0];
  bar1_data.cur_par_sf_e    = start_cond.blend_pt_par[1];
  bar1_data.col_dir         = b_start_inf->col_dir; 
  bar1_data.dyn_bar         = 1&dyn_bar;
  bar1_data.dyn_iso         = 1&dyn_iso;    
  bar1_data.dyn_vector      = 1&dyn_vector;


  if (!bar1_data.cv_flag)
  {
    for (j=0; j<2; j++)
      for (i=0; i<3; i++)
        bar1_data.dir_vec[j][i] = b_start_inf->dir_vec[j][i];

    bar1_data.ib_crv = b_start_inf->ib_crv;
    bar1_data.acv = NULL; 
  } 

  sts = BLs_startup(&bar1_data);
  if (!sts)  goto wrapup;


  /*---  startup element 2  ---*/

  /*  preset bar2 array with basic work parameters  */
  bar2_data.cur_dir         = ende_cond.direction; 
  bar2_data.bar_ratio       = ende_cond.tangent_value[1];
  bar2_data.cur_sensi       = sensi_fakt2;
  bar2_data.cv_flag         = ende_cond.boundary_flag;
  bar2_data.par_iso         = ende_cond.pariso;
  bar2_data.cont            = ende_cond.curvature_flag + 1;     
  bar2_data.cur_par_sf_s    = ende_cond.blend_pt_par[0];
  bar2_data.cur_par_sf_e    = ende_cond.blend_pt_par[1];
  bar2_data.col_dir         = b_ende_inf->col_dir; 
  bar2_data.dyn_bar         = 2&dyn_bar;
  bar2_data.dyn_iso         = 2&dyn_iso; 
  bar2_data.dyn_vector      = 2&dyn_vector;

  if (!bar2_data.cv_flag)
  {
    for (j=0; j<2; j++)
      for (i=0; i<3; i++)
        bar2_data.dir_vec[j][i] = b_ende_inf->dir_vec[j][i];

    bar2_data.ib_crv = b_ende_inf->ib_crv;
    bar2_data.acv = NULL; 
  }
  sts = BLs_startup(&bar2_data);
  if (!sts)  goto wrapup;

  if (symmetric)
  {
    cor_sym_dir = bar1_data.cur_dir * bar2_data.cur_dir;
  }


  /*  prepare blend surface call  */
  start_cond.boundary_flag = ABS(bar1_data.cv_flag);
  if (bar1_data.dyn_iso)  start_cond.boundary_flag += 4;
  start_cond.surface = bar1_data.sf;

  ende_cond.boundary_flag = ABS(bar2_data.cv_flag);
  if (bar2_data.dyn_iso)  ende_cond.boundary_flag += 4;
  ende_cond.surface = bar2_data.sf;

  if (!bar1_data.cv_flag)   sts = BLs_startup_exc(&bar1_data, 0);
  if (!bar2_data.cv_flag)   sts = BLs_startup_exc(&bar2_data, 0);

  if (!bar1_data.cv_flag || !bar2_data.cv_flag)
  { 
    sts = BLs_startup_exc(&bar1_data, 1);
    sts = BLs_startup_exc(&bar2_data, 1);
  }

  if (!bar1_data.cv_flag)
  {
    sts = BLs_startup_exc(&bar1_data, 2);
    start_cond.surface       = bar1_data.sf;
    start_cond.boundary_flag = bar1_data.boundary_flag;
  }

  if (!bar2_data.cv_flag)
  {
    sts = BLs_startup_exc(&bar2_data, 2);
    ende_cond.surface       = bar2_data.sf;
    ende_cond.boundary_flag = bar2_data.boundary_flag;
  }

  sf1 = start_cond.surface;
  sf2 = ende_cond.surface;
  /*  dont need to recalculate in case of hedgehog move  */ 
  start_cond.boundary_flag    = bar1_data.boundary_flag;
  start_cond.tangent_value[1] = ABS(bar1_data.bar_ratio);
  start_cond.blend_pt_par[0]  = bar1_data.cur_par_sf_s;
  start_cond.blend_pt_par[1]  = bar1_data.cur_par_sf_e;
  start_cond.direction        = bar1_data.cur_dir * bar1_data.aval_dir;
  start_cond.pariso           = bar1_data.par_iso;

  ende_cond.boundary_flag     = bar2_data.boundary_flag;
  ende_cond.tangent_value[1]  = ABS(bar2_data.bar_ratio);
  ende_cond.blend_pt_par[0]   = bar2_data.cur_par_sf_s;
  ende_cond.blend_pt_par[1]   = bar2_data.cur_par_sf_e;
  ende_cond.direction         = bar2_data.cur_dir * bar2_data.aval_dir;
  ende_cond.pariso            = bar2_data.par_iso;

  boundary_flag[0] = start_cond.boundary_flag;
  boundary_flag[1] = ende_cond.boundary_flag;
  blend_pt_par[0][0] = start_cond.blend_pt_par[0];
  blend_pt_par[0][1] = start_cond.blend_pt_par[1];
  blend_pt_par[1][0] = ende_cond.blend_pt_par[0];
  blend_pt_par[1][1] = ende_cond.blend_pt_par[1];
  pariso[0] = start_cond.pariso;
  pariso[1] = ende_cond.pariso;
  direction[0] = start_cond.direction;
  direction[1] = ende_cond.direction;
  tangent_flag[0] = start_cond.tangent_flag[1];
  tangent_flag[1] = ende_cond.tangent_flag[1];
  tangent_value[0] = start_cond.tangent_value[1];
  tangent_value[1] = ende_cond.tangent_value[1];
  curvature_flag[0] = start_cond.curvature_flag;
  curvature_flag[1] = ende_cond.curvature_flag;
  approx_flag[0] = start_cond.approx_flag;
  approx_flag[1] = ende_cond.approx_flag;
  approx_fact[0] = start_cond.approx_fact;
  approx_fact[1] = ende_cond.approx_fact;

  XBSblndsrfg2(sf1,                
              sf2,              
              boundary_flag,
              blend_pt_par,
              pariso,
              direction,
              tangent_flag,
              tangent_value,
              curvature_flag,
              approx_flag,
              approx_fact,
              (IGRint )blend_order,
              tolarr,
              &blndsrf,
              &inform,
              &rc);
  if (BSERROR(rc))  goto wrapup;

  /*  Get the pole and the knot extents for that portion of the surface  */
  /*  that is affected by the pole to be modified.                       */
  /*  get space for dynamic display of blend surface and preset buffer   */

  /*  get space for dynamic display of u/v lines  */
  num_lines = MAX(blndsrf->u_num_poles, blndsrf->v_num_poles);

  u_end_pl = num_lines - 1;
  v_end_pl = num_lines - 1;

  BSallocsf (blndsrf->u_order     +1,         /*  + 1 for savety  */
             blndsrf->v_order     +1, 
             u_end_pl + 1         +1,
             v_end_pl + 1         +1,
             blndsrf->rational,
             blndsrf->num_boundaries,
             &srf_disp,
             &rc);
  if  (rc != BSSUCC)  goto wrapup;

  p_u_rules = malloc(num_lines*sizeof (IGRdouble));
  if (!p_u_rules)  Goto (wrapup);

  p_v_rules = malloc(num_lines*sizeof (IGRdouble));
  if (!p_v_rules)  Goto (wrapup);

  p_u_bounds = malloc(num_lines*sizeof (IGRint));
  if (!p_u_bounds)  Goto (wrapup);

  p_v_bounds = malloc(num_lines*sizeof (IGRint));
  if (!p_u_bounds)  Goto (wrapup);

  /*  preset dynamic surface display buffer  */
  sts =  BLs_prep_sf_disp(0, blndsrf, srf_disp, 
                          p_u_rules, p_v_rules, p_u_bounds, p_v_bounds);

  /*  calculate the main blend distance  */
  dist_bar1_bar2 = BSdistptpt( &rc, bar1_data.eval[0], bar2_data.eval[0]);
  if (BSERROR(rc))  goto wrapup; 
  bar1_data.bar_length = bar1_data.dyn_bar_length = dist_bar1_bar2;
  bar2_data.bar_length = bar2_data.dyn_bar_length = dist_bar1_bar2;

  /*  prepare first line  */
  bar1_data.cv_a = NULL;
  sts = BLs_prep_view( &bar1_data);
  if (!sts)  goto wrapup;

  /*  prepare second line  */
  bar2_data.cv_a = NULL;
  sts = BLs_prep_view( &bar2_data); 
  if (!sts)  goto wrapup;  

  /*  prepare diagnostics (hedgehog)  */  
  if (cv_diagnos)
  {
    curve_order     = MAX(blndsrf->u_order, blndsrf->v_order);
    curve_num_poles = MAX(blndsrf->u_num_poles, blndsrf->v_num_poles);

    /*  allocate space for work iso curves  */
    for (i=0; i<4; i++)
    {
      igel_edges[i] = NULL;
      BSalloccv(curve_order, curve_num_poles, blndsrf->rational, iso_num_bound,
                &igel_edges[i], &rc );
      if ( rc != BSSUCC )  goto wrapup;

      igel_projt[i] = NULL;
      BSalloccv(curve_order, curve_num_poles, blndsrf->rational, iso_num_bound,
                &igel_projt[i], &rc );
      if ( rc != BSSUCC )  goto wrapup;
    }

    BSalloccv(curve_order, curve_num_poles, blndsrf->rational, iso_num_bound,
              &igel_cur, &rc );
    if ( rc != BSSUCC )  goto wrapup;
    BSalloccv(curve_order, curve_num_poles, blndsrf->rational, iso_num_bound,
              &igel_sgn, &rc );
    if ( rc != BSSUCC )  goto wrapup;
    orig_pointhh =
    pointhh      = (IGRdouble *) malloc (3* NUM_HH_POINTS*sizeof (IGRdouble));
    if (!pointhh)  goto wrapup;

    /*  preset variables  */
    max_length    = dist_bar1_bar2 / 4.0;  /*  use 1/4 3d bar length  */
    hd_cur_uv     = 0.333;                 /*  any value in range  */
    hd_cur_opt    = 2;                     /*  any value in range  */

    /*  get work space for hedgehog  */ 
    n = NUM_HH_POINTS/2 + 1;
    hedge_buf = (IGRdouble *) malloc (7 * (n+2)*sizeof(IGRdouble)); 
    if (!hedge_buf) goto wrapup;
    /*  set up workbuffers  */ 
    nx  = hedge_buf + 0*n;    
    ny  = hedge_buf + 1*n;
    nz  = hedge_buf + 2*n;
    rho = hedge_buf + 3*n;
    p_x = hedge_buf + 4*n;
    p_y = hedge_buf + 5*n;
    p_z = hedge_buf + 6*n;

    /*  extract iso curves  */
    sts =  BLs_prep_h_iso(hd_index); 
    /*  preset curvature hedgehog sign */
    sts =  BLs_dis_h_sign(hd_cur_param, hd_index);
    /*  calculate curvature hegdgehog polyline  */
    pointhh =  orig_pointhh;
    sts =  BLs_hedgehog(igel_cur, max_length, NUM_HH_POINTS, pointhh);
    if (!sts)  goto wrapup;
  }



  /* ----------------------------------- */
  /*  initialize bar1/2 display buffers  */
  /* ----------------------------------- */

  bar1_data.line.points = bar1_data.points;
  bar1_data.line.num_points = 2;

  bar1_data.pntsc.points = bar1_data.pointsc;
  bar1_data.pntsc.num_points = 1;

  bar1_data.linei.points = bar1_data.pointi;
  bar1_data.linei.num_points = 6;


  bar2_data.line.points = bar2_data.points;
  bar2_data.line.num_points = 2;

  bar2_data.pntsc.points = bar2_data.pointsc;
  bar2_data.pntsc.num_points = 1;

  bar2_data.linei.points = bar2_data.pointi;
  bar2_data.linei.num_points = 6;

  /*  hedgehog  */
  lineh.points = orig_pointhh;
  lineh.num_points = NUM_HH_POINTS - 1;

  /*  hedgehog position sign  */
  lines.points = pointss;
  lines.num_points = 4;
   
  /*  int blend direction vector  */
  bar1_data.linev.points = bar1_data.pointv;
  bar1_data.linev.num_points = 6;
 
  bar2_data.linev.points = bar2_data.pointv;
  bar2_data.linev.num_points = 6;
                    



  /*  get default display symbology from Default Parameter Block (DPB)  */
  sts = gr$get_active_display(buffer = &fix_bar_display);
  fix_bar_display.weight = 0;             /*  dont preset thicker line  */
  dyn_bar_display    =
  zoom_bar_display_f =
  zoom_bar_display_d =
  hedgehog_display   =
  hd_base_display    =
  pnt1_bar_display   =
  pnt2_bar_display   =
  int1_bar_display   =
  int2_bar_display   =
  dyn_vec1_display   =
  dyn_vec2_display   =
  hd_sgn_display     = fix_bar_display;

  dyn_bar_display.weight    = 2;
  dyn_bar_display.style     = 5;
  zoom_bar_display_f.weight = 2;
  zoom_bar_display_d.weight = 5;
  hd_sgn_display.weight   = L_WEIGHT_MIN;
  dyn_vec1_display.weight = L_WEIGHT_MIN;
  dyn_vec2_display.weight = L_WEIGHT_MIN;
  pnt1_bar_display.weight = P_WEIGHT_MIN;
  pnt2_bar_display.weight = P_WEIGHT_MIN;
  int1_bar_display.weight = L_WEIGHT_MIN;
  int2_bar_display.weight = L_WEIGHT_MIN;
  hd_sgn_display.weight   = L_WEIGHT_MIN;
  hd_base_display.weight  = 0;
  hd_base_display.style   = 0;

  ind_arr = 0;                                             /* ---0--- */
  dp$build_dis_buffer(buffer       = &display_elements[ind_arr],
                      display_att  = &fix_bar_display,
                      ele_spec_att = &esqs,
                      flags        = NULL,        
                      geometry     = srf_disp,
                      type         = IGRQS);
  ind_arr++;                                               /* ---1--- */

  if (bar1_data.dyn_bar)  
  {
    /*  current bar1 ratio display  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &dyn_bar_display,
                        geometry    = &bar1_data.line,
                        type        = IGRPY);
    ind_arr++;                                             /* ---2--- */

    /*  bar1 sensitiv position marker  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &pnt1_bar_display,
                        geometry    = &bar1_data.pntsc,
                        type        = IGRPS);
    ind_arr++;                                             /* ---3--- */
  }

  if (bar2_data.dyn_bar)  
  {
    /*  current bar2 ratio display  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &dyn_bar_display,
                        geometry    = &bar2_data.line,
                        type        = IGRPY);
    ind_arr++;                                             /* ---4--- */

    /*  bar2 sensitiv position marker  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &pnt2_bar_display,
                        geometry    = &bar2_data.pntsc,
                        type        = IGRPS);
    ind_arr++;                                             /* ---5--- */

  }
 


  if (bar1_data.dyn_iso) 
  {
    /*  internal blend-1 pos selector */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &int1_bar_display,
                        geometry    = &bar1_data.linei,
                        type        = IGRPY);
    ind_arr++;                                             /* ---6--- */
  }

  if (bar2_data.dyn_iso)  
  {
    /*  internal blend-2 pos selector */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &int2_bar_display,
                        geometry    = &bar2_data.linei,
                        type        = IGRPY);
    ind_arr++;                                             /* ---7--- */
  }


  if (bar1_data.dyn_vector)  
  {
    /*  int blend vector sign  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &dyn_vec1_display,
                        geometry    = &bar1_data.linev,
                        type        = IGRPY);
    ind_arr++;                                             /* ---8--- */
  }


  if (bar2_data.dyn_vector)   
  {
    /*  int blend vector sign  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &dyn_vec2_display,
                        geometry    = &bar2_data.linev,
                        type        = IGRPY);
    ind_arr++;                                             /* ---9--- */
  }


  if (cv_diagnos)   
  {
    /*  bs curve needs element attributes!  */
    bc_attr.is_polydis  = FALSE;  
    bc_attr.is_curvedis = TRUE;

    /*  display curvature hedgehog  */
    dp$build_dis_buffer(buffer = &display_elements[ind_arr],
                        display_att  = &hd_base_display,
                        ele_spec_att = &bc_attr,
                        flags        = NULL,     
                        geometry     = igel_cur,   /* current hedgehog base curve */
                        type         = IGRBC);
    ind_arr++;                                             /* ---10--- */

    /*  diagnostic position sign  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &hd_sgn_display,
                        geometry    = &lines,
                        type        = IGRPY);
    ind_arr++;                                             /* ---11--- */
        
    /*  display curvature hedgehog points  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr], 
                       display_att = &hedgehog_display,
                       geometry    = &lineh,
                       type        = IGRPY);
    ind_arr++;                                             /* ---12--- */ 


    /*  display current iso curve from hedgehog  */
    /*  bs curve needs element attributes!  */
    bc_attr.is_polydis  = FALSE;  
    bc_attr.is_curvedis = TRUE;

    tsty_bar_display = fix_bar_display;
    tsty_bar_display.weight = 0;         /*  2  */
    tsty_bar_display.style  = 0;         /*  4  */

    /*  display curvature basic iso curve  */
    dp$build_dis_buffer(buffer = &display_elements[ind_arr],
                        display_att  = &tsty_bar_display,
                        ele_spec_att = &bc_attr,
                        flags        = NULL,    
                        geometry     = igel_sgn,  
                        type         = IGRBC);
    ind_arr++;                                             /* ---13--- */

  }




 
  /* ---------------------------------- */
  /* ---  select dynamic work mode  --- */
  /* ---------------------------------- */
 

  {

    IGRint      ii;
    IGRlong     txt_index;
    IGRdouble   dist_cur;
    IGRdouble   dist_min;          /*  miminum distance to sensitiv point  */
    IGRpoint    mouse_rot;         /*  mouse point in mouse view  */
    IGRpoint    sensi_rot;         /*  current sensitive point in mouse view  */
                  
    IGRdouble   rot_matrix[16];    /*  mouse view rotation matrix  */
    IGRdouble   mat_wtv[16];       /*  world to view matrix  */



repeat:

    /* clear all elements if buffers  */
    for (ii=0; ii<ind_arr; ii++)
    {
      dp$display(msg    = &loc_msg,
                 buffer = &display_elements[ii],
                 mode   = GRhe);
    }

    /*  set last used to medium size marked  */
    if (last_wrk_sel == WRK_TANG1)     pnt1_bar_display.weight = P_WEIGHT_MED;
    if (last_wrk_sel == WRK_TANG2)     pnt2_bar_display.weight = P_WEIGHT_MED;
    if (last_wrk_sel == WRK_INT_BLND1) int1_bar_display.weight = L_WEIGHT_MED;
    if (last_wrk_sel == WRK_INT_BLND2) int2_bar_display.weight = L_WEIGHT_MED;
    if (last_wrk_sel == WRK_ROT_VEC1)  dyn_vec1_display.weight = L_WEIGHT_MED;
    if (last_wrk_sel == WRK_ROT_VEC2)  dyn_vec2_display.weight = L_WEIGHT_MED;
    if (last_wrk_sel == WRK_HEDGEHOG)  hd_sgn_display.weight   = L_WEIGHT_MED;


    /*  highlight all elements if buffers  */
    for (ii=0; ii<ind_arr; ii++)
    {
      dp$display(msg    = &loc_msg,
                 buffer = &display_elements[ii],
                 mode   = GRhd);
    }

    dist_cur = event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_DATA;
 
    sts = co$getevent(msg           = &loc_msg,
                      event_mask    = event_mask,
                      msgnum        = SELECT_NEXT_DYN,
                      response      = response,
                      response_data = response_data,    
                      event         = &param_event);
    if (!(1&sts&loc_msg))  goto wrapup;

    /*  not DATA means terminate modify at all */
    if (*response != EX_DATA) 
    {
      /*  reset highlight all elements if buffers  */
      for (ii=0; ii<ind_arr; ii++)  
      {
        dp$display(msg    = &loc_msg,
                   buffer = &display_elements[ii],
                   mode   = GRhe);
      }
      goto finish;
    }
    
    /***********************************/
    /*  response == EX_DATA            */
    /*  handle dynamic task selection  */
    /***********************************/

    /*  get current mouse data  */
    mouse[0]      = param_event.event.button.x;         
    mouse[1]      = param_event.event.button.y;         
    mouse[2]      = param_event.event.button.z;

    last_w_window = param_event.event.button.window;       
    last_w_objid  = param_event.event.button.objid;    
    last_w_osnum  = param_event.event.button.osnum;  

    /*  extract window rotation matrix  */
    dp$inq_window_info(msg           = &loc_msg,
                       osnum         = last_w_osnum,
                       window_objid  = last_w_objid,
                       view_rotation = &rot_matrix,
                       world_to_view = &mat_wtv);
    if (!(1&sts&loc_msg))  goto wrapup;

    /*  copy significant members for rotation matrix  */
    for (k = 0, j = 0; j < 3; j++)
    {    
      for (i = 0; i < 3; i++)                 
        mat[j][i] = rot_matrix[k+i]; 
      k = k + 4;
    }

 
    /*  recalculate view dependent values  */
    epsw = 0.001;
    /*  calculate work view zoom faktor  */
    if   (ABS(rot_matrix[0]) > epsw)  disp_fakt = mat_wtv[0] / rot_matrix[0];
      else
      if (ABS(rot_matrix[1]) > epsw)  disp_fakt = mat_wtv[1] / rot_matrix[1];
      else                            disp_fakt = mat_wtv[2] / rot_matrix[2];
    disp_fakt = WITH_FAKT / disp_fakt; 
    offs_int_d = FAK_INT_D * disp_fakt; 
    offs_int_s = FAK_INT_S * disp_fakt;  
    fak_marker = 0.35 * FAKQ * disp_fakt;  /* sensitiv barpoint marker length */

    /*  map mousepoint to new mouse view  */
    BSptoldtnw(&rc, trans_vec, mat, &scale, mouse, mouse_rot);
    if (BSERROR(rc))  goto wrapup; 

    mouse_rot_2d[0] = mouse_rot[0];
    mouse_rot_2d[1] = mouse_rot[1];
    mouse_rot_2d[2] = 0.0;

    /*  choose nearest sensitiv point to mouse position  */ 

    /*  map bar dyn end to new mouse view  */
    BSptoldtnw(&rc, trans_vec, mat, &scale, bar1_data.point_cur, sensi_rot);
    if (BSERROR(rc))  goto wrapup;  
    sensi_rot[2] = 0.0;
    /*  calculate point distance  */
    dist_min = BSdistptpt(&rc, mouse_rot, sensi_rot);
    if (BSERROR(rc))  goto wrapup; 

    if (first_disp)
    {
      first_disp = FALSE;
      if (bar1_data.dyn_iso    || bar2_data.dyn_iso
       || bar1_data.dyn_vector || bar2_data.dyn_vector  || cv_diagnos)
      {
        /*  clear / display all elements if buffers  */
        for (ii=0; ii<ind_arr; ii++)
        {
          dp$display(msg = &loc_msg, buffer = &display_elements[ii],
                     mode = GRhe);
        }
        /*  recalculate sign for current mouse window */
        if (bar1_data.dyn_iso)    sts = BLs_dis_ibl_sign(&bar1_data);
        if (bar2_data.dyn_iso)    sts = BLs_dis_ibl_sign(&bar2_data);
        if (bar1_data.dyn_vector) sts = BLs_prep_bar_lines(&bar1_data);
        if (bar2_data.dyn_vector) sts = BLs_prep_bar_lines(&bar2_data);
        if (cv_diagnos)           sts = BLs_dis_h_sign(hd_cur_param, hd_index);

        /*  clear / display all elements if buffers  */
        for (ii=0; ii<ind_arr; ii++)
        {
          dp$display(msg = &loc_msg, buffer = &display_elements[ii],
                     mode = GRhd);
        }
      }
    }

    last_wrk_sel = WRK_TANG1;
    txt_index    = DYN_TANGENT_1;

    BSptoldtnw(&rc, trans_vec, mat, &scale, bar2_data.point_cur, sensi_rot);
    if (BSERROR(rc))  goto wrapup;  
    sensi_rot[2] = 0.0;
    /*  calculate point distance  */
    dist_cur = BSdistptpt(&rc, mouse_rot, sensi_rot);
    if (BSERROR(rc))  goto wrapup;
    if (dist_cur < dist_min)
    {
      dist_min     = dist_cur;
      last_wrk_sel = WRK_TANG2;
      txt_index    = DYN_TANGENT_2;
    }

    if (bar1_data.dyn_iso)
    {
      /*  map vied dep curve blendpoint marker  to mouse view  */
      BSptoldtnw( &rc, trans_vec, mat, &scale, bar1_data.p_sensi_int, sensi_rot);
      if (BSERROR(rc))  goto wrapup;
      sensi_rot[2] = 0;
      /*  calculate point distance  */
      dist_cur = BSdistptpt( &rc, mouse_rot, sensi_rot);
      if (BSERROR(rc))  goto wrapup; 
      if (dist_cur < dist_min)
      {
        dist_min     = dist_cur;
        last_wrk_sel = WRK_INT_BLND1;
        txt_index    = DYN_INT_POINT1;
      }
    }

    if (bar2_data.dyn_iso)
    {
      /*  map vied dep curve blendpoint marker  to mouse view  */
      BSptoldtnw( &rc, trans_vec, mat, &scale, bar2_data.p_sensi_int, sensi_rot);
      if (BSERROR(rc))  goto wrapup;
      sensi_rot[2] = 0;
      /*  calculate point distance  */
      dist_cur = BSdistptpt( &rc, mouse_rot, sensi_rot);
      if (BSERROR(rc))  goto wrapup;
      if (dist_cur < dist_min)
      {
        dist_min     = dist_cur;
        last_wrk_sel = WRK_INT_BLND2;
        txt_index    = DYN_INT_POINT2;
      }
    }

    if (bar1_data.dyn_vector)
    {
      /*  map bar dyn end to new mouse view  */
      BSptoldtnw( &rc, trans_vec, mat, &scale, bar1_data.point_bar_end, sensi_rot);
      if (BSERROR(rc))  goto wrapup; 
      sensi_rot[2] = 0.0; 

      /*  calculate point distance  */
      dist_cur = BSdistptpt( &rc, mouse_rot, sensi_rot);
      if (BSERROR(rc))  goto wrapup;
      if (dist_cur < dist_min)
      {
        dist_min     = dist_cur;
        last_wrk_sel = WRK_ROT_VEC1;
        txt_index    = DYN_ROT_POINT1;
      }
    }


    if (bar2_data.dyn_vector)
    {
      /*  map bar dyn end to new mouse view  */
      BSptoldtnw( &rc, trans_vec, mat, &scale, bar2_data.point_bar_end, sensi_rot);
      if (BSERROR(rc))  goto wrapup; 
      sensi_rot[2] = 0.0;

      /*  calculate point distance  */
      dist_cur = BSdistptpt( &rc, mouse_rot, sensi_rot);
      if (BSERROR(rc))  goto wrapup;
      if (dist_cur < dist_min)
      {
        dist_min     = dist_cur;
        last_wrk_sel = WRK_ROT_VEC2;
        txt_index    = DYN_ROT_POINT2;
      }
    }
 
    if (cv_diagnos)
    {
      /*  map bar dyn end to new mouse view  */
      BSptoldtnw( &rc, trans_vec, mat, &scale, evalh[0], sensi_rot);
      if (BSERROR(rc))  goto wrapup; 
      sensi_rot[2] = 0.0; 

      /*  calculate point distance  */
      dist_cur = BSdistptpt( &rc, mouse_rot, sensi_rot);
      if (BSERROR(rc))  goto wrapup;
      if (dist_cur < dist_min)
      {
        dist_min     = dist_cur;
        last_wrk_sel = WRK_HEDGEHOG;
        txt_index    = DYN_HEDGEHOG;
      }
    }

    /*  reset nearest sensi point marker (=weight)  */ 
    pnt1_bar_display.weight = P_WEIGHT_MIN;
    pnt2_bar_display.weight = P_WEIGHT_MIN;
    int1_bar_display.weight = L_WEIGHT_MIN;
    int2_bar_display.weight = L_WEIGHT_MIN;
    dyn_vec1_display.weight = L_WEIGHT_MIN;
    dyn_vec2_display.weight = L_WEIGHT_MIN;
    hd_sgn_display.weight   = L_WEIGHT_MIN;
    /*  mark new selected sensi marker  */
    if (last_wrk_sel == WRK_TANG1)     pnt1_bar_display.weight = P_WEIGHT_MAX;
    if (last_wrk_sel == WRK_TANG2)     pnt2_bar_display.weight = P_WEIGHT_MAX;
    if (last_wrk_sel == WRK_INT_BLND1) int1_bar_display.weight = L_WEIGHT_MAX;
    if (last_wrk_sel == WRK_INT_BLND2) int2_bar_display.weight = L_WEIGHT_MAX;
    if (last_wrk_sel == WRK_ROT_VEC1)  dyn_vec1_display.weight = L_WEIGHT_MAX;
    if (last_wrk_sel == WRK_ROT_VEC2)  dyn_vec2_display.weight = L_WEIGHT_MAX;
    if (last_wrk_sel == WRK_HEDGEHOG)  hd_sgn_display.weight   = L_WEIGHT_MAX;

    /*  highlight all elements if buffers with selected in bigger size  */
    for (ii=0; ii<ind_arr; ii++)
    {
      dp$display(msg    = &loc_msg,
                 buffer = &display_elements[ii],
                 mode   = GRhd);
    }

    /*  tell user what to do now  */
    sts = ex$message(msgnumb = txt_index);     
  

    /*------------------------------------*/
    /*---  start the dynamics display  ---*/
    /*------------------------------------*/

    GRstatus_display_button(FALSE);     /*  no options during dyn shown  */
    first_run = TRUE;
    sts = dp$dynamics(dyn_fun     = Blend_dyn_sf,
                      information = &display_elements);


    /*  this function is terminated by event (mouse click)  */
    /*  get the input  (without wait)                       */
    size = SIZE;
    sts = ex$wait_for_input(response   = response,
                            buffer     = response_data,    
                            byte       = (int *)&size);

    GRstatus_display_button(TRUE);     /*  display options after dyn  */

  }



  /*****************/
  /*  Termination  */
  /*****************/


  /*  User has left dynamics be entering an event. Get the event  */
  /*  to allow buffer draw                                        */

  /* clear all elements if buffers  */
  for (ii=0; ii<ind_arr; ii++)
  {
    dp$display(msg    = &loc_msg,
               buffer = &display_elements[ii],
               mode   = GRhe);
  }

  /*  recalculate iso marker  */
  sts = BLs_prep_view( &bar1_data);
  sts = BLs_prep_view( &bar2_data);  

  /*  redisplay all elements if buffers  */
  for (ii=0; ii<ind_arr; ii++)
  {
    dp$display(msg    = &loc_msg,
               buffer = &display_elements[ii],
               mode   = GRhd);
  }

  if (*response == EX_DATA)  goto repeat;

  /*  display all elements if buffers  */
  for (ii=0; ii<ind_arr; ii++)
  {
    dp$display(msg    = &loc_msg,
               buffer = &display_elements[ii],
               mode   = GRhe);
  }


finish:

  /*****************/
  /*  Termination  */
  /*****************/


  *status = 1;
  if (*response == EX_RJT_MOVEON)   *status = END_BY_MOVEON;
  if (*response == EX_CMD_KEY)      *status = END_BY_CMD;
  if (*response == GR_UNKNOWN_TYPE) *status = END_BY_CMD;

  /*  update internal blend: dynamic vector  */

  if (bar1_data.cv_flag == 0  && bar1_data.dyn_vector)  
  {
    for (j=0; j<2; j++)
      for (i=0; i<3; i++)
        b_start_inf->dir_vec[j][i] = bar1_data.dir_vec[j][i];
  }

  if (bar2_data.cv_flag == 0  &&  bar2_data.dyn_vector)  
  {
    for (j=0; j<2; j++)
      for (i=0; i<3; i++)
        b_ende_inf->dir_vec[j][i] = bar2_data.dir_vec[j][i];
  }

  /*  copy work basic surface structure to main  */
  *b_start_cond = start_cond;
  *b_ende_cond  = ende_cond;

  /* save last used hedgehog values  */
  *ext_hd_cur_param = hd_cur_param;       /*  initial start/end position  */
  *ext_hd_index     = hd_index;           /*  initial value               */

  /*  save last used rotation matrix  */
  w_rot_mat = rot_mat;
  for (i=0; i<3; i++)
  {
    for (j=0; j<3; j++)
      *w_rot_mat++ = mat[i][j];
  }
  /*  save last used zoom factor  */
  *disp_fakt_init =  WITH_FAKT / disp_fakt;

  /*  release all higlights  */
  dp$erase_hilite(msg = &loc_msg);
       


releas:
  if (srf_disp)      BSfreesf(&loc_msg, srf_disp);
  if (blndsrf)       BSfreesf(&rc, blndsrf);
  if (p_u_rules)     free(p_u_rules);
  if (p_v_rules)     free(p_v_rules);
  if (p_u_bounds)    free(p_u_bounds);
  if (p_v_bounds)    free(p_v_bounds);

  if (bar2_data.cv)  free(bar2_data.cv);
  if (bar1_data.cv)  free(bar1_data.cv);

  if (bar1_data.csf) BSfreesf(&rc, bar1_data.csf);
  if (bar2_data.csf) BSfreesf(&rc, bar2_data.csf);

  if (cvw)           BSfreecv(&rc, cvw); 

  if (pointhh)       free(orig_pointhh);

  if (hedge_buf)     free(hedge_buf);
  if (igel_cur)      free(igel_cur);
  if (igel_sgn)      free(igel_sgn);
  for (i=0; i<4; i++)
  {
    if (igel_edges[i])  BSfreecv(&rc, igel_edges[i]);
    if (igel_projt[i])  BSfreecv(&rc, igel_projt[i]);
  }

  return (*status);


wrapup:

  *status = FALSE;
  goto releas;
}



end implementation ECblendsf;
   

