

/*

Description

    This file contains method function for modify a blend curve (HDC).
*/
class implementation ECblendcv;

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
# include "grmacros.h"             /*  gr$delete  */
# include "EMSasnuc.h"
# include "EMSasmacros.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "expression.h"
# include "expmacros.h"
# include "EMSutlmacros.h"        /*  get_construction_info_from_id  */
# include "ASmsg.h"
# include "ECmsg.h"
# include "ecblc_macros.h"
# include "ecblc_for.h"

# include "EMS.h"
# include "parametric.h"
# include "nddef.h"
# include "emsdef.h"    
              
# include "ecblc_bitcod.h"                                

/*  prototypes  */

# include "bscveval.h"       /*  function prototype  */
# include "bsnorvec.h"       /*  function prototype  */
# include "bsmdstptcv.h"     /*  function prototype  */
# include "emblendcv.h"      /*  proto type  */
# include "ecblc_dyn.h"      /*  proto type  */


extern OMuword  OPP_GRcurve_class_id;
extern OMuword  OPP_EMSsubbs_class_id;
extern OMuword  OPP_GRpoint_class_id;

from EMSassoc import EMget_parent_info;

from GRvg     import GRgetsize,
                     GRgetgeom,
                     GRconstruct; 

from NDnode     import NDget_objects; 




struct ext_pnt_info
{
    struct GRlc_info    base_crv;        /*  base curve main info            */
    struct GRlc_info    ib_pnt;          /*  internal blend start/end point  */
};




# define NUM_PARENTS    9
# define TANGENT_MODE   3                  /*  current used tangent mode  */

# define    MARK_VAL     -1234567

/* text for prompts and other messages */
/*                       "Identify point for curve 1  */
#define ENTER_PROMPT_BL1  EMS_P_Id_Po_Cu_1                  
/*                       "Identify point for curve 2  */
#define ENTER_PROMPT_BL2  EMS_P_Id_Po_Cu_2                  



/*
Name

    locatePoint

Abstract

    This is a function used to perform locate for this command.

Synopsis

    static locate_N_Point(msg, locate_event, accept_event,
                               response, response_data)

    long            *msg;               return code 
    IGRint          txt_index;          text index ( = curve number)
    struct GRid     *base_curve;        base curve GRid for normal point  
    struct GRmd_env *env_curve;         base curve environment  
    struct GRevent  *locate_event;      locate event structure
    struct GRevent  *accept_event;      accept event structure
    int             *response;          response
    char            *response_data;     response data
    IGRdouble       *par;               normal point parameter on base curve



Description

    This function sets up the locate arguments for point select
    arguments (such as the prompts) and calls lc$locate and calculates
    the nearest normal point to the base_curve.

Return Value

    Returns OM_S_SUCCESS or OM_E_ABORT if error.

Notes

    This function exists for the purpose of making the execute method
    more readable.

History

    08 Feb 94   AIC     Creation
*/



       IGRlong locate_N_Point(IGRlong         *msg,
                              IGRint           txt_index, 
                              struct GRid     *base_curve,  
                              struct GRmd_env *env_curve,  
                              struct GRevent  *locate_event,
                              struct GRevent  *accept_event,
                              int             *response,
                              char            *response_data,
                              IGRdouble       *par )

