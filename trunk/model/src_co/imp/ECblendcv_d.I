
class implementation ECblendcv;
     
 
# include <math.h>

# include "bsparameters.h"         /*  bspmath */
# include "bstypes.h"              /*  bspmath */

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
# include "COretcodef.h"            /*  COMMAND_FIELD */
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
# include "ecblc_macros.h"
# include "dpstruct.h"  
# include "igrtypedef.h" 
# include "igrdef.h"  
# include "msdef.h"            /*  MS message codes  */
# include "OMerrordef.h"       /*  OM error definitions  */
# include "msmacros.h"           
# include "emsmacros.h"
# include "igrdp.h"
# include "bserr.h"
# include "dpezmac.h"          /*  dp$inq_window   */
# include "exmacros.h"         /*  ex$wait..  */
# include "dpdef.h"
# include "bsconic.h"

# include "EMSblend_cv.h"

# include "emblendcv.h"       /*  function prototype  */
# include "bsblndcrvg2.h"     /*  function prototype  */
# include "bsdistptli.h"      /*  function prototype  */ 
# include "bslenvec.h"        /*  function prototype  */    
# include "bsdistptpt.h"      /*  function prototype  */ 
# include "bsint2lns.h"       /*  function prototype  */ 
# include "bsdptseg2.h"       /*  function prototype  */ 
# include "bsproj0.h"         /*  function prototype  */
# include "bsptoldtnw.h"      /*  function prototype  */
# include "bsptnwtold.h"      /*  function prototype  */
# include "bsdotp.h"          /*  function prototype  */
# include "bsnorvec.h"        /*  function prototype  */
# include "bscveval.h"        /*  function prototype  */
# include "bsmdstptcv.h"      /*  function prototype  */
# include "bsmdistcvcv.h"     /*  function prototype  */
# include "bscveval.h"        /*  function prototype  */
# include "bsmdptcvbx.h"      /*  function prototype  */
# include "bsprepcirc.h"      /*  function prototype  */
# include "bsalloccv.h"       /*  function prototype  */
# include "bsfreecv.h"        /*  function prototype  */
# include "bsprj_cv_pl.h"     /*  function prototype  */


#define MAX_POLES        9    /*  max poles for dyn pole display  */
#define NUM_DYN         23+MAX_POLES  /*  number of dynamic elements   */  
#define NUM_HH_POINTS  100    /*  number of hedgehog points   */  

#define CATCH          2.0    /*  bar sensitive faktor (in bar line width)  */
#define FAKQ          0.06    /*  bar display offset faktor, looks nice  */
#define FAKDARK       0.04    /*  zoom marker dark offset  */
#define FAKZOOM        2.0    /*  zoom bar marker offset faktor  */
#define FAK_INT_D      0.45   /*  int blend  marker distance faktor  */
#define FAK_INT_S      0.15   /*  int blend marker size faktor  */
#define FAK_MID         0.5   /*  mid bar position  */
#define WITH_FAKT        60   /*  bar leader line distance faktor  */

#define P_WEIGHT_POL      5   /*  polygon poles point weight  */
#define P_WEIGHT_MIN     10   /*  min sensitiv point weight  */
#define P_WEIGHT_MAX     15   /*  max sensitiv point weight  */
#define P_WEIGHT_MED     12   /*  med sensitiv point weight  */
#define L_WEIGHT_MIN      1   /*  min sensitiv line weight   */
#define L_WEIGHT_MAX      4   /*  max sensitiv line weight   */
#define L_WEIGHT_MED      2   /*  med sensitiv line weight   */

#define INDX1            1    /*  dynamic buffer index bar1    */
#define INDX2            2    /*  dynamic buffer index bar2    */

#define WRK_TANG1         1   /*  work: move tangent 1 */
#define WRK_TANG2         2   /*  work: move tangent 2 */
#define WRK_INT_BLND1     3   /*  work: move internal blend 1 */
#define WRK_INT_BLND2     4   /*  work: move internal blend 2 */

#define SIZE           1024;  /*  buffer size  */
#define MINVAL         0.001  /*  minimum ratio value usable  */

#define END_BY_MOVEON    3
#define END_BY_CMD       5


# define MAX(x,y)    ((x) < (y) ? (y) :(x))
# define MIN(x,y)    ((x) < (y) ? (x) :(y))
# define ABS(x)      ((x) < 0 ? -(x) : (x))
  

extern OMuword  OPP_GRcurve_class_id;
extern OMuword  OPP_EMSsubbs_class_id;

from GRvg       import GRgetsize,
                       GRgetgeom;

/* text for prompts and other messages */

/*                    "Select task to modify/options/terminate"  */
#define SELEXT_NEXT_DYN       EMS_P_Se_Ta_Mo__Op__Te

/*                           "Modify tangent 1/Accept"  */
#define DYN_TANGENT_1         EMS_P_Mo_Ta_1__Acc

/*                           "Modify tangent 2/Accept"  */
#define DYN_TANGENT_2         EMS_P_Mo_Ta_2__Acc

/*             "Modify internal point 1 position/Accept"  */
#define DYN_INT_POINT1        EMS_P_Mo_In_Po_1_Po__Acc

/*             "Modify internal point 1 position/Accept"  */
#define DYN_INT_POINT2        EMS_P_Mo_In_Po_2_Po__Acc




  static IGRdouble  mat[3][3];                     /*  view rotation matrix  */
  static IGRvector  trans_vec;                     /*  translate vector = none */

  static IGRdouble  scale;

  static IGRint     num_pnt_blend;                 /*  number of blendpoints  */

  static IGRdouble poles1[6];                      /* mouse view bore_line data */ 

  static IGRdouble  cor_sym_dir;                   /*  cor direction for sym  */


struct bar_data
       {

         IGRboolean zoom_activ;        /*  zoom activ for bar | old=zoom1    */
         IGRboolean int_blend_activ;   /*  internal blend flag | old=iblend1 */
         IGRboolean bar_check;         /*  bar sensi point check true = in   */
         IGRboolean int_blend_check;   /*  internal blend check  true = in   */

         struct     IGRbsp_curve  *cv; /*  pointer to the abstract geometry */
         IGRdouble  cur_dir;           /*  current bar direction  +/- 1 */
         IGRdouble  base_dir;          /*  base bar direction  */
         IGRdouble  last_dir;          /*  last bar direction  +/-   */
         IGRint     red_fakt;          /*  bar display reducing faktor */
         IGRdouble  cur_sensi;         /*  bar sensibility faktor */

         IGRdouble  bar_length_cur;   
         IGRdouble  dyn_bar_length;         
         IGRdouble  bar_length; 
         IGRdouble  bar_ratio;
         IGRdouble  last_ratio;
         IGRdouble  base_bar_ratio;
         IGRvector  bar_length_base;

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
         IGRdouble  fakt_zoom_pos;     /*  cur zoom base base pos */
         IGRdouble  z_offset[3];       /*  perpto bar normalized for zoom */
         IGRdouble  zoom_length;
         IGRdouble  fak_mid;

         /*  evaluation / direction  */
         IGRpoint  eval[3];            /*  point and 1st/2nd derivate  */
         IGRpoint  evalx[3];           /*  int blend point and 1st/2nd deriv */
         IGRpoint  eval_rot;           /*  point  */
         IGRpoint  evalx_rot;          /*  int blend point  rot  */
         IGRpoint  evalxv_rot;         /*  int blend  1st derivate rot  */
         IGRpoint  evalx_2d;           /*  int blend point 2d  */
         IGRpoint  evalxv_2d;          /*  int blend vector 2d  */

         IGRdouble  offset[3];         /*  perpto bar normalized  */
         IGRdouble  sym_offset;        /*  real length of ratio bar  */
         IGRdouble  sym_dir;           /*  real direction of ratio bar  */

         /*  internal blend  */
         IGRpoint   last_int;          /*  last used int blendpoint  */
         IGRpoint   int_pos_rot;       /*  current 2d int blend pos  */
         IGRpoint   p_sensi_int;       /*  cur view dep int blend marker pos */
         IGRpoint   p_sensi_rot;       /*  cur rot int blend marker pos */
         IGRdouble  offsetx_2d[3];     /*  perpto int blend1 dir norm. rot.  */
         IGRdouble  offsetx[3];        /*  perpto int blend1 dir normalized  */
         struct GRid      cv_grid;     /*  base curve  GRid        */    
         struct GRmdenv_info cv_envinf; /*  base curve environment info  */  

         /*  blendcurve generation variables  */
         IGRdouble valx;
         IGRdouble cur_par_cv;         /*  actual int blend param  */
         IGRdouble wrk_par_cv ;        /*  work int blend param  */

         /*  bar display  */
         IGRpoint   point_cur;         /*  current 3d bar sensitive point  */
         IGRpoint   point_cur_rot;     /*  current 2d bar sensitive point  */
         IGRpoint   mid_linea;
         IGRpoint   mid_lineb;


         /*        main dynamic bar                                       */
         /* _a   = left bar marker       / _b   = right bar marker        */
         /* _c   = current dynamic end marker                             */
         /* _d,e = left bar zoom marker  / _f,g = base pos zoom marker    */
         /*        current work position is a dark dot in the zoom bar    */

         struct IGRpolyline line;
         struct IGRpolyline linea;
         struct IGRpolyline lineb;
         struct IGRpointset pntsc;
         struct IGRpolyline lined;
         struct IGRpolyline linee;
         struct IGRpolyline linef;
         struct IGRpolyline lineg;
         struct IGRpolyline linei;     /*  internal blend sign  */ 

         IGRdouble  points[6];         /*  dynamic line  */          
         IGRdouble  pointsa[6];        /*  coord. of line/a buffer  */ 
         IGRdouble  pointsb[6];        /*  coord. of line/b buffer  */
         IGRdouble  pointsc[3];        /*  coord. of pnts/c buffer  */
         IGRdouble  pointsd[6];        /*  coord. of line/d buffer  */
         IGRdouble  pointse[6];        /*  coord. of line/e buffer  */
         IGRdouble  pointsf[6];        /*  coord. of line/f buffer  */
         IGRdouble  pointsg[6];        /*  coord. of line/g buffer  */
         IGRdouble  pointi[18];        /*  coord. of int blend sign buffer */
         };

static struct bar_data    bar1_data;  
static struct bar_data    bar2_data;  

static IGRint     cur_task;           /*  main dynamic task  */
static IGRboolean leader_line;        /*  true if leader line display  */
static IGRboolean first_run;          /*  dyn display init flag  */
static IGRint     last_wrk_sel;       /*  last work selected  */
static IGRint     last_activ_bar;     /*  last activ bar  (0 = none)  */
static IGRdouble  eps;                /*  general used work eps  */ 
static IGRdouble  tolarr[3];          /*  [0]  same point tolerance       */
                                      /*  [1]  same angle tolerance       */
                                      /*  [2]  degeneracy of derivatives  */

