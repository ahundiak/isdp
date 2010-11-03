/* ###################   APOGEE COMPILED   ################## */

/*************************************************************
History

  Nirmal : creation                                  06/91
  Sudha  : Modified for BSprototypes ansificatiob    12-jul-93
  scw    : clarified sleep method                    08/15/94

*************************************************************/

class implementation ECworstol;

#include "EMS.h"
#include "FI.h"
#include "EC_I.h"
#include "EC_S.h"
#include "EC_M.h"
#include "msmacros.h"
#include <stdio.h>                      /* Needed for print statements */
%safe
#include <math.h> 
%endsafe
#include "emsdef.h"
#include "griodef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "griodef.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "EMSopt.h"
#include "lcmacros.h"

#include "exmacros.h"                   /* Has ex$putque */
#include "maerr.h"
#include "EMSbnddef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "EMSlogic.h"
#include "EMSmsgdef.h"
#include "EMScmacros.h"
#include "OMmacros.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSdpb.h"
#include "nddef.h"
#include "ndmacros.h"
#include "nddef.h"
#include "godef.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "dim.h"
#include "dimdef.h"
#include "dimplcmacros.h"
#include "DItypedef.h" /* Following files are for di$translate */
#include "DIdef.h" 
#include "DIglob.h" 
#include "DIprims.h"
#include "madef.h"
#include "SKdef.h"
#include "emserr.h"
#include "go.h"
#include "SKdef.h"
#include "bserr.h"
#include "bsadsimp.h"

# ifndef DEBUG
# define DEBUG 0  /*Set to 1 if want error strings printed.*/
# endif


# ifndef EMScmacros_include
# include "EMScmacros.h"
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
        if (EMSmsgReport (sts_stupid, error_message, FALSE) OR \
            EMSmsgReport (error_number, error_message, FALSE)) \
            {\
              EMSmsgReport(OM_E_ABORT,"In ECworstol",FALSE); \
              goto wrapup; \
            }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if (! (1 & sts_stupid & error_number)) goto wrapup;\
 }
#endif


#define DIM_MCF      22 
#define DIM_MCF2     11 
#define DIM_MCF3     32 

#define PERCENT_REJECT 34
#define FILE_NAME     59 
#define ACCEPT_BUTTON  1
#define ERASE_BUTTON   4
#define WINDOW_BUTTON  5

#define INIT           0
#define LOCATE         1
#define GET_DIM        2
#define PROCESS1       3
#define PROCESS2       4
#define PROCESS3       5
#define WAIT          6

#define FORM1         1
#define FORM2         1

#define NAME    0
#define VALUE   1
#define HI_TOL  3
#define LO_TOL  2
#define SENSE   4
#define PERC_CNTRB 5
#define VAL_1   5
#define VAL_2   4
#define SIGMA   6
#define SELECT  7  
#define DRIVEN_DIM_LO_TOL 2  
#define DRIVEN_DIM_HI_TOL 3  

from GRgraphics   import GRdisplay;
from GRvg   import GRgetsymb, GRputsymb, GRchgweight, GRchgdp;
from GRcurve      import GRendpts;
from SKvariable   import SKgetvar;
from SKexplicit   import SKstoreval;
/* from DMroot import modify_misc_params;*/
from DMroot import replace_text;
from DMroot import return_dim_go,get_info;
from GRowner import GRget_components;
from NDnode import NDs_compute_node;
from expression import NDgive_value;
from SKconstraint import SKgetmgr, SKgetprops;

extern OMuword  OPP_SKline_class_id, OPP_SKarc_class_id,
                OPP_SKhpt_class_id, OPP_SKhvptpt_class_id,
                OPP_SKptpt_class_id,
                OPP_SKexplicit_class_id, OPP_EMSexpcnstr_class_id;

method init(int type; char *str_ptr)
{
 IGRlong	sts;
 IGRint ECworstol_process_form();
/*
 * Let my parent do it's stuff
 */
 sts = om$send(
  mode = OM_e_wrt_message,
  msg = message COconst.init(
   type,
   str_ptr),
  targetid = my_id);

 me->form_requested = FALSE;

 
 return(OM_S_SUCCESS);
}


method delete(int f_defer_flag)
{
 int ii,sts;

  for(ii=0;ii<me->num_loc; ii++)
    if(me->driving_dim_selected[ii]) 
       free(me->driving_dim_name[ii]);

 sts = om$send(
  mode = OM_e_wrt_message,
  msg = message Root.delete(f_defer_flag),
  targetid = my_id);

 return(OM_S_SUCCESS);
}


method super_cmd.sleep(int pos)
{
 extern void wierd_display();
 int j;

 UI_prompt("");
 UI_status("");
 UI_message("");

 GRstatus_display_button(0);
 if(me->form_requested == TRUE )
    FIf_erase(me->form);

 for(j=0;j<me->num_loc ; j++)
   wierd_display(&me->driving_dim_grid[j],&me->ele2_info[0].module_info,FALSE);

  return( OM_S_SUCCESS);
}

method wakeup(int pos)
{
 IGRlong        msg=EMS_S_Success, sts = OM_S_SUCCESS;
 IGRint         EMdpb_getinfo();
 int            j;

 extern void wierd_display();

 for(j=0;j<me->num_loc ; j++)
    wierd_display(&me->driving_dim_grid[j],&me->ele2_info[0].module_info,TRUE);

 if(me->form_requested )
      sts = om$send(
        msg = message ECworstol.status_disp(),
        targetid = my_id);

 sts = om$send (
    mode = OM_e_wrt_parent,
     msg = message ECworstol.wakeup (pos),
    targetid = my_id
 );
 ERROR (sts, msg, "wakeup parent");

 wrapup:
   return(sts);
}

