
/*       
  history :

    07/xx/93 - Horst Bernhardt
    08/09/93 - change accept message key
    09/xx/94 - add better closed curve handling 
    08/xx/95 - add comp_crv / SKmgr handling 
    08/28/97 - change text for UNDO
    09/01/97 - avoid selection of elements with dimension constraint 
 

  DISCLAIMER :

             Allows trim curve(s) to a boundary using one pick only.
*/

class implementation ECtrim1;

#include   "VCdef.h"               /*  test  */              

#include   <math.h>
#include   "igrtypedef.h"
#include   "OMminimum.h"
#include   "OMprimitives.h"
#include   "OMDB.h"
#include   "igetypedef.h"
#include   "OMlimits.h"
#include   "igr.h"
#include   "gr.h"
#include   "exdef.h"
#include   "ex.h"
#include   "exmacros.h"
#include   "igrdef.h"
#include   "OMmacros.h"
#include   "msdef.h"
#include   "msmacros.h"
#include   "griodef.h"
#include   "grio.h"
#include   "griomacros.h"
#include   "lcdef.h"
#include   "lcmacros.h"
#include   "igrdef.h"
#include   "dpdef.h"
#include   "dpmacros.h"
#include   "igrdp.h"
#include   "godef.h"
#include   "go.h"
#include   "grdpbdef.h"
#include   "grdpbmacros.h"
#include   "maerr.h"
#include   "igrmacros.h"
#include   "grmacros.h"
#include   "comiscmac.h"
#include   "dp.h"
#include   "grdpbdef.h"
#include   "grdpbmacros.h"
#include   "coimport.h"
#include   "grmessage.h"
#include   "bserr.h"
#include   "bsparameters.h"
#include   "bsconic.h"
#include   "codebug.h"

#include   "grgsmacros.h"     /* gr$gsdisplay */
#include   "emserr.h"
#include   "EMSmsgdef.h"
#include   "EMSutlmacros.h"   /*  get_construction_info_from_id  */
#include   "SKmacros.h"
#include   "SKdef.h"
#include   "comisc.h"

#include   "ECcmd.h"
#include   "ECmsg.h"

#include   "bscvcvint.h"     /*  function prototype  *
#include   "ma2pt2di.h"      /*  function prototype  */
#include   "bsactivsplt.h"   /*  function prototype  */
#include   "bsnorkts.h"      /*  function prototype  */
#include   "bsfullarc.h"     /*  function prototype  */
#include   "bsalloccv.h"     /*  function prototype  */
#include   "bscveval.h"      /*  function prototype  */
#include   "bsfreecv.h"      /*  function prototype  */
#include   "bsprptoncv.h"    /*  function prototype  */
#include   "bsarccen.h"      /*  function prototype  */
#include   "bsmkvec.h"       /*  function prototype  */
#include   "bsdotp.h"        /*  function prototype  */
#include   "bsnorvec.h"      /*  function prototype  */

#include   "ectrm_alc.h"     /*  function prototype  */
#include   "ectrm_sk.h"      /*  function prototype  */
#include   "ectrm_prf.h"     /*  function prototype  */
#include   "ectrm_del.h"     /*  function prototype  */
#include   "ectrm_cpb.h"     /*  function prototype  */


/* Command states */
#define NUMBER_OF_STATES      3

#define IDENTIFY_BOUND        1
#define IDENTIFY_ELEMENT      2
#define EXTEND_ELEMENT        3

    #define NR_PRE_INT 2  
    #define NR_PRE_OVL 2  

#define REM_R_TREE  0              /*  remove from r_tree               */
#define ADD_R_TREE -1              /*  add to r_tree                    */
#define REAL_DEL    1              /*  real delete (with members)       */
#define REM_HIGHL   2              /*  remove highlight (with members)  */

#define CV_START_PARAM  0.0     /*  curve start parameter  */ 
#define CV_END_PARAM    1.0     /*  curve end parameter    */
#define WRAP            CV_END_PARAM-CV_START_PARAM
#define FEW             0.1     /*  small curve positiv offset  */

#define OFFSET_FAKT   100       /*  faktor offset parameter for direction  */ 
#define DIFF       100000.0     /*  used to search second intersection  */

#define SPECIAL_FLAG    1       /*  used to distinguish pick pos  */



# define MAX(x,y)    ((x) < (y) ? (y) :(x))
# define MIN(x,y)    ((x) > (y) ? (y) :(x))
# define ABS(x)      ((x) < 0 ? -(x) : (x))

#define VCdebug_return    1            /*  test  */

/* imported messages */
from GRcurve     import GRptextend; 
from GRcurve     import GR3ptpartdel;
from GRgraphics  import GRaddwrng,
                        GRptproject;
                                   from GRgraphics import GRdelete;
from GRgraphics  import GRdisplay;
from GRgraphics  import GRlocaldp;
from IGEgragad   import DPinrot;
from GRvg        import GRgetsize,
                        GRgetgeom,
                        GRgeomprops,
                        GRpostabsg;
from GRgraphics  import GRconstruct;
from GRcompcurve import EMmakecomp;


/* text for prompts and other messages */

/*                         "Trim elements at Boundary"  */
#define COMMAND_TEXT       EM_M_TrElBn 

/*                         "Identify boundary"  */
#define LOCATE_PROMPT_B    EMS_P_IdBd

/*                         "Identify curve at remaining side near boundary" */
#define LOCATE_PROMPT_A    EMS_P_IdCuAtReSiNeBd

/*                         "Identify curve at rem. side near border/Backup for undo" */
#define LOCATE_PROMPT_A_U  EMS_P_IdCuAtReSiNeBd__Bk

/*                         "No curve(s) found"  */
#define RELOCATE_PROMPT    EMS_I_NoCuFo

/*                         "Accept/Reject"  */
#define ACCEPT_PROMPT      GR_P_Acc

/*                         "No trim/extend possible"  */    
#define ERROR_MSG_NOINT    EMS_I_NoTEPo

/*                         "Same curve as boundary!"  */
#define ERROR_MSG_DOUBLE   EMS_I_SaCuAsBd

/*                         "Accept/Reject"  */
#define ACCEPT_PROMPT      GR_P_Acc

/*                         "Already trimmed side"  */
#define MSG_TRIM_ALR1      EMS_P_AlTrSi    

/*                         "Both sides already trimmed"  */
#define MSG_TRIM_ALR2      EMS_P_BoSiAlTr    

/*                         "Already trimmed side/data point for other border" */
#define MSG_TRIM_ALR_DP    EMS_P_AlTrSi__DPFoOtBo

/*                         "Idendification was outside element range"  */
#define MSG_TRIM_OUT       EMS_P_IdWaOuElRa

/*                          Element with dimension constraint cannot be trimmed */
#define ERROR_MESSAGE_DIM   EMS_S_ElWiDiCoCABeTr



extern GRclassid OPP_GRpoint_class_id;
extern GRclassid OPP_GRcurve_class_id;
extern GRclassid OPP_GR3dpolygon_class_id;
extern GRclassid OPP_GRbcsubbc_class_id;
extern GRclassid OPP_GR3dellipse_class_id;
extern GRclassid OPP_GR3dellarc_class_id;
extern GRclassid OPP_GRcompcurve_class_id;
extern GRclassid OPP_EMSsurface_class_id;
extern GRclassid OPP_SKmgr_class_id;
extern GRclassid OPP_SKgeometry_class_id;
extern GRclassid OPP_GR3dtext_class_id;

extern GRclassid OPP_GR3dcirarc_class_id;
extern GRclassid OPP_GR3dcircle_class_id;
extern GRclassid OPP_GR3dlinestr_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;

extern GRclassid OPP_SKline_class_id;
extern GRclassid OPP_SKarc_class_id;
extern GRclassid OPP_SKcircle_class_id;
extern GRclassid OPP_SKbspline_class_id;
extern GRclassid OPP_SKdumpt_class_id;
extern GRclassid OPP_SKpoint_class_id;


extern IGRboolean  EFisAncestryValid();
extern IGRboolean  EMshould_be_associative();




static struct IGRbsp_curve
         *curve_bound,                 /*  work bound                       */
         *curve_extend,                /*  work extend                      */

                                       /*          om$malloc:               */
         *space_b1,                    /*  bound ptr for return (original)  */
         *space_b2,                    /*  bound ptr for return (work)      */
         *space_e1,                    /*  extend ptr for return (original) */
         *space_e2,                    /*  extend ptr for return (work)     */
         *curve_new,                   /*  trimmed element new   */

                                       /*          BSalloccv:               */ 
         *space_b3,                    /*  bound ptr for return (work)      */
         *space_e3;                    /*  extend ptr for return (work)     */


static IGRdouble     eps,              /*  basic tolerance  */ 
                     epsx;     

static struct GRid   saved_grid_1, saved_grid_2;
static struct GRid   new_trim_1, new_trim_2;
static struct GRid   wrk_bound;





/*
 * execute method for ECtrim command object
 */

method init(int type;char *str_ptr)
{

   me->last_extend_ele.objid = 
   me->saved_ele.objid       =
   me->bound_ele.objid       = 
      saved_grid_1.objid     =  
      saved_grid_2.objid     = 
      new_trim_1.objid       =
      new_trim_2.objid       = NULL_OBJID; 

   /* set initial state for execute method */
   me->save_state      = -1;
   ME.super_cmd->state = IDENTIFY_BOUND; 

   /*  reset curve space pointer  */ 
   curve_bound  = 
   curve_extend = 
   curve_new    = NULL;
   space_b1 =
   space_b2 =
   space_b3 =
   space_e1 =
   space_e2 =
   space_e3 = NULL;

   return(OM_S_SUCCESS);
}



