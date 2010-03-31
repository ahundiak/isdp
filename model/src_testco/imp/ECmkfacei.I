/* ###################   APOGEE COMPILED   ################## */
class implementation ECmkface;

#include "EMS.h"
#include <stdio.h>                      /* Needed for print statements */
#include "griodef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "griodef.h"
#include "dpmacros.h"
#include "EMSopt.h"
#include "lcmacros.h"
#include "local_dsp.h"                  /* Local display macro */
#include "exmacros.h"                   /* Has ex$putque */
#include "maerr.h"
#include "EMSbnddef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "EMSlogic.h"
#include "EMSmsgdef.h"
#include "EMScmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSdpb.h"
#include "EMSasopts.h"
#include "EC_M.h"
#include "EC_P.h"
#include "EC_S.h"
#include "EMSaction.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "EMSascmacros.h"

#define INCREMENT 10
#define TRUE  1
#define FALSE 0

# ifndef DEBUG
# define DEBUG 0  /*Set to 1 if want error strings printed.*/
# endif

# define ACCEPT_IS_DATA 1

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
              EMSmsgReport(OM_E_ABORT,"In ECmkface",FALSE); \
              goto wrapup; \
            }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if (! (1 & sts_stupid & error_number)) goto wrapup;\
 }
#endif

from GRgraphics   import GRdisplay;
from EMSsurface   import EMgetactiveid;
from EMSsfmkface  import EMmake_face_execute, EMgraceful_exit;
from EMSsurface   import EMmake_face;
from EMSdpr       import EMundo;
from EMSsfdpr     import EMadd;
from EMSsubbs     import EMpartolbasis;
from EMSloop      import EMgroup_loops;

extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_GRbspline_class_id, OPP_GRcurve_class_id;

/*
 History   

9 June 1992 	Tapadia Message sub system compliance

12 Jun 1989 jBk Moved UI_message from wakeup to execute;

                enhanced wakeup to send to self wrt parent.

22 May 1989 jBk Removed extern GRgetevent () declaration.

        RC      05/04/87  Modified COimpbnd code for 
                          this command object
        DLB     5/27/87   mod for re-execute.
        RC      7/2/87    Modified such that more than 20 curves
                          can be located in makeing a face.
        RC      2/8/88    Added code to handle grouping of 
                          ambiguous loops.
        DLB     08/15/88  Removed undo/recompute code.
        SM      21-Mar-89 In all the GRdisplay sends, changed the
                          display_info argument to '&me->ModuleInfo->md_id'. 
                          I did this because the curves located can be in a 
                          reference file and the md_id from that element's 
                          locate info is not the active one. For consistency
                          and safety all the message sends were changed thusly.
        Inasu  Apr 30,90  Fix for TR90n1034 (Make face snap).
        scw    08/08/91   Converted to use gr$dpb associative flag
        AMD    02/04/92   Removed display code after undo.
	Tapadia	5/27/92   Modified for message sub system compliance
        scw    08/14/94   clarified sleep method
*/

method super_cmd.sleep(int pos)
{
 IGRlong msg=EMS_S_Success, sts = OM_S_SUCCESS;
 enum    GRdpmode DisplayMode;

 ex$message(msgnumb = EMS_P_ClearPromptField);
 ex$message(msgnumb = EMS_I_ClearStatusField);
 ex$message(msgnumb = EM_M_ClearMessageField);

 DisplayMode = GRbdhe;

 if (me->numcrv)
 {
   sts = dp$erase_hilite(msg = &msg);
   ERROR(sts, msg, "erase_hilite");
 }

 if (me->associative_flag)
   GRdisplay_associative_button(FALSE);

 wrapup:
   return(sts);
}

method wakeup(int pos)
{
 IGRlong        i, msg=EMS_S_Success, sts = OM_S_SUCCESS;
 IGRint         EMdpb_getinfo();
 enum           GRdpmode DisplayMode=GRhd;

 sts = om$send(mode = OM_e_wrt_parent,
               msg = message ECmkface.wakeup (pos),
               targetid = my_id );
 ERROR (sts, msg, "wakeup parent");

 for (i = 0;i < me->numcrv; i++)
 {
   sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                  &me->locobj[i].module_info.md_env.matrix_type,
                  me->locobj[i].module_info.md_env.matrix, 
                  &DisplayMode, &me->ModuleInfo.md_id),
                 targetid = me->locobj[i].located_obj.objid,
                 targetos = me->locobj[i].located_obj.osnum);
   ERROR(sts, msg, "GRdisplay");
 }

 /*
  * Get the dpb variables.
  */

 sts = EMdpb_getinfo (&msg, &me->dpb_info);
 ERROR (sts, msg, "wakeup, EMdpb_getinfo");

 gr$get_associative_flag( buffer = &me->associative_flag );
 
 if( me->associative_flag )
   GRdisplay_associative_button(TRUE);

 wrapup:
   return(sts);
}