method execute(int *response; char *response_data; int pos)
{

 IGRlong      EMmsg= OM_S_SUCCESS;

 struct GRevent                   event, accept_event;
 struct GRlc_locate               attributes;

 OM_S_CLASSLIST   rtree_classes, elig_classes;
 OMuword          rclass[2], eliclass[2];

 IGRchar          locate_prompt[52], accept_prompt[52], relocate_prompt[52];
 IGRint           size, object_was_located, display_flag;
 IGRlong          msg; 
 IGRint           sts = OM_S_SUCCESS ;
 IGRint           locate_mask, accept_mask;
 enum  GRdpmode   DisplayMode;

 IGRushort        props;
 IGRint           num_roots; 
 struct GRid      driven_dim_grid;
 struct GRid      *root;
 OMuword          class_id;
 int              found_same=0, number_located=0;
 int              i, j , ii ;
 IGRint           qsize;


 IGRlong rc;
 IGRchar *arglist;
 IGRdouble   error;
 IGRdouble (*func)(); 
extern IGRdouble EMgas() ;
 double rej2;
 extern void wierd_display();
 IGRdouble temp;

 func = EMgas;

 size = sizeof(event);
 qsize = sizeof(me->locate_event.event) +  sizeof(IGRint);

 ex$message(msgnumb = EM_M_AnalyzeTolWsCs);
 ex$message(msgnumb = EMS_I_InvkStatusFrm);
 GRstatus_display_button(1);

 /*
  * Enter infinite loop
  */

 do
 {
   switch(ME.super_cmd->state)
   {

     /*
      * Room for growth
      */

    case INIT:

    dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "erase_hilite error")
    for(j=0;j<me->num_loc ; j++)
    wierd_display(&me->driving_dim_grid[j],&me->ele2_info[0].module_info,FALSE);

       ME.super_cmd->state = 1;
         me->num_located = 0;
         me->num_loc = 0;
         me->form_num = 1;
         me->driven_dim_moments[0] = 0.;
         me->driven_dim_moments[1] = 0.;
         me->driven_dim_percent_rej =0.;
        *me->driven_dim_name = '\0';
         me->driven_dim_value = 0.0;
         me->worst_case_driven_dim_val1 = 0.0;
         me->worst_case_driven_dim_val2 = 0.0;
         me->driven_dim_lo_tol= 0.0;
         me->driven_dim_hi_tol= 0.0;
         break;

    case WAIT:

    dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "erase_hilite error")
    for(j=0;j<me->num_loc ; j++)
    wierd_display(&me->driving_dim_grid[j],&me->ele2_info[0].module_info,FALSE);

       ME.super_cmd->state = 1;
       break;

     case LOCATE:

     if(me->num_located == 0)
      {
      ex$message(msgnumb = EMS_P_DrivenDim, buff = locate_prompt);
      eliclass[0] = OPP_DMroot_class_id;
      ex$message(msgnumb = EMS_P_AccDim, buff = accept_prompt);
      }
     else
      {
        if(me->num_located == 1 )
          ex$message(msgnumb = EMS_P_DrivingDimMoveonForAll,
                                                         buff = locate_prompt)
        else
      ex$message(msgnumb = EMS_P_DrivingDimMoveon, buff = locate_prompt)
      eliclass[0] = OPP_EMSexpcnstr_class_id;
      }

      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask = GRm_DATA | GRm_RESTART | GRm_BACK_UP | GRm_RJT_MOVEON;
      accept_mask = GRm_DATA;
      ex$message(msgnumb = EMS_P_AccDim, buff = accept_prompt);
      ex$message(msgnumb = EMS_S_DimensionNotFound, buff = relocate_prompt);
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY;
      attributes.owner_action = LC_FLEX_COMP | LC_RIGID_OWNER |  
         LC_HANDLES | LC_NO_REF_HEADER | LC_REF_OBJECTS;
      strcpy(attributes.classes, "GRvg");

      rtree_classes.w_count = 1;
      elig_classes.w_count = 2;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
      rclass[0] = OPP_GRvg_class_id;
      eliclass[1] = OPP_SKexplicit_class_id;
      rtree_classes.p_classes = rclass;
      elig_classes.p_classes = eliclass;

      lc$locate(rc = &object_was_located, event1 = &me->locate_event, 
                event2 = &accept_event, mask1 = locate_mask, 
                mask2 = accept_mask, eventsize= &size, 
                display_flag = display_flag, response = response, 
                response_data = response_data, 
                locate_prompt = locate_prompt, 
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt, 
                attributes = &attributes, 
                stack = &me->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);


    case GET_DIM:

    if (!object_was_located)
    {
        switch(me->locate_event.response)
        {
        case EX_RJT_MOVEON :
           if  ( me->num_located ==0 )   
              {
              me->num_loc = 0;
              ME.super_cmd->state = INIT;
              }
           else
              ME.super_cmd->state = PROCESS3;
           break;

        case EX_BACK_UP:
           if  ( me->num_located == 0 || me->num_located == 1  )
           {
             ME.super_cmd->state = INIT;
             if(me->form_requested == TRUE)
             {
/* reinitialize */
               for(j=0;j<me->num_loc ; j++)
                      wierd_display(&me->driving_dim_grid[j],
                             &me->ele2_info[0].module_info,FALSE);
               me->num_located = 0;
               me->num_loc = 0;
               me->driven_dim_moments[0] = 0.;
               me->driven_dim_moments[1] = 0.;
               me->driven_dim_percent_rej =0.;
               *me->driven_dim_name = '\0';
               me->driven_dim_value = 0.0;
               me->worst_case_driven_dim_val1 = 0.0;
               me->worst_case_driven_dim_val2 = 0.0;
               me->driven_dim_lo_tol= 0.0;
               me->driven_dim_hi_tol= 0.0;
               sts = om$send(
                     msg = message ECworstol.update_status_form(),
                  targetid = my_id);
             }
           }
           else
             {
             me->num_located--; 
             for(i=0;i< me->num_loc;i++)
             {
               if( me->driving_dim_grid[i].objid ==
                            me->ele2_info[me->num_located].located_obj.objid)
               {
               me->driving_dim_selected[i]=FALSE;
               break;
               }
             }
             if(me->form_requested == TRUE)
             sts = om$send( msg = message ECworstol.update_status_form(),
                       targetid = my_id);
/***/
             DisplayMode = GRhe;
             sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                        &me->ele1_info.module_info.md_env.matrix_type, 
                        me->ele1_info.module_info.md_env.matrix, 
                        &DisplayMode, 
                        &me->ele1_info.module_info.md_id),
               targetid = me->ele2_info[me->num_located].located_obj.objid,
               targetos = me->ele2_info[me->num_located].located_obj.osnum);
             ERROR(sts, msg, "GRdisplay error");

              ME.super_cmd->state = LOCATE;
             }
           break;
       
         default:
            return (OM_S_SUCCESS);
 
        } /* switch*/

    }
    else /* object  was located */
    {
        struct GRid eleid;
	GRclassid eleclass;

        me->ele2_info[me->num_located] = accept_event.located_object[0];
        me->ele1_info = accept_event.located_object[0];
        eleid = me->ele1_info.located_obj;

        if(me->num_located == 0) /* driven dim located */
         {
           om$get_classid (objid = eleid.objid, osnum = eleid.osnum,
           p_classid = &eleclass);
           if (om$is_ancestry_valid (superclassid = OPP_SKexplicit_class_id,
               subclassid = eleclass) == OM_S_SUCCESS)
           {
               props = NULL;
               sts = om$send(msg = message SKconstraint.SKgetprops(&msg,&props),
                   targetid = me->ele1_info.located_obj.objid,
                   targetos = me->ele1_info.located_obj.osnum);
               EMerr_hndlr (EMSerror (sts & msg), sts, OM_E_ABORT, wrapup);

               dp$erase_hilite(msg = &msg);
               ERROR(sts, msg, "erase_hilite error")
  
  
               if( !(props & SK_PARAMETER_DIM))
               {
                   ex$message(msgnumb = EMS_S_DimIsConstr);
                   me->num_loc = 0;
                   ME.super_cmd->state = INIT;
               }
               else
                   ME.super_cmd->state = PROCESS1;
            }
	    else
                ME.super_cmd->state = PROCESS1;
        }

        else /* driving dim located */

        {
          found_same=0;
          for(ii=0;ii<me->num_located;ii++)
           if(me->ele1_info.located_obj.objid == 
             me->ele2_info[ii].located_obj.objid)
             {
             found_same=1;
             break;
             }
          if(found_same ==1)
             {
             ex$message(msgnumb = EMS_S_DimAlrdyLc);
             me->num_located--;
             }
          else
             {

       for(i=0;i< me->num_loc;i++)
       {
             if( me->driving_dim_grid[i].objid ==
                            me->ele2_info[me->num_located].located_obj.objid)
             {
              me->driving_dim_selected[i]=TRUE;
              break;
             }
       }
       if(me->form_requested == TRUE)
           sts = om$send( msg = message ECworstol.update_status_form(),
                     targetid = my_id);
       ME.super_cmd->state = LOCATE;

           }
        }
        me->num_located++;
    }
    break;


       case PROCESS1:
       {
        struct GRid root_grid;
        struct GRmd_env *env;
        struct diminfo dim_info;
        struct DMloc_param  dim_measure;
        IGRchar temp_name[DI_PATH_MAX];
        IGRint jj,kk;
        OMuint comp_count;
        OM_S_CHANSELECT to_child;
        struct GRid dim_GRid;
        extern OMuword OPP_DMroot_class_id;
        IGRushort skprops;

        env = &me->ele2_info[0].module_info;
        driven_dim_grid =  me->ele2_info[0].located_obj;

        sts = om$send (msg = message DMroot.get_info((IGRint *)&msg,
                            env, &dim_info),
               targetid = driven_dim_grid.objid,
               targetos = driven_dim_grid.osnum);
        ERROR(sts, 1, "get info error")

        dm$get_dim_param(type = DM_LOC_PARAM, 
                    dim_objid =  driven_dim_grid.objid,
                    dim_osnum =  driven_dim_grid.osnum,
                       p_data = &dim_measure);

        *temp_name = '\0';
        sts = di$untranslate(objname = temp_name,
                               objid =  driven_dim_grid.objid,
                               osnum =  driven_dim_grid.osnum);


        for(jj=0;  *(temp_name + jj) != '\0' ; jj++);
        for(kk=jj; *(temp_name + kk) != ':' && kk >= 0  ; kk--);
   
        if(sts)
          strcpy(me->driven_dim_name, temp_name+kk+1);
        else
          *me->driven_dim_name = '\0';

        me->driven_dim_type = dim_info.dim_type;
        me->driven_dim_value = dim_info.dim_value;

        EMtofloat(dim_measure.primary.tole_up,&me->driven_dim_hi_tol);
        EMtofloat(dim_measure.primary.tole_low,&me->driven_dim_lo_tol);

        if( me->driven_dim_type == STACKED_ANGULAR ||
            me->driven_dim_type == SINGLE_ARC_ANGLE ||
            me->driven_dim_type == STRINGED_ANGULAR)
            {
            me->driven_dim_value *= 180/PI;
            }

        DisplayMode = GRhe;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                        &me->ele2_info[0].module_info.md_env.matrix_type, 
                        me->ele2_info[0].module_info.md_env.matrix, 
                        &DisplayMode, 
                        &me->ele2_info[0].module_info.md_id),
               targetid = driven_dim_grid.objid,
               targetos = driven_dim_grid.osnum);
        ERROR(sts, msg, "GRdisplay error");