method execute(int *response; char *response_data; int pos)
{

   IGRshort
     display_location,
     display_flag,
     num;

   IGRboolean
     apparent_flag,
     no_undo,
     shure_single_int,
     start_in,
     end_in,
     intersect_found,
     already_msg,
     extend_e_extend;  /* extend_ele must be extended for display /intersect */


   IGRlong 
     msg,
     rc,
     size,
     size_bound, size_extend,
     ret_size,
     msg_tst,
     display_flag_b,
     display_flag_e;

   enum  GRdpmode  
     display_mode[2];

   IGRdouble
     step_dist_f,
     step_dist_e,
     offset,
     tw,
     fabs(),
     dist_sq,
     dist_best_sq,
     dist1_best_sq,
     dist2_best_sq,
     parm_ext_a,
     parm_ext_s,
     parm_ext_e,
     parm_ext_m,
     cv_start_par,
     cv_end_par,
     parm_real_t,
     parm_dist1, parm_dist2,
     parm_dist_as, parm_wrk,
     dot;


   
   IGRint
     i, jj, k,
     best1, best2, best3,
     orig_best3,
     ind_same,
     same_start,
     same_end,
     near_end,
     work_type,
     last_trim_same,
     last_near_end,
     last_work_type,
     last_ind_repl,
     last_ind_to,
     locate_mask,
     accept_mask,
     sts;

   struct GRlc_locate
     attributes_b,
     attributes_e;

   OMuword
     r_classes[1],
     r_classes_e[1],
     b_classes[6],
     e_classes[6];

   OM_S_CLASSLIST
     rtree_classes,
     rtree_classes_e,
     b_eligible_classes,
     e_eligible_classes;

   struct GRid   extend_ele; 
   struct GRid   main_obj1, main_obj2;
   struct GRid   sel_extend;
   struct GRid   orig_bound, orig_extend; 

   struct GRmd_env
     *p_module_info_e,
     *p_module_info_s,
     module_info_e,
     module_info_s;

   IGRpoint
     appr_intersect,
     intersect_point,
     Endpoint,
     pntxxx,
     From_point,
     Dir_point,
     End_point,
     Guess_point,
     pnt_cur,
     pnt_dummy,
     e_start_point,
     e_end_point,
     e_few_point;

   struct GRparms
     geom_parms_e, 
     parm_int,
     parm,
     From_parms,
     Dir_parms,
     End_parms;


   IGRvector
     view_vector,
     vec_best1;

   IGRmatrix
     rot_matrix;

   GRobjid
     last_trim_objid,
     c1,
     c2;

   OMuword
     bound_ele_classid, 
     extend_ele_classid; 
 
   /*        nearest intersection to accept pnt                              */
   /*                 other intersection pnt                                 */
   /*                          2nd nearest intersection to accept pnt in dir */
   IGRpoint  point1,  point2,  point3;     /*  point value                   */
   IGRdouble parme1,  parme2,  parme3;     /*  curve param extended curve    */



/* intersection function values */
   IGRboolean out_int_alloc, out_ovl_alloc; 
   IGRint     n_int, n_ovl;
   IGRint     control;

   IGRdouble  ipar1[NR_PRE_INT], ipar2[NR_PRE_INT];
   IGRdouble  opar1[NR_PRE_OVL], opar2[NR_PRE_OVL];
   IGRpoint   int_pts[NR_PRE_INT];
   IGRpoint   ovl_pts[NR_PRE_INT];

   IGRdouble  *xipar1, *xipar2;
   IGRdouble  *xopar1, *xopar2;
   IGRpoint   *xint_pts, *xovl_pts;

   IGRdouble  parm_int1u = 0.0;
   IGRdouble  parm_int2u = 0.0;
   IGRdouble  parm_int3u = 0.0;

   IGRvector  vec_wrk;

   struct GRprops       props_b,          /*  geom properties  */
                        props_e;          /*  geom properties  */

   struct IGRbsp_curve  *curve_1_work,    /*  bound work pointer            */
                        *curve_2_work,    /*  extend work pointer           */
                        *bc2;             /*  b_spline work (to overwrite)  */

   GRobjid             newid;             /*  new object id           */
   struct GRpost_info  post_info;         /*  new element gen infov   */

   IGRdouble  parm_real_s, parm_real_e, parm_real_a;
   IGRdouble  parm_real_i1, parm_real_i2, parm_real_i;
   IGRdouble  parm_real_ot;
   IGRdouble  parm_a_start, parm_a_end;
   IGRdouble  dif_m_s;
   IGRdouble  curve_dir;   

   IGRdouble   dist_e_s, dist_e_e, dist;
   IGRdouble   par_few;
   IGRboolean  on_curve;

   IGRint      ind_repl, ind_to;
   IGRint      msg_key;

   IGRint      member_cnt_1, member_cnt_2;            
   IGRboolean  closed_cv1, closed_cv2; 

   IGRint            member_cnt_x;
   IGRboolean        closed_cvx; 
   struct GRid       main_objx;


   /* --- start of executable code --- */

   /*  make compiler happy  */
   curve_2_work = NULL;
   last_trim_objid = NULL;
   orig_best3      =
   last_trim_same  =
   last_near_end   =
   near_end        =
   last_work_type  =
   ind_repl        = 
   last_ind_repl   =
   ind_to          = 
   last_ind_to     = NULL;
   parme1       = parme2       = parme3      = 
   parm_real_s  = parm_real_e  = parm_real_a = 
   parm_real_i  = parm_real_i1 = 
   parm_a_start = parm_a_end   = NULL;
   curve_dir = NULL;

   shure_single_int = FALSE;
   ind_same = NULL;
   work_type = NULL;

   /*  preset flags  */
   no_undo = TRUE;

   sts = OM_S_SUCCESS;
   msg = MSSUCC;

   me->last_extend_ele.objid = NULL_OBJID;
   p_module_info_e = &module_info_e;

   /* set up filter event masks */
   locate_mask = GRm_DATA  | GRm_BACK_UP | GRm_TEXT_VALUE;
   accept_mask = GRm_DATA  | GRm_BACK_UP | GRm_TEXT_VALUE;

   /* locate display flag set for bound */
   display_flag_b =
        SEGMENT_HILIGHT         |      /*  hilite obj and extension  */
        NO_PROJ_ACCEPT_POINT    |      /*  don't project the accept  point */
        RELOCATE                |      /*  relocate if none found  */
        LC_REGULAR_HIGHLIGHT    |      /*                                    */
        LC_ERASE_LOC_ELEMENT    |      /*                                    */
        LC_ACC_ONE_ELEMENT      ;      /*  don't accept if one element in tol */



   attributes_b.properties =
               LC_LC_ONLY            |    /*  locate locatable objects  */
               LC_RW                 |    /*  locate readable/writable objects  */
               LC_DP_ONLY            ;    /*  locate displayable objects  */
    
   /* locate attributes set for bound */
   attributes_b.owner_action =
	                        LC_RIGID_COMP 
                              | LC_FLEX_COMP
                              | LC_REF_OBJECTS
                              | LC_NO_RIGID_OWNER_WORKS 
                              | LC_NO_FLEX_OWNER_WORKS
                              | LC_HANDLES 
                                ;
   /* Rtree set up for bound */
   rtree_classes.w_flags = OM_CLST_subclass;
   rtree_classes.p_classes = r_classes;
                             r_classes[0] = OPP_GRcurve_class_id;
   rtree_classes.w_count = 1;

   b_eligible_classes.w_flags = OM_CLST_subclass | OM_CLST_negation; 
   b_eligible_classes.p_classes = b_classes;
                                  b_classes[0] = OPP_GRpoint_class_id;
                                  b_classes[1] = OPP_SKpoint_class_id;
                                  b_classes[2] = OPP_EMSsurface_class_id;
                                  b_classes[3] = OPP_GRcompcurve_class_id;
                                  b_classes[4] = OPP_GR3dtext_class_id;
                                  b_classes[5] = OPP_SKdumpt_class_id;
   b_eligible_classes.w_count = 6; 

   /* locate display flag set for element */
   display_flag_e =
        ELEM_HILIGHT            |       /* Hilite the whole element */
        LC_ACC_ONE_ELEMENT      |       /* dont accept if one element in tol */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_LOC_ELEMENT;           /* Erase the hilite plane */


   /* Rtree set up for element */
   rtree_classes_e.w_flags   = OM_CLST_subclass;
   rtree_classes_e.p_classes = r_classes_e;
                               r_classes_e[0] = OPP_GRcurve_class_id;  
   rtree_classes_e.w_count = 1;

   /*  set extend element not eligible class list  */
   e_eligible_classes.w_flags = OM_CLST_subclass | OM_CLST_negation;
   e_eligible_classes.p_classes = &e_classes[0];
                                   e_classes[0] = OPP_GRpoint_class_id;
                                   e_classes[1] = OPP_SKpoint_class_id;
                                   e_classes[2] = OPP_EMSsurface_class_id;
                                   e_classes[3] = OPP_GRcompcurve_class_id;
                                   e_classes[4] = OPP_GR3dtext_class_id;
                                   e_classes[5] = OPP_SKdumpt_class_id;
   e_eligible_classes.w_count = 6; 

   /* locate attributes set for extend element */
   attributes_e.owner_action = LC_GEOM_MOD
                             | LC_RIGID_COMP  
                             | LC_FLEX_COMP
                             | LC_REF_OBJECTS
                             | LC_NO_RIGID_OWNER_WORKS 
                             | LC_NO_FLEX_OWNER_WORKS 
                             | LC_EXTERN_CONSTRAINED
                             | LC_HANDLES ;

   attributes_e.properties =   LC_WRITE_ONLY 
                             | LC_LC_ONLY 
                             | LC_DP_ONLY ;



   /*  get basis tolerance value  eps  */
   sts = BSEXTRACTPAR(&msg,BSTOLBASIS,eps);
   if (BSERROR(msg)) Goto (wrapup);
   epsx = 0.001 * eps;
   offset = OFFSET_FAKT * eps;

  /*
   * Loop through the command states until an input is received by a filter 
   * that cannot be handled.  On exit from this loop, the execute method 
   * exits, returning control to the Command Server.
   */


   do
   {
     if (me->save_state > 0)
     {
       ME.super_cmd->state = me->save_state;
       me->save_state = -1;
     }

     switch (ME.super_cmd->state)
     {

       case IDENTIFY_BOUND:
       { 
         last_trim_objid = NULL;
         last_trim_same  =
         last_near_end   =
         last_work_type  = 
         last_ind_repl   = 
         last_ind_to     = NULL;

         /*-------------------------------*/                            
         /*  locate the boundary element  */
         /*-------------------------------*/ 
                   
         sts = lc$locate(rc               = &msg,
                         event1           = &me->locate_event1,
                         event2           = &me->accept_event1,
                         mask1            =  locate_mask,
                         mask2            =  accept_mask,
                         display_flag     =  display_flag_b,
                         locate_key       =  LOCATE_PROMPT_B,
                         acc_key          =  ACCEPT_PROMPT,
                         attributes       = &attributes_b,
                         relocate_key     =  RELOCATE_PROMPT,
                         stack            = &me->locate_stack,
                         rtree_classes    = &rtree_classes,
                         eligible_classes = &b_eligible_classes);
         if (!(1&sts))
         { 
           /* let command server handle it */
           return (OM_S_SUCCESS);
         }
         if (!(1&msg))
         {
           if (me->locate_event1.response == EX_BACK_UP)
           {
             /* backup to previous command state */
           }
           else
           {
             /* let command server handle it */
             return(OM_S_SUCCESS);
           }
         }
         else

         {
           if (me->accept_event1.response == EX_BACK_UP)
           {
             /* backup to previous command state */
             ME.super_cmd->state = IDENTIFY_BOUND;
           }
           else
           {
             /* ------------------------------ */ 
             /* --- bound element selected --- */
             /* ------------------------------ */ 

             /* Erase the located element */
             me->bound_ele     = me->accept_event1.located_object[0].located_obj;
             me->module_info_b = me->accept_event1.located_object[0].module_info;
             me->parm_sel      = me->accept_event1.located_object[0].geom_parms.u;

             /*  get bound element class_id    */
             sts = om$get_classid(objid     = me->bound_ele.objid,
                                  osnum     = me->bound_ele.osnum,
                                  p_classid = &bound_ele_classid); 

             /*  check for Smart Sketch obj and replace it by basic geo object */
             sts = ECtrm_SK(me->bound_ele, &wrk_bound, &member_cnt_1, &closed_cv1, &main_obj1);

             /*  get bound element class_id    */
             sts = om$get_classid(objid     = wrk_bound.objid,
                                  osnum     = wrk_bound.osnum,
                                  p_classid = &bound_ele_classid); 

             if ( !(1&sts) || wrk_bound.objid == NULL_OBJID)
             {
               /*  erase highlight and redraw old element in case of error  */
               sts = dp$display(msg  = &msg,   
                                mode = GRbdhe,
                                oids = &me->accept_event1.located_object[0].located_obj);
               break;
            }
            if (extend_ele.objid != me->accept_event2.located_object[0].located_obj.objid)
            {
              /*  clear message field when command is put to sleep  */
              sts = ex$message (field   = MESSAGE_FIELD,
                                msgnumb = EMS_I_ClearStatusField ); 
              if (!(1&sts))  Goto (wrapup); 
            }

            /*---------------------------------*/
            /*  prepare boundary element data  */
            /*---------------------------------*/
            if (space_b1)  {  om$dealloc(ptr = space_b1);  space_b1 = NULL;  }
            if (space_b2)  {  om$dealloc(ptr = space_b2);  space_b2 = NULL;  }
            if (space_b3)  {  BSfreecv(&rc, space_b3);     space_b3 = NULL;  }

            if (member_cnt_1 < 2)
            {
              wrk_bound = me->bound_ele;     /*  reset to original selected  */
            }
            me->bound_ele = wrk_bound;

            sts = ECtrm_alc(&msg, 1, wrk_bound, &me->module_info_b.md_env,
                            &space_b1, &props_b, &size_bound);
            if (!(1&sts))  Goto (wrapup);

            /*  get bound element class_id  */
           
            sts = om$get_classid(objid     = wrk_bound.objid,
                                 osnum     = wrk_bound.osnum,
                                 p_classid = &bound_ele_classid); 
    
            curve_bound = space_b1; 

            /*  mark boundary in half highligh mode  */

            /*  distinguish extendable curves  */
             if ( member_cnt_1 <= 1 
               && (  bound_ele_classid == OPP_GR3dlineseg_class_id
                  || bound_ele_classid == OPP_GR3dcirarc_class_id 
                  || bound_ele_classid == OPP_GR3dellarc_class_id
                  || bound_ele_classid == OPP_SKarc_class_id
                  || bound_ele_classid == OPP_SKline_class_id   )  )
             {
               /*  extendable curves  */
               me->extend_b_extend = TRUE;
               display_flag = 0;
               display_mode[0] = display_mode[1] = GRhhd;
               parm.u = me->parm_sel;  
               parm.v = 0.0;

               sts = om$send( mode = OM_e_wrt_object,
                              msg  = message GRgraphics.GRlocaldp(
                                       &msg_tst,
                                       &me->module_info_b.md_env.matrix_type, 
                                       me->module_info_b.md_env.matrix, 
                                       &parm,
                                       display_mode,
                                       &me->module_info_b.md_id,
                                       &display_location,
                                       &display_flag),
                              targetid = wrk_bound.objid,
                              targetos = wrk_bound.osnum); 

             if (!(1&(sts&msg_tst)))  Goto (wrapup);
             }
             else
             {
               /*  non-extendable curves  */
               me->extend_b_extend = FALSE;
          
               sts = dp$display(msg = &msg,
                               mode = GRhd,
                               oids = &wrk_bound);
             if (!(1&(sts&msg)))  Goto (wrapup);
             }
             /*  save bound module info  */
             me->geom_parms_b  = me->locate_event1.located_object[0].geom_parms;
             ME.super_cmd->state = IDENTIFY_ELEMENT;
           }
         }
         break;

         
       case IDENTIFY_ELEMENT:
       {
         /*---------------------------------*/
         /*  locate element to be extented  */
         /*---------------------------------*/
        
         /*  extract correct text  */
         if (me->last_extend_ele.objid == NULL_OBJID  
         ||  no_undo)                  msg_key = LOCATE_PROMPT_A; 
         else                          msg_key = LOCATE_PROMPT_A_U;

         sts = lc$locate(rc               = &msg,
                         event1           = &me->locate_event2,
                         event2           = &me->accept_event2,
                         mask1            = locate_mask,
                         mask2            = locate_mask,
                         display_flag     = display_flag_e,
                         locate_key       = msg_key,
                         acc_key          = ACCEPT_PROMPT,
                         attributes       = &attributes_e,
                         relocate_key     = RELOCATE_PROMPT,
                         stack            = &me->locate_stack,
                         rtree_classes    = &rtree_classes_e,
                         eligible_classes = &e_eligible_classes); 

         if (!(1&sts))
         {
           ME.super_cmd->state = IDENTIFY_BOUND; 
           /*  let command server handle it  */
           return (OM_S_SUCCESS);
         }
 
         /*  clear message field when command is put to sleep  */
         sts = ex$message (field   = MESSAGE_FIELD,
                           msgnumb = EMS_I_ClearStatusField ); 
         if (!(1&sts))  Goto (wrapup); 

         if (!(1&msg))
         {
           if (me->locate_event2.response == EX_BACK_UP)
           {
             /*  double click right mouse button  */
             if (me->last_extend_ele.objid != NULL_OBJID) 
             {

               /*---------------------*/
               /*  simulate  U N D O  */  
               /*---------------------*/

               extend_ele = me->last_extend_ele;
          
               /*  get extend element class_id  */
               sts = om$get_classid(objid     = extend_ele.objid,
                                    osnum     = extend_ele.osnum,
                                    p_classid = &extend_ele_classid); 
          
               /*  check if saved old element is there  */
               if ( me->saved_ele.objid != NULL_OBJID)
               {
                 shure_single_int =
                            (  bound_ele_classid  == OPP_GR3dlineseg_class_id
                            || bound_ele_classid  == OPP_SKline_class_id     )
                            &&
                            (  extend_ele_classid == OPP_GR3dlineseg_class_id
                            || extend_ele_classid == OPP_SKline_class_id     );

               if (!shure_single_int)
               {
                 /*  erase element with old extension  */
                 sts = dp$display(msg  = &msg,
                                  mode = GRbehe,
                                  oids = &me->last_extend_ele);

                 /*  erase + delete last created element  */ 
                 sts = ECtrm_del(REAL_DEL, me->last_extend_ele, &module_info_e);
                 me->last_extend_ele.objid = NULL_OBJID;

                 sts = ECtrm_del(ADD_R_TREE, me->saved_ele, &module_info_e);

                 /*  redraw saved element  */
                 sts = dp$display(msg  = &msg,
                                  mode = GRbd,
                                  oids = &me->saved_ele);

                 me->saved_ele.objid = NULL_OBJID;

                 ME.super_cmd->state = IDENTIFY_ELEMENT;
                 break;          
                }
              }

              /*  decide if only one intersection is possible  */

              if (shure_single_int)
              {
                 /*  remove old curve extend from display */
                 sts = dp$display(msg  = &msg,
                                  mode = GRbe,  
                                  oids = &extend_ele);   
                 if (!(1&(sts&msg)))  Goto (wrapup);

                 /*  send to the object to get it to extend itself  */
                 sts = om$send(mode = OM_e_wrt_object,
                               msg = message GRcurve.GRptextend(  
                                       &msg,
                                       &module_info_e,
                                       me->last_extend_from,  /* pnt to extend    */
                                       me->last_extend_to,    /* pnt to extend to */
                                       me->last_extend_from), /* new end pnt      */
                               targetid = extend_ele.objid,
                               targetos = extend_ele.osnum);
                 if (!(1&(sts&msg)))  Goto (wrapup);

                 /*  add curve new extend to display */ 
                 sts = dp$display(msg  = &msg,
                                  mode = GRbd,  
                                  oids = &extend_ele);   
                 if (!(1&(sts&msg)))  Goto (wrapup);

              }   /*  if (shure_single_int...  */

              else

              {
                if ( me->saved_ele.objid != NULL_OBJID)
                {
                  /*  delete last handled element ,this also erases the element  */
                  sts = gr$delete_object(msg          = &msg,
                                         md_env       = &module_info_s,      
                                         object_id    = &me->last_extend_ele,
                                         display_flag = 1);
                  if (!(1&(sts&msg)))  Goto (wrapup);

                  /*  add saved element to R_tree  */
                  sts = om$send(mode = OM_e_wrt_object,
                                msg = message GRgraphics.GRaddwrng(
                                                &msg_tst,
                                                &me->module_info_u),
                                targetid = me->saved_ele.objid,
                                targetos = me->saved_ele.osnum);      
                  if (!(1&(sts&msg)))  Goto (wrapup);

                  /*  display restored element  */
                  sts = dp$display(msg  = &msg,
                                   mode = GRbd,
                                   oids = &me->saved_ele);
                  if (!(1&(sts&msg)))  Goto (wrapup);
                }

                else

                {
                  /*  dark old curve old extend  */ 
                  sts = dp$display(msg  = &msg,
                                  mode = GRbe,  
                                  oids = &me->last_extend_ele);   
                  if (!(1&(sts&msg)))  Goto (wrapup);

                  /*  send to the object to get it to extend itself  */
                  extend_ele = me->last_extend_ele;
                  sts = om$send(mode = OM_e_wrt_object,
                                msg = message GRcurve.GRptextend(  
                                               &msg,
                                               &module_info_e,
                                               me->last_extend_from,  /* pnt to extend    */
                                               me->last_extend_to,    /* pnt to extend to */
                                               me->last_extend_from), /* new end pnt      */
                                targetid = extend_ele.objid,
                                targetos = extend_ele.osnum);
                  if (!(1&(sts&msg)))  Goto (wrapup);

                  /*  add curve new extend to display */ 
                  sts = dp$display(msg  = &msg,
                                  mode = GRbd,  
                                  oids = &extend_ele);   
                  if (!(1&(sts&msg)))  Goto (wrapup);
                }

              }
              me->saved_ele.objid       = NULL_OBJID;
              me->last_extend_ele.objid = NULL_OBJID;
            }
            else
            {
              ME.super_cmd->state = IDENTIFY_BOUND;  
            }
            break;

            /*---  end of undo  ---*/      

          }
         
          else

          {

            if (me->locate_event2.event.button.numb == SPECIAL_FLAG)
            {
              /*  right mouse button not pushed  */
              /*  let command server handle it  */
              return (OM_S_SUCCESS);
            }
            /*  right mouse botton pushed = end of trim loop  */
            /*  erase boundary highlighting  */
            if(me->extend_b_extend)
            {
              display_mode[0] = GRbehe;
              display_mode[1] = GRbehe;
               parm.u = me->parm_sel;
               parm.v = 0.0;
               sts = om$send(mode = OM_e_wrt_object,
                             msg  = message GRgraphics.GRlocaldp(
                                      &msg,
                                      &me->module_info_b.md_env.matrix_type, 
                                      me->module_info_b.md_env.matrix, 
                                      &parm,
                                      display_mode,
                                      &me->module_info_b.md_id,
                                      &display_location,
                                      &display_flag),
                             targetid = me->bound_ele.objid,
                             targetos = me->bound_ele.osnum); 
             if (!(1&(sts&msg)))  Goto (wrapup);

             }
             else
             {
               sts = dp$display(msg  = &msg,
                                mode = GRbehe,
                                oids = &me->bound_ele);
               if (!(1&(sts&msg)))  Goto (wrapup);

             }
 
             /*  redraw bound  */
             sts = dp$display(msg  = &msg,   
                              mode = GRbd,
                              oids = &me->bound_ele);
              if (!(1&(sts&msg)))  Goto (wrapup);  

             me->bound_ele.objid = NULL_OBJID;

             ME.super_cmd->state = IDENTIFY_BOUND;
             break;
           }

         }

         extend_ele    = me->accept_event2.located_object[0].located_obj;
         module_info_e = me->accept_event2.located_object[0].module_info;

         sts = om$get_classid(objid     = extend_ele.objid,
                              osnum     = extend_ele.osnum,
                              p_classid = &extend_ele_classid);  

         sel_extend = extend_ele;
         /*  avoid bound elelement the same as extend element  */
         /*  what is with trim a curve with itself ????        */
         if (me->bound_ele.objid == extend_ele.objid  &&
             me->bound_ele.osnum == extend_ele.osnum )
         {
           sts = ex$message(msgnumb = ERROR_MSG_DOUBLE,
                            field   = ERROR_FIELD);
           if (!(1&sts))  Goto (wrapup);
           break;
         }

         /*  check for Smart Sketch obj and replace it by basic geo object */
         orig_extend = extend_ele;
         sts = ECtrm_SK(extend_ele, &extend_ele, &member_cnt_2, &closed_cv2, &main_obj2);

         if (extend_ele.objid == NULL_OBJID)
         {   
           /*  erase highlight and redraw old element in case of error  */
           sts = dp$display(msg  = &msg,   
                            mode = GRbdhe,
                            oids = &me->accept_event2.located_object[0].located_obj);
           break;
         }

         /*  check if extend element has dimemsion constraint  */
         if (ECtrm_isdim (extend_ele) )    
         {
           sts = ex$message(msgnumb = ERROR_MESSAGE_DIM,
                            field   = ERROR_FIELD);
           break;
         }

         /* ------------------------------------ */ 
         /* ---  extend element is selected  --- */
         /* ------------------------------------ */ 

         /*  mark element by highligh mode  */
         sts = dp$display(
                  msg  = &msg,
                  mode =  GRhd,
                  oids = &me->accept_event2.located_object[0].located_obj);
         if (!(1&(sts&msg)))  Goto (wrapup);
       }
   


       case EXTEND_ELEMENT:
       {

         orig_bound  = me->bound_ele;

         for (i=0; i<3; i++)
           appr_intersect[i] = me->accept_event2.located_object[0].proj_pnt[i];
         geom_parms_e  = me->accept_event2.located_object[0].geom_parms; 



         /*---------------------------------*/
         /*  prepare boundary element data  */
         /*---------------------------------*/

         /*  get bound element class_id  */
         sts = om$get_classid(objid     = me->bound_ele.objid,
                              osnum     = me->bound_ele.osnum,
                              p_classid = &bound_ele_classid); 

         if (!space_b1)
         {
           sts = ECtrm_alc(&msg, 1, me->bound_ele, &me->module_info_b.md_env,
                            &space_b1, &props_b, &size_bound);
           if (!(1&sts))  Goto (wrapup); 
         }
         curve_bound = space_b1;



         /*-------------------------------*/
         /*  prepare extend element data  */
         /*-------------------------------*/

         /*  get extend element class_id  */
         sts = om$get_classid(objid     = extend_ele.objid,
                              osnum     = extend_ele.osnum,
                              p_classid = &extend_ele_classid); 

         /*  special handling for composite curve  */
         if (member_cnt_1 > 1 &&  member_cnt_2 > 1) 
         {
           /*  erase all highlighting                  */
           /*  dp$erase_hilite(msg = &msg);   -error-  */
           goto idle;            /*  profile/profile not allowed  */
         }

         if (member_cnt_1 <= 1  &&  member_cnt_2 <= 1)
         {
           me->bound_ele = orig_bound; 
           extend_ele    = orig_extend; 
           member_cnt_1 = member_cnt_2 = 0;   /*  dont handle as profile  */

           if (space_b1)  {  om$dealloc(ptr = space_b1);  space_b1 = NULL;  }

           sts = ECtrm_alc(&msg, 1, me->bound_ele, &me->module_info_b.md_env,
                           &space_b1, &props_b, &size_bound);
           if (!(1&sts))  Goto (wrapup); 
           curve_bound = space_b1;
         }

         if (member_cnt_1 > 1  ||  member_cnt_2 > 1)
         {
           if (member_cnt_1 > 1)
           { 
             sts = ECtrm_prf(1,                    /*  handle 1st */
                             &geom_parms_e,
                             &module_info_e,
                             &extend_ele,
                             closed_cv2,
                             &me->bound_ele,
                             closed_cv1,
                             appr_intersect,
                             &control,
                             &new_trim_2,
                             &new_trim_1,
                             intersect_point,
                             Endpoint,
                             &saved_grid_2,
                             &saved_grid_1);

             if (1&control)
             {
               for (k=0; k<3; k++)
               {
                 me->last_extend_from[k] = intersect_point[k];
                 me->last_extend_to[k]   = Endpoint[k];
               }
               if (me->saved_ele.objid != NULL_OBJID
               &&  me->saved_ele.objid != saved_grid_2.objid )
               {
                 sts = ECtrm_SK(me->saved_ele, &me->saved_ele, &member_cnt_x, &closed_cvx, &main_objx);
                 /*  delete last for undo saved element  */
                 sts = om$send (msg      = message Root.delete(0),
                                targetid = me->saved_ele.objid,
                                targetos = me->saved_ele.osnum);
               }

               me->saved_ele = saved_grid_2;
               if (new_trim_2.objid != NULL_OBJID) me->last_extend_ele = new_trim_2; 
               else                                me->last_extend_ele = extend_ele; 
             }
           }      /*   if (member_cnt_1...  */

           if (member_cnt_2 > 1  &&  member_cnt_1 <= 1)
           {
             sts = ECtrm_prf(2,                    /*  handle 2nd */
                             &me->accept_event1.located_object[0].geom_parms,
                             &module_info_e,
                             &me->bound_ele,
                             closed_cv1,
                             &extend_ele,
                             closed_cv2,
                             appr_intersect,
                             &control,
                             &new_trim_1,
                             &new_trim_2,
                             intersect_point,
                             Endpoint,
                             &saved_grid_1,
                             &saved_grid_2);

             if (2&control)
             {
               for (k=0; k<3; k++)
               {
                 me->last_extend_from[k] = intersect_point[k];
                 me->last_extend_to[k]   = Endpoint[k];
               }
               me->last_extend_ele = new_trim_2;
               if (me->saved_ele.objid != NULL_OBJID
               &&  me->saved_ele.objid != saved_grid_2.objid )
               {
                 sts = ECtrm_SK(me->saved_ele, &me->saved_ele, &member_cnt_x, &closed_cvx, &main_objx);
                 /*  delete last for undo saved element  */
                 sts = om$send (msg      = message Root.delete(0),
                                targetid = me->saved_ele.objid,
                                targetos = me->saved_ele.osnum);
               }
               me->saved_ele = saved_grid_2;
             }

           }

           if (control == NULL)
           {
             /*  inform user of wrong element  */
             sts = ex$message(msgnumb = ERROR_MSG_NOINT,
                              field   = ERROR_FIELD);
             me->last_extend_ele.objid = NULL_OBJID;

             /*  erase highlight and redraw old element in case of error  */
             sts = dp$display(msg  = &msg,   
                              mode = GRbdhe,
                              oids = &extend_ele);
           }

           /*  save last work indication for second bound extend  */
           last_trim_objid = NULL; 
           last_trim_same  = 
           last_near_end   = 
           last_work_type  = 
           last_ind_repl   =
           last_ind_to     = NULL; 

           ME.super_cmd->state = IDENTIFY_ELEMENT;
           break;  

         }   /*  if (member_cnt_1  ||  member_cnt_2...  */

         /*--- end of external profile handling ---*/




         /*  get extend element class_id  */
         sts = om$get_classid(objid     = extend_ele.objid,
                              osnum     = extend_ele.osnum,
                              p_classid = &extend_ele_classid); 

         if (space_e1)  {  om$dealloc(ptr = space_e1);  space_e1 = NULL; }
         sts = ECtrm_alc(&msg, 1, extend_ele, &module_info_e.md_env,
                                        &space_e1, &props_e, &size_extend);
         if (!(1&sts))  Goto (wrapup);
         curve_extend = space_e1;

         msg_tst = MSSUCC;
         n_int           = 
         work_type       =
         ind_same        =
         same_start      =
         same_end        = NULL;

         no_undo         =
         already_msg     =
         intersect_found = FALSE; 

         /*  decide if only one intersection is possible  */
         shure_single_int = (   bound_ele_classid  == OPP_GR3dlineseg_class_id
                              || bound_ele_classid  == OPP_SKline_class_id     )
                            &&
                             (  extend_ele_classid == OPP_GR3dlineseg_class_id
                             || extend_ele_classid == OPP_SKline_class_id     );

         /*  get apparent flag value  */
         size = sizeof(apparent_flag);
         sts = gr$get_apparent_flag(msg    = &msg,
                                    sizbuf = &size,
                                    buffer = &apparent_flag,
                                    nret   = &ret_size);
         if (!(1&(sts&msg)))  Goto (wrapup);

         if (shure_single_int)
         {
           if (apparent_flag) 
           { 
             /*  calculate single apparent intersection  */

             /*  load view vector  */
             sts = om$send(
                      msg = message IGEgragad.DPinrot(&msg,
                                                      rot_matrix),
                      senderid = NULL_OBJID,
                      targetid = me->accept_event2.event.button.objid,
                      targetos = me->accept_event2.event.button.osnum); 
             if (!(1&(sts&msg)))  Goto (wrapup);

             /*  get unit vector  */
             for (i=0; i<3; i++)
               view_vector[i] = rot_matrix[8+i];

             /*  calculate apparent intersect point in the extend element  */
             sts = GR2objaisect(
                       &msg, 
                       &extend_ele,         /* extend element         */
                       p_module_info_e,     /* extend ele module inf  */
                       &geom_parms_e,       /* extend ele parameters  */
                       &me->bound_ele,      /* bound element          */
                       &me->module_info_b,  /* bound ele module inf   */
                       &me->geom_parms_b,   /* bound ele parameters   */
                       appr_intersect,      /* approximate int pt     */
                       view_vector,         /* unit view vector       */
                      intersect_point);    /* actual intersect       */

             intersect_found = (msg == MSSUCC);
           }

           else

           {
             me->geom_parms_b  = me->locate_event1.located_object[0].geom_parms;  /*  reset to original value  */
             /*  calculate true single intersect  */ 
             sts = GR2objisect(&msg,
                               &me->bound_ele,     /* bound element      */
                               &me->module_info_b, /* bound module info  */
                               &me->geom_parms_b,  /* bound parameters   */
                               &extend_ele,        /* extend element     */
                               p_module_info_e,    /* extend module inf  */
                               &geom_parms_e,      /* extend parameters  */
                               appr_intersect,     /* approximate int pt */
                               intersect_point );  /* actual intersect   */

             intersect_found = (msg == MSSUCC); 
          }

          /*  calculate t-parameter of single intersection  */  
          sts = om$send (
                    mode = OM_e_wrt_object,
                    msg = message GRgraphics.GRptproject(
                                  &msg,
                                  &p_module_info_e->md_env.matrix_type,
                                  &p_module_info_e->md_env.matrix[0],
                                  &intersect_point[0],
                                   pntxxx,
                                  &parm_int),
                    senderid = NULL_OBJID,
                    targetid = extend_ele.objid,
                    targetos = extend_ele.osnum);
          if (!(1&(sts&msg)))  Goto (wrapup);
           
          /*  check if already trimmed  */ 
          sts = MA2pt2dis(&msg, &curve_extend->poles[0],
                                          intersect_point, &dist1_best_sq);
          sts = MA2pt2dis(&msg, &curve_extend->poles[(curve_extend->num_poles-1)*3],
                                          intersect_point, &dist2_best_sq);
          if (dist1_best_sq < eps*eps  || dist2_best_sq < eps*eps)
          {
            /*  inform user of already trimmed side  */
            sts = ex$message(msgnumb = MSG_TRIM_ALR1,
                             field   = ERROR_FIELD);
            if (!(1&sts))  Goto (wrapup); 
          }

          /*  decide side to extend  */
          tw = -1;
          if (parm_int.u <= CV_START_PARAM)  tw = CV_START_PARAM; 
          if (parm_int.u >= CV_END_PARAM)    tw = CV_END_PARAM;  
   
          if (tw < 0)
          {    
            if (geom_parms_e.u < parm_int.u)  tw = CV_END_PARAM;
            if (geom_parms_e.u > parm_int.u)  tw = CV_START_PARAM;
          }
 
          if (tw < 0.5) 
          {
            for (i=0; i<3; i++)
              Endpoint[i] = curve_extend->poles[i];

          }
          else
          {
            for (i=0; i<3; i++)
              Endpoint[i] = curve_extend->poles[(curve_extend->num_poles -1)*3 + i];
          }
        }

        else

        {
          if (!apparent_flag) 
          { 


            /*----------------------------------------*/
            /*----------------------------------------*/
            /* possible multiple intersection points  */
            /*----------------------------------------*/
            /*----------------------------------------*/

            curve_1_work = curve_bound;
             curve_2_work = curve_extend;

             /*  prepare boundary element data  */ 
             if (space_b2)  {  om$dealloc(ptr = space_b2);  space_b2 = NULL; }
             sts = ECtrm_alc(&msg, 1, me->bound_ele, &me->module_info_b.md_env,
                              &space_b2, &props_b, &size_bound);
             if (!(1&sts))  Goto (wrapup);

             if (space_e2)  {  om$dealloc(ptr = space_e2);  space_e2 = NULL; }
             sts = ECtrm_alc(&msg, 1, extend_ele, &module_info_e.md_env,
                              &space_e2, &props_e, &size_extend);
             if (!(1&sts))  Goto (wrapup);   

             bc2 = curve_extend;    /*  curve_extend->phy_closed overwritten */         
             me->geom_parms_b = me->locate_event2.located_object[0].geom_parms;  /*  reset to original value  */

             sts = GR2bcisectutil(                        
                             &msg,
                             &curve_bound,      /* ext array-b      */
                             &bc2,              /* ext array-e (overwritten!) */
                             &me->geom_parms_b, /* param-b          */
                             &geom_parms_e,     /* param-e          */
                             &props_b,          /* properties-b     */
                             &props_e,          /* properties -e    */
                             space_b2,          /* b-spline-b expanded */
                             space_e2);         /* b-spline-e expanded */

             if (me->extend_b_extend)  curve_1_work = space_b2;     

             if (   bound_ele_classid == OPP_GR3dcirarc_class_id
                 || bound_ele_classid == OPP_GR3dellarc_class_id
                 || bound_ele_classid == OPP_SKcircle_class_id
                 || bound_ele_classid == OPP_SKarc_class_id        )
             {
               /*   allocate arc_space 7poles/ 7weights/ 10 knots  */
               if (space_b3)  {  BSfreecv(&rc, space_b3); space_b3 = NULL;  }
               BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 1, 0,
                         &space_b3, &rc);
               if (rc)  Goto (wrapup);
               curve_1_work = space_b3;

               sts = BSfullarc(&rc, curve_bound, curve_1_work); 
               if (!(1&sts))  Goto (wrapup);
             }

             extend_e_extend =
                               extend_ele_classid == OPP_GR3dlineseg_class_id 
                            || extend_ele_classid == OPP_GR3dcirarc_class_id
                            || extend_ele_classid == OPP_GR3dellarc_class_id
                            || extend_ele_classid == OPP_SKline_class_id
                            || extend_ele_classid == OPP_SKarc_class_id ;

             if (extend_e_extend)  curve_2_work = space_e2;

             if (   extend_ele_classid == OPP_GR3dcirarc_class_id
                 || extend_ele_classid == OPP_GR3dellarc_class_id
                 || extend_ele_classid == OPP_SKarc_class_id )    
             {

               if (space_e3)  {  BSfreecv(&rc, space_e3); space_e3 = NULL;  } 
               /*   allocate arc_space 7poles/ 7weights/ 10 knots  */
               BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 1, 0,
                         &space_e3, &rc);
               if (rc)  Goto (wrapup);
               curve_2_work = space_e3;

               sts = BSfullarc(&rc, curve_extend, curve_2_work); 
               if (!(1&(sts)))  Goto (wrapup);
             }

             /*  intersect curves  */
             xint_pts = NULL;
             xovl_pts = NULL;

             BScvcvint(
               curve_1_work,     /* first element to intersect */
               curve_2_work,     /* second element to intersect */
               TRUE,             /* remove duplicate intersect points */
               NR_PRE_INT,       /* number of preallocated intersect points */
               NR_PRE_OVL,       /* number of preallocated overlap points */
               int_pts,          /* preallocated intersection points */
               ipar1,      /* preallocated intersect par curve1 */
               ipar2,     /* preallocated intersect par curve2 */
               ovl_pts,          /* preallocated overlap points */
               opar1,      /* preallocated overlap par curve1 */
               opar2,     /* preallocated overlap par curve2 */
               &n_int,           /* number of intersection points found */
               &n_ovl,           /* number of overlappoints found */
               &out_int_alloc,   /* are int points in xint_pts (TRUE) */
               &out_ovl_alloc,   /* are overlaps in xovl_pts (TRUE) */
               &xint_pts,        /* intersection points alloc by the math */
               &xipar1,          /* intersection paramaters alloc by math */
               &xipar2,          /* intersection paramaters alloc by math */
               &xovl_pts,        /* overlap points alloc by the math */
               &xopar1,          /* overlap paramaters alloc by math */
               &xopar2,          /* overlap paramaters alloc by math */
               &msg);            /* error return code */

             intersect_found = (n_int > 0  ||  n_ovl > 0); 
             if ( n_int + n_ovl >= 1) 
             { 
               best1 = best2 = best3 = orig_best3 = NULL;
	       for (jj = 0; jj < 3; jj++)         
               {
                 /*  find the 1st/2nd nearest point in intersect array */
                 dist_best_sq = GRDGNLIMITS_MAX_D * GRDGNLIMITS_MAX_D;

                 for (i=0; i<n_int; i++)
                 {
                   /*  calculate squared distance to accept_point  */
                   if (out_int_alloc)  sts = MA2pt2dis(&msg, xint_pts[i], appr_intersect, &dist_sq);
                   else                sts = MA2pt2dis(&msg, int_pts[i],  appr_intersect, &dist_sq);
                   if (dist_sq < dist_best_sq)
                   {
                     if (jj == 0)
                     { 
                       dist_best_sq = dist_sq;
                       best1 = i + 1; 
                     }
                     else
                     {
                       if (i != ABS(best1)-1)
                       {
                         if (jj != 1)
                         {
                           dist_best_sq = dist_sq;
                           best2 = i + 1;
                         } 
                         else 
                         { 
                           if (out_int_alloc) BSmkvec(&rc, vec_wrk, xint_pts[i], appr_intersect); 
                           else               BSmkvec(&rc, vec_wrk,  int_pts[i], appr_intersect); 
                           dot = BSdotp(&rc, vec_best1, vec_wrk);
                           if (dot > 0)
                           {
                             dist_best_sq = dist_sq; 
                             best3 = i + 1; 
                           }
                         } 
                       }
                     }
                   }
                 }

                 /*  find the 1st/2nd nearest point in overlay array */
                 for (i=0; i<n_ovl; i++)
                 {
                   /*  calculate squared distance to accept_point  */
                   if (out_ovl_alloc)  sts = MA2pt2dis(&msg, xovl_pts[i], appr_intersect, &dist_sq);
                   else                sts = MA2pt2dis(&msg, ovl_pts[i],  appr_intersect, &dist_sq);
                   if (dist_sq < dist_best_sq)
                   {
                     if (jj == 0)
                     { 
                       dist_best_sq = dist_sq;
                       best1 = -(i + 1);
                     }
                     else
                     {
                       if (i != ABS(best1)-1)
                       {
                         if (jj != 1)
                         {
                           dist_best_sq = dist_sq;
                           best2 = -(i + 1);
                         } 
                         else 
                         { 
                           if (out_int_alloc) BSmkvec(&rc, vec_wrk, xovl_pts[i], appr_intersect); 
                           else               BSmkvec(&rc, vec_wrk,  ovl_pts[i], appr_intersect); 
                           dot = BSdotp(&rc, vec_best1, vec_wrk);
                           if (dot > 0)
                           {
                             dist_best_sq = dist_sq; 
                             best3 = -(i + 1); 
                           }
                         } 
                       }
                     }
                   }
                 }
                
                 if (jj == 1)  
                 {
                   /*  save point1 / prepare point3 search  */
                   for (k=0; k<3; k++)  
                   {
                     if (best1 > 0) 
                     {
                       if (out_int_alloc)  point1[k] = xint_pts[best1-1][k];
                       else                point1[k] =  int_pts[best1-1][k];
                     }
                     else
                     {
                       if (out_ovl_alloc)  point1[k] = xovl_pts[-best1-1][k];
                       else                point1[k] =  ovl_pts[-best1-1][k];
                     }
                   }
                   /*  calculate work direction vector  */
                   BSmkvec(&rc, vec_best1, point1, appr_intersect);  
                 }
               }      

               orig_best3 = best3;
               if (best3 == 0)  best3 = best2;
               for (k=0; k<3; k++)               /*  copy point2  */  
               {
                 if (best2 > 0) 
                 {
                   if (out_int_alloc)  point2[k] = xint_pts[best2-1][k];
                   else                point2[k] =  int_pts[best2-1][k];
                 }
                 else
                 {
                   if (out_ovl_alloc)  point2[k] = xovl_pts[-best2-1][k];
                   else                point2[k] =  ovl_pts[-best2-1][k];
                 }

                 if (best3 > 0)               /*  copy point3  */ 
                 {
                   if (out_int_alloc)  point3[k] = xint_pts[best3-1][k];
                   else                point3[k] =  int_pts[best3-1][k];
                 }
                 else
                 {
                   if (out_ovl_alloc)  point3[k] = xovl_pts[-best3-1][k];
                   else                point3[k] =  ovl_pts[-best3-1][k];
                 }  
               }

               /*  copy best parameters 1-3  */
               if (best1 > 0) 
               {
                 if (out_int_alloc)  parme1 = xipar2[best1-1];
                 else                parme1 =  ipar2[best1-1];
               }
               else
               {
                 if (out_ovl_alloc)  parme1 = xopar2[-best1-1];
                 else                parme1 =  opar2[-best1-1];
               }

               if (best2 > 0) 
               {
                 if (out_int_alloc)  parme2 = xipar2[best2-1];
                 else                parme2 =  ipar2[best2-1];
               }
               else
               {
                 if (out_ovl_alloc)  parme2 = xopar2[-best2-1];
                 else                parme2 =  opar2[-best2-1];
               }

               if (best3 > 0) 
               {
                 if (out_int_alloc)  parme3 = xipar2[best3-1];
                 else                parme3 =  ipar2[best3-1];
               }
               else
               {
                 if (out_ovl_alloc)  parme3 = xopar2[-best3-1];
                 else                parme3 =  opar2[-best3-1];
               }
          
               /*  recalculate nearest intersection parameter    */
               /*  if extend element was extended to max curve size  */
               if (extend_e_extend)
               {            
                 BSprptoncv(&rc, curve_extend, point1, &parm_int1u, &on_curve);
                 if (rc)  Goto (wrapup);
                 BSprptoncv(&rc, curve_extend, point2, &parm_int2u, &on_curve);
                 if (rc)  Goto (wrapup);
                 BSprptoncv(&rc, curve_extend, point3, &parm_int3u, &on_curve);
                 if (rc)  Goto (wrapup);
               }

               /*  return space form extra points allocated by intersection  */
               if (xint_pts)  { free(xint_pts); free(xipar1); free(xipar2); } 
               if (xovl_pts)  { free(xovl_pts); free(xopar1); free(xopar2); }
             }
             /*------------------------------------*/
             /*  end of non apparent intersection  */
             /*------------------------------------*/
           }

           else

           {
             /*------------------------------------------------------------*/
             /*  calculate apparent intersect point in the extend element  */
             /*------------------------------------------------------------*/

             sts = GR2objaisect(&msg_tst, 
                              &extend_ele,         /* extend element         */
                              p_module_info_e,     /* extend ele module inf  */
                              &geom_parms_e,       /* extend ele parameters  */
                              &me->bound_ele,      /* bound element          */
                              &me->module_info_b,  /* bound ele module inf   */
                              &me->geom_parms_b,   /* bound ele parameters   */
                              Guess_point,         /* approximate int pt     */
                              view_vector,         /* unit view vector       */
                              pnt_cur);            /* actual intersect       */
             msg = msg_tst;
             if (!(1&(sts&msg)))  Goto (wrapup);

             /*  check if same intersection as first  */
             if (fabs(pnt_cur[0]-intersect_point[0]) < eps  &&
                 fabs(pnt_cur[1]-intersect_point[1]) < eps  &&
                 fabs(pnt_cur[2]-intersect_point[2]) < eps  )      
             {
               for (i=0; i<3; i++)
                 Guess_point[i] = appr_intersect[i] - DIFF;

               /*  calculate apparent intersect point in the extend element  */
               sts = GR2objaisect(&msg_tst, 
                              &extend_ele,         /* extend element         */
                              p_module_info_e,     /* extend ele module inf  */
                              &geom_parms_e,       /* extend ele parameters  */
                              &me->bound_ele,      /* bound element          */
                              &me->module_info_b,  /* bound ele module inf   */
                              &me->geom_parms_b,   /* bound ele parameters   */
                              Guess_point,         /* approximate int pt     */
                              view_vector,         /* unit view vector       */
                              pnt_cur);            /* actual intersect       */
               msg = msg_tst;
               if (!(1&(sts&msg)))  Goto (wrapup); 
             }
             n_int = n_int + n_ovl;
           }

           /*------------------------------------*/
           /*  end of intersection calculations  */
           /*------------------------------------*/

           if (!curve_extend->phy_closed)   
           {

             if (n_int)
             {
               /*---------------------------------------------------------*/
               /*---------------------------------------------------------*/
               /*  open extend element - possible multiple intersections  */
               /*       prepare basic single side trim / open curve       */
               /*---------------------------------------------------------*/
               /*---------------------------------------------------------*/

               /*  get work start/end  */
               cv_start_par = CV_START_PARAM;
               cv_end_par   = CV_END_PARAM;
         
               /*  evaluate original start_point  */
               BScveval(space_e1, cv_start_par, 0, &e_start_point, &rc);
               if (rc)  Goto (wrapup);

               /*  evaluate original end_point  */
               BScveval(space_e1, cv_end_par, 0, &e_end_point, &rc);
               if (rc)  Goto (wrapup); 
             
               /*  evaluate original offset_point in work direction */
               par_few = cv_start_par + FEW;    
               BScveval(space_e1, par_few, 0, &e_few_point, &rc);
               if (rc)  Goto (wrapup); 
             
               /*  recalculate accept parameter on extend  */
               BSprptoncv(&rc, curve_2_work, appr_intersect, &parm_ext_a, &on_curve);
               /*  recalculate old curve start point parameter on extend  */
               BSprptoncv(&rc, curve_2_work, e_start_point, &parm_ext_s, &on_curve);
               /*  recalculate old curve end point parameter on extend  */
               BSprptoncv(&rc, curve_2_work, e_end_point, &parm_ext_e, &on_curve);
               /*  recalculate old curve few point parameter on extend  */
               BSprptoncv(&rc, curve_2_work, e_few_point, &parm_ext_m, &on_curve);


               sts = MA2pt2dis(&msg, point1, e_start_point, &dist);
               if (dist < eps*eps)   same_start = 1;
               sts = MA2pt2dis(&msg, point1, e_end_point, &dist);
               if (dist < eps*eps)   same_end = 1;
               sts = MA2pt2dis(&msg, point2, e_start_point, &dist);
               if (dist < eps*eps)   same_start = 2;
               sts = MA2pt2dis(&msg, point2, e_end_point, &dist);
               if (dist < eps*eps)   same_end = 2;

               /*  calculate squared distance to original start_point  */
               sts = MA2pt2dis(&msg, e_start_point, appr_intersect, &dist_e_s);
               /*  calculate squared distance to original end_point  */
               sts = MA2pt2dis(&msg, e_end_point, appr_intersect, &dist_e_e);

               if (dist_e_s < dist_e_e)   near_end = 0;
               else                       near_end = 1;   

               /*  calculate distance from trimpoint to original start_point  */
               sts = MA2pt2dis(&msg, point1, e_start_point, &dist);
               if (dist < eps*eps)  ind_same += 1;

               /*  calculate distance from trimpoint to original end_point  */
               sts = MA2pt2dis(&msg, point1, e_end_point, &dist);
               if (dist < eps*eps)  ind_same += 2;
 
               parm_real_a = parm_ext_a;
               /*  calculate real curve parameter extend (start/end) */
               /*  define real nearest intersect within curve for side decition base */
               dif_m_s = parm_ext_m - parm_ext_s;
               if (dif_m_s < 0.5)  dif_m_s += WRAP;
               if (dif_m_s > 0.5)  dif_m_s -= WRAP;       
               if (ABS(dif_m_s) < eps)
               {
                 goto idle;
               }
               curve_dir = dif_m_s;

               if (curve_dir > 0)
               { 
                 parm_real_s = parm_ext_s;
                 parm_real_e = parm_ext_e;
                 if ( parm_real_e < parm_real_s)  parm_real_e += WRAP;
               }
               else
               { 
                 /*  switch start/end  */
                 parm_real_s = parm_ext_e;
                 parm_real_e = parm_ext_s;
                 if ( parm_real_e < parm_real_s)  parm_real_e += WRAP;
               }
               if (parm_real_a < parm_real_s)  parm_real_a += WRAP;

               /*  extract nearest intersection in true curve part  */
               parm_real_i1 = -1.0;
               if (parme1 >= parm_real_s-epsx && parme1 <= parm_real_e+epsx)
                 parm_real_i1 = parme1;
               if (parme1+WRAP >= parm_real_s-epsx && parme1+WRAP <= parm_real_e+epsx)
                 parm_real_i1 = parme1 + WRAP;
             }

             if (n_int >= 2)
             { 
               /*--------------------------------------------------*/
               /*  prepare extended single side trim / open curve  */
               /*--------------------------------------------------*/

               /*  extract nearest intersection in true curve part  */
               /*  2nd intersection point                           */
               parm_real_i2 = -1.0;

               if (parme2 >= parm_real_s-epsx && parme2 <= parm_real_e+epsx) 
                   parm_real_i2 = parme2;

               if (parme2+WRAP >= parm_real_s-epsx && parme2+WRAP <= parm_real_e+epsx)
                   parm_real_i2 = parme2 + WRAP;


               if (parm_real_i1 >= 0  &&  parm_real_i2 >= 0)
               {
                 if ( MIN (ABS(parm_real_i1 - parm_real_a),
                           ABS(parm_real_i1 - parm_real_a+WRAP) )
                    < MIN (ABS(parm_real_i2 - parm_real_a),
                           ABS(parm_real_i2 - parm_real_a+WRAP) ) )
                                           parm_real_i = parm_real_i1;
                 else                      parm_real_i = parm_real_i2;

                 parm_a_start = parme1;
                 parm_a_end   = parme2;
               }


               if (parm_real_i1 < 0  &&  parm_real_i2 < 0)
               {
                 parm_real_i  = parme1;
                 parm_real_i1 = parme1;
                  
                 parm_a_start = parm_real_s;
                 parm_a_end   = parm_real_e;
               }
               else
               { 
                 if (parm_real_i1 < 0 || parm_real_i2 < 0)
                 {
                   if (parm_real_i1 < 0)  parm_real_i = parm_real_i2; 
                   if (parm_real_i2 < 0)  parm_real_i = parm_real_i1;

                   parm_a_start = parm_real_i;
                   if (parm_real_i < parm_real_a)  parm_a_end = parm_real_e;
                   else                            parm_a_end = parm_real_s;
                 }
               }

               parm_real_t = 0.5 * (parm_a_start + parm_a_end); 
               if (parm_real_t > parm_real_e)  parm_real_t -= WRAP;
               if (parm_real_t < parm_real_s)  parm_real_t += WRAP;

               parm_real_ot = parme2;

               start_in = ( MIN(parme1, parme2) < (parm_ext_s+epsx) 
                        &&  MAX(parme1, parme2) > (parm_ext_s-epsx));

               end_in   = ( MIN(parme1, parme2) < (parm_ext_e+epsx) 
                        &&  MAX(parme1, parme2) > (parm_ext_e-epsx));

               /*----------------------*/
               /*  end of preparation  */
               /*----------------------*/


               /*  one curve must be open  */
               if ( !curve_bound->phy_closed || !curve_extend->phy_closed ) 
               {
                 ind_to = 1;        
                 if (parm_real_a < parm_real_t)  ind_repl = 1;
                 else                            ind_repl = 2;


                 /*  decide side of accept pick  start/end       */
                 /*  if not both intersections in visible range  */

                 if (parm_real_i1 < 0  ||  parm_real_i2 < 0)
                 { 
                   /*  define nearest intersection in positive work direction  */
                   if (parm_real_a < parm_real_t)  
                   {
                     parm_dist1 = parm_real_a - parme1;
                     parm_dist2 = parm_real_a - parme2;
                   }
                   else
                   {
                     parm_dist1 = parme1 - parm_real_a;
                     parm_dist2 = parme2 - parm_real_a;
                   }

                   if (parm_dist1 < 0)      parm_dist1 += WRAP;
                   if (parm_dist1 < 0)      parm_dist1 += WRAP;  /*  needed! */
                   if (parm_dist1 >= WRAP)  parm_dist1 -= WRAP;
                   if (parm_dist2 < 0)      parm_dist2 += WRAP;
                   if (parm_dist2 < 0)      parm_dist2 += WRAP;  /*  needed! */
                   if (parm_dist2 >= WRAP)  parm_dist2 -= WRAP;

                   if (parm_dist1 < parm_dist2)  ind_to = 1;
                   else                          ind_to = 2;

                   if (ind_repl == 1)  parm_wrk = parm_real_s;
                   else                parm_wrk = parm_real_e;

                   parm_dist_as = parm_wrk - parm_real_a;
                   if (parm_dist_as < 0)  parm_dist_as += WRAP;
                   if (parm_dist_as < eps)
                   {
                     if (parm_wrk < 0.5)  parm_dist_as = 0.1;
                     else                 parm_dist_as = 0.9;

                     parm_real_a = parm_wrk;
                     /*  inform user of identififation outside of element range  */
                     sts = ex$message(msgnumb = MSG_TRIM_OUT,
                                      field   = ERROR_FIELD);
                     if (!(1&sts))  Goto (wrapup); 
                   }

 

                   if (   extend_ele_classid == OPP_GR3dlineseg_class_id
                       || extend_ele_classid == OPP_SKline_class_id )
                   {
                     /*-----------------------------------------------*/
                     /*-------- extend element = line ----------------*/
                     /*-----------------------------------------------*/

                     if ( start_in && !end_in  ||  !start_in && end_in)
                     {
                       work_type = 10; 
                       if  (!start_in  &&  parm_real_i > parm_real_a 
                                       &&  parm_real_a > parm_real_s)
                       {   
                         work_type = 11;
                         if (ABS(parm_real_a - parm_real_s)
                           > ABS(parm_real_i - parm_real_a) )
                         {                        
                           if (parm_real_a < parm_real_i < 0)  ind_repl = 1;
                           else                                ind_repl = 2;

                           if (ind_repl == 1  &&  same_start)  goto do_it_toggle;
                           if (ind_repl == 2  &&  same_end)    goto do_it_toggle;
                           goto do_it;
                         }
                         no_undo = TRUE; 
                         goto idle;          /*  change nothing  */   
                       }

                       if  (!end_in  &&  parm_real_i < parm_real_a 
                                     &&  parm_real_a > parm_real_s)
                       {
                         work_type = 12; 
                         if (ABS(parm_real_e - parm_real_a)
                           > ABS(parm_real_a - parm_real_i) )
                         {   
                           if (parm_real_a < parm_real_i < 0)  ind_repl = 2;
                           else                                ind_repl = 1;

                           if (ind_repl == 2  &&  same_end)   goto do_it_toggle;
                           if (ind_repl == 1  &&  same_start)    goto do_it_toggle;
                           goto do_it;
                         } 
                         goto idle;          /*  change nothing  */
                       }

                       /*  check for already trimmed side / message  */
                       if (ABS(parm_real_i - parm_real_s) < epsx 
                        || ABS(parm_real_i - parm_real_e) < epsx)
                       {
                         /*  inform user of already trimmed side  */
                         sts = ex$message(msgnumb = MSG_TRIM_ALR1,
                                          field   = ERROR_FIELD);
                         if (!(1&sts))  Goto (wrapup);
                       }
                     }
  
                     if ( !start_in && !end_in)
                     {
                       work_type = 13; 
                       if ( ABS(parm_real_s - parm_real_i) 
                         <  ABS(parm_real_e - parm_real_i) )  ind_repl = 1;
                       else                                   ind_repl = 2;
                       if (curve_dir < 0)  ind_repl = 3 - ind_repl;   /*  observe reversed work direction  */
                       ind_to = 1;
                     }
                     goto do_it;        
                    
                     /*-----------------------------------------*/
                   } /*  end of: extend = line segment special  */
                     /*-----------------------------------------*/
                
            

                   if (curve_dir < 0)  ind_repl = 3 - ind_repl;   /*  observe reversed work direction  */

                   /*------------------------------*/
                   /*  general bound toggle check  */
                   /*------------------------------*/
 
                   if ( (ind_repl == 1  &&  same_start)
                     || (ind_repl == 2  &&  same_end)   )
                   {
                     work_type = 14; 
                     goto do_it_toggle;    
                   }
                   goto do_it; 
                 } 


                 /*-----------------------------*/
                 /*  curve side trim decision   */
                 /*  2 intersection on curve_e  */
                 /*-----------------------------*/

                 if (!same_start || !same_end || n_int != 2)
                 {
                   /*  not both sides already trimmed and 2 intersetions  */
                   if (parm_real_i1 < 0)  parm_real_i1 = parme3; 
                   if (parm_real_i2 < 0)  parm_real_i2 = parme3;  
           
                   if (parm_real_a < parm_real_i)  ind_repl = 2;
                   else                            ind_repl = 1;
                   if (curve_dir < 0)  ind_repl = 3 - ind_repl;   /*  observe reversed work direction  */

                   work_type = 15;
                   if (orig_best3)
                   {
                     if ((ind_repl == 1  &&  same_start == 1) 
                      || (ind_repl == 2  &&  same_end == 1  ))  goto do_it_toggle;
                   }
                   goto do_it;
                 }

                 /*------------------------------*/
               } /*  end of open curve handling  */   
                 /*------------------------------*/


               /*  handle both trimmed  */
               if (same_start && same_end)
               { 
                 /*  inform user of already trimmed side  */
                 sts = ex$message(msgnumb = MSG_TRIM_ALR2,
                                  field   = ERROR_FIELD);
                 if (!(1&sts))  Goto (wrapup);
                 already_msg = TRUE; 
                 no_undo = TRUE;
                 goto idle;                   /*  change nothing  */
               }

               /*------------------------------------------------*/
             } /*  end of open extend element - 2 intersections  */
               /*------------------------------------------------*/
   
                   
             /*--------------------*/
             /*  single intersect  */
             /*--------------------*/

             if (n_int == 1)
             {
               ind_to = 1;
               /*  decide side to replace  */
               /*  use recalculate nearest intersection parameter  */
               tw = -1;
               if (parm_real_i1 < 0)
               {
                 /*  intersection outside in curve part  */
                 if ( ABS(parm_real_a - parm_real_s)
                   <  ABS(parm_real_a - parm_real_e) )  tw = CV_START_PARAM;    
                 else                                   tw = CV_END_PARAM;
               }
               else
               {    
                 if (parm_real_a > parm_real_i1)  tw = CV_END_PARAM;
                 else                             tw = CV_START_PARAM;
                 if (curve_dir > 0)  tw = CV_END_PARAM - tw;   /*  observe reversed work direction  */
               }

               if (tw < 0.5) 
               {
                 for (i=0; i<3; i++)
                 Endpoint[i] = curve_extend->poles[i];
               }
               else
               {
                 for (i=0; i<3; i++)
                 Endpoint[i] = curve_extend->poles[(curve_extend->num_poles -1)*3 + i];
               }
               ind_repl = 0;            /*  endpoint already set  */
             }
             goto do_it;



idle:
             /*  save last work indication for second bound extend  */ 
             last_trim_same  = ind_same;
             last_near_end   = near_end;
             last_trim_objid = extend_ele.objid;
             last_work_type  = work_type;  
             last_ind_repl   = ind_repl;
             last_ind_to     = ind_to; 

             /*  erase element with old extension  */
             sts = dp$display(msg  = &msg,
                              mode = GRbehe,
                              oids = &extend_ele);

             /*  redraw old element in case of error  */
             sts = dp$display(msg  = &msg,   
                              mode = GRbdhe,
                              oids = &extend_ele);  
             if (!(1&(sts&msg)))  Goto (wrapup);
   
             ME.super_cmd->state = IDENTIFY_ELEMENT;
             break;     


do_it_toggle:
              if (last_work_type  == work_type  
              && last_trim_same  == ind_same
              && last_near_end   == near_end
              && last_trim_objid == extend_ele.objid
              && last_ind_repl   == ind_repl
              && last_ind_to     == ind_to)  
             {
               ind_to = 3;
               goto do_it;
             } 
             /*  inform user of already trimmed side and border switching  */
             sts = ex$message(msgnumb = MSG_TRIM_ALR_DP,
                              field   = ERROR_FIELD);
             if (!(1&sts))  Goto (wrapup); 
             already_msg = TRUE;
             no_undo = TRUE;   
             goto idle;                   /*  change nothing  */   


do_it:
             /*-------------------------*/
             /*  common final handling  */
             /*-------------------------*/

             /* inform user of alredy trimmed side  */
             if (ind_same  &&  !already_msg)
             {
               dist = 2*eps*eps;      
               /*  check for already same side trimmed as new  */
               if (ind_repl == 1  &&  same_start)
                 sts = MA2pt2dis(&msg, e_start_point, point1, &dist);
               if (ind_repl == 2  &&  same_end)
                 sts = MA2pt2dis(&msg, e_end_point, point1, &dist);
               if (dist < eps*eps)         
               {
                 /*  inform user of already trimmed side  */
                 sts = ex$message(msgnumb = MSG_TRIM_ALR1,
                                  field   = ERROR_FIELD);
                 if (!(1&sts))  Goto (wrapup);
               }
             }
             parm_int.u = parm_int1u;  
           }  
         }        
       }
  


       /*  save last work indication for second bound extend  */ 
       last_trim_same  = ind_same;
       last_near_end   = near_end;
       last_trim_objid = extend_ele.objid;
       last_work_type  = work_type;  
       last_ind_repl   = ind_repl;
       last_ind_to     = ind_to; 

       if (!intersect_found) 
       {
         /*  inform user of wrong element  */
         sts = ex$message(msgnumb = ERROR_MSG_NOINT,
                          field   = ERROR_FIELD);
         if (!(1&sts))  Goto (wrapup);

         /*  erase highlight and redraw old element in case of error  */
         sts = dp$display(msg  = &msg,   
                          mode = GRbdhe,
                          oids = &extend_ele);  
         if (!(1&(sts&msg)))  Goto (wrapup);

       }

       if ( !intersect_found ||                           /*  no intersection  */
           (n_int == 1  &&  curve_extend->phy_closed) )   /*  do nothing  */
       {
         /*  redraw old element in case of error  */
         sts = dp$display(msg  = &msg,   
                          mode = GRbdhe,
                          oids = &extend_ele);  
         if (!(1&(sts&msg)))  Goto (wrapup);
   
         ME.super_cmd->state = IDENTIFY_ELEMENT;
         break;            
       }

       if (me->saved_ele.objid != NULL_OBJID) 
       {
         /*  delete last for undo saved element  */
         sts = om$send (msg      = message Root.delete(0),
                        targetid = me->saved_ele.objid,
                        targetos = me->saved_ele.osnum);
         if (!(1&sts))  Goto (wrapup);
       }


       /*  make basic copy of element  */
       sts = ECtrm_cpb(extend_ele, &me->saved_ele);
       if (!(1&sts))  Goto (wrapup);

       sts = ECtrm_del(REM_R_TREE, me->saved_ele, &module_info_e); 

       /*  save module_info_u for other methods (sleep)  */
       module_info_s   = module_info_e;     
       p_module_info_s = &module_info_s; 

       /*  erase element with old extension  */
       sts = dp$display(msg  = &msg,
                        mode = GRbehe,
                        oids = &extend_ele);
       if (!(1&(sts&msg)))  Goto (wrapup);


       /*--------------------------*/
       /*  modify trimmed element  */
       /*--------------------------*/

         if (shure_single_int) 
         {
           /*-----------------------*/
           /*  single intersection  */
           /*-----------------------*/

           /*  save both points  for undo  */
           for (k=0; k<3; k++)
           {
             me->last_extend_from[k] = intersect_point[k];
             me->last_extend_to[k]   = Endpoint[k];
           }

           /*  handle line-line  */ 
           /*  send to the object to get it to extend itself  */
           sts = om$send( mode = OM_e_wrt_object,
                   msg = message GRcurve.GRptextend(  
                                   &msg,
                                   &module_info_e,
                                   Endpoint,         /* pnt to extend    */   
                                   intersect_point,  /* pnt to extend to */
                                   Endpoint ),       /* new end pnt      */
                   targetid = extend_ele.objid,
                   targetos = extend_ele.osnum);
           if (!(1&(sts&msg)))  Goto (wrapup);
         }

         else

         {
           /*-------------------------*/
           /*  mulpiple intersections */
           /*-------------------------*/

           if (n_int < 1)  goto idle;

           if (!curve_extend->phy_closed)
           {
             /*--------------*/
             /*  open curve  */
             /*--------------*/

             if (curve_new == NULL) 
             {
               for (i=0; i<3; i++) 
               { 
                 if (ind_repl == 1)  Endpoint[i] = e_start_point[i]; 
                 if (ind_repl == 2)  Endpoint[i] = e_end_point[i]; 
                 if (ind_to == 1)  From_point[i] = point1[i]; 
                 if (ind_to == 2)  From_point[i] = point2[i]; 
                 if (ind_to == 3)  From_point[i] = point3[i]; 
               }
               /*  save both points  for undo  */
               for (k=0; k<3; k++)
               {
                 me->last_extend_from[k] = From_point[k];
                 me->last_extend_to[k]   = Endpoint[k];
               }

               /*  trim range very near bspline end or out   */
               sts = MA2pt2dis(&msg, Endpoint, From_point, &dist);
               if (dist < eps*eps)   goto idle;

               sts = om$send( mode = OM_e_wrt_object,               
                       msg = message GRcurve.GRptextend(
                                      &msg,
                                      &module_info_e,
                                      Endpoint,        /* pnt to be extended */ 
                                      From_point,      /* to extend to this  */ 
                                      pnt_dummy),      /* new end pnt        */
                      targetid = extend_ele.objid,
                      targetos = extend_ele.osnum);
               if (!(1&(sts&msg)))
             {

               /*  redraw old element in case of error  */
               sts = dp$display(msg  = &msg,   
                                mode = GRbdhe,
                                oids = &extend_ele); 
               }
             if (!(1&(sts&msg)))  Goto (wrapup);
             }

             else 
    
             { 
               /*  trim range in large bspline array  */
               post_info.construct_flag = FALSE;
               /*  modify current */ 
               sts = om$send(mode = OM_e_wrt_object,
                             msg  = message GRvg.GRpostabsg(
                                 &msg,
                                 &module_info_e,
                                 &post_info,             /* same elelement  */
                                 (IGRchar *) curve_new,  /* curve data      */
                                 &newid),               
                        targetid = extend_ele.objid,
                        targetos = extend_ele.osnum);   
             }  
           }

           else

           {
             /*----------------*/
             /*  closed curve  */
             /*----------------*/

             From_parms.u = parme1;
             parm_int.u   = parme2;

             if (geom_parms_e.u > parme1)
             {
               for (i=0; i<3; i++)  End_point[i] = point2[i]; 
               End_parms.u = parme2; 
             }
             else
             {
              
               for (i=0; i<3; i++)
               {
                 End_point[i]  = From_point[i]; 
                 From_point[i] = point2[i]; 
               }
               End_parms.u   = From_parms.u; 
               From_parms.u  = parm_int.u;
             }

             if (End_parms.u == CV_START_PARAM && From_parms.u > CV_START_PARAM)
                End_parms.u = CV_END_PARAM;
             /*  Dir_point is part to be deleted / reverse to accept point  */
             step_dist_f = geom_parms_e.u - From_parms.u;
             step_dist_e = geom_parms_e.u - End_parms.u;
             if (fabs(step_dist_f) < fabs(step_dist_e))
               Dir_parms.u  = From_parms.u + ((step_dist_f < 0) ? offset : -offset);
             else
               Dir_parms.u  = End_parms.u + ((step_dist_e < 0) ? offset : -offset);
             if (Dir_parms.u < CV_START_PARAM) Dir_parms.u = Dir_parms.u + CV_END_PARAM;
             if (Dir_parms.u > CV_END_PARAM)   Dir_parms.u = Dir_parms.u - CV_END_PARAM;

             /*  Dir_point not used here  */
             for (i=0; i<3; i++)  Dir_point[i] = appr_intersect[i];


             /*  send to the object to get it to split itself  */
             if ( extend_ele_classid != OPP_GRcompcurve_class_id)
             {
               sts = om$send(mode = OM_e_wrt_object,
                             msg  = message GRcurve.GR3ptpartdel(
                                        &msg,
                                        &module_info_e,
                                        From_point,
                                        Dir_point, 
                                        End_point,
                                        &From_parms,
                                        &Dir_parms,
                                        &End_parms,
                                        &c1,
                                        &c2,
                                        &num ),   
                            targetid = extend_ele.objid,
                            targetos = extend_ele.osnum);
               if (!(1&(sts&msg)))  Goto (wrapup);

             }
             else
             {
               sts = om$send(mode = OM_e_wrt_ancestor,
                             msg  = message GRcurve.GR3ptpartdel( 
                                      &msg,
                                      &module_info_e,
                                      From_point,
                                      Dir_point, 
                                      End_point,
                                      &From_parms,
                                      &Dir_parms,
                                      &End_parms,
                                      &c1,
                                      &c2,
                                      &num ), 
                       targetid = extend_ele.objid,
                       targetos = extend_ele.osnum);
               if (!(1&(sts&msg)))  Goto (wrapup);
             }
             extend_ele.objid = c1;
           }
         }
       {   


       if (main_obj2.objid != NULL_OBJID)
       {

         IGRint                 indx;
         IGRint                 ii;
         IGRint                 member_cnt;
         IGRint                 num_segs;
         OMuint                 chan_count;
         OM_S_CHANSELECT        to_ch_ptr;
         OM_S_OBJECT_LINKAGE    *chan_list;   

         struct  GRlc_info      *buf_ptr;
         struct  GRid           cur_grid;
         struct  GRid           new_grid;

         /*  comp curve reconstruct  */
         IGRlong                wrk_msg;
         IGRchar                *buf_x;
         struct GRmd_env        wrk_env;

         /*  make comp curve */
         struct GRvg_construct  construct_list;

         GRobjid               compcrv_id;
         IGRlong               err_crv_num;
         IGRboolean            assoc_flag;

         struct IGRdisplay     c_wrk_dis;
         struct IGResintx      c_old_attr;

         /*--- build new comp crv by partial copy ---*/
         chan_count = NULL;
         buf_ptr    = NULL;
         chan_list  = NULL;
         buf_x = NULL;

         sts =  om$make_chanselect (channame     = "GRcmpowner.to_components",
                                  p_chanselect = &to_ch_ptr);
         if (!(1&sts))  Goto (wrapup);

         sts = om$get_channel_count(osnum        = main_obj2.osnum,
                                    objid        = main_obj2.objid,
                                    p_chanselect = &to_ch_ptr,
                                    count        = &chan_count);
         if (chan_count <= NULL)  Goto (wrapup);


         chan_list = (OM_S_OBJECT_LINKAGE *) malloc(chan_count * sizeof(OM_S_OBJECT_LINKAGE));
         if (!chan_list)  Goto (wrapup);

         sts = om$get_channel_objects(osnum        = main_obj2.osnum,
                                      objid        = main_obj2.objid,
                                      p_chanselect = &to_ch_ptr,
                                      list         = chan_list,
                                      size         = chan_count,
                                      count        = &chan_count);
         if (!(sts&1)) Goto (wrapup);

         member_cnt = chan_count;

         buf_ptr = (struct  GRlc_info *) malloc(chan_count * sizeof (struct GRlc_info)); 
         if (!buf_ptr)  Goto (wrapup);

         sts = gr$get_module_env(msg    = &msg, 
                                 buffer = &wrk_env);
         if (!(sts&1)) Goto (wrapup);

         /*  handle each object  */     
         indx = 0;
         for (ii=0; ii<chan_count; ii++)
         {
           cur_grid.objid = chan_list[ii].S_objid;
           cur_grid.osnum = chan_list[ii].osnum;
      
           /*  make basic copy of element  */
           sts = ECtrm_cpb(cur_grid, &new_grid);
           if (!(1&sts))  Goto (wrapup);

           if (new_grid.objid == NULL)  continue;   /*  skip point  */  
           if (new_grid.objid == NULL_OBJID)  Goto (wrapup);

           buf_ptr[indx].located_obj.osnum = new_grid.osnum;
           buf_ptr[indx].located_obj.objid = new_grid.objid; 
           buf_ptr[indx].module_info = wrk_env;
           indx++;
          }    /*  for (ii=0; ii<...  */ 


          /*  make composite curve out of these segments (parts of curve) */

          /*  prepare construct  */ 
          construct_list.msg        = &wrk_msg;
          construct_list.env_info   = &wrk_env;
          construct_list.geometry   = NULL;       
          construct_list.display    = &c_wrk_dis;
          construct_list.class_attr = (IGRchar *) &c_old_attr; 

 
          EFget_construction_info_from_id(&msg,
                                          &construct_list,
                                          cur_grid.objid,
                                          cur_grid.osnum);
          if (! (1&msg))  Goto (wrapup);   

          sts = om$construct(classid   = OPP_GRcompcurve_class_id,
                             obj_osnum = NULL,
                             osnum     = cur_grid.osnum,
                             msg       = message GRgraphics.GRconstruct
                                                             (&construct_list),
                             p_objid   = &compcrv_id);
          if (!(1 & sts & msg)) Goto (wrapup);

          num_segs = indx;
          sts = om$send(mode = OM_e_wrt_object,
                        msg  = message GRcompcurve.EMmakecomp(
                                         &msg,           /* *msg          */
                                         &wrk_env,       /* *myModuleInfo */
                                         num_segs,       /* num_ent       */
                                         buf_ptr,        /* *entries      */
                                         &err_crv_num),  /* *rotten_one   */
                        senderid = NULL_OBJID,
                        targetid = compcrv_id,
                        targetos = cur_grid.osnum);

          if (!(1 & sts & msg))
          {
            new_grid.objid = NULL_OBJID;
            Goto (wrapup);
          }
          new_grid.objid = compcrv_id;
          new_grid.osnum = main_obj2.osnum;

          gr$get_associative_flag(buffer = &assoc_flag);

          if (assoc_flag)
          {
            sts = sk$convert_to_profile(msg      = &msg,
                                        options  = SK_CONVERT_VERBOSE,
                                        geometry = new_grid,
                                        module   = &wrk_env, 
                                        profile  = &compcrv_id,
                                        automask = SK_AUTO_GEOMETRIC);
            if (!(1&sts))  Goto (wrapup);
            new_grid.objid = compcrv_id;
          }

          sts = ECtrm_del(REM_R_TREE, main_obj2, &wrk_env);
          extend_ele = new_grid;

          if (buf_x)   free(buf_x); 
        }
      }
    } 
    /*  common open/closed  */         

    /*  clear abstract geom buffer to force new data  */
    GRabsg_del_all();
   

    /*  redraw new element  */
        sts = dp$display(msg  = &msg,
                        mode = GRbd,  
                        oids = &extend_ele);   
       if (!(1&(sts&msg)))  Goto (wrapup);

       /*  save last element handled  */
       me->last_extend_ele = extend_ele;

       /*  return space if not done before, return extend curve space only  */
       if (space_e1)  {  om$dealloc(ptr = space_e1);   space_e1  = NULL;  }
       if (space_e2)  {  om$dealloc(ptr = space_e2);   space_e2  = NULL;  }
       if (space_e3)  {  BSfreecv(&rc, space_e3);      space_e3  = NULL;  } 
       if (curve_new) {  om$dealloc(ptr = curve_new);  curve_new = NULL;  }

       ME.super_cmd->state = IDENTIFY_ELEMENT;
       break;


wrapup:
       if (space_b1)  {  om$dealloc(ptr = space_b1);   space_b1  = NULL;  }
       if (space_b2)  {  om$dealloc(ptr = space_b2);   space_b2  = NULL;  }
       if (space_b3)  {  BSfreecv(&rc, space_b3);      space_b3  = NULL;  }
       if (space_e1)  {  om$dealloc(ptr = space_e1);   space_e1  = NULL;  }
       if (space_e2)  {  om$dealloc(ptr = space_e2);   space_e2  = NULL;  }
       if (space_e3)  {  BSfreecv(&rc, space_e3);      space_e3  = NULL;  }
       if (curve_new) {  om$dealloc(ptr = curve_new);  curve_new = NULL;  }

       /*  avoid loop  */
       if (ME.super_cmd->state > IDENTIFY_BOUND)   ME.super_cmd->state--; 
       me->save_state = ME.super_cmd->state;
       break;

 
     }   
     /*  switch (ME.super_cmd->state)  */
     me->save_state = ME.super_cmd->state;
   } 

   while (TRUE); 

   /*  return (OM_S_SUCCESS);  */
} 




