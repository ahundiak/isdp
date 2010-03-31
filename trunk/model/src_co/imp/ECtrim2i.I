 
 
/*
  HISTORY :

    07/xx/93 - Horst Bernhardt
    06/21/95 - don't change PIX size ( by order of TR )
    07/01/95 - change selection classes / change undo procedure
    08/02/95 - add special handling for sketch class
    08/28/97 - change text for UNDO
    09/01/97 - avoid selection of elements with dimension constraint 

  DISCLAIMER :
              
     Allows to trim 2 curves with one pick defining the 2 elements and
     the intersection quadrant of the remaining parts.
      
*/

class implementation ECtrim2;


#include   "VCdef.h"               /*  test  */              


#include   "ECcmd.h"                 /*  command text  */
#include   "ECmsg.h"                 /*  message text  */


#include   "bsparameters.h"
#include   "bsconic.h"
#include   "bserr.h"

#include   "igrtypedef.h"
#include   "OMminimum.h"
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
#include   "EMSaction.h"
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
#include   "codebug.h"
#include   "gocmacros.h"      /*  GRgetabsg  */
#include   "grgsmacros.h"     /* gr$gsdisplay */
#include   "emserr.h"
#include   "EMSmsgdef.h"
#include   "comndef.h"

#include   "ectrm_alc.h"      /*  prototype  */

#include   "ectrm_sk.h"       /*  function prototype  */
#include   "ectrm_prf.h"      /*  function prototype  */
#include   "ectrm_del.h"      /*  function prototype  */




/* Command states */
#define NUMBER_OF_STATES          3

#define IDENTIFY_ELEMENTS         1
#define IDENTIFY_2ND_ELEMENT      2 	
#define EXTEND_ELEMENTS           3

/* Selection tolerance */
#define MAXSEL           12     /*  14 is max value for locate ICON           */
#define MINSEL            5     /*  normal used minimum value for locate ICON */
                                /*  but larger values are used for selection  */

#define CV_START_PARAM  0.0     /*  curve start parameter  */ 
#define CV_END_PARAM    1.0     /*  curve end parameter    */
#define WRAP            CV_END_PARAM-CV_START_PARAM


#define NR_PRE_INT 2  
#define NR_PRE_OVL 2  

#define REAL_DEL    1                   /*  real delete ( + members )  */
#define DEL_R_TREE  0                   /*  remove from r_tree  */
#define ADD_R_TREE -1                   /*  add to r_tree  */

/* imported messages */

from GRcurve    import GRptextend;
from GRgraphics import GRcpforundo;
from GRgraphics import GRaddwrng;
from GRgraphics import GRdisplay;
from GRgraphics import GRptproject;
from IGEgragad  import DPinrot;


#define VCdebug_return    1            /*  test  */


/* text for prompts and other messages */

/*                         "Trim 2 elements to intersection"  */
#define MESSAGE_TEXT       EM_M_Tr2ElIn

/*                         "Identify the 2 elements at rem. intersect quadrant"  */
#define LOCATE_PROMPT_A    EMS_P_Id2CuAtReInQu

/*                         "Identify the 2 elements at rem. intersect quadrant/Moveon for undo"  */
#define LOCATE_PROMPT_A_U  EMS_P_Id2CuAtReInQu__MU

/*                         Identify 2 curves at rem. intersect quadrant/Back up to undo  */
#define LOCATE_PROMPT_A_U  EMS_P_Id2CuAtReInQu__Bk

/*                         "Identify 2nd element at remaining part"  */
#define LOCATE_PROMPT_2    EMS_P_Id2CuAtRePa
 
/*                         "No curves(s) found"  */
#define RELOCATE_PROMPT     EMS_I_NoCuFo
 
/*                         "Accept/Reject"  */
#define ACCEPT_PROMPT      GR_P_Acc

/*                            "No trim/extend possible!"  */
#define ERROR_MESSAGE_NOINT   EMS_I_NoTEPo

/*                            "Same curve as 1st curve!"  */
#define ERROR_MESSAGE_DOUBLE  EMS_I_SaCuAs1Cu

/*                            Element with dimension constraint cannot be trimmed */
#define ERROR_MESSAGE_DIM     EMS_S_ElWiDiCoCABeTr



extern IGRboolean  EFisAncestryValid();

extern GRclassid OPP_GRpoint_class_id;
extern GRclassid OPP_GRcurve_class_id;
extern GRclassid OPP_EMSsurface_class_id;
extern GRclassid OPP_SKmgr_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;
extern GRclassid OPP_GR3dcirarc_class_id;
extern GRclassid OPP_GR3dellarc_class_id;
extern GRclassid OPP_EMSagrp_class_id;
extern GRclassid OPP_GR3dtext_class_id;
extern GRclassid OPP_DMtxldr_class_id;
extern GRclassid OPP_DMdim_class_id;
extern GRclassid OPP_EMSdatpln_class_id;
extern GRclassid OPP_GRbcsubbc_class_id;
extern GRclassid OPP_SKbspline_class_id;
extern GRclassid OPP_SKline_class_id;
extern GRclassid OPP_SKarc_class_id;
extern GRclassid OPP_GRcompcurve_class_id;
extern GRclassid OPP_SKdumpt_class_id;
extern GRclassid OPP_SKpoint_class_id;

extern IGRboolean EMshould_be_associative();
 

/***********************************************/
/*  execute method for ECtrim2 command object  */
/***********************************************/


method init(int type;char *str_ptr)
{
   IGRint  sts;
   IGRint  kk;
   IGRlong msg;


   sts = OM_S_SUCCESS;
   msg = MSSUCC;


   me->saved1_objid           = me->saved2_objid =
   me->last_extend_ele1.objid = me->last_extend_ele2.objid = NULL_OBJID;
   /*  preset from/to points  */
   for (kk=0; kk<3; kk++)
   {
     me->last_extend_1_to[kk] = 0.0;;
     me->last_extend_1_from[kk] = 0.0;
   }
   /* save original selection tolerance  */
   gr$get_dit_tolerance(buffer = &me->loc_tol_old);
   if (me->loc_tol_old >= MAXSEL)  me->loc_tol_old = MINSEL;

   /* set initial state for execute method */
   ME.super_cmd->state = IDENTIFY_ELEMENTS;
   return(OM_S_SUCCESS);
}




