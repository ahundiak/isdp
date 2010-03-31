
/*

Description

    This file contains method implementations and functions for
    blend curves (HDC). 
*/

class implementation ECblendcv;

#include "VCdef.h"                        /*... test ...*/

# include <math.h>

# include "bsparameters.h"
# include "bstypes.h"
# include "bserr.h"
# include "EMSmsgdef.h"
# include "exdef.h"
# include "igr.h"
# include "griodef.h"
# include "griomacros.h"
# include "dp.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"
# include "grmsg.h"
# include "emserr.h"
# include "dpmacros.h"
# include "dpezmac.h"             /* dp$inq_window */
# include "EMSasnuc.h"
# include "EMSasmacros.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "expression.h"
# include "expmacros.h"
# include "exmacros.h"         /*  ex$wait..  */
# include "ASmsg.h"
# include "ECcmd.h"
# include "ECmsg.h"
# include "ecblc_macros.h"
# include "execmsg.h"       
# include "EMS.h"
# include "parametric.h"
# include "nddef.h"
# include "emsdef.h"                  
# include "EMSblend_cv.h"         
# include "ecblc_for.h"         
# include "ecblc_bitcod.h" 

        


/*  prototypes  */

# include "bscveval.h"       /*  function prototype  */
# include "bsnorvec.h"       /*  function prototype  */
# include "bsmdstptcv.h"     /*  function prototype  */

# include "emblendcv.h"      /*  proto type  */
# include "ecblc_mod.h"      /*  proto type  */



struct ext_pnt_info
{
    struct GRlc_info    base_crv;        /*  base curve main info            */
    struct GRlc_info    ib_pnt;          /*  internal blend start/end point  */
};



extern OMuword  OPP_GRcurve_class_id;
extern OMuword  OPP_EMSsubbs_class_id;
extern OMuword  OPP_GRpoint_class_id;
extern OMuword  OPP_GAbcsubbc_class_id;
extern OMuword  OPP_SKmgr_class_id; 
extern OMuword  OPP_EMSsurface_class_id;
extern OMuword  OPP_EMSplane_class_id;
extern OMuword  OPP_GRbcsubbc_class_id;
extern OMuword  OPP_EMSagrp_class_id;


extern IGRint  locate_N_Point();


from EMSassoc  import EMget_parent_info;

from GRvg      import GRgetsize,
                      GRgetgeom,
                      GRconstruct; 

from GRvg      import GRgetattr,
                      GRputattr; 

from NDnode    import NDget_objects; 


# define MAX(x,y)    ((x) < (y) ? (y) :(x))
# define MIN(x,y)    ((x) < (y) ? (x) :(y))
# define ABS(x)      ((x) < 0 ? -(x) : (x))

#define VCdebug_return   1                  /*... test ...*/

#define END_BY_MOVEON    3
#define END_BY_CMD       5

#define NEW_MODY         1                  /*  control */


# define NUM_PARENTS         9               /*  max number parents  */
# define TANGENT_MODE        3               /*  current used tangent mode  */

# define DUMMY_SIZE             64


/* text for prompts and other messages */

/*                            "Place Blend between 2 curves"  */
#define COMMAND_TEXT          EM_M_PlBl2Cr

/*                            "Idendify curve 1"  */
#define LOCATE_PROMPT_1       EMS_P_Id_Cu_1 

/*                            "Idendify curve 1/Option Form to modify"  */
#define LOCATE_PROMPT_1C      EMS_P_Id_Cu_1__Op_Fo_Mo           

/*                            "Idendify curve 2"  */
#define LOCATE_PROMPT_2S      EMS_P_Id_Cu_2

/*                            "Idendify curve 2/Move on to modify this curve" */
#define LOCATE_PROMPT_2M      EMS_P_Id_Cu_2__MoOn_Mo_Cu         

/*                            "No element(s) found"  */
#define RELOCATE_PROMPT       EMS_P_TE_NoElFo

/*                            "Accept/Reject"  */
#define ACCEPT_PROMPT         GR_P_Acc

/*                            "No blend possible"  */    
#define ERROR_MESSAGE_NOINT   EMS_I_No_Bl_Po
 
/*                            "Select Options / Exit to modify"  */
#define SEL_OPT_EXIT          EMS_P_Se_Op__Ex_Mo   
             
/*                            "Warning:  No modify if non-associative"  */
#define NO_MODIFY             EMS_S_Warn_No_Mo_No_As     
 

static IGRdouble base_ratio1, base_ratio2;   /* last used ratios at gen.  */ 





/*
Name

    BL_locateCrv

Abstract

    This is a static function used to perform locate for this command.

Synopsis

    static long BL_locateCrv(msg, index, locate_event, accept_event,
                             response, response_data, wrk_classid)

    IGRlong         *msg;               return code from lc$locate
    IGRint          index;              text index
    struct GRevent  *locate_event;      locate event structure
    struct GRevent  *accept_event;      accept event structure
    IGRint          *response;          response
    IGRchar         *response_data;     response data
    OMuword         *wrk_classid;       classid of selected curve

Description

    This function sets up the locate arguments, including state-specific
    arguments (such as the prompts), and calls lc$locate.

Return Value

    Returns the results of lc$locate (see lcdef.h), or OM_E_ABORT if the
    state is not a locate state.

Notes

    This function exists for the purpose of making the execute method
    more readable.

History

    03 Sep 93   AIC     Creation
*/

static IGRlong BL_locateCrv(msg, index, locate_event, accept_event,
                           response, response_data, wrk_classid)

IGRlong         *msg;
IGRint          index;
struct GRevent  *locate_event;
struct GRevent  *accept_event;
IGRint          *response;
IGRchar         *response_data;
OMuword         *wrk_classid;   
                           
{

  IGRlong               sts = OM_S_SUCCESS;
  IGRint                locate_key;

  struct GRlc_locate    attributes;
  struct GRlc_stack     stack;
  OM_S_CLASSLIST        rtree_classes, eligible_classes;
  OMuword               n_classes[4];
  IGRint                msk1, msk2;



  /*  Initialize the locate input structures  */
 
  stack.num_entries    = 0;          /*  reset stack counter  */
  stack.number_located = 0;          /*  reset stack counter  */
  attributes.properties =
                    LC_LC_ONLY       /*  locate locatable objects   */
                  | LC_RW            /*  locate readable/writable objects  */
                  | LC_DP_ONLY;      /*  locate displayable objects  */

  attributes.owner_action =
               LC_FLEX_COMP            /*  locate flexible components  */
             | LC_RIGID_COMP           /*  locate rigid components  */
             | LC_REF_OBJECTS          /*  Objects in ref. files are allowed  */
             | LC_ASSOCIATIVE          /*  associative elements  */
             | LC_EXTERN_CONSTRAINED;  /*  extern constrained assoc elements  */

  rtree_classes.w_count = eligible_classes.w_count = 1;
  rtree_classes.w_flags = eligible_classes.w_flags = OM_CLST_subclass;

 
  /*  Initialize the element-specific info in the locate input structures.  */
  locate_key = LOCATE_PROMPT_1;                       /*  index: 0  */
  if (index <  0)  locate_key = SEL_OPT_EXIT;              
  if (index == 1)  locate_key = LOCATE_PROMPT_1C;
  if (index == 2)  locate_key = LOCATE_PROMPT_2S;
  if (index == 3)  locate_key = LOCATE_PROMPT_2M;

  rtree_classes.p_classes = &OPP_GRcurve_class_id;
  /*  set not eligible class list  */
  eligible_classes.w_flags = OM_CLST_subclass | OM_CLST_negation;
  eligible_classes.p_classes = n_classes;        
                               n_classes[0] = OPP_GRpoint_class_id;
                               n_classes[1] = OPP_EMSsurface_class_id;
                               n_classes[2] = OPP_SKmgr_class_id;
                               n_classes[3] = OPP_EMSagrp_class_id;
  eligible_classes.w_count = 4;

  msk1 = GRm_DATA | GRm_BACK_UP | GRm_MOVE_ON | GRm_RJT_MOVEON;
 
  if (index == 1 || index < 0)  msk1 |= GRm_FORM_FINISHED;

  msk2 = GRm_DATA | GRm_BACK_UP | GRm_MOVE_ON | GRm_RESET;

  /*  Perform locate  */
  sts = lc$locate(rc = msg,
                  event1 = locate_event,
                  mask1 = msk1,
                  event2 = accept_event,
                  mask2 = msk2,
                  response = response,            
                  response_data = response_data,  
                  locate_key = locate_key,
                  relocate_key = GR_I_EleNotFound,
                  acc_key = GR_P_Acc,
                  attributes = &attributes,
                  stack = &stack,
                  display_flag =   ELEM_HILIGHT 
                                 | LC_ACC_ONE_ELEMENT 
                                 | LC_ERASE_LOC_ELEMENT,
                  eligible_classes = &eligible_classes,
                  rtree_classes = &rtree_classes);

  if (accept_event[0].response == EX_DATA)
  {
    /*  extract element class_id  */
    sts = om$get_classid(
          objid     = accept_event[0].located_object[0].located_obj.objid,
          osnum     = accept_event[0].located_object[0].located_obj.osnum,
          p_classid = wrk_classid);
  }

  return sts;
}






