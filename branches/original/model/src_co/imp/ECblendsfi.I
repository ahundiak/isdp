
/*
    This file contains method implementations and functions for
    blend surfaces (HDC). 
*/

class implementation ECblendsf;

# include "VCdef.h"              /*... test  ...*/
# include "bsparameters.h"
# include "bstypes.h"
# include "bserr.h"

# include <math.h>

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
# include "dpezmac.h"            /* dp$inq_window */
# include "EMSasnuc.h"
# include "EMSasmacros.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "expression.h"
# include "expmacros.h"
# include "exmacros.h"                 /*  ex$wait..  */
# include "ASmsg.h"
# include "ECmsg.h"
# include "ECcmd.h"
# include "ecbls_macros.h"
# include "execmsg.h"       
# include "EMS.h"
# include "parametric.h"
# include "nddef.h"
# include "emsdef.h"
                
# include "EMSblend_sf.h"         
# include "ecbls_bitcod.h"         
# include "ecbls_for.h"         
# include "ecbls_inf.h"         


/*  prototypes  */

# include "bscveval.h"       /*  function prototype  */
# include "bssfeval.h"       /*  function prototype  */
# include "bsnorvec.h"       /*  function prototype  */
# include "bsmkvec.h"        /*  function prototype  */
# include "bsdotp.h"         /*  function prototype  */
# include "bsdistptpt.h"     /*  function prototype  */

# include "ecbls_dyn.h"      /*  function prototype  */
# include "ecbls_mod.h"      /*  function prototype  */
# include "emblendsf.h"      /*  function prototype  */
# include "ecbls_gt.h"       /*  function prototype  */
# include "ecbls_sf_vc.h"    /*  function prototype  */



extern OMuword  OPP_GRcurve_class_id;
extern OMuword  OPP_EMSsubbs_class_id;
extern OMuword  OPP_GRpoint_class_id;
extern OMuword  OPP_EMSsphere_class_id;
extern OMuword  OPP_EMAgenbs_class_id;
extern OMuword  OPP_EMSsurface_class_id;
extern OMuword  OPP_EMScompsurf_class_id;
extern OMuword  OPP_EMSsfimpbnd_class_id;
extern OMuword  OPP_EMSprjcompsf_class_id;
extern OMuword  OPP_EMSsfstitch_class_id;
extern OMuword  OPP_EMSslboolean_class_id;
extern OMuword  OPP_EMSsfboolean_class_id;
extern OMuword  OPP_EMAgenbs_class_id; 



from EMSassoc  import  EMget_parent_info;

from GRvg      import  GRgetsize,
                       GRgetgeom,
                       GRconstruct; 

from GRlinear  import  GRgetpolyline;


# define VCdebug_return   1                 /*... test on ...*/

# define MAX_NUM_PARENTS    38





/* text for prompts and other messages */

/*                       "Place Blend between 2 surfaces"  */
#define COMMAND_TEXT      EM_M_PBS2S

/*                       "Idendify surface 1"  */
#define LOCATE_PROMPT_1S  EMS_P_IdentifySurface1

/*                       "Identify surface 1/Curve on surface 1/OPtion Form to modify"  */
#define LOCATE_PROMPT_1M  EMS_P_Id_Su_1__Cu_Su_1__MoOn_Mo_Su

/*                        "Identify curve on surface 1"  */
#define ENTER_PROMPT_BLC1   EMS_P_Id_Cu_Su_1     
            
/*                       "Idendify surface 1/Curve on surface 1"  */
#define LOCATE_PROMPT_1C  EMS_P_Id_Su_1__Cu_Su_1  
           
/*                       "Idendify surface 2"  */
#define LOCATE_PROMPT_2S  EMS_P_IdentifySurface2 

/*                        "Identify curve on surface 2"  */
#define ENTER_PROMPT_BLC2  EMS_P_Id_Cu_Su_2     
   
/*                       "Idendify surface 2/Curve on surface 2"  */
#define LOCATE_PROMPT_2C  EMS_P_Id_Su_2__Cu_Su_2             

/*                       "Identify surface 2/Curve on surface 2/Move on to modify it"  */
#define LOCATE_PROMPT_2M  EMS_P_Id_Su_2__Cu_Su_2__MoOn_Mo_Su                

/*                       "Element not found"  */
#define RELOCATE_PROMPT  EMS_I_00013

/*                       "Accept with edge/Reject"  */
#define ACCEPT_PROMPT    EMS_P_AccWithEdgeReject	

/*                       "Select Options / Exit to modify"  */
#define SEL_OPT_EXIT     EMS_P_Se_Op__Ex_Mo

/*                        "Identify surface 1 partial blend startpoint"  */
#define ENTER_PROMPT_PB1S  EMS_P_Id_Su1_Pa_Bl_St  
 
/*                        "Identify surface 2 partial blend endpoint"  */
#define ENTER_PROMPT_PB1E  EMS_P_Id_Su1_Pa_Bl_En 

/*                        "Identify surface 2 partial blend startpoint"  */
#define ENTER_PROMPT_PB2S  EMS_P_Id_Su2_Pa_Bl_St  
 
/*                        "Identify surface 2 partial blend endpoint"  */
#define ENTER_PROMPT_PB2E  EMS_P_Id_Su2_Pa_Bl_En   

/*                       "Identify surface 1 internal blend direction vector"*/
#define ENTER_PROMPT_IBV1  EMS_P_Id_Su1_In_Bl_Di
  
/*                       "Identify surface 2 internal blend direction vector"*/
#define ENTER_PROMPT_IBV2  EMS_P_Id_Su2_In_Bl_Di  

            

/*                           "No blend possible"  */    
#define ERROR_MESSAGE_NOINT  EMS_I_No_Bl_Po
             
/*                           "Warning:  No modify if non-associative"  */
#define NO_MODIFY            EMS_S_Warn_No_Mo_No_As     
 


#define NEW_MODY          1           /*  control: modified during create  */

# define BIT_PNT          1 
# define BIT_CRV          2
# define BIT_SRF          4
# define BIT_FORM         8
# define BIT_VEC         16

# define SEL_CRV          1
# define SEL_SRF          2
# define SEL_PNT          4
# define SEL_VEC          4

# define  END_BY_CMD      5
# define  DUMMY_SIZE      64

# define MAX(x,y)  ((x) < (y) ? (y) : (x))
# define MIN(x,y)  ((x) < (y) ? (x) : (y))
# define ABS(x)    ((x) < 0 ? -(x) : (x))


extern IGRboolean  EFisAncestryValid();


static IGRdouble base_ratio1,  base_ratio2;   /*  last used ratio for forms   */
static IGRdouble base_approx1, base_approx2;  /*  last used approx for forms  */


/*   ----------------------------------------------------------
Name

    locateObject

Abstract

    This is a static function used to perform locate for this command.

Synopsis

    static long locateObject(msg, task, txt_index, locate_event, accept_event,
                            response, response_data, wrk_classid, sel_typ, vec)

    IGRlong         *msg;               return code from lc$locate
    IGRint          task;               task
                                        BIT_CRV:   select curve
                                        BIT_SRF:   select surface
                                        BIT_FORM:  allow form event
                                        BIT_VEC:   select vector
    IGRint          txt_index;          text_index
    struct GRevent  *locate_event;      locate event structure
    struct GRevent  *accept_event;      accept event structure
    IGRint          *response;          response
    char            *response_data;     response data
    OMuword         *wrk_classid;       classid of selected curve/surface
    IGRint          *sel_typ;           SEL_CRV = curve selected
                                        SEL_SRF = surface selected 
                                        SEL_PNT = point selected
    IGRvec          vec;                SEL_VEC = curve+vector selected

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
static long locateObject(msg, task, txt_index, locate_event, accept_event,
                         response, response_data, wrk_classid, sel_typ, vec)

IGRlong         *msg;
IGRint          task;
IGRint          txt_index;
struct GRevent  *locate_event;
struct GRevent  *accept_event;
IGRint          *response;
char            *response_data;
OMuword         *wrk_classid;
IGRint          *sel_typ;
IGRvector       vec;

{
  IGRlong               sts = OM_S_SUCCESS;

  struct GRlc_locate    attributes;
  struct GRlc_stack     stack;

  OM_S_CLASSLIST        rtree_classes;
  OMuword               p_classes[2];
  OM_S_CLASSLIST        n_eligible_classes; 
  OMuword               n_classes[7];

  IGRint                msk1, msk2,
                        ii;

  struct IGRbsp_curve   *cv; 
  IGRlong               num_bytes;
  IGRlong               rc;
  IGRpoint              eval[3];
  IGRdouble             par;                 


  *sel_typ = 0;
  cv = NULL;

  /*  Initialize the locate input structures  */
  stack.num_entries    = 0;
  stack.number_located = 0;
  attributes.properties = LC_LC_ONLY | LC_RW | LC_DP_ONLY;
  attributes.owner_action =   LC_FLEX_COMP
                            | LC_GEOM_MOD
                            | LC_RIGID_COMP 
                            | LC_RIGID_OWNER
                            | LC_REF_OBJECTS 
                            | LC_ASSOCIATIVE 
                            | LC_EXTERN_CONSTRAINED;


  rtree_classes.w_count = 1;
  rtree_classes.w_flags      = 
  n_eligible_classes.w_flags = OM_CLST_subclass | OM_CLST_negation;
  n_eligible_classes.p_classes = n_classes;
  n_classes[0] = OPP_GRpoint_class_id;
  n_classes[1] = OPP_EMSsfimpbnd_class_id;
  n_classes[2] = OPP_EMSprjcompsf_class_id;
  n_classes[3] = OPP_EMSsfstitch_class_id;
  n_classes[4] = OPP_EMSslboolean_class_id;
  n_classes[5] = OPP_EMSsfboolean_class_id;


  /*  Initialize the element-specific info in the locate input structures  */
  if (BIT_PNT & task) 
  {
    /*  point locate only  */
    attributes.owner_action = LC_READ | LC_REF_OBJECTS;
    n_eligible_classes.w_count = 1;          /*  point  */
    n_classes[0] = OPP_GRpoint_class_id;
    p_classes[0] = OPP_GRpoint_class_id;
        rtree_classes.w_flags      = 
        n_eligible_classes.w_flags = OM_CLST_subclass;
        n_eligible_classes.p_classes = n_classes;
  }
  else
  { 
    p_classes[0] = OPP_EMSsubbs_class_id;
    p_classes[1] = OPP_GRcurve_class_id;

    if ((BIT_CRV|BIT_SRF)&task == BIT_CRV|BIT_SRF)
    { 
      n_eligible_classes.w_count = 6;          /*  curve and surface  */
    }

    if ((BIT_CRV|BIT_SRF)&task == BIT_SRF)
    {
      n_classes[6] = OPP_GRcurve_class_id;
      n_eligible_classes.w_count = 7;          /*  surface only  */
      p_classes[1] = OPP_EMSsubbs_class_id;
    }

    if ((BIT_CRV|BIT_SRF)&task == BIT_CRV)
    {
      n_classes[6] = OPP_GRcurve_class_id;
      n_eligible_classes.w_count = 5;          /*  curve only  */
      p_classes[0] = OPP_GRcurve_class_id;
    }
  }


  rtree_classes.p_classes = p_classes;

  msk1 = GRm_DATA | GRm_BACK_UP | GRm_MOVE_ON | GRm_RJT_MOVEON;
  msk2 = GRm_DATA | GRm_BACK_UP | GRm_MOVE_ON | GRm_RESET;

  if (BIT_FORM&task)     /*  add form finished  */
  {
    msk1 |= GRm_FORM_FINISHED;
    msk2 |= GRm_FORM_FINISHED;
  }

  /*  Perform locate  */
  sts = lc$locate(
        rc               = msg,
        event1           = locate_event,
        mask1            = msk1,
        event2           = accept_event,
        mask2            = msk2,
        response         = response,            
        response_data    = response_data,  
        locate_key       = txt_index,
        relocate_key     = GR_I_EleNotFound,
        acc_key          = ACCEPT_PROMPT,
        attributes       = &attributes,
        stack            = &stack,
        display_flag     =   ELEM_HILIGHT | LC_ACC_ONE_ELEMENT
                           | LC_ERASE_LOC_ELEMENT ,
        eligible_classes = &n_eligible_classes,
        rtree_classes    = &rtree_classes);

  if (!(1&sts))  goto wrapup;

  if (accept_event[0].response == EX_DATA)
  {
    /*  extract element class_id  */
    sts = om$get_classid(
          objid     = accept_event[0].located_object[0].located_obj.objid,
          osnum     = accept_event[0].located_object[0].located_obj.osnum,
          p_classid = wrk_classid);

    if (BIT_SRF & task)          /*  surface  */
    {
      /*  find out if surface or curve selected  */ 
      if (EFisAncestryValid(msg, 
                            accept_event[0].located_object[0].located_obj.objid,
                            accept_event[0].located_object[0].located_obj.osnum,
                            OPP_EMSsubbs_class_id,
                            FALSE)
       || EFisAncestryValid(msg, 
                            accept_event[0].located_object[0].located_obj.objid,
                            accept_event[0].located_object[0].located_obj.osnum,
                            OPP_EMScompsurf_class_id,
                            FALSE)  )                    *sel_typ = SEL_SRF;
    }

    if (BIT_CRV & task)          /*  curve  */
    {
      if (EFisAncestryValid(msg, 
                            accept_event[0].located_object[0].located_obj.objid,
                            accept_event[0].located_object[0].located_obj.osnum,
                            OPP_GRcurve_class_id,
                            FALSE) )                     *sel_typ = SEL_CRV;

      if (BIT_VEC & task)          /*  vector + (curve)  */
      {
       /*---  get selected curve  ---*/ 
        sts = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRgetsize (
                              msg,
                              &accept_event->located_object[0].module_info.md_env.matrix_type,
                              accept_event->located_object[0].module_info.md_env.matrix,
                              &num_bytes ),
                      senderid = NULL,
                      targetid = accept_event->located_object[0].located_obj.objid,
                      targetos = accept_event->located_object[0].located_obj.osnum);
 
        cv  = (struct IGRbsp_curve *) malloc(num_bytes); 

        sts = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRgetgeom (msg,
                              &accept_event->located_object[0].module_info.md_env.matrix_type,
                              accept_event->located_object[0].module_info.md_env.matrix,
                              (IGRchar *) cv),
                      senderid = NULL,
                      targetid = accept_event->located_object[0].located_obj.objid,
                      targetos = accept_event->located_object[0].located_obj.osnum);

        par = accept_event->located_object[0].geom_parms.u;
        BScveval(cv, par, 1, eval, &rc); 
    
        for (ii=0; ii<3; ii++)
          vec[ii]    = eval[1][ii];
        /*  return space  */
        if (cv)  {  free(cv);  cv = NULL;  }
      }
    }

    if (BIT_PNT & task)          /*  point  */
    {
      if (EFisAncestryValid(msg, 
                            accept_event[0].located_object[0].located_obj.objid,
                            accept_event[0].located_object[0].located_obj.osnum,
                            OPP_GRpoint_class_id,
                            FALSE) )                     *sel_typ = SEL_PNT;
    }
    if ( *sel_typ == SEL_SRF)
    {

    if ( ! EFisAncestryValid(msg, 
                             accept_event[0].located_object[0].located_obj.objid,
                             accept_event[0].located_object[0].located_obj.osnum,
                             OPP_EMSsubbs_class_id,
                             TRUE) )  
    {
      /*  this surface is not the basic geometric surface  */
      OM_S_CHANSELECT     to_ch_ptr;
      OMuint              chan_count;
      OM_S_OBJECT_LINKAGE *chan_list; 
      IGRint  kk;     

      sts =  om$make_chanselect (channame     = "GRcmpowner.to_components",
                                 p_chanselect = &to_ch_ptr);
      if (1&sts)
      {
        chan_count = NULL;
        sts = om$get_channel_count(osnum        = accept_event[0].located_object[0].located_obj.osnum,
                                   objid        = accept_event[0].located_object[0].located_obj.objid,
                                   p_chanselect = &to_ch_ptr,
                                   count        = &chan_count);
        if (chan_count > NULL) 
        {
           chan_list = NULL;
           chan_list = (OM_S_OBJECT_LINKAGE *) malloc(chan_count * sizeof(OM_S_OBJECT_LINKAGE));
           if (!chan_list)  Goto (wrapup);
           sts = om$get_channel_objects(osnum = accept_event[0].located_object[0].located_obj.osnum,
                                        objid = accept_event[0].located_object[0].located_obj.objid,
                                        p_chanselect = &to_ch_ptr,
                                        list  = chan_list,
                                        size  = chan_count,
                                        count = &chan_count);
           if (!(sts&1)) Goto (wrapup);

           for (kk=0; kk<chan_count; kk++)
           {
             if (EFisAncestryValid(msg, 
                                   chan_list[kk].S_objid,
                                   chan_list[kk].osnum,
                                   OPP_EMSsubbs_class_id,
                                   TRUE) )
             {
               accept_event[0].located_object[0].located_obj.objid  =
                                                        chan_list[kk].S_objid;
   
             }
           }
         if (chan_list)  free(chan_list);   /*  release temporary space  */
         }    /*      if (chan_count > NUL         */
       }    /*      if (1&sts                      */         
     }    /*      if (! EFisAncestryValid(&loc_m   */
    }
  }


  return (sts);