static IGRint     ind_arr;            /*  current dyn display buffer number */
static IGRlong    last_w_window;      /*  last mouse window used  */
                                      /*  -1 = initial            */
static OM_S_OBJID last_w_objid;       /*  last mouse window objid used  */
static uword      last_w_osnum;       /*  last mouse window osnum used  */

static IGRdouble  dist_bar1_bar2;
static IGRdouble  dist_bar1_bar2_rot;
static IGRdouble  fakt2d3d;             /*  length faktor 2d/3d bar length */
static IGRdouble  fak_marker;           /*  sensitiv barpoint marker length */

 
/*  blend generation variables  */
   
static struct IGRbsp_curve  *cv1;        /* pointer to the abstract geometry
                                            of curve object 1 */
static struct IGRbsp_curve  *cv2;        /* pointer to the abstract geometry
                                            of curve object 2 */
static struct IGRbsp_curve  *blndcrv;    /* pointer to the blend curve */

static struct EMSblend_cv_end_condition  start_cond;
static struct EMSblend_cv_end_condition  end_cond;

static IGRdouble  blend_pt_par[2]; 
static IGRint     direction[2]; 
static IGRint     tangent_flag[2];
static IGRdouble  tangent_value[2];
static IGRint     curvature[2];  
static IGRint     info;
  

static IGRdouble  last_dis_bar1_ratio;
static IGRdouble  last_dis_bar2_ratio;

static IGRint      siz;  
static IGRdouble   *p_x, *p_y, *p_z;        /*  hedgehog work buffer  */
static IGRdouble   *nx, *ny, *nz;           /*  hedgehog work buffer  */
static IGRdouble   *rho;                    /*  hedgehog work buffer  */


  /*  commmon used dynamic values  */
  static struct DPele_header display_elements[NUM_DYN];  /*  display buffers */

  static struct IGRbsp_curve  *circcrv;       /* pointer to the circle curve */

  /*  Activate color, style, weight, ...  */
  static struct IGRdisplay dyn_bar_display;
  static struct IGRdisplay fix_bar_display;
  static struct IGRdisplay dot_bar_display;
  static struct IGRdisplay pnt1_bar_display;
  static struct IGRdisplay pnt2_bar_display;
  static struct IGRdisplay pnt_poles_display;
  static struct IGRdisplay zoom_bar_display_d;
  static struct IGRdisplay zoom_bar_display_f;
  static struct IGRdisplay int1_bar_display;
  static struct IGRdisplay int2_bar_display;
  static struct IGRdisplay hedgehog_display;
  static struct IGRdisplay circ_display;


  static IGRpoint   mouse;                /*  3d_mouse coordinates  */         
  static struct IGRbsp_curve  bore_line;  /*  mouse view bore_line */
  static struct IGRbsp_curve  *cvw;       /*  ptr to planar int blend cv  */ 
  static IGRvector  bore_vect;            /*  bore line direction  */
  static IGRpoint   mouse_rot_2d;         /*  mouse point          */
  static IGRpoint   mouse_rot;            /*  mouse point          */
  static IGRdouble  disp_fakt;            /*  current work view zoom factor  */
  static IGRdouble  offs_int_d;           /*  view dep int blend sign dist 1  */
  static IGRdouble  offs_int_s;           /*  view dep int blend sign dist 2  */

  static IGRdouble  epsw;
  
  /*  dynamic circle input data  */
  static struct IGRpolyline linecir1;      /*  circle centerline 1  */ 
  static struct IGRpolyline linecir2;      /*  circle centerline 2  */ 
  static        IGRdouble  pointscir1[6];  /*  coord. of centerline1 buffer  */
  static        IGRdouble  pointscir2[6];  /*  coord. of centerline2 buffer  */
  static IGRdouble  radius;                /*  radius of dyn cirvle mode  */
  static IGRvector  cir_vec, cir_vecn;     /*  current centerl. disp vector */

  /*  hedgehog data  */
  static struct IGRpolyline lineh;            /*  hedgehog display buffe  */ 
  static IGRdouble  pointhh[3*NUM_HH_POINTS]; /*  coord. of hedgehog buffer */
  static IGRdouble  max_length;               /*  max length of offset */

  static IGRboolean cv_diagnos;               /*  curvature diagnostics  */
  static IGRboolean toggle_poly;              /*  toggle polygon         */
  static IGRboolean symmetric;                /*  symmetric curve build  */

  /*  poles display data  */
  static        IGRint      n_disp_poles;
  static struct IGRpointset pntsp[MAX_POLES];  /*  poles points  */
  static        IGRpoint    poles_pnt[MAX_POLES];









/* ========================================================= */
/*   this routine builds the boreline for based on s curve   */
/* ========================================================= */

IGRint BL_handle_bore_line(

         IGRint               task,   /* I:  0 = initialize new curve  */
                                      /* I:  1 = find nearest curvepoint to mouse */
         struct bar_data  *cur_bar,   /* I:  current work bar  */
         IGRdouble        *par )      /* O:  nearest curvepoint parameter  */         

         /* return = FALSE in case of error  */



{
  IGRlong        rc;                            /*  return code            */
  IGRpoint       base;                          /*  nearest point on curve */
  IGRdouble      dist;                          /*  nearest distance to cv */
  IGRpoint       bore_base;                     /*  projected mouse point  */


  IGRpoint       zero_point = { 0.0, 0.0, 0.0 };   /* plane base point */



  if (task == 0)
  {
    /*  get space and data for projected int blend point search  */
    if (cvw)  BSfreecv(&rc, cvw);
      BSalloccv(cur_bar->cv->order, cur_bar->cv->num_poles,
                cur_bar->cv->rational, cur_bar->cv->num_boundaries, &cvw, &rc);
      if (BSERROR(rc))  goto wrapup;

      BSprj_cv_pl(&rc, cur_bar->cv, zero_point, mat[2], mat[2], cvw);
      if (BSERROR(rc))  goto wrapup;
  }


                            
  if (task == 1)
  {
    /*  find nearest point to local mouse point on projected curve  */
    bore_base[0] = mouse_rot[0];
    bore_base[1] = mouse_rot[1];   
    bore_base[2] = NULL;
    BSptnwtold( &rc, trans_vec, mat, &scale, bore_base, bore_base);
    if (BSERROR(rc))  goto wrapup; 
      
    BSmdstptcv(cvw, bore_base, par, base, &dist, &rc);
    if (BSERROR(rc))  goto wrapup; 
  }

  return (TRUE);


wrapup:
  return (FALSE);
}








/* ====================================== */
/*  this routine prepares basic bar data  */
/* ====================================== */

IGRint BL_prep_basic_bar( struct bar_data  *cur_bar)
    
/*                   parameter:                          */            
/*                   cur_bar     activ bar definition    */   
 
                     /* return = FALSE in case of error  */                   


{

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
    cur_bar->points[3+i]     =       /*  error 1  */
    cur_bar-> point_base[i]  = cur_bar->eval[0][i] + cur_length
                                                     * cur_bar->eval[1][i]
                                                     * cur_bar->cur_dir;

    cur_bar->z_point_base[i] = cur_bar->eval[0][i] + cur_bar->fakt_zoom_pos 
                                                     * cur_bar->bar_length
                                                     * cur_bar->eval[1][i]
                                                     * cur_bar->cur_dir;
    /*  set midline end point  */  
    cur_bar->mid_lineb[i] = cur_bar->mid_linea[i] + cur_bar->bar_length
                                                    * cur_bar->eval[1][i];
  }

  /*  setup two parallel lines of tangent length  */
  for (i=0; i<3; i++)
  {
    cur_bar->pointsa[i]   = cur_bar->eval[0][i] + cur_bar->offset[i];
    cur_bar->pointsa[3+i] = cur_bar->pointsa[i] + cur_bar->bar_length*
                                    cur_bar->eval[1][i]*cur_bar->cur_dir;
    cur_bar->pointsb[i]   = cur_bar->pointsa[i]   - 2*cur_bar->offset[i];
    cur_bar->pointsb[3+i] = cur_bar->pointsa[3+i] - 2*cur_bar->offset[i];

    /*  mark sensitiv end  by point  */                               
    cur_bar->pointsc[i] = cur_bar->point_cur[i];
  }
 
  return(TRUE);


/*  wrapup:  */
/*  return (FALSE);  */
}










/* ================================================== */
/*  this routine prepares bar data for current view   */
/* ================================================== */

IGRint BL_prep_view( struct bar_data  *cur_bar)
    
/*                   parameter:                          */            
/*                   cur_bar     activ bar definition    */   

                     /* return = FALSE in case of error  */                    