method sleep(int pos)
{
   IGRlong           sts, msg, rc;
   IGRint            member_cnt_x;

   IGRboolean        associative_flag;
   IGRboolean        closed_cvx; 
   struct GRmd_env   wrk_env;
   struct GRid       main_objx;


   sts = OM_S_SUCCESS;
   msg = MSSUCC;

   /*  delete last for undo saved element  */
   if (me->saved_ele.objid != NULL_OBJID)
   { 
     sts = gr$get_module_env(msg   = &msg, 
                            buffer = &wrk_env);

     /*  check for Smart Sketch obj and replace it by basic geo object */
     sts = ECtrm_SK(me->saved_ele, &me->saved_ele, &member_cnt_x, &closed_cvx, &main_objx);

     /*  delete last for undo saved element  */
     sts = om$send (msg      = message Root.delete(0),
                    targetid = me->saved_ele.objid,
                    targetos = me->saved_ele.osnum);

     me->saved_ele.objid = NULL_OBJID;
   }

   /*  clear message field when command is put to sleep  */
   sts = ex$message (field   = MESSAGE_FIELD,
                     msgnumb = EMS_I_ClearStatusField );
   if (!(1&sts))  Goto (wrapup); 

   /*  reset assoc marker  */
   gr$get_associative_flag( buffer = &associative_flag );
   if ( associative_flag )  GRdisplay_associative_button(FALSE);

   /*  return all used space  */
   if (space_b1)  {  om$dealloc(ptr = space_b1);   space_b1  = NULL;  }
   if (space_b2)  {  om$dealloc(ptr = space_b2);   space_b2  = NULL;  }
   if (space_b3)  {  BSfreecv(&rc, space_b3);      space_b3  = NULL;  }
   if (space_e1)  {  om$dealloc(ptr = space_e1);   space_e1  = NULL;  }
   if (space_e2)  {  om$dealloc(ptr = space_e2);   space_e2  = NULL;  }
   if (space_e3)  {  BSfreecv(&rc, space_e3);      space_e3  = NULL;  }
   if (curve_new) {  om$dealloc(ptr = curve_new);  curve_new = NULL;  }

wrapup:
   return(sts);
}