method execute(int *response; char *response_data; int pos)
{


   IGRchar     *ptr;                     /*  abstract geometry pointer  */

   IGRboolean  extend_t1_extend, extend_t2_extend,
               apparent_flag;

   IGRint      ii, i, k;
   IGRint      cur_max_loop;
   IGRint      display_flag;  
   IGRint      event_mask, locate_mask, accept_mask;
   IGRlong     msg, sts, msg_unused, rc;
   IGRlong     size, size_t1, size_t2, ret_size;

   IGRdouble   tw;

   /*...IGRdouble  tol;   not used yet  */

   IGRdouble   eps;                       /*  basic tolerance  */ 

   OMuword     r_classes[1],
               n_classes[8]; 
          

   OM_S_CLASSLIST  rtree_classes,
                   n_eligible_classes;

   struct GRlc_locate    attributes;

   struct GRid  cur_grid,  trim_ele_w;
   struct GRid  trim_ele_1,   trim_ele_2,
                trim_sel_1,   trim_sel_2,
                new_ele_1,    new_ele_2,
                main_obj1,    main_obj2,
                saved_grid_1, saved_grid_2;

   GRobjid      acc_1_obj, acc_2_obj, acc_w_obj,
                but_1_obj, but_2_obj, but_w_obj,
                savedw_objid;

   GRspacenum   acc_1_os, acc_2_os, acc_w_os,
                but_1_os, but_2_os, but_w_os;

   struct GRmd_env  *p_module_info_1, *p_module_info_2,
                    *p_module_info_s, *p_module_info_w,
                    module_info_1, module_info_2, module_info_w,
                    module_info_u, module_info_s,
                    module_info_u1, module_info_u2,      
                    module_info_s1, module_info_s2;
    
   IGRpoint     appr_intersect, appr_intersect1, appr_intersect2; 

   IGRpoint     intersect_point, intersect_point_1, intersect_point_2,
                Endpoint, Strpoint, pntxxx;

   IGRvector     view_vector;

   IGRmatrix     rot_matrix;

   OMuword       trim_ele_1_classid, trim_ele_2_classid; 


   /* intersection region values  */
   IGRint     n_int, n_ovl,
              best1;

   IGRboolean out_int_alloc, out_ovl_alloc,
              intersect_found,
              undo_possible;

   IGRdouble  ipar1[NR_PRE_INT], ipar2[NR_PRE_INT];
   IGRdouble  opar1[NR_PRE_OVL], opar2[NR_PRE_OVL];
   IGRpoint   int_pts[NR_PRE_INT];
   IGRpoint   ovl_pts[NR_PRE_INT];

   IGRdouble  *xipar1, *xipar2;
   IGRdouble  *xopar1, *xopar2;
   IGRpoint   *xint_pts, *xovl_pts;

   IGRpoint   point1;

   IGRdouble parm_t1, parm_t2;

   IGRdouble dist_best_sq, dist_sq;




   struct GRparms        geom_parms_t1,    geom_parms_t2,
                         geom_parms_w;
   struct GRparms        parm_int;

   struct GRprops       props_t1,          /*  geom properties  */
                        props_t2;          /*  geom properties  */



   struct IGRbsp_curve
                                        /*          om$malloc:            */
               *curve_t1_work,            /*  work t1                       */
               *curve_t2_work,            /*  work t2                       */
               *curve_t1,                 /*  work t1                       */
               *curve_t2,                 /*  work t2                       */
               *space_tr1,                /*  t1 ptr for return (work)      */
               *space_tr2,                /*  t2 ptr for return (work)      */

                                          /*          BSalloccv:            */
               *space_tx1,                /*  t1 ptr for return (work)      */
               *space_tx2,                /*  t2 ptr for return (work)      */
  
               *curve_cur;                /*  current t1/2 ptr              */



   IGRint      member_cnt_1, member_cnt_2;
   IGRboolean  closed_cv1, closed_cv2;
   IGRint      control;
   IGRint      task;


   /* --- start of executable code --- */

   /*  make compiler happy  */
   best1 = NULL;
   p_module_info_w = NULL;

   sts = OM_S_SUCCESS;
   msg = MSSUCC;

   p_module_info_1 = &module_info_1;
   p_module_info_2 = &module_info_2;       
   /*  formal preset only  */
   but_1_obj = but_2_obj = acc_1_obj = acc_2_obj = NULL_OBJID;
   but_1_os  = but_2_os  = acc_1_os  = acc_2_os  = NULL;

   geom_parms_t1 = me->locate_event.located_object[0].geom_parms;
   geom_parms_t2 = me->locate_event.located_object[0].geom_parms;
   /* set up filter event masks */
   event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_DATA;
   locate_mask = GRm_DATA | GRm_BACK_UP | GRm_TEXT_VALUE;
   accept_mask = GRm_DATA | GRm_BACK_UP | GRm_TEXT_VALUE;

   /* locate display flag set  */
   display_flag =
        ELEM_HILIGHT            |       /* Hilite the whole element */
        ACC_REJ_CYCLE           |
        LC_ACCEPT_CURSOR        |
        LC_ACC_ONE_ELEMENT      |       /* dont accept if one element in tol */
        LC_ONE_ELEM_ACCEPT      |       /* dont need accept */
        LC_ACC_TWO_ELEMENT      |       /* Id. two elements at once */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_ALL            |     
        LC_ERASE_LOC_ELEMENT;           /* Erase the hilite plane */

   /*   locate attributes  */
   attributes.owner_action =    LC_RIGID_COMP 
                              | LC_FLEX_COMP
                              | LC_REF_OBJECTS
                              | LC_NO_RIGID_OWNER_WORKS 
                              | LC_NO_FLEX_OWNER_WORKS
                              | LC_HANDLES 
                                ;


   attributes.properties =     LC_WRITE_ONLY 
                             | LC_LC_ONLY 
                             | LC_DP_ONLY ;
 


   /*  Rtree set  */
   rtree_classes.w_flags   = OM_CLST_subclass;
   rtree_classes.p_classes = r_classes;
                             r_classes[0] = OPP_GRcurve_class_id;
   rtree_classes.w_count = 1;

   n_eligible_classes.w_flags   = OM_CLST_subclass | OM_CLST_negation;
   n_eligible_classes.p_classes =  n_classes;
                                   n_classes[0] = OPP_GRpoint_class_id;
                                   n_classes[1] = OPP_EMSsurface_class_id;
                                   n_classes[2] = OPP_EMSdatpln_class_id;
                                   n_classes[3] = OPP_GR3dtext_class_id;
                                   n_classes[4] = OPP_DMtxldr_class_id;
                                   n_classes[5] = OPP_DMdim_class_id;
                                   n_classes[6] = OPP_SKdumpt_class_id;
                                   n_classes[7] = OPP_SKpoint_class_id;
   n_eligible_classes.w_count = 8;


 
  /*
   * Loop through the command states until an input is received by a filter 
   * that cannot be handled.  On exit from this loop, the execute method 
   * exits, returning control to the Command Server.
   */

   do
   {
     switch (ME.super_cmd->state)

     {

       case IDENTIFY_ELEMENTS:

       {
         /*  set to maximum selection tolerance         */
         /*--- tol = MAXSEL;                         ---*/
         /*--- gr$put_dit_tolerance(buffer = &tol);  ---*/

         undo_possible =  me->last_extend_ele1.objid != NULL_OBJID 
                       || me->last_extend_ele2.objid != NULL_OBJID;


         /*  locate both elements to be trimmed with one pick  */
         sts = lc$locate(
                  rc               = &msg,
                  event1           = &me->locate_event,
                  event2           = &me->accept_event,
                  mask1            = locate_mask,
                  mask2            = accept_mask,
                  display_flag     = display_flag,
                  locate_key       = undo_possible ? LOCATE_PROMPT_A_U :
                                                     LOCATE_PROMPT_A,
                  acc_key          = ACCEPT_PROMPT,
                  attributes       = &attributes,
                  relocate_key     = RELOCATE_PROMPT,
                  stack            = &me->locate_stack,
                  stack_size       = 2,
                  rtree_classes    = &rtree_classes,
                  eligible_classes = &n_eligible_classes);

         if (!(1&sts))
         { 
           /* let command server handle it */
           return (OM_S_SUCCESS);
         }

         if (!(1&msg))
         {
           if (me->locate_event.response == EX_BACK_UP)
           {
             /* backup to previous command state */
             /*  double click right mouse button  */

             /*-------------------*/
             /*      U N D O      */  
             /*-------------------*/

             if (undo_possible )
             {
               /* ------------------------------- */
               /*  loop to restore both elements  */
               /* ------------------------------- */
               for (ii=0; ii<2; ii++) 
               {
                 if (ii == 0)
                 {
                   trim_ele_w   = me->last_extend_ele1;
                   savedw_objid = me->saved1_objid;
                   module_info_u = module_info_u1;
                   module_info_s = module_info_s1;

                   /*  restore from/to points  */
                   for (k=0; k<3; k++)
                   {
                      intersect_point[k] = me->last_extend_1_to[k];
                      Endpoint[k]        = me->last_extend_1_from[k];
                   }
                 }
                 else
                 {
                   trim_ele_w   = me->last_extend_ele2;
                   savedw_objid = me->saved2_objid;
                   module_info_u = module_info_u2;
                   module_info_s = module_info_s2;

                   /*  restore from/to points  */
                   for (k=0; k<3; k++)
                   {
                      intersect_point[k] = me->last_extend_2_to[k];
                      Endpoint[k]        = me->last_extend_2_from[k];
                   }
                 }

                 if (savedw_objid != NULL_OBJID)
                 {
                   p_module_info_w = &module_info_1; 
                   cur_grid.objid = savedw_objid;
                   cur_grid.osnum = trim_ele_w.osnum;

                   if (trim_ele_w.objid != NULL_OBJID
                    && trim_ele_w.objid != NULL)
                   {
                     /*  erase elements with old extension  */
                     dp$display(msg  = &msg,
                                mode = GRbehe,
                                oids = &trim_ele_w);

                     /*  delete last made comp_crv  */
                     sts = ECtrm_del(REAL_DEL, trim_ele_w, &module_info_1);

                     /*  add saved comp curve to r-tree  */ 
                     sts = ECtrm_del(ADD_R_TREE, cur_grid, &module_info_1);
                   }

                   else

                   { 
                     cur_grid.objid = savedw_objid;
                     cur_grid.osnum = trim_ele_w.osnum;

                     /*  dont handle closed objects  */
                     sts = ECtrm_SK(cur_grid, &trim_ele_1, &member_cnt_1, &closed_cv1, &main_obj1);
                     if (!closed_cv1)
                     {
                       /*  erase old extend  */
                       dp$display(msg  = &msg,
                                  mode = GRbe,
                                  oids = &cur_grid);
                       if (!(1&msg))   Goto (wrapup);

                       /*  send to the object to get it to extend itself  */
                       om$send(mode = OM_e_wrt_object,
                               msg  = message GRcurve.GRptextend(
                                         &msg,
                                         &module_info_1,
                                         Endpoint,         /* pnt to extend    */
                                         intersect_point,  /* pnt to extend to */
                                         Endpoint ),       /* new end pnt      */
                               targetid = cur_grid.objid,
                               targetos = cur_grid.osnum);
                       if (!(1&msg))   Goto (wrapup);
                     }     /*  if (!closed_cv1...  */  
                   }
  
                   dp$display(msg  = &msg,
                              mode = GRbd,
                              oids = &cur_grid);
                   if (!(1&msg))   Goto (wrapup);

                 }
                  /* ----------------------------------- */
               }  /*  loop end of restore both elements  */
                  /* ----------------------------------- */

               me->saved1_objid           = 
               me->saved2_objid           =
               me->last_extend_ele1.objid =
               me->last_extend_ele2.objid = NULL_OBJID;
               break;

             }   
           }
           else
           {
             me->last_extend_ele1.objid =
             me->last_extend_ele2.objid = NULL_OBJID;
             /* let command server handle it */
             return(OM_S_SUCCESS);
           }
         }

         else
         {
           if (me->locate_event.response == EX_BACK_UP)  
           {
             /* backup to previous command state */
             ME.super_cmd->state = IDENTIFY_ELEMENTS;
           }
           else
           {
             {
               if (me->accept_event.num_id >= 1)
               {
                 trim_sel_1 =
                 trim_ele_1 = me->accept_event.located_object[0].located_obj;
                 for (i=0; i<3; i++)
                   appr_intersect1[i] = me->accept_event.located_object[0].proj_pnt[i];        

                 /*  check for Smart Sketch obj and replace it by basic geo object */
                 sts = ECtrm_SK(trim_ele_1, &trim_ele_1, &member_cnt_1, &closed_cv1, &main_obj1);
                 if (trim_ele_1.objid == NULL_OBJID)
                 {
                   /*  try 2nd selected  */
                   trim_ele_1 = me->accept_event.located_object[1].located_obj;
                   /*  check for Smart Sketch obj and replace it by basic geo object */
                   sts = ECtrm_SK(trim_ele_1, &trim_ele_1, &member_cnt_1, &closed_cv1, &main_obj1);
                   if (trim_ele_1.objid == NULL_OBJID)
                   {
                     /*  erase highlight at all  */
                     dp$erase_hilite(msg = &msg);
                     break;
                   }
                   me->accept_event.num_id = 1;   /*  set only 1 selected  */
                   /*  save bound module info  */
                   module_info_1 = me->accept_event.located_object[1].module_info;
                   geom_parms_t1 = me->locate_event.located_object[1].geom_parms; 
                   but_1_obj = me->accept_event.event.button.objid;
                   but_1_os  = me->accept_event.event.button.osnum;
                   for (i=0; i<3; i++)
                     appr_intersect1[i] = me->accept_event.located_object[1].proj_pnt[i];
                 }
                 else
                 {
                   /*  save bound module info  */
                   module_info_1 = me->accept_event.located_object[0].module_info;
                   geom_parms_t1 = me->locate_event.located_object[0].geom_parms; 
                   but_1_obj = me->accept_event.event.button.objid;
                   but_1_os  = me->accept_event.event.button.osnum;
                   if (me->accept_event.num_id == 2)
                   {
                     for (i=0; i<3; i++)
                       appr_intersect2[i] = me->accept_event.located_object[1].proj_pnt[i];
                   }
                 }
                 acc_1_obj = trim_ele_1.objid, 
                 acc_1_os  = trim_ele_1.osnum;

                 /*  check if extend element1 1 has dimemsion constraint  */
                 if (ECtrm_isdim (trim_ele_1) )    
                 {
                   sts = ex$message(msgnumb = ERROR_MESSAGE_DIM,
                                    field   = ERROR_FIELD);

                   ME.super_cmd->state = IDENTIFY_ELEMENTS; 
                   break;
                 }
                 /*  mark boundary-1 in highligh mode  */
                 dp$display(msg  = &msg,     
                            mode = GRhd,
                            oids = &trim_ele_1);
                 if (!(1&msg))   Goto (wrapup);

                 ME.super_cmd->state = IDENTIFY_2ND_ELEMENT;

               }

               if (me->accept_event.num_id == 2)
               {
                 trim_sel_2 =   
                 trim_ele_2 = me->accept_event.located_object[1].located_obj;
                 /*  check for Smart Sketch obj and replace it by basic geo object */
                 sts = ECtrm_SK(trim_ele_2, &trim_ele_2, &member_cnt_2, &closed_cv2, &main_obj2);

                 /*  check if extend element 2 has dimension constraint  */
                 if (ECtrm_isdim (trim_ele_2) )
                 {
                   sts = ex$message(msgnumb = ERROR_MESSAGE_DIM,
                                    field   = ERROR_FIELD);

                   ME.super_cmd->state = IDENTIFY_2ND_ELEMENT; 
                   break;
                 }

                 /*  mark boundary-2  in highligh mode  */
                 dp$display(msg  = &msg,
                            mode = GRhd,
                            oids = &trim_ele_2);
                 if (!(1&msg))   Goto (wrapup);

                 /*  save bound module info  */
                 module_info_2 = me->accept_event.located_object[1].module_info;
                 geom_parms_t2 = me->locate_event.located_object[1].geom_parms;  
                 acc_2_obj = trim_ele_2.objid, 
                 acc_2_os  = trim_ele_2.osnum;
                 but_2_obj = me->accept_event.event.button.objid;
                 but_2_os  = me->accept_event.event.button.osnum;
                 ME.super_cmd->state = EXTEND_ELEMENTS; 

               }
             }
           }
         }
         break;
       }


       case IDENTIFY_2ND_ELEMENT:
       {
         /*  use normal tolerance for single pick operations  */
         /*--- gr$put_dit_tolerance(buffer = &me->loc_tol_old); ---*/
         /*  locate 2nd element  */

         sts = lc$locate(
                  rc               = &msg,
                  event1           = &me->locate_event,
                  event2           = &me->accept_event,
                  mask1            = locate_mask,
                  mask2            = locate_mask,
                  display_flag     = display_flag,
                  locate_key       = LOCATE_PROMPT_2,
                  acc_key          = ACCEPT_PROMPT,
                  attributes       = &attributes,
                  relocate_key     = RELOCATE_PROMPT,
                  stack            = &me->locate_stack,
                  stack_size       = 1,  
                  rtree_classes    = &rtree_classes,        
                  eligible_classes = &n_eligible_classes);
    
         if (!(1&sts))
         {
           /*  let command server handle it  */
           return (OM_S_SUCCESS);
           /*  ME.super_cmd->state = IDENTIFY_ELEMENTS;  */
         }

         if (!(1&msg))
         {
           if (me->locate_event.response != EX_BACK_UP)
           {
             /*  right mouse botton pushed  */
             /*  reject last selection  */
             /*  clear highlihgting on selected element 1  */
             dp$display(msg  = &msg,  
                        mode = GRhe,
                        oids = &trim_ele_1); 
             if (!(1&msg))   Goto (wrapup);
 
             /*  reset to old selection tolerance  */
             /*--- gr$put_dit_tolerance(buffer = &tol); ---*/
             ME.super_cmd->state = IDENTIFY_ELEMENTS;
             break;
           }

         }
         else
         {    

           trim_sel_2 =  
           trim_ele_2 = me->accept_event.located_object[0].located_obj;
           /*  check for Smart Sketch obj and replace it by basic geo object */
           sts = ECtrm_SK(trim_ele_2, &trim_ele_2, &member_cnt_2, &closed_cv2, &main_obj2);
           if (trim_ele_2.objid == NULL_OBJID)  goto termi;
 
           /*  check if extend element 2 has dimemsion constraint  */
           if (ECtrm_isdim (trim_ele_2) )    
           {
             sts = ex$message(msgnumb = ERROR_MESSAGE_DIM,
                              field   = ERROR_FIELD);

             ME.super_cmd->state = IDENTIFY_2ND_ELEMENT;
             break;
           }

           module_info_2 = me->locate_event.located_object[0].module_info;
           p_module_info_2 = &module_info_2; 
           acc_2_obj = trim_ele_2.objid; 
           acc_2_os  = trim_ele_2.osnum;
           but_2_obj = me->accept_event.event.button.objid;
           but_2_os  = me->accept_event.event.button.osnum;

          /*  avoid bound elelement the same as extend element  */
          /*  what is with trim a curve with itself ????        */
          if (trim_ele_1.objid == trim_ele_2.objid  &&
              trim_ele_1.osnum == trim_ele_2.osnum )
          {
            sts = ex$message(msgnumb = ERROR_MESSAGE_DOUBLE,
                             field   = ERROR_FIELD);
            break;
          }
          /*  mark element by highligh mode  */
          dp$display(msg  = &msg,
                     mode = GRhd,
                     oids = &trim_ele_2);
          if (!(1&msg))   Goto (wrapup);

          /*  if two pick mode use 2nd pick as only intersection master */
          for (i=0; i<3;i++)
          {
            /*...appr_intersect1[i] = me->accept_event.located_object[0].proj_pnt[i];...not so good...*/
            appr_intersect2[i] = me->accept_event.located_object[0].proj_pnt[i];
          }
          geom_parms_t2  = me->accept_event.located_object[0].geom_parms; 

          ME.super_cmd->state = EXTEND_ELEMENTS;   
          break;
        }
      }           


       case EXTEND_ELEMENTS:

       {
         control = 0;
         curve_t1      = curve_t2      = 
         space_tr1     = space_tr2     = 
         space_tx1     = space_tx2     = 
         curve_t1_work = curve_t2_work = NULL;

         /*  use middle of located positions  */
         for (i=0; i<3; i++)
           appr_intersect[i] = 0.5 * (appr_intersect1[i] + appr_intersect2[i]);

         /*  special handling for composite curve  */
         if (closed_cv1  &&  closed_cv2)    goto nix;  /*  both closed not allowed  */

         if (member_cnt_1 >= 1  ||  member_cnt_2 >= 1)
         {
            task = 3;                     /*  handle both  */  
            if (member_cnt_1 >= 1  &&  member_cnt_2 <= 1)
            {
              sts = ECtrm_prf(task,
                              &geom_parms_t2,
                              &me->locate_event.located_object[0].module_info,
                              &trim_ele_2,
                              closed_cv2,
                              &trim_ele_1,
                              closed_cv1,
                              appr_intersect,
                              &control,
                              &new_ele_2,
                              &new_ele_1,
                              intersect_point,
                              Endpoint,
                              &saved_grid_2,
                              &saved_grid_1);




              if (1&control)
              {  
                me->last_extend_ele2 = new_ele_2;
                me->saved2_objid     = trim_ele_2.objid;
                if (new_ele_2.objid == NULL_OBJID)
                {
                  for (k=0; k<3; k++)
                  {
                    me->last_extend_2_from[k] = intersect_point[k];
                    me->last_extend_2_to[k]   = Endpoint[k];
                  }
                }
              }

              if (2&control)
              {
                me->last_extend_ele1 = new_ele_1;
                me->saved1_objid     = saved_grid_1.objid;
              }
            }    /*   if (member_cnt_1 >= 1  &&  member_cnt_2...*/

            else

            {
              if (member_cnt_2 >= 1  &&  member_cnt_1 <= 1)
              {
                sts = ECtrm_prf(task,
                                &geom_parms_t1,
                                &me->locate_event.located_object[0].module_info,
                                &trim_ele_1,
                                closed_cv1,
                                &trim_ele_2,
                                closed_cv2,
                                appr_intersect,
                                &control,
                                &new_ele_1,
                                &new_ele_2,
                                intersect_point,
                                Endpoint,
                                &saved_grid_1,
                                &saved_grid_2);

                if (1&control)
                {  
                  me->last_extend_ele1 = new_ele_1;
                  me->saved1_objid     = trim_ele_1.objid;
                  if (new_ele_1.objid == NULL_OBJID)
                  {
                    for (k=0; k<3; k++)
                    {
                      me->last_extend_1_from[k] = intersect_point[k];
                      me->last_extend_1_to[k]   = Endpoint[k];
                    }
                  }
                }

                if (2&control)
                {
                  me->last_extend_ele2 = new_ele_2;
                  me->saved2_objid     = trim_ele_2.objid;
                }
              }    /*  if (member_cnt_2 > 1  || ( member_cnt_1...  */
            }

            if (control <= 0)  goto nix;
            else               goto termi;
           
         }

         /*  get trim element 1 class_id  */
         om$get_classid(objid     = trim_ele_1.objid,
                        osnum     = trim_ele_1.osnum,
                        p_classid = &trim_ele_1_classid);

         /*  get trim element 2 class_id  */
         om$get_classid(objid     = trim_ele_2.objid,
                        osnum     = trim_ele_2.osnum,
                        p_classid = &trim_ele_2_classid);



         if ( trim_ele_1_classid == OPP_GR3dlineseg_class_id 
          ||  trim_ele_1_classid == OPP_GR3dcirarc_class_id  
          ||  trim_ele_1_classid == OPP_GR3dellarc_class_id
          ||  trim_ele_1_classid == OPP_SKline_class_id
          ||  trim_ele_1_classid == OPP_SKarc_class_id)
                                                  extend_t1_extend = TRUE;
         else                                     extend_t1_extend = FALSE;

         /*  check for extendable curves  */
         if ( trim_ele_2_classid == OPP_GR3dlineseg_class_id 
          ||  trim_ele_2_classid == OPP_GR3dcirarc_class_id  
          ||  trim_ele_2_classid == OPP_GR3dellarc_class_id
          ||  trim_ele_2_classid == OPP_SKline_class_id
          ||  trim_ele_2_classid == OPP_SKarc_class_id)
                                                  extend_t2_extend = TRUE;
         else                                     extend_t2_extend = FALSE;

         /*  get basis tolerance value  eps  */
         sts = BSEXTRACTPAR(&msg, BSTOLBASIS, eps);
         if (msg)  Goto (wrapup);


         /*----------------------*/
         /*  prepare curve data  */
         /*----------------------*/

         /*  prepare element 1  data  (original and extendable)  */ 
         sts = ECtrm_alc(&msg, 1, trim_ele_1, &module_info_1.md_env,
                         &curve_t1, &props_t1, &size_t1);
         if (!(1&(sts&msg)))  Goto (wrapup);

         sts = ECtrm_alc(&msg, 0, trim_ele_1, &module_info_1.md_env,
                         &space_tr1, &props_t1, &size_t1);
         if (!(1&(sts&msg)))  Goto (wrapup);
         curve_t1_work = space_tr1;


         /*  prepare element 2  data  (original and extendable)  */  
         sts = ECtrm_alc(&msg, 1, trim_ele_2, &module_info_2.md_env,
                         &curve_t2, &props_t2, &size_t2);
         if (!(1&(sts&msg)))  Goto (wrapup);
 
         sts = ECtrm_alc(&msg, 0, trim_ele_2, &module_info_2.md_env,
                           &space_tr2, &props_t2, &size_t2);
         if (!(1&(sts&msg)))  Goto (wrapup);  
         curve_t2_work = space_tr2; 


         /*  get apparent flag value  */
         size = sizeof(apparent_flag);
         gr$get_apparent_flag(msg   = &msg,
                             sizbuf = &size,
                             buffer = &apparent_flag,
                             nret   = &ret_size);
         if (!(1&msg))   Goto (wrapup);


         if (apparent_flag) 
         { 
           /*-----------------------------------*/
           /*  calculate apparent intersection  */
           /*-----------------------------------*/

           /*  load view vector  */
           om$send(msg = message IGEgragad.DPinrot(&msg, rot_matrix),
                   senderid = NULL_OBJID,
                   targetid = but_2_obj,
                   targetos = but_2_os);
           if (!(1&msg))   Goto (wrapup);

           /*  get unit vector  */
           for (i=0; i<3; i++)
             view_vector[i] = rot_matrix[8+i];

           /*  calculate apparent intersect point in the first element  */
           sts = GR2objaisect(&msg, 
                              &trim_ele_1,        /* trim element 1         */
                              p_module_info_1,    /* trim ele 1 module inf  */
                              &geom_parms_t1,     /* trim ele 1 parameters  */
                              &trim_ele_2,        /* trim element 2         */
                              p_module_info_2,    /* trim ele 2 module inf  */
                              &geom_parms_t2,     /* trim ele 2 parameters  */
                              appr_intersect,     /* approximate int pt     */
                              view_vector,        /* unit view vector       */
                              intersect_point_1); /* actual intersect       */
           if (!(1&msg))   Goto (wrapup);

           if (msg == MSSUCC)
           {
             sts = GR2objaisect(&msg,
                                &trim_ele_2,        /* trim element 2         */
                                p_module_info_2,    /* trim ele 2 module inf  */
                                &geom_parms_t2,     /* trim ele 2 parameters  */
                                &trim_ele_1,        /* trim element 1         */
                                p_module_info_1,    /* trim ele 1 module inf  */
                                &geom_parms_t1,     /* trim ele 1 parameters  */
                                appr_intersect,     /* approximate int pt     */
                                view_vector,        /* unit view vector       */
                                intersect_point_2); /* actual intersect       */
             if (!(1&msg))   Goto (wrapup);
           }
         }
         else
         {          
 
           /*---------------------------------------------*/
           /* possible true multiple intersection points  */
           /*---------------------------------------------*/


           /*  both curves closed are not allowed  */
           if (closed_cv1  &&  closed_cv2)   goto nix;
           if (curve_t1->phy_closed && curve_t2->phy_closed)  goto nix;

           /*  prepare lines for intersection  */
           sts = GR2bcisectutil(&msg,                         
                                &space_tr1,       /* ext array-1         */
                                &space_tr2,       /* ext array-2         */
                                &geom_parms_t1,   /* param-1             */
                                &geom_parms_t2,   /* param-2             */
                                &props_t1,        /* properties-1        */
                                &props_t2,        /* properties-2        */
                                space_tr1,        /* b-spline-1 expanded */
                                space_tr2);       /* b-spline-2 expanded */
           if (!(1&msg))   Goto (wrapup);

           if (extend_t1_extend)  curve_t1_work = space_tr1;     

           if (trim_ele_1_classid == OPP_GR3dcirarc_class_id 
            || trim_ele_1_classid == OPP_GR3dellarc_class_id
            || trim_ele_1_classid == OPP_SKarc_class_id)
           {

             /*   allocate arc_space 7poles/ 7weights/ 10 knots  */
             if (space_tx1)  { BSfreecv(&rc, space_tx1); space_tx1 = NULL; }
             BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 1, 0,
                       &space_tx1, &rc);
             if (rc)  Goto (wrapup);
             curve_t1_work = space_tx1;

             BSfullarc(&rc, curve_t1, curve_t1_work); 
             if (rc)  Goto (wrapup); 

           }


           if (extend_t2_extend)  curve_t2_work = space_tr2;

           if (trim_ele_2_classid == OPP_GR3dcirarc_class_id 
            || trim_ele_2_classid == OPP_GR3dellarc_class_id  
            || trim_ele_2_classid == OPP_SKarc_class_id)    
           { 
             if (space_tx2)  { BSfreecv(&rc, space_tx2); space_tx2 = NULL; }
             /*   allocate arc_space 7poles/ 7weights/ 10 knots  */
             BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 1, 0,
                       &space_tx2, &rc);
             if (rc)  Goto (wrapup);
             curve_t2_work = space_tx2;

             BSfullarc(&rc, curve_t2, curve_t2_work); 
             if (rc)  Goto (wrapup);  
           }

           xint_pts = xovl_pts = NULL;

           /*  intersect curves  */
           BScvcvint(
               curve_t1_work,    /* first element to intersect */
               curve_t2_work,    /* second element to intersect */
               TRUE,             /* remove duplicate intersect points */
               NR_PRE_INT,       /* number of preallocated intersect points */
               NR_PRE_OVL,       /* number of preallocated overlap points */
               int_pts,          /* preallocated intersection points */
               ipar1,            /* preallocated intersect par curve1 */
               ipar2,            /* preallocated intersect par curve2 */
               ovl_pts,          /* preallocated overlap points */
               opar1,            /* preallocated overlap par curve1 */
               opar2,            /* preallocated overlap par curve2 */
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
               &rc);             /* error return code */
           if (rc)  Goto (wrapup);

           intersect_found = (n_int > 0  ||  n_ovl > 0); 
           if (!intersect_found)   goto nix;

           best1 = NULL;      
           /*  find the nearest point in intersect array */
           dist_best_sq = GRDGNLIMITS_MAX_D * GRDGNLIMITS_MAX_D;

           for (i=0; i<n_int; i++)
           {
             /*  calculate squared distance to accept_point  */
             if (out_int_alloc)  sts = MA2pt2dis(&msg, xint_pts[i], appr_intersect, &dist_sq);
             else                sts = MA2pt2dis(&msg, int_pts[i],  appr_intersect, &dist_sq);
             if (dist_sq < dist_best_sq) { dist_best_sq = dist_sq; best1 = i+1; }                         
           }

           /*  find the nearest point in overlay array */
           for (i=0; i<n_ovl; i++)
           {
             /*  calculate squared distance to accept_point  */
             if (out_ovl_alloc)  sts = MA2pt2dis(&msg, xovl_pts[i], appr_intersect, &dist_sq);
             else                sts = MA2pt2dis(&msg, ovl_pts[i],  appr_intersect, &dist_sq);
             if (dist_sq < dist_best_sq) {  dist_best_sq = dist_sq;
                                             best1 = -(i+1);         }
           }
        
           /*  save point1  */
           for (k=0; k<3; k++)  
           {
             if (best1 > 0) 
             {  if (out_int_alloc)  point1[k] = xint_pts[best1-1][k];
                else                point1[k] =  int_pts[best1-1][k];   }
             else
             {  if (out_ovl_alloc)  point1[k] = xovl_pts[-best1-1][k];
                else                point1[k] =  ovl_pts[-best1-1][k];  }
           }

           /*  copy parameters  */
           if (best1 > 0) 
           { if (out_int_alloc)
                   {  parm_t1 = xipar1[best1-1];  parm_t2 = xipar2[best1-1];  }
             else  {  parm_t1 =  ipar1[best1-1];  parm_t2 =  ipar2[best1-1];  }
           }
           else 
           { if (out_ovl_alloc)
                   {  parm_t1 = xopar1[-best1-1];  parm_t2 = xopar2[-best1-1];  }
             else  {  parm_t1 =  opar1[-best1-1];  parm_t2 =  opar2[-best1-1];  }
           }

           /*  return space form extra points allocated by intersection  */
           if (xint_pts)  { free(xint_pts); free(xipar1); free(xipar2); } 
           if (xovl_pts)  { free(xovl_pts); free(xopar1); free(xopar2); }
        
           for (i=0; i<3; i++)
             intersect_point_1[i] =  intersect_point_2[i] = point1[i];
 
           /*------------------------------------*/
         } /*  end of non apparent intersection  */
           /*------------------------------------*/
       } 

       /*  intersection point is ok  */

       /*  ---------------------------------  */
       /*  loop to trim/extend both elements  */
       /*  ---------------------------------  */




       cur_max_loop = 2;
       for (ii =0; ii<cur_max_loop; ii++)
       {
         if (! (1&ii) )                        /*  1st and 3rd  */
         {
           curve_cur = curve_t1;
           trim_ele_w = trim_ele_1;  
           acc_w_obj  = acc_1_obj;
           acc_w_os   = acc_1_os;
           but_w_obj  = but_1_obj;
           but_w_os   = but_1_os;
           savedw_objid = me->saved1_objid;
           p_module_info_w = p_module_info_1;
           geom_parms_w  = geom_parms_t1;
           for (i=0; i<3; i++)
             intersect_point[i] = intersect_point_1[i];      
         }
         else
         {
           curve_cur = curve_t2;     
           trim_ele_w = trim_ele_2;
           acc_w_obj  = acc_2_obj;
           acc_w_os   = acc_2_os;
           but_w_obj  = but_2_obj;
           but_w_os   = but_2_os;
           savedw_objid = me->saved2_objid;
           p_module_info_w = p_module_info_2;
           geom_parms_w  = geom_parms_t2;
           for (i=0; i<3; i++)
           intersect_point[i] = intersect_point_2[i];
          }
         if (curve_cur->phy_closed)
         {
           trim_ele_w.objid = savedw_objid = NULL_OBJID;
           goto no_action;    
         }

         module_info_w = *p_module_info_w;

         /*  erase elements with old extension  */
         dp$display(msg  = &msg_unused,
                    mode = GRbehe,
                    oids = &trim_ele_w);
         if (!(1&msg))  Goto (wrapup);

         /*  calculate t-parameter of intersection point element  */
         om$send(mode = OM_e_wrt_object,
                 msg  = message GRgraphics.GRptproject(
                                    &msg,
                                    &p_module_info_w->md_env.matrix_type,  
                                    &p_module_info_w->md_env.matrix[0],
                                    &intersect_point[0], 
                                    pntxxx,
                                    &parm_int),
                 senderid = NULL_OBJID,
                 targetid = acc_w_obj,
                 targetos = acc_w_os);
         if (!(1&msg))  Goto (wrapup);

         /*  decide side element to extend  */
         tw = -1;
         if (parm_int.u <= CV_START_PARAM)  tw = CV_START_PARAM; 
         if (parm_int.u >= CV_END_PARAM)    tw = CV_END_PARAM;  
  
         if (tw < 0)
         {    
           if (geom_parms_w.u < parm_int.u)  tw = CV_END_PARAM;
           if (geom_parms_w.u > parm_int.u)  tw = CV_START_PARAM;
         }
         if ( !(1&ii)  &&  (trim_ele_1_classid == OPP_GR3dlineseg_class_id)
          ||   (1&ii)  &&  (trim_ele_2_classid == OPP_GR3dlineseg_class_id) )
         {
           ptr = 0;
           GRabsg_test(&msg,
                       &p_module_info_w->md_env.matrix_type,        
                       p_module_info_w->md_env.matrix,                 
                       &trim_ele_w.osnum,
                       &trim_ele_w.objid,
                       &ptr);
           /*... if (!(1&msg))  goto wrapup;   no real error  */   

           if (!(1&msg)  ||  ptr == NULL)  goto nix;
         }  
 
         if (parm_int.u<=0.00001 && curve_cur->order>2 )  
         {
           if (geom_parms_w.u > CV_END_PARAM/2)  tw = CV_END_PARAM;
           if (geom_parms_w.u < CV_END_PARAM/2)  tw = CV_START_PARAM;
         }

         for (i=0; i<3; i++)
         {
           if (tw < 0.5)
           {
             Endpoint[i] = curve_cur->poles[i];  
             Strpoint[i] = curve_cur->poles[(curve_cur->num_poles -1)*3 + i];
           }
           else
           {
             Endpoint[i] = curve_cur->poles[(curve_cur->num_poles -1)*3 + i];
             Strpoint[i] = curve_cur->poles[i];  
           }
         }

         if (savedw_objid != NULL_OBJID)
         {
           om$send (msg      = message Root.delete(0),
                    targetid = savedw_objid,
                    targetos = module_info_w.md_id.osnum);
         }

         module_info_u = module_info_w; 

         /*--- this is a part of GRcpforundo( used )  ---*/        
         om$construct_and_copy (objid     = trim_ele_w.objid,
                                obj_osnum = trim_ele_w.osnum,
                                osnum     = trim_ele_w.osnum,
                                p_objid   = &savedw_objid); 
                          
         module_info_s   = *p_module_info_w;     
         p_module_info_s = &module_info_s;
            

         /* ----------- trim/extend element --------- */

         sts = MA2pt2dis(&msg, Strpoint, intersect_point, &dist_sq);
         /*  avoid result of closed curve  */
         if (dist_sq < eps  &&  n_int == 2)    
         {
           if (ii == 1)  cur_max_loop = 3;     /*  redo first element  */
           for (k=0; k<3; k++)
             intersect_point_1[k] = intersect_point_2[k] = intersect_point[k] =
                                                           int_pts[2-best1][k];
         }

         /*  save both points  for undo  */
         for (k=0; k<3; k++)
         {
           if (ii == 0)
           { 
             me->last_extend_1_from[k] = intersect_point[k];
             me->last_extend_1_to[k]   = Endpoint[k];
           }
           else
           { 
             me->last_extend_2_from[k] = intersect_point[k];
             me->last_extend_2_to[k]   = Endpoint[k];
           }
         }

         /*  send to the object to get it to extend itself  */
         om$send(mode = OM_e_wrt_object,
                 msg = message GRcurve.GRptextend(
                               &msg,
                               p_module_info_w,
                               Endpoint,         /* pnt to extend    */  
                               intersect_point,  /* pnt to extend to */
                               Endpoint ),       /* new end pnt      */
                 targetid = trim_ele_w.objid,
                 targetos = trim_ele_w.osnum);
         if (!(1&msg))   Goto (wrapup);

         /*  redraw new element    (not done in previous call)  */
         dp$display(msg  = &msg,
                    mode = GRbd,
                    oids = &trim_ele_w); 
         if (!(1&msg))   Goto (wrapup);



 no_action:

         /*  save curve status  */ 
         if (! (1&ii) )                        /*  1st and 3rd  */
         {
           me->last_extend_ele1 = trim_ele_w;  
           me->saved1_objid = savedw_objid;
           module_info_s1 = module_info_1;
           module_info_u1 = module_info_u;
         }
         else
         {
           me->last_extend_ele2 = trim_ele_w;
           me->saved2_objid = savedw_objid;
           module_info_s2 = module_info_2;
           module_info_u2 = module_info_u;
         }

          /*  -------------------------------------  */
       }  /*  loop end of trim/extend both elements  */
          /*  -------------------------------------  */

       /*  erase highlight at all  */
       dp$erase_hilite(msg = &msg);

       /*  return all allocated curve space  */
       if (curve_t1)   {  om$dealloc(ptr = curve_t1);   curve_t1  = NULL;  }
       if (curve_t2)   {  om$dealloc(ptr = curve_t2);   curve_t2  = NULL;  }
       if (space_tr1)  {  om$dealloc(ptr = space_tr1);  space_tr1 = NULL;  }
       if (space_tr2)  {  om$dealloc(ptr = space_tr2);  space_tr2 = NULL;  }

       if (space_tx1)  {  BSfreecv(&rc, space_tx1);  space_tx1 = NULL; }
       if (space_tx2)  {  BSfreecv(&rc, space_tx2);  space_tx2 = NULL; }

       ME.super_cmd->state = IDENTIFY_ELEMENTS;     
       break;


nix:
       /*  inform user of wrong element  */
       ex$message(msgnumb = ERROR_MESSAGE_NOINT,
                  field   = ERROR_FIELD);

       /*  erase highlight at all  */
       dp$erase_hilite(msg = &msg);

       /*  redraw element 1/2 */
       dp$display(msg  = &msg,   
                  mode = GRbd,
                  oids = &trim_ele_1);  
       if (!(1&msg))  Goto (wrapup);

       dp$display(msg  = &msg,   
                  mode = GRbd,
                  oids = &trim_ele_2);  
       if (!(1&msg))  Goto (wrapup);


termi:
       ME.super_cmd->state = IDENTIFY_ELEMENTS;

       /*  return all allocated curve space  */
       if (curve_t1)   {  om$dealloc(ptr = curve_t1);   curve_t1 = NULL;   }
       if (curve_t2)   {  om$dealloc(ptr = curve_t2);   curve_t2 = NULL;   }
       if (space_tr1)  {  om$dealloc(ptr = space_tr1);  space_tr1 = NULL;  }
       if (space_tr2)  {  om$dealloc(ptr = space_tr2);  space_tr2 = NULL;  }

       if (space_tx1)  {  BSfreecv(&rc, space_tx1);  space_tx1 = NULL; }
       if (space_tx2)  {  BSfreecv(&rc, space_tx2);  space_tx2 = NULL; }

       ME.super_cmd->state = IDENTIFY_ELEMENTS;     
       break;

     }   
                  /*  end of  switch (ME.super_cmd->state)  */

   }            /*  end of do while  */

   while (TRUE);
   
 wrapup:
   ME.super_cmd->state = IDENTIFY_ELEMENTS;      /*  avoid looping  */

   /*  return all allocted curve space  */
   if (curve_t1)   {  om$dealloc(ptr = curve_t1);   curve_t1  = NULL;  }
   if (curve_t2)   {  om$dealloc(ptr = curve_t2);   curve_t2  = NULL;  }
   if (space_tr1)  {  om$dealloc(ptr = space_tr1);  space_tr1 = NULL;  }
   if (space_tr2)  {  om$dealloc(ptr = space_tr2);  space_tr2 = NULL;  }

   if (space_tx1)  {  BSfreecv(&rc, space_tx1);  space_tx1 = NULL; }
   if (space_tx2)  {  BSfreecv(&rc, space_tx2);  space_tx2 = NULL; }

   return (OM_S_SUCCESS); 

}  /*  end of execute  */