{

  struct GRlc_locate    attributes;
  struct GRlc_stack     stack;
  OM_S_CLASSLIST        rtree_classes;
  OM_S_CLASSLIST        eligible_classes;

  struct IGRbsp_curve   *curve;
  IGRpoint              base;                  /*  dummy  */
  BSrc                  rc;
  IGRdouble             dist;                  /*  min distance - unused  */
  IGRlong               num_bytes;             /*  size of base curve     */
  
  IGRlong               loc_msg;
  IGRint                loc_key;

  IGRlong               sts = OM_E_ABORT;

  curve = NULL;
  /* Initialize the locate input structures  */
  stack.num_entries    = 0;
  stack.number_located = 0;
  attributes.properties = LC_LC_ONLY | LC_RW | LC_DP_ONLY;
  /* attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP | LC_REF_OBJECTS | */
  attributes.owner_action = LC_FLEX_COMP   | LC_REF_OBJECTS       |
                            LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;

  rtree_classes.w_count = eligible_classes.w_count = 1;
  rtree_classes.w_flags = eligible_classes.w_flags = OM_CLST_subclass;
  rtree_classes.p_classes  = &OPP_GRpoint_class_id;

  eligible_classes.w_flags = OM_CLST_subclass;
  eligible_classes.w_count = 1;
  eligible_classes.p_classes  = &OPP_GRpoint_class_id; 

  loc_key = ENTER_PROMPT_BL1;                          /*  txt_index: 0  */ 
  if (txt_index == 1)  loc_key = ENTER_PROMPT_BL2;

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
    /*  get existing base curve  */ 
    sts = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetsize(&loc_msg,
                                               &env_curve->md_env.matrix_type, 
			                       env_curve->md_env.matrix,
                                               &num_bytes ),
                  senderid = NULL,
                  targetid = base_curve->objid,
                  targetos = base_curve->osnum);
     if (!(1&sts&loc_msg)) goto wrapup;

     curve = (struct IGRbsp_curve *) malloc(num_bytes);
     if (!curve)  goto wrapup;

     sts = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetgeom(&loc_msg,
                                                &env_curve->md_env.matrix_type, 
                                                env_curve->md_env.matrix, 
                                                (IGRchar *) curve ),
                  senderid = NULL,
                  targetid = base_curve->objid,
                  targetos = base_curve->osnum);
    if (!(1&sts&loc_msg)) goto wrapup;

    BSmdstptcv(curve, accept_event->located_object[0].proj_pnt,
               par, base, &dist, &rc);

    /*  return alloc  */
    if (curve)  free(curve);

    sts = OM_S_SUCCESS;


  }
wrapup:  
   return sts; 
}






/* --------------------------------------
Name

    get_crv_data

Abstract

    This is a static function used get the curve data.

Synopsis

 static IGRlong get_crv_data(msg, surf_info, crv)

    IGRlong                *msg;               return code 
    struct GRlc_info       *crv_info;          curve info
    struct IGRbsp_curve    **crv;              curve buffer



Description

    This function extracts the data of a curve.

Return Value

    Returns OM_S_SUCCESS or OM_E_ABORT if error.

Notes

    This function exists for the purpose of making the execute method
    more readable.

History

    14 Jul 94   HBE     Creation
*/


static IGRlong get_crv_data(IGRlong                *msg,
                            struct GRlc_info       *crv_info,
                            struct IGRbsp_curve    **crv)
{


  IGRlong               num_bytes;        /*  size of base curve     */
  IGRlong               loc_msg;
  IGRlong               sts = OM_E_ABORT;
  struct IGRbsp_curve   *crv_x;


  /*---  get curve data  ---*/ 
  sts = om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRgetsize (
                        &loc_msg,
                        &crv_info->module_info.md_env.matrix_type,
                        crv_info->module_info.md_env.matrix,
                        &num_bytes ),
                senderid = NULL,
                targetid = crv_info->located_obj.objid,
                targetos = crv_info->located_obj.osnum);
  if (!(1&sts&loc_msg)) goto wrapup;

  crv_x = (struct IGRbsp_curve *) malloc(num_bytes);
  if (!crv_x)  goto wrapup;

  sts = om$send(mode = OM_e_wrt_object,
                msg  = message GRvg.GRgetgeom (&loc_msg,
                         &crv_info->module_info.md_env.matrix_type,
                         crv_info->module_info.md_env.matrix,
                         (IGRchar *) crv_x),
                senderid = NULL,
                targetid = crv_info->located_obj.objid,
                targetos = crv_info->located_obj.osnum);
  if (!(1&sts&loc_msg)) goto wrapup;

  *crv = crv_x;

  *msg = sts;
  return sts; 