/*
Name

    Blend_getval

Abstract

    This is a static function used to perform numeric input for this command.

Synopsis


    IGRlong Blend_ext_p (msg, parents_base, parents_point, par_proj) 

 IGRlong                *msg;              return code
 struct EMSobject_info  *parents_base;     base curve assoc info
 struct EMSobject_info  *parents_point;    assoc point info
 IGRdouble              *par_proj;         parameter of assoc point on base curve

    

Description

    This function calculates the projetion point parameter of the assoc point
    on the base curve.

Return Value

    par_proj          parameter of the projected point on curve

Notes

    This function exists for the purpose of making the test of execute method
    more readable.

History

    18 Apr 94   HOB     Creation
*/


 IGRlong Blend_ext_p (msg, parents_base, parents_point, par_proj) 

 IGRlong                *msg;
 struct EMSobject_info  *parents_base;
 struct EMSobject_info  *parents_point;
 IGRdouble              *par_proj;

 {   
   IGRlong               sts = OM_S_SUCCESS;
   IGRlong               loc_msg;
   BSrc                  rc; 

   struct IGRbsp_curve   *curve;
   struct IGRbsp_curve   *curve_p;

   IGRpoint              proj_pnt; 
   IGRpoint              base;                  /*  dummy  */
   IGRdouble             dist;                  /*  min distance - unused  */
   IGRlong               num_bytes;             /*  size of base curve     */
   IGRlong               i;



    *msg = FALSE;
    curve = curve_p = NULL;

    /*  get existing base curve  */ 
    sts = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetsize (
                                  &loc_msg,
                                  &parents_base->env.md_env.matrix_type,
                                  parents_base->env.md_env.matrix,
                                  &num_bytes ),
                  senderid = NULL,
                  targetid = parents_base->grid.objid,
                  targetos = parents_base->grid.osnum);
    if (!(1 & sts & loc_msg)) Goto (wrapup);

    curve = (struct IGRbsp_curve *) malloc(num_bytes);
    if (!curve)  Goto (wrapup);

    sts = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetgeom (
                                   &loc_msg,
                                   &parents_base->env.md_env.matrix_type, 
                                   parents_base->env.md_env.matrix, 
                                   (IGRchar *) curve ),
                  senderid = NULL,
                  targetid = parents_base->grid.objid,
                  targetos = parents_base->grid.osnum);
    if (!(1 & sts & loc_msg)) Goto (wrapup);

    /*  get existing point  */ 
    sts = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetsize (
                                &loc_msg,
                                &parents_point->env.md_env.matrix_type, 
			         parents_point->env.md_env.matrix,
                                &num_bytes),
                  senderid = NULL,
                  targetid = parents_point->grid.objid,
                  targetos = parents_point->grid.osnum);
     if (!(1 & sts & loc_msg)) Goto (wrapup);

     curve_p = (struct IGRbsp_curve *) malloc(num_bytes); 
     if (!curve_p)  Goto (wrapup); 

     sts = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRgetgeom (
                                   &loc_msg,
                                   &parents_point->env.md_env.matrix_type, 
                                   parents_point->env.md_env.matrix, 
                                   (IGRchar *) curve_p ),
                   senderid = NULL,
                   targetid = parents_point->grid.objid,
                   targetos = parents_point->grid.osnum);
    if (!(1 & sts & loc_msg)) Goto (wrapup);

    for (i=0; i<3; i++)
      proj_pnt[i] = curve_p->poles[i];

    /*  project point on base curve  */
    BSmdstptcv(curve, proj_pnt, par_proj, base, &dist, &rc);
    if (BSERROR(rc))  Goto (wrapup);

    
    /*  return space  */
    if (curve)    free(curve);
    if (curve_p)  free(curve_p);
    *msg = TRUE;
    return TRUE;

wrapup: 
    if (curve)    free(curve);
    if (curve_p)  free(curve_p);
    *msg = FALSE;
    return FALSE;
}




/*
Name

    method init

Abstract

    This is the init method for the command ECblendcv.

Synopsis

    method init()


Description

    This method presets the initial values.

Return Value

    OM_S_SUCCESS

Notes

    

Index

Keywords

History

    22 Sep 93   HOB     Creation
*/
method init(int type;char *str_ptr)
{


  /*
   * preset for first entry 
   */
  me->bl_cv_control = NULL;
  me->last_curve_1     = NULL_OBJID;
  me->last_curve_2     = NULL_OBJID;
  me->blend_grid.objid = NULL_OBJID;
  me->blend_grid.osnum = NULL;
  me->first_cv_classid = NULL;
  me->blend_tag = NULL;
  me->internal_1_mode  = FALSE;
  me->internal_2_mode  = FALSE;
  me->modify = FALSE;
  me->last_modify_sts = NULL;
  me->b_start_cond.curve = NULL;
  me->b_ende_cond.curve  = NULL; 
  /* preset the modify values */

  me->HDbd_f_par.HDbd_crv1point  = 
  me->HDbd_f_par.HDbd_crv2point  = TRUE;
  me->HDbd_f_par.HDbd_crv1exip   =
  me->HDbd_f_par.HDbd_crv2exip   = 0;
  me->HDbd_f_par.HDbd_crv1_cont  = 
  me->HDbd_f_par.HDbd_crv2_cont  = FALSE;
  me->HDbd_f_par.HDbd_undolm     = FALSE;
  me->HDbd_f_par.HDbd_undo       = FALSE;
  me->HDbd_f_par.HDbd_mode       = 1;
  me->HDbd_f_par.HDbd_diagnos    = FALSE;
  me->HDbd_f_par.HDbd_toggle_pol = FALSE;
  me->HDbd_f_par.HDbd_symmetric  = FALSE;

  me->HDbd_f_par.HDbd_crv1sens =
  me->HDbd_f_par.HDbd_crv2sens = 1.0;
  me->HDbd_f_par.HDbd_abs_ratio1 =
  me->HDbd_f_par.HDbd_abs_ratio2 = 1.0;
  me->HDbd_f_par.HDbd_minrad   = 0.1;

  /*  fill form function with actual form values  */ 
  HDbd_cp_f_data(0, &me->HDbd_f_par);

  /*  reset color of option icon  */
  GRstatus_display_button(FALSE);

/*
wrapup:

*/
  return OM_S_SUCCESS;
}