/********************* get roots of the driven dimension **********************/

       root = NULL; num_roots = 0; 
       sts = nd$get_graph(nb_tip=1,
                         p_tip=  &driven_dim_grid);

       sts = nd$get_list_in_graph(  acc_type = ND_EXTERN,
                                 rej_type = ND_TIP | ND_BODY,
                                 p_count  = &num_roots,
                                 buf_addr = &root);


       me->num_loc =0;
       number_located=0;
       i=0;

       for(j=0;j< num_roots; j++)
       {
        root_grid = *(root+j);
        om$get_classid(osnum=root_grid.osnum, objid= root_grid.objid,
                      p_classid= &class_id);
        if (om$is_ancestry_valid (superclassid = OPP_expression_class_id,
                                subclassid = class_id) == OM_S_SUCCESS)
        {

           number_located++;
           me->num_loc++;
           me->driving_dim_grid[i] = root_grid;
        
/***/
        wierd_display(&root_grid,&me->ele1_info.module_info,TRUE);
/***/

/*******  allocate memory *************/
    if (om$dimension_of(varray = me->driving_dim_type) <= number_located)
    {
    sts = om$vla_set_dimension(varray = me->driving_dim_name,
                                 size = number_located + 2);
    sts = om$vla_set_dimension(varray = me->driving_dim_type,
                                 size = number_located + 2 );
    sts = om$vla_set_dimension(varray = me->driving_dim_value,
                                 size = number_located + 2);
    sts = om$vla_set_dimension(varray = me->driving_dim_lo_tol,
                                 size = number_located + 2);
    sts = om$vla_set_dimension(varray = me->driving_dim_hi_tol,
                                 size = number_located + 2);
    sts = om$vla_set_dimension(varray = me->driving_dim_selected,
                                 size = number_located + 2);
    sts = om$vla_set_dimension(varray = me->driving_dim_grid,
                                 size = number_located + 2);
    sts = om$vla_set_dimension(varray = me->ele2_info,
                                 size = number_located + 2);
    sts = om$vla_set_dimension(varray = me->worst_case_driving_dim_val1,
                                 size = number_located + 2);
    sts = om$vla_set_dimension(varray = me->worst_case_driving_dim_val2,
                                 size = number_located + 2);
    sts = om$vla_set_dimension(varray = me->driving_dim_percentage_contrb,
                                 size = number_located + 2);
    sts = om$vla_set_dimension(varray = me->driving_dim_sensitivity,
                                 size = number_located + 2);
    sts = om$vla_set_dimension(varray = me->driving_dim_sgma,
                                 size = number_located + 2);

    } 
/*
 * Env was being redefined when memory was being malloced again.
 * Prasad 02/23/92
 */

        env = &me->ele1_info.module_info;
        om$get_classid(osnum=root_grid.osnum, objid= root_grid.objid,
                      p_classid= &class_id);

        if ( om$is_ancestry_valid (superclassid = OPP_SKexplicit_class_id,
               subclassid = class_id) == OM_S_SUCCESS
                        ||
            om$is_ancestry_valid (superclassid = OPP_EMSexpcnstr_class_id,
               subclassid = class_id) == OM_S_SUCCESS
           )
        {
          sts = om$send (msg = message DMroot.get_info((IGRint *)&msg,
                            env, &dim_info),
               targetid = root_grid.objid,
               targetos = root_grid.osnum);
          ERROR(sts, 1, "get info error")

          me->driving_dim_value[i] = dim_info.dim_value;

        if( om$is_ancestry_valid (superclassid = OPP_SKhvptpt_class_id,
               subclassid = class_id) == OM_S_SUCCESS)
        {
          sts = om$send (msg = message SKconstraint.SKgetprops(&msg,
                         &skprops),
               targetid = root_grid.objid,
               targetos = root_grid.osnum);
          if(skprops & SK_HALFVALUE)
             me->driving_dim_value[i] *=2.;
        }

          dm$get_dim_param(type = DM_LOC_PARAM, 
                          dim_objid = root_grid.objid,
                          dim_osnum = root_grid.osnum,
                       p_data = &dim_measure);

          me->driving_dim_type[i] = dim_info.dim_type;
          EMtofloat(dim_measure.primary.tole_up,&me->driving_dim_hi_tol[i]);
          EMtofloat(dim_measure.primary.tole_low,&me->driving_dim_lo_tol[i]);
        }
        else
        {
	  sts = om$send(msg= message
                      expression.NDgive_value(&me->driving_dim_value[i]),
	        	targetid = root_grid.objid,
			targetos = root_grid.osnum);
          ERROR(sts, 1, "NDgive_value error")

          me->driving_dim_type[i] = STRINGED_LINEAR;
          me->driving_dim_lo_tol[i]= -0.001;
          me->driving_dim_hi_tol[i]= 0.001;

          EMmake_chanselect (NDchildren_children,&to_child);
          comp_count = 0;
          om$get_channel_count(p_chanselect = &to_child,
                      objid = root_grid.objid,
                      osnum = root_grid.osnum,
                      count = &comp_count);
          if (!(comp_count)) goto wrapup;

        for(ii=0;ii<comp_count;ii++)
         {
          sts = om$get_objid_at_index(objid = root_grid.objid,
                              osnum = root_grid.osnum,
                              index = ii,
                              p_chanselect = &to_child,
                              objidaddr = &dim_GRid.objid,
                              osnumaddr = &dim_GRid.osnum);
          if (!(1&sts)) goto wrapup;

          if (EFisAncestryValid(&msg, dim_GRid.objid, dim_GRid.osnum, 
                          OPP_DMroot_class_id, FALSE))
             {
              root_grid.objid = dim_GRid.objid;
              root_grid.osnum = dim_GRid.osnum;

              sts = om$send (msg = message DMroot.get_info((IGRint *)&msg,
                            env, &dim_info),
              targetid = root_grid.objid,
              targetos = root_grid.osnum);
              ERROR(sts, 1, "get info error")

              me->driving_dim_type[i] = dim_info.dim_type;
              dm$get_dim_param(type = DM_LOC_PARAM, 
                          dim_objid = root_grid.objid,
                          dim_osnum = root_grid.osnum,
                       p_data = &dim_measure);
              EMtofloat(dim_measure.primary.tole_up,&me->driving_dim_hi_tol[i]);
             EMtofloat(dim_measure.primary.tole_low,&me->driving_dim_lo_tol[i]);
             break;
            }
          }
        }

        dm$get_dim_param(type = DM_LOC_PARAM, 
                    dim_objid = root_grid.objid,
                    dim_osnum = root_grid.osnum,
                       p_data = &dim_measure);

        me->driving_dim_name[i] = ( IGRchar * )malloc( 20 * sizeof(char) );
        *temp_name = '\0';
        sts = di$untranslate(objname =  temp_name,
                               objid = root_grid.objid,
                               osnum = root_grid.osnum);


        for(jj=0; *(temp_name + jj) != '\0' ; jj++);
        for(kk=jj; *(temp_name + kk) != ':'; kk--);

        if(sts)
          strcpy(me->driving_dim_name[i],temp_name+kk+1); 
        else
          *me->driving_dim_name[i] = '\0';

        me->driving_dim_selected[i]=FALSE;

        if( me->driving_dim_type[i] == STACKED_ANGULAR ||
            me->driving_dim_type[i] == SINGLE_ARC_ANGLE ||
            me->driving_dim_type[i] == STRINGED_ANGULAR)
            {
            me->driving_dim_value[i] *= 180/PI;
            }

        /* initializing */
        me->driving_dim_selected[i]= FALSE;
        me->driving_dim_sgma[i]= 0.;
        me->driving_dim_percentage_contrb[i] = 0.;
        me->driving_dim_sensitivity[i] = 0.;
        me->worst_case_driven_dim_val1=0.;
        me->worst_case_driven_dim_val2=0.;
        i++;
       }
      }


      if(me->form_requested == TRUE)
      sts = om$send(
           msg = message ECworstol.update_status_form(),
           targetid = my_id);

      ME.super_cmd->state = LOCATE;
     }
      break;
     