method sleep(int pos)
{
   IGRlong      sts;
   IGRlong      msg;
   IGRboolean   associative_flag;   	


   sts = OM_S_SUCCESS;
   msg = MSSUCC;

   /*--- gr$put_dit_tolerance(buffer = &me->loc_tol_old); ---*/

#ifdef HBGtst
   /*  clear message field when command is put to sleep  */
   sts = ex$message (field = MESSAGE_FIELD,
                     msgnumb = EMS_I_ClearStatusField);
#endif HBGtst
   /*  erase highlight at all  (wanted here ?)  */
   /*  dp$erase_hilite(msg = &msg);             */


   /*  reset assoc flag  */
   gr$get_associative_flag( buffer = &associative_flag );
   if ( associative_flag )   GRdisplay_associative_button(FALSE);

   return(sts);
}





method wakeup (int pos)
{
   IGRint       sts;
   IGRboolean   associative_flag;


   sts = OM_S_SUCCESS;

   /* put name of command in message field */
   sts = ex$message (field         = MESSAGE_FIELD,
                     msgnumb       = MESSAGE_TEXT);

 
   if ( EMshould_be_associative() )
   {
     gr$get_associative_flag( buffer = &associative_flag );
     if ( associative_flag )   GRdisplay_associative_button(TRUE);
   }

   return(OM_S_SUCCESS);
}





method delete (int pos)
{

   /*  delete saved elements */

   if (me->saved1_objid != NULL_OBJID)
   {
     om$send (msg      = message Root.delete(0),
              targetid = me->saved1_objid,
              targetos = me->last_extend_ele1.osnum);
   }

   if (me->saved2_objid != NULL_OBJID)
   {
     om$send (msg      = message Root.delete(0),
              targetid = me->saved2_objid,
              targetos = me->last_extend_ele2.osnum);
   }

   /*  delete call  */
   om$send(mode     = OM_e_wrt_message,   
           msg      = message Root.delete(1),
           targetid = my_id);

   return(OM_S_SUCCESS);
}




end implementation ECtrim2;