/*
Name

    method execute

Abstract

    This is the execute method for the command ECblendcv

Synopsis

    method execute(IGRint *response; IGRchar *response_data; IGRint pos)

    response        - response from last event when command returns
                      control to command services

    response_data   - response data from last event when command returns
                      control to command services

    pos             - unused

Description

    This method gathers the user's input and calls the macro
    ec$blend_curves.

Return Value

    OM_S_SUCCESS

Notes

    Event handling is not done well.

Index

Keywords

History

    03 Sep 93    AIC     Creation
*/
method execute(IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRlong     sts       = OM_S_SUCCESS;
  IGRlong     loc_msg   = EMS_S_Success;
  IGRlong     blend_msg = EMS_S_Success;
  IGRlong     sts_m;
  IGRlong     num_bytes;             /*  size of base curve     */

  IGRint      cont = 1;
  IGRint      txt_index;
  IGRint      loc_index;
  OMuword     wrk_classid;
  IGRint      event_msk; 

  IGRdouble   rot_matrix[16];     /*  first loc. view rotation matrix       */
  IGRdouble   mat_wtv[16];        /*  first loc. view world to view matrix  */
  IGRpoint    origin_point;
  IGRdouble   vwvolume[6];
  IGRdouble   epsw = 0.001;       /*  for view usage only            */

  IGRint      i, j, k, l;         /*  loop counter  */

  struct IGRdisplay     blend_dis;
  struct GRmd_env       blend_env;  
  struct GRvg_construct blend_cnst;
  struct GRmd_env       int_module_info;

  struct GRlc_info      info_curve1,            /*  objid basic curve 1  */
                        info_curve2;            /*  objid basic curve 2  */

  struct IGRbsp_curve   *curve;

  IGRdouble  b_start_par1,       /*  select for dir parameter on curve1   */
             b_start_par2;       /*  select for dir parameter on curve2   */

  IGRdouble  int_cv1,            /*  blend start parameter on curve1      */
             int_cv2;            /*  blend start parameter on curve2      */

  struct GRlc_info blend_point1,      /*  internal blendpoint cv1  */ 
                   blend_point2;      /*  internal blendpoint cv2  */
                                      /*  none  = NULL_OBJID       */

  struct GRevent   locate_event;
  struct GRevent   accept_event;


#define INIT                            0
#define LOCATE_1                 INIT + 1
#define LOCATE_2             LOCATE_1 + 1     
#define GENERATE             LOCATE_2 + 1
#define EXT_MODIFY           GENERATE + 1
#define DISP_FORM          EXT_MODIFY + 1
#define WAIT_FORM           DISP_FORM + 1
#define MODIFY_FORM         WAIT_FORM + 1
#define MODIFY_NO_FORM    MODIFY_FORM + 1




  GRstatus_display_button(TRUE);      /*  set color of option icon  */

  while (cont)
  {
    switch(me->state)

    {
      case INIT:
      {
        me->global_assoc_flag = NULL;
        me->bl_cv_control = NULL;
        if (me->blend_grid.objid == NULL_OBJID)
        {
          me->HDbd_f_par.HDbd_crv1exip =
          me->HDbd_f_par.HDbd_crv2exip = NULL;
        }
        me->state = LOCATE_1;
      }
      case LOCATE_1:
      case LOCATE_2:
      {
        /* ------------------------------------------------------- */
        /*     L O C A T E   B A S I C   C U R V E S               */
        /* ------------------------------------------------------- */

        if (me->state <= LOCATE_1)
        {
          if (me->blend_grid.objid == NULL_OBJID)  txt_index = 0;
          else                                     txt_index = 1;
          /*  get associative lock state  */
          gr$get_associative_flag(msg    = &loc_msg,
                                  buffer = &me->global_assoc_flag);
          if (!me->global_assoc_flag)
          {
            txt_index = 0;   /* no modify if not assoc */
            /*  tell user that mo modify in non assoc mode  */
            sts = ex$message(msgnumb = NO_MODIFY,
                             field   = ERROR_FIELD);
          } 
        }
        else
        {
          if (me->first_cv_classid != OPP_GAbcsubbc_class_id)  txt_index = 2;
          else                                                 txt_index = 3;
          if (!me->global_assoc_flag)  txt_index = 2;   /* no modify if not assoc */ 
        }
        if (me->modify)  txt_index = -1;   /*  no real locate if modify  */
        if (me->state <= LOCATE_1)  loc_index = 0;
        else                        loc_index = 1;
        /*  Locate the object  */
        sts = BL_locateCrv(&loc_msg, txt_index,
                           &me->locate_event[loc_index],
                           &me->accept_event[loc_index],
                           response,
                           response_data,
                           &wrk_classid);
        if (!(1 & sts)) Goto (wrapup);

        /*  Highlight the located object (if one was located)  */
        if (loc_msg)
        {
          IGRlong     loc_mx_type;
          IGRmatrix   *loc_mx_ptr;

          loc_mx_type = (IGRlong) me->accept_event[loc_index].located_object[0]
                                       .module_info.md_env.matrix_type;
          loc_mx_ptr = &me->accept_event[loc_index].located_object[0].
                               module_info.md_env.matrix; 
          sts = dp$display(msg = &loc_msg,
                           mtx_type = &loc_mx_type,
                           matrix = &loc_mx_ptr,
                           oids = &me->accept_event[loc_index].
                                           located_object[0].located_obj,
                           mode = GRhd); 
          if (!(1 & sts & loc_msg)) Goto (wrapup);
        }
        else  loc_msg = EMS_S_Success; /* Reset loc_msg */

        /*
         * Set state based on response:
         *  EX_VALUE: go to the next state
         *  EX_BACK_UP (except initial state): go to last state
         * If the accept event is unknown, the locate event is checked.
         */
        if (me->locate_event[loc_index].response == EX_RJT_MOVEON)
        {
          if (me->state == LOCATE_2 
           && me->first_cv_classid == OPP_GAbcsubbc_class_id
           && me->global_assoc_flag                          )
          {
            me->blend_grid = me->accept_event[0].located_object[0].located_obj;
            me->state = EXT_MODIFY;     /*  = external modify entry  */
            break;
          }
          else
          {
            /*  is not a associative blend curve class  */
            break;
          }
        }  
        if (me->accept_event[loc_index].response == EX_DATA)
        {
          if (me->state == LOCATE_1)
          {
            if (me->bl_cv_control == NULL)
            {
              me->HDbd_f_par.HDbd_crv1exip = 
              me->HDbd_f_par.HDbd_crv2exip = NULL;
              me->HDbd_f_par.HDbd_abs_ratio1 =
              me->HDbd_f_par.HDbd_abs_ratio2 = 1.0;
              me->HDbd_f_par.HDbd_diagnos    = FALSE;
              me->HDbd_f_par.HDbd_toggle_pol = FALSE;
              me->HDbd_f_par.HDbd_symmetric  = FALSE;
              /*  fill form function with actual form values  */ 
              HDbd_cp_f_data(0, &me->HDbd_f_par);
            }
            me->first_cv_classid = wrk_classid;
            me->blend_grid.objid = NULL_OBJID;
            me->modify = FALSE;
            if (me->HDbd_f_par.HDbd_crv1exip >= 2) me->HDbd_f_par.HDbd_crv1exip = 4; 
            if (me->HDbd_f_par.HDbd_crv2exip >= 2) me->HDbd_f_par.HDbd_crv2exip = 4; 
            if (me->b_start_cond.curve) 
               { free(me->b_start_cond.curve); me->b_start_cond.curve = NULL; }

            if (me->b_ende_cond.curve)
               { free(me->b_ende_cond.curve);  me->b_ende_cond.curve  = NULL; }
            sts_m = NULL;

            /*  get current window info  */
            dp$inq_window_info( msg = &loc_msg,
                              osnum = me->accept_event[0].event.button.osnum,
                       window_objid = me->accept_event[0].event.button.objid,
                        view_origin = &origin_point,
                          vw_volume = vwvolume,
                      view_rotation = &rot_matrix,
                      world_to_view = &mat_wtv);

            /*  copy significant members for rotation matrix  */
            for (k=0, j=0, l=0; j < 3; j++)
            {    
              for (i = 0; i < 3; i++)                
                me->rot_mat[l++] = rot_matrix[k+i];
              k = k + 4;
            }

            epsw = 0.001;
            /*  calculate work view zoom faktor  */
            if (ABS(rot_matrix[0]) > epsw) me->disp_fakt = mat_wtv[0] / rot_matrix[0];
            else
            if (ABS(rot_matrix[1]) > epsw) me->disp_fakt = mat_wtv[1] / rot_matrix[1];
            else                           me->disp_fakt = mat_wtv[2] / rot_matrix[2];
          }
          me->state++;
        }

        else

        if (me->state && me->accept_event[loc_index].response
                                                            == EX_BACK_UP)
        {
          /*  Erase the located elements  */ 
          dp$erase_hilite(msg = &loc_msg);
          me->state--;
        }

        else

        if (me->accept_event[loc_index].response == EX_FORM_FINISHED
            && me->state == LOCATE_1)
        {
          me->state = MODIFY_FORM;
          break;
        }

        else
 
        if (me->accept_event[loc_index].response == GR_UNKNOWN_TYPE)
          {
            /*  let command server handle it  */
            return( OM_S_SUCCESS );
          }

        }
        break;



      case GENERATE:
      {
        /*  Erase the located elements  */ 
        dp$erase_hilite(msg = &loc_msg);
        ex$message(msgnumb = GR_I_Processing);

                info_curve1 = me->accept_event[0].located_object[0];
                info_curve2 = me->accept_event[1].located_object[0];

        /*  get actual form data  */
        HDbd_cp_f_data(1, &me->HDbd_f_par);

        me->first_cv_classid = NULL;
        me->last_curve_1 = me->accept_event[0].located_object[0].located_obj.objid;
        me->last_curve_2 = me->accept_event[1].located_object[0].located_obj.objid;
      
        b_start_par1 = me->accept_event[0].located_object[0].geom_parms.u;
        if (!me->internal_1_mode)  sts = modf(b_start_par1+0.5, &b_start_par1);
        b_start_par2 = me->accept_event[1].located_object[0].geom_parms.u;
        if (!me->internal_2_mode)  sts = modf(b_start_par2+0.5, &b_start_par2);

        blend_point1.located_obj.objid = NULL_OBJID;
        blend_point2.located_obj.objid = NULL_OBJID;

        int_cv1 = b_start_par1;
        int_cv2 = b_start_par2;

        /*  observe current modals  */
        if (me->HDbd_f_par.HDbd_crv1exip)
        {
          if (me->HDbd_f_par.HDbd_crv1exip > 2)  
          {
            /*  Locate the object  */
            sts = locate_N_Point(&loc_msg,
                                 0,                   /*  select point 1  */
                                 &info_curve1.located_obj,
                                 &int_module_info,
                                 &locate_event,
                                 &accept_event,
                                 response,               
                                 response_data,
                                 &int_cv1);
            if(! (1 & sts)) goto wrapup;

            if (accept_event.response == EX_BACK_UP)  goto wrapup;   
            if (accept_event.response == GR_UNKNOWN_TYPE) 
            {
              me->state = LOCATE_1;  
              break;
            }
            /*  save point1 object id  */
            blend_point1        =
            me->ext_pnt1.ib_pnt = accept_event.located_object[0];
            me->b_start_cond.blend_pt_par = int_cv1;
            me->HDbd_f_par.HDbd_crv1exip = 2;
          }
        }

        if (me->HDbd_f_par.HDbd_crv2exip)
        {
          if (me->HDbd_f_par.HDbd_crv2exip > 2)  
          {
            /*  Locate the object  */
            sts = locate_N_Point(&loc_msg,
                                 1,                   /*  select point 2  */
                                 &info_curve2.located_obj,
                                 &int_module_info,
                                 &locate_event,
                                 &accept_event,
                                 response,               
                                 response_data,
                                 &int_cv2);
            if(! (1 & sts)) goto wrapup;

            if (accept_event.response == EX_BACK_UP)  goto wrapup;   
            if (accept_event.response == GR_UNKNOWN_TYPE) 
            {
              me->state = LOCATE_1;  
              break;
            }
            /*  save point2 object id  */
            blend_point2        =
            me->ext_pnt2.ib_pnt = accept_event.located_object[0];
            me->b_ende_cond.blend_pt_par = int_cv2;
            me->HDbd_f_par.HDbd_crv2exip = 2;
          }
        }

        /*  Set up the construct list  */ 
        blend_cnst.msg        = &blend_msg;
        blend_cnst.env_info   = &blend_env;
        blend_cnst.newflag    = FALSE;
        blend_cnst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        blend_cnst.geometry   = NULL;       
        blend_cnst.display    = &blend_dis;
        blend_cnst.class_attr = NULL;
        blend_cnst.name       = NULL;


        sts = gr$get_active_layer  (msg = &blend_msg, buffer = &blend_cnst.level);
        sts = gr$get_module_env    (msg = &blend_msg, buffer = &blend_env);
        sts = gr$get_active_display(msg = &blend_msg, buffer = &blend_dis);

        /*  build associative blend curve  */
        sts = ec$blend_curves( 
                  msg       = &loc_msg,
                  curve1    = &info_curve1,
                  curve2    = &info_curve2,
                  tangent_par1 = -1,
                  tangent_par2 = -1,
                  direction1 = 2*b_start_par1 - 1,
                  direction2 = 2*b_start_par2 - 1,
                  curvature1 = me->HDbd_f_par.HDbd_crv1_cont + 1,
                  curvature2 = me->HDbd_f_par.HDbd_crv2_cont + 1,
                  blend_start_par1 = int_cv1,
                  blend_start_par2 = int_cv2,
                  int_blend_point1 = &blend_point1,
                  int_blend_point2 = &blend_point2,
                  blend_order = NULL,
                  construct_list = &blend_cnst,
                  blend_os  = &me->blend_grid.osnum,
                  blend_id  = &me->blend_grid.objid);  

        if (!(1 & sts & loc_msg))
        {
          sts = ex$message(msgnumb = ERROR_MESSAGE_NOINT,
                           field   = ERROR_FIELD);

          goto wrapup;
        }

        om$objid_to_tag(osnum = me->blend_grid.osnum, 
                        objid = me->blend_grid.objid,
                        p_tag = &me->blend_tag);

        /*  (should this get the local environment?)  */

        {
          IGRlong     loc_mx_type = MAIDMX;
          IGRmatrix   loc_mx, *loc_mx_ptr;

          MAidmx(&loc_msg, loc_mx);
          loc_mx_ptr = &loc_mx;

          sts = dp$display(msg = &loc_msg,
                           mtx_type = &loc_mx_type,
                           matrix = &loc_mx_ptr,
                           oids = &me->blend_grid,
                           mode = GRbd);
          if (!(1 & sts & loc_msg)) Goto (wrapup);
        }

        /* ---------------------- */
        /*  new blend curve done  */
        /* ---------------------- */


        /*  save basic curves info  */
        me->ext_pnt1.base_crv = me->accept_event[0].located_object[0];
        me->ext_pnt2.base_crv = me->accept_event[1].located_object[0];

        /*  preset form with last used values  */
        me->HDbd_f_par.HDbd_abs_ratio1 = ABS(base_ratio1);
        me->HDbd_f_par.HDbd_abs_ratio2 = ABS(base_ratio2);

        /*  fill form function with actual form values  */ 
        HDbd_cp_f_data(0, &me->HDbd_f_par);

        /*  reset processing info message   */
        sts = ex$message ( msgnumb = EMS_I_ClearStatusField);

        /*  get associative lock state  */
        gr$get_associative_flag(msg    = &loc_msg,
                                buffer = &me->global_assoc_flag);
        if (!me->global_assoc_flag)
        {
           sts = HDbd_display_status_form(FALSE); 
           me->state = INIT;  
           break;
        }

        if (NEW_MODY & me->bl_cv_control)   me->state = MODIFY_NO_FORM;  
        else                            me->state = INIT;  
      }
      break;


      case EXT_MODIFY:
      {  
        /* ------------------------------------------------------- */
        /*     E X T E R N A L  B L E N D   M O D I F Y            */
        /* ------------------------------------------------------- */
  
        struct GRmd_env     blend_env;  
        struct GRevent      param_event; 
        struct GRid         cur_blend;
        OMuint              new_tag;


        me->modify = TRUE;
        cur_blend = me->blend_grid;
        sts = gr$get_module_env  (msg = &loc_msg, buffer = &blend_env);

        /*  first call to read all assoc data in  */ 
        me->b_start_cond.curve = NULL;   /*  force basic read  */
        me->b_ende_cond.curve  = NULL;   /*  force basic read  */

        /*  call modify module */
        sts = ECblendcv_m(&loc_msg, &me->blend_grid, &me->HDbd_f_par,
                          response, response_data,
                          &me->b_start_cond, &me->b_ende_cond,
                          &me->ext_pnt1, &me->ext_pnt2,
                          &me->rot_mat[0], &me->disp_fakt,  
                          &new_tag);

        om$objid_to_tag(osnum = me->blend_grid.osnum, 
                        objid = me->blend_grid.objid,
                        p_tag = &me->blend_tag); 

        /*  preset form with last used values  */
        me->HDbd_f_par.HDbd_abs_ratio1 = ABS(me->b_start_cond.tangent_value);
        me->HDbd_f_par.HDbd_abs_ratio2 = ABS(me->b_ende_cond.tangent_value);
        if (me->b_start_cond.blend_pt_par > 0.0 && me->b_start_cond.blend_pt_par < 1.0)
        {
          if (me->ext_pnt1.ib_pnt.located_obj.objid == NULL)
                        me->HDbd_f_par.HDbd_crv1exip = 1;
          else          me->HDbd_f_par.HDbd_crv1exip = 2;
        }
        else
        {
          me->HDbd_f_par.HDbd_crv1exip = 0;
        }

        if (me->b_ende_cond.blend_pt_par > 0.0 && me->b_ende_cond.blend_pt_par < 1.0)
        {
          if (me->ext_pnt2.ib_pnt.located_obj.objid == NULL)
                        me->HDbd_f_par.HDbd_crv2exip = 1;
          else          me->HDbd_f_par.HDbd_crv2exip = 2;
        }
        else
        {
          me->HDbd_f_par.HDbd_crv2exip = 0;
        }

        me->HDbd_f_par.HDbd_crv1_cont = me->b_start_cond.curvature;
        me->HDbd_f_par.HDbd_crv2_cont = me->b_ende_cond.curvature;

        /* preset the modify values */
        me->HDbd_f_par.HDbd_undolm    = FALSE;
        me->HDbd_f_par.HDbd_undo      = FALSE;
        me->HDbd_f_par.HDbd_mode      = 1;
        me->HDbd_f_par.HDbd_diagnos   = FALSE;

        me->HDbd_f_par.HDbd_crv1sens = 1.0;
        me->HDbd_f_par.HDbd_crv2sens = 1.0;
        me->HDbd_f_par.HDbd_minrad   = 0.1;

        me->state = DISP_FORM;
        break;



    case DISP_FORM:
        /*  fill form function with actual form values  */ 
        HDbd_cp_f_data(0, &me->HDbd_f_par);

        /*  display option form */
        sts = HDbd_display_status_form(TRUE); 
        me->state = WAIT_FORM;
        break;



     case WAIT_FORM:
       event_msk = GRm_FORM_FINISHED;
       sts = co$getevent(msg           = &loc_msg,
                         event_mask    = event_msk,
                         msgnum        = SEL_OPT_EXIT,
                         response      = response,
                         response_data = response_data,    
                         event         = &param_event);
            
        if (*response == EX_FORM_FINISHED || param_event.response == EX_FORM_FINISHED)
           me->state = MODIFY_FORM;     /* go on;  */
        break;



      case MODIFY_FORM:
      case MODIFY_NO_FORM:
        /* ------------------------------------------------------- */
        /*      B L E N D   M O D I F Y                            */
        /* ------------------------------------------------------- */

        me->modify = TRUE; 
        GRstatus_display_button(TRUE);
        me->bl_cv_control = (!NEW_MODY) & me->bl_cv_control;  

        /*  reset message  */
        sts = ex$message (msgnumb = EMS_I_ClearStatusField);

        if (me->state == MODIFY_FORM)
        {
          /*  get actual form data  */
          HDbd_cp_f_data(1, &me->HDbd_f_par);

          if (!me->HDbd_f_par.HDbd_accept)
          {
            me->state = INIT;  
            me->modify = FALSE;
            break;
          }
        }

        if (!me->b_start_cond.curve)
        {
          /*  get existing base curve  */ 
          sts = om$send(mode = OM_e_wrt_object,
                        msg  = message GRvg.GRgetsize (
                               &loc_msg,
                               &me->ext_pnt1.base_crv.module_info.md_env.matrix_type, 
                               me->ext_pnt1.base_crv.module_info.md_env.matrix,
                               &num_bytes ),
                       senderid = NULL,
                       targetid = me->ext_pnt1.base_crv.located_obj.objid,
                       targetos = me->ext_pnt1.base_crv.located_obj.osnum);
          if (!(1 & sts & loc_msg)) Goto (wrapup);

          curve = (struct IGRbsp_curve *) malloc(num_bytes);
          if (!curve)  Goto (wrapup);

          sts = om$send(mode = OM_e_wrt_object,
                        msg = message GRvg.GRgetgeom (
                              &loc_msg,
                              &me->ext_pnt1.base_crv.module_info.md_env.matrix_type, 
                              me->ext_pnt1.base_crv.module_info.md_env.matrix,
                              (IGRchar *) curve ),
                        senderid = NULL,
                        targetid = me->ext_pnt1.base_crv.located_obj.objid,
                        targetos = me->ext_pnt1.base_crv.located_obj.osnum);
          if (!(1 & sts & loc_msg)) Goto (wrapup);
          me->b_start_cond.curve = curve; 
        }

        if (!me->b_ende_cond.curve)
        { 
          /*  get existing base curve  */ 
          sts = om$send(mode = OM_e_wrt_object,
                        msg = message GRvg.GRgetsize (
                              &loc_msg,
                              &me->ext_pnt2.base_crv.module_info.md_env.matrix_type, 
                              me->ext_pnt2.base_crv.module_info.md_env.matrix,
                              &num_bytes ),
                        senderid = NULL,
                        targetid = me->ext_pnt2.base_crv.located_obj.objid,
                        targetos = me->ext_pnt2.base_crv.located_obj.osnum);
          if (!(1 & sts & loc_msg)) Goto (wrapup);
          curve = (struct IGRbsp_curve *) malloc(num_bytes);
          if (!curve)  Goto (wrapup);

          sts = om$send(mode = OM_e_wrt_object,
                         msg  = message GRvg.GRgetgeom (
                                &loc_msg,
                                &me->ext_pnt2.base_crv.module_info.md_env.matrix_type, 
                                me->ext_pnt2.base_crv.module_info.md_env.matrix,
                                (IGRchar *) curve ),
                         senderid = NULL,
                         targetid = me->ext_pnt2.base_crv.located_obj.objid,
                         targetos = me->ext_pnt2.base_crv.located_obj.osnum);
          if (!(1 & sts & loc_msg)) Goto (wrapup);
          me->b_ende_cond.curve = curve; 
        }

        /*  extract objid from blend tag  */
        om$tag_to_objid(osnum   = me->blend_grid.osnum,
                        tag     = me->blend_tag , 
                        p_objid = &me->blend_grid.objid);

        sts_m = ECblendcv_m(&loc_msg, &me->blend_grid, &me->HDbd_f_par,
                            response, response_data,
                            &me->b_start_cond, &me->b_ende_cond,
                            &me->ext_pnt1, &me->ext_pnt2,
                            &me->rot_mat[0], &me->disp_fakt,  
                            &new_tag);

        if (me->HDbd_f_par.HDbd_crv1exip > 2) me->HDbd_f_par.HDbd_crv1exip = 2;
        if (me->HDbd_f_par.HDbd_crv2exip > 2) me->HDbd_f_par.HDbd_crv2exip = 2;
        me->last_modify_sts = sts_m;

        if (!(1 & sts_m & loc_msg))
        {
          me->modify = FALSE;
          me->state = INIT;  
          Goto (wrapup);  
        } 

        if (me->blend_grid.objid == NULL)
        {
          /*  modify was UNDO ---> delete  */
          me->modify = FALSE;
          me->state = INIT;
          return (TRUE);
        }
 
        om$objid_to_tag(osnum = me->blend_grid.osnum, 
                        objid = me->blend_grid.objid,
                        p_tag = &me->blend_tag);

        if (sts_m == END_BY_CMD)
        {
          me->modify = FALSE;
          me->state = INIT;
          /*  let command server handle it  */
          return( OM_S_SUCCESS );
        }

        /*  redisplay option button  */
        GRstatus_display_button(TRUE);

        /*  put name of command in message field  */
        sts = ex$message (field = MESSAGE_FIELD, msgnumb = COMMAND_TEXT); 

        /*  set color of the associative lock icon to blue */
        GRdisplay_associative_button(me->global_assoc_flag);

        /*  clear last used data  */ 
        me->b_start_cond.curve = NULL;   /*  force basic read  */
        me->b_ende_cond.curve  = NULL;   /*  force basic read  */

        me->state = INIT;
        me->modify = FALSE; 

        break;
      } 



    default:

      sts = OM_E_ABORT;
      loc_msg = EMS_E_Fail;
      Goto (wrapup);
    }
  }

  return sts;


wrapup:
  /*  reset color of option icon  */
  GRstatus_display_button(FALSE);
  me->modify = FALSE;

  /*  reset info message   */
  sts = ex$message ( msgnumb = EMS_I_ClearStatusField);

  me->state = INIT;
  return sts;
}