{

  IGRlong     rc;                                /*  BS return code    */

  IGRpoint    work;
  IGRvector   vect;

  IGRint i;



  /*  map bar direction to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->eval[1], work);
  if (BSERROR(rc))  goto wrapup; 

  /*  calculate bar direction length in mouse view  */
  cur_bar->bar_length_rot = BSdistptpt(&rc, trans_vec, work);
  if (BSERROR(rc))  goto wrapup; 
  work[2] = 0.0;

  cur_bar->bar_length_rot_2d = BSdistptpt( &rc, trans_vec, work);
  if (BSERROR(rc))  goto wrapup; 

  cur_bar->bar_2d_factor = cur_bar->bar_length_rot / cur_bar->bar_length_rot_2d;
  cur_bar->bar_length_cur = cur_bar->bar_length * fakt2d3d * cur_bar->bar_2d_factor; 

  /*  set perpto bar direction  */
  vect[0] = -work[1];
  vect[1] =  work[0];
  vect[2] =  0.0;

  /*  normalize 2d vector  */
  BSnorvec( &rc, vect);
  if (BSERROR(rc))  goto wrapup; 

  /*  map bar perpto offset back to world coord  */
  BSptnwtold( &rc, trans_vec, mat, &scale, vect, cur_bar->offset);
  if (BSERROR(rc))  goto wrapup; 

  /*  correct for same small distance (view dependent) */
  for (i=0; i<3; i++)
    cur_bar->offset[i] *= FAKQ * disp_fakt;

  /*  map bar dyn end to new mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->point_cur,
               cur_bar->point_cur_rot);
  if (BSERROR(rc))  goto wrapup;  
  cur_bar->point_cur_rot[2] = 0.0;

  /*  map bar linepoint a to new mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->mid_linea,
               cur_bar->mid_linea_rot);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->mid_linea_rot[2] = 0.0;         /*  force 2D handling  */

  /*  map bar linepoint b to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->mid_lineb,
               cur_bar-> mid_lineb_rot);  
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->mid_lineb_rot[2] = cur_bar->mid_linea_rot[2];  /*  force 2D handling  */

  /*  prepare 2d line  */
  for (i=0; i<2; i++)
  {
    cur_bar->line_2d[0][i] = cur_bar->mid_linea_rot[i];
    cur_bar->line_2d[1][i] = cur_bar->mid_lineb_rot[i];
  }
  cur_bar->line_2d[0][2] = 0.0;
  cur_bar->line_2d[1][2] = 0.0;
 
  cur_bar->bar_leng_2d = BSdistptpt( &rc, cur_bar->line_2d[0],
                                      cur_bar->line_2d[1]); 
  if (BSERROR(rc))  goto wrapup; 

  /*  calculate bar dynamic end to new mouse view  */
  /*  (recalculate point_cur if zooming on )  */
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
  BSptoldtnw(&rc, trans_vec, mat, &scale, cur_bar->point_cur,
              cur_bar-> point_cur_rot);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->point_cur_rot[2] = 0.0; 
 
  /*  map bar base direction to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->bar_length_base,
               cur_bar->bar_base_dir);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->bar_base_dir[2] = 0.0;         /*  force 2D handling  */


  /*  position start-marker to  ratio faktor of bar length  */
  for (i=0; i<3; i++)
  {
    /*  setup two parallel lines of tangent length  */
    cur_bar->pointsa[i]   = cur_bar->eval[0][i] + cur_bar->offset[i];
    cur_bar->pointsa[3+i] = cur_bar->pointsa[i] + cur_bar->bar_length_cur
                              *cur_bar->eval[1][i]*cur_bar->cur_dir;
    cur_bar->pointsb[i]   = cur_bar->pointsa[i]   - 2*cur_bar->offset[i];
    cur_bar->pointsb[3+i] = cur_bar->pointsa[3+i] - 2*cur_bar->offset[i];

    cur_bar->z_point_base[i] = cur_bar->eval[0][i] + cur_bar->z_rel_bar_point
                                                     * cur_bar->bar_length_cur
                                                     * cur_bar->eval[1][i]
                                                     * cur_bar->cur_dir;
 
  }

  return(TRUE);


wrapup:
  return (FALSE);
}





/* ======================================================= */
/*  this routine prepares zoom bar data for current view   */
/* ======================================================= */

IGRint BL_prep_zoom( struct bar_data  *cur_bar )

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

    cur_bar->pointsd[i]    = cur_bar->point_base[i] - dark_offset + cur_bar->z_offset[i];
    cur_bar->pointsd[3+i]  = cur_bar->point_base[i] - work_offset + cur_bar->z_offset[i];

    cur_bar->pointse[i]    = cur_bar->point_base[i] + dark_offset + cur_bar->z_offset[i];
    cur_bar->pointse[3+i]  = cur_bar->point_base[i] + work_offset + cur_bar->z_offset[i];

    cur_bar->pointsf[i]    = cur_bar->point_base[i] - dark_offset - cur_bar->z_offset[i];
    cur_bar->pointsf[3+i]  = cur_bar->point_base[i] - work_offset - cur_bar->z_offset[i];

    cur_bar->pointsg[i]    = cur_bar->point_base[i] + dark_offset - cur_bar->z_offset[i];
    cur_bar->pointsg[3+i]  = cur_bar->point_base[i] + work_offset - cur_bar->z_offset[i];
  }

  return(TRUE);

}






/* ============================================================= */
/*  this routine prepares internal blend data for current view   */
/* ============================================================= */

IGRint BL_prep_iblend( struct bar_data  *cur_bar )   

/*                   parameter:                          */            
/*                   cur_bar     activ bar definition    */ 

                     /* return = FALSE in case of error  */  

{

  IGRlong     rc;                                /*  BS return code    */
  IGRint      i;


  BScveval(cur_bar->cv, cur_bar->cur_par_cv, 2, cur_bar->evalx, &rc); 
  if (BSERROR(rc))  goto wrapup; 

  /*  save last used base blend point  */
  for (i=0; i<3; i++)
    cur_bar->last_int[i] = cur_bar->evalx[0][i];

  /*  map curve blendpoint to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->evalx[0], cur_bar->evalx_rot);
  if (BSERROR(rc))  goto wrapup;
  cur_bar->evalx_rot[2] = 0.0;

  /*  map point back to world coordinates  */
  BSptnwtold( &rc, trans_vec, mat, &scale, cur_bar->evalx_rot, cur_bar->evalx_2d);
  if (BSERROR(rc))  goto wrapup; 

  /*  map curve blendp vector to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->evalx[1], cur_bar->evalxv_rot);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->evalxv_rot[2] = 0.0;

  /*  normalize tangent  */
  BSnorvec( &rc, cur_bar->evalxv_rot);
  if (BSERROR(rc))
  {
    if (rc < 0) 
    {
      /*  1st dervate could be wrong  / use 2nd*/
      for (i=0; i<3; i++)
        cur_bar->evalx[1][i] = cur_bar->evalx[2][i] * cur_bar->cur_dir * -1;

      /*  map curve blendp vector to mouse view  */
      BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->evalx[1], cur_bar->evalxv_rot);
      if (BSERROR(rc))  goto wrapup; 
      cur_bar->evalxv_rot[2] = 0.0;
      BSnorvec( &rc, cur_bar->evalxv_rot);
      if (BSERROR(rc))
      {
        cur_bar->evalxv_rot[0] = 0.7;     /* preset with any value  */
        cur_bar->evalxv_rot[1] = 0.7;     /* preset with any value  */
        cur_bar->evalx[1][0] = 0.7;     /* preset with any value  */
        cur_bar->evalx[1][1] = 0.7;     /* preset with any value  */
        cur_bar->evalx[1][2] = 0.7;     /* preset with any value  */
      }
    }
  }


  /*  setup current perpto direction  */
  cur_bar->offsetx[0] = (-cur_bar->evalxv_rot[1]);
  cur_bar->offsetx[1] =   cur_bar->evalxv_rot[0];
  cur_bar->offsetx[2] =   0.0;

  /*  setup 2d sensitive point  */ 
  cur_bar->int_pos_rot[0] = cur_bar->evalx_rot[0];
  cur_bar->int_pos_rot[1] = cur_bar->evalx_rot[1];

  /*  map vector back to world coordinates  */ 
  BSptnwtold( &rc, trans_vec, mat, &scale, cur_bar->evalxv_rot, cur_bar->evalxv_2d);
  if (BSERROR(rc))  goto wrapup; 

  /*  map vector back to world coordinates  */
  BSptnwtold( &rc, trans_vec, mat, &scale, cur_bar->offsetx, cur_bar->offsetx_2d);
  if (BSERROR(rc))  goto wrapup;

  /*  update position sign   (world coordinates for display) */
  for (i=0; i<3; i++)
  {
    cur_bar->pointi[i]    = cur_bar->evalx[0][i];
    cur_bar->p_sensi_int[i]  = cur_bar->pointi[i]  + offs_int_d*cur_bar->offsetx_2d[i];
    cur_bar->pointi[3+i]  = cur_bar->pointi[15+i] = cur_bar->p_sensi_int[i] - offs_int_s*cur_bar->offsetx_2d[i];
    cur_bar->pointi[6+i]  = cur_bar->p_sensi_int[i] + offs_int_s*cur_bar->evalxv_2d[i];
    cur_bar->pointi[9+i]  = cur_bar->p_sensi_int[i] + offs_int_s*cur_bar->offsetx_2d[i];
    cur_bar->pointi[12+i] = cur_bar->p_sensi_int[i] - offs_int_s*cur_bar->evalxv_2d[i];
  }

  /*  map vied dep curve blendpoint marker  to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->p_sensi_int, cur_bar->p_sensi_rot);
  if (BSERROR(rc))  goto wrapup;

  return(TRUE);


wrapup:
  return (FALSE);
}










/* ================================================ */
/*  this routine handles internal blendpoint moving  */
/* ================================================ */

IGRint BL_mov_iblend(
                     struct bar_data  *cur_bar,
                     IGRint           *new_display)
                                                  
/*                   parameter:                             */            
/*                   cur_bar         activ bar definition   */   
/*                   new_display     > 0 if update needed   */

                     /* return = FALSE in case of error  */