method execute(int *response; char *response_data; int pos)
{

 struct GRvg_construct            construct_list;
 struct EMSmkf_grouping_info      grp_info;
 struct GRevent                   event, accept_event;
 struct GRlc_locate               attributes;
 struct EMSpartolbasis            partolbasis;
 struct IGResbs                   class_attr;
 OM_S_CHANSELECT                  to_owners;

 OM_S_CLASSLIST rtree_classes, elig_classes;
 OMuword        rclass, eliclass;

 IGRchar        locate_prompt[52], accept_prompt[52], relocate_prompt[52];
 IGRushort      deactivate_option;
 IGRboolean     world_flag, is_lp_org;
 IGRint         size, object_was_located, display_flag, mask, 
                sts = OM_S_SUCCESS, cur_entry;
 IGRint         locate_mask, accept_mask, i, j, token;
 IGRint   EFgrp_ambiguous_loops();
 IGRlong        number_of_points = 0, number_of_bad_curves = 0, msg,
                bad_curve_indices[50], *lps_grp = NULL, sender_lp_gr;
 GRobjid        gr1_lp_to_connect, gr2_lp_to_connect;
 IGRpoint       *points = NULL;
 enum  GRdpmode DisplayMode;

  extern  void           EMownercomp_free();
  extern void   EMsfintedpar_free();

#define NUM_TOKENS 4

/* */ static /* */ int Tokens[NUM_TOKENS] =

{
   EX_BACK_UP, DATA, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
};

 size = sizeof(event);

 ex$message(msgnumb = EM_M_MakeFace);
 EMmake_chanselect(GRconnector_to_owners, &to_owners);

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

     case 0:
      ME.super_cmd->state = 1;

     /*
      * Get the surface
      */

     case 1: 

      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      ex$message(msgnumb = EMS_P_00031, buff = locate_prompt); 
      ex$message(msgnumb = EMS_P_AccFirBound, buff = accept_prompt);
      ex$message(msgnumb = EMS_I_00011, buff = relocate_prompt);
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY;
      attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP | LC_LOCALMOD | 
                                LC_NO_REF_HEADER | LC_REF_OBJECTS; 
      strcpy(attributes.classes, "EMSsurface");

      rtree_classes.w_count = 1;
      elig_classes.w_count = 1;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
      rclass = OPP_EMSsubbs_class_id;
      eliclass = OPP_EMSsubbs_class_id;
      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = &eliclass;

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

      if (!object_was_located)
      {
        if (me->locate_event.response == EX_BACK_UP)
          ME.super_cmd->state = 0;
        else
          return(OM_S_SUCCESS);
      }
      else
      {

        me->srf_info = accept_event.located_object[0];
        sts = dp$erase_hilite(msg = &msg);
        ERROR(sts, msg, "erase_hilite error")

        /*
         * get the active solid id from the state tree
         */

        sts = om$send (msg = message EMSsurface.EMgetactiveid (&msg,
                             &me->active_state_GRid, NULL),
                       targetid = me->srf_info.located_obj.objid,
                       targetos = me->srf_info.located_obj.osnum);
        ERROR(sts, msg, "EMgetactiveid error")

        sts = ex$putque(msg = &msg, response = response,
                        byte = (IGRlong *) &size, 
			buffer = (IGRchar *)&accept_event.event);
        ERROR(sts, msg, "ex$putque error")

        ME.super_cmd->state = 2;
      }
      break;


     /*
      * Loop around until all curves have been input
      */

     case 2: 

      display_flag = ALL_WINDOWS | 
                     ELEM_HILIGHT | 
                     NO_PROJ_ACCEPT_POINT | 
                     ACC_REJ_CYCLE;  /* Go through accept reject cycle.
                                        Added to fix TR90N1034         */
      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
      accept_mask = GRm_DATA;

      if (me->numcrv) 
	ex$message(msgnumb = EMS_P_IdentBound, type = "%d",
		var = `me->numcrv + 1`, buff = locate_prompt)
      else
	ex$message(msgnumb = EMS_P_IdentBound1, buff = locate_prompt)
      ex$message(msgnumb = EMS_P_AccWtNextBoundary, buff = accept_prompt); 
      ex$message(msgnumb = EMS_P_BoundaryNotFound, buff = relocate_prompt);  
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
      attributes.owner_action = LC_RIGID_COMP | LC_RIGID_OWNER |
                                LC_FLEX_COMP | LC_NO_REF_HEADER |
                                LC_REF_OBJECTS;  
      strcpy(attributes.classes, "GRbspline");
      rtree_classes.w_count = 1;
      elig_classes.w_count = 1;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
      rclass = OPP_GRbspline_class_id;
      eliclass = OPP_GRcurve_class_id;
      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = &eliclass;

      {
       extern      IGRlong EFlocate_action_handler();
       struct      EMSaction_handler already_located;
       IGRint      inx;
       IGRboolean  use_act = TRUE;

       if(me->numcrv > RLW_STACK_SIZE)
        use_act = FALSE;

       if(use_act)
        {
         already_located.next = NULL;
         already_located.option = 0;  /* Do not locate objects in the list*/
         already_located.type = 0; /* array of GRlc_info pointers */
         already_located.num_objects = me->numcrv;
         for(inx=0; inx<me->numcrv; inx++)
          already_located.objects.lc_info[inx] = &me->locobj[inx];
        }

       lc$locate(rc = &object_was_located, event1 = &me->locate_event, 
                event2 = &accept_event, mask1 = locate_mask, 
                mask2 = accept_mask, eventsize= &size, 
                display_flag = display_flag, response = response, 
                response_data = response_data, 
                locate_prompt = locate_prompt, 
                acc_prompt = accept_prompt,
                relocate_prompt = relocate_prompt, 
                attributes = &attributes, 
                act_handler = use_act ? EFlocate_action_handler : NULL,
                act_args = use_act ? &already_located : NULL,
                stack = &me->locate_stack, 
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);
      }
 	ex$message(msgnumb = EMS_I_ClearStatusField);

      if (!object_was_located)
       {
        if (me->locate_event.response == EX_BACK_UP)
         {
          if (me->numcrv)
           {
            DisplayMode = GRbdhe;
            sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
               &me->locobj[me->numcrv - 1].module_info.md_env.matrix_type,
                 me->locobj[me->numcrv - 1].module_info.md_env.matrix, 
                 &DisplayMode,
                 &me->ModuleInfo.md_id),
                 targetid = me->locobj[me->numcrv - 1].located_obj.objid,
                 targetos = me->locobj[me->numcrv - 1].located_obj.osnum);
            me->numcrv--;
           }
          else
           {
             ME.super_cmd->state = 1;
           }
         }
        else if (me->locate_event.response == EX_RJT_MOVEON)
         {
          if (me->numcrv) ME.super_cmd->state = 3;
          me->process_phase = EMS_PROCESS_PHASE1;
         }
        else
         return(OM_S_SUCCESS);
       }
      else
       {
         OMuint  vla_size;
         struct GRid owner;
         IGRint inx;

         /* Make sure the owner composite curve has not already been
            located.
         */
         owner.objid = NULL_OBJID;
         sts = om$get_objid_at_index(
               objid = accept_event.located_object[0].located_obj.objid, 
               osnum = accept_event.located_object[0].located_obj.osnum, 
               p_chanselect = &to_owners, index = 0, objidaddr = &owner.objid, 
               osnumaddr = &owner.osnum);
         if(!IF_NULL_OBJID(owner.objid))
          {
	   for(inx = 0; inx<me->numcrv; inx++)
	    {
	     if(IF_EQ_GRID(me->locobj[inx].located_obj, owner))
	      {
	       ex$message(msgnumb = EMS_I_CvAlreadyLocated);
               return(OM_S_SUCCESS);
              }
	    }
          }
         else sts = OM_S_SUCCESS;

         /*
          * Check if enough space is available to save
          * the located boundary.
          */

         vla_size = om$dimension_of (varray = me->locobj);

         if ((me->numcrv + 1)  > vla_size)
          {
           sts = om$vla_set_dimension (varray = me->locobj,
                                        size = vla_size + INCREMENT);
           ERROR (sts, 1, "vla_set_dimension")
          }
     
         me->locobj[me->numcrv] = accept_event.located_object[0];
         me->numcrv++;

         size = sizeof(accept_event.event) + sizeof (IGRint); 
         sts = ex$putque(msg = &msg, response = response,
                        byte = (IGRlong *) &size, 
			buffer = (IGRchar *)&accept_event.event);
         ERROR(sts, msg, "ex$putque error")
       }
      break;

    /*
     * make a new face using imposed boundaries
     */

     case 3:

      ex$message(msgnumb = EMS_P_ClearPromptField);
      ex$message(msgnumb = EMS_S_ProcessingOne);
      ex$message(msgnumb = EMS_S_ProcessingTwo);

      number_of_points = 0;
      points = NULL;
      number_of_bad_curves = 0;

      {
         construct_list.newflag = FALSE;
         construct_list.display = &ME.CObuild->ActiveDisplay;
         construct_list.geometry = NULL;
         class_attr.u_rules = (IGRlong) me->dpb_info.u_rules;
         class_attr.v_rules = (IGRlong) me->dpb_info.v_rules;
         class_attr.is_polydis = me->dpb_info.props &
                                 EMDPB_POLYGON_DISPLAY_ON; 
         class_attr.is_surfdis = TRUE; 
         class_attr.is_slowdis = FALSE;
         construct_list.class_attr = (IGRchar *) &class_attr;
         construct_list.msg = &msg;
         construct_list.env_info = &me->srf_info.module_info;
         construct_list.level = ME.CObuild->ActiveLevel;
         construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
         construct_list.name = NULL;
/*
 * This function creates the associative make face object.
 * Need to take a decision on whether to support grouping ambiguous loops.
 */

/* **************************** EMS 2.0 ************************* */

         me->mkface_obj_GRid.objid = NULL_OBJID;
/*****************************************************************************
         sts = EFmake_face(&msg, 
                           NULL,
                           me->numcrv,me->locobj,
                           &me->srf_info,
                           &construct_list,
                           &me->mkface_obj_GRid,
                           (me->associative_flag ) ? 
                            NULL : EFfunc_PLACE_NON_ASSOC);
*****************************************************************************/
         sts = ems$make_face(msg = &msg,
                             num_curves = me->numcrv,
                           curve_info = me->locobj,
                  face_info = &me->srf_info,
                  construction_list = &construct_list,
                  resultant_obj = &me->mkface_obj_GRid,
    general_options = (me->associative_flag ) ? NULL : EFfunc_PLACE_NON_ASSOC);           

/* *************************************************************** */

         /*
          * Check if some more user input is needed for grouping
          * ambiguous loops.
          */

         if ( (1&sts) && msg == EMS_I_NeedGrpInfo)
         {
           msg = EMS_S_Success;
           ME.super_cmd->state = 4;
           break;  
         }
           
         /*
          * If make face failed, try to disect the return
          * code and let the user informed about the cause
          */

         if (!(1&sts&msg))
         {
            switch (msg)
            {
               case EMS_E_NoValidBnd:
		 ex$message(msgnumb = EMS_S_NoValBndToImp);
                 break;
 
               case EMS_E_NoTrimBnd:
		 ex$message(msgnumb = EMS_S_NoValTrimBnd);
                 break;
 
               case  EMS_E_MkfCollapse:
		 ex$message(msgnumb = EMS_S_MkFaceColError);
                 break;
 
               case EMS_E_MkfGrouping:
		 ex$message(msgnumb = EMS_S_MkFaceGrpError);
                 break;

               case EMS_E_MkfGrExit:
	         ex$message(msgnumb = EMS_S_ModCouNotBeRec);
	         break;

	       default:
	         ex$message(msgnumb = EMS_S_ModelIsRec);
	         break;
	

            } /* switch (msg) */

/******************* SM 2/10/93                        
            if (msg == EMS_E_MkfGrExit)
	      ex$message(msgnumb = EMS_S_ModCouNotBeRec)
            else
            {
	      ex$message(msgnumb = EMS_S_ModelIsRec);
            }
***************** End SM 2/10/93 ********/

            ME.super_cmd->state = 0;
            me->numcrv = 0;
            break;  
       } /* if (!(1&sts&msg) */
  
         ERROR(sts, msg, "GRdisplay error")
       }

      ex$message(msgnumb = EMS_S_Processing);
      ME.super_cmd->state = 5;
      break;

      /*
       * If more user input is needed in resolving the ambiguous loops,
       * do so.
       */

      case 4:

       ex$message(msgnumb = EMS_S_NeedMoInpForGrp);

       lps_grp = (IGRlong *) om$malloc (size = grp_info.num_amb_lps *
                             sizeof(IGRlong));
       if (!lps_grp) ERROR (0, 1, "lps_grp malloc error");

       /*
        * Dehilite the the curves as they may interfere with
        * the highlighted loops during grouping process.
        */
       
       DisplayMode = GRbdhe;

       for (i = 0; i < me->numcrv; i++)
       {
          sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &me->locobj[i].module_info.md_env.matrix_type,
                me->locobj[i].module_info.md_env.matrix, 
                &DisplayMode,
                &me->ModuleInfo.md_id),
                targetid = me->locobj[i].located_obj.objid,
                targetos = me->locobj[i].located_obj.osnum);
           ERROR(sts, msg, "GRdisplay error")
       }
       
       /*
        * draw the surface in background.
        */