/*
Name

    method sleep

Abstract

    This is the sleep method for the command ECblendcv.

Synopsis

    method sleep(int pos)

    pos             - unused

Description

    This method erases the highlight plane.

Return Value

    OM_S_SUCCESS

Notes

    dp$erase_hilite may be on its last legs. dp$display with mode GRhdbe
    for each element may need to be used in its place.

Index

Keywords

History

    03 Sep 93   AIC     Creation
*/



method sleep(int pos)
{
  IGRlong   loc_msg = EMS_S_Success;



  HDbd_erase_status_form();

  /*  reset color of the associative lock icon */
  GRdisplay_associative_button(FALSE);

  /*  reset color of option icon  */
  GRstatus_display_button(FALSE);

  /*  Erase everything  */
  dp$erase_hilite(msg = &loc_msg);


  return OM_S_SUCCESS;
}




/*
Name

    method wakeup

Abstract

    This is the wakeup method for the command ECblendcv.

Synopsis

    method wakeup(int pos)

    pos             - unused

Description

    This method highlight the elements that have already been located.

Return Value

    OM_S_SUCCESS

Notes

Index

Keywords

History

    03 Sep 93   AIC     Creation
*/


method wakeup(int pos)
{
  IGRint     last_locate_event, ii;
  IGRlong    loc_msg = EMS_S_Success,
             sts     = OM_S_SUCCESS;
  IGRint     size;            
  IGRint     response;
  IGRchar    response_data[DUMMY_SIZE];
  IGRlong    loc_mx_type;
  IGRmatrix  *loc_mx_ptr;  



  /*  put name of command in message field  */
  sts = ex$message (field = MESSAGE_FIELD, msgnumb = COMMAND_TEXT);
 
  /*  get assiciative lock state  */
  gr$get_associative_flag(msg    = &loc_msg,
                          buffer = &me->global_assoc_flag);

  /*  set color of the associative lock icon to blue */
  GRdisplay_associative_button(me->global_assoc_flag);

  /*  set color of option icon  */
  GRstatus_display_button(TRUE);

  last_locate_event = NULL;
  if ( me->state == LOCATE_2)  last_locate_event = 1;
  if ( me->state == GENERATE)  last_locate_event = 2;

  if (last_locate_event)
  {
    for(ii = 0; ii < last_locate_event; ii ++)
    {
      /*  Half highlight the located object  */
      loc_mx_type = (IGRlong) me->accept_event[ii].located_object[0].
                              module_info.md_env.matrix_type;
      loc_mx_ptr = &me->accept_event[ii].located_object[0].module_info.md_env.
                    matrix;

      sts = dp$display(msg      = &loc_msg,
                       mtx_type = &loc_mx_type,
                       matrix   = &loc_mx_ptr,
                       oids     = &me->accept_event[ii].located_object[0].located_obj,
                       mode     = GRhhd);
      if (!(1 & sts & loc_msg)) Goto (wrapup);
    }
  }
  if (me->global_assoc_flag)                   /*  modify only if assoc */ 
  {
    /*  go on with dynamic if interrupted there  */
    if (me->last_modify_sts == END_BY_CMD)
    {
      /*  preset form with last used values  */
      me->HDbd_f_par.HDbd_abs_ratio1 = ABS(base_ratio1);
      me->HDbd_f_par.HDbd_abs_ratio2 = ABS(base_ratio2);

      sts = ex$peek_event_queue(resp = &response);
      if (sts > 0)
      {
        /*  get the input  (without wait)  */
        size = DUMMY_SIZE;
        sts = ex$wait_for_input(response   = &response,
                                buffer     = response_data,    
                                byte       = (int *)&size);

        /*  fill form function with actual form values  */ 
        HDbd_cp_f_data(0, &me->HDbd_f_par);
        /*  display option form */
        sts = HDbd_display_status_form(TRUE); 
        me->state = WAIT_FORM;
                            me->bl_cv_control |= NEW_MODY;
      }
      else
      {
        me->state = MODIFY_NO_FORM;
      }     
    }
                     
    /*  check for modify during generation phase  */
    if (me->state == LOCATE_1  || me->state == LOCATE_2)
    {
      /*  preset form with last used values  */
      me->HDbd_f_par.HDbd_abs_ratio1 = ABS(base_ratio1);
      me->HDbd_f_par.HDbd_abs_ratio2 = ABS(base_ratio2);

      /*  fill form function with actual form values  */ 
      HDbd_cp_f_data(0, &me->HDbd_f_par);
      /*  display option form */
      sts = HDbd_display_status_form(TRUE); 
      me->bl_cv_control |= NEW_MODY; 
      if  (me->state == INIT)  me->state = LOCATE_1;
    }

  }
  return sts;

wrapup:
  return sts;
}