wrapup:
  return (FALSE);

}







/*   ----------------------------------------------------------
Name

    method init

Abstract

    This is the init method for the command ECblendsf.

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
  /*  preset for first entry  */ 
  me->wrk_mode = 0;
  me->last_surface_1   = NULL_OBJID;
  me->last_surface_2   = NULL_OBJID;
  me->blend_grid.objid = NULL_OBJID;
  me->blend_tag        = NULL;
  me->blend_grid.osnum = NULL;
  me->modify           = FALSE;
  me->number_modify    = NULL;
  me->last_modify_sts  = NULL;
  me->bl_sf_control    = NULL;

  me->b_start_cond.surface = NULL;
  me->b_ende_cond.surface  = NULL;

  /* preset the modify values SRF1 */

  me->HDbd_f_par.HDbd_srf1.exicrv    = 0;            /*  natural blend */
  me->HDbd_f_par.HDbd_srf1.t_sensi   = 1.0;
  me->HDbd_f_par.HDbd_srf1.curv_c    = FALSE;

  me->HDbd_f_par.HDbd_srf1.t_auto    = FALSE;
  me->HDbd_f_par.HDbd_srf1.t_screen  = TRUE;
  me->HDbd_f_par.HDbd_srf1.t_copy    = FALSE;
  me->HDbd_f_par.HDbd_srf1.t_keyin   = FALSE;
  me->HDbd_f_par.HDbd_srf1.partial   = 0;

  me->HDbd_f_par.HDbd_srf1.crv_u     = FALSE;
  me->HDbd_f_par.HDbd_srf1.crv_v     = FALSE;
  me->HDbd_f_par.HDbd_srf1.crv_ruled = TRUE;
  me->HDbd_f_par.HDbd_srf1.crv_vec_s = FALSE;
  me->HDbd_f_par.HDbd_srf1.crv_perp  = FALSE;    
  me->HDbd_f_par.HDbd_srf1.crv_vec_d = FALSE;
    
  me->HDbd_f_par.HDbd_srf1.approx    = 0.0;            

  /*  preset 2nd surface with the same values  */
  me->HDbd_f_par.HDbd_srf2 = me->HDbd_f_par.HDbd_srf1;


  me->HDbd_f_par.HDbd_undo      = FALSE;  
  me->HDbd_f_par.HDbd_undolm    = FALSE;  
  me->HDbd_f_par.HDbd_mode      = 1;  
  me->HDbd_f_par.HDbd_diagnos   = FALSE;  
  me->HDbd_f_par.HDbd_symmetric = FALSE;  
  me->HDbd_f_par.HDbd_srf_twist = FALSE;  
  me->HDbd_f_par.HDbd_minrad    = 0.1;  
  me->HDbd_f_par.HDbd_order     = 4;  
  me->HDbd_f_par.HDbd_poles     =  me->HDbd_f_par.HDbd_order +  
                                     2 * (me->HDbd_f_par.HDbd_srf1.curv_c 
                                        | me->HDbd_f_par.HDbd_srf2.curv_c);

  /*  preset first hedgehog position parameters  */
  me->last_blend.hd_index     = 0;        /*  use any edge (0-3) */
  me->last_blend.hd_cur_param = 0.5;      /*  use middle         */

  base_ratio1  = -1.0;    
  base_ratio2  = -1.0;
  base_approx1 = 0.0;
  base_approx2 = 0.0;

  return OM_S_SUCCESS;
}