/************************
      DisplayMode = GRbd; 
      sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
              &me->srf_info.module_info.md_env.matrix_type,
              me->srf_info.module_info.md_env.matrix,
              &DisplayMode, &me->ModuleInfo.md_id),
            targetid = me->srf_info.located_obj.objid,
            targetos = me->srf_info.located_obj.osnum);
       ERROR(sts, msg, "GRdisplay error")
************************/

       sts = EFgrp_ambiguous_loops (&msg, grp_info.amb_lps,
                  grp_info.num_amb_lps, lps_grp,
                  me->srf_info.located_obj, 
                  &me->srf_info.module_info, &accept_event, response, 
                   response_data);
       if (!(1&sts&msg)) ERROR (sts, msg, "EFgrp_ambiguous_loops error");

       /*
        * Highlight the curves again.
        */

       DisplayMode = GRhd;

       if (accept_event.response == EX_BACK_UP)
         me->numcrv--;

       for (i = 0; i < me->numcrv; i++)
       {
          sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &me->locobj[i].module_info.md_env.matrix_type,
                me->locobj[i].module_info.md_env.matrix, 
                &DisplayMode,
                &me->ModuleInfo.md_id),
                targetid = me->locobj[i].located_obj.objid,
                targetos = me->locobj[i].located_obj.osnum);
           ERROR(sts, msg, "GRdisplay error")
       }
       

       switch (accept_event.response)
       {
         case EX_DATA:
         case EX_RJT_MOVEON:

            /*
             * Based upon the ambiguous loops groups', connect
             * them and their complements to gr1_ls_id and gr2_ls_id
             */

            gr1_lp_to_connect = grp_info.gr1_ls_id;
            gr2_lp_to_connect = grp_info.gr2_ls_id;

            for (i = 0; i < grp_info.num_amb_lps; i++)
            {
              sender_lp_gr = (lps_grp[i] == EMS_MKFACE_GROUP1) ?
                             EMS_MKFACE_GROUP1 : EMS_MKFACE_GROUP2;
              
              sts = om$send (msg = message EMSloop.EMgroup_loops (&msg,
                              gr1_lp_to_connect, gr2_lp_to_connect,
                              NULL, sender_lp_gr),
                             targetid = grp_info.amb_lps[i],
                             targetos = me->srf_info.located_obj.osnum);
              ERROR (sts, msg, "EMSloop.EMgroup_loops error")

            } /* for (i = 0; i < grp_info.num_amb_lps; i++) */

            ME.super_cmd->state = 3;
            me->process_phase = EMS_PROCESS_PHASE2;
            break;

         case GR_UNKNOWN_TYPE:
         case EX_BACK_UP:

          /*
           * Recover the model back.
           */

          world_flag = TRUE;

          partolbasis.in_world = TRUE;
          partolbasis.is_valid = TRUE;
          partolbasis.mattyp=&me->srf_info.module_info.md_env.matrix_type;
          partolbasis.mat = me->srf_info.module_info.md_env.matrix;

          sts = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                          &me->srf_info.module_info.md_env.matrix_type,
                           me->srf_info.module_info.md_env.matrix,
                          &world_flag, FALSE, &partolbasis.tol),
                         senderid = my_id,
                         targetid = me->srf_info.located_obj.objid,
                         targetos = me->srf_info.located_obj.osnum);
          ERROR (sts, msg, "EMSsubbs.EMpartolbasis");

          sts = om$send (msg = message EMSsfmkface.EMgraceful_exit (
                          &msg, &partolbasis, &me->srf_info.module_info,
                          grp_info.loops_trim_info, 
                          grp_info.num_trim_info, NULL, NULL, 
                          grp_info.gr1_ls_id, grp_info.gr2_ls_id,
                          me->srf_info.located_obj, grp_info.sf_org_ls,
                          grp_info.sf_org_lps, grp_info.num_sf_org_lps,
                          NULL_OBJID, EMS_DO_DISPLAY),
                        targetid = me->mkface_obj_GRid.objid,
                        targetos = me->mkface_obj_GRid.osnum);
           ERROR (sts, msg, "EMgraceful_exit error");

           /*
            * delete the ambiguous loops that were not
            * part of the original loopset.
            */

           for (i = 0; i < grp_info.num_amb_lps; i++)
           {
             is_lp_org = FALSE;
             cur_entry = 0;
             do
             {
               if (grp_info.amb_lps[i] == grp_info.sf_org_lps[cur_entry])
                  is_lp_org = TRUE;
               else cur_entry++;
             } while (cur_entry < grp_info.num_sf_org_lps &&
                      !is_lp_org);

             if (!is_lp_org)
             {
               sts = om$send (msg = message Root.delete(1),
                         targetid = grp_info.amb_lps[i],
                         targetos = me->srf_info.located_obj.osnum);
               ERROR (sts, 1, "Root.delete error");

             } /* if (!is_lp_org) */

           } /* for (i = 0; i < grp_info.num_amb_lps; i++) */
       
           /*
            * free memory
            */
      
           if (grp_info.amb_lps) om$dealloc (ptr = grp_info.amb_lps);
           if (grp_info.sf_org_lps) om$dealloc (ptr=grp_info.sf_org_lps);
           if (grp_info.sf_lps_removed) 
                   EMownercomp_free (grp_info.sf_lps_removed, NULL);
           if (grp_info.new_lps_added) 
                     om$dealloc (ptr = grp_info.new_lps_added);
           if (grp_info.loops_trim_info)
           {
               for (i = 0; i < grp_info.num_trim_info; i++)
                   EMsfintedpar_free(grp_info.loops_trim_info[i],2);
        
               om$dealloc(ptr = grp_info.loops_trim_info);
           }
           
           if (accept_event.response == EX_BACK_UP)
           {
             ME.super_cmd->state = 2;
           }
           else
           {
               ME.super_cmd->state = 3;
               me->process_phase = EMS_PROCESS_PHASE1;
              return(OM_S_SUCCESS);
           }

           break;
         
         default:
           ERROR (OM_E_ABORT, msg, "something got screwed up"); 
    
       } /* switch (*response) */

       break;

     /*
      * Unhighlight the boundaries and redraw the active state object
      * and newly constructed mkface_object. Ask the user if
      * the newly constructed object to be added to the 
      * state tree.
      */

     case 5:

      ex$message(msgnumb = EMS_S_ProcessingFour);
      DisplayMode = GRbdhe;

      for (j = 0, i = 0; i < me->numcrv; i++)
      {
        if ((number_of_bad_curves == 0) ||
            ((j < number_of_bad_curves) &&
             (bad_curve_indices[j] != i )))

         {
          sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &me->locobj[i].module_info.md_env.matrix_type,
                me->locobj[i].module_info.md_env.matrix, 
                &DisplayMode,
                &me->ModuleInfo.md_id),
                targetid = me->locobj[i].located_obj.objid,
                targetos = me->locobj[i].located_obj.osnum);
           ERROR(sts, msg, "GRdisplay error")
         }
        else            /* Bad curve was found */
         j++;
       }

      /*
       * draw the face of the active state object and the newly constructed
       * mkface object
       */

      ME.super_cmd->state = 6;

      if (number_of_points)
       {
        IGRlong EMoutput_point();
        struct  GRid *point_ids = NULL;

        point_ids = (struct GRid *) 
          malloc(number_of_points * sizeof(struct GRid));
         if (!point_ids) ERROR(0, MANOMEMORY, "Malloc error")

        construct_list.msg = &msg;
        construct_list.env_info = &ME.CObuild->ModuleInfo;
        construct_list.newflag = FALSE;
        construct_list.geometry = NULL;
        construct_list.class_attr = NULL;
        construct_list.level = ME.CObuild->ActiveLevel;
        construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        construct_list.display = &ME.CObuild->ActiveDisplay;
        construct_list.name = NULL;

        sts = EMoutput_point(&msg, my_id, &construct_list, 
                              number_of_points, points, point_ids);
        ERROR(sts, msg, "LOCAL_DISPLAY error")

        free(points);
        DisplayMode = GRbd;

        for (i = 0; i < number_of_points; i++)
        {
          sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                &ME.CObuild->ModuleInfo.md_env.matrix_type,
                ME.CObuild->ModuleInfo.md_env.matrix, 
                &DisplayMode,
                &ME.CObuild->ModuleInfo.md_id),
                targetid = point_ids[i].objid);
          ERROR(sts, msg, "GRdisplay error")
        }
        free(point_ids);
       }

      if (number_of_points || number_of_bad_curves)
	 ex$message(msgnumb = EMS_S_ProbAreaDis)
      else
 	 ex$message(msgnumb = EMS_I_ClearStatusField)

      break;

     case 6:

       /*
        * ask if the newly constructed dpr make-face
        * object is to be added to the state tree ?
        */

       ex$message(msgnumb = EMS_P_AccBackMove);

       mask = GRm_BACK_UP | GRm_DATA | GRm_RJT_MOVEON;
       token = GRget_token(&sts, Tokens, &mask, &me->locate_event, &size, 
                           response, response_data);

       ERROR(sts,1, "GRget_token error")

       if (Tokens[token] == GR_UNKNOWN_TYPE || Tokens[token] == DATA)
       {

         me->numcrv = 0;
         me->state = 0;

 	 ex$message(msgnumb = EMS_P_ClearPromptField);

#if ASSOC_DIDNT_ADD_IT
         add_option = EMS_DO_DISPLAY;
         sts = om$send(msg = message EMSsfdpr.EMadd(&msg, 
                             &me->active_state_GRid, NULL,
                             &me->srf_info.module_info, &add_option),
                       targetid = me->mkface_obj_GRid.objid,
                       targetos = me->mkface_obj_GRid.osnum);
         ERROR(sts, msg, "exec, EMadd");
#endif

 	 ex$message(msgnumb = EMS_I_ClearStatusField);

         if (Tokens[token] == DATA)
         {
           IGRlong qsize = sizeof(me->locate_event.event);  /*DECL*/

           /*Place accept event on the software stack*/
           sts = ex$putque(msg = &msg, 
                           response = response, 
                           byte = &qsize,
                           buffer = (IGRchar *) &me->locate_event.event);
           ERROR(sts, EMS_S_Success, "put que");
         }
         else return(sts);

        }
       else
       if (Tokens[token] == EX_BACK_UP || Tokens[token] == EX_RJT_MOVEON)
        {               
           GRobjid *display_ids = NULL;
           IGRint display_count = 0;


           sts = dp$erase_hilite(msg = &msg);
           ERROR(sts, msg, "erase_hilite");

           /*
            * send deactivate message to the make face dpr object
            */
#if ASSOC_NOT_HERE
           deactivate_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY |
                               EMS_DELETE_DPR;  
           sts = om$send(msg = message EMSdpr.EMdeactivate(&msg,
                               &deactivate_option,
                               &me->srf_info.module_info, &display_ids, 
                               &display_count),
                         targetid = me->mkface_obj_GRid.objid,
                         targetos = me->mkface_obj_GRid.osnum);
#else
           {
             IGRint invoke_cnt=0;
       
             deactivate_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
             sts = om$send(msg = message EMSdpr.EMundo(&msg,
                                     &deactivate_option,
                                     &me->srf_info.module_info,
                                     NULL,
                                     NULL,
                                     NULL,  
                                     &display_ids,
                                     &display_count,
                                     &invoke_cnt),
                           targetid = me->mkface_obj_GRid.objid,
                           targetos = me->mkface_obj_GRid.osnum);
           }
#endif
           ERROR(sts, msg, "EMdeactivate error")

/*
           DisplayMode = GRbd;

           for (i=0; i<display_count; i++)
           {
             if (om$is_objid_valid(
                 objid = display_ids[i],
                 osnum = me->srf_info.located_obj.osnum) == OM_S_SUCCESS)
             {
               sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                              &me->srf_info.module_info.md_env.matrix_type, 
                              me->srf_info.module_info.md_env.matrix, 
                              &DisplayMode, 
                              &me->ModuleInfo.md_id),
                             targetid = display_ids[i],
                             targetos = me->srf_info.located_obj.osnum);
               ERROR(sts, msg, "display");
             }
           }     

           if (display_ids) om$dealloc(ptr = display_ids);

*/
           if (Tokens[token] == EX_RJT_MOVEON)
           {
             ME.super_cmd->state = 0;

             /*
              * Dehilite the bad curves
              */

             DisplayMode = GRbdhe;
             for (i = 0; i < me->numcrv; i++)
             {
               sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                          &me->locobj[i].module_info.md_env.matrix_type,
                          me->locobj[i].module_info.md_env.matrix, 
                          &DisplayMode,
                          &me->ModuleInfo.md_id),
                       targetid = me->locobj[i].located_obj.objid,
                       targetos = me->locobj[i].located_obj.osnum);
                ERROR(sts, msg, "GRdisplay error")
             }

             me->numcrv = 0;
 	     ex$message(msgnumb = EMS_I_ClearStatusField);

           } /* if (Tokens[token] == EX_RJT_MOVEON) */
           else
           {
             me->numcrv--;
           
             /*
              * highlight the good curves again
              */
 
             DisplayMode = GRbdhd;
             for (j = 0, i = 0; i < me->numcrv; i++)
             {
               if ((number_of_bad_curves == 0) ||
               ((j < number_of_bad_curves) &&
                (bad_curve_indices[j] != i )))

               {
                 sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                   &me->locobj[i].module_info.md_env.matrix_type,
                   me->locobj[i].module_info.md_env.matrix, 
                   &DisplayMode,
                   &me->ModuleInfo.md_id),
                 targetid = me->locobj[i].located_obj.objid,
                 targetos = me->locobj[i].located_obj.osnum);
                ERROR(sts, msg, "GRdisplay error")
               }
               else            /* bad curve was found */
               j++;
             }

             DisplayMode = (bad_curve_indices[number_of_bad_curves-1] ==
                            me->numcrv ) ? GRbdhe : GRbd;

             sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                   &me->locobj[me->numcrv].module_info.md_env.matrix_type,
                   me->locobj[me->numcrv].module_info.md_env.matrix, 
                   &DisplayMode,
                   &me->ModuleInfo.md_id),
                 targetid = me->locobj[me->numcrv].located_obj.objid,
                 targetos = me->locobj[me->numcrv].located_obj.osnum);
              ERROR(sts, msg, "GRdisplay error")
 
            me->state = 2;

           } /* else for if (Tokens[token] == EX_RJT_MOVEON) */

       }    

       break;

      /*       
       * Something has messed up our state table
       */

     default:
      ERROR(OM_E_ABORT, 0, "Default state reached")

    }

  }
 while(TRUE);

 wrapup:
  *response = TERMINATE;
  return(sts);
}
/* ADDED FOR EMS 2.0 *************************** */

