 
/*

Description

    This file contains method function for modify a blend curve (HDC).
*/

class implementation ECblendsf;


# include "bsparameters.h"
# include "bstypes.h"

# include <math.h>


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
# include "grmacros.h"            /*  delete  */
# include "grdpbmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "expression.h"
# include "expmacros.h"
# include "EMSutlmacros.h"        /*  get_construction_info_from_id  */
# include "ASmsg.h"
# include "ECmsg.h"
# include "bserr.h"

# include "EMS.h"
# include "parametric.h"
# include "nddef.h"
# include "emsdef.h" 
 
# include "ecbls_macros.h"                
# include "ecbls_bitcod.h"                                
# include "saved_blend.h" 
# include "EMSblend_sf.h"
# include "ecbls_for.h"
# include "ecbls_inf.h"

/*  prototypes  */ 
# include "bscveval.h"         /*  function prototype  */
# include "bsconstprcv.h"      /*  function prototype  */
# include "bsmdistcvsf.h"      /*  function prototype  */
# include "bsmdistcvcv.h"      /*  function prototype  */
# include "bsdistptpt.h"       /*  function prototype  */
# include "bsdotp.h"           /*  function prototype  */

# include "ecbls_gt.h"         /*  function prototype  */
# include "ecbls_dyn.h"        /*  function prototype  */
# include "ecbls_sf_vc.h"      /*  function prototype  */


# define MAX(x,y)  ((x) < (y) ? (y) : (x))
# define MIN(x,y)  ((x) < (y) ? (x) : (y))
# define ABS(x)    ((x) < 0 ? -(x) : (x))

extern OMuword  OPP_GRcurve_class_id;
extern OMuword  OPP_GRpoint_class_id;
extern OMuword  OPP_EMSsubbs_class_id;

from EMSassoc import EMget_parent_info;

from GRvg     import GRgetsize,
                     GRgetgeom,
                     GRconstruct; 
                                    from GRvg     import GRremwrng;
from NDnode   import NDget_objects; 


# define    MAX_NUM_PARENTS    38
# define    MARK_VAL     -1234567
# define    PARM_EPS     0.000001          /*  avoid zero at iso  */


/* text for prompts and other messages */

/*                           "No blend possible"  */    
#define ERROR_MESSAGE_NOINT  EMS_I_No_Bl_Po


/*                        "Identify curve on surface 1"  */
#define ENTER_PROMPT_BLC1  EMS_P_Id_Cu_Su_1    
               
/*                        "Identify curve on surface 2"  */
#define ENTER_PROMPT_BLC2  EMS_P_Id_Cu_Su_2                   

/*                        "Identify surface 1 partial blend startpoint"  */
#define ENTER_PROMPT_PB1S  EMS_P_Id_Su1_Pa_Bl_St  

/*                        "Identify surface 1 partial blend endpoint"   */
#define ENTER_PROMPT_PB1E  EMS_P_Id_Su1_Pa_Bl_En  

/*                        "Identify surface 2 partial blend startpoint"  */
#define ENTER_PROMPT_PB2S  EMS_P_Id_Su2_Pa_Bl_St  
 
/*                        "Identify surface 2 partial blend endpoint"  */
#define ENTER_PROMPT_PB2E  EMS_P_Id_Su2_Pa_Bl_En  
 
/*                        "Identify surface 1 base curve"  */
#define ENTER_PROMPT_IBB1  EMS_P_Id_Su1_Ba_Cu

/*                        "Identify surface 2 base curve"  */
#define ENTER_PROMPT_IBB2  EMS_P_Id_Su2_Ba_Cu     

/*                        "Identify surface 1 internal blend direction vector"  */
#define ENTER_PROMPT_IBV1  EMS_P_Id_Su1_In_Bl_Di
  
/*                        "Identify surface 2 internal blend direction vector"  */
#define ENTER_PROMPT_IBV2  EMS_P_Id_Su2_In_Bl_Di  





/* --------------------------------------
Name

    locateCurve

Abstract

    This is a static function used to perform locate for this command.

Synopsis

    static long locateCurve(msg, txt_index, locate_event, accept_event,
                            response, response_data, par, selpnt, vec)

    long            *msg;           return code 
    IGRint          txt_index;      select type & text number
                                    1 curve   Ind. 1.srf int blend curve
                                    2 curve   Ind. 2.srf int blend curve
                                    3 point   Ind. 1.srf start partial blendpnt
                                    4 point   Ind. 1.srf end   partial blendpnt
                                    5 point   Ind. 2.srf start partial blendpnt
                                    6 point   Ind. 2.srf end   partial blendpnt
                                    7 curve   Ind. 1.sfr base blend curve
                                    8 curve   Ind. 2.srf base blend curve
                                    9 curve   Ind. 1.srf direction vector
                                   10 curve   Ind. 2.srf direction vector

    struct GRevent  *locate_event;      locate event structure
    struct GRevent  *accept_event;      accept event structure
    IGRint          *response;          response
    IGRchar         *response_data;     response data
    IGRdouble       *par;               iso parameter 
    IGRpoint        selpnt;             projected selection point
    IGRvector       vec;                tangent value of curve at sel. point



Description

    This function sets up the locate arguments for curve select
    arguments (such as the prompts) and calls lc$locate.

Return Value

    Returns OM_S_SUCCESS or OM_E_ABORT if error.

Notes

    This function exists for the purpose of making the execute method
    more readable.

History

    08 Feb 94   AIC     Creation
*/


static IGRlong locateCurve(IGRlong         *msg,
                           IGRint          txt_index,   
                           struct GRevent  *locate_event,
                           struct GRevent  *accept_event,
                           IGRint          *response,
                           IGRchar         *response_data,
                           IGRdouble       *par,
                           IGRpoint        selpnt,
                           IGRvector       vec)


{

  struct GRlc_locate    attributes;
  struct GRlc_stack     stack;
  OM_S_CLASSLIST        rtree_classes;
  OM_S_CLASSLIST        eligible_classes;

  struct IGRbsp_curve   *cv;              /*  selected curve abstract data */

  IGRpoint              eval[3];          /*  evaluated point and tangent  */
  BSrc                  rc;
  IGRlong               num_bytes;        /*  size of base curve     */

  IGRint                i;                /*  loop index  */
  IGRlong               loc_msg;
  IGRint                loc_key;
  IGRlong               sts = OM_E_ABORT;


  /* Initialize the locate input structures  */
  stack.num_entries    = 0;
  stack.number_located = 0;
  cv = NULL;

  attributes.properties = LC_LC_ONLY | LC_RW | LC_DP_ONLY;

  rtree_classes.w_count = eligible_classes.w_count = 1;
  rtree_classes.w_flags = eligible_classes.w_flags = OM_CLST_subclass;

  if ( txt_index == 1  ||  txt_index == 2
      || (txt_index >= 7 && txt_index <= 10) )
  {
    attributes.owner_action = LC_READ | LC_REF_OBJECTS;

    rtree_classes.p_classes    = &OPP_GRcurve_class_id;
    eligible_classes.p_classes = &OPP_GRcurve_class_id;
  }

  if (txt_index >= 3 && txt_index <= 6)  
  {
    /*  point locate only  */
    attributes.owner_action = LC_READ | LC_REF_OBJECTS;

    rtree_classes.p_classes     = &OPP_GRpoint_class_id;
    eligible_classes.p_classes  = &OPP_GRpoint_class_id;
  }

  eligible_classes.w_flags = OM_CLST_subclass;
  eligible_classes.w_count = 1;

  /*  txt_index == 1 */ loc_key = ENTER_PROMPT_BLC1;
  if (txt_index == 2)   loc_key = ENTER_PROMPT_BLC2;
  if (txt_index == 3)   loc_key = ENTER_PROMPT_PB1S;
  if (txt_index == 4)   loc_key = ENTER_PROMPT_PB1E;
  if (txt_index == 5)   loc_key = ENTER_PROMPT_PB2S;
  if (txt_index == 6)   loc_key = ENTER_PROMPT_PB2E;
  if (txt_index == 7)   loc_key = ENTER_PROMPT_IBB1;
  if (txt_index == 8)   loc_key = ENTER_PROMPT_IBB2;
  if (txt_index == 9)   loc_key = ENTER_PROMPT_IBV1;
  if (txt_index == 10)  loc_key = ENTER_PROMPT_IBV2;

  /*  Perform locate  */
  sts = lc$locate(rc = msg,
                  event1 = locate_event,
                  mask1  = GRm_DATA | GRm_BACK_UP | GRm_MOVE_ON ,
                  event2 = accept_event,
                  mask2  = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_MOVE_ON ,
                  response      = response,            
                  response_data = response_data,  
                  locate_key    = loc_key,
                  relocate_key  = GR_I_EleNotFound,
                  acc_key       = GR_P_Acc,
                  attributes    = &attributes,
                  stack         = &stack,
                  display_flag  =   ELEM_HILIGHT 
                                  | LC_ACC_ONE_ELEMENT 
                                  | LC_ERASE_LOC_ELEMENT,
                  eligible_classes = &eligible_classes,
                  rtree_classes    = &rtree_classes);  

  if (accept_event->response == EX_DATA) 
  {
    if (txt_index <= 7 || txt_index >= 8)
    {    
      /*---  get selected curve  ---*/ 
      sts = om$send(mode = OM_e_wrt_object,
                    msg = message GRvg.GRgetsize (
                          &loc_msg,
                          &accept_event->located_object[0].module_info.md_env.matrix_type,
                           accept_event->located_object[0].module_info.md_env.matrix,
                           &num_bytes ),
                    senderid = NULL,
                    targetid = accept_event->located_object[0].located_obj.objid,
                    targetos = accept_event->located_object[0].located_obj.osnum);
 
      cv  = (struct IGRbsp_curve *) malloc(num_bytes); 

      sts = om$send(mode = OM_e_wrt_object,
                    msg = message GRvg.GRgetgeom (&loc_msg,
                          &accept_event->located_object[0].module_info.md_env.matrix_type,
                           accept_event->located_object[0].module_info.md_env.matrix,
                                (IGRchar *) cv),
                    senderid = NULL,
                    targetid = accept_event->located_object[0].located_obj.objid,
                    targetos = accept_event->located_object[0].located_obj.osnum);

      *par = accept_event->located_object[0].geom_parms.u;
      /*  use exact start/end point for copy tangent value  */
      if (txt_index == 7 || txt_index == 8)
      {
        if (*par < 0.5)  *par = 0.0;
        else             *par = 1.0;
      }
      /*  extract tangent at selection point  */
      BScveval(cv, *par, 1, eval, &rc); 
    
      for (i=0; i<3; i++)
      {
        selpnt[i] = eval[0][i];
        vec[i]    = eval[1][i];
      }
    }
  }

  /*  return space  */
  if (cv)  {  free(cv);  cv = NULL;  }

  *msg = sts;
  return sts; 
}