/*
Name

    method execute

Abstract

    This is the execute method for the command ECblendsf

Synopsis

    method execute(int *response; char *response_data; int pos)

    response        - response from last event when command returns
                      control to command services

    response_data   - response data from last event when command returns
                      control to command services

    pos             - unused

Description

    This method gathers the user's input and calls the macro
    ec$blend_surfaces.

Return Value

    OM_S_SUCCESS

Notes

    Event handling is not done well.

Index

Keywords

History

    03 Sep 93   AIC     Creation
*/
method execute(int *response; char *response_data; int pos)
{
   IGRlong     sts = OM_S_SUCCESS;
   IGRlong     sts_m;

   IGRlong     loc_msg   = EMS_S_Success;
   IGRlong     blend_msg = EMS_S_Success;
   IGRlong     rc;                     
   IGRint      cont = 1;

   OMuword     sf1_classid, sf2_classid;
   OMuword     wrk_classid;
   IGRint      sel_typ;
   IGRint      wrk_dir;

   struct IGRdisplay     blend_dis;
   struct GRmd_env       blend_env;
   struct GRvg_construct blend_cnst;
   struct IGResbs        attr;
   struct GRevent        param_event;

   IGRint     cont1, cont2;        /* 1 tangent , 2 curvature            */
                                   /* 0 only tangent continous at both
                                       curves
                                      1 curvature continous at 1. curve
                                      2                        2.
                                      3                        both      */
   IGRdouble  ratio1, ratio2;      /* ratio for tangents                 */

   IGRvector  dir_vec1[2],
              dir_vec2[2];

   IGRshort   blend_order;         /*  order of blendcurve  0 = not spec */ 

   IGRdouble  par_cv1[2],   /*  start and end parameter of blend curve  */
              par_cv2[2];   /*  start and end parameter of blend curve  */

   IGRdouble  par_sf1u, par_sf1v,  /*  surface 1 selection uv-parameter  */
              par_sf2u, par_sf2v;  /*  surface 2 selection uv-parameter  */

   IGRvector  vec_1, vec_2;        /*  selected edge direction vector  */ 
   IGRint     ind;                 /*  u,v selection index  */
   IGRdouble  par_u, par_v;        /*  tangent uv position  */

   IGRint     iu1, iu2,  iv1, iv2;
   IGRdouble  xu1, xu2,  xv1, xv2; 
          
   IGRdouble  par_iso1, par_iso2;      
   IGRint     approx_flag1, approx_flag2;
   IGRdouble  approx_fact1, approx_fact2;
 
   IGRint    txt_index;
   IGRint    loc_task;
   IGRint    dyn_status;

   IGRdouble   rot_matrix[16];     /*  first loc. view rotation matrix       */
   IGRdouble   mat_wtv[16];        /*  first loc. view world to view matrix  */
   IGRpoint    origin_point;
   IGRdouble   vwvolume[6];
   IGRdouble   epsw = 0.001;       /*  for view usage only            */

   IGRint    i, j, k, l;           /*  loop counter  */
 
   IGRpoint   pos1, pos2;          /*  surface accept position  */
   IGRboolean closed_1, closed_2;

   struct GRlc_info   *p_point1s, *p_point1e,
                      *p_point2s, *p_point2e,
                      *p_point2x;

   IGRdouble          temp;
   IGRvector          sel_vect;



 #define INIT            0                  /*  initialize                  */
 #define LOCATE_1_CS     INIT + 1           /*  Curve-1 / Surface-1 select  */
 #define LOCATE_1_S      LOCATE_1_CS + 1    /*            Surface-1 select  */
 #define LOCATE_1_V      LOCATE_1_S + 1     /*  Dir-Vect  Surface-1 select  */
 #define LOCATE_1_P1     LOCATE_1_V + 1     /*  Partial-s Surface-1 select  */
 #define LOCATE_1_P2     LOCATE_1_P1 + 1    /*  Partial-e Surface-1 select  */

 #define LOCATE_2_CS     LOCATE_1_P2 + 1    /*  Curve-2 / Surface-2 select  */
 #define LOCATE_2_S      LOCATE_2_CS + 1    /*            Surface-2 select  */
 #define LOCATE_2_V      LOCATE_2_S + 1     /*  Dir-Vect  Surface-2 select  */
 #define LOCATE_2_P1     LOCATE_2_V + 1     /*  Partial-s Surface-2 select  */
 #define LOCATE_2_P2     LOCATE_2_P1 + 1    /*  Partial-e Surface-2 select  */

 #define GENERATE        LOCATE_2_P2 + 1
 #define EXT_MODIFY      GENERATE + 1
 #define WAIT_FORM       EXT_MODIFY + 1
 #define MODIFY_FORM     WAIT_FORM + 1
 #define MODIFY_NO_FORM  MODIFY_FORM + 1


  /*  make compiler happy  */
  sf1_classid = sf2_classid = NULL;
  loc_task = NULL;
  txt_index = NULL;
  ind = NULL;          
  par_u = par_v = NULL;


  while (cont)
  {
    switch(me->state)

    {
      case INIT:
      {
        me->bl_sf_control = NULL;
        /*  get associative lock state  */
        gr$get_associative_flag(msg    = &loc_msg, 
                                buffer = &me->global_assoc_flag);
        if (!me->global_assoc_flag)
        {
          /* no modify if not assoc */
          me->blend_grid.objid = NULL_OBJID;
          /*  tell user that mo modify in non assoc mode  */
          sts = ex$message(msgnumb = NO_MODIFY,
                           field   = ERROR_FIELD);
        }
        /*  set/reset color of option icon  */
        GRstatus_display_button(!me->modify);
        me->cv_flag1  = me->cv_flag2  = 0;
        me->dir_flag1 = me->dir_flag2 = 3;              /* preset ruled  */
        dir_vec1[1][0] = 0.0;          /*  preset  */
        dir_vec1[1][1] = 1.0;          /*  preset  */
        dir_vec1[1][2] = 0.0;          /*  preset  */
        dir_vec2[1][0] = 0.0;          /*  preset  */
        dir_vec2[1][1] = 1.0;          /*  preset  */
        dir_vec2[1][2] = 0.0;          /*  preset  */
        me->HDbd_f_par.HDbd_srf1.exicrv =
        me->HDbd_f_par.HDbd_srf2.exicrv = 0;
        /*  fill form function with (last used) actual form values  */ 
        me->HDbd_f_par.HDbd_srf1.ratio = base_ratio1;   /*  use newest value */
        me->HDbd_f_par.HDbd_srf2.ratio = base_ratio2;   /*  use newest value */
        me->HDbd_f_par.HDbd_srf1.approx = base_approx1; /*  use newest value */
        me->HDbd_f_par.HDbd_srf2.approx = base_approx2; /*  use newest value */
        HDbs_cp_f_data(0, &me->HDbd_f_par);

        dp$erase_hilite(msg = &loc_msg);      /*  make shure no highlight  */

        me->indx_sf1 = me->indx_cv1 = me->indx_pa1 = me->indx_sf2 = 
                                      me->indx_cv2 = me->indx_pa2 = -99;

        me->state++;
        break;
      }


      /* ------------------------- */
      /*       L O C A T E         */
      /* ------------------------- */

      case LOCATE_1_CS:
        me->source = NULL;                     /*  set first surface index  */
        loc_task = BIT_CRV | BIT_SRF | BIT_FORM; 
        if (!me->modify)
        {
          if (me->blend_grid.objid == NULL_OBJID) txt_index = LOCATE_PROMPT_1C;
          else                                    txt_index = LOCATE_PROMPT_1M;

          if (me->HDbd_f_par.HDbd_srf1.exicrv > 1)
          {
            if (NEW_MODY & me->bl_sf_control)
            {
              loc_task  = BIT_CRV | BIT_FORM;
              txt_index = ENTER_PROMPT_BLC1;
            }
          }
          if ((NEW_MODY & me->bl_sf_control) && me->HDbd_f_par.HDbd_srf1.partial)
          {
            txt_index = LOCATE_PROMPT_1S;     
            loc_task  = BIT_SRF | BIT_FORM;    
          }
        }
        else
        {
          txt_index = SEL_OPT_EXIT;
          loc_task  = BIT_FORM; 
        }

      case LOCATE_1_S:
        if (me->state == LOCATE_1_S)
        {
          me->modify = FALSE;
          txt_index = LOCATE_PROMPT_1S;     
          loc_task  = BIT_SRF | BIT_FORM;    
        }

      case LOCATE_1_V:
        if (me->state == LOCATE_1_V)
        {
          if ((NEW_MODY & me->bl_sf_control) && me->HDbd_f_par.HDbd_srf1.crv_vec_s)
          {
            txt_index = ENTER_PROMPT_IBV1;     
            loc_task  = BIT_CRV | BIT_FORM | BIT_VEC; 
          }
          else
          {
            me->state++;
            break;
          }
        }

      case LOCATE_1_P1:
        if (me->state == LOCATE_1_P1)
        {
          if ((NEW_MODY & me->bl_sf_control) && me->HDbd_f_par.HDbd_srf1.partial)
          {
            txt_index = ENTER_PROMPT_PB1S;     
            loc_task  = BIT_PNT | BIT_FORM;   
          }
          else
          {
            me->state = LOCATE_2_CS;
            break;
          }
        }

      case LOCATE_1_P2:
        if (me->state == LOCATE_1_P2)
        {
            txt_index = ENTER_PROMPT_PB2E;     
            loc_task  = BIT_PNT | BIT_FORM;   
        }

      case LOCATE_2_CS: 
        if (me->state == LOCATE_2_CS)
        {
          me->modify = FALSE;          
          if (sf1_classid == OPP_EMAgenbs_class_id  && me->cv_flag1 == 0)
                                             txt_index = LOCATE_PROMPT_2M;
          else                               txt_index = LOCATE_PROMPT_2C;
          if (!me->global_assoc_flag)   txt_index = LOCATE_PROMPT_2C;

          if (me->HDbd_f_par.HDbd_srf2.exicrv > 1)
          {
            if (NEW_MODY & me->bl_sf_control)
            {
              loc_task = BIT_CRV | BIT_FORM;
              txt_index = ENTER_PROMPT_BLC2;
            }
          }
          else loc_task = BIT_CRV | BIT_SRF | BIT_FORM;
          if (me->HDbd_f_par.HDbd_srf2.partial)  me->state = LOCATE_2_S;
        }

      case LOCATE_2_S: 
        if (me->state == LOCATE_2_S)
        {          
          txt_index = LOCATE_PROMPT_2S;     
          loc_task  = BIT_SRF | BIT_FORM;   
        }

      case LOCATE_2_V:
        if (me->state == LOCATE_2_V)
        {
          if ((NEW_MODY & me->bl_sf_control) && me->HDbd_f_par.HDbd_srf2.crv_vec_s)
          {
            txt_index = ENTER_PROMPT_IBV2;     
            loc_task  = BIT_CRV | BIT_FORM | BIT_VEC; 
          }
          else
          {
            me->state++;
            break;
          }
        }

      case LOCATE_2_P1:
        if (me->state == LOCATE_2_P1)
        {
          if ((NEW_MODY & me->bl_sf_control) && me->HDbd_f_par.HDbd_srf2.partial)
          {
            txt_index = ENTER_PROMPT_PB2S;     
            loc_task  = BIT_PNT | BIT_FORM;   
          }
          else
          {
            me->state = GENERATE;
            break;
          }
        }

      case LOCATE_2_P2:
        if (me->state == LOCATE_2_P2)
        {
            txt_index = ENTER_PROMPT_PB2E;     
            loc_task  = BIT_PNT | BIT_FORM;   
        }
  
        /*  Locate the object  (curve or surface) */
        sts = locateObject(&loc_msg,
                           loc_task,
                           txt_index,        
                           &me->locate_event[me->source],
                           &me->accept_event[me->source],
                           response, response_data,
                           &wrk_classid,
                           &sel_typ,
                           sel_vect);
        if(! (1 & sts)) goto wrapup;
        if (loc_msg)
        {
          if (   !(sel_typ == SEL_CRV && (loc_task & BIT_CRV))
              && !(sel_typ == SEL_SRF && (loc_task & BIT_SRF))
              && !(sel_typ == SEL_PNT && (loc_task & BIT_PNT))  )
          {
            /*  tell user that selection was wrong type */
            sts = ex$message(msgnumb = RELOCATE_PROMPT,
                             field   = ERROR_FIELD);
            break;
          }       

          /*  Half highlight the located object  */
          sts = dp$display(msg  = &loc_msg,
                           oids = &me->accept_event[me->source].located_object[0].located_obj,
                           mode = GRhhd);  
          if (!(1 & sts & loc_msg))  goto wrapup;
        }

        else loc_msg = EMS_S_Success;      /* Reset loc_msg */

        if (me->accept_event[me->source].response == EX_FORM_FINISHED)
        {
          /*  update data from form  */
          HDbs_cp_f_data(1, &me->HDbd_f_par);
        }


        /*
         * Set state based on response:
         *  EX_VALUE: go to the next state
         *  EX_BACK_UP (except initial state): go to last state
         * If the accept event is unknown, the locate event is checked.
         */

        if (me->locate_event[me->source].response == EX_RJT_MOVEON
            &&  txt_index == LOCATE_PROMPT_2M)
        {
          if (sf1_classid == OPP_EMAgenbs_class_id)
          {
            me->blend_grid = me->accept_event[0].located_object[0].located_obj;
            me->state = EXT_MODIFY;           /*  = external modify entry  */
            break;
          }
          else
          {
            /*  is not a associative blend surface class  */
            break;
          }
        }

        if(me->accept_event[me->source].response == EX_DATA)
        {
          /*  good first selection  */
          if (me->state == LOCATE_1_CS)
          {
            /*  clear option message field when new blend starts  */
            sts = ex$message (msgnumb = EMS_I_ClearStatusField ); 
            if (me->bl_sf_control == NULL)
            {
              me->HDbd_f_par.HDbd_srf1.exicrv    = 0;       /*  natural blend */
              me->HDbd_f_par.HDbd_srf1.t_sensi   = 1.0;
              me->HDbd_f_par.HDbd_srf1.curv_c    = FALSE;

              me->HDbd_f_par.HDbd_srf1.t_auto    = FALSE;
              me->HDbd_f_par.HDbd_srf1.t_screen  = TRUE;
              me->HDbd_f_par.HDbd_srf1.t_copy    = FALSE;
              me->HDbd_f_par.HDbd_srf1.t_keyin   = FALSE;
              me->HDbd_f_par.HDbd_srf1.partial   = 0;

              me->HDbd_f_par.HDbd_srf1.crv_u     = FALSE;
              me->HDbd_f_par.HDbd_srf1.crv_v     = FALSE;
              me->HDbd_f_par.HDbd_srf1.crv_ruled = TRUE;
              me->HDbd_f_par.HDbd_srf1.crv_vec_s = FALSE;
              me->HDbd_f_par.HDbd_srf1.crv_perp  = FALSE;    
              me->HDbd_f_par.HDbd_srf1.crv_vec_d = FALSE;
    
              me->HDbd_f_par.HDbd_srf1.approx    = 0.0;            

              /*  preset 2nd surface with the same values  */
              me->HDbd_f_par.HDbd_srf2 = me->HDbd_f_par.HDbd_srf1;

              me->HDbd_f_par.HDbd_mode      = 1;  
              me->HDbd_f_par.HDbd_diagnos   = FALSE;  
              me->HDbd_f_par.HDbd_symmetric = FALSE;  
              me->HDbd_f_par.HDbd_srf_twist = FALSE;  
              me->HDbd_f_par.HDbd_minrad    = 0.1;  
              me->HDbd_f_par.HDbd_order     = 4;  
              me->HDbd_f_par.HDbd_poles     =  me->HDbd_f_par.HDbd_order +  
                                          2 * (me->HDbd_f_par.HDbd_srf1.curv_c 
                                             | me->HDbd_f_par.HDbd_srf2.curv_c);

              /*  preset first hedgehog position parameters  */
              me->last_blend.hd_index     = 0;        /*  use any edge (0-3) */
              me->last_blend.hd_cur_param = 0.5;      /*  use middle         */

              /*  fill form function with actual form values  */ 
              HDbd_cp_f_data(0, &me->HDbd_f_par);

              me->cv_flag1 = me->cv_flag2 = 0;     /* reset int curve flag  */
            } 

            /*  return space from last blend cycle  */
            if (me->b_start_cond.surface) { free(me->b_start_cond.surface);  me->b_start_cond.surface = NULL; }
            if (me->b_ende_cond.surface)  { free(me->b_ende_cond.surface);  me->b_ende_cond.surface  = NULL; }

            /*  get window info  */
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
                {  me->rot_mat[l] = rot_matrix[k+i];  l++;  }
              k = k + 4;
            }

            /*  calculate work view zoom faktor  */
            if (ABS(rot_matrix[0]) > epsw) me->disp_fakt = mat_wtv[0] / rot_matrix[0];
            else
            if (ABS(rot_matrix[1]) > epsw) me->disp_fakt = mat_wtv[1] / rot_matrix[1];
            else                           me->disp_fakt = mat_wtv[2] / rot_matrix[2];

          }
      

          if (sel_typ == SEL_SRF)
          { 
            if (me->state == LOCATE_1_CS  ||  me->state == LOCATE_1_S)
            {
              sf1_classid = wrk_classid;
              me->indx_sf1 = me->source;
              me->source++;
              if (me->state == LOCATE_1_CS)  me->state++;    /*  skip next  */
            }
            if (me->state == LOCATE_2_CS  ||  me->state == LOCATE_2_S)
            {
              sf2_classid = wrk_classid;
              me->indx_sf2 = me->source;
              me->source++;
              if (me->state == LOCATE_2_CS)  me->state++;    /*  skip next  */
            }
            me->modify = FALSE;
          }

          if (sel_typ == SEL_CRV) 
          {
            {
              if (me->state == LOCATE_1_CS)
              {
                /*  save inner blend curve  */
                me->cv_flag1 = -1;
                me->curve1 = me->accept_event[me->source].located_object[0];
                par_iso1 = 0.0;
                me->HDbd_f_par.HDbd_srf1.exicrv = 2;
                me->indx_cv1 = me->source;
                me->source++;
              }
              if (me->state == LOCATE_1_V)
              {
                dir_vec1[0][0] = sel_vect[0];
                dir_vec1[0][1] = sel_vect[1];
                dir_vec1[0][2] = sel_vect[2];
                me->dir_flag1 = 4;
                me->HDbd_f_par.HDbd_srf1.exicrv = 2;
                me->indx_ve1 = me->source;
                me->source++; 
              }

              if (me->state == LOCATE_2_CS)
              {
                /*  save inner blend curve  */
                me->cv_flag2 = -1;
                me->curve2 = me->accept_event[me->source].located_object[0];
                par_iso2 = 0.0;
                me->HDbd_f_par.HDbd_srf2.exicrv = 2;
                me->indx_cv2 = me->source;
                me->source++; 
              }
              if (me->state == LOCATE_2_V)
              {
                dir_vec2[0][0] = sel_vect[0];
                dir_vec2[0][1] = sel_vect[1];
                dir_vec2[0][2] = sel_vect[2];
                me->dir_flag2 = 4;
                me->HDbd_f_par.HDbd_srf2.exicrv = 2;
                me->indx_ve2 = me->source;
                me->source++; 
              }
            }
          }

          if (loc_task & BIT_PNT)
          {
            if (me->state == LOCATE_1_P1)  me->indx_pa1 = me->source;
            if (me->state == LOCATE_2_P1)  me->indx_pa2 = me->source;
            me->source++;
          }
          me->state++;
          break;      
        }

        if (me->accept_event[me->source].response == EX_BACK_UP)
        {
          dp$erase_hilite(msg = &loc_msg);
          if (me->state > LOCATE_1_CS)
          {
            if (me->state > LOCATE_1_S)
            {
              if (me->state > LOCATE_2_CS  &&  me->cv_flag1 == -1)
              {
                sts = dp$display(msg  = &loc_msg,
                                 mode = GRhhd,
                                 oids = &me->curve1.located_obj);
              }
              if ( (me->state > LOCATE_1_S  &&  me->cv_flag1 == -1) 
                 || me->state == LOCATE_2_S)
              {
                sts = dp$display(msg  = &loc_msg,
                                 mode = GRhhd,
                                 oids = &me->accept_event[0].located_object[0].located_obj);
              }
            }
            if (me->state > 0)  me->state--;
            if (me->state == LOCATE_1_P2 && !me->HDbd_f_par.HDbd_srf1.partial)
                                                       me->state = LOCATE_1_S;
            if (me->state == LOCATE_2_P2 && !me->HDbd_f_par.HDbd_srf2.partial)
                                                       me->state = LOCATE_2_S;
            if (me->state == LOCATE_1_S  &&  me->cv_flag1 == 0) 
                                                      me->state = LOCATE_1_CS;
            if (me->state == LOCATE_2_S  &&  me->cv_flag2 == 0) 
                                                      me->state = LOCATE_2_CS;
            if (me->state <= LOCATE_1_S)   me->cv_flag1 = 0;
            if (me->state <= LOCATE_2_CS)  me->cv_flag2 = 0;
          }
          break;                    
        }


        if (me->accept_event[me->source].response == EX_FORM_FINISHED)
        {
          if (me->state == LOCATE_1_CS &&   me->blend_grid.objid != NULL_OBJID)
          {
            me->state = MODIFY_FORM;
            break;
          }
          else
          {
            /*  get data from form  */
            HDbs_cp_f_data(1, &me->HDbd_f_par);
            if (!me->HDbd_f_par.HDbd_accept)
            {
              me->modify = FALSE;
              me->state = LOCATE_1_CS;
              return (TRUE);
            }
          }
        }

        if(me->accept_event[me->source].response == GR_UNKNOWN_TYPE)
        {   
          return( OM_S_SUCCESS );   /*  let command server handle it  */
        }

      break;



      /* ----------------------------------------- */
      /*       B L E N D   G E N E R A T E         */
      /* ----------------------------------------- */

      case GENERATE:
      {
        /*  Erase the located elements  */ 
        dp$erase_hilite(msg = &loc_msg);
        me->bl_sf_control = NULL; 
    
        /*  take all selected values  */
        me->cur_grid_sf1 = me->accept_event[me->indx_sf1].located_object[0].located_obj;
        me->cur_grid_sf2 = me->accept_event[me->indx_sf2].located_object[0].located_obj;     
        me->last_surface_1 = me->cur_grid_sf1.objid;
        me->last_surface_2 = me->cur_grid_sf2.objid;
        par_sf1u = me->accept_event[me->indx_sf1].located_object[0].geom_parms.u;
        par_sf1v = me->accept_event[me->indx_sf1].located_object[0].geom_parms.v;
        par_sf2u = me->accept_event[me->indx_sf2].located_object[0].geom_parms.u;
        par_sf2v = me->accept_event[me->indx_sf2].located_object[0].geom_parms.v;
        me->cur_module_info_sf1 = me->accept_event[me->indx_sf1].located_object[0].module_info;
        me->cur_module_info_sf2 = me->accept_event[me->indx_sf2].located_object[0].module_info;

        /*  Construct the blend        */
        /*  Set up the construct list  */ 

        blend_cnst.msg        = &blend_msg;
        blend_cnst.env_info   = &blend_env;
        blend_cnst.newflag    = FALSE;
        blend_cnst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        blend_cnst.geometry   = NULL;       
        blend_cnst.display    = &blend_dis;
        blend_cnst.class_attr = (IGRchar *) &attr; 
        blend_cnst.name = NULL;
        /*  preset attributes  */
          attr.u_rules = 2;
          attr.v_rules = 2;
          attr.is_polydis = FALSE;
          attr.is_surfdis = TRUE;
          attr.is_slowdis = FALSE;
          attr.type = NULL;

        sts = gr$get_active_layer  (msg = &blend_msg, buffer = &blend_cnst.level);
        sts = gr$get_module_env    (msg = &blend_msg, buffer = &blend_env);
        sts = gr$get_active_display(msg = &blend_msg, buffer = &blend_dis);

        /*  initialize some values  */
        blend_order = me->HDbd_f_par.HDbd_order;
        par_cv1[0]     = 0.0;          /*  use whole side  */
        par_cv1[1]     = 1.0;          /*  use whole side  */
        par_iso1       = 0.0;
        ratio1         = -1.0;               
        cont1          = 1;

        par_cv2[0]     = 0.0;          /*  use whole side  */
        par_cv2[1]     = 1.0;          /*  use whole side  */
        par_iso2       = 0.0;
        ratio2         = -1.0;       
        cont2          = 1; 

        dir_vec2[1][0] = 0.0;          /*  preset  */
        dir_vec2[1][1] = 1.0;          /*  preset  */
        dir_vec2[1][2] = 0.0;          /*  preset  */

        
        /*  calculate edge number from surface selection point  */

        /*  surface 1  preparation  */
        if (!me->cv_flag1)
        {
          if (par_sf1u <= 0.5)  {  iu1 = 2;   xu1 = par_sf1u;  }
          else                  {  iu1 = 4;   xu1 = 1.0 - par_sf1u;  }

          if (par_sf1v <= 0.5)  {  iv1 = 1;   xv1 = par_sf1v;  }
          else                  {  iv1 = 3;   xv1 = 1.0 - par_sf1v;  }


          if (xu1 < xv1)  {  par_iso1 = par_sf1u;   me->cv_flag1 = iu1;  }
          else            {  par_iso1 = par_sf1v;   me->cv_flag1 = iv1;  }

          if (par_iso1 <= 0.5)  par_iso1 = 0.0;
          else                  par_iso1 = 1.0;  
        }

        if (me->cv_flag1 > 0)
        {
          if (me->cv_flag1 == 1  ||  me->cv_flag1 == 3)
                           {   par_u = 0.5;       par_v = par_iso1;  ind = 1;  }
          else             {   par_u = par_iso1;  par_v = 0.5;       ind = 2;  }
        }

 
        if (me->cv_flag1 > 0)
        {
          /*  extract surface_1 blend edge direction  */
          sts = BL_get_sf_vc(me->accept_event[me->indx_sf1].located_object[0].located_obj,
                            &me->accept_event[me->indx_sf1].located_object[0].module_info,
                            par_u, par_v, ind, pos1, vec_1, &closed_1); 

          if (sf1_classid == OPP_EMSsphere_class_id)
          {
            /*  avoid initial problems with sphere  */
            par_iso1 = 0.1;
            me->cv_flag1 = 6;   /*  use iso line (2) as preset  */
          }
        }
        else
        {
          /*  extract surface_1 blend curve direction  */
          sts = BL_get_sf_vc(me->curve1.located_obj,
                            &me->curve1.module_info,
                             0.5, 0.0, NULL, pos1, vec_1, &closed_1);
        }



        /*  surface 2  preparation  */
        if (!me->cv_flag2)
        { 
          if (par_sf2u <= 0.5)  {  iu2 = 2;   xu2 = par_sf2u;  }
          else                  {  iu2 = 4;   xu2 = 1.0 - par_sf2u;  }

          if (par_sf2v <= 0.5)  {  iv2 = 1;   xv2 = par_sf2v;  }
          else                  {  iv2 = 3;   xv2 = 1.0 - par_sf2v;  }

          if (xu2 < xv2)  {  par_iso2 = par_sf2u;   me->cv_flag2 = iu2;  }
          else            {  par_iso2 = par_sf2v;   me->cv_flag2 = iv2;  }

          if (par_iso2 <= 0.5)  par_iso2 = 0.0;
          else                  par_iso2 = 1.0;  
        }


        if (me->cv_flag2 > 0)
        {
          if (me->cv_flag2 == 1  ||  me->cv_flag2 == 3)
                           {   par_u = 0.5;       par_v = par_iso2;  ind = 1;  }
          else             {   par_u = par_iso2;  par_v = 0.5;       ind = 2;  }
        }
        if (me->cv_flag2 > 0)
        {
          /*  extract surface_2 blend edge direction  */
          sts = BL_get_sf_vc(me->accept_event[me->indx_sf2].located_object[0].located_obj,
                             &me->accept_event[me->indx_sf2].located_object[0].module_info,
                             par_u, par_v, ind, pos2, vec_2, &closed_2); 
       
          if (sf2_classid == OPP_EMSsphere_class_id)
          {
            /*  avoid initial problems with sphere  */
            par_iso2 = 0.1;
            me->cv_flag2 = 6;   /*  use iso line (2) as preset  */
          }

        }
        else
        {
          /*  extract surface_2 blend curve direction  */
          sts = BL_get_sf_vc(me->curve2.located_obj,
                            &me->curve2.module_info,
                             0.5, 0.0, NULL, pos2, vec_2, &closed_2);
        }


        if (me->HDbd_f_par.HDbd_srf1.partial)
        {
          /*  recalculate partial blend parameter  */
          p_point1s = &me->accept_event[me->indx_pa1].located_object[0];
          me->b_start_inf.pb_point_s = *p_point1s;
          sts = ECblendsf_gt(&loc_msg,
                             me->accept_event[me->indx_sf1].located_object[0].located_obj,     
                             p_point1s->proj_pnt,  
                             &me->accept_event[me->indx_sf1].located_object[0].module_info,
                             me->cv_flag1,
                             &par_cv1[0]);

          p_point1e = &me->accept_event[me->indx_pa1+1].located_object[0];
          me->b_start_inf.pb_point_e = *p_point1e;
          sts = ECblendsf_gt(&loc_msg,
                             me->accept_event[me->indx_sf1].located_object[0].located_obj,     
                             p_point1e->proj_pnt,  
                             &me->accept_event[me->indx_sf1].located_object[0].module_info,
                             me->cv_flag1,
                             &par_cv1[1]);

          if (par_cv1[0] > par_cv1[1])
          {
            p_point1s = &me->accept_event[me->indx_pa1+1].located_object[0];
            p_point1e = &me->accept_event[me->indx_pa1].located_object[0];
            me->b_start_inf.pb_point_s = *p_point1s;
            me->b_start_inf.pb_point_e = *p_point1e;
            temp = par_cv1[0];
            par_cv1[0] = par_cv1[1];
            par_cv1[1] = temp;
          }
          par_cv1[0] = -10.0 + par_cv1[0];
          par_cv1[1] = -10.0 + par_cv1[1];
        }
        else   p_point1s = p_point1e = NULL;

        if (me->HDbd_f_par.HDbd_srf2.partial)
        {
          /*  recalculate partial blend parameter  */
          p_point2s = &me->accept_event[me->indx_pa2].located_object[0];
          me->b_ende_inf.pb_point_s = *p_point2s;
          sts = ECblendsf_gt(&loc_msg,
                             me->accept_event[me->indx_sf2].located_object[0].located_obj,     
                             p_point2s->proj_pnt,  
                             &me->accept_event[me->indx_sf2].located_object[0].module_info,
                             me->cv_flag2,
                             &par_cv2[0]);

          p_point2e = &me->accept_event[me->indx_pa2+1].located_object[0];
          me->b_ende_inf.pb_point_e = *p_point2e;
          sts = ECblendsf_gt(&loc_msg,
                             me->accept_event[me->indx_sf2].located_object[0].located_obj,     
                             p_point2e->proj_pnt,  
                             &me->accept_event[me->indx_sf2].located_object[0].module_info,
                             me->cv_flag2,
                             &par_cv2[1]);

          if (par_cv2[0] > par_cv2[1])
          {
            p_point2s = &me->accept_event[me->indx_pa2+1].located_object[0];
            p_point2e = &me->accept_event[me->indx_pa2].located_object[0];
            me->b_ende_inf.pb_point_s = *p_point2s;
            me->b_ende_inf.pb_point_e = *p_point2e;
            temp = par_cv2[0];
            par_cv2[0] = par_cv2[1];
            par_cv2[1] = temp;
          }
          par_cv2[0] = -10.0 + par_cv2[0];
          par_cv2[1] = -10.0 + par_cv2[1];
        }
        else   p_point2s = p_point2e = NULL;


        /*  set un-twisted blend direction  */
        if (BSdotp(&rc, vec_1, vec_2) < 0.0)
        { 
          IGRdouble  temp;
          /*  twist blend direction of second edge */
          temp       = par_cv2[0];
          par_cv2[0] = par_cv2[1];
          par_cv2[1] = temp;

          if (me->HDbd_f_par.HDbd_srf2.partial)
          {
            p_point2x = p_point2s;
            p_point2s = p_point2e;
            p_point2e = p_point2x;
            me->b_ende_inf.pb_point_s = *p_point2s;
            me->b_ende_inf.pb_point_e = *p_point2e;
          }
        }



        /*  check for wrong combined selection  */
        if (me->accept_event[0].located_object[me->indx_sf1].located_obj.objid ==
            me->accept_event[1].located_object[me->indx_sf1].located_obj.objid)
        {
          /*  same surfaces  , check for same curves  */
          if (me->cv_flag1 == me->cv_flag2)
          {
            /*  same surfaces & cv_flag  */
            if (me->cv_flag1 > 0)
            {
              /*  same surfaces & same edges  */
              me->state = LOCATE_1_CS;
              sts = ex$message (msgnumb = ERROR_MESSAGE_NOINT);
              break;
            }
            else
            {
              if (me->curve1.located_obj.objid == me->curve2.located_obj.objid)
              {
                /*  same surfaces & same curves  */
                me->state = LOCATE_1_CS;
                sts = ex$message (msgnumb = ERROR_MESSAGE_NOINT);
                break;
              }
            }
          }
        }

        if (me->cv_flag1 == 0)  me->dir_flag1 =  3;  /*  for internal ruled  */
        if (me->cv_flag1 < 0)   me->dir_flag1 = ABS(me->dir_flag1);
        if (ABS(me->dir_flag1) != 4)
        {
          if (me->cv_flag1 > 0)   me->dir_flag1 = -1;  /*  away from surface  */ 
          BSmkvec(&rc, dir_vec1[0], pos1, pos2);
          BSnorvec(&rc, dir_vec1[0]);
        }

        if (me->cv_flag2 == 0)  me->dir_flag2 =  3;  /*  for internal ruled  */
        if (me->cv_flag2 < 0)   me->dir_flag2 = ABS(me->dir_flag2);
        if (ABS(me->dir_flag2) != 4)
        {
          if (me->cv_flag2 > 0)   me->dir_flag2 = -1;  /*  away from surface  */ 
          BSmkvec(&rc, dir_vec2[0], pos2, pos1);
          BSnorvec(&rc, dir_vec2[0]);
        }


        /*  save initial cv_flag  */
        me->last_blend.init_cv1_flag = me->cv_flag1;
        me->last_blend.init_cv2_flag = me->cv_flag2;

        if (!(NEW_MODY & me->bl_sf_control))
        {
          /*  check if both internal blend curves are closed  */
          if (  me->cv_flag1 < 0  &&  me->cv_flag2 < 0
             && closed_1  && closed_2)
          {
            me->dir_flag1 = 5;                  /*  for internal perpendicular  */
	    me->HDbd_f_par.HDbd_srf1.crv_ruled = FALSE;
            me->HDbd_f_par.HDbd_srf1.crv_perp  = TRUE;
            me->dir_flag2 = 5;                  /*  for internal perpendicular  */
	    me->HDbd_f_par.HDbd_srf2.crv_ruled = FALSE;
            me->HDbd_f_par.HDbd_srf2.crv_perp  = TRUE;
          }
        }

        /*  preset approximation flag  */
        approx_flag1  = 0;
        approx_flag2  = 0;
        approx_fact1  = 0.0;
        approx_fact2  = 0.0; 

        ex$message(msgnumb = GR_I_Processing);

        /*****************************/
        /*  calculate blend surface  */
        /*****************************/
        sts = ec$blend_surfaces( 
                  msg            = &loc_msg,
                  surface1       = &me->accept_event[me->indx_sf1].located_object[0],
                  curve1         = &me->curve1,
                  p_point1s      = p_point1s,
                  p_point1e      = p_point1e,
                  cv_flag1       = me->cv_flag1,
                  cont1          = cont1,
                  approx_flag1   = approx_flag1,
                  approx_fact1   = approx_fact1,
                  tangent_flag1  = -2,       /*  calculate value for first run  */
                  ratio1         = &ratio1,
                  par_iso1       = par_iso1,
                  par_cv1        = par_cv1,
                  dir_flag1      = me->dir_flag1,
                  dir_vec1       = dir_vec1,
                  surface2       = &me->accept_event[me->indx_sf2].located_object[0],
                  curve2         = &me->curve2,
                  p_point2s      = p_point2s,
                  p_point2e      = p_point2e,
                  cv_flag2       = me->cv_flag2,
                  cont2          = cont2,
                  approx_flag2   = approx_flag2,
                  approx_fact2   = approx_fact2,
                  tangent_flag2  = -2,       /*  calculate value for first run  */
                  ratio2         = &ratio2,
                  par_iso2       = par_iso2,
                  par_cv2        = par_cv2,
                  dir_flag2      = me->dir_flag2,
                  dir_vec2       = dir_vec2,
                  blend_order    = blend_order,
                  construct_list = &blend_cnst,  
                  blend_os       = &me->blend_grid.osnum,
                  blend_id       = &me->blend_grid.objid); 
        if(! (1 & sts & loc_msg)) goto wrapup;

        om$objid_to_tag(osnum = me->blend_grid.osnum, 
                        objid = me->blend_grid.objid,
                        p_tag = &me->blend_tag);

        /*  display the blend surface  */
        sts = dp$display(msg  = &loc_msg,
                         mode = GRbd,
                         oids = &me->blend_grid);
        if(! (1 & sts & loc_msg)) goto wrapup;


        /* ------------------------ */
        /*  new blend surface done  */
        /* ------------------------ */

        /*  return space from last blend cycle  */
        if (me->b_start_cond.surface) { free(me->b_start_cond.surface);  me->b_start_cond.surface = NULL; }
        if (me->b_ende_cond.surface)  { free(me->b_ende_cond.surface);  me->b_ende_cond.surface  = NULL; }


        sts = ex$message (msgnumb = EMS_I_ClearStatusField ); 
        if (NEW_MODY & me->bl_sf_control)
        {
          me->state = MODIFY_NO_FORM;
          /*  reset modify control flags  */ 
          me->HDbd_f_par.HDbd_undolm = 0;
          me->HDbd_f_par.HDbd_srf1.ratio = base_ratio1;
          me->HDbd_f_par.HDbd_srf2.ratio = base_ratio2;
          /*  force new parial blend points select  */
          me->HDbd_f_par.HDbd_srf1.partial &= 1;
          me->HDbd_f_par.HDbd_srf2.partial &= 1;
          /*  force new internal blend curve select  */
          if (me->HDbd_f_par.HDbd_srf1.exicrv > 2)
                                         me->HDbd_f_par.HDbd_srf1.exicrv = 4;
          if (me->HDbd_f_par.HDbd_srf2.exicrv > 2)
                                         me->HDbd_f_par.HDbd_srf2.exicrv = 4;
          me->number_modify = NULL;
        }  
        else
        {
          me->state = LOCATE_1_CS;
          me->HDbd_f_par.HDbd_srf1.ratio = base_ratio1;
          me->HDbd_f_par.HDbd_srf2.ratio = base_ratio2;
          HDbs_cp_f_data(0, &me->HDbd_f_par);
        }  
      }
      break;


  

      /* ------------------------------------------------------- */
      /*     E X T E R N A L   B L E N D   M O D I F Y           */
      /* ------------------------------------------------------- */

      case EXT_MODIFY:
      {  
        struct GRmd_env     blend_env; 
        struct GRid         cur_blend;

        GRstatus_display_button(FALSE);

        me->wrk_mode = 1;
        me->number_modify = 0;
        me->modify = TRUE;
        cur_blend = me->blend_grid;

        om$objid_to_tag(osnum = me->blend_grid.osnum, 
                        objid = me->blend_grid.objid,
                        p_tag = &me->blend_tag);

        sts = gr$get_module_env  (msg = &loc_msg, buffer = &blend_env);

        /*  first call to read all assoc data in  */
        me->b_start_cond.surface = NULL;   /*  force basic read  */
        me->b_ende_cond.surface  = NULL;   /*  force basic read  */

        sts = ECblendsf_m(&loc_msg, &cur_blend, &blend_env, &me->HDbd_f_par,
                          response, response_data,
                          &me->b_start_cond, &me->b_ende_cond,
                          &me->b_start_inf, &me->b_ende_inf,
                          &me->last_blend, &me->last_but_one_blend,
                          &me->rot_mat[0], &me->disp_fakt,
                          &dyn_status);

        /*************************************/
        /*  preset form for modify existing  */
        /*************************************/

        me->last_blend.init_cv1_flag = me->b_start_cond.boundary_flag;
        me->last_blend.init_cv2_flag = me->b_ende_cond.boundary_flag;

        me->cur_grid_sf1 = me->b_start_inf.base_srf.located_obj;
        me->cur_grid_sf2 = me->b_ende_inf.base_srf.located_obj;
        me->cur_module_info_sf1 = me->b_start_inf.base_srf.module_info;
        me->cur_module_info_sf2 = me->b_ende_inf.base_srf.module_info;

        /*  preset form with last used values  */
        me->HDbd_f_par.HDbd_srf1.ratio = base_ratio1 = me->b_start_cond.tangent_value[1];
        me->HDbd_f_par.HDbd_srf2.ratio = base_ratio2 = me->b_ende_cond.tangent_value[1];

        if (me->b_start_cond.boundary_flag > 0)
        {
          if (me->b_start_cond.pariso > 0.0 && me->b_start_cond.pariso < 1.0)
            me->HDbd_f_par.HDbd_srf1.exicrv = 1;
        }
        else
          me->HDbd_f_par.HDbd_srf1.exicrv = 2;

        if (me->b_ende_cond.boundary_flag > 0)
        {
          if (me->b_ende_cond.pariso > 0.0 && me->b_ende_cond.pariso < 1.0)
              me->HDbd_f_par.HDbd_srf2.exicrv = 1;
        }
        else
          me->HDbd_f_par.HDbd_srf2.exicrv = 2;


        me->HDbd_f_par.HDbd_srf1.approx = me->b_start_cond.approx_fact;
        me->HDbd_f_par.HDbd_srf2.approx = me->b_ende_cond.approx_fact;

        me->HDbd_f_par.HDbd_srf1.curv_c = me->b_start_cond.curvature_flag;
        me->HDbd_f_par.HDbd_srf2.curv_c = me->b_ende_cond.curvature_flag;

        if (me->b_start_inf.pb_point_s.located_obj.objid != NULL_OBJID)
                                       me->HDbd_f_par.HDbd_srf1.partial = 1;
        if (me->b_ende_inf.pb_point_s.located_obj.objid != NULL_OBJID)
                                       me->HDbd_f_par.HDbd_srf2.partial = 1;

        me->HDbd_f_par.HDbd_srf1.crv_u     = FALSE;
        me->HDbd_f_par.HDbd_srf1.crv_v     = FALSE;
        me->HDbd_f_par.HDbd_srf1.crv_ruled = FALSE;
        me->HDbd_f_par.HDbd_srf1.crv_perp  = FALSE;
        me->HDbd_f_par.HDbd_srf1.crv_vec_s = FALSE;
        me->HDbd_f_par.HDbd_srf1.crv_vec_d = FALSE;

        wrk_dir = ABS(me->b_start_cond.direction);
        if (wrk_dir == 1)  me->HDbd_f_par.HDbd_srf1.crv_u     = TRUE;
        if (wrk_dir == 2)  me->HDbd_f_par.HDbd_srf1.crv_v     = TRUE;
        if (wrk_dir == 3)  me->HDbd_f_par.HDbd_srf1.crv_ruled = TRUE;
        if (wrk_dir == 4)  me->HDbd_f_par.HDbd_srf1.crv_vec_s = TRUE;
        if (wrk_dir == 5)  me->HDbd_f_par.HDbd_srf1.crv_perp  = TRUE;
        if (wrk_dir == 6)  me->HDbd_f_par.HDbd_srf1.crv_vec_d = TRUE;

        me->HDbd_f_par.HDbd_srf2.crv_u     = FALSE;
        me->HDbd_f_par.HDbd_srf2.crv_v     = FALSE;
        me->HDbd_f_par.HDbd_srf2.crv_ruled = FALSE;
        me->HDbd_f_par.HDbd_srf2.crv_perp  = FALSE;
        me->HDbd_f_par.HDbd_srf2.crv_vec_s = FALSE;
        me->HDbd_f_par.HDbd_srf2.crv_vec_d = FALSE;

        wrk_dir = ABS(me->b_ende_cond.direction);
        if (wrk_dir == 1)  me->HDbd_f_par.HDbd_srf2.crv_u     = TRUE;
        if (wrk_dir == 2)  me->HDbd_f_par.HDbd_srf2.crv_v     = TRUE;
        if (wrk_dir == 3)  me->HDbd_f_par.HDbd_srf2.crv_ruled = TRUE;
        if (wrk_dir == 4)  me->HDbd_f_par.HDbd_srf2.crv_vec_s = TRUE;
        if (wrk_dir == 5)  me->HDbd_f_par.HDbd_srf2.crv_perp  = TRUE;
        if (wrk_dir == 6)  me->HDbd_f_par.HDbd_srf2.crv_vec_d = TRUE;

        me->HDbd_f_par.HDbd_symmetric = FALSE;     /*  is better  */

        /*  fill form function with (new) actual form values  */
        HDbs_cp_f_data(0, &me->HDbd_f_par);


        /*  display option form */
        sts = HDbs_display_status_form(TRUE);

        me->state = WAIT_FORM;
        break;
      }

       

      case WAIT_FORM:
      {
        /*  wait for event  */
        sts = co$getevent(msg           = &loc_msg,
                          event_mask    = GRm_FORM_FINISHED,
                          msgnum        = SEL_OPT_EXIT,
                          response      = response,
                          response_data = response_data,    
                          event         = &param_event);
            
        if ( ( *response == EX_FORM_FINISHED  ||  *response == EX_RJT_MOVEON 
           ||  param_event.response == EX_FORM_FINISHED ) ) 
        {
          me->state = MODIFY_FORM;
        }
        else
        {
          ex$message(msgnumb = GR_I_InpDiscard);
        }

      break;
      }
      

      /* ----------------------------------------- */
      /*         B L E N D   M O D I F Y           */
      /* ----------------------------------------- */

      case MODIFY_FORM:
      case MODIFY_NO_FORM:
      {
        struct GRmd_env     blend_env;  
        IGRlong             num_bytes;       /*  size of surface  */



        if (me->state == MODIFY_FORM)
        {
          /*  get data from form  */
          HDbs_cp_f_data(1, &me->HDbd_f_par);
          if (!me->HDbd_f_par.HDbd_accept)
          {
            me->modify = FALSE;
            me->state = LOCATE_1_CS;
            return (TRUE);
          }
        }

        me->modify = TRUE; 
        GRstatus_display_button(TRUE);
        me->bl_sf_control = (!NEW_MODY) & me->bl_sf_control; 
 
        /*  prepare main surfaces data  */
        if (me->b_start_cond.surface == NULL)
        { 
          /*  get basic surface data  */
          sts = om$send(mode = OM_e_wrt_object,
                        msg  = message GRvg.GRgetsize (
                                 &loc_msg, 
                                 &me->cur_module_info_sf1.md_env.matrix_type, 
                                 me->cur_module_info_sf1.md_env.matrix,
                                 &num_bytes ),
                        senderid = NULL,
                        targetid = me->cur_grid_sf1.objid,
                        targetos = me->cur_grid_sf1.osnum);
          if (!sts)  goto wrapup; 

          me->b_start_cond.surface = (struct IGRbsp_surface *) malloc(num_bytes);
          if (!me->b_start_cond.surface) goto wrapup;
 
          sts = om$send(mode = OM_e_wrt_object,
                        msg  = message GRvg.GRgetgeom
                                 (&loc_msg,
                                 &me->cur_module_info_sf1.md_env.matrix_type,
                                 me->cur_module_info_sf1.md_env.matrix,
                                (IGRchar *) me->b_start_cond.surface),
                       senderid = NULL,
                       targetid = me->cur_grid_sf1.objid,
                       targetos = me->cur_grid_sf1.osnum);
         if (!sts)  goto wrapup;

        }

        if (me->b_ende_cond.surface == NULL)
        {
          /*  get basic surface data  */
          sts = om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRgetsize (
                                &loc_msg,
                                &me->cur_module_info_sf2.md_env.matrix_type,
                                me->cur_module_info_sf2.md_env.matrix,
                                &num_bytes ),
                senderid = NULL,
                targetid = me->cur_grid_sf2.objid,
                targetos = me->cur_grid_sf2.osnum);
          if (!sts)  goto wrapup; 
 
          me->b_ende_cond.surface = (struct IGRbsp_surface *) malloc(num_bytes);
         if (!me->b_ende_cond.surface) goto wrapup;

          sts = om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRgetgeom
                                (&loc_msg,
                                &me->cur_module_info_sf2.md_env.matrix_type,
                                me->cur_module_info_sf2.md_env.matrix,
                               (IGRchar *) me->b_ende_cond.surface),
                senderid = NULL,
                targetid = me->cur_grid_sf2.objid,
                targetos = me->cur_grid_sf2.osnum);
          if (!sts)  goto wrapup;    
        }

        /*  extract objid from blend tag  */
        om$tag_to_objid(osnum   = me->blend_grid.osnum,
                        tag     = me->blend_tag, 
                        p_objid = &me->blend_grid.objid);
 
        sts = gr$get_module_env  (msg = &loc_msg, buffer = &blend_env);

        sts_m = ECblendsf_m(&loc_msg, &me->blend_grid, &blend_env, &me->HDbd_f_par,
                          response, response_data,
                          &me->b_start_cond, &me->b_ende_cond,
                          &me->b_start_inf, &me->b_ende_inf,
                          &me->last_blend, &me->last_but_one_blend,
                          &me->rot_mat[0], &me->disp_fakt,
                          &dyn_status);


        if (me->b_start_cond.surface) { free (me->b_start_cond.surface); me->b_start_cond.surface = NULL; }
        if (me->b_ende_cond.surface)  { free (me->b_ende_cond.surface);  me->b_ende_cond.surface  = NULL; }

        me->modify = FALSE;
        me->last_modify_sts  = sts_m;
   
        if(!(1&loc_msg&sts_m)) goto wrapup;  

        if (me->blend_grid.objid == NULL)
        {
          /*  modify was UNDO ---> delete  */
          me->state = INIT;
          return (TRUE)	;
        }

        if (sts_m == END_BY_CMD)
        {
          /*  if non modify command input, let command server handle it  */
          me->state = LOCATE_1_CS;
          me->modify = FALSE;
          return( OM_S_SUCCESS );
        }

        om$objid_to_tag(osnum = me->blend_grid.osnum, 
                        objid = me->blend_grid.objid,
                        p_tag = &me->blend_tag);

        me->number_modify++;

        /*  reset modify control flags  */ 
        me->HDbd_f_par.HDbd_undolm = 0;
        me->HDbd_f_par.HDbd_srf1.ratio = base_ratio1;
        me->HDbd_f_par.HDbd_srf2.ratio = base_ratio2;
        /*  force new parial blend points select  */
        me->HDbd_f_par.HDbd_srf1.partial &= 1;
        me->HDbd_f_par.HDbd_srf2.partial &= 1;
        /*  force new internal blend curve select  */
        if (me->HDbd_f_par.HDbd_srf1.exicrv > 2)
                                         me->HDbd_f_par.HDbd_srf1.exicrv = 2;
        if (me->HDbd_f_par.HDbd_srf2.exicrv > 2)
                                         me->HDbd_f_par.HDbd_srf2.exicrv = 2;

        if (sts_m == END_BY_CMD)
        {
          /*  fill form function with (new) actual form values  */ 
          HDbs_cp_f_data(0, &me->HDbd_f_par);
          /*  display option form */
          sts = HDbs_display_status_form(TRUE);
          me->state = WAIT_FORM;
        }
        else    me->state = LOCATE_1_CS;

        break;
      }


   default:
      sts = OM_E_ABORT;
      loc_msg = EMS_E_Fail;
      goto wrapup;
    }



  }