EFclassify_obj_type(EMmsg,obj_type,grid)
IGRlong *EMmsg;
IGRint *obj_type;
struct GRid *grid;
{
 IGRlong OM_stat;
 OMuword Class_id;
 extern OMuword OPP_EMSsolid_class_id;

 *EMmsg = EMS_S_Success;

 OM_stat = om$get_classid (objid = grid->objid, p_classid = &Class_id,
                           osnum = grid->osnum);
 ERROR(OM_stat, 1, "getclassid")

 OM_stat = om$is_ancestry_valid (subclassid = Class_id,
                      superclassid = OPP_EMSsolid_class_id);
 ERROR(OM_stat, 1, "is ancestry valid")

 if (OM_stat == OM_S_SUCCESS)
 {
   *obj_type = 1;
 }
 else
 if (OM_stat == OM_I_INVANCESTRY)
 {
  *obj_type = 0;
 }

wrapup:
 return (OM_stat);
}
end implementation ECmkface;

/*
 Code removed for EMS 2.0:
         sts = om$send(msg = message EMSsurface.EMmake_face(&msg, 
                               message EMSsfmkface.EMmake_face_execute(&msg,
                                me->srf_info.located_obj,
                                &me->srf_info.module_info, 
                                me->numcrv, me->locobj, &construct_list, 
                                &number_of_points, &points, TRUE,
                                &number_of_bad_curves, bad_curve_indices,
                                TRUE, me->process_phase, 
                                (IGRchar *) &grp_info,
                                EMS_DO_DISPLAY, NULL, NULL),
                             &me->mkface_obj_GRid),
                       targetid = me->active_state_GRid.objid,
                       targetos = me->active_state_GRid.osnum);
*/