/* --------------------------------------
Name

    get_sfr_data

Abstract

    This is a static function used get surface data.

Synopsis

 static IGRlong get_srf_data(msg, surf_info, sf)

    IGRlong                *msg;               return code 
    struct GRlc_info       *surf_info;         surface info
    struct IGRbsp_surface  **sf;               surface buffer



Description

    This function extracts the surface data..

Return Value

    Returns OM_S_SUCCESS or OM_E_ABORT if error.

Notes

    This function exists for the purpose of making the execute method
    more readable.

History

    14 Jun 94   HBE     Creation
*/


static IGRlong get_srf_data(IGRlong                *msg,
                            struct GRlc_info       *surf_info,
                            struct IGRbsp_surface  **sf)
{


  IGRlong               num_bytes;        /*  size of base curve     */
  IGRlong               loc_msg;
  IGRlong               sts = OM_E_ABORT;
  struct IGRbsp_surface *sf_x;


  /*---  get surface data  ---*/ 
  sts = om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRgetsize (
                      &loc_msg,
                      &surf_info->module_info.md_env.matrix_type,
                       surf_info->module_info.md_env.matrix,
                      &num_bytes ),
                senderid = NULL,
                targetid = surf_info->located_obj.objid,
                targetos = surf_info->located_obj.osnum);
  if (!(1&sts))  goto wrapup;

  sf_x = (struct IGRbsp_surface *) malloc(num_bytes);

  sts = om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRgetgeom (&loc_msg,
                      &surf_info->module_info.md_env.matrix_type,
                       surf_info->module_info.md_env.matrix,
                       (IGRchar *) sf_x),
                senderid = NULL,
                targetid = surf_info->located_obj.objid,
                targetos = surf_info->located_obj.osnum);
  if (!(1&sts)) goto wrapup;

  *sf = sf_x;

  *msg = sts;
  return sts; 


wrapup:
  return OM_E_ABORT;
}







/*
Name

    ECblendsf_m

Abstract

    This is a static function used to perform numeric input for this command.

Synopsis

    static long ECblendsf_m(msg, blend_id, HDbd_f_p, module_inf, 
                            response, response_data,
                            b_start_cond, b_ende_cond,
                            b_start_inf, b_ende_inf,
                            saved_blend, pre_saved_blend,
                            rot_mat, disp_fakt,
                            dyn_status)

    IGRlong                           *msg               return code from co$getevent
    struct GRid                       *blend_id          blend_surface to modify
    struct GRmd_env                   *module_inf        bend curve environment 
    struct HDbd_form_sf_p             *HDbd_f_p          values get by option form
    IGRint                            *response          response
    IGRchar                           *response_data     response data
    struct EMSblend_sf_end_condition  *b_start_cond      main basic surface info
    struct EMSblend_sf_end_condition  *b_ende_cond       main basic surface info
    struct HDbd_ext_inf               *b_start_inf       ext surface info
    struct HDbd_ext_inf               *b_ende_inf        ext surface info
    struct saved_blend                *saved_blend       last saved assoc build block
    struct saved_blend                *pre_saved_blend   last -1 saved assoc build block
    IGRdouble                         *rot_mat[9]        first locate view rot matrix
    IGRdouble                         *disp_fakt         first locate view zoom faktor
    IGRlong                           *dyn_status        dynamic modul termination status

    22  Okt 93   HOB     Creation
*/


IGRlong ECblendsf_m(msg, blend_id, module_inf, HDbd_f_p,
                    response, response_data, 
                    b_start_cond, b_ende_cond,
                    b_start_inf, b_ende_inf,
                    saved_blend, pre_saved_blend,
                    rot_mat, disp_fakt,
                    dyn_status)