/************************ analyze ****************************/
   
     case PROCESS3:
     {
     int all = 0;

     driven_dim_grid =  me->ele2_info[0].located_obj;

     if(me->num_located == 1)
     {
        for(i=0;i< me->num_loc;i++)
          if(me->driving_dim_selected[i]==TRUE)
            {
            all =1;
            break;
            }
        if(all == 0)
        {
          for(i=0;i< me->num_loc;i++)
             {
             me->worst_case_driving_dim_val1[i]=0;
             me->worst_case_driving_dim_val2[i]=0;
             me->driving_dim_selected[i]=TRUE;
             }
             me->worst_case_driven_dim_val1=0;
             me->worst_case_driven_dim_val2=0;
        
          if(me->form_requested == TRUE)
             sts = om$send(
               msg = message ECworstol.update_status_form(),
               targetid = my_id);
        }
     }

       ex$message(msgnumb = EMS_S_Analyzing);

       EMsense( &EMmsg,
                &me->num_loc,
                me->driving_dim_name,
                me->driving_dim_grid,
                &me->driven_dim_type,
                me->driving_dim_value,
                me->driving_dim_lo_tol,
                me->driving_dim_hi_tol,
                me->driving_dim_selected,
                &driven_dim_grid,
                &me->ele1_info.module_info,
                me->driving_dim_sensitivity,
                me->driving_dim_percentage_contrb);

        ERROR(1, EMmsg, "EMsense error")

       EMworst( &EMmsg,
                &me->num_loc,
                me->driving_dim_name,
                me->driving_dim_grid,
                &me->driven_dim_type,
                me->driving_dim_value,
                me->driving_dim_hi_tol,
                me->driving_dim_lo_tol,
                me->driving_dim_selected,
                &driven_dim_grid,
                &me->ele1_info.module_info,
                me->driving_dim_sensitivity,
                me->worst_case_driving_dim_val1,
                me->worst_case_driving_dim_val2,
                &me->worst_case_driven_dim_val1,
                &me->worst_case_driven_dim_val2);
        ERROR(1, EMmsg, "EMworst error")

     for(ii=0;ii< me->num_loc;ii++)
      {
       if(me->driving_dim_sgma[ii] == 0)
          me->driving_dim_sgma[ii] = (me->driving_dim_hi_tol[ii]-
                                      me->driving_dim_lo_tol[ii] )/6;
      }
     me->driven_dim_moments[0] = 0;
     me->driven_dim_moments[1] = 0;
     for(ii=0;ii< me->num_loc;ii++)
      {
       if( me->driving_dim_selected[ii] == TRUE) 
        {
          me->driven_dim_moments[0] +=  me->driving_dim_sensitivity[ii] * 
                                        me->driving_dim_value[ii];
          me->driven_dim_moments[1] +=  me->driving_dim_sensitivity[ii] * 
                                        me->driving_dim_sensitivity[ii] *
                                        me->driving_dim_sgma[ii]*
                                        me->driving_dim_sgma[ii];
        }
      }
      temp = me->driven_dim_moments[1];

      me->driven_dim_moments[1] =  sqrt(temp  );

      me->driven_dim_moments[0] =  me->driven_dim_value; 

      if( me->driven_dim_moments[1] < 0.0)
        me->driven_dim_moments[1] = 0.0 - me->driven_dim_moments[1];
      if( me->driven_dim_moments[1] > 0.)
      {
          arglist = (char *)&me->driven_dim_moments[0];

          rej2 = 0.0;
          if(me->driven_dim_lo_tol < me->driven_dim_hi_tol)
          rej2 = BSadsimp(func,
                      1,
                      me->driven_dim_moments[1],
                      arglist,
                      me->driven_dim_moments[0] + me->driven_dim_lo_tol,
                      me->driven_dim_moments[0] + me->driven_dim_hi_tol,
                      0.00001,
                      0.00001,
                      &error,
                      &rc);

          me->driven_dim_percent_rej = 100 * (1 - rej2);
       }
       else
        me->driven_dim_percent_rej = 0.0;

        if(me->driven_dim_percent_rej < 0.0 )  
          me->driven_dim_percent_rej = 0.0;
        else if(me->driven_dim_percent_rej > 100.0)
          me->driven_dim_percent_rej = 100.0 ;


    ME.super_cmd->state = WAIT;
    me->form_num = 2;

    sts = om$send(
      msg = message ECworstol.status_disp(),
      targetid = my_id);
   }
    break;