wrapup:
  /*  inform of problem:  command in message field  */
  sts = ex$message (msgnumb = ERROR_MESSAGE_NOINT);
  me->state = INIT;    
  return sts;
}




/*
Name

    method sleep

Abstract

    This is the sleep method for the command ECblendsf.

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

  /*  reset color of the associative lock icon */
  GRdisplay_associative_button(FALSE);
  /*  reset color of the option button  */
  GRstatus_display_button(FALSE);
  /*  Erase everything  */
  dp$erase_hilite(msg = &loc_msg);

  return OM_S_SUCCESS;
}




/*
Name

    method wakeup

Abstract

    This is the wakeup method for the command ECblendsf.

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
  IGRlong    loc_msg = EMS_S_Success;
  IGRlong    sts     = OM_S_SUCCESS;
  IGRint     last_locate_event, ii;
  IGRint     size;            
  IGRint     response;
  IGRchar    response_data[DUMMY_SIZE];
  IGRlong    loc_mx_type;
  IGRmatrix  *loc_mx_ptr;  


  sts = ex$message(field = MESSAGE_FIELD, msgnumb = COMMAND_TEXT);

  /*  get assiciative lock state  */
  gr$get_associative_flag(msg    = &loc_msg,
                          buffer = &me->global_assoc_flag);

  /*  set color of the associative lock icon to blue */
  GRdisplay_associative_button(me->global_assoc_flag);

  /*  set color of option icon  */
  GRstatus_display_button(TRUE);    

  last_locate_event = NULL;
  if ( me->state >= LOCATE_1_S)  last_locate_event = 1;
  if ( me->state >= LOCATE_2_S)  last_locate_event = 2;

  for (ii = 0; ii < last_locate_event; ii++)
  {
    /*  Half highlight the located object  */
    loc_mx_type = (IGRlong) me->accept_event[ii].located_object[0].
                            module_info.md_env.matrix_type;
    loc_mx_ptr = &me->accept_event[ii].located_object[0].module_info.md_env.
                  matrix;

    sts = dp$display(msg      = &loc_msg,
                     mtx_type = &loc_mx_type,
                     matrix   = &loc_mx_ptr,
                     oids = &me->accept_event[ii].located_object[0].located_obj,
                     mode = GRhhd);
    if(! (1 & sts & loc_msg)) goto wrapup;
  }
            
  if (me->state >= LOCATE_2_CS  &&  me->cv_flag1 == -1)
  {
    sts = dp$display(msg  = &loc_msg,
                     mode = GRhhd,
                     oids = &me->curve1.located_obj);
  }
   
     
  if (me->global_assoc_flag)                   /*  modify only if assoc  */ 
  {
    /*  go on with dynamic if interrupted there  */
    if (me->last_modify_sts == END_BY_CMD)
    {
      /*  fill form function with actual form values  */ 
      me->HDbd_f_par.HDbd_srf1.ratio  = base_ratio1;  /*  use newest value  */
      me->HDbd_f_par.HDbd_srf2.ratio  = base_ratio2;  /*  use newest value  */
      me->HDbd_f_par.HDbd_srf1.approx = base_approx1; /*  use newest value  */
      me->HDbd_f_par.HDbd_srf2.approx = base_approx2; /*  use newest value  */
      sts = ex$peek_event_queue(resp = &response);
      if (sts > 0)
      {
        /*  get the input  (without wait)  */
        size = DUMMY_SIZE;
        sts = ex$wait_for_input(response   = &response,
                                buffer     = response_data,    
                                byte       = (int *)&size);

        /*  fill form function with actual form values  */ 
        HDbs_cp_f_data(0, &me->HDbd_f_par);
        /*  display option form */
        sts = HDbs_display_status_form(TRUE);
        GRstatus_display_button(TRUE);
        me->state = WAIT_FORM;
        me->bl_sf_control |= NEW_MODY;
      }
      else
      {
        me->state = MODIFY_NO_FORM;
      }   
    }

    if (me->state >= LOCATE_1_CS  &&  me->state <= LOCATE_2_S)
    {
      sts = ex$peek_event_queue(resp = &response);
      if (response == STATUS_DISP)       /*  option  icon  */
      {
        /*  fill form function with actual form values  */ 
        me->HDbd_f_par.HDbd_srf1.ratio  = base_ratio1;  /*  use newest value  */
        me->HDbd_f_par.HDbd_srf2.ratio  = base_ratio2;  /*  use newest value  */
        me->HDbd_f_par.HDbd_srf1.approx = base_approx1; /*  use newest value  */
        me->HDbd_f_par.HDbd_srf2.approx = base_approx2; /*  use newest value  */
        /*  fill form function with actual form values  */
        HDbs_cp_f_data(0, &me->HDbd_f_par);
        /*  display option form */
        sts = HDbs_display_status_form(TRUE);
        /*  get data from form  */
        HDbs_cp_f_data(1, &me->HDbd_f_par);
        me->bl_sf_control |= NEW_MODY;
        if (me->state == INIT)  me->state = LOCATE_1_CS;
      }
    }
  }
  return sts;