{

  IGRlong     rc;                                /*  BS return code    */
  IGRlong     sts;                               /*  OM return status  */
    
  IGRint      i;


  *new_display = 0;
  sts = BL_handle_bore_line(1, cur_bar, &cur_bar->wrk_par_cv);

  BScveval( cur_bar->cv, cur_bar->wrk_par_cv, 1, cur_bar->evalx, &rc);  
  if (BSERROR(rc))  goto wrapup; 

  /*  map curve blendpoint to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale,
              cur_bar->evalx[0], cur_bar->evalx_rot);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->evalx_rot[2] = 0.0;

  /*  map point back to world coordinates  */
  BSptnwtold( &rc, trans_vec, mat, &scale,
              cur_bar->evalx_rot, cur_bar->evalx_2d);
  if (BSERROR(rc))  goto wrapup; 

  /*  map curve blendp vector to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, 
              cur_bar->evalx[1], cur_bar->evalxv_rot);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->evalxv_rot[2] = 0.0;

  /*  normalize tangent  */
  BSnorvec( &rc, cur_bar->evalxv_rot);
  if (BSERROR(rc))  goto wrapup; 

  /*  setup current perpto direction  */
  cur_bar->offsetx[0] = (-cur_bar->evalxv_rot[1]);
  cur_bar->offsetx[1] =   cur_bar->evalxv_rot[0];
  cur_bar->offsetx[2] =   0.0; 

  /*  setup 2d sensitive point  */ 
  cur_bar->int_pos_rot[0] = cur_bar->evalx_rot[0] + cur_bar->offsetx[0];
  cur_bar->int_pos_rot[1] = cur_bar->evalx_rot[1] + cur_bar->offsetx[1];

  /*  map vector back to world coordinates  */ 
  BSptnwtold( &rc, trans_vec, mat, &scale,
              cur_bar->evalxv_rot, cur_bar->evalxv_2d);
  if (BSERROR(rc))  goto wrapup; 

  /*  map vector back to world coordinates  */
  BSptnwtold( &rc, trans_vec, mat, &scale,
             cur_bar->offsetx, cur_bar->offsetx_2d);
  if (BSERROR(rc))  goto wrapup; 

  /* get move_view coordinates sign for position compare  */
  for (i=0; i<3; i++)
  {
    cur_bar->p_sensi_int[i]   = cur_bar->evalx_rot[i]  + offs_int_d
                                                   *cur_bar->offsetx[i];
  }
  cur_bar->p_sensi_int[2] = 0;    
 
  cur_bar->cur_par_cv = cur_bar->wrk_par_cv;
  /*  update position sign   (world coordinates for display)  */
  for (i=0; i<3; i++)
  {
    cur_bar->pointi[i]    = cur_bar->evalx[0][i]; 
    cur_bar->p_sensi_int[i] = cur_bar->pointi[i]  + offs_int_d*cur_bar->offsetx_2d[i];
    cur_bar->pointi[3+i]  = cur_bar->pointi[15+i] = cur_bar->p_sensi_int[i] - offs_int_s*cur_bar->offsetx_2d[i];
    cur_bar->pointi[6+i]  = cur_bar->p_sensi_int[i] + offs_int_s*cur_bar->evalxv_2d[i];
    cur_bar->pointi[9+i]  = cur_bar->p_sensi_int[i] + offs_int_s*cur_bar->offsetx_2d[i];
    cur_bar->pointi[12+i] = cur_bar->p_sensi_int[i] - offs_int_s*cur_bar->evalxv_2d[i]; 

    /*  save last used base blend point  */
    cur_bar->last_int[i] = cur_bar->evalx[0][i];
  }

  /*  map vied dep curve blendpoint marker  to mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->p_sensi_int, cur_bar->p_sensi_rot);
  if (BSERROR(rc))  goto wrapup;

  /*  set update  */
  *new_display = 1;


  /*  evaluate start point and tangent for new curve position */
  BScveval( cur_bar->cv, cur_bar->cur_par_cv, 1, cur_bar->eval, &rc);
  if (BSERROR(rc))  goto wrapup; 

  /*  normalize tangent  */
  BSnorvec( &rc, cur_bar->eval[1]);
  if (BSERROR(rc))  goto wrapup; 

  /*  prepare bar line for modified basepoint */
  sts = BL_prep_view( cur_bar );     
  sts = BL_prep_basic_bar( cur_bar );

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

IGRint BL_calc_new_bar( struct bar_data  *cur_bar )   

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
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->proj_2d[2] = 0.0;

  /*  check for same direction as base vector  */
  cur_bar->cur_vector[0] = cur_bar->proj_2d[0] - cur_bar->eval_rot[0];
  cur_bar->cur_vector[1] = cur_bar->proj_2d[1] - cur_bar->eval_rot[1];
  cur_bar->cur_vector[2] = 0.0;

  cur_dot = BSdotp( &rc, cur_bar->bar_base_dir,cur_bar->cur_vector);
  if (BSERROR(rc))  goto wrapup; 

  /*  different direction handling if zooming on  */
  if (!cur_bar->zoom_activ)
  {
    cur_bar->cur_dir = 1;
    if (cur_dot < 0)  cur_bar->cur_dir = -1.0;
    if (cur_bar->cur_dir != cur_bar->last_dir)
    {
      cur_bar->last_dir = cur_bar->cur_dir;

      /*  toggle bar borders display  */
      for (i=0; i<3; i++)
      {
        cur_bar->pointsa[3+i] = cur_bar->pointsa[i] + 
            cur_bar->bar_length_cur * cur_bar->eval[1][i] * cur_bar->cur_dir;
        cur_bar->pointsb[3+i] = cur_bar->pointsa[3+i] - 2*cur_bar->offset[i];
      }
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
    /*  mark sensitiv end by point  */                             
    cur_bar->pointsc[i] = cur_bar->point_cur[i];
  }

  bar_dist = BSdistptpt( &rc, cur_bar->eval[0], cur_bar->point_cur);
  if (BSERROR(rc))  goto wrapup; 

  if (!cur_bar->zoom_activ)
  {
    cur_bar->bar_ratio = bar_dist*cur_bar->red_fakt / cur_bar->bar_length; 
  }
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
           /*  (cur_bar->fakt_dist_pos - FAK_MID*cur_bar->cur_dir)  */
           (cur_bar->fakt_dist_pos - cur_bar->fak_mid)
           * cur_bar->bar_length_cur * cur_bar->eval[1][i];
    }
    cur_bar->bar_ratio = cur_bar->base_bar_ratio + z_cur_dif * cur_bar->red_fakt;
    if (cur_bar->bar_ratio*cur_bar->last_ratio < 0)
    {
      cur_bar->cur_dir *= -1;
      cur_bar->last_dir = cur_bar->cur_dir;
      /*  toggle bar borders display  */
      for (i=0; i<3; i++)
      {
        cur_bar->pointsa[3+i] = cur_bar->pointsa[i] + 
            cur_bar->bar_length_cur * cur_bar->eval[1][i] * cur_bar->cur_dir;
        cur_bar->pointsb[3+i] = cur_bar->pointsa[3+i] - 2*cur_bar->offset[i];
      }
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

      cur_bar->pointsd[i]   = cur_bar->z_point_cur[i] - dark_offset
                              + cur_bar->z_offset[i];
      cur_bar->pointse[i]   = cur_bar->z_point_cur[i] + dark_offset 
                              + cur_bar->z_offset[i];

    }


    /*  save real direction for symmetric usage  */
    wrk_vector[0] = cur_bar->points[3] - cur_bar->points[0];
    wrk_vector[1] = cur_bar->points[4] - cur_bar->points[1];
    wrk_vector[2] = cur_bar->points[5] - cur_bar->points[2];

    cur_dot = BSdotp( &rc, cur_bar->eval[1], wrk_vector);

    if (cur_dot < 0)  cur_bar->sym_dir = -1.0;
    else              cur_bar->sym_dir =  1.0;

  }
 

  /*  update current rot checkpoint  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, cur_bar->point_cur,
              cur_bar->point_cur_rot);
  if (BSERROR(rc))  goto wrapup; 
  cur_bar->point_cur_rot[2] = 0.0;       /*  force 2D handling  */
   

  return(TRUE);


wrapup:
  return (FALSE);
}











/* ============================================================= */
/*  this routine initializes dynamics data for one base element  */
/* ============================================================= */

IGRint BL_startup(
                  struct bar_data  *cur_bar)    /*  bar data array  */

                  /* return = FALSE in case of error  */

{

  IGRlong     loc_msg;
  IGRlong     rc;                                /*  BS return code    */
  IGRlong     sts;                               /*  OM return status  */
  IGRshort    i;                                 /*  loop counter  */
  IGRdouble   dist;                              /*  vector length  */
  IGRlong    num_bytes;                          /*  used for allocation */
  /*  calculate dependent values  */

  cur_bar->last_dir = cur_bar->base_dir = cur_bar->cur_dir;
  cur_bar->zoom_activ      = cur_bar->cur_sensi < (1.0 - eps);
  cur_bar->base_bar_ratio  = cur_bar->bar_ratio;
  cur_bar->last_ratio      = cur_bar->bar_ratio;
  cur_bar->red_fakt        = cur_bar->bar_ratio + 1.5;

  if (cur_bar->zoom_activ)
  { 
    cur_bar->fakt_dist_pos = FAK_MID;                     /* start is middle */
    cur_bar->fak_mid =  FAK_MID*cur_bar->cur_dir;
    cur_bar->fakt_zoom_pos = cur_bar->base_bar_ratio / cur_bar->red_fakt;  /* start is ratio  */
  }
  else
  {
    cur_bar->fakt_dist_pos = cur_bar->base_bar_ratio / cur_bar->red_fakt;  /* start is ratio  */
    cur_bar->fakt_zoom_pos = 1.0;                    /* unused  */
  }
  cur_bar->fakt_dist_pos *= cur_bar->cur_dir;        /*  regard direction  */

  cur_bar->z_rel_bar_point = cur_bar->fakt_zoom_pos;

  cur_bar->int_pos_rot[2] = 0.0;

  /*  get basic element data  */
  sts = om$send(mode = OM_e_wrt_object,
                msg  = message GRvg.GRgetsize(&loc_msg,
                                              &cur_bar->cv_envinf.matrix_type, 
			                      cur_bar->cv_envinf.matrix,
                                              &num_bytes ),
                senderid = NULL,
                targetid = cur_bar->cv_grid.objid,
                targetos = cur_bar->cv_grid.osnum);
  if (!(1&sts&loc_msg))  goto wrapup;

  cur_bar->cv = (struct IGRbsp_curve *) malloc(num_bytes);
  if (!cur_bar->cv)  goto wrapup;

  sts = om$send(mode = OM_e_wrt_object,
                msg  = message GRvg.GRgetgeom(&loc_msg,
                                              &cur_bar->cv_envinf.matrix_type, 
			                      cur_bar->cv_envinf.matrix,
                                              (IGRchar *)cur_bar->cv),
                senderid = NULL,
                targetid = cur_bar->cv_grid.objid,
                targetos = cur_bar->cv_grid.osnum);
  if (!(1&sts&loc_msg))  goto wrapup;

  /*  evaluate start point and tangent  */
  BScveval( cur_bar->cv, cur_bar->cur_par_cv, 1, cur_bar->eval, &rc);
  if (BSERROR(rc))  goto wrapup; 

  dist = BSlenvec(&rc, cur_bar->eval[1]);
  if (dist <= tolarr[2])
  {
    /*  1st dervate could be wrong  */
    BScveval( cur_bar->cv, cur_bar->cur_par_cv, 2, cur_bar->eval, &rc);
    if (BSERROR(rc))  goto wrapup; 
    for (i=0; i<2; i++)
    {
      cur_bar->eval[1][i] = cur_bar->eval[2][i] * cur_bar->cur_dir * -1;
     }
    BSnorvec( &rc, cur_bar->eval[1]);
    if (BSERROR(rc))
    {
      cur_bar->eval[1][0] = 1.0;
    }
  }
  /*  normalize tangent  */
  BSnorvec( &rc, cur_bar->eval[1]);
  if (BSERROR(rc))
  {
    goto wrapup; 
  }
  return(TRUE);


wrapup:
  return (FALSE);
}








/* ===================================== */
/*  this routine prepares bar line data  */
/* ===================================== */

IGRint BL_init_side(
                     struct bar_data  *cur_bar)
                                                  
/*                   parameter:                             */            
/*                   cur_bar         activ bar definition   */   

                     /* return = FALSE in case of error  */

{

  IGRlong     rc;                                /*  BS return code    */
  IGRlong     sts;                               /*  OM return status  */


  if (cur_bar == &bar1_data) 
  {
    /*  recalculate current 2d blendpoint distance  (only at first bar ) */
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
  }

  /*  prepare bar data  */
  sts = BL_prep_view(cur_bar);  
  if (!sts)  goto wrapup;   

  sts = BL_prep_basic_bar(cur_bar);
  if (!sts)  goto wrapup;   

  if (cur_bar->zoom_activ)
    { sts = BL_prep_zoom(cur_bar);  if (!sts)  goto wrapup;  }

  if (cur_bar->int_blend_activ)
    { sts = BL_prep_iblend(cur_bar);  if (!sts)  goto wrapup;  }



  return(TRUE);


wrapup:
  return (FALSE);
}