method status_disp()
{
  IGRlong  sts = OM_S_SUCCESS;
  IGRlong  loc_msg;


  gr$get_associative_flag(msg    = &loc_msg,
                          buffer = &me->global_assoc_flag);
  if (me->global_assoc_flag)              /*  modify only if assoc  */ 
  {
    if (me->blend_grid.objid != NULL_OBJID)
    {
      me->modify = TRUE;
      /*  fill form function with actual form values  */ 
      HDbd_cp_f_data(0, &me->HDbd_f_par);

      /*  message: select option or exit to modify  */
      sts = ex$message ( msgnumb = SEL_OPT_EXIT);

      /*  display option form  */
      HDbd_display_status_form(TRUE); 
      me->last_modify_sts = NULL;
    }  
  }


  return sts;
}






method delete (int pos)
{
  IGRlong  sts;



  /*  reset color of the option icon  */
  GRstatus_display_button(FALSE);

  /*  return space if not done before  */
  if (me->b_start_cond.curve) { free(me->b_start_cond.curve);  me->b_start_cond.curve = NULL; }
  if (me->b_ende_cond.curve)  { free(me->b_start_cond.curve);  me->b_ende_cond.curve  = NULL; }

  sts = om$send(mode     = OM_e_wrt_message,   
                msg      = message Root.delete(1),
                targetid = my_id);


  return(OM_S_SUCCESS);
}