IGRlong                           *msg;
struct GRid                       *blend_id; 
struct GRmd_env                   *module_inf; 
struct HDbd_form_sf_p             *HDbd_f_p;
IGRint                            *response;
IGRchar                           *response_data;
struct EMSblend_sf_end_condition  *b_start_cond, *b_ende_cond;
struct HDbd_ext_inf               *b_start_inf, *b_ende_inf;
struct saved_blend                *saved_blend, *pre_saved_blend;
IGRdouble                         *rot_mat;  
IGRdouble                         *disp_fakt; 
IGRlong                           *dyn_status;
{      


  IGRlong          sts   = OM_S_SUCCESS;
  IGRlong          sts_m = OM_S_SUCCESS;
  IGRlong          loc_msg, EMmsg;
  IGRlong          rc;
  IGRint           control;
  IGRint           bar_control;
  IGRint           status;
  IGRint           nro;               /*  current object index  */  

  struct GRevent   locate_event,
                   accept_event;
  char             syntax[20];       /*  for sprintf  */

  IGRuint                parent_types[MAX_NUM_PARENTS];
  union EMSparent_info   parents[MAX_NUM_PARENTS];
  IGRint                 num_parents;

                                          /*  1 = surf1 on / 2 = surf2 on  */
  IGRint      dyn_bar;                    /*  dyn bar display              */
  IGRint      dyn_iso;                    /*  dyn int. blend by isoline    */  
  IGRint      dyn_vector;                 /*  collar dyn vector control    */
  IGRint      i, j;                       /*  loop index   */

  IGRint            loc_root_count;       /*  number of roots  */

  struct GRlc_info  curve1_info,          /*  internal blend curve id  */
                    curve2_info;

  struct GRlc_info  p_point1s_info,     /*  srf1 partial blend point id from */
                    p_point1e_info,     /*  srf1 partial blend point id to   */
                    p_point2s_info,     /*  srf1 partial blend point id from */
                    p_point2e_info;     /*  srf1 partial blend point id to   */
  struct GRlc_info  temp_info;          /*  buffer for switching direction   */
  struct GRid       *buf_ptr,        
                    *buf_ptr_w;
  
  /*  FORM values  */ 
  IGRboolean diagnos;                     /*  curvature diagnostic flag  */
  IGRdouble sensi_fakt1, sensi_fakt2;     /*  bar sensitivity factor  */

  IGRint    cv_flag1, cv_flag2;           /*  uv + internal blend switch  */
  IGRint    cont1, cont2;                 /*  1 tangent , 2 curvature  */
  IGRdouble ratio1, ratio2;               /*  ratio for tangents  */ 
  IGRint    tangent_flag1, tangent_flag2, /*  type of tangent value  */
            w_flag1, w_flag2;

  IGRint    approx_flag1, approx_flag2;  /*  approximatiom mode  / 0 = none  */ 
  IGRdouble approx_fact1, approx_fact2;  /*  approximation value  0.0 - 1.0  */
  IGRshort  blend_order;                 /*  order of blendsurface           */
  IGRint    blend_poles;                 /*  sugg. nr poles of blendsurface  */

  IGRint    blend_type;                  /*  blend control information  */

  struct GRid      blend_sf;
  struct GRid      cv1_grid, cv2_grid;

  struct GRmd_env  env_cv1, env_cv2;
  IGRint dir_flag1, dir_flag2;

  IGRdouble  par_cv1[2], par_cv2[2];      /*  partial blend uv parameters   */
  IGRdouble  api_cv1[2], api_cv2[2];      /*  par_cv1 values for API entry   */
                                          /*  < 0  means value set by point  */
                                          /*  value is -10.0 + current       */
  IGRdouble  par_cv1_wrk[2],              /*  partial blend uv (no bias) */
             par_cv2_wrk[2];

  IGRdouble  par_cv_x;
  IGRdouble  par_dum;

  IGRdouble  par_iso1, par_iso2;

  IGRvector  dir_vec1[2], dir_vec2[2];
  IGRvector  vec_copy;
  IGRboolean closed_1, closed_2; 
  IGRdouble  min_rad;
  	

  IGRint     old_cv1,      old_cv2;         /*  old blend start mode  */
  IGRint     old_cont1,    old_cont2;       /*  old curvature  */
  IGRint     old_d_flag1,  old_d_flag2;     /*  old internal blend dir  */
  IGRdouble  old_p_cv1[2], old_p_cv2[2];    /*  old start/end of curve  */
  IGRdouble  old_ratio1,   old_ratio2;      /*  old ratios for tangents  */
  IGRdouble  old_iso1,     old_iso2;        /*  old iso values int blend  */
  IGRdouble  old_approx1,  old_approx2;     /*  old approx values  */
  IGRshort   old_order;                     /*  old blend order  */

  OM_S_OBJID old_cv1_obj, old_cv2_obj;      /*  old int blend curve objid */
  OM_S_OBJID old_pb1s_obj, old_pb1e_obj,    /*  old partial blend point objid */
             old_pb2s_obj, old_pb2e_obj;   
  IGRint     old_t_flag1, old_t_flag2;      /*  old tangent flag  */

  IGRvector  old_vec1[2], old_vec2[2];      /*  old direction vector  */

  IGRint     ind_ratio1,  ind_ratio2,       /*  index in parent list  */
             ind_iso1,    ind_iso2,
             ind_cv1,     ind_cv2,
             ind_p_cv1,   ind_p_cv2,
             ind_cont1,   ind_cont2,
             ind_d_flag1, ind_d_flag2, 
             ind_t_flag1, ind_t_flag2,
             ind_appr1,   ind_appr2, 
             ind_dirv1,   ind_dirv2,
             ind_order;
  struct GRid  new_blend_id;
     
  struct IGRbsp_surface *orig_sf1,  /*  saved base surface  */
                        *orig_sf2;  /*  saved base surface  */

  IGRpoint   selpnt;
  IGRvector  vec1, vec2;          /*  vector of edge (or curve ) at blendpos  */
  IGRdouble  val1, val2;          /*  saved parameter values  */
  	
  IGRvector  vec_1, vec_2;        /*  selected edge direction vector  */ 
  IGRint     ind;                 /*  u,v selection index  */
  IGRdouble  par_u, par_v;        /*  tangent uv position  */
  IGRdouble  temp;                /*  temp value for switch  */
  IGRboolean twist_check;         /*  true if twist check needed  */
  IGRboolean symmetric;           /*  symmetric flag  */

  IGRpoint   pos;  




  /*  make compiler happy  */
  blend_poles = NULL;
  old_cv1 = old_cv2 = NULL;
  old_d_flag1 = old_d_flag2 = NULL; 
  old_cv1_obj = old_cv2_obj = NULL;
  old_pb1s_obj = old_pb1e_obj = old_pb2s_obj = old_pb2e_obj = NULL;   
  old_order = NULL; 


  *msg = OM_S_SUCCESS;
  *dyn_status = NULL;
  twist_check = FALSE; 

  /*  preset work mode                                  */
  dyn_bar    = 3;        /*  dyn bar display            */
  dyn_iso    = 0;        /*  dyn int. blend by isoline  */
  dyn_vector = 0;        /*  collar dyn vector control  */
  
  loc_root_count = NULL;

  sts = om$send (msg = message NDnode.NDget_objects(
                       ND_IN_BUF | ND_ROOT,
                       NULL,
                       0,
                       &buf_ptr,
                       0,
                       MAXINT,
                       &loc_root_count),   /*  number of roots  */
                 senderid = NULL_OBJID,            
                 targetid = blend_id->objid,
		 targetos = blend_id->osnum);

  if (! (1&sts)) goto wrapup;

  /*
   * Get the parents
   * parent[0] = surface1
   * parent[1] = surface2
   * parent[2] = type of blend   (defines structure of parameters)
   * parent[3...] = surface  parameters
   * parent[x...MAX_NUM_PARENTS-6] = surface 2 parameters
   * parents[MAX_NUM_PARENT-5 ... MAX_NUM_PARENTS] = EXT OBJECT INFO
   */

  parent_types[0] =
  parent_types[1] = EMSlcinfo; 

  for (nro=2; nro < MAX_NUM_PARENTS-6; nro++) 
    parent_types[nro] = EMSscalar;

  /*  correct for vector  */
  parent_types[16] = EMSvector;
  parent_types[30] = EMSvector;

  for (nro=MAX_NUM_PARENTS-6; nro < loc_root_count; nro++)
    parent_types[nro] = EMSlcinfo; 


  sts = om$send(msg = message EMSassoc.EMget_parent_info(
                              &EMmsg,
                              NULL,
                              loc_root_count,
                              NULL,
                              parent_types,
                              parents),
                senderid = NULL_OBJID,
                targetid = blend_id->objid,
                targetos = blend_id->osnum);
  if(! (1 & sts & EMmsg)) goto wrapup;
     

  nro = 2;
  /*  get parameter for blend construction control  */ 
  blend_type     = parents[nro++].value;     /*  nro = 2  */

  /*  get other parameters  */
    ind_cv1  = nro; 
  cv_flag1       = parents[nro++].value;        /*  nro = 3  */
    ind_cont1 = nro;
  cont1          = parents[nro++].value;        /*  nro = 4  */ 
    ind_appr1 = nro;
  approx_flag1   = parents[nro++].value;        /*  nro = 5  */    
  approx_fact1   = parents[nro++].value;        /*  nro = 6  */ 
    ind_t_flag1 = nro;  
  tangent_flag1  = parents[nro++].value;        /*  nro = 7  */ 
    ind_ratio1 = nro; 
  ratio1         = parents[nro++].value;        /*  nro = 8  */
    ind_iso1 = nro;
  par_iso1       = parents[nro++].value;        /*  nro = 9  */  
    ind_p_cv1 = nro;
  api_cv1[0]     =  
  par_cv1[0]     = parents[nro++].value;        /*  nro = 10  */
  api_cv1[1]     =     
  par_cv1[1]     = parents[nro++].value;        /*  nro = 11  */ 
    ind_d_flag1 = nro; 
  dir_flag1      = parents[nro++].value;        /*  nro = 12  */ 
    ind_dirv1 = nro;
  for (i=0; i<3; i++)   
    dir_vec1[0][i] = parents[nro++].value;      /*  nro = 13-15  */   
  for (i=0; i<3; i++)    
    dir_vec1[1][i] = parents[nro].vector[1];    /*  nro = 16 vector */    
  nro++;
  
  /*  create parametric objects for surface 2  */
    ind_cv2 = nro; 
  cv_flag2       = parents[nro++].value;        /*  nro = 17  */
    ind_cont2 = nro;  
  cont2          = parents[nro++].value;        /*  nro = 18  */ 
    ind_appr2 = nro;
  approx_flag2   = parents[nro++].value;        /*  nro = 19  */    
  approx_fact2   = parents[nro++].value;        /*  nro = 20  */  
    ind_t_flag2 = nro;   
  tangent_flag2  = parents[nro++].value;        /*  nro = 21  */
    ind_ratio2 = nro; 
  ratio2         = parents[nro++].value;        /*  nro = 22  */ 
    ind_iso2 = nro;  
  par_iso2       = parents[nro++].value;        /*  nro = 23  */ 
    ind_p_cv2 = nro;
  api_cv2[0]     =     
  par_cv2[0]     = parents[nro++].value;        /*  nro = 24  */ 
  api_cv2[1]     =     
  par_cv2[1]     = parents[nro++].value;        /*  nro = 25  */ 
    ind_d_flag2 = nro;
  dir_flag2      = parents[nro++].value;        /*  nro = 26  */
    ind_dirv2 = nro;
  for (i=0; i<3; i++)       
    dir_vec2[0][i] = parents[nro++].value;      /*  nro = 27-29  */ 

  for (i=0; i<3; i++)      
    dir_vec2[1][i] = parents[nro].vector[i];    /*  nro = 30 vector */    
  nro++;

    ind_order = nro;
  blend_order      = parents[nro++].value;      /*  nro = 31  */ 


  /*  preset with ext curve value  */
  /*  curve1  */
  /*  check for additional dependecy by internal blend curve  */   
  if (blend_type & BLEND_BIT_INT_PTR_1)
  {
    cv1_grid    = parents[nro].grobj.grid;
    curve1_info = parents[nro].lc_info;
    env_cv1     = parents[nro].lc_info.module_info;
    nro++;
  }
  else
  {
    cv1_grid.osnum = NULL;
    cv1_grid.objid = NULL;
  }

  /*  curve2  */ 
  if (blend_type & BLEND_BIT_INT_PTR_2)
  {
    cv2_grid    = parents[nro].grobj.grid;
    curve2_info = parents[nro].lc_info;
    env_cv2     = parents[nro].lc_info.module_info;
    nro++;
  }
  else
  {  
    cv2_grid.osnum = NULL;
    cv2_grid.objid = NULL;
  }



  /*  preset with partial blend point value  */
  
  /*  check for additional dependecy by internal blend curve  */   
  if (blend_type & BLEND_BIT_PART_PTR_1S)
  {     p_point1s_info = parents[nro].lc_info;  nro++;  }
  else  p_point1s_info.located_obj.objid = NULL_OBJID;

  if (blend_type & BLEND_BIT_PART_PTR_1E)
  {     p_point1e_info = parents[nro].lc_info;  nro++;  }
  else  p_point1e_info.located_obj.objid = NULL_OBJID;

 
  if (blend_type & BLEND_BIT_PART_PTR_2S)
  {     p_point2s_info = parents[nro].lc_info;  nro++;  }
  else  p_point2s_info.located_obj.objid = NULL_OBJID; 

  if (blend_type & BLEND_BIT_PART_PTR_2S)
  {     p_point2e_info = parents[nro].lc_info;   nro++;  }
  else  p_point2e_info.located_obj.objid = NULL_OBJID; 


  /*  check for additional dependency by internal blend curve  */   
  /*  blend regeneration date all there  */
  num_parents = nro;

  /*  fill main surface1 data block  */

  /* b_start_cond->surface  (done before)  */
  b_start_cond->boundary_flag    = cv_flag1;
  b_start_cond->curve            = NULL;
  b_start_cond->blend_pt_par[0]  = par_cv1[0];
  b_start_cond->blend_pt_par[1]  = par_cv1[1];
  b_start_cond->pariso           = par_iso1;
  b_start_cond->direction        = dir_flag1;
  b_start_cond->tangent_flag[0]  = 0;
  b_start_cond->tangent_flag[1]  = tangent_flag1;
  b_start_cond->tangent_flag[2]  = 0;
  b_start_cond->tangent_value[0] = 1.0;
  b_start_cond->tangent_value[1] = ratio1;
  b_start_cond->tangent_value[2] = 1.0;
  b_start_cond->curvature_flag   = cont1 - 1;
  b_start_cond->curvature_value  = NULL;
  b_start_cond->approx_flag      = approx_flag1;
  b_start_cond->approx_fact      = approx_fact1;

  b_start_inf->base_srf         = parents[0].lc_info;
  b_start_inf->ib_crv           = curve1_info;
  b_start_inf->pb_point_s       = p_point1s_info;
  b_start_inf->pb_point_e       = p_point1e_info;
  for (j=0; i<3; i++)
  {
    b_start_inf->dir_vec[0][i]   = dir_vec1[0][i];
    b_start_inf->dir_vec[1][i]   = dir_vec1[1][i];
  }
  b_start_inf->col_dir           = ABS(dir_flag1) - 1;

  /*  fill main surface2 data block  */   

  /* b_ende_cond->surface  (done before)  */
  b_ende_cond->boundary_flag    = cv_flag2;
  b_ende_cond->curve            = NULL;
  b_ende_cond->blend_pt_par[0]  = par_cv2[0];
  b_ende_cond->blend_pt_par[1]  = par_cv2[1];
  b_ende_cond->pariso           = par_iso2;
  b_ende_cond->direction        = dir_flag2;
  b_ende_cond->tangent_flag[0]  = 0;
  b_ende_cond->tangent_flag[1]  = tangent_flag2;
  b_ende_cond->tangent_flag[2]  = 0;
  b_ende_cond->tangent_value[0] = 1.0;
  b_ende_cond->tangent_value[1] = ratio2;
  b_ende_cond->tangent_value[2] = 1.0;
  b_ende_cond->curvature_flag   = cont2 - 1;
  b_ende_cond->curvature_value  = NULL;
  b_ende_cond->approx_flag      = approx_flag2;
  b_ende_cond->approx_fact      = approx_fact2;
  b_ende_inf->base_srf         = parents[1].lc_info;
  b_ende_inf->ib_crv           = curve2_info;
  b_ende_inf->pb_point_s       = p_point2s_info;
  b_ende_inf->pb_point_e       = p_point2e_info;
  for (j=0; i<3; i++)
  {
    b_ende_inf->dir_vec[0][i]   = dir_vec2[0][i];
    b_ende_inf->dir_vec[1][i]   = dir_vec2[1][i];
  }
  b_ende_inf->col_dir           = ABS(dir_flag2) - 1;



  if (b_ende_cond->surface == NULL  &&  b_ende_cond->surface == NULL)
  {
    /*  reload basic surface data from assoc  */
    sts = get_srf_data(&loc_msg, &parents[0].lc_info ,&b_start_cond->surface);
    sts = get_srf_data(&loc_msg, &parents[1].lc_info ,&b_ende_cond->surface);
    /*  set current blend order  */
    HDbd_f_p->HDbd_order = blend_order;

    *msg = OM_S_SUCCESS;
    return OM_S_SUCCESS;
  }

  if (cv_flag1)  saved_blend->init_cv1_flag = cv_flag1;   /*  save original value  */
  if (cv_flag2)  saved_blend->init_cv2_flag = cv_flag2;   /*  save original value  */
  if (cv_flag1 < 0)  cv_flag1 = 0;
  if (cv_flag2 < 0)  cv_flag2 = 0;
  b_start_cond->boundary_flag = cv_flag1;
  b_ende_cond->boundary_flag  = cv_flag2;

  /*  save base surface pointer  */
  orig_sf1 = b_start_cond->surface;
  orig_sf2 = b_ende_cond->surface;

  if (!HDbd_f_p->HDbd_undo &&  !HDbd_f_p->HDbd_undolm)
  {
    /*  save parameters fur undo  */
    pre_saved_blend = saved_blend;        /*  save old last parameters  */

    /*  fill new saved blend  */
    saved_blend->surface1      = parents[0].lc_info,
    saved_blend->curve1        = curve1_info;
    saved_blend->cv_flag1      = cv_flag1;
    saved_blend->cont1         = cont1;
    saved_blend->approx_flag1  = approx_flag1;
    saved_blend->approx_fact1  = approx_fact1;
    saved_blend->tangent_flag1 = tangent_flag1;
    saved_blend->ratio1        = ratio1;
    saved_blend->par_iso1      = par_iso1;
    saved_blend->par_cv1[0]    = par_cv1[0];
    saved_blend->par_cv1[1]    = par_cv1[1];
    saved_blend->dir_flag1     = dir_flag1;
    for (j=0; j<2; j++)
      for (i=0; i<3; i++)
        saved_blend->dir_vec1[j][i] = dir_vec1[j][i];
    saved_blend->p_point1s     = p_point1s_info;
    saved_blend->p_point1e     = p_point1e_info;

    saved_blend->surface2      = parents[1].lc_info, 
    saved_blend->curve2        = curve2_info,
    saved_blend->cv_flag2      = cv_flag2;
    saved_blend->cont2         = cont2;
    saved_blend->approx_flag2  = approx_flag2;
    saved_blend->approx_fact2  = approx_fact2;
    saved_blend->tangent_flag2 = tangent_flag2;
    saved_blend->ratio2        = ratio2;
    saved_blend->par_iso2      = par_iso2;
    saved_blend->par_cv2[0]    = par_cv2[0];
    saved_blend->par_cv2[1]    = par_cv2[1];
    saved_blend->dir_flag2     = dir_flag2;
    for (j=0; j<2; j++)
      for (i=0; i<3; i++)
        saved_blend->dir_vec2[j][i] = dir_vec2[j][i];

    saved_blend->blend_order = blend_order;
    saved_blend->blend_poles = blend_poles;

  }
  else
  {
    if (HDbd_f_p->HDbd_undolm)
    {
      parents[0].lc_info = saved_blend->surface1;
      curve1_info        = saved_blend->curve1;
      cv_flag1           = saved_blend->cv_flag1;
      cont1              = saved_blend->cont1;
      approx_flag1       = saved_blend->approx_flag1; 
      approx_fact1       = saved_blend->approx_fact1;
      tangent_flag1      = saved_blend->tangent_flag1;
      ratio1             = saved_blend->ratio1;
      par_iso1           = saved_blend->par_iso1;
      api_cv1[0]         =  
      par_cv1[0]         = saved_blend->par_cv1[0];
      api_cv1[1]         =  
      par_cv1[1]         = saved_blend->par_cv1[1];
      dir_flag1          = saved_blend->dir_flag1;
      for (j=0; j<2; j++)
        for (i=0; i<3; i++)
          dir_vec1[j][i] = saved_blend->dir_vec1[j][i];
      p_point1s_info     = saved_blend->p_point1s;
      p_point1e_info     = saved_blend->p_point1e;

      parents[1].lc_info = saved_blend->surface2;
      curve2_info        = saved_blend->curve2;
      cv_flag2           = saved_blend->cv_flag2;
      cont2              = saved_blend->cont2;
      approx_flag2       = saved_blend->approx_flag2;
      approx_fact2       = saved_blend->approx_fact2;
      tangent_flag2      = saved_blend->tangent_flag2;
      ratio2             = saved_blend->ratio2;
      par_iso2           = saved_blend->par_iso2;
      api_cv2[0]         =  
      par_cv2[0]         = saved_blend->par_cv2[0];
      api_cv2[1]         =  
      par_cv2[1]         = saved_blend->par_cv2[1];
      dir_flag2          = saved_blend->dir_flag2;
      for (j=0; j<2; j++)
        for (i=0; i<3; i++)
          dir_vec2[j][i] = saved_blend->dir_vec2[j][i];
      p_point2s_info     = saved_blend->p_point2s;
      p_point2e_info     = saved_blend->p_point2e;

      blend_order = saved_blend->blend_order;
      blend_poles = saved_blend->blend_poles;

      goto rebuild;
 
    }

 
    if (HDbd_f_p->HDbd_undo)
    {
    /*  UNDO means delete  */
      sts = dp$display(msg  = &loc_msg,
                       oids = blend_id,
                       mode = GRbehe);

      sts = om$send(msg  = message GRvg.GRremwrng(&loc_msg, module_inf),
                    senderid = NULL,
                    targetid = blend_id->objid,
                    targetos = blend_id->osnum);

      sts = om$send(msg      = message Root.delete(0),
                    senderid = NULL,
                    targetid = blend_id->objid,
                    targetos = blend_id->osnum);

      blend_id->objid  = NULL;      /*  mark as UNDO - delete  */

      return (TRUE);
    }
  }



  /*  save old values  */
  old_cv1 = cv_flag1;
  old_cv2 = cv_flag2;
  old_cv1_obj = cv1_grid.objid;
  old_cv2_obj = cv2_grid.objid;
  old_pb1s_obj = p_point1s_info.located_obj.objid;
  old_pb1e_obj = p_point1e_info.located_obj.objid;
  old_pb2s_obj = p_point2s_info.located_obj.objid;
  old_pb2e_obj = p_point2e_info.located_obj.objid;
  old_ratio1 = ratio1;
  old_ratio2 = ratio2;
  old_iso1 = par_iso1;
  old_iso2 = par_iso2;
  old_cont1 = cont1;        
  old_cont2 = cont2;        
  old_p_cv1[0] = par_cv1[0];
  old_p_cv1[1] = par_cv1[1];
  old_p_cv2[0] = par_cv2[0];
  old_p_cv2[1] = par_cv2[1];
  old_d_flag1 = dir_flag1;
  old_d_flag2 = dir_flag2;
  old_t_flag1 = tangent_flag1;
  old_t_flag2 = tangent_flag2;
  old_approx1 = approx_fact1;
  old_approx2 = approx_fact2;
  for (i=0; i<3; i++)
  {
    old_vec1[0][i] = dir_vec1[0][i];
    old_vec1[1][i] = dir_vec1[1][i];
    old_vec2[0][i] = dir_vec2[0][i];
    old_vec2[1][i] = dir_vec2[1][i];
  }
  old_order = blend_order;

  blend_sf = *blend_id;


  /* ---  handle FORM changes  --- */
       
  /*  handle twisted surfaces  */
  if ( HDbd_f_p->HDbd_srf_twist)
  {
    /*  twist blend surface at start  */
    par_cv2[0] = old_p_cv2[1];
    par_cv2[1] = old_p_cv2[0];  
    /*  twist also partial blend points info  */
    temp_info      = p_point2s_info; 
    p_point2s_info = p_point2e_info;  
    p_point2e_info = temp_info; 
  }

  /* ---  SURFACE 1  --- */

  /*  get sensitivity faktors set by option form  */
  sensi_fakt1 = HDbd_f_p->HDbd_srf1.t_sensi;

  /*  get tangent value input type  */
  if (HDbd_f_p->HDbd_srf1.t_auto)   dyn_bar &= ~1; 
  else                              dyn_bar |=  1;


  /*  tangent flag / curvature  setting  */
  w_flag1 = tangent_flag1 = ABS(tangent_flag1);
  /* force new optimized ratio in case of mode change */
  if ( HDbd_f_p->HDbd_srf1.curv_c  && cont1 != 2)  w_flag1 *= -1;
  if (!HDbd_f_p->HDbd_srf1.curv_c  && cont1 != 1)  w_flag1 *= -1;
  /*  observe default tangent setting  */
  if (!(dyn_bar&1))  tangent_flag1 *= -1;
  if (w_flag1 < 0)   tangent_flag1 = w_flag1; 
  b_start_cond->tangent_flag[1]  = tangent_flag1;
  cont1 = HDbd_f_p->HDbd_srf1.curv_c + 1;  

  /*  use last form displayed ratio value */
  ratio1 = HDbd_f_p->HDbd_srf1.ratio;

  if (HDbd_f_p->HDbd_srf1.t_copy)
  {
    HDbd_f_p->HDbd_srf1.t_copy  = FALSE;     /*  use only once  */
    HDbd_f_p->HDbd_srf1.t_keyin = TRUE;      /*  use only once  */
    /*  locate the blend curve to copy parameters  */
    sts = locateCurve(&loc_msg, 7, &locate_event, &accept_event,
                      response, response_data,
                      &par_dum, selpnt, vec_copy);   
    if(! (1 & sts)) goto wrapup;
      
    if (accept_event.response == EX_BACK_UP)      goto wrapup;
    if (accept_event.response == GR_UNKNOWN_TYPE) return(OM_S_SUCCESS);
    ratio1 = sqrt(vec_copy[0]*vec_copy[0] + vec_copy[1]*vec_copy[1]
                                          + vec_copy[2]*vec_copy[2]);
  }

  /*  get approximation factor ad determine approximation flag  */
  approx_fact1 = HDbd_f_p->HDbd_srf1.approx;
  approx_flag1 = (int) (approx_fact1 + 0.99999);

  /*  ..exicrv: 0 = no existing int blend                        */
  /*            1 = internal blend by screen position            */
  /*            2 = internal blend by existing curve             */
  /*            3 = (modify)         reselect curve position     */
  /*            4 = (start)          reselect curve position     */
  if (HDbd_f_p->HDbd_srf1.exicrv)
  {
    if (HDbd_f_p->HDbd_srf1.exicrv == 1)
    {

      if (cv_flag1 <= 0)
      {
        cv_flag1 = ABS(saved_blend->init_cv1_flag);  /*  reset to original value  */
        if (cv_flag1 < 3 )  par_iso1 = 0.0;     /*  reset to initial start pos */
        else                par_iso1 = 1.0;
      }
      dyn_iso |= 1;                             /*  mark for screen pos  */
      if (ABS(cv_flag1) != old_cv1)  twist_check = TRUE;
    }
    else
    {

      /*  internal blend by external curve  */

      /*  set tangent direction  */
      dir_flag1 =   1*HDbd_f_p->HDbd_srf1.crv_u
                  + 2*HDbd_f_p->HDbd_srf1.crv_v
                  + 3*HDbd_f_p->HDbd_srf1.crv_ruled
                  + 4*HDbd_f_p->HDbd_srf1.crv_vec_s
                  + 4*HDbd_f_p->HDbd_srf1.crv_vec_d
                  + 5*HDbd_f_p->HDbd_srf1.crv_perp;
      if (saved_blend->dir_flag1 < 0)  dir_flag1 *= -1;
      /*  set dynamic tangent direction by vector  */
      if (HDbd_f_p->HDbd_srf1.crv_vec_d)   dyn_vector |=  1; 
      else                                 dyn_vector &= ~1; 

      if (HDbd_f_p->HDbd_srf1.exicrv > 2)
      {
        /*  locate the internal blend curve1  */
        sts = locateCurve(&loc_msg, 1, &locate_event, &accept_event,
                          response, response_data, 
                          &par_cv_x, selpnt, vec1);   
        if(! (1 & sts)) goto wrapup;
      
        if (accept_event.response == EX_BACK_UP)      goto wrapup;
        if (accept_event.response == GR_UNKNOWN_TYPE) return(OM_S_SUCCESS);

        if (parents[0].lc_info.located_obj.objid ==
            parents[1].lc_info.located_obj.objid)
        {
          /*  check for ext curve and same curve  */
          if (accept_event.located_object[0].located_obj.objid == cv2_grid.objid)
          {
            sts = ex$message (msgnumb = ERROR_MESSAGE_NOINT);
            goto  wrapup;
          }
        }      

        /*  save curve1 object id  */
        cv1_grid.objid = accept_event.located_object[0].located_obj.objid;
        cv1_grid.osnum = accept_event.located_object[0].located_obj.osnum;
        env_cv1        = accept_event.located_object[0].module_info;
        b_start_inf->ib_crv =
        curve1_info          = accept_event.located_object[0];
        cv_flag1 = 0;
        par_iso1 = 0.0;
        b_start_cond->direction = 1;    /*  collar surface direction  */

        /*  reset new obj partial parameters  */
        api_cv1[0] = par_cv1[0] = 0.0;
        api_cv1[1] = par_cv1[1] = 1.0;
        /*  reset partial point pointer  */
        p_point1s_info.located_obj.objid = NULL_OBJID;
        p_point1e_info.located_obj.objid = NULL_OBJID;
        if (HDbd_f_p->HDbd_srf1.partial > 0)   
                       HDbd_f_p->HDbd_srf1.partial = 0;  /*  reset format  */ 
        saved_blend->dir_flag1 = 0;   /*  reset for new select  */
        twist_check = TRUE;
      }


      if (HDbd_f_p->HDbd_srf1.exicrv >= 2)
      {
        if (HDbd_f_p->HDbd_srf1.crv_vec_s  &&  ABS(saved_blend->dir_flag1) != 4)
        {
          /*  locate external vector 1  */
          sts = locateCurve(&loc_msg, 9, &locate_event, &accept_event,
                            response, response_data,
                            &par_cv_x, selpnt, dir_vec1[0]);
          if(! (1 & sts)) goto wrapup;

          if (accept_event.response == EX_BACK_UP)      goto wrapup;
          if (accept_event.response == GR_UNKNOWN_TYPE) return(OM_S_SUCCESS);
          /*  don't save vector object id  */
        }
      } 
    }
  }
  else
  {
    cv_flag1 = saved_blend->init_cv1_flag; /*  reset to original value  */
    if (cv_flag1 <  3)  par_iso1 = 0.0; 
    else                par_iso1 = 1.0;

    if (cv_flag1 != old_cv1)  twist_check = TRUE;
  }

  if (HDbd_f_p->HDbd_srf1.partial == 3)
  {
    HDbd_f_p->HDbd_srf1.partial = 1;               /*  reset read new  */
    /*  locate the SRF1 partial blend point 1  */
    sts = locateCurve(&loc_msg, 3, &locate_event, &accept_event,
                      response, response_data, &par_cv_x, selpnt, vec1);   
         if(! (1 & sts)) goto wrapup;
      
    if (accept_event.response == EX_BACK_UP)      goto wrapup;
    if (accept_event.response == GR_UNKNOWN_TYPE) return(OM_S_SUCCESS);

    /*  save point object id for assoc handling  */
    p_point1s_info  = 
    b_start_inf->pb_point_s = accept_event.located_object[0]; 
 
    sts = ECblendsf_gt(&loc_msg, parents[0].lc_info.located_obj,        
                       accept_event.located_object[0].proj_pnt,    
                       &parents[0].lc_info.module_info,               
                       ABS(cv_flag1), &val1);

    /*  locate the SRF1 partial blend point 2  */
    sts = locateCurve(&loc_msg, 4, &locate_event, &accept_event,
                      response, response_data, &par_cv_x, selpnt, vec1); 
  
    if(! (1 & sts)) goto wrapup;
      
    if (accept_event.response == EX_BACK_UP)      goto wrapup;
    if (accept_event.response == GR_UNKNOWN_TYPE) return(OM_S_SUCCESS);

    /*  save point object id for assoc handling  */
    p_point1e_info  =
    b_start_inf->pb_point_e = accept_event.located_object[0];  

    sts = ECblendsf_gt(&loc_msg, parents[0].lc_info.located_obj,        
                       accept_event.located_object[0].proj_pnt,    
                       &parents[0].lc_info.module_info,               
                       ABS(cv_flag1), &val2);

    /*  avoid same start/end value  */
    if (val1 == val2)
    {
      if (val1 < 0.5)  val1 = 0.0;
      else             val2 = 1.0;
    }

    if (  (par_cv1[0] < par_cv1[1]  &&  val1 > val2) 
       || (par_cv1[0] > par_cv1[1]  &&  val1 < val2) ) 
    {
        par_cv1[0] = val2;
        par_cv1[1] = val1;
        temp_info      = p_point1s_info; 
        p_point1s_info = p_point1e_info;  
        p_point1e_info = temp_info; 
    }
    else
    {
      par_cv1[0] = val1;
      par_cv1[1] = val2; 
    }
    api_cv1[0] = par_cv1[0];
    api_cv1[1] = par_cv1[1];

    if (par_cv1[0] >= 0)
    {
      api_cv1[0] = -10.0 + par_cv1[0];    /*  mark :  value set by pointer  */
      api_cv1[1] = -10.0 + par_cv1[1];    /*  mark :  value set by pointer  */
    }
  }
  else
  {
    if (!(HDbd_f_p->HDbd_srf1.partial&1))
    {
      /*  check if partial blend value  */
      if ( old_pb1s_obj != NULL_OBJID ||  old_pb1e_obj != NULL_OBJID)
      {
        /*  reset to surface bound values ( observe old direction)  */
        if (par_cv1[0] < par_cv1[1]) {  par_cv1[0] = 0.0;  par_cv1[1] = 1.0;  } 
        else                         {  par_cv1[0] = 1.0;  par_cv1[1] = 0.0;  } 
      }
      /*  reset new obj partial parameters  */
      api_cv1[0] = par_cv1[0];
      api_cv1[1] = par_cv1[1];  
      /*  reset partial point pointer  */
      p_point1s_info.located_obj.objid = NULL_OBJID;
      p_point1e_info.located_obj.objid = NULL_OBJID;
    }
  }


  /* ---  SURFACE 2  --- */

  /*  get sensitivity faktors set by option form  */
  sensi_fakt2 = HDbd_f_p->HDbd_srf2.t_sensi;

  /*  get tangent value input type  */
  if (HDbd_f_p->HDbd_srf2.t_auto)   dyn_bar &= ~2; 
  else                              dyn_bar |=  2;


  /*  tangent flag / curvature  setting  */       
  w_flag2 = tangent_flag2 = ABS(tangent_flag2);
  /* force new optimized ratio in case of mode change */
  if ( HDbd_f_p->HDbd_srf2.curv_c  && cont2 != 2)  w_flag2 *= -1;
  if (!HDbd_f_p->HDbd_srf2.curv_c  && cont2 != 1)  w_flag2 *= -1;
  /*  observe default tangent setting  */
  if (!(dyn_bar&2))  tangent_flag2 *= -1;
  if (w_flag2 < 0)   tangent_flag2 = w_flag1; 
  b_ende_cond->tangent_flag[1]  = tangent_flag2;
  cont2 = HDbd_f_p->HDbd_srf2.curv_c + 1;


  ratio2 = HDbd_f_p->HDbd_srf2.ratio;      /*  use last form displayed ratio value */

  if (HDbd_f_p->HDbd_srf2.t_copy)
  {
    HDbd_f_p->HDbd_srf2.t_copy = FALSE;      /*  use only once  */
    HDbd_f_p->HDbd_srf2.t_keyin = TRUE;      /*  use only once  */
    /*  locate the blend curve to copy parameters  */
    sts = locateCurve(&loc_msg, 8, &locate_event, &accept_event,
                      response, response_data,
                      &par_dum, selpnt, vec_copy);   
    if(! (1 & sts)) goto wrapup;
      
    if (accept_event.response == EX_BACK_UP)      goto wrapup;
    if (accept_event.response == GR_UNKNOWN_TYPE) return(OM_S_SUCCESS);
    ratio2 = sqrt(vec_copy[0]*vec_copy[0] + vec_copy[1]*vec_copy[1]
                                          + vec_copy[2]*vec_copy[2]);
  }

  /*  get approximation factor ad determine approximation flag  */
  approx_fact2 = HDbd_f_p->HDbd_srf2.approx;
  approx_flag2 = (int) (approx_fact2 + 0.99999);

  if (HDbd_f_p->HDbd_srf2.exicrv)
  {
    if (HDbd_f_p->HDbd_srf2.exicrv == 1)
    {
      if (cv_flag2 <= 0)
      {
        cv_flag2 = ABS(saved_blend->init_cv2_flag);   /*  reset to original value  */
        if (cv_flag2 < 3 )  par_iso2 = 0.0;      /*  reset to initial start pos */
        else                par_iso2 = 1.0;
      }

      dyn_iso |= 2;                             /*   mark for screen pos  */
      if (ABS(cv_flag2) != old_cv2)  twist_check = TRUE;
    }
    else
    {
      /*  internal blend by external curve  */
      /*  set tangent direction  */
      dir_flag2 =   1*HDbd_f_p->HDbd_srf2.crv_u
                  + 2*HDbd_f_p->HDbd_srf2.crv_v
                  + 3*HDbd_f_p->HDbd_srf2.crv_ruled 
                  + 4*HDbd_f_p->HDbd_srf2.crv_vec_s
                  + 4*HDbd_f_p->HDbd_srf2.crv_vec_d
                  + 5*HDbd_f_p->HDbd_srf2.crv_perp; 
      if (saved_blend->dir_flag2 < 0)  dir_flag2 *= -1;
      /*  set dynamic tangent direction by vector  */
      if (HDbd_f_p->HDbd_srf2.crv_vec_d)   dyn_vector |=  2; 
      else                                 dyn_vector &= ~2; 


      if (HDbd_f_p->HDbd_srf2.exicrv > 2)
      {
        /*  locate the internal blend curve2  */
        sts = locateCurve(&loc_msg, 2, &locate_event, &accept_event,
                          response, response_data, &par_cv_x, selpnt, vec2);   
        if(! (1 & sts)) goto wrapup;
      
        if (accept_event.response == EX_BACK_UP)      goto wrapup;
        if (accept_event.response == GR_UNKNOWN_TYPE) return(OM_S_SUCCESS);

        if (parents[0].lc_info.located_obj.objid ==
            parents[1].lc_info.located_obj.objid)
        {
          /*  check for ext curve and same curve  */
          if (accept_event.located_object[0].located_obj.objid == cv1_grid.objid)
          {
            sts = ex$message (msgnumb = ERROR_MESSAGE_NOINT);
            goto  wrapup;
          }
        }      

        /*  save curve2 object id  */
        cv2_grid.objid = accept_event.located_object[0].located_obj.objid;
        cv2_grid.osnum = accept_event.located_object[0].located_obj.osnum;
        env_cv2        = accept_event.located_object[0].module_info;
        b_ende_inf->ib_crv =       
        curve2_info         = accept_event.located_object[0];
        cv_flag2 = 0;
        par_iso2 = 0.0; 
        b_ende_cond->direction = 1;    /*  collar surface direction  */   

        /*  reset new obj partial parameters  */
        api_cv2[0] = par_cv2[0] = 0.0;
        api_cv2[1] = par_cv2[1] = 1.0;
        /*  reset partial point pointer  */
        p_point2s_info.located_obj.objid = NULL_OBJID; 
        p_point2e_info.located_obj.objid = NULL_OBJID; 
        if (HDbd_f_p->HDbd_srf2.partial > 0)   
                       HDbd_f_p->HDbd_srf2.partial = 0;  /*  reset format  */ 
        saved_blend->dir_flag2 = 0;   /*  reset for new select  */
        twist_check = TRUE;
      }


      if (HDbd_f_p->HDbd_srf2.exicrv >= 2)
      {
        if (HDbd_f_p->HDbd_srf2.crv_vec_s  &&  ABS(saved_blend->dir_flag2) != 4)
        {
          /*  locate external vector 2  */
          sts = locateCurve(&loc_msg, 10, &locate_event, &accept_event,
                            response, response_data,
                            &par_cv_x, selpnt, dir_vec2[0]);   
          if(! (1 & sts)) goto wrapup;

          if (accept_event.response == EX_BACK_UP)      goto wrapup;
          if (accept_event.response == GR_UNKNOWN_TYPE) return(OM_S_SUCCESS);
          /*  don't save vector object id  */
        }
      }
    }
  }
  else
  {
    cv_flag2 = saved_blend->init_cv2_flag;    /*  reset to original value  */
    if (cv_flag2 <  3)  par_iso2 = 0.0; 
    else                par_iso2 = 1.0;

    if (cv_flag2 != old_cv2)  twist_check = TRUE;
  }


  if (HDbd_f_p->HDbd_srf2.partial == 3)
  {
    HDbd_f_p->HDbd_srf2.partial = 1;
    /*  locate the SRF2 partial blend point 1  */
    sts = locateCurve(&loc_msg, 5, &locate_event, &accept_event,
                      response, response_data, &par_cv_x, selpnt, vec1);   
 
    if(! (1 & sts)) goto wrapup;
      
    if (accept_event.response == EX_BACK_UP)      goto wrapup;
    if (accept_event.response == GR_UNKNOWN_TYPE) return(OM_S_SUCCESS);

    /*  save point object id for assoc handling  */
    p_point2s_info  = 
    b_ende_inf->pb_point_s = accept_event.located_object[0];  

    sts = ECblendsf_gt(&loc_msg, parents[1].lc_info.located_obj,        
                       accept_event.located_object[0].proj_pnt,    
                       &parents[0].lc_info.module_info,               
                       ABS(cv_flag2), &val1);

    /*  locate the SRF2 partial blend point 2  */
    sts = locateCurve(&loc_msg, 6, &locate_event, &accept_event,
                      response, response_data, &par_cv_x, selpnt, vec1);   

    if(! (1 & sts)) goto wrapup;
      
    if (accept_event.response == EX_BACK_UP)      goto wrapup;
    if (accept_event.response == GR_UNKNOWN_TYPE) return(OM_S_SUCCESS);

    /*  save point object id for assoc handling  */
    p_point2e_info = 
    b_ende_inf->pb_point_e = accept_event.located_object[0];  

    sts = ECblendsf_gt(&loc_msg, parents[1].lc_info.located_obj,        
                       accept_event.located_object[0].proj_pnt,    
                       &parents[0].lc_info.module_info,               
                       ABS(cv_flag2), &val2);

    /*  avoid same start/end value  */
    if (val1 == val2)
    {
      if (val1 < 0.5)  val1 = 0.0;
      else             val2 = 1.0;
    }
    if (  (par_cv2[0] < par_cv2[1]  &&  val1 > val2) 
       || (par_cv2[0] > par_cv2[1]  &&  val1 < val2) ) 
    {
        par_cv2[0] = val2;
        par_cv2[1] = val1;
        temp_info      = p_point2s_info; 
        p_point2s_info = p_point2e_info;  
        p_point2e_info = temp_info; 
    }
    else
    {
      par_cv2[0] = val1;
      par_cv2[1] = val2;
    }
    api_cv2[0] = par_cv2[0];
    api_cv2[1] = par_cv2[1];

    if (par_cv2[0] >= 0)
    {
      api_cv2[0] = -10.0 + par_cv2[0];    /*  mark :  value set by pointer  */
      api_cv2[1] = -10.0 + par_cv2[1];    /*  mark :  value set by pointer  */
    }

  }
  else
  {
    if (!(HDbd_f_p->HDbd_srf2.partial&1))
    {
      /*  check if old partial blend value  */
      if ( old_pb2s_obj != NULL_OBJID ||  old_pb2e_obj != NULL_OBJID)
      {
        /*  reset to surface bound values ( observe old direction)  */
        if (par_cv2[0] < par_cv2[1]) {  par_cv2[0] = 0.0;  par_cv2[1] = 1.0;  }
        else                         {  par_cv2[0] = 1.0;  par_cv2[1] = 0.0;  }
 
      }

      /*  reset new obj partial parameters  */
      api_cv2[0] = par_cv2[0];
      api_cv2[1] = par_cv2[1];    
      /*  reset partial point pointer  */
      p_point2s_info.located_obj.objid = NULL_OBJID; 
      p_point2e_info.located_obj.objid = NULL_OBJID; 
    } 
  }



  if (p_point1s_info.located_obj.objid != NULL_OBJID  &&
      p_point1s_info.located_obj.objid == p_point1e_info.located_obj.objid)
  {
    if (par_cv1[0] == 0.0  ||  par_cv1[0] == 1.0 )
    {
      p_point1s_info.located_obj.objid = NULL_OBJID;
      api_cv1[0] = par_cv1[0];
    } 
    if (par_cv1[1] == 0.0  ||  par_cv1[1] == 1.0 )
    {
      p_point1e_info.located_obj.objid = NULL_OBJID;
      api_cv1[0]  = par_cv1[1];
    } 
  }

  if (p_point2s_info.located_obj.objid != NULL_OBJID  &&
      p_point2s_info.located_obj.objid == p_point2e_info.located_obj.objid)
  {
    if (par_cv2[0] == 0.0  ||  par_cv2[0] == 1.0 )
    {
      p_point2s_info.located_obj.objid = NULL_OBJID;
      api_cv2[0] = par_cv2[0];
    } 
    if (par_cv2[1] == 0.0  ||  par_cv2[1] == 1.0 )  
    {
      p_point2e_info.located_obj.objid = NULL_OBJID;
      api_cv2[1] = par_cv2[1];
    }  
  }


  if (twist_check && !HDbd_f_p->HDbd_srf_twist)      
  {
    /*  extract unit 1 direction  */
    if (cv_flag1 > 0)
    {
      /*  find untwisted surface direction of surface  */ 
      if (ABS(cv_flag1) == 1  ||  ABS(cv_flag1) == 3) 
                        {   par_u = 0.5;  par_v = par_iso1;  ind = 1;  }
      else              {   par_u = par_iso1;  par_v = 0.5;  ind = 2;  }
      /*  extract surface_1 blend edge direction  */
      sts = BL_get_sf_vc( parents[0].lc_info.located_obj, 
                         &parents[0].lc_info.module_info,
                         par_u, par_v, ind, pos, vec_1, &closed_1); 
    }

    else

    {  
      /*  get curve 1 direction  */
      sts = BL_get_sf_vc(curve1_info.located_obj, &curve1_info.module_info,
                                        0.5, 0.0, NULL, pos, vec_1, &closed_1);
    }

    /*  extract unit 2 direction  */
    if (cv_flag2 >  0)
    {
      /*  find untwisted surface direction of surface  */ 
      if (ABS(cv_flag2) == 1  ||  ABS(cv_flag2) == 3) 
                        {   par_u = 0.5;  par_v = par_iso2;  ind = 1;  }
      else              {   par_u = par_iso2;  par_v = 0.5;  ind = 2;  }

      /*  extract surface_2 blend edge direction  */
      sts = BL_get_sf_vc( parents[1].lc_info.located_obj, 
                         &parents[1].lc_info.module_info,
                         par_u, par_v, ind, pos, vec_2, &closed_2); 
    }

    else

    {                                    
      /*  get curve 2 direction  */
      sts = BL_get_sf_vc(curve2_info.located_obj, &curve2_info.module_info,
                                       0.5, 0.0, NULL, pos, vec_2, &closed_2);
    }


    /*  blend surface may be twisted at surface_2 connection only!  */
    if ( BSdotp(&rc, vec_1, vec_2) < 0.0   ==  par_cv2[0] < par_cv2[1] )
    { 

      /*  twist blend direction by second edge */ 
      temp       = par_cv2[0];
      par_cv2[0] = par_cv2[1];
      par_cv2[1] = temp;
      temp       = api_cv2[0];
      api_cv2[0] = api_cv2[1];
      api_cv2[1] = temp;
    }
  }


  /*  set blend order from form  */
  blend_order = HDbd_f_p->HDbd_order;

  /*  curvator diagnostics set by options  */
  diagnos = HDbd_f_p->HDbd_diagnos;

  /*  symmetric surface build set by otions  */
  symmetric = HDbd_f_p->HDbd_symmetric;

  /*  unbias partial blend parameter  */
  par_cv1_wrk[0] = par_cv1[0];
  par_cv1_wrk[1] = par_cv1[1];
  if (par_cv1_wrk[0] < 0) { par_cv1_wrk[0] += 10.0;   par_cv1_wrk[1] += 10.0; }
  par_cv2_wrk[0] = par_cv2[0];
  par_cv2_wrk[1] = par_cv2[1];
  if (par_cv2_wrk[0] < 0) { par_cv2_wrk[0] += 10.0;   par_cv2_wrk[1] += 10.0; }

  b_start_cond->approx_fact = approx_fact1;
  b_start_cond->approx_flag = approx_flag1  = (int) (approx_fact1 + 0.9999);
  b_ende_cond->approx_fact  = approx_fact2;
  b_ende_cond->approx_flag  = approx_flag1  = (int) (approx_fact2 + 0.9999);


  /*  update main base surface block partial parameters  */
  if (par_cv1[0] < 0)   par_cv1[0] += 10.0;
  if (par_cv1[1] < 0)   par_cv1[1] += 10.0;
  if (par_cv2[0] < 0)   par_cv2[0] += 10.0;
  if (par_cv2[1] < 0)   par_cv2[1] += 10.0;

  b_start_cond->blend_pt_par[0] = par_cv1[0];
  b_start_cond->blend_pt_par[1] = par_cv1[1];
  b_ende_cond->blend_pt_par[0]  = par_cv2[0];
  b_ende_cond->blend_pt_par[1]  = par_cv2[1];

  if (b_start_cond->tangent_flag[1] < 0)
  {
    b_start_cond->tangent_flag[1] = ABS(b_start_cond->tangent_flag[1]);
    b_start_cond->tangent_value[1] = 1.0;
  }
  if (b_ende_cond->tangent_flag[1] < 0)
  {
    b_ende_cond->tangent_flag[1]  = ABS(b_ende_cond->tangent_flag[1]);
    b_ende_cond->tangent_value[1]  = 1.0;
  }

  b_start_inf->col_dir = ABS(dir_flag1) - 1;
  b_ende_inf->col_dir  = ABS(dir_flag2) - 1;

  b_start_cond->boundary_flag = cv_flag1;
  b_ende_cond->boundary_flag  = cv_flag2;
  b_start_cond->pariso = par_iso1;
  b_ende_cond->pariso  = par_iso2;

  for (i=0; i<3; i++)
  {
    b_start_inf->dir_vec[0][i]   = dir_vec1[0][i];
    b_start_inf->dir_vec[1][i]   = dir_vec1[1][i];
    b_ende_inf->dir_vec[0][i]    = dir_vec2[0][i];
    b_ende_inf->dir_vec[1][i]    = dir_vec2[1][i];
  }
 
  if (ratio1 < 0) {  ratio1 *= -1;  dir_flag1 *= -1;  }
  if (ratio2 < 0) {  ratio2 *= -1;  dir_flag2 *= -1;  }
    

  b_start_cond->tangent_value[1] = ratio1;
  b_ende_cond->tangent_value[1]  = ratio2;
  b_start_cond->direction = dir_flag1;
  b_ende_cond->direction  = dir_flag2;

  b_start_cond->curvature_flag = cont1 - 1;
  b_ende_cond->curvature_flag  = cont2 - 1;

  if (b_start_cond->boundary_flag == -1)  b_start_cond->boundary_flag = 0; 
  if (b_ende_cond->boundary_flag  == -1)  b_ende_cond->boundary_flag  = 0;

  control = 0;                                 /*  not yet used  */
  /*  set circle mode min_rad  */

  min_rad = HDbd_f_p->HDbd_minrad;
  bar_control = 0;

  /***************************/
  /*  execute dynamic modify  */
  /***************************/
  ECblendsf_d(bar_control,                 /*  bar display control        */
	                                   /*  0: no display leading bar  */
	                                   /*  1:    display leading bar  */
              &status,                     /*  return code                */
              sensi_fakt1,
              sensi_fakt2,
              dyn_bar,                      /*  dyn bar display           */
              dyn_iso,                      /*  dyn int. blend by isoline */
              dyn_vector,                   /*  collar dyn vector control */
              response,                     /*  response                  */
              response_data,                /*  char response array       */
              b_start_cond,                 /*  main basic surface info   */
              b_ende_cond,                  /*  main basic surface info   */
              b_start_inf ,                 /*  ext surface info          */
              b_ende_inf ,                  /*  ext surface info          */
              diagnos + 4*symmetric,        /*  diagnostic, symm. on/off  */
              blend_order,                  /*  order in blend direction  */
              &saved_blend->hd_index,       /*  last used hedgehog edge   */
              &saved_blend->hd_cur_param,   /*  last used hedgehog param  */
              rot_mat,                      /*  first locate rot. matrix  */
              disp_fakt);                   /*  first locate zoom faktor  */

  *dyn_status = status;
  sts_m = MARK_VAL;

  if (!(1&status))  goto wrapup;
  {
    struct GRsymbology   cur_symb;
    struct IGRaltdisplay alt_symb;

    /*  dark draw old curve with thicker weight and style = solid  */
    sts = gr$get_symbology(object_id = blend_id,
                           symb      = &cur_symb);

    alt_symb.rgb_value = NULL;
    alt_symb.color     = NULL;
    alt_symb.style     = &cur_symb.display_attr.style;
    alt_symb.weight    = &cur_symb.display_attr.weight;

    cur_symb.display_attr.weight += 3;
    cur_symb.display_attr.style   = 0;

    sts = dp$display(msg      = &loc_msg,
                     oids     = blend_id,
                     mode     = GRbehe,
                     alt_symb = &alt_symb);
  }


  /*  return space  */
  free(orig_sf1);  orig_sf1 = NULL;
  free(orig_sf2);  orig_sf2 = NULL;
  b_start_cond->surface = NULL;
  b_ende_cond->surface  = NULL;

  /*  get parent information  */
  loc_root_count = NULL;    

  sts = om$send (msg = message NDnode.NDget_objects(
                          ND_IN_BUF | ND_ROOT,
                          NULL,
                          0,
                          &buf_ptr,
                          0,
                          MAXINT,
                          &loc_root_count),
                 senderid = NULL_OBJID,            
                 targetid = blend_id->objid,
		 targetos = blend_id->osnum);

  /*  restore modified blend_surface values if changed */ 

  ratio1 = b_start_cond->tangent_value[1];
  ratio2 = b_ende_cond->tangent_value[1];

  par_iso1 = b_start_cond->pariso;
  if (old_iso1 != par_iso1)   
  {
    if (par_iso1 <     PARM_EPS && old_iso1 >= PARM_EPS)
                                                 par_iso1 =       2.0*PARM_EPS;
    if (par_iso1 > 1.0-PARM_EPS && old_iso1 <= 1.0-PARM_EPS) 
                                                 par_iso1 = 1.0 - 2.0*PARM_EPS;
  }
  par_iso2 = b_ende_cond->pariso;
  if (old_iso2 != par_iso2)   
  {
    if (par_iso2 <     PARM_EPS && old_iso2 >= PARM_EPS)
                                                 par_iso2 =       2.0*PARM_EPS;
    if (par_iso2 > 1.0-PARM_EPS && old_iso2 <= 1.0-PARM_EPS) 
                                                 par_iso2 = 1.0 - 2.0*PARM_EPS;
  }

  dir_flag1 = ABS(dir_flag1);
  if( 1&dyn_vector)  dir_flag1 = 6;      /*  index 6 is dyn_vector  */
  dir_flag1 = (b_start_cond->direction < 0) ? -dir_flag1 : dir_flag1; 
  dir_flag2 = ABS(dir_flag2);
  if( 2&dyn_vector)  dir_flag2 = 6;      /*  index 6 is dyn_vector  */
  dir_flag2 = (b_ende_cond->direction < 0) ? -dir_flag2 : dir_flag2; 


  /*  force automatic tangent mode  if button set  */
  if ( !(dyn_bar & 1))   b_start_cond->tangent_flag[1] = tangent_flag1 = -2;
  if ( !(dyn_bar & 2))   b_ende_cond->tangent_flag[1]  = tangent_flag2 = -2;

  /*  convert double to character string  / set mode to modified */  
  sprintf(syntax, "%d", blend_type | BLEND_BIT_MODIFIED); 
  buf_ptr_w = buf_ptr + 2;               
  sts = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                   exp_syntax = syntax);           

  if (old_d_flag1 != dir_flag1) 
  { 
    sprintf(syntax, "%d", dir_flag1); 
    buf_ptr_w = buf_ptr + ind_d_flag1; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);   
  }

  if (old_ratio1 != ratio1)
  {   
    /*  convert double to character string  */   
    sprintf(syntax, "%g", ratio1);
    buf_ptr_w = buf_ptr + ind_ratio1;
    sts_m = exp$modify(exp_id  = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);   
  }  
   
  if (old_d_flag2 != dir_flag2)   
  {
    sprintf(syntax, "%d", dir_flag2); 
    buf_ptr_w = buf_ptr + ind_d_flag2; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);   
  }

  if (old_ratio2 != ratio2)
  {       
    /*  convert double to character string  */              
    sprintf(syntax, "%g", ratio2);
    buf_ptr_w = buf_ptr + ind_ratio2;
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);  
  }

  /*  update internal blend values  (set/reset)  */
  if (old_iso1 != par_iso1)   
  {
    if (par_iso1 <     PARM_EPS && old_iso1 >= PARM_EPS)
                                               par_iso1 =       2.0*PARM_EPS;
    if (par_iso1 > 1.0-PARM_EPS && old_iso1 <= 1.0-PARM_EPS) 
                                               par_iso1 = 1.0 - 2.0*PARM_EPS;
    sprintf(syntax, "%g", par_iso1); 
    buf_ptr_w = buf_ptr + ind_iso1; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);   
  }

  if (old_iso2 != par_iso2)   
  {
    sprintf(syntax, "%g", par_iso2); 
    buf_ptr_w = buf_ptr + ind_iso2; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);   
  }


  if (par_cv1[0] != old_p_cv1[0])
  {
    /*  convert double to character string  */              
    sprintf(syntax, "%g",par_cv1[0]);
    buf_ptr_w = buf_ptr + ind_p_cv1;
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax); 
  }

  if (par_cv1[1] != old_p_cv1[1])
  {
    /*  convert double to character string  */              
    sprintf(syntax, "%g",par_cv1[1]);
    buf_ptr_w = buf_ptr + ind_p_cv1 + 1;
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);  
  }

  if (par_cv2[0] != old_p_cv2[0])
  {
    /*  convert double to character string  */              
    sprintf(syntax, "%g",par_cv2[0]);
    buf_ptr_w = buf_ptr + ind_p_cv2;
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);  
  }

  if (par_cv2[1] != old_p_cv2[1])
  {
    /*  convert double to character string  */              
    sprintf(syntax, "%g",par_cv2[1]);
    buf_ptr_w = buf_ptr + ind_p_cv2 + 1;
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);  
  }


  /*  update curvature mode  */

  if (cont1 != old_cont1)  
  {
    sprintf(syntax, "%d", cont1); 
    buf_ptr_w = buf_ptr + ind_cont1; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);   
  }

  if (cont2 != old_cont2)  
  {
    sprintf(syntax, "%d", cont2); 
    buf_ptr_w = buf_ptr + ind_cont2; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);   
  }

  if (old_t_flag1 != tangent_flag1)   
  {
    sprintf(syntax, "%d", tangent_flag1); 
    buf_ptr_w = buf_ptr + ind_t_flag1; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);   
  }

  if (old_t_flag2 != tangent_flag2)   
  {
    sprintf(syntax, "%d", tangent_flag2); 
    buf_ptr_w = buf_ptr + ind_t_flag2; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);   
  }


  if (old_approx1 != approx_fact1)   
  {
    sprintf(syntax, "%d", approx_flag1); 
    buf_ptr_w = buf_ptr + ind_appr1; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);

    sprintf(syntax, "%g", approx_fact1); 
    buf_ptr_w++; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);
  }

  if (old_approx2 != approx_fact2)   
  {
    sprintf(syntax, "%d", approx_flag2); 
    buf_ptr_w = buf_ptr + ind_appr2; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);

    sprintf(syntax, "%g", approx_fact2); 
    buf_ptr_w++; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);
  }


  /*  save new direction vectors  */

  if (old_vec1[0][0] != b_start_inf->dir_vec[0][0]  ||  
      old_vec1[0][1] != b_start_inf->dir_vec[0][1]  ||  
      old_vec1[0][2] != b_start_inf->dir_vec[0][2]      ) 
  {
    sprintf(syntax, "%g", b_start_inf->dir_vec[0][0]);  
    buf_ptr_w = buf_ptr + ind_dirv1; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);
    sprintf(syntax, "%g", b_start_inf->dir_vec[0][1]);    
    buf_ptr_w++; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);
    sprintf(syntax, "%g", b_start_inf->dir_vec[0][2]);    
    buf_ptr_w++; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);
  }

  if (old_vec2[0][0] != b_ende_inf->dir_vec[0][0]  ||  
      old_vec2[0][1] != b_ende_inf->dir_vec[0][1]  ||   
      old_vec2[0][2] != b_ende_inf->dir_vec[0][2]      )
  {
    sprintf(syntax, "%g", b_ende_inf->dir_vec[0][0]);  
    buf_ptr_w = buf_ptr + ind_dirv2; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);
    sprintf(syntax, "%g", b_ende_inf->dir_vec[0][1]);  
    buf_ptr_w++; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);
    sprintf(syntax, "%g", b_ende_inf->dir_vec[0][2]); 
    buf_ptr_w++; 
    sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                       exp_syntax = syntax);
  }