wrapup:
  return sts;
}







method status_disp()
{
  IGRlong  sts = OM_S_SUCCESS;


  GRstatus_display_button(FALSE); 
  if (!me->modify  &&  me->blend_grid.objid != NULL_OBJID)
  {
    me->modify = TRUE;
    sts = ex$message (msgnumb = SEL_OPT_EXIT); 
    HDbs_display_status_form(TRUE);
    me->last_modify_sts  = NULL;
  }

  return sts;
}




method delete (int pos)
{
  IGRlong  sts;

  /*  reset color of the option icon  */
  GRstatus_display_button(FALSE);

  /*  return space if not done before  */
  if (me->b_start_cond.surface) { free (me->b_start_cond.surface); me->b_start_cond.surface = NULL; }
  if (me->b_ende_cond.surface)  { free (me->b_ende_cond.surface);  me->b_ende_cond.surface  = NULL; }
  sts = om$send(mode     = OM_e_wrt_message,   
                msg      = message Root.delete(1),
                targetid = my_id);
  
     
  return(OM_S_SUCCESS);
}












/*
Name

    ECblend_surfaces_api

Abstract

    This is the api function for placing a blend surface.

Synopsis

    IGRint  ECblend_surfaces_api(
                  IGRlong               *EMmsg,
                  struct GRlc_info      *surface1,
                  struct GRlc_info      *curve1,
                  struct GRlc_info      *p_point1s,
                  struct GRlc_info      *p_point1e,
                  IGRint                cv_flag1,
                  IGRint                cont1,
                  IGRint                approx_flag1,
                  IGRdouble             approx_fact1,
                  IGRint                tangent_flag1,
                  IGRdouble             *ratio1,
                  IGRdouble             par_iso1,
                  IGRdouble             par_cv1[2],
                  IGRint                dir_flag1,
                  IGRvector             dir_vec1[2],
                  struct GRlc_info      *surface2,
                  struct GRlc_info      *curve2,
                  struct GRlc_info      *p_point2s,
                  struct GRlc_info      *p_point2e,
                  IGRint                cv_flag2,
                  IGRint                cont2,
                  IGRint                approx_flag2,
                  IGRdouble             approx_fact2,
                  IGRint                tangent_flag2,
                  IGRdouble             *ratio2,
                  IGRdouble             par_iso2,
                  IGRdouble             par_cv2[2],
                  IGRint                dir_flag2,
                  IGRvector             dir_vec2[2],
                  IGRshort              blend_order,
                  IGRdouble             tolarr[3],
                  struct GRvg_construct *construct_list,
                  GRspacenum            *blend_os,
                  GRobjid               *blend_id)  



    IGRlong                *EMmsg;            O - return code.
    struct GRlc_info       *surface1,         I - surface elements.
                           *surface2;

    struct GRlc_info       *curve1,           I - if boundary_flag == 0
                           *curve2,               the bounday curve at which
                                                  the blend starts/ends.

    struct GRlc_info       *p_point1s,        I - partial blend point from
                           *p_point1e,        I - partial blend point to
                           *p_point2s,        I - partial blend point from
                           *p_point2e,        I - partial blend point to     
                                              (  set par_cv1/2 to -10.0+value )

    IGRint                 cv_flag1,          I - 0: The curve where the blend
                           cv_flag2,                 starts/end is a B-spline curve.
                                                  1: The curve is an iso_parametric
                                                     curve with 1. parameter of
                                                     surface beeing constant.
                                                  2: The curve is an iso_parametric
                                                     curve with 2. parameter of
                                                     surface beeing constant.

    IGRdouble             *ratio1,            I - tangent value parameters
                          *ratio2;                if NULL, first guess is
                                                   used.

    IGRdouble              par_iso1,          I - iso parameter for boundary
                           par_iso2;              curve.

    IGRint                 dir_flag1,         I - 1: The triple product :
                           dir_flag2;               ( derivate of blend bound, 
                                                     positive surface normal,
                                                     blend direction vector ) >= 0
                                                 -1: For the opposite direction.
                                                  parametrization.

    IGRdouble              par_cv1[2],        I - Start and end parameter of
                           par_cv2[2],            the boundary curve
                                                  (may be iso curve of the
                                                   surface. Is -1.0 if partial
                                                   blend point by assoc points).

    IGRint                 cont1,             I - 0: no curvature contition
                           cont2,                 1: curvature condition.

    IGRint                 approx_flag1,      I - Approximation flag
                           approx_flag2;          0:  exact
                                                  1:  approximative

    IGRdouble              approx_fact1,      I - if (approx_flag > 0)
                           approx_fact2;          a factor between 0.0 and 1.0
                                                  corresponds to the exact.

    IGRshort               blend_order;       I - Order of surface blend
                                       

    IGRdouble              tolarr[3];         I - working tolerances
                                              [0]  same point tolerance
                                              [1]  same angle tolerance
                                              [2]  degeneracy of derivatives


    struct GRvg_construct  *construct_list;   I - construct list (optional).
    GRspacenum             *blend_os;         O - os of result.
    GRobjid                *blend_id;         O - id of result
                             
Description

    Format the input, and call ems$associative_element_by_function.

Return Value

Notes

    The macro ec$blend_surfaces (ecbls_macros.h) is the macro interface, and
    calls this function.

    This creates and EMSagrp, which may not be the best thing.

    The name field of "construct_list" needs to be supported for naming
    the blend.

History

    03 JAN 94   HOB     Creation
*/