/*
Name

    ECblend_curves_api

Abstract

    This is the api function for placing a blend.

Synopsis

    IGRint  ECblend_curves_api(EMmsg,
                                 curve1,            curve2,
                                 tangent_par1,      tangent_par2,
                                 direction1,        direction2,
                                 curvature1,        curvature2,
                                 blend_star_par1,   blend_start_par2,
                                 int_blend_point_1, int_blend_poiŸnt2,
                                 blend_order,       construct_list,
                                 result_os,         result_id )

    IGRlong                *EMmsg;              O - return code.
    struct GRlc_info       *curve1,             I - curve elements.
                           *curve2;
    IGRdouble              tangent_par1,        I - tangent value parameters
                           tangent_par2;            if NULL, first guess is
                                                     used.
    IGRint                 direction1,          I - If nonnegativ, blend is in
                           direction2;              direction of curve
                                                    parametrization.
    IGRint                 curvature1,          I - Curvature 1 = tangency
                           curvature2;              2 = curvature and tangency.
    IGRdouble              blend_start_par1,    I - Parameter on the curve of
                           blend_start_par2,        the blend start point.

    struct GRlc_info       *int_blend_poiŸnt1,   I - if existing blend point cv1
                           *int_blend_point2;   I - if existing blend point cv2
                                                    NULL_OBJID = none

    IGRshort               blend_order;         I - Order of blend curve
                                                    ( unused ).
    struct GRvg_construct  *construct_list;     I - construct list (optional).
    GRspacenum             *result_os;          O - os of result.
    GRobjid                *result_id;          O - id of result

Description

    Format the input, and call ems$associative_element_by_function.

Return Value

Notes

    The macro ec$blend_curves (ecbl1macros.h) is the macro interface, and
    calls this function.

    This creates and EMSagrp, which may not be the best thing.

    The name field of "construct_list" needs to be supported for naming
    the blend.

History

    03 Sep 93   AIC     Creation
*/
IGRint  ECblend_curves_api(
           IGRlong                 *EMmsg,
           struct GRlc_info        *curve1,
           struct GRlc_info        *curve2,
           IGRdouble               tangent_par1,
           IGRdouble               tangent_par2,
           IGRint                  direction1,
           IGRint                  direction2,
           IGRint                  curvature1,
           IGRint                  curvature2,
           IGRdouble               blend_start_par1,
           IGRdouble               blend_start_par2,
           struct GRlc_info        *int_blend_point1,
           struct GRlc_info        *int_blend_point2,
           IGRshort                blend_order,
           struct GRvg_construct   *construct_list,
           GRspacenum              *result_os,
           GRobjid                 *result_id)