rebuild:     
  /*  cv_flag != 0: dir_flag is blend direction (+/-)     */  
  /*  cv_flag == 0: dir_flag is ext crv blend direction   */

  if ( (( ABS(cv_flag1) == old_cv1  &&  ABS(cv_flag2) == old_cv2 ) 
     || ( cv_flag1 > 0  &&  old_cv1 > 0 &&  cv_flag2 > 0  &&  old_cv2 > 0) )

     && (cv1_grid.objid  == old_cv1_obj  
     &&  cv2_grid.objid  == old_cv2_obj 
     &&  p_point1s_info.located_obj.objid == old_pb1s_obj 
     &&  p_point1e_info.located_obj.objid == old_pb1e_obj 
     &&  p_point2s_info.located_obj.objid == old_pb2s_obj 
     &&  p_point2e_info.located_obj.objid == old_pb2e_obj )

     && !HDbd_f_p->HDbd_undolm)
  {   
    /*  ********************************************  */
    /*  modifying by changing curve assos parameters  */
    /*  ********************************************  */

    if (dir_flag1 != old_d_flag1)  
    {
      sprintf(syntax, "%d", dir_flag1); 
      buf_ptr_w = buf_ptr + ind_d_flag1; 
      sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                         exp_syntax = syntax); 
    }

    if (dir_flag2 != old_d_flag2)  
    {
      sprintf(syntax, "%d", dir_flag2); 
      buf_ptr_w = buf_ptr + ind_d_flag2; 
      sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                         exp_syntax = syntax); 
    }

    if (blend_order != old_order)  
    {
      sprintf(syntax, "%d", blend_order); 
      buf_ptr_w = buf_ptr + ind_order; 
      sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                         exp_syntax = syntax); 
    }

    /*  redisplay old blend surface if no modification  */
    if (sts_m == MARK_VAL)
    {
      sts = dp$display(msg      = &loc_msg,
                       mode     = GRbd,
                       oids     = blend_id);
      if(! (1 & sts & loc_msg)) goto wrapup; 
    } 
  }

  else

  {
    /*  ***********************************************  */
    /*  modifying by generating new assoc blend surface  */
    /*  ( used for undo last modified also )             */
    /*  ***********************************************  */

    struct GRmd_env         blend_env;
    struct GRvg_construct   blend_cnst;
    struct IGResbs          attr;
    struct IGRdisplay       blend_dis;
    IGRint                  wrk_cv_flag1, wrk_cv_flag2;
    IGRlong                 blend_msg;


    /*  Set up the construct like old  */ 
    blend_cnst.msg        = &blend_msg;
    blend_cnst.env_info   = &blend_env;
    blend_cnst.geometry   = NULL;       
    blend_cnst.display    = &blend_dis;
    blend_cnst.class_attr = (IGRchar *) &attr; 
    sts = gr$get_module_env(msg = &blend_msg, buffer = &blend_env);

    EFget_construction_info_from_id(&loc_msg,
                                    &blend_cnst,
                                    blend_id->objid,
                                    blend_id->osnum);
    if(! (1&loc_msg) ) goto wrapup;


    sts = om$send(msg  = message GRvg.GRremwrng(&loc_msg, module_inf),
                  senderid = NULL,
                  targetid = blend_id->objid,
                  targetos = blend_id->osnum);

    sts = om$send(msg      = message Root.delete(0),
                  senderid = NULL,
                  targetid = blend_id->objid,
                  targetos = blend_id->osnum);


    /*  prepare parameters get from locate  */
    wrk_cv_flag1 = (cv_flag1 && cv_flag1>0) ?
                            ABS(cv_flag1) : -ABS(saved_blend->init_cv1_flag);
    wrk_cv_flag2 = (cv_flag2 && cv_flag2>0) ?
                            ABS(cv_flag2) : -ABS(saved_blend->init_cv2_flag);

    /*  call associativ blend build  */
    sts = ec$blend_surfaces( 
             msg            = &loc_msg,
             surface1       = &parents[0].lc_info,
             curve1         = &curve1_info,  
             p_point1s      = &p_point1s_info,
             p_point1e      = &p_point1e_info,
             cv_flag1       = wrk_cv_flag1,
             cont1          = cont1,
             approx_flag1   = approx_flag1,
             approx_fact1   = approx_fact1,
             tangent_flag1  = tangent_flag1,
             ratio1         = &ratio1,
             par_iso1       = par_iso1,
             par_cv1        = api_cv1,
             dir_flag1      = dir_flag1,
             dir_vec1       = b_start_inf->dir_vec, 
             surface2       = &parents[1].lc_info,
             curve2         = &curve2_info,
             p_point2s      = &p_point2s_info,
             p_point2e      = &p_point2e_info,
             cv_flag2       = wrk_cv_flag2,
             cont2          = cont2,
             approx_flag2   = approx_flag2,
             approx_fact2   = approx_fact2,
             tangent_flag2  = tangent_flag2,
             ratio2         = &ratio2,
             par_iso2       = par_iso2,
             par_cv2        = api_cv2,
             dir_flag2      = dir_flag2,
             dir_vec2       = b_ende_inf->dir_vec,  
             blend_order    = blend_order,
             construct_list = &blend_cnst,  
             blend_os       = &blend_id->osnum,
             blend_id       = &new_blend_id.objid); 
 
    new_blend_id.osnum = blend_id->osnum; 
    if(! (1 & sts & loc_msg)) goto wrapup;


    /*  display new blend surface  */
    sts = dp$display(msg      = &loc_msg,
                     mode     = GRbd,
                     oids     = &new_blend_id);
    if(! (1 & sts & loc_msg)) goto wrapup;
      
    /*  exchange to blend_objid  */
    blend_id->objid  = new_blend_id.objid;
    /*  new blend surface done  */
  }

  if (blend_id->objid > 0)  sts = status;       /*  use dynamic end status  */
  *msg = OM_S_SUCCESS;

  return sts;


wrapup:
  return OM_E_ABORT;
}





end implementation ECblendsf;