/*********************************************************************/


      default:
      ERROR(OM_E_ABORT, 0, "Default state reached")

   } /* switch(ME.super_cmd->state) */

  }
 while(TRUE);

 wrapup:
  *response = TERMINATE;
  return(sts);
}

/************ form handling *****************/


method update_status_form()
{
 int i;


   FIfld_set_num_rows(me->form,DIM_MCF,me->num_loc);

   for(i=0;i< me->num_loc ;i++)
   {
     FIfld_set_text(me->form,DIM_MCF,i,NAME,me->driving_dim_name[i],FALSE);
     FIfld_set_value(me->form,DIM_MCF,i,VALUE,me->driving_dim_value[i],FALSE);
     FIfld_set_value(me->form,DIM_MCF,i,LO_TOL,me->driving_dim_lo_tol[i],FALSE);
     FIfld_set_value(me->form,DIM_MCF,i,HI_TOL,me->driving_dim_hi_tol[i],FALSE);
     FIfld_set_value(me->form,DIM_MCF,i,SENSE,
                     me->driving_dim_sensitivity[i],FALSE);
     FIfld_set_value(me->form,DIM_MCF,i,PERC_CNTRB,
                     me->driving_dim_percentage_contrb[i], FALSE);
     if( me->driving_dim_sgma[i] == 0.0)
        me->driving_dim_sgma[i] = (me->driving_dim_hi_tol[i] 
                                 - me->driving_dim_lo_tol[i])/6.;
        
     FIfld_set_value(me->form,DIM_MCF,i,SIGMA,
                     me->driving_dim_sgma[i],FALSE);
     if(me->driving_dim_selected[i] == TRUE)
        FIfld_set_text(me->form,DIM_MCF,i,SELECT,"yes",FALSE);
     else
        FIfld_set_text(me->form,DIM_MCF,i,SELECT,"no",FALSE);
   }

      if(me->num_located <= 0)
        {
         FIfld_set_num_rows(me->form,DIM_MCF2,0);
         FIfld_set_num_rows(me->form,DIM_MCF3,0);
        }
      else
        {
         FIfld_set_num_rows(me->form,DIM_MCF2,1);
         FIfld_set_num_rows(me->form,DIM_MCF3,0);
        }

    for(i=0;i<me->num_located;i++){
      FIfld_set_text(me->form,DIM_MCF2,i,NAME,me->driven_dim_name,FALSE);
      FIfld_set_value(me->form,DIM_MCF2,i,VALUE,me->driven_dim_value,FALSE);
      FIfld_set_value(me->form,DIM_MCF2,i,LO_TOL,me->driven_dim_lo_tol,FALSE);
      FIfld_set_value(me->form,DIM_MCF2,i,HI_TOL,me->driven_dim_hi_tol,FALSE);
      if(me->form_num == 2)
      {
        FIfld_set_value(me->form,DIM_MCF2,i,VAL_1,
                            me->worst_case_driven_dim_val1,FALSE);
        FIfld_set_value(me->form,DIM_MCF2,i,VAL_2,
                            me->worst_case_driven_dim_val2,FALSE);
        FIfld_set_value(me->form,DIM_MCF3,i,0,
                            me->driven_dim_moments[0], FALSE);
        FIfld_set_value(me->form,DIM_MCF3,i,1,
                            me->driven_dim_moments[1], FALSE);
      }
     }

     if(me->form_num == 2)
        FIg_set_value(me->form,PERCENT_REJECT, me->driven_dim_percent_rej );

 return(OM_S_SUCCESS);
}