wrapup:
  return OM_E_ABORT;
}








/*
Name

    ECblendcv_m

Abstract

    This is a static function used to perform numeric input for this command.

Synopsis

    static long ECblendcv_m (msg, blend_id, HDbd_f_p, 
                             response, response_data,
                             b_start_cond, b_ende_cond,
                             ext_pnt1, ext_pnt2,
                             rot_mat, disp_fakt,
                             new_tag)

    IGRlong                  *msg                   return code from co$getevent
    struct GRid              *blend_id              blend_curve to modify
    struct HDbd_form_params  *HDbd_f_p              values get by option form
    IGRlong                  *response              response
    IGRchar                  *response_data         response data
    struct EMSblend_cv_end_condition *b_start_cond  basic blend block 
                                     *b_ende_cond
    struct ext_pnt_info      *ext_pnt1              ext point1 info
                             *ext_pnt2              ext point2 info
    IGRdouble                *rot_mat               cur view rotation matrix  
    IGRdouble                *disp_fakt             cur view zoom faktor 
    OMuint                   *new_tag               new_tag if blend has changed
                                                    NULL = no change

Description

    This function is used to modify a blend curve.

Return Value

    Returns the status of modify.

Notes

    None.

History

    22  Okt 93   HOB     Creation
*/


IGRlong ECblendcv_m(msg, blend_id, HDbd_f_p,
                    response, response_data,
                    b_start_cond,
                    b_ende_cond,
                    ext_pnt1,
                    ext_pnt2,
                    rot_mat,
                    disp_fakt,
                    new_tag)

IGRlong                           *msg;
struct GRid                       *blend_id; 
struct HDbd_form_params           *HDbd_f_p;
IGRint                            *response;
IGRchar                           *response_data;
struct EMSblend_cv_end_condition  *b_start_cond;
struct EMSblend_cv_end_condition  *b_ende_cond;
struct ext_pnt_info               *ext_pnt1;
struct ext_pnt_info               *ext_pnt2;
IGRdouble                         *rot_mat;   
IGRdouble                         *disp_fakt;   
OMuint                            *new_tag;