{

  struct EMSobject_info  obj_info[NUM_PARENTS];
  struct IGRdisplay      loc_dis;
  struct GRmd_env        loc_env;
  struct GRvg_construct  loc_cnst;
  struct GRvg_construct  *cnst_ptr;
  struct EMSvalue_info   value;

  IGRlong                loc_msg = EMS_S_Success,
                         sts = OM_S_SUCCESS;
  IGRint                 par_control;
  IGRint                 number_parents;    /*  actual number parents  */
  GRobjid                loc_result_id;
  IGRboolean             cur_assoc_flag;
  

	
  /*  Set up the construct list  */   

  if (construct_list) 
  {
    cnst_ptr = construct_list;    
  }
  else          
  {
    loc_cnst.env_info   = &loc_env;
    loc_cnst.newflag    = FALSE;
    loc_cnst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    loc_cnst.geometry   = NULL;
    loc_cnst.display    = &loc_dis;
    loc_cnst.class_attr = NULL;
    loc_cnst.name       = NULL;

    gr$get_active_layer  (msg = &loc_msg, buffer = &loc_cnst.level);
    gr$get_module_env    (msg = &loc_msg, buffer = &loc_env);
    gr$get_active_display(msg = &loc_msg, buffer = &loc_dis);

    cnst_ptr = &loc_cnst;
  }
  cnst_ptr->msg = &loc_msg;


  gr$get_associative_flag(msg    = &loc_msg, buffer = &cur_assoc_flag);

  if (!cur_assoc_flag)              /*  modify only if assoc  */ 
  {
    IGRint       tangent_flag1, tangent_flag2;
    IGRdouble    par_cv1, par_cv2;
    struct GRid  loc_blend;

    /*  construct non assoc blend  */
    par_cv1 = (IGRint)(blend_start_par1 + 0.5);
    par_cv2 = (IGRint)(blend_start_par2 + 0.5); 

    /* ------------------------- */
    /* --- Perform the blend --- */
    /* ------------------------- */

    /*  preset for first blend  */
    tangent_flag1 = TANGENT_MODE;
    if (tangent_par1 < NULL)  tangent_flag1 = -TANGENT_MODE;
    tangent_flag2 = TANGENT_MODE; 
    if (tangent_par2 < NULL)  tangent_flag2 = -TANGENT_MODE;
    blend_order = NULL;     /*  free choise  */

    EMblendcv(&loc_msg,
              &curve1->module_info,
              curve1->located_obj,
              curvature1,
              tangent_flag1,
              tangent_par1,
              par_cv1,
              direction1,
              &curve2->module_info,
              curve2->located_obj,
              curvature2,
              tangent_flag2,
              tangent_par2,
              par_cv2,
              direction2,
              blend_order,
              construct_list,
              &loc_blend);
    if (!(1 & loc_msg))
    {
      sts = ex$message(msgnumb = ERROR_MESSAGE_NOINT,
                       field   = ERROR_FIELD);
      goto wrapup;
    }
    if (result_os) *result_os = loc_blend.osnum; 
    if (result_id) *result_id = loc_blend.objid;

    return loc_msg;
  }



  /*  create a parametric object of the tangent bar1 value  */
  value.type = EMSdatainfo_numeric; 
  value.val  = tangent_par1;   
  sts = EMgetparval_object(
                         &loc_msg,
                          cnst_ptr->env_info->md_id.osnum,
                          NULL,                        /* no object name  */
                         &value,
                         &obj_info[2]);

  /*  create a parametric object of the tangent bar2 value  */
  /*  value.type = EMSdatainfo_numeric;  */
  value.val = tangent_par2;
  
  sts = EMgetparval_object(
                         &loc_msg,
                          cnst_ptr->env_info->md_id.osnum,
                          NULL,                        /* no object name  */
                         &value,
                         &obj_info[3]);

  /*  create a parametric object of the parameter blendpoint 1 value  */
  value.type = EMSdatainfo_numeric; 
  value.val = blend_start_par1;
  
  sts = EMgetparval_object(
                         &loc_msg,
                          cnst_ptr->env_info->md_id.osnum,
                          NULL,                        /* no object name  */
                         &value,
                         &obj_info[4]);

  /*  create a parametric object of the parameter blendpoint 2 value  */
  value.type = EMSdatainfo_numeric; 
  value.val = blend_start_par2;
  
  sts = EMgetparval_object(&loc_msg,
                           cnst_ptr->env_info->md_id.osnum,
                           NULL,                        /* no object name  */
                           &value,
                           &obj_info[5]);


  /*  create a parametric object of the construction parameters  */
  value.type = EMSdatainfo_numeric; 

  par_control = 0;
  if (curvature1 == 2)  par_control += BLEND_BIT_CURVATOR_1; 
  if (curvature2 == 2)  par_control += BLEND_BIT_CURVATOR_2; 
  if (direction1 > 0)  par_control += BLEND_BIT_DIRECTION_1; 
  if (direction2 > 0)  par_control += BLEND_BIT_DIRECTION_2; 
  if (int_blend_point1->located_obj.objid != NULL_OBJID)  par_control += BLEND_BIT_INT_PTR_1; 
  if (int_blend_point2->located_obj.objid != NULL_OBJID)  par_control += BLEND_BIT_INT_PTR_2; 

  value.val = par_control;
  sts = EMgetparval_object(
                         &loc_msg,
                          cnst_ptr->env_info->md_id.osnum,
                          NULL,                        /* no object name  */
                         &value,
                         &obj_info[6]);

   
  /*
   * Initialize the EMSobject_info (to be parents)
   */

  obj_info[0].grid.osnum = curve1->located_obj.osnum;
  obj_info[0].grid.objid = curve1->located_obj.objid;
  obj_info[0].env  = curve1->module_info;

  obj_info[1].grid.osnum = curve2->located_obj.osnum;
  obj_info[1].grid.objid = curve2->located_obj.objid;
  obj_info[1].env  = curve2->module_info;


  obj_info[2].grid.osnum = cnst_ptr->env_info->md_id.osnum,
  obj_info[2].env  = *cnst_ptr->env_info;

  obj_info[3].grid.osnum = cnst_ptr->env_info->md_id.osnum,
  obj_info[3].env  = *cnst_ptr->env_info;

  obj_info[4].grid.osnum = cnst_ptr->env_info->md_id.osnum,
  obj_info[4].env  = *cnst_ptr->env_info;

  obj_info[5].grid.osnum = cnst_ptr->env_info->md_id.osnum,
  obj_info[5].env  = *cnst_ptr->env_info;

  obj_info[6].grid.osnum = cnst_ptr->env_info->md_id.osnum,
  obj_info[6].env  = *cnst_ptr->env_info;
 
  number_parents = 7;
  if (int_blend_point1->located_obj.objid != NULL_OBJID)
  {
    obj_info[number_parents].grid.osnum = int_blend_point1->located_obj.osnum;
    obj_info[number_parents].grid.objid = int_blend_point1->located_obj.objid;
    obj_info[number_parents].env        = int_blend_point1->module_info;
    number_parents++;

  }

  if (int_blend_point2->located_obj.objid != NULL_OBJID)
  {
    obj_info[number_parents].grid.osnum = int_blend_point2->located_obj.osnum;
    obj_info[number_parents].grid.objid = int_blend_point2->located_obj.objid;
    obj_info[number_parents].env        = int_blend_point2->module_info;
    number_parents++;
  }

  /*
   * Create the blend curve using the associative mechanism
   */

  sts = ems$associative_element_by_function(
            msg = &loc_msg,
            num_parents = number_parents,  
            parents = obj_info,
            function_name = "ECblend_curves",
            construct_list = cnst_ptr,
            class_name = "EMSagrp",
            created_id = &loc_result_id);
  if (!(1 & sts)) goto wrapup;

  /*
   * If specified, return the blend curve id and OS.
   */
  if (result_os) *result_os = cnst_ptr->env_info->md_id.osnum; 
  if (result_id) *result_id = loc_result_id;
 

  return sts;


wrapup:
  if (EMmsg) *EMmsg = loc_msg;
  return sts;
}                




/*
Name

    ECblend_curves

Abstract

    This is the associative function for placing a blend curve that is
    used as an argument to ems$associative_element_by_function.

Synopsis

    IGRint ECblend_curves(EMmsg, options, old_objid, new_objid,
                           num_parents, parent_info, recomp_info,
                           construct_list, mod_new_id)

    IGRlong                 *EMmsg;
    IGRuint                 options;
    GRobjid                 old_objid;
    GRobjid                 new_objid;
    IGRint                  num_parents;
    IGRchar                 *parent_info;
    IGRchar                 *recomp_info;
    struct GRvg_construct   *construct_list;
    GRobjid                 *mod_new_id;

    These are the standard arguments for an associative placement
    function.

Description

Return Value

Notes

History

    03 Sep 93   AIC     Creation
*/
IGRint ECblend_curves(EMmsg, options, old_objid, new_objid, num_parents, 
                      parent_info, recomp_info, construct_list, mod_new_id)