method wakeup (int pos)
{
   IGRshort       display_flag = 0;
   IGRshort       display_location;
   IGRlong        sts = OM_S_SUCCESS;
   IGRlong        msg;
   enum GRdpmode  display_mode[2];
   struct GRparms parm;
   IGRboolean     associative_flag;


   sts = OM_S_SUCCESS;
   msg = MSSUCC;

   /*  put name of command in message field  */
   sts = ex$message (field   = MESSAGE_FIELD,
                     msgnumb = COMMAND_TEXT);
   if (!(1&sts))  Goto (wrapup); 

   if (me->bound_ele.objid != NULL_OBJID)
   {
     /*  mark boundary in half highligh mode  */
     /*  mark display flag set for bound  */
     if (me->extend_b_extend)
     {
       display_mode[0] = display_mode[1] = GRhhd;
       parm.u = me->parm_sel;
       parm.v = 0.0;
 
       sts = om$send( mode = OM_e_wrt_object,
                      msg  = message GRgraphics.GRlocaldp(
                                       &msg,
                                       &me->module_info_b.md_env.matrix_type, 
                                       me->module_info_b.md_env.matrix, 
                                       &parm,
                                       display_mode,
                                       &me->module_info_b.md_id,
                                       &display_location,
                                       &display_flag),
                      targetid = me->bound_ele.objid,
                      targetos = me->bound_ele.osnum); 
       if (!(1&(sts&msg)))  Goto (wrapup); 
       }
       else
       {
         sts = dp$display(msg = &msg,
                          mode = GRhhd,
                          oids = &me->bound_ele);
         if (!(1&(sts&msg)))  Goto (wrapup);
       }
       /*  force state for identify element  */
       me->save_state = IDENTIFY_ELEMENT;
     }

     /*  set assoc marker  */
     if ( EMshould_be_associative() )
     {
       gr$get_associative_flag( buffer = &associative_flag );
       if ( associative_flag )  GRdisplay_associative_button(TRUE);
     }

wrapup:
   return(OM_S_SUCCESS);
}





method delete (int pos)
{
   IGRint    sts;
   IGRlong   rc;

   /*  return spaces if not done before  */
   if (space_b1)  {  om$dealloc(ptr = space_b1);   space_b1  = NULL;  }
   if (space_b2)  {  om$dealloc(ptr = space_b2);   space_b2  = NULL;  }
   if (space_b3)  {  BSfreecv(&rc, space_b3);      space_b3  = NULL;  }
   if (space_e1)  {  om$dealloc(ptr = space_e1);   space_e1  = NULL;  }
   if (space_e2)  {  om$dealloc(ptr = space_e2);   space_e2  = NULL;  }
   if (space_e3)  {  BSfreecv(&rc, space_e3);      space_e3  = NULL;  }
   if (curve_new) {  om$dealloc(ptr = curve_new);  curve_new = NULL;  }

      sts = om$send(mode     = OM_e_wrt_message,   
                    msg      = message Root.delete(1),
                    targetid = my_id);

   return(OM_S_SUCCESS);
}



end implementation ECtrim1;