IGRint  ECblend_surfaces_api(
                  IGRlong               *EMmsg,
                  struct GRlc_info      *surface1,
                  struct GRlc_info      *curve1,
                  struct GRlc_info      *p_point1s,
                  struct GRlc_info      *p_point1e,
                  IGRint                cv_flag1,
                  IGRint                cont1,
                  IGRint                approx_flag1,
                  IGRdouble             approx_fact1,
                  IGRint                tangent_flag1,
                  IGRdouble             *ratio1,
                  IGRdouble             par_iso1,
                  IGRdouble             par_cv1[2],
                  IGRint                dir_flag1,
                  IGRvector             dir_vec1[2],
                  struct GRlc_info      *surface2,
                  struct GRlc_info      *curve2,
                  struct GRlc_info      *p_point2s,
                  struct GRlc_info      *p_point2e,
                  IGRint                cv_flag2,
                  IGRint                cont2,
                  IGRint                approx_flag2,
                  IGRdouble             approx_fact2,
                  IGRint                tangent_flag2,
                  IGRdouble             *ratio2,
                  IGRdouble             par_iso2,
                  IGRdouble             par_cv2[2],
                  IGRint                dir_flag2,
                  IGRvector             dir_vec2[2],
                  IGRshort              blend_order,
                  struct GRvg_construct *construct_list,
                  GRspacenum            *blend_os,
                  GRobjid               *blend_id)  