IGRlong                 *EMmsg;             /* output */
IGRuint                 options;            /* input  */
GRobjid                 old_objid;
GRobjid                 new_objid;
IGRint                  num_parents;
IGRchar                 *parent_info;
IGRchar                 *recomp_info;
struct GRvg_construct   *construct_list;
GRobjid                 *mod_new_id;        /* output  0 = error */



{
  IGRlong               sts;
  IGRlong               msg;
  IGRuint               parent_types[NUM_PARENTS];
  union EMSparent_info  parents[NUM_PARENTS];
  struct GRid           *buf_ptr, *cur_buf_ptr;
  char syntax[20];                  /*  for sprintf  */

  IGRlong   loc_msg = EMS_S_Success;

  struct GRid  blend_cv;            /*  blend curve                        */
  IGRint    cont1, cont2;           /*  1 tangent , 2 curvature            */
  IGRdouble old_ratio1, old_ratio2; /*  ratio for tangents                 */
  IGRdouble old_parcv1, old_parcv2; /*  int blend parameters               */
  IGRdouble ratio1, ratio2;         /*  ratio for tangents                 */
  IGRdouble par_cv1, par_cv2;       /*  parameter of projected pick point  */
  IGRint    dir_cv1, dir_cv2;       /*  +1 tangent in direction of drivative 
                                        -1 opposite direction              */
  IGRint    tangent_flag1,          /*  type of tangent value              */
            tangent_flag2; 
  IGRshort  blend_order;            /*  order of blendcurve / 0 = free     */
  IGRint    par_control; 

  IGRboolean cur_assoc_flag;

  IGRint    ind;



  options     = options;        /* make the compiler happy */
  old_objid   = old_objid;      /* make the compiler happy */
  recomp_info = recomp_info;    /* make the compiler happy */

  *mod_new_id = NULL; 

  if (num_parents > NUM_PARENTS)
    { *EMmsg = EMS_E_InvalidArg; sts = OM_E_ABORT; Goto (wrapup); }

  /* -----
   * Get the parents
   * parent[0] = curve1
   * parent[1] = curve2
   * parent[2] = tangent_par1
   * parent[3] = tangent_par2
   * parent[4] = parameter for curve 1 at blendpoint
   * parent[5] = parameter for curve 2 at blendpoint
   * parent[6] = blendcurve control
   * parent[7] =    int blend point pointer cv1  (0 = none)
   * parent[8] =    int blend point pointer cv2  (0 = none)
   ----- */
  parent_types[0] = EMSlcinfo;
  parent_types[1] = EMSlcinfo;
  parent_types[2] = EMSscalar;
  parent_types[3] = EMSscalar;
  parent_types[4] = EMSscalar;
  parent_types[5] = EMSscalar;
  parent_types[6] = EMSscalar;
  parent_types[7] = EMSlcinfo;
  parent_types[8] = EMSlcinfo;


  sts = om$send(msg = message EMSassoc.EMget_parent_info(
                              EMmsg,
                              NULL,
                              num_parents,
                              parent_info,
                              parent_types,
                              parents),
                senderid = NULL_OBJID,
                targetid = new_objid,
                targetos = construct_list->env_info->md_id.osnum);

  if (!(1 & sts & *EMmsg)) Goto (wrapup);

  /*  get tangent 1 value */
  ratio1 = old_ratio1 = parents[2].value;    

  /*  get tangent 2 value */
  ratio2 = old_ratio2 = parents[3].value;           
 
  /*  get parameter for curve 1 at blendpoint  */
  par_cv1 = old_parcv1 = parents[4].value;    

  /*  get parameter for curve 2 at blendpoint  */
  par_cv2 = old_parcv2 = parents[5].value;

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

  if (!(par_control & BLEND_BIT_INT_PTR_1)  &&
      !(par_control & BLEND_BIT_INT_PTR_2)  &&
      !(par_control & BLEND_BIT_MODIFIED)      )  ratio1 = ratio2 = -1.0;

  /*  handle internal blend point by existing point  */
  ind = 7;
  if (par_control & BLEND_BIT_INT_PTR_1) 
  { 
    /*  internal blend point curve 1 */
    sts = Blend_ext_p(&msg, &parents[0].grobj, &parents[ind].grobj, &par_cv1);
    if (!(1&sts)) Goto (wrapup);
    ind++;  
  }

  if (par_control & BLEND_BIT_INT_PTR_2) 
  {
    /*  internal blend point curve 2 */
    sts = Blend_ext_p(&msg, &parents[1].grobj, &parents[ind].grobj, &par_cv2);
    if (!(1&sts)) Goto (wrapup);
    ind++;
  }

    /*  get associative lock state  */
    gr$get_associative_flag(msg    = &loc_msg,
                            buffer = &cur_assoc_flag); 
    if (!cur_assoc_flag)  par_cv1 = (IGRint)(par_cv1 + 0.5);
    if (!cur_assoc_flag)  par_cv2 = (IGRint)(par_cv2 + 0.5); 


  /* ------------------------- */
  /* --- Perform the blend --- */
  /* ------------------------- */

  /*  preset for first blend  */
  tangent_flag1 = TANGENT_MODE;
  if (ratio1 < NULL)  tangent_flag1 = -TANGENT_MODE;

  tangent_flag2 = TANGENT_MODE; 
  if (ratio2 < NULL)  tangent_flag2 = -TANGENT_MODE;

  blend_order = NULL;     /*  free choise  */
   
  EMblendcv (
             &loc_msg,
             &parents[0].grobj.env,
              parents[0].grobj.grid,
              cont1,
              tangent_flag1,
             &ratio1,
              par_cv1,
              dir_cv1,
             &parents[1].grobj.env,
              parents[1].grobj.grid,
              cont2,
              tangent_flag2,
             &ratio2,
              par_cv2,
              dir_cv2,
              blend_order,
              construct_list,
              &blend_cv);

  if (!(1 & loc_msg)) goto wrapup;


  {
    /*  take over polygon display status  */
    struct    IGResbc element_specific;

    if (old_objid == NULL_OBJID)
    {
      element_specific.is_polydis  = FALSE;
      element_specific.is_curvedis = TRUE;
    }
    else
    {
      sts = om$send(msg = message GRvg.GRgetattr(
                                       &loc_msg,
                                       (IGRchar *) &element_specific),
                    targetid = old_objid,
                    targetos = blend_cv.osnum,
                    senderid = old_objid);
    }

    sts = om$send(msg = message GRvg.GRputattr(
                                     &loc_msg,
                                     (IGRchar *) &element_specific),
                  targetid = blend_cv.objid,
                  targetos = blend_cv.osnum,
                  senderid = blend_cv.objid);
  }


  /*  save last used ratios for modify output  */
  base_ratio1 = ratio1;
  base_ratio2 = ratio2;

  *mod_new_id = blend_cv.objid;
  buf_ptr = (struct GRid *) parent_info;

  /*  restore modified blendcurve values  */ 
  if (old_ratio1 != ratio1 ||  old_ratio2 != ratio2)
  {
    cur_buf_ptr = (struct GRid *) parent_info + 2;
    /*  restore new tangent length  */
    /*  convert double to character string  */        
    sprintf(syntax,"%g",ratio1); 
    sts = exp$modify(exp_id = cur_buf_ptr->objid, exp_syntax = syntax); 
    if (!(1&sts)) Goto (wrapup);

    /*  convert double to character string  */              
    sprintf(syntax,"%g",ratio2);
    cur_buf_ptr = (struct GRid *) parent_info + 3;
    sts = exp$modify(exp_id = cur_buf_ptr->objid, exp_syntax = syntax); 
    if (!(1&sts)) Goto (wrapup);
  }

  /*  restore new int blend parameters  */
  if (old_parcv1 !=  par_cv1)
  {
    /*  convert double to character string  */              
    sprintf(syntax,"%g",par_cv1);
    cur_buf_ptr = (struct GRid *) parent_info + 4;
    sts = exp$modify(exp_id = cur_buf_ptr->objid, exp_syntax = syntax); 
    if (!(1&sts)) Goto (wrapup);
  }

  if (old_parcv2 != par_cv2)
  {
    /*  convert double to character string  */              
    sprintf(syntax,"%g",par_cv2);
    cur_buf_ptr = (struct GRid *) parent_info + 5;
    sts = exp$modify(exp_id = cur_buf_ptr->objid, exp_syntax = syntax);
    if (!(1&sts)) Goto (wrapup);
 }

  return sts;


wrapup:
  *mod_new_id = NULL;
  *EMmsg = TERMINATE;
  return (OM_S_SUCCESS);
}

end implementation ECblendcv;