/* ======================================================== */
/*   this routine builds a curvature hedgehog for display   */
/* ======================================================== */

IGRint BL_hedgehog(

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
  IGRint      bound, ev_bound, ND; 
  IGRdouble   max, rmin;
  IGRdouble   par0;
  IGRdouble   mx=0, my=0, mz=0;
  IGRdouble   d_l[9], d_r[9];
  IGRdouble   tmp_a, tmp_b; 
  IGRdouble   fakt, fakt_rho;


  
  n =  nr_pnt_blend / 2;            /*  number of prickles for blend_curve  */
  ND = 2;
  rmin = 0.01*max_length;

  /*  first loop to calculate the normal vectors, curvature (+max.)  */
  max = 0;

  for ( j=0; j<n; j++ )
  {
    par0 = (double)(j)/(double)(n-1);

    BScveval_b( &rc, cv_blend, &par0, &ND, &ev_bound, &bound,
                &d_l[0], &d_r[0]);
    if (BSERROR(rc))  goto wrapup; 

    mx = d_l[3]*d_l[3]+d_l[4]*d_l[4]+d_l[5]*d_l[5];
    my = d_l[6]*d_l[6]+d_l[7]*d_l[7]+d_l[8]*d_l[8];
    mz = d_l[3]*d_l[6]+d_l[4]*d_l[7]+d_l[5]*d_l[8]; 

    tmp_a = mx*mx*mx;
    tmp_b = mx*my - mz*mz;
    if ( mx<1e-8 )
    {
     /*...printf("hedgehog-error 1e8\n");  */
     goto wrapup;
    }

    rho[j] = sqrt( ABS(tmp_b)/tmp_a );
    if (rho[j] < rmin)  rho[j] = rmin;    /*  avoid zero length line display  */
    if (max < rho[j])  max = rho[j];      /*  set max curvature  */

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
 
  /*  second loop to produce normal lines with curvatrue length  */
  /*  in dynamic display buffer                                  */
  fakt = max_length/max;

  for ( j=0; j<n; j++ )
  {
    *polyline_bl = p_x[j];                         /*  base_point  */
    polyline_bl++;
    *polyline_bl = p_y[j];
    polyline_bl++;
    *polyline_bl = p_z[j];
    polyline_bl++;

    fakt_rho = fakt*rho[j] / sqrt(nx[j]*nx[j]+ny[j]*ny[j]+nz[j]*nz[j]);
    *polyline_bl = p_x[j] + fakt_rho*nx[j];     /*  normal end point  */
    polyline_bl++;
    *polyline_bl = p_y[j] + fakt_rho*ny[j];
    polyline_bl++;
    *polyline_bl = p_z[j] + fakt_rho*nz[j];
    polyline_bl++;


   }

  return (TRUE);


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
    IGRint Blend_dyn_bar(
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
   IGRlong      loc_msg;
   IGRlong      rc;                      /*  BS return code    */
   IGRlong      sts;                     /*  OM return status  */
   IGRpoint     mouse;
   IGRdouble   dummy;

   IGRdouble rot_matrix[16];
   IGRdouble mat_wtv[16];                    /*  world to view matrix  */

   IGRint       dyn_update1, dyn_update2;    /*  > 0 if dynamic update needed  */
   IGRint       i, k, j;                     /*  loop index  */

static IGRdouble knots1[4] = { 0.0, 0.0, 1.0, 1.0 }; /* bore_line data */



  if (first_run)
  {
    /*  set no more first run  */
    first_run = FALSE;
    last_activ_bar = 0;
    last_w_window = -1;

    last_dis_bar1_ratio =    
    last_dis_bar2_ratio = GRDGNLIMITS_MAX_D;
 
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

    /*  setup boreline vector  */
    bore_vect[0] = mat[2][0];
    bore_vect[1] = mat[2][1];
    bore_vect[2] = mat[2][2];

    epsw = 0.001;
    /*  calculate work view zoom faktor  */
    if   (ABS(rot_matrix[0]) > epsw)  disp_fakt = mat_wtv[0] / rot_matrix[0];
    else
      if (ABS(rot_matrix[1]) > epsw)  disp_fakt = mat_wtv[1] / rot_matrix[1];
      else                            disp_fakt = mat_wtv[2] / rot_matrix[2];

    disp_fakt  = WITH_FAKT / disp_fakt; 
    offs_int_d = FAK_INT_D * disp_fakt; 
    offs_int_s = FAK_INT_S * disp_fakt;  
    fak_marker = 0.35 * FAKQ * disp_fakt;      /*  sensitiv barpoint marker length */

    /*  set bore_line fix values  */
    bore_line.planar = 1;
    bore_line.num_knots = 4;
    bore_line.knots = knots1;
    bore_line.num_poles = 2;
    bore_line.poles = poles1;
    bore_line.order = 2;

    /*  prepare bar view data  */
    sts = BL_init_side(&bar1_data);
    if (!sts)  goto wrapup;
    sts = BL_init_side(&bar2_data);
    if (!sts)  goto wrapup;

    /*  prepare boreline data for new view  */ 
    if (last_wrk_sel == WRK_INT_BLND1) sts = BL_handle_bore_line(0, &bar1_data, &dummy);
    if (last_wrk_sel == WRK_INT_BLND2) sts = BL_handle_bore_line(0, &bar2_data, &dummy);
  }
  /*  end window change  */


  /****************************/
  /*  interpret mouse change  */
  /****************************/
    

  mouse[0] = point->x;
  mouse[1] = point->y;
  mouse[2] = point->z;

  /*  map mousepoint to new mouse view  */
  BSptoldtnw( &rc, trans_vec, mat, &scale, mouse, mouse_rot);
  if (BSERROR(rc))  goto wrapup; 

  mouse_rot_2d[0] = mouse_rot[0];
  mouse_rot_2d[1] = mouse_rot[1];
  mouse_rot_2d[2] = 0.0;


  dyn_update1 = dyn_update2 = 0;

  switch (last_wrk_sel)
  {


    case WRK_TANG1: 
    {
      sts =  BL_calc_new_bar( &bar1_data );
      dyn_update1 = 1;
      if (!sts)  goto wrapup;
      if (symmetric)
      {
        bar2_data.bar_ratio = bar1_data.bar_ratio;  /* force same ratio     */
        bar2_data.cur_dir   = bar1_data.cur_dir * cor_sym_dir;    /* force same direction */ 
        if (!bar1_data.zoom_activ || !bar2_data.zoom_activ)
          sts = BL_init_side(&bar2_data);     /* force same display   */
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
      sts =  BL_calc_new_bar( &bar2_data );
      if (!sts)  goto wrapup; 
      if (symmetric)
      {
        bar1_data.bar_ratio = bar2_data.bar_ratio;  /* force same ratio     */
        bar1_data.cur_dir   = bar2_data.cur_dir * cor_sym_dir;    /* force same direction */ 
        if (!bar1_data.zoom_activ || !bar2_data.zoom_activ)
          sts = BL_init_side(&bar1_data);     /* force same display   */
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
      dyn_update2 = 1;
      break;
    }



    case WRK_INT_BLND1:
    {
      sts = BL_mov_iblend( &bar1_data, &dyn_update1);
      if (!sts)  goto wrapup;    
      if (dyn_update1 > 0)
      {
        start_cond.blend_pt_par = bar1_data.cur_par_cv;
        if (bar1_data.zoom_activ)
        {
          sts = BL_prep_zoom( &bar1_data );
          if (!sts)  goto wrapup;
        }   
      }
      break;  
    }
   

    case WRK_INT_BLND2:
    {
      sts = BL_mov_iblend( &bar2_data, &dyn_update2); 
      if (!sts)  goto wrapup;   
      if (dyn_update2 > 0)
      {
        end_cond.blend_pt_par = bar2_data.cur_par_cv; 
        if (bar2_data.zoom_activ)
        {
          sts = BL_prep_zoom( &bar2_data );
          if (!sts)  goto wrapup;  
        }   
      }
      break;
    }

  default:
    break;

  }    /*  end of switch  */


  if (circcrv)
  {  
    /*  update circle display  */ 
    IGRvector unit_plane_normal = { 0.0, 0.0, 1.0 };   /*  plane normal */
    IGRint    type;

    type = 1;

    /*  prepare basic circle  */
    sts = BSprepcirc(&rc, mouse, &radius, bore_vect, circcrv, unit_plane_normal,
                     &type);
   
    for (i=0; i<3; i++)
    {
       pointscir1[i]   = mouse[i] - radius*cir_vec[i];
       pointscir1[i+3] = mouse[i] + radius*cir_vec[i];
       pointscir2[i]   = mouse[i] - radius*cir_vecn[i];
       pointscir2[i+3] = mouse[i] + radius*cir_vecn[i];
    }
  }



  /*-------------------------*/
  /*  call the math routine  */
  /*-------------------------*/
  start_cond.tangent_value = ABS(bar1_data.bar_ratio);
  start_cond.direction     = bar1_data.cur_dir;
  end_cond.tangent_value   = ABS(bar2_data.bar_ratio);
  end_cond.direction       = bar2_data.cur_dir;

  blend_pt_par[0]  = start_cond.blend_pt_par;
  blend_pt_par[1]  = end_cond.blend_pt_par;
  direction[0]     = start_cond.direction; 
  direction[1]     = end_cond.direction;
  tangent_flag[0]  = start_cond.tangent_flag;
  tangent_flag[1]  = end_cond.tangent_flag;
  tangent_value[0] = start_cond.tangent_value;
  tangent_value[1] = end_cond.tangent_value;
  curvature[0]     = start_cond.curvature;
  curvature[1]     = end_cond.curvature;

  BSblndcrvg2 (bar1_data.cv,
               bar2_data.cv,
               blend_pt_par,
               direction,
               tangent_flag,
               tangent_value,
               curvature,
               tolarr,
               blndcrv,
               &info,
               &rc);

  if (info == -8)  goto wrapup; 

  /*  update of poles display  */
  if (toggle_poly)
  {
    for (i=0; i<n_disp_poles; i++)
    {
      for (k=0; k<3; k++)               
        poles_pnt[i][k] = blndcrv->poles[3*i+k];
    }
  }

  /*  check for online curvature diagnostics  */
  if (cv_diagnos)             
  {
    max_length = dist_bar1_bar2 / 4.0;
    sts =  BL_hedgehog(blndcrv, max_length, num_pnt_blend, &pointhh[0]);
    if (!sts)  goto wrapup;   
  }


  /*  we are drawing NUM_DYN graphic object */
  *num_buffers = ind_arr;           
  *buffers = DY1info; 
  return(TRUE);


wrapup:
  return(FALSE);

}













/* ====================================================== */
/*  this routine creates the storage for the buffers...   */
/* ====================================================== */

IGRint ECblendcv_d(IGRint          task,             /* type of blend input */
                   IGRint          bar_control,      /* bar display control */
                   IGRint          *status,          /* termination status  */

                   IGRint          *response,
                   IGRchar         *response_data,

                   struct GRmd_env *env1,
                   struct GRid     cv1_grid,

                   IGRint          cont1,
                   IGRint          tangent_flag1,
                   IGRdouble       *ratio1,
                   IGRdouble       *par_cv1,
                   IGRint          *dir_cv1,
                   IGRboolean      int_cv1,
                   IGRdouble       sensi_fakt1,


                   struct GRmd_env *env2,
		   struct GRid     cv2_grid,
                   IGRint          cont2,
                   IGRint          tangent_flag2,
                   IGRdouble       *ratio2,
                   IGRdouble       *par_cv2,
                   IGRint          *dir_cv2,
                   IGRboolean      int_cv2,
                   IGRdouble       sensi_fakt2,

                   IGRboolean      diagnos,      /*  1= hedgehog, 2= polygon */
                   IGRint          blnd_order,
                   IGRdouble       min_rad,
                   IGRdouble       *rot_mat,
                   IGRdouble       *disp_fakt_init)


{

  IGRlong         loc_msg;
  IGRlong         rc;                      /*  BS return code    */
  IGRlong         sts;                     /*  OM return status  */

  IGRlong         blnd_num_poles;
  IGRshort        blnd_rat;
  IGRshort        blnd_num_bound;
  IGRint          i, j, k, ii;             /*  loop index  */
  IGRlong         size;  
  IGRdouble       *w_rot_mat;            /*  work pointer matrix  */   
  
  struct IGResbc  bc_attr;                 /* B-spline element specific attrib. */  

  IGRint          event_mask;
  struct GRevent  param_event;

  /********************/
  /*  Initialisation  */
  /********************/

  cur_task = task;                            /*  save task parameter     */
  *status = 0;                                /*  preset with error  */

  if (bar_control != 0)  leader_line = FALSE; 
  else                   leader_line = TRUE;

  radius = min_rad;
  sts = OM_S_SUCCESS;
  bar1_data.cv = 
  bar2_data.cv = NULL;
  cv1 =
  cv2 = NULL;
  cvw = NULL;
  blndcrv = NULL;

  /*  hedgehog buffers  */
  nx  =
  ny  =
  nz  =
  rho =
  p_x =
  p_y =
  p_z = NULL;

  /*  mark first step  */
  first_run = TRUE;
  disp_fakt = WITH_FAKT / *disp_fakt_init;   /*  preset with faktor from locate  */
  fak_marker = 0.35 * FAKQ * disp_fakt;      /*  sensitiv barpoint marker length */


  /*  get System Tolerances  */
  BSEXTRACTPAR (&rc,BSTOLBASIS,tolarr[0]); 
  if (BSERROR(rc))  goto wrapup; 
  /*  set general eps value  */
  eps = tolarr[0];
  BSEXTRACTPAR (&rc,BSTOLCOLLINVEC,tolarr[1]); 
  BSEXTRACTPAR (&rc,BSTOLLENVEC,tolarr[2]); 


  /*  set basic matrix/vector  */
  scale = 1.0;

  for (i=0; i<3; i++)
    trans_vec[i] = 0.0;          /*  translate vector = none */  

  w_rot_mat = rot_mat;
  for (i=0; i<3; i++)
  {
    for (j=0; j<3; j++)
     mat[i][j] = *w_rot_mat++;
  }

  /*  preset calculate work view zoom faktor  */
  offs_int_d = FAK_INT_D * disp_fakt; 
  offs_int_s = FAK_INT_S * disp_fakt;  
  fak_marker = 0.35 * FAKQ * disp_fakt;  /* sensitiv barpoint marker length */

  /*---  startup element 1  ---*/

  /*  preset bar1 array with basic parameters  */
  bar1_data.cur_dir         = *dir_cv1;
  bar1_data.bar_ratio       = ABS(*ratio1);
  bar1_data.cur_sensi       = sensi_fakt1;
  bar1_data.cur_par_cv      = *par_cv1;
  bar1_data.int_blend_activ = int_cv1;
  bar1_data.cv_grid         = cv1_grid;
  bar1_data.cv_envinf       = env1->md_env;

  bar1_data.cv = NULL;
  sts = BL_startup( &bar1_data);
  if (!sts)  goto wrapup;

  /*---  startup element 2  ---*/

  /*  preset bar2 array with basic parameters  */
  bar2_data.cur_dir         = *dir_cv2;
  bar2_data.bar_ratio       = ABS(*ratio2);
  bar2_data.cur_sensi       = sensi_fakt2;
  bar2_data.cur_par_cv      = *par_cv2;
  bar2_data.int_blend_activ = int_cv2;
  bar2_data.cv_grid         = cv2_grid;
  bar2_data.cv_envinf       = env2->md_env;

  bar2_data.cv = NULL;
  sts = BL_startup( &bar2_data);
  if (!sts)  goto wrapup;

  /*  extract curvature diagnostic, toggle polygon and symmetric switch  */
  cv_diagnos  = 1&diagnos;
  toggle_poly = 2&diagnos;
  symmetric   = 4&diagnos;


  if (symmetric)
  {
    cor_sym_dir = bar1_data.cur_dir * bar2_data.cur_dir;
  }

  /*  allocate memory for the blend curve    */
  /*  use buffer for with curvature on if needed  */

  blnd_order     = 
  blnd_num_poles = cont1 + cont2 + 2;
  blnd_rat = TRUE;                                /*  for arcs, ...  */
  blnd_num_bound = 0;
  BSalloccv (blnd_order, blnd_num_poles, blnd_rat, blnd_num_bound,
             &blndcrv, &rc );
  if ( rc != BSSUCC )  goto wrapup;


  /*  call the math routine  */

  start_cond.curve = bar1_data.cv;
  start_cond.tangent_flag = tangent_flag1;
  start_cond.tangent_value = ABS(bar1_data.bar_ratio);
  start_cond.blend_pt_par = *par_cv1;
  start_cond.direction = *dir_cv1;
  start_cond.curvature = cont1 - 1 ;

  end_cond.curve = bar2_data.cv;
  end_cond.tangent_flag = tangent_flag2;
  end_cond.tangent_value = ABS(bar2_data.bar_ratio);
  end_cond.blend_pt_par = *par_cv2;
  end_cond.direction = *dir_cv2;
  end_cond.curvature = cont2 - 1;

  blend_pt_par[0]  = start_cond.blend_pt_par;
  blend_pt_par[1]  = end_cond.blend_pt_par;
  direction[0]     = start_cond.direction; 
  direction[1]     = end_cond.direction;
  tangent_flag[0]  = start_cond.tangent_flag;
  tangent_flag[1]  = end_cond.tangent_flag;
  tangent_value[0] = start_cond.tangent_value;
  tangent_value[1] = end_cond.tangent_value;
  curvature[0]     = start_cond.curvature;
  curvature[1]     = end_cond.curvature;

  BSblndcrvg2 (bar1_data.cv,
               bar2_data.cv,
               blend_pt_par,
               direction,
               tangent_flag,
               tangent_value,
               curvature,
               tolarr,
               blndcrv,
               &info,
               &rc);

  if (info == -8)  goto wrapup; 

  /* reset default mode */
  start_cond.tangent_flag = ABS(start_cond.tangent_flag);
  end_cond.tangent_flag   = ABS(end_cond.tangent_flag);

  /*  preset blend curve buffer           */
  /*  bs curve needs element attributes!  */
  bc_attr.is_curvedis = TRUE;
  n_disp_poles = MIN(MAX_POLES, blndcrv->num_poles);
  bc_attr.is_polydis  = toggle_poly;         /*  TRUE for polygon display  */

  dist_bar1_bar2 = BSdistptpt( &rc, bar1_data.eval[0], bar2_data.eval[0]); 
  if (rc != BSSUCC)  goto wrapup; 
  bar1_data.bar_length = bar1_data.dyn_bar_length = dist_bar1_bar2;
  bar2_data.bar_length = bar2_data.dyn_bar_length = dist_bar1_bar2;

  /*  prepare first line  */
  sts = BL_prep_view( &bar1_data);
  if (!sts)  goto wrapup;
  sts = BL_prep_basic_bar( &bar1_data);
  if (!sts)  goto wrapup;
  if (bar1_data.zoom_activ) 
  {
    sts = BL_prep_zoom( &bar1_data );
    if (!sts)  goto wrapup;
  }

  if (bar1_data.int_blend_activ)
  {
    sts = BL_prep_iblend( &bar1_data );
    if (!sts)  goto wrapup;
  }

  /*  prepare second line  */
  sts = BL_prep_view( &bar2_data);
  if (!sts)  goto wrapup;  
  sts = BL_prep_basic_bar( &bar2_data);
  if (!sts)  goto wrapup;

  if (bar2_data.zoom_activ)
  {
    sts = BL_prep_zoom( &bar2_data );
    if (!sts)  goto wrapup;
  }
  if (bar2_data.int_blend_activ)
  {
    sts = BL_prep_iblend( &bar2_data ); 
    if (!sts)  goto wrapup;
  }

  /*  check for online curvature diagnostics  */
  if (cv_diagnos)             
  {
    /*  hedgehog construction  */
    lineh.num_points = NUM_HH_POINTS - 1;
    num_pnt_blend    = NUM_HH_POINTS;
    max_length = dist_bar1_bar2 / 4.0;

    siz   = num_pnt_blend*sizeof(IGRdouble);
    rho = (IGRdouble *) om$malloc ( size = siz );    /*  normal length */
    nx  = (IGRdouble *) om$malloc ( size = siz );    /*  normals vectors */
    ny  = (IGRdouble *) om$malloc ( size = siz ); 
    nz  = (IGRdouble *) om$malloc ( size = siz );
    p_x = (IGRdouble *) om$malloc ( size = siz );    /*  base_points */ 
    p_y = (IGRdouble *) om$malloc ( size = siz ); 
    p_z = (IGRdouble *) om$malloc ( size = siz ); 
 
    sts =  BL_hedgehog(blndcrv, max_length, num_pnt_blend, &pointhh[0]);
    if (!sts)  goto wrapup;   
  }

  if (task == 2)
  {  
    /*  alloc space for circle display  */ 

    IGRpoint  center;
    IGRvector normal;
    IGRvector unit_plane_normal;
    IGRint    type;

    EFget_curve_buffer(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, TRUE, 0, &circcrv);
    /*  preset with some value  */
        center[0] = center[1] = center[2] = 0.0;  /*... later  test  !!! */
        normal[0] = 0; normal[1] = 0; normal[2] = 1.0;
        unit_plane_normal[0] = 0; unit_plane_normal[1] = 0; unit_plane_normal[2] = 1.0; 
        type = 1;

    /*  prepare basic circle  */
    sts = BSprepcirc(&rc, center, &radius, normal, circcrv, unit_plane_normal,
                     &type);
    if (rc != BSSUCC)  goto wrapup; 

    /*  preset circle with dummy  */
    for (i=0; i<3; i++)
    {
      pointscir1[i]   = bar1_data.eval[0][i] - radius*bar1_data.offset[i];
      pointscir1[i+3] = bar1_data.eval[0][i] + radius*bar1_data.offset[i];
      pointscir2[i]   = bar1_data.eval[0][i] - radius*bar1_data.eval[1][i];
      pointscir2[i+3] = bar1_data.eval[0][i] + radius*bar1_data.eval[1][i];
    }
    for (i=0; i<3; i++)
    {
      cir_vec[i]  = bar1_data.offset[i];
      cir_vecn[i] = bar1_data.eval[1][i];
    }
  }






  /* ------------------------------------------ */
  /* ---  initialize bar1/2 display buffers --- */
  /* ------------------------------------------ */

  bar1_data.line.points = bar1_data.points;
  bar1_data.line.num_points = 2;

  bar1_data.linea.points = bar1_data.pointsa;
  bar1_data.linea.num_points = 2;

  bar1_data.lineb.points = bar1_data.pointsb;
  bar1_data.lineb.num_points = 2;

  bar1_data.pntsc.points = bar1_data.pointsc;
  bar1_data.pntsc.num_points = 1;

  bar1_data.lined.points = bar1_data.pointsd;
  bar1_data.lined.num_points = 2;

  bar1_data.linee.points = bar1_data.pointse;
  bar1_data.linee.num_points = 2;

  bar1_data.linef.points = bar1_data.pointsf;
  bar1_data.linef.num_points = 2;

  bar1_data.lineg.points = bar1_data.pointsg;
  bar1_data.lineg.num_points = 2;

  bar1_data.linei.points = bar1_data.pointi;
  bar1_data.linei.num_points = 6;


  bar2_data.line.points = bar2_data.points;
  bar2_data.line.num_points = 2;

  bar2_data.linea.points = bar2_data.pointsa;
  bar2_data.linea.num_points = 2;

  bar2_data.lineb.points = bar2_data.pointsb;
  bar2_data.lineb.num_points = 2;

  bar2_data.pntsc.points = bar2_data.pointsc;
  bar2_data.pntsc.num_points = 1;

  bar2_data.lined.points = bar2_data.pointsd;
  bar2_data.lined.num_points = 2;

  bar2_data.linee.points = bar2_data.pointse;
  bar2_data.linee.num_points = 2;

  bar2_data.linef.points = bar2_data.pointsf;
  bar2_data.linef.num_points = 2;

  bar2_data.lineg.points = bar2_data.pointsg;
  bar2_data.lineg.num_points = 2;


  bar2_data.linei.points = bar2_data.pointi;
  bar2_data.linei.num_points = 6;

  /*  hedgehog */
  lineh.points = pointhh;

  /*  circle centerlines  */
  linecir1.points = pointscir1;
  linecir1.num_points = 2;

  linecir2.points = pointscir2;
  linecir2.num_points = 2;


  /*  get default display symbology from Default Parameter Block (DPB)  */
  sts = gr$get_active_display(buffer = &fix_bar_display);
  dyn_bar_display    = 
  dot_bar_display    =
  pnt1_bar_display   = 
  pnt2_bar_display   = 
  pnt_poles_display  = 
  zoom_bar_display_f =
  zoom_bar_display_d = 
  int1_bar_display   = 
  int2_bar_display   = 
  hedgehog_display   = 
  circ_display       = fix_bar_display;

  dyn_bar_display.weight    = 2;
  if (leader_line)     dyn_bar_display.style = 0;
  else                 dyn_bar_display.style = 5;

  dot_bar_display.weight    = 10;
  zoom_bar_display_f.weight = 2;
  zoom_bar_display_d.weight = 6;
  hedgehog_display.weight   = 0;
  pnt1_bar_display.weight   = P_WEIGHT_MIN;
  pnt2_bar_display.weight   = P_WEIGHT_MIN; 
  int1_bar_display.weight   = L_WEIGHT_MIN; 
  int2_bar_display.weight   = L_WEIGHT_MIN; 
  pnt_poles_display.weight  = P_WEIGHT_POL;

  circ_display.style        = 1;

  ind_arr = 0;
  /*  must be first buffer  */                 
  dp$build_dis_buffer(buffer       = &display_elements[ind_arr],
                                 /*  &display_elements[ind_arr++] = error */
                      display_att  = &fix_bar_display,
                      ele_spec_att = &bc_attr,
                      geometry     = blndcrv,
                      type         = IGRBC);
  ind_arr++;                                        /* ---1--- */

  /*  current bar1 ratio display  */
  /*  buffer index = INDX1 used in DY1info[ ]  */
  dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                      display_att = &dyn_bar_display,
                      geometry    = &bar1_data.line,
                      type        = IGRPY);
  ind_arr++;                                        /* ---2--- */

  /*  current bar2 ratio display  */
  /*  buffer index = INDX2 used in DY1info[ ]  */
  dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                      display_att = &dyn_bar_display,
                      geometry    = &bar2_data.line,
                      type        = IGRPY);
  ind_arr++;                                        /* ---3--- */

  /*  bar1 sensitiv position marker  (point) */
  dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                      display_att = &pnt1_bar_display,
                      geometry    = &bar1_data.pntsc,
                      type        = IGRPS);
  ind_arr++;                                        /* ---4--- */

  /*  bar2 sensitiv position marker  (point) */
  dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                      display_att = &pnt2_bar_display,
                      geometry    = &bar2_data.pntsc,
                      type        = IGRPS);
   ind_arr++;                                        /* ---5--- */
 


  if (leader_line)
  {
    /*  bar1 activ length marker left side  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &fix_bar_display,
                        geometry    = &bar1_data.linea,
                        type        = IGRPY);
    ind_arr++;                                        /* ---6--- */

    /*  bar1 activ length marker right side  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &fix_bar_display,
                        geometry    = &bar1_data.lineb,
                        type        = IGRPY);
    ind_arr++;                                        /* ---7--- */

    /*  bar2 activ length marker left side  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &fix_bar_display,
                        geometry    = &bar2_data.linea,
                        type        = IGRPY);
    ind_arr++;                                        /* ---8--- */

    /*  bar2 activ length marker right side  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &fix_bar_display,
                        geometry    = &bar2_data.lineb,
                        type        = IGRPY);
    ind_arr++;                                        /* ---9--- */

    /*  zoom bars display  ( only if zoom mode on)  */  

    if (bar1_data.zoom_activ)   
    {
      /*  bar1 activ zoom extension marker left/lower */
      dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                          display_att = &zoom_bar_display_d,
                          geometry    = &bar1_data.lined,
                          type        = IGRPY);
      ind_arr++;                                        /* ---10--- */

      /*  bar1 activ zoom extension marker left/upper */
      dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                          display_att = &zoom_bar_display_d,
                          geometry    = &bar1_data.linee,
                          type        = IGRPY);
      ind_arr++;                                        /* ---11--- */

      /*  bar1 activ zoom extension marker right/lower */
      dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                          display_att = &zoom_bar_display_f,
                          geometry    = &bar1_data.linef,
                          type        = IGRPY);
      ind_arr++;                                        /* ---12--- */

      /*  bar1 activ zoom extension marker right/upper */
      dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                          display_att = &zoom_bar_display_f,
                          geometry    = &bar1_data.lineg,
                          type        = IGRPY);
      ind_arr++;                                        /* ---13--- */
    }

    if (bar2_data.zoom_activ)   
    {
      /*  bar2 activ zoom extension marker left/lower */
      dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                          display_att = &zoom_bar_display_d,
                          geometry    = &bar2_data.lined,
                          type        = IGRPY);
      ind_arr++;                                        /* ---14--- */

      /*  bar2 activ zoom extension marker left/upper */
      dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                          display_att = &zoom_bar_display_d,
                          geometry    = &bar2_data.linee,
                          type        = IGRPY);
      ind_arr++;                                        /* ---15--- */

      /*  bar2 activ zoom extension marker right/lower */
      dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                          display_att = &zoom_bar_display_f,
                          geometry    = &bar2_data.linef,
                          type        = IGRPY);
      ind_arr++;                                        /* ---16--- */

      /*  bar2 activ zoom extension marker right/upper */
      dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                          display_att = &zoom_bar_display_f,
                          geometry    = &bar2_data.lineg,
                          type        = IGRPY);
      ind_arr++;                                        /* ---17--- */

    }
  }            /*  end of leader_line  */

  if (bar1_data.int_blend_activ) 
  {
    /*  internal blend-1 pos selector */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &int1_bar_display,
                        geometry    = &bar1_data.linei,
                        type        = IGRPY);
    ind_arr++;                                        /* ---18--- */

  }

  if (bar2_data.int_blend_activ)  
  {
    /*  internal blend-2 pos selector */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &int2_bar_display,
                        geometry    = &bar2_data.linei,
                        type        = IGRPY);
    ind_arr++;                                        /* ---19--- */

  }


  /*  check for online curvature diagnostics  */
  if (cv_diagnos)  
  {
    /*  display radius hedgehog  */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &hedgehog_display,
                        geometry    = &lineh,
                        type        = IGRPY);
    ind_arr++;                                        /* ---20--- */
  }

  /*  for circle mode  */
  if (task == 2)
  {                
    dp$build_dis_buffer(buffer       = &display_elements[ind_arr],
                        display_att  = &circ_display,
                        ele_spec_att = &bc_attr,
                        geometry     = circcrv,
                        type         = IGRBC);
    ind_arr++;                                        /* ---21--- */

    /*  internal blend-1 pos selector */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &circ_display,
                        geometry    = &linecir1,
                        type        = IGRPY);
    ind_arr++;                                        /* ---22--- */

    /*  internal blend-1 pos selector */
    dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                        display_att = &pnt1_bar_display,
                        geometry    = &bar1_data.pntsc,
                        type        = IGRPS); 
    ind_arr++;                                        /* ---23--- */

  }

  /*  poles display  */
  if (toggle_poly)
  {
    for (i=0; i<n_disp_poles; i++)
    {  
      pntsp[i].points = poles_pnt[i];
      pntsp[i].num_points = 1;

      for (k=0; k<3; k++)               
        poles_pnt[i][k] = blndcrv->poles[3*i+k];
             
      dp$build_dis_buffer(buffer      = &display_elements[ind_arr],
                          display_att = &pnt_poles_display,
                          geometry    = &pntsp[i],
                          type        = IGRPS);
      ind_arr++;                                       /* ---23+MAX_POLES--- */
    }
  }




 
  /* ---------------------------------- */
  /* ---  select dynamic work mode  --- */
  /* ---------------------------------- */
 

  {

    IGRlong     txt_index;
    IGRdouble   dist_cur;
    IGRdouble   dist_min;
    IGRpoint    mouse_rot;
                  
    IGRdouble   rot_matrix[16];
    IGRdouble   mat_wtv[16];                    /*  world to view matrix  */


repeat:
    /*  redraw clear all elements if buffers  */
    for (ii=0; ii<ind_arr; ii++)
    {
      dp$display(msg    = &loc_msg,
                 buffer = &display_elements[ii],
                 mode   = GRhe);
    }
    /*  reset nearest sensi point marker with old = medium size  */ 
    if (last_wrk_sel == WRK_TANG1)     pnt1_bar_display.weight = P_WEIGHT_MED;
    if (last_wrk_sel == WRK_TANG2)     pnt2_bar_display.weight = P_WEIGHT_MED;
    if (last_wrk_sel == WRK_INT_BLND1) int1_bar_display.weight = L_WEIGHT_MED;
    if (last_wrk_sel == WRK_INT_BLND2) int2_bar_display.weight = L_WEIGHT_MED;

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
                      msgnum        = SELEXT_NEXT_DYN,
                      response      = response,
                      response_data = response_data,    
                      event         = &param_event);
    if (!(1&sts)) goto wrapup;

    /*  move on means terminate modify at all */
    if (*response == EX_RJT_MOVEON)
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

    if (*response == EX_DATA)
    {
      /***********************************/
      /*  handle dynamic task selection  */
      /***********************************/
      /*  reset highlight all elements if buffers  */
      for (ii=0; ii<ind_arr; ii++)  
      {
        dp$display(msg    = &loc_msg,
                   buffer = &display_elements[ii],
                   mode   = GRhe);
      }

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

      mat[0][0] = rot_matrix[0];
      mat[0][1] = rot_matrix[1];
      mat[0][2] = rot_matrix[2];
      mat[1][0] = rot_matrix[4];
      mat[1][1] = rot_matrix[5];
      mat[1][2] = rot_matrix[6];
      mat[2][0] = rot_matrix[8];
      mat[2][1] = rot_matrix[9];
      mat[2][2] = rot_matrix[10];

      /*  recalculate view dependent values  */
      epsw = 0.001;
      /*  calculate work view zoom faktor  */
      if   (ABS(rot_matrix[0]) > epsw)  disp_fakt = mat_wtv[0] / rot_matrix[0];
       else
        if (ABS(rot_matrix[1]) > epsw)  disp_fakt = mat_wtv[1] / rot_matrix[1];
        else                            disp_fakt = mat_wtv[2] / rot_matrix[2];
      
      disp_fakt  = WITH_FAKT / disp_fakt; 
      offs_int_d = FAK_INT_D * disp_fakt; 
      offs_int_s = FAK_INT_S * disp_fakt;  
      fak_marker = 0.35 * FAKQ * disp_fakt;  /* sensitiv barpoint marker length */

      /*  map mousepoint to new mouse view  */
      BSptoldtnw(&rc, trans_vec, mat, &scale, mouse, mouse_rot);
      if (BSERROR(rc))  goto wrapup; 

      mouse_rot_2d[0] = mouse_rot[0];
      mouse_rot_2d[1] = mouse_rot[1];
      mouse_rot_2d[2] = 0.0;



      /*  check if mouse near any sensitiv point  */ 

      /*  map bar dyn end to new mouse view  */
      BSptoldtnw(&rc, trans_vec, mat, &scale, bar1_data.point_cur,
                 bar1_data.point_cur_rot);
      if (BSERROR(rc))  goto wrapup;  
      bar1_data.point_cur_rot[2] = 0.0;
      /*  calculate point distance  */
      dist_min = BSdistptpt(&rc, mouse_rot, bar1_data.point_cur_rot);
      if (BSERROR(rc))  goto wrapup; 
      last_wrk_sel = WRK_TANG1;
      txt_index    = DYN_TANGENT_1;

      BSptoldtnw(&rc, trans_vec, mat, &scale, bar2_data.point_cur,
                 bar2_data.point_cur_rot);
      if (BSERROR(rc))  goto wrapup;  
      bar2_data.point_cur_rot[2] = 0.0;
      /*  calculate point distance  */
      dist_cur = BSdistptpt(&rc, mouse_rot, bar2_data.point_cur_rot);
      if (BSERROR(rc))  goto wrapup;
      if (dist_cur < dist_min)
      {
        dist_min     = dist_cur;
        last_wrk_sel = WRK_TANG2;
        txt_index    = DYN_TANGENT_2;
      }

      if (bar1_data.int_blend_activ)
      {
        /*  map vied dep curve blendpoint marker  to mouse view  */
        BSptoldtnw( &rc, trans_vec, mat, &scale, bar1_data.p_sensi_int, bar1_data.p_sensi_rot);
        if (BSERROR(rc))  goto wrapup;
        bar1_data.p_sensi_rot[2] = 0;
        /*  calculate point distance  */
        dist_cur = BSdistptpt( &rc, mouse_rot, bar1_data.p_sensi_rot);
        if (BSERROR(rc))  goto wrapup; 
        if (dist_cur < dist_min)
        {
          dist_min     = dist_cur;
          last_wrk_sel = WRK_INT_BLND1;
          txt_index    = DYN_INT_POINT1;
        }
      }

      if (bar2_data.int_blend_activ)
      {
        /*  map vied dep curve blendpoint marker  to mouse view  */
        BSptoldtnw( &rc, trans_vec, mat, &scale, bar2_data.p_sensi_int, bar2_data.p_sensi_rot);
        if (BSERROR(rc))  goto wrapup;
        bar2_data.p_sensi_rot[2] = 0;
        /*  calculate point distance  */
        dist_cur = BSdistptpt( &rc, mouse_rot, bar2_data.p_sensi_rot);
        if (BSERROR(rc))  goto wrapup;
        if (dist_cur < dist_min)
        {
          dist_min     = dist_cur;
          last_wrk_sel = WRK_INT_BLND2;
          txt_index    = DYN_INT_POINT2;
        }
      }


      /*  tell user what to do now  */
      sts = ex$message(msgnumb = txt_index);  

      /*  recalculate sign for selected view  */
      if (bar1_data.int_blend_activ)
      {
        sts = BL_prep_iblend( &bar1_data );  
        if (!sts)  goto wrapup;
      }
      if (bar2_data.int_blend_activ)
      {
        sts = BL_prep_iblend( &bar2_data );  
        if (!sts)  goto wrapup;
      }

      /*  mark selected element  */
      pnt1_bar_display.weight = P_WEIGHT_MIN;
      pnt2_bar_display.weight = P_WEIGHT_MIN;
      int1_bar_display.weight = L_WEIGHT_MIN;
      int2_bar_display.weight = L_WEIGHT_MIN;
      if (last_wrk_sel == WRK_TANG1)     pnt1_bar_display.weight = P_WEIGHT_MAX;
      if (last_wrk_sel == WRK_TANG2)     pnt2_bar_display.weight = P_WEIGHT_MAX;
      if (last_wrk_sel == WRK_INT_BLND1) int1_bar_display.weight = L_WEIGHT_MAX;
      if (last_wrk_sel == WRK_INT_BLND2) int2_bar_display.weight = L_WEIGHT_MAX;

      /*  highlight all elements if buffers  */
      for (ii=0; ii<ind_arr; ii++)
      {
        dp$display(msg    = &loc_msg,
                   buffer = &display_elements[ii],
                   mode   = GRhd);
      }

      /*  start the dynamics display  */
      first_run = TRUE;

      sts = dp$dynamics(dyn_fun     = Blend_dyn_bar,
                        information = &display_elements);

      /*  this function is terminated by event (mouse click)  */
      /*  get the input  (without wait)                       */
      size = SIZE;
      sts = ex$wait_for_input(response   = response,
                              buffer     = response_data,    
                              byte       = (int *)&size);

    }
  }

  /*****************/
  /*  Termination  */
  /*****************/

    /*  highlight all elements if buffers  */
    for (ii=0; ii<ind_arr; ii++)
    {
      dp$display(msg    = &loc_msg,
                 buffer = &display_elements[ii],
                 mode   = GRhd);

    }

  /*  User has left dynamics be entering an event. Get the event  */
  /*  to allow buffer draw                                        */
  if (*response == EX_DATA)  goto repeat;
  
  /*  fix redraw clear all elements if buffers  */
  for (ii=0; ii<ind_arr; ii++)
  {
    dp$display(msg    = &loc_msg,
               buffer = &display_elements[ii],
               mode   = GRhe);
  }
 