{


  struct EMSobject_info  obj_info[MAX_NUM_PARENTS];

  struct IGRdisplay      loc_dis;
  struct GRmd_env        loc_env;
  struct GRvg_construct  loc_cnst,
                         *cnst_ptr;
  struct EMSvalue_info   value;
  struct EMSvector_info  vector;

  IGRlong                loc_msg = EMS_S_Success,
                         sts     = OM_S_SUCCESS;
  IGRlong                rc; 

  IGRint                 blend_type;
  IGRint                 nro;                   /*  current object index  */
  IGRint                 i;                     /*  loop counter  */
  IGRboolean             loc_assoc_flag;
  GRobjid                loc_result_id;



  /*  Set up the construct list  */
   if( construct_list ) 
      cnst_ptr = construct_list;
    else                        
  {
    cnst_ptr = &loc_cnst;
    loc_cnst.msg = &loc_msg;
    loc_cnst.env_info = &loc_env;
    loc_cnst.newflag = FALSE;
    loc_cnst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    loc_cnst.geometry = NULL;
    loc_cnst.display = &loc_dis;
    loc_cnst.class_attr = NULL;
    loc_cnst.name = NULL;

    gr$get_active_layer(msg = &loc_msg, buffer = &loc_cnst.level);

    gr$get_module_env(msg = &loc_msg, buffer = &loc_env);

    gr$get_active_display(msg = &loc_msg, buffer = &loc_dis);

    cnst_ptr = &loc_cnst;
  }

  /*  get associative lock state  */
  gr$get_associative_flag(msg = &loc_msg, buffer = &loc_assoc_flag);

  if (!loc_assoc_flag)
  {

    IGRint         new_tangent_flag1[3], new_tangent_flag2[3];
    IGRdouble      new_ratio1[3], new_ratio2[3];
    IGRdouble      tolarr[3];                  /*  tolerance array  */    
    struct GRid    blend_sf;


    /*  get System Tolerances  */
    BSEXTRACTPAR (&rc,BSTOLBASIS,tolarr[0]);
    BSEXTRACTPAR (&rc,BSTOLCOLLINVEC,tolarr[1]);
    BSEXTRACTPAR (&rc,BSTOLLENVEC,tolarr[2]);

    cv_flag1 = (cv_flag1 < 0) ? 0 : cv_flag1;      /*  extract real flag  */ 
    cv_flag2 = (cv_flag2 < 0) ? 0 : cv_flag2;      /*  extract real flag  */

    /*  fill ratio/tangent_flag interface  */
    for (i=0; i<3; i++)
    {
      new_tangent_flag1[i] = 0;
      new_tangent_flag2[i] = 0;
      new_ratio1[i] = 1.0;
      new_ratio2[i] = 1.0;
    }
    tangent_flag1 = tangent_flag2 = 2;


    /* --------------------------------------- */
    /* --- Perform non assoc surface blend --- */
    /* --------------------------------------- */
    EMblendsf(&loc_msg,
              &surface1->module_info,
              surface1->located_obj,
              &curve1->module_info,
              curve1->located_obj,
              cv_flag1,
              cont1,
              &approx_flag1,
              &approx_fact1,
              new_tangent_flag1,
              new_ratio1, 
              par_iso1,
              par_cv1,
              dir_flag1,
              dir_vec1,
              &surface2->module_info,
              surface2->located_obj,
              &curve2->module_info,
              curve2->located_obj,
              cv_flag2,
              cont2,
              &approx_flag2,
              &approx_fact2,
              new_tangent_flag2,
              new_ratio2,
              par_iso2,
              par_cv2,
              dir_flag2,
              dir_vec2,
              blend_order,
              tolarr,
              construct_list,
              &blend_sf);
    if(! (1 & loc_msg))
    {
      sts = ex$message(msgnumb = ERROR_MESSAGE_NOINT,
                       field   = ERROR_FIELD);
      goto wrapup;
    }
    *blend_os = blend_sf.osnum;
    *blend_id = blend_sf.objid;
    
    return (loc_msg);
  }


                                          
  /*  -------------------------  */
  /*  create parametric objects  */            
  /*  -------------------------  */
  /*    obj_info[0]  = surface1 object pointer  */
  /*    obj_info[1]  = surface2 object pointer  */
  value.type  = EMSdatainfo_numeric; 
  vector.type = EMSdatainfo_numeric; 

  nro = 2;

  /*  prepare and save blend type  */
  blend_type = 1;
  /*  observe internal blend by curve  */

  if (cv_flag1 < 0)    blend_type |= BLEND_BIT_INT_PTR_1;
  if (cv_flag2 < 0)    blend_type |= BLEND_BIT_INT_PTR_2;
  if (par_cv1[0] < 0)  blend_type |= BLEND_BIT_PART_PTR_1S;
  if (par_cv1[1] < 0)  blend_type |= BLEND_BIT_PART_PTR_1E;
  if (par_cv2[0] < 0)  blend_type |= BLEND_BIT_PART_PTR_2S;
  if (par_cv2[1] < 0)  blend_type |= BLEND_BIT_PART_PTR_2E;

  value.val = blend_type;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  /*  create parametric objects for surface 1  */
  value.val = cv_flag1;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = cont1;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = approx_flag1;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = approx_fact1;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = tangent_flag1;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = *ratio1;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = par_iso1;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = par_cv1[0];
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = par_cv1[1];
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = dir_flag1;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  for (i=0; i<3; i++)
  {
    value.val = dir_vec1[0][i];
    sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                              &value, &obj_info[nro++]);
    if(! (1 & sts)) goto wrapup;
  }

  /*  second vector not yet modified  */
  for (i=0; i<3; i++)
    vector.vec[i] = dir_vec1[1][i];
  sts = EMgetparvec_object( &loc_msg, surface1->module_info.md_env.matrix_type,
                            surface1->module_info.md_env.matrix, cnst_ptr->env_info->md_id.osnum,
                            &vector, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  /*  create parametric objects for surface 2  */

  value.val = cv_flag2;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = cont2;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = approx_flag2;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = approx_fact2;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = tangent_flag2;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = *ratio2;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = par_iso2;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = par_cv2[0];
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = par_cv2[1];
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = dir_flag2;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  for (i=0; i<3; i++)
  {
    value.val = dir_vec2[0][i];
    sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                              &value, &obj_info[nro++]);
    if(! (1 & sts)) goto wrapup;
  }

  /*  second vector not yet modified  */
  for (i=0; i<3; i++)
    vector.vec[i] = dir_vec2[1][i];
  sts = EMgetparvec_object( &loc_msg, surface1->module_info.md_env.matrix_type,
                            surface1->module_info.md_env.matrix, cnst_ptr->env_info->md_id.osnum,
                            &vector, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;

  value.val = blend_order;
  sts = EMgetparval_object( &loc_msg, cnst_ptr->env_info->md_id.osnum, NULL,
                            &value, &obj_info[nro++]);
  if(! (1 & sts)) goto wrapup;



  /*  Initialize the EMSobject_info (to be parents)  */

  /*  surface 1  */
  obj_info[0].grid.osnum = surface1->located_obj.osnum;
  obj_info[0].grid.objid = surface1->located_obj.objid;
  obj_info[0].env  = surface1->module_info;
  /*  surface 2  */
  obj_info[1].grid.osnum = surface2->located_obj.osnum;
  obj_info[1].grid.objid = surface2->located_obj.objid;
  obj_info[1].env  = surface2->module_info;

  for (i=2; i < nro; i++)  
  {
    obj_info[i].grid.osnum =  cnst_ptr->env_info->md_id.osnum,
    obj_info[i].env        = *cnst_ptr->env_info;
  }

  if (cv_flag1 < 0)
  {
    /*  internal blend curve 1  */
    obj_info[nro].grid.osnum = curve1->located_obj.osnum;
    obj_info[nro].grid.objid = curve1->located_obj.objid;
    obj_info[nro].env        = curve1->module_info;
    nro++;
  }

  if (cv_flag2 < 0)
  {
    /*  internal blend curve 2  */
    obj_info[nro].grid.osnum = curve2->located_obj.osnum;
    obj_info[nro].grid.objid = curve2->located_obj.objid;
    obj_info[nro].env        = curve2->module_info;
    nro++;
  }


  if (par_cv1[0] < 0)
  {
    /*  partial blend point 1S  */
    obj_info[nro].grid.osnum = p_point1s->located_obj.osnum;
    obj_info[nro].grid.objid = p_point1s->located_obj.objid;
    obj_info[nro].env        = p_point1s->module_info;
    nro++;
  }


  if (par_cv1[1] < 0)
  {
    /*  partial blend point 1E  */
    obj_info[nro].grid.osnum = p_point1e->located_obj.osnum;
    obj_info[nro].grid.objid = p_point1e->located_obj.objid;
    obj_info[nro].env        = p_point1e->module_info;
    nro++;
  }


  if (par_cv2[0] < 0)
  {
    /*  partial blend point 2S  */
    obj_info[nro].grid.osnum = p_point2s->located_obj.osnum;
    obj_info[nro].grid.objid = p_point2s->located_obj.objid;
    obj_info[nro].env        = p_point2s->module_info;
    nro++;
  }

  if (par_cv2[1] < 0)
  {
    /*  partial blend point 2E  */
    obj_info[nro].grid.osnum = p_point2e->located_obj.osnum;
    obj_info[nro].grid.objid = p_point2e->located_obj.objid;
    obj_info[nro].env        = p_point2e->module_info;
    nro++;
  }

  /*  Create the blend surface using the associative mechanism  */
  sts = ems$associative_element_by_function(
            msg = &loc_msg,
            num_parents = nro,  
            parents = obj_info,
            function_name = "ECblend_surfaces",
            construct_list = cnst_ptr,
            class_name = "EMAgenbs",
            created_id = &loc_result_id);
  if(! (1 & sts)) goto wrapup;

  /*  If specified, return the blend surface id and OS */
  if(blend_os) *blend_os = cnst_ptr->env_info->md_id.osnum; 
  if(blend_id) *blend_id = loc_result_id; 

  if(EMmsg) *EMmsg = loc_msg;

  return sts;


wrapup:
  return (FALSE);
}                




/*
Name

    ECblend_surfaces

Abstract

    This is the associative function for placing a blend surface that is
    used as an argument to ems$associative_element_by_function.

Synopsis

    IGRint ECblend_surfaces(EMmsg, options, old_objid, new_objid,
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
IGRint ECblend_surfaces(EMmsg, options, old_objid, new_objid, num_parents,
                       parent_info, recomp_info, construct_list, mod_new_id)

IGRlong                 *EMmsg;             /* output */
IGRuint                 options;            /* input  */
GRobjid                 old_objid;
GRobjid                 new_objid;
IGRint                  num_parents;
IGRchar                 *parent_info;
IGRchar                 *recomp_info;
struct GRvg_construct   *construct_list;
GRobjid                 *mod_new_id;        /*  output  0 = error */