{
  IGRlong          sts = OM_S_SUCCESS;
  IGRlong          sts_m;
  IGRlong          loc_msg;
  IGRint           ind;
  IGRint           ind_bp1, ind_bp2;
  IGRint           number_parents; 

  struct GRevent   locate_event,
                   accept_event;

  char syntax[20];       /*  for sprintf  */

  IGRuint                parent_types[NUM_PARENTS];
  union EMSparent_info   parents[NUM_PARENTS];

  IGRint      task;
  IGRint      bar_control;
  IGRint      status;
  IGRlong     blend_msg;

  IGRint      par_control;
  IGRdouble   min_rad; 

  /*   for NDnode.NDget_objects  */
  IGRint                 loc_root_count;
  struct GRid            *buf_ptr, *buf_ptr_w;
  struct GRlc_info       point1_id,      /*  internal blend point id  */
                         point2_id;
  OM_S_OBJID             point1_old,  point2_old;   /*  original  objid  */

  IGRint         blend_order;
  IGRint         dir_cv1, dir_cv2;
  IGRint         tangent_flag1, tangent_flag2;
  IGRint         cont1, cont2;
  IGRboolean     int_cv1, int_cv2;        /*  internal blend flag       */
  IGRboolean     diagnos;                 /*  curvator diagnostic flag  */
  IGRboolean     toggle_poly;             /*  toggle polygon flag       */
  IGRboolean     symmetric;               /*  toggle symmetric flag     */

  IGRdouble      ratio1, ratio2;
  IGRdouble      par_cv1, par_cv2;
  IGRdouble      sensi_fakt1, sensi_fakt2;

  IGRdouble  old_ratio1,  old_ratio2;     /* original values  */
  IGRdouble  old_par_cv1, old_par_cv2;    /* original values  */
  IGRint     old_par_control;             /* original values  */


  struct GRvg_construct blend_cnst;      /*  new blend curve construct list  */
  struct GRid           new_blend_id;    /*  replacing object  */
  OMuint                old_blend_tag;

  IGRlong      loc_mx_type = MAIDMX;
  IGRmatrix    loc_mx, *loc_mx_ptr;

  struct GRmd_env      blend_env;
  struct IGRdisplay    blend_dis;
  struct IGResbs       attr;

  struct GRsymbology   cur_symb;
  struct IGRaltdisplay alt_symb;




  /************************/
  /*  blend modify start  */
  /************************/

  /*  make compiler happy  */
  ind_bp1 = ind_bp2 = NULL;
  blend_order = NULL;                /*  yet unused  */

  *msg = OM_S_SUCCESS;
  status = 0;
  *new_tag = NULL;


  point1_id.located_obj.objid = NULL_OBJID;
  point2_id.located_obj.objid = NULL_OBJID;

  /*  get parameter from parent_objects  */
  parent_types[0] = EMSlcinfo;     /*  curve 1 definition     */
  parent_types[1] = EMSlcinfo;     /*  curve 2 definition     */
  parent_types[2] = EMSscalar;     /*  tangent parameter 1    */
  parent_types[3] = EMSscalar;     /*  tangent parameter 2    */
  parent_types[4] = EMSscalar;     /*  parameter blend pnt 1  */
  parent_types[5] = EMSscalar;     /*  parameter blend pnt 2  */ 
  parent_types[6] = EMSscalar;     /*  blendcurve control     */ 
  parent_types[7] = EMSlcinfo;     /*  int blend point cv1    */
  parent_types[8] = EMSlcinfo;     /*  int blend point cv2    */

  sts = om$send(msg = message EMSassoc.EMget_parent_info (
                             &loc_msg,
                              NULL,
                              NUM_PARENTS,
                              NULL,        /*  parent_info not known here  */
                              parent_types,
                              parents),
                senderid = NULL_OBJID,
                targetid = blend_id->objid,
                targetos = blend_id->osnum);
  if(! (1 & sts & loc_msg) )  goto wrapup;

  /*  get tangent 1 value */
  ratio1 = parents[2].value;    
     
  /*  get tangent 2 value */
  ratio2 = parents[3].value;           
        
  /*  get parameter for curve 1 at blendpoint  */
  par_cv1 = parents[4].value;    
     
  /*  get parameter for curve 2 at blendpoint  */
  par_cv2 = parents[5].value;    
        
  /*  get parameter for blend construction control  */ 
  par_control = parents[6].value; 

  if (par_control & BLEND_BIT_CURVATOR_1)  cont1 = 2;
  else                                     cont1 = 1;

  if (par_control & BLEND_BIT_CURVATOR_2)  cont2 = 2;
  else                                     cont2 = 1;
  
  if (par_control & BLEND_BIT_DIRECTION_1)  dir_cv1 = 1; 
  else                                      dir_cv1 = -1;

  if (par_control & BLEND_BIT_DIRECTION_2)  dir_cv2 = 1;
  else                                      dir_cv2 = -1; 

  ind = 7;
  if (par_control & BLEND_BIT_INT_PTR_1)
  {
    point1_id.located_obj.objid = parents[ind].grobj.grid.objid;
    point1_id.located_obj.osnum = parents[ind].grobj.grid.osnum;
    point1_id.module_info       = parents[ind].grobj.env;
    ind_bp1 = ind;
    ind++;
  }
  if (par_control & BLEND_BIT_INT_PTR_2)
  {
    point2_id.located_obj.objid = parents[ind].grobj.grid.objid;
    point2_id.located_obj.osnum = parents[ind].grobj.grid.osnum;
    point2_id.module_info       = parents[ind].grobj.env;
    ind_bp2 = ind;
    ind++;
  }

  /*  save unmodified values  */
  old_ratio1 = ratio1;
  old_ratio2 = ratio2;
  old_par_cv1 = par_cv1;
  old_par_cv2 = par_cv2;
  old_par_control = par_control; 
          

  /*  fill main data block  */
  b_start_cond->blend_pt_par  = par_cv1;
  b_start_cond->direction     = dir_cv1;
  b_start_cond->tangent_flag  = TANGENT_MODE;
  b_start_cond->tangent_value = ratio1;
  b_start_cond->curvature     = cont1 - 1;
  ext_pnt1->base_crv      = parents[0].lc_info;
  if (par_control & BLEND_BIT_INT_PTR_1)  ext_pnt1->ib_pnt = parents[ind_bp1].lc_info;
  else                                    ext_pnt1->ib_pnt.located_obj.objid = NULL;
  b_ende_cond->blend_pt_par  = par_cv2;
  b_ende_cond->direction     = dir_cv2;
  b_ende_cond->tangent_flag  = TANGENT_MODE;
  b_ende_cond->tangent_value = ratio2;
  b_ende_cond->curvature     = cont2 - 1;
  ext_pnt2->base_crv      = parents[1].lc_info;
  if (par_control & BLEND_BIT_INT_PTR_2) ext_pnt2->ib_pnt = parents[ind_bp2].lc_info;
  else                                   ext_pnt2->ib_pnt.located_obj.objid = NULL;

 
  if (b_start_cond->curve == NULL  &&  b_ende_cond->curve == NULL)
  {
    /*  reload basic curve data from assoc  */
    sts = get_crv_data(&loc_msg, &parents[0].lc_info ,&b_start_cond->curve);
    sts = get_crv_data(&loc_msg, &parents[1].lc_info ,&b_ende_cond->curve);
    *msg = OM_S_SUCCESS;
    return (OM_S_SUCCESS);
  }


  /*  save old point objid  */
  point1_old =   point1_id.located_obj.objid;
  point2_old =   point2_id.located_obj.objid;

  /*  set current task  */
  task = 1;
  if (HDbd_f_p->HDbd_mode > 1)  task = 2;
  /*  get sensitivity faktors set by option form  */
  sensi_fakt1 = HDbd_f_p->HDbd_crv1sens;
  sensi_fakt2 = HDbd_f_p->HDbd_crv2sens;

  /*  internal blend  set by option form ( set:int_cv. TRUE = internal blend ) */
  /*  ..exip:  0 = natural blend                                 */
  /*           1 = internal blend  by screen position            */
  /*           2 = internal blend  by existing point             */
  /*           3 = internal blend  by existing point / reselect  */
  int_cv1 = HDbd_f_p->HDbd_crv1exip;
  if (HDbd_f_p->HDbd_crv1exip)
  {
    if (HDbd_f_p->HDbd_crv1exip == 1)
    {
      point1_id.located_obj.objid = NULL_OBJID; 
    }              
    else
    {
      int_cv1 = 0;
      if (HDbd_f_p->HDbd_crv1exip > 2)  
      {
        /*  Locate the object  */
        sts = locate_N_Point(&loc_msg,
                             0,
                             &parents[0].lc_info.located_obj,
                             &parents[0].lc_info.module_info,
                             &locate_event,
                             &accept_event,
                             response,               
                             response_data,
                             &par_cv1);
         if(! (1 & sts)) goto wrapup;


         if (accept_event.response == EX_BACK_UP)  goto wrapup;   
         if (accept_event.response == GR_UNKNOWN_TYPE) 
         {
           return(OM_S_SUCCESS);
         }
         /*  save point1 object id  */
         point1_id = accept_event.located_object[0];
      }
    }
  }

  else
 
  {
    par_cv1 = (IGRint) (par_cv1 + 0.5);  
    point1_id.located_obj.objid = NULL_OBJID; 
  }        


  int_cv2 = HDbd_f_p->HDbd_crv2exip;
  if (HDbd_f_p->HDbd_crv2exip)
  {
    if (HDbd_f_p->HDbd_crv2exip == 1)
    {
      point2_id.located_obj.objid = NULL_OBJID; 
    }              
    else
    {
      int_cv2 = 0;
      if (HDbd_f_p->HDbd_crv2exip > 2)  
      {
        /*  Locate the object  */
        sts = locate_N_Point(&loc_msg,
                             1,
                             &parents[1].lc_info.located_obj,
                             &parents[1].lc_info.module_info,
                             &locate_event,
                             &accept_event,
                             response,               
                             response_data,
                             &par_cv2);
         if(! (1 & sts)) goto wrapup;

         if (accept_event.response == EX_BACK_UP)  goto wrapup;   
         if (accept_event.response == GR_UNKNOWN_TYPE)
         {
           return(OM_S_SUCCESS);
         }
         /*  save point2 object id  */
         point2_id = accept_event.located_object[0];
      }
    }
  }

  else
 
  {
    par_cv2 = (IGRint) (par_cv2 + 0.5);  
    point2_id.located_obj.objid = NULL_OBJID; 
  }        

  /*  set ratios changed by modify  */
  ratio1 = HDbd_f_p->HDbd_abs_ratio1;
  ratio2 = HDbd_f_p->HDbd_abs_ratio2;

  /*  curvator diagnostics set by options  */
  diagnos = HDbd_f_p->HDbd_diagnos;

  /*  toggle polygon set by options  */
  toggle_poly = HDbd_f_p->HDbd_toggle_pol;

  /*  symmetric curve build set by options  */
  symmetric = HDbd_f_p->HDbd_symmetric;

  /* tangent/curvature setting  */
  /* force new optimized ratio in case of mode change */
  tangent_flag1 = TANGENT_MODE;
  if ( HDbd_f_p->HDbd_crv1_cont  && cont1 != 2)  tangent_flag1 = -TANGENT_MODE;
  if (!HDbd_f_p->HDbd_crv1_cont  && cont1 != 1)  tangent_flag1 = -TANGENT_MODE;
  if (tangent_flag1 == -3)  ratio1 = 1.0;       /*  reset relativ factor  */
  b_start_cond->tangent_flag  = tangent_flag1;

  cont1 = HDbd_f_p->HDbd_crv1_cont + 1;

  tangent_flag2 = TANGENT_MODE;
  if ( HDbd_f_p->HDbd_crv2_cont  && cont2 != 2)  tangent_flag2 = -TANGENT_MODE;
  if (!HDbd_f_p->HDbd_crv2_cont  && cont2 != 1)  tangent_flag2 = -TANGENT_MODE;
  if (tangent_flag2 == -3)  ratio2 = 1.0;       /*  reset relativ factor  */
  b_ende_cond->tangent_flag   = tangent_flag2;

  cont2 = HDbd_f_p->HDbd_crv2_cont + 1;
  

  min_rad = HDbd_f_p->HDbd_minrad;     /*  set circle mode min_rad  */

  /***************************/
  /*  execut dynamic modyfy  */
  /***************************/
  if (ratio1 < 0) {  ratio1 *= -1;  dir_cv1 *= -1;  }
  if (ratio2 < 0) {  ratio2 *= -1;  dir_cv2 *= -1;  } 

  task = 1;                    /*  modify tangent length bar  */
  bar_control = 1;             /*  dont display leading bar   */

  ECblendcv_d(task,                        /*  dynamic work mode:            */
                                           /*  1: modify tangent length bar  */
                                           /*  2: modify by circle           */

	      bar_control,                 /*  bar display control         */
	                                   /*  0:      display leading bar */
	                                   /*  1: dont display leading bar */

              &status,                     /*  return code  */

              response,
              response_data,

              &parents[0].lc_info.module_info,
              parents[0].lc_info.located_obj,

              cont1,
              tangent_flag1,
              &ratio1,
              &par_cv1,
              &dir_cv1,
              int_cv1,
              sensi_fakt1,

              &parents[1].lc_info.module_info,
              parents[1].lc_info.located_obj,
              cont2,
              tangent_flag2,
              &ratio2,
              &par_cv2,
              &dir_cv2,
              int_cv2,
              sensi_fakt2,

              diagnos + 2*toggle_poly + 4*symmetric,
              blend_order,
              min_rad,
              rot_mat,
              disp_fakt);
  if (!(1&status))  goto wrapup;


  /*  dark draw old curve with thicker weight and style = solid  */
  sts = gr$get_symbology(object_id = blend_id,
                         symb      = &cur_symb);

  alt_symb.rgb_value = NULL;
  alt_symb.color     = NULL;
  alt_symb.style     = &cur_symb.display_attr.style;
  alt_symb.weight    = &cur_symb.display_attr.weight;

  cur_symb.display_attr.weight += 2;
  cur_symb.display_attr.style   = 0;

  sts = dp$display(msg      = &loc_msg,
                   oids     = blend_id,
                   mode     = GRbehe,
                   alt_symb = &alt_symb);


  /*  save ratios changed by dyn modify  */
  HDbd_f_p->HDbd_abs_ratio1 = ratio1;
  HDbd_f_p->HDbd_abs_ratio2 = ratio2;

  if (point1_id.located_obj.objid == point1_old  &&
      point2_id.located_obj.objid == point2_old    )
  {
    /*  --------------------------------  */ 
    /*  modify current blend values only  */
    /*  --------------------------------  */ 

    sts_m = MARK_VAL;
    loc_root_count = 0;

    /*  extract old blend curve tag  */
    om$objid_to_tag(
                    osnum = blend_id->osnum,
                    objid = blend_id->objid,
                    p_tag = &old_blend_tag);
  

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
    /*  warning: don't return buf_ptr space  */
    if(! (1 & sts)) goto wrapup;

    /*  get parameter from parent_objects  */
    parent_types[0] = EMSlcinfo;     /*  curve 1 definition     */
    parent_types[1] = EMSlcinfo;     /*  curve 2 definition     */
    parent_types[2] = EMSscalar;     /*  tangent parameter 1    */
    parent_types[3] = EMSscalar;     /*  tangent parameter 2    */
    parent_types[4] = EMSscalar;     /*  parameter blend pnt 1  */
    parent_types[5] = EMSscalar;     /*  parameter blend pnt 2  */ 
    parent_types[6] = EMSscalar;     /*  blendcurve control     */ 
    parent_types[7] = EMSlcinfo;     /*  int blend point cv1    */
    parent_types[8] = EMSlcinfo;     /*  int blend point cv2    */

    sts = om$send(msg = message EMSassoc.EMget_parent_info(
                                &loc_msg,
                                NULL,
                                NUM_PARENTS,
                                NULL,       /*  parent_info not known here  */
                                parent_types,
                                parents),
                  senderid = NULL_OBJID,
                  targetid = blend_id->objid,
                  targetos = blend_id->osnum);
    if(! (1 & sts & loc_msg)) goto wrapup;

    if (old_ratio1 != ratio1)
    {          
      /*  convert tangent 1 double to character string  */ 
      sprintf (syntax,"%g",ratio1);
      buf_ptr_w = buf_ptr + 2;             /*  skip first 2 parents  */
      sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                         exp_syntax = syntax); 
    }

    if (old_ratio2 != ratio2)
    {
      /*  convert tangent 2 double to character string  */        
      sprintf (syntax,"%g",ratio2); 
      buf_ptr_w = buf_ptr + 3;
      sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                         exp_syntax = syntax); 
    }

    if (old_par_cv1 != par_cv1)
    {
      /*  convert blend curve 1 param double to character string  */  
      sprintf (syntax,"%f",par_cv1); 
      buf_ptr_w = buf_ptr + 4; 
      sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                         exp_syntax = syntax); 
    }

    if (old_par_cv2 != par_cv2)
    {
      /*  convert blend curve 2 param double to character string  */  
      sprintf (syntax,"%f",par_cv2); 
      buf_ptr_w = buf_ptr + 5;
      sts_m = exp$modify(exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,
                         exp_syntax = syntax); 
    }

    /*  create a parametric object of the construction parameters  */
    par_control = BLEND_BIT_MODIFIED;
    if (cont1 == 2)  par_control |= BLEND_BIT_CURVATOR_1; 
    if (cont2 == 2)  par_control |= BLEND_BIT_CURVATOR_2; 
    if (dir_cv1 > 0) par_control |= BLEND_BIT_DIRECTION_1; 
    if (dir_cv2 > 0) par_control |= BLEND_BIT_DIRECTION_2; 
    if (point1_id.located_obj.objid != NULL_OBJID) par_control |= BLEND_BIT_INT_PTR_1; 
    if (point2_id.located_obj.objid != NULL_OBJID) par_control |= BLEND_BIT_INT_PTR_2; 

    if (old_par_control != par_control) 
    {
      /*  convert blend control to character string  */      
      sprintf (syntax,"%d",par_control);
      buf_ptr_w = buf_ptr + 6; 
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

    /*  -----------------------------------------------------  */ 
    /*  make new assoc blend curve with additional dependency  */
    /*  -----------------------------------------------------  */ 
    number_parents = 7;
    /*  add/modify int blend point1 id  */
    if (point1_id.located_obj.objid != NULL_OBJID)
    {
      par_control += BLEND_BIT_INT_PTR_1; 
      number_parents++;
    }

    /*  add/modify int blend point2 id  */
    if (point2_id.located_obj.objid != NULL_OBJID)
    {
      par_control += BLEND_BIT_INT_PTR_2; 
      number_parents++;
    }

    /*  Set up the construct list  */ 
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

    /*  build associative blend curve  */
    sts = ec$blend_curves( 
             msg          = &loc_msg,
             curve1       = &parents[0].lc_info,
             curve2       = &parents[1].lc_info,
             tangent_par1 = ratio1,
             tangent_par2 = ratio2,
             direction1   = dir_cv1,
             direction2   = dir_cv2,
             curvature1   = cont1,
             curvature2   = cont2,
             blend_start_par1 = par_cv1,
             blend_start_par2 = par_cv2,
             int_blend_point1 = &point1_id,
             int_blend_point2 = &point2_id,
             blend_order    = NULL,
             construct_list = &blend_cnst,
             blend_os = &new_blend_id.osnum,
             blend_id = &new_blend_id.objid ); 
    if(! (1 & sts & loc_msg)) goto wrapup;

    /*  extract new tag  */
    om$objid_to_tag(osnum = new_blend_id.osnum,
                    objid = new_blend_id.objid,
                    p_tag = new_tag); 

   
    sts = gr$delete_object(msg          = &loc_msg,
                           md_env       = NULL,      
                           object_id    = blend_id,
                           display_flag = 1);


    /* exchange blend_grid  */
    *blend_id = new_blend_id;

    /*  display new blend curve  (not done if new genrated)  */
    MAidmx(&loc_msg, loc_mx);
    loc_mx_ptr = &loc_mx;
    sts = dp$display(msg      = &loc_msg,
                     mtx_type = &loc_mx_type,
                     matrix   = &loc_mx_ptr,
                     oids     = &new_blend_id,
                     mode     = GRbd);              
    if(! (1 & sts & loc_msg)) goto wrapup;     
  }

  return status;


wrapup:
  return sts;
}





end implementation ECblendcv;