finish:
  *status = 1;
  if (*response == EX_RJT_MOVEON)   *status = END_BY_MOVEON;
  if (*response == EX_CMD_KEY)      *status = END_BY_CMD;
  if (*response == GR_UNKNOWN_TYPE) *status = END_BY_CMD;

  *ratio1 = start_cond.tangent_value;
  if (*ratio1 <= 0)  *ratio1 = MINVAL;

  *ratio2 = end_cond.tangent_value; 
  if (*ratio2 <= 0)  *ratio2 = MINVAL;

  *dir_cv1 = start_cond.direction;
  *dir_cv2 =   end_cond.direction;
  *par_cv1 = start_cond.blend_pt_par;        
  *par_cv2 =   end_cond.blend_pt_par;  

  /*  save last used rotation matrix  */
  w_rot_mat = rot_mat;
  for (i=0; i<3; i++)
  {
    for (j=0; j<3; j++)
      *w_rot_mat++ = mat[i][j];
  }
  /*  save last used zoom faktor  */
  *disp_fakt_init = WITH_FAKT / disp_fakt; 

  /*  clear all highlite  */
  dp$erase_hilite(msg = &loc_msg);



releas:
  /*  Deallocate memory  */
  if (bar1_data.cv)  free(bar1_data.cv);
  if (bar2_data.cv)  free(bar2_data.cv);
  if (cvw)  BSfreecv(&rc, cvw);
  if (blndcrv)  BSfreecv(&rc, blndcrv);
  if (circcrv)  BSfreecv(&rc, circcrv);  


  if (nx)  om$dealloc(ptr = nx);
  if (ny)  om$dealloc(ptr = ny);
  if (nz)  om$dealloc(ptr = nz);
  if (rho) om$dealloc(ptr = rho);
  if (p_x) om$dealloc(ptr = p_x);
  if (p_y) om$dealloc(ptr = p_y);
  if (p_z) om$dealloc(ptr = p_z);


  return(*status);


wrapup:
  *status = FALSE;
  goto releas;
}


end implementation ECblendcv;