{
  IGRlong               sts;
  IGRlong               rc; 
  IGRint                nro;                /*  current object index  */
  IGRint                i;                  /*  loop count  */ 
  IGRuint               parent_types[MAX_NUM_PARENTS];
  union EMSparent_info  parents[MAX_NUM_PARENTS];
  struct GRid           *buf_ptr;
  struct GRid           *buf_ptr_w;
  char syntax[20];       /*  for sprintf  */
 
  struct IGRpolyline polyline;     /*  used for partial point  */
  IGRint     action;               /*  GRgetpolyline action  */
  IGRpoint           proj_pnt;     /*  actual partial blend point  */

  IGRlong   loc_msg = EMS_S_Success;

  /*  struct GRid  blend_cv;  */    /*  blend surface                      */
  IGRint    cont1, cont2;           /*  1 tangent , 2 curvature            */
  IGRdouble ratio1, ratio2;         /*  ratio for tangents                 */

  IGRint    tangent_flag1,          /*  type of tangent value              */
            tangent_flag2; 
  IGRshort  blend_order;            /*  order of blend surface      */
  IGRint    blend_type;             /*  blend control information  */

  IGRint    ind_ratio1, ind_ratio2, /*  parent list index ratios  */
            ind_dir1,   ind_dir2,   /*  parent list index directions  */
            ind_approx1,ind_approx2;/*  parent list index approx values  */
  IGRdouble old_ratio1, old_ratio2; /*  old ratio for tangents  */
  IGRint    approx_flag1, approx_flag2; /* approximation mode 0 = none  */
  IGRdouble approx_fact1, approx_fact2; /* approximation mode 0 = none  */
  IGRint    old_approx_m1, old_approx_m2; /* old approx mode */
  IGRdouble old_approx_f1, old_approx_f2; /* old approx factor */


  struct GRid      cv1_grid, cv2_grid;

  struct GRid      pb1s_grid, pb1e_grid,
                   pb2s_grid, pb2e_grid;

  struct GRid      blend_sf;

  struct GRmd_env  env_cv1, env_cv2;

  struct GRmd_env  env_pb1s, env_pb1e,
                   env_pb2s, env_pb2e;

  IGRint     dir_flag1, dir_flag2;
  IGRint     cv_flag1, cv_flag2;
  IGRint     wrk_cv_flag1, wrk_cv_flag2;           

  IGRdouble  par_cv1[2], par_cv2[2];
  IGRdouble  par_iso1, par_iso2;

  IGRvector  dir_vec1[2], dir_vec2[2];

  IGRdouble  tolarr[3];                  /*  tolerance array  */     

  IGRdouble new_ratio1[3],               /*  ratio for tangents  */
            new_ratio2[3];        

  IGRint    new_tangent_flag1[3],        /*  type of tangent value  */
            new_tangent_flag2[3]; 



                          
   options     = options;       /* make the compiler happy */
   old_objid   = old_objid;     /* make the compiler happy */
   recomp_info = recomp_info;   /* make the compiler happy */

   /*  get System Tolerances  */
   BSEXTRACTPAR (&rc,BSTOLBASIS,tolarr[0]);
   BSEXTRACTPAR (&rc,BSTOLCOLLINVEC,tolarr[1]);
   BSEXTRACTPAR (&rc,BSTOLLENVEC,tolarr[2]);

   *mod_new_id = NULL; 

  if(num_parents > MAX_NUM_PARENTS)
    { *EMmsg = EMS_E_InvalidArg; sts = OM_E_ABORT; goto wrapup; }

  /*
   * Get the parents
   * parent[0] = surface1
   * parent[1] = surface2
   * parent[2] = type of blend   (defines structure of parameters)
   * parent[3...] = surface 1 parameters
   * (values and 1 vectors)
   * parent[x...MAX_NUM_PARENTS] = surface 2 parameters
   * (values and 1 vectors)
   */
  parent_types[0] = EMSlcinfo;
  parent_types[1] = EMSlcinfo;

  for (nro=2; nro < MAX_NUM_PARENTS-6; nro++)
    parent_types[nro] = EMSscalar;

  /*  correct for vectors  */
  parent_types[16] = EMSvector;  
  parent_types[30] = EMSvector; 

  /*  preset list for possible internal blend curve / partial blend points  */  
  for (nro=MAX_NUM_PARENTS-6; nro < MAX_NUM_PARENTS; nro++)
    parent_types[nro] = EMSlcinfo;  

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
  if(! (1 & sts & *EMmsg)) goto wrapup;
               



  nro = 2;
  /*  get parameter for blend construction control  */ 
  blend_type     = parents[nro++].value; 

  /*  get other parameters  */
  cv_flag1       = parents[nro++].value;    
  cont1          = parents[nro++].value;
  ind_approx1 = nro;        
  approx_flag1   = parents[nro++].value;
  approx_fact1   = parents[nro++].value;  
  tangent_flag1  = parents[nro++].value; 
  ind_ratio1 = nro;        
  ratio1         = parents[nro++].value;    
  par_iso1       = parents[nro++].value;   
  par_cv1[0]     = parents[nro++].value;    
  par_cv1[1]     = parents[nro++].value;
  ind_dir1 = nro;               
  dir_flag1      = parents[nro++].value;
  for (i=0; i<3; i++) 
    dir_vec1[0][i] = parents[nro++].value; 
  for (i=0; i<3; i++) 
    dir_vec1[1][i] = parents[nro].vector[i]; 
  nro++; 

  /*  create parametric objects for surface 2  */
  cv_flag2       = parents[nro++].value;    
  cont2          = parents[nro++].value; 
  ind_approx2 = nro;        
  approx_flag2   = parents[nro++].value;
  approx_fact2   = parents[nro++].value;     
  tangent_flag2  = parents[nro++].value;
  ind_ratio2 = nro;            
  ratio2         = parents[nro++].value;    
  par_iso2       = parents[nro++].value;    
  par_cv2[0]     = parents[nro++].value;    
  par_cv2[1]     = parents[nro++].value;
  ind_dir2 = nro;                  
  dir_flag2      = parents[nro++].value; 
  for (i=0; i<3; i++) 
    dir_vec2[0][i] = parents[nro++].value;  
  for (i=0; i<3; i++) 
    dir_vec2[1][i] = parents[nro].vector[i]; 
  nro++; 
  blend_order      = parents[nro++].value;     


  /*  check for additional dependecy by internal blend curve  */  
 
  if (blend_type & BLEND_BIT_INT_PTR_1)
  {
    env_cv1  = parents[nro].grobj.env;
    cv1_grid = parents[nro].grobj.grid;
    nro++;
  }

  if (blend_type & BLEND_BIT_INT_PTR_2)
  { 
    env_cv2  = parents[nro].grobj.env;
    cv2_grid = parents[nro].grobj.grid; 
    nro++; 
  }   

   /*  preset for possible partial blend points  */
  polyline.points = proj_pnt;  
  action = 1;        /*  0: get number of point , 1:  get point(s)  */

  if (blend_type & BLEND_BIT_PART_PTR_1S)
  {    

    env_pb1s  = parents[nro].grobj.env;
    pb1s_grid = parents[nro].grobj.grid; 
    nro++; 

    /*  get actual partial blend point value  */ 
    sts = om$send(mode = OM_e_wrt_object,
                 msg = message GRlinear.GRgetpolyline
                               (&loc_msg, &env_pb1s.md_env.matrix_type, 
                               env_pb1s.md_env.matrix, &action, &polyline),
                 senderid = NULL_OBJID,
                 targetid = pb1s_grid.objid,
                 targetos = pb1s_grid.osnum);
    if(! (1 & sts & loc_msg))  goto wrapup;

    /*  recalculate partial blend parameter  */

    sts = ECblendsf_gt(&loc_msg, parents[0].lc_info.located_obj,        
                       proj_pnt, &parents[0].lc_info.module_info,               
                       cv_flag1, &par_cv1[0]);
    if(! (1 & sts))  goto wrapup;
  }   


  if (blend_type & BLEND_BIT_PART_PTR_1E)
  { 

    env_pb1e  = parents[nro].grobj.env;
    pb1e_grid = parents[nro].grobj.grid; 
    nro++; 

    /*  get actual partial blend point value  */ 
    sts = om$send(mode = OM_e_wrt_object,
                 msg = message GRlinear.GRgetpolyline
                               (&loc_msg, &env_pb1e.md_env.matrix_type, 
                               env_pb1e.md_env.matrix, &action, &polyline),
                 senderid = NULL_OBJID,
                 targetid = pb1e_grid.objid,
                 targetos = pb1e_grid.osnum); 
    if(! (1 & sts & loc_msg))  goto wrapup;

    /*  recalculate partial blend parameter  */
    sts = ECblendsf_gt(&loc_msg, parents[0].lc_info.located_obj,        
                       proj_pnt, &parents[0].lc_info.module_info,               
                       cv_flag1, &par_cv1[1]);
    if(! (1 & sts))  goto wrapup;

    /*  avoid same start/end parameter  */
    if (par_cv1[0] == par_cv1[1])
    {
      if (par_cv1[0] < 0.5)   par_cv1[0] = 0.0;
      else                    par_cv1[1] = 1.0;
    }
  }   


  if (blend_type & BLEND_BIT_PART_PTR_2S)
  { 

    env_pb2s  = parents[nro].grobj.env;
    pb2s_grid = parents[nro].grobj.grid; 
    nro++; 

     /*  get actual partial blend point value  */ 
    sts = om$send(mode = OM_e_wrt_object,
                 msg = message GRlinear.GRgetpolyline
                               (&loc_msg, &env_pb2s.md_env.matrix_type, 
                               env_pb2s.md_env.matrix, &action, &polyline),
                 senderid = NULL_OBJID,
                 targetid = pb2s_grid.objid,
                 targetos = pb2s_grid.osnum);
    if(! (1 & sts & loc_msg))  goto wrapup;

    /*  recalculate partial blend parameter  */
    sts = ECblendsf_gt(&loc_msg, parents[1].lc_info.located_obj,        
                       proj_pnt, &parents[1].lc_info.module_info,               
                       cv_flag2, &par_cv2[0]);
    if(! (1 & sts))  goto wrapup;
  }   


  if (blend_type & BLEND_BIT_PART_PTR_2E)
  { 

    env_pb2e  = parents[nro].grobj.env;
    pb2e_grid = parents[nro].grobj.grid; 
    nro++; 

    /*  get actual partial blend point value  */ 
    sts = om$send(mode = OM_e_wrt_object,
                 msg = message GRlinear.GRgetpolyline
                               (&loc_msg, &env_pb2e.md_env.matrix_type, 
                               env_pb2e.md_env.matrix, &action, &polyline),
                 senderid = NULL_OBJID,
                 targetid = pb2e_grid.objid,
                 targetos = pb2e_grid.osnum);
    if(! (1 & sts & loc_msg))  goto wrapup;

    /*  recalculate partial blend parameter  */
    sts = ECblendsf_gt(&loc_msg, parents[1].lc_info.located_obj,        
                       proj_pnt, &parents[1].lc_info.module_info,               
                       cv_flag2, &par_cv2[1]);
    if(! (1 & sts))  goto wrapup;
    
    /*  avoid same start/end parameter  */
    if (par_cv2[0] == par_cv2[1])
    {
      if (par_cv2[0] < 0.5)   par_cv2[0] = 0.0;
      else                    par_cv2[1] = 1.0;
    }
  }   

  /*  all regeneration values there  */

  /*  check for original optimized blend      */
  /*  and not initialized with positiv ratio  */
  if (!(blend_type & BLEND_BIT_MODIFIED)  && ratio1 < 0  &&  ratio2 < 0)
  {
    ratio1 = ratio2 = -12345;
    tangent_flag1 = tangent_flag2 = -2;  
    tangent_flag1 = tangent_flag2 =  2;
    ratio1 = ratio2 = 1.0;   
      old_ratio1 =  -12345;
      old_ratio2 =  -12345;
  }
  else
  {
    tangent_flag1 = ABS(tangent_flag1);
    tangent_flag2 = ABS(tangent_flag2);
    old_ratio1 =  ratio1;
    old_ratio2 =  ratio2;
  }


  /*  fill ratio/tangent_flag interface  */
  for (i=0; i<3; i++)
  {
    new_tangent_flag1[i] = 0;
    new_tangent_flag2[i] = 0;
    new_ratio1[i] = 1.0;
    new_ratio2[i] = 1.0;
  }

  new_tangent_flag1[1] = tangent_flag1;      /*  2nd is used only  */
  new_tangent_flag2[1] = tangent_flag2;      /*  2nd is used only  */
  new_ratio1[1] = ratio1;
  new_ratio2[1] = ratio2;

  /*  save old approximation's  */
  old_approx_m1 = approx_flag1;
  old_approx_m2 = approx_flag2;
  old_approx_f1 = approx_fact1;
  old_approx_f2 = approx_fact2;

  /* --------------------------------- */
  /* --- Perform the surface blend --- */
  /* --------------------------------- */

  wrk_cv_flag1 = (cv_flag1 < 0) ? 0 : cv_flag1;      /*  extract real flag  */ 
  wrk_cv_flag2 = (cv_flag2 < 0) ? 0 : cv_flag2;      /*  extract real flag  */

  loc_msg = 0;
  EMblendsf (&loc_msg,
             &parents[0].grobj.env,
             parents[0].grobj.grid,
             &env_cv1,
             cv1_grid,
             wrk_cv_flag1,
             cont1,
             &approx_flag1,
             &approx_fact1,
             new_tangent_flag1,
             new_ratio1, 
             par_iso1,
             par_cv1,
             dir_flag1,
             dir_vec1,
             &parents[1].grobj.env,
             parents[1].grobj.grid,
             &env_cv2,
             cv2_grid,
             wrk_cv_flag2,
             cont2,
             &approx_flag2,
             &approx_fact2,
             new_tangent_flag2,
             new_ratio2,
             par_iso2,
             par_cv2,
             dir_flag2,
             dir_vec2,
             blend_order,
             tolarr,
             construct_list,
             &blend_sf);


  if(! (1 & loc_msg))
  {
    sts = ex$message(msgnumb = ERROR_MESSAGE_NOINT,
                     field   = ERROR_FIELD);
    goto wrapup;
  }

  *mod_new_id = blend_sf.objid;

  /*  extract new ratio interface  */


  tangent_flag1 = new_tangent_flag1[1];
  tangent_flag2 = new_tangent_flag2[1];

  ratio1 = new_ratio1[1];
  ratio2 = new_ratio2[1];
  base_ratio1 = ratio1;            /*  save for forms  */
  base_ratio2 = ratio2;            /*  save for forms  */
  base_approx1 = approx_fact1;     /*  save for forms  */
  base_approx2 = approx_fact2;     /*  save for forms  */


  /*  restore modified blend_surface values  */ 
  buf_ptr = (struct GRid *) parent_info;
  if ( old_ratio1 !=  ratio1 ||  old_ratio2 !=  ratio2)                        
  {
    buf_ptr = (struct GRid *) parent_info;

    /*  convert double to character string  */        
    sprintf (syntax,"%g",ratio1); 
    buf_ptr_w = buf_ptr + ind_ratio1;
    sts = exp$modify( exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,  
                      exp_syntax = syntax);

    /*  convert double to character string  */              
    sprintf (syntax,"%g",ratio2);
    buf_ptr_w = buf_ptr + ind_ratio2;
    sts = exp$modify( exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,  
                      exp_syntax = syntax);
  }

  if (old_approx_f1 != approx_fact1)
  {
    /*  approximation 1 has changed and must be saved  */
    /*  convert integer to character string  */  
    sprintf (syntax,"%d",approx_flag1); 
    buf_ptr_w = buf_ptr + ind_approx1;
    sts = exp$modify( exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,  
                      exp_syntax = syntax);

    /*  convert double to character string  */  
    sprintf (syntax,"%f",approx_fact1); 
    buf_ptr_w = buf_ptr + ind_approx1 + 1;
    sts = exp$modify( exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,  
                      exp_syntax = syntax);
  }
 
  if (old_approx_f2 != approx_fact2)
  {
    /*  approximation 2 has changed and must be saved  */
    /*  convert integer to character string  */  
    sprintf (syntax,"%d",approx_flag2); 
    buf_ptr_w = buf_ptr + ind_approx2;
    sts = exp$modify( exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,  
                      exp_syntax = syntax);

    /*  convert double to character string  */  
    sprintf (syntax,"%f",approx_fact2); 
    buf_ptr_w = buf_ptr + ind_approx2 + 1;
    sts = exp$modify( exp_id = buf_ptr_w->objid, osnum = buf_ptr_w->osnum,  
                      exp_syntax = syntax);
  } 


  return sts;

wrapup:
  return sts;
}

end implementation ECblendsf;