method status_disp()
{
  IGRlong status, EMmsg;
  int ret;
  IGRint ECworstol_process_form();

  status = OM_S_SUCCESS;
  EMmsg = 1;

  if(!me->form_requested)
     me->form_requested = TRUE;

  if(!me->form)
   {
    ret = FIf_new (FORM1, "MDAnTolWrsCs", ECworstol_process_form, &me->form);
    if (ret) { status = FALSE; goto wrapup; }
   }

  ret = FIf_set_cmd_oid_os(me->form, my_id, OM_Gw_current_OS);
   if (ret) { status = FALSE; goto wrapup; }

  ret = FIf_set_location (me->form, 0, 125);
  if (ret) { status = FALSE; goto wrapup; }

  ret = FIf_display(me->form);
  if (ret) { status = FALSE; goto wrapup; }

  status = om$send(msg = message ECworstol.update_status_form(),
                targetid = my_id);
  wrapup:
  if (!(1&status&EMmsg))
    return (OM_E_ABORT);
  return (status);
 }



IGRint ECworstol_process_form (form_label, gadget_label, value, form_ptr)
int form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{
  IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;


  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (stat_func)
    return (OM_E_ABORT);

  stat_OM = om$send (msg = message ECworstol.do_form (&msg_loc, form_label,
                     gadget_label, value),
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  if(! (stat_OM & 1))
   return (OM_E_ABORT);
return (stat_OM);
}

method do_form (IGRlong *msg1; IGRint form_label; IGRint gadget_label;
               IGRdouble value)
{
 IGRdouble      value;
 IGRint         col,pos,row,sel;
 IGRboolean	update_form;
 IGRlong	msg, sts;
 IGRchar        text[15];
 int            ii,i;
 FILE           *fp;
 enum  GRdpmode   DisplayMode;

 IGRlong rc;
 IGRchar *arglist;
 IGRdouble   error;
 IGRdouble (*func)();
extern IGRdouble EMgas() ;
 double rej2;
 func = EMgas;

 update_form = TRUE;

 switch (gadget_label)
  {
   case ERASE_BUTTON:
    if(me->form_num == 2)
    {

   /* initializing here and not in INIT because of 
                                the need to display forms */

       ME.super_cmd->state = 1;
         me->num_located = 0;
         me->driven_dim_moments[0] = 0.;
         me->driven_dim_moments[1] = 0.;
         me->driven_dim_percent_rej =0.;
         *me->driven_dim_name = '\0';
         me->driven_dim_value = 0.0;
         me->worst_case_driven_dim_val1 = 0.0;
         me->worst_case_driven_dim_val2 = 0.0;
         me->driven_dim_lo_tol= 0.0;
         me->driven_dim_hi_tol= 0.0;
 
  /* freeing memory */

     for(ii=0;ii<me->num_loc; ii++)
      if(me->driving_dim_selected[ii] == TRUE)
         free(me->driving_dim_name[ii]);
     me->num_loc =0;
    }
    update_form = TRUE;
    FIg_set_state_off (me->form, gadget_label);
    FIf_erase (me->form);
    break;

   case ACCEPT_BUTTON:
    update_form = TRUE;
    FIg_set_state_off (me->form, gadget_label);
    FIf_erase (me->form);
    break;

   case WINDOW_BUTTON:
    FIg_erase (me->form, gadget_label);    
    break;

   case DIM_MCF:
      update_form = TRUE;
      FImcf_get_active_col(me->form,DIM_MCF,&col,&pos);
      FIfld_get_active_row(me->form,DIM_MCF,&row,&pos);
     if(col <= 1 )
     {
       if(me->form_num == 1)
         if(me->driving_dim_selected[row] == TRUE)
            {
             DisplayMode = GRhe;
             me->driving_dim_selected[row] = FALSE;
            }
         else
            {
             DisplayMode = GRhd;
             me->driving_dim_selected[row] = TRUE;
            }
       else
       {
         dp$erase_hilite(msg = &msg);
         DisplayMode = GRhd;
       }

         sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                       &me->ele1_info.module_info.md_env.matrix_type, 
                       me->ele1_info.module_info.md_env.matrix, 
                       &DisplayMode, 
                       &me->ele1_info.module_info.md_id),
         targetid = me->driving_dim_grid[row].objid,
         targetos = me->driving_dim_grid[row].osnum);
         ERROR(sts, msg, "GRdisplay error");

    }

      for(row = 0; row < me->num_loc ; row++)
       if(me->driving_dim_selected[row] == TRUE)
         for(col = LO_TOL ; col <= SIGMA ; col++)
           switch(col)
           {
           case LO_TOL:
              FIfld_get_value(me->form,DIM_MCF,row,col,&value,&sel,&pos);
              me->driving_dim_lo_tol[row] = value;
              break;
           case HI_TOL:
              FIfld_get_value(me->form,DIM_MCF,row,col,&value,&sel,&pos);
              me->driving_dim_hi_tol[row] = value;
              break;
           case SIGMA:
              FIfld_get_value(me->form,DIM_MCF,row,col,&value,&sel,&pos);
              me->driving_dim_sgma[row] = value;
              break;
            }
         FImcf_set_active_col(me->form,DIM_MCF,0,0);
         break;
 
        
   case DIM_MCF2:
      update_form = TRUE;
      row =0;
      FImcf_get_active_col(me->form,DIM_MCF2,&col,&pos);
      switch(col)
      {
      case DRIVEN_DIM_LO_TOL:
      case DRIVEN_DIM_HI_TOL:

         FIfld_get_value(me->form,DIM_MCF2,row,col,&value,&sel,&pos);
         if(col == DRIVEN_DIM_LO_TOL)
              me->driven_dim_lo_tol = value;
           else  
              me->driven_dim_hi_tol = value;

        if(me->driven_dim_moments[1] > 0)
        {
          me->driven_dim_percent_rej = 0.0;
          arglist = (char *)&me->driven_dim_moments[0];

          rej2 = 0.0;
          if(me->driven_dim_lo_tol < me->driven_dim_hi_tol)
               rej2 = BSadsimp(func,
                      1,
                      me->driven_dim_moments[1],
                      arglist,
                      me->driven_dim_moments[0] + me->driven_dim_lo_tol,
                      me->driven_dim_moments[0] + me->driven_dim_hi_tol,
                      0.00001,
                      0.00001,
                      &error,
                      &rc);

         me->driven_dim_percent_rej = 100 * (1 - rej2);
         if(me->driven_dim_percent_rej < 0.0 )  
           me->driven_dim_percent_rej = 0.0;
         else if(me->driven_dim_percent_rej > 100.0)
           me->driven_dim_percent_rej = 100.0 ;
         FIg_set_value(me->form,PERCENT_REJECT,me->driven_dim_percent_rej);
        }
      }
       break;

    case FILE_NAME:
      update_form = FALSE;
      FIfld_get_text(me->form,FILE_NAME,0,0,25,text,&sel,&pos);
if(text == NULL)
  printf("error opening file \n");
else if( (fp = fopen( text , "w")) == NULL )
  printf("error opening file: %s \n", text);
else
  {
      fprintf(fp,"----------WORST CASE ANALYSIS RESULTS ----------\n\n");
      fprintf(fp,"DRIVEN DIMENSION:\n");
   fprintf(fp,"name    value    lo-tol   hi-tol   low value   high value \n\n");
      fprintf(fp," %s   %f   %f   %f   %f   %f\n",
      me->driven_dim_name,
      me->driven_dim_value,
      me->driven_dim_lo_tol,
      me->driven_dim_hi_tol,
      me->worst_case_driven_dim_val1,
      me->worst_case_driven_dim_val2);

 fprintf(fp,"\n\nDRIVING DIMENSIONS:\n");
 fprintf(fp,"no.  name   value  lo-tol  hi-tol  sensitivity  % contrb   sigma\n\n");
   for(i=0;i<me->num_loc;i++)
   {
    if(me->driving_dim_selected[i] == TRUE )
      fprintf(fp,"%d   %s   %f   %f   %f   %f   %f   %f  \n",
      i+1,
      me->driving_dim_name[i],
      me->driving_dim_value[i],
      me->driving_dim_lo_tol[i],
      me->driving_dim_hi_tol[i],
      me->driving_dim_sensitivity[i],
      me->driving_dim_percentage_contrb[i],
      me->driving_dim_sgma[i]);
   }

 
  fprintf(fp,"\n\n DRIVEN DIMENSION PARAMETER ESTIMATES:\n\n");
  fprintf(fp,"driven dimension distribution estimates:\n");
  fprintf(fp,"first moment(mean) %f\nsecond moment(sigma) %f\n",
      me->driven_dim_moments[0],
      me->driven_dim_moments[1]);
  fclose(fp);
 }
  FIg_set_state_off (me->form, gadget_label);
  break;
 }
        

  if(update_form )  
 {
   sts = om$send(
    msg = message ECworstol.update_status_form(),
    targetid = my_id);
 }
 wrapup:
 return(OM_S_SUCCESS);
}

/*********************** display ************************/

void wierd_display(grid,env,witch)
 struct GRmd_env *env;
 struct GRid *grid;
 IGRboolean witch;
 {
 OMuint comp_count;
 IGRlong msg=EMS_S_Success, sts = OM_S_SUCCESS;
 OM_S_CHANSELECT to_comps;
 struct GRid dim_GRid;
 extern OMuword OPP_DMroot_class_id;

 EMmake_chanselect (GRcmpowner_to_components, &to_comps);

 comp_count = 0;
 om$get_channel_count(p_chanselect = &to_comps,
                      objid = grid->objid,
                      osnum = grid->osnum,
                      count = &comp_count);

 if (comp_count)
 {
   sts = om$get_objid_at_index(objid = grid->objid,
                              osnum = grid->osnum,
                              index = 0,
                              p_chanselect = &to_comps,
                              objidaddr = &dim_GRid.objid,
                              osnumaddr = &dim_GRid.osnum);
   if (!(1&sts)) goto wrapup;

   if (EFisAncestryValid(&msg, dim_GRid.objid, dim_GRid.osnum, 
                          OPP_DMroot_class_id, FALSE))
   {
    dm$enclose_dimtext(set1_clear0=witch,
                          dim_grid = &dim_GRid,
                          md_env = env);
   }
  }
   wrapup:
   return ;
 }
	
end implementation ECworstol;
