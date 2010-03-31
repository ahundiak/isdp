/* ###################   APOGEE COMPILED   ################## */

class implementation ECintf;

#include "EMS.h"
#include "RAPdefs.h"

/*
DESCRIPTION

RETURN VALUES
        Response contains information for the command server.
        If response is TERMINATE then the command is deleted by
        the command server.

HISTORY
   Tapadia 5/22/92 	Modified for message sub system compliance
   Sudha   7/05/93      Modified for BSprototypes ansification
   scw    08/14/94      clarified sleep method
*/

# ifndef DEBUG
# define DEBUG 0
# endif

/* mytypes.
*/
#define Intf		0
#define IntfXsec	1
#define IntfBxsec	2
#define IntfToggleWrite 3
#define IntfBatch	4

#include <stdio.h>
#include "codef.h"
#include "ECdlb.h"
#include "igr.h"
#include "igrtypedef.h"
#include "griodef.h"
#include "exdef.h"
#include "EMSmsgdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSlmdef.h"
#include "grgsdef.h"    /* Needed for the macros */
#include "grgsmacros.h" /* gr$gsput_locate_criteria() */
#include "EC_M.h"       /* Command strings */
#include "EC_I.h"       /* Status strings */
#include "EC_P.h"       /* Prompt strings */
#include "EC_F.h"       /* Error box strings */
#include "EC_E.h"       /* Error strings */
#include "EMSaction.h"  /* Structure definition for select handler */
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSintf.h"
#include "bserr.h"
#include "bsparameters.h"
#include "madetplan.h"
#include "bsdistnct2.h"

/* AND, ISNT ... */
# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif
                                        
#if DEBUG
#define ERRORs(sts_stupid, error_number, error_message, label)\
 {\
        if (EMSmsgReport (sts_stupid, error_message, FALSE) OR \
                EMSmsgReport (error_number, error_message, FALSE)) \
                goto label; \
 }
#else
#define ERRORs(sts_stupid, error_number, error_message, label)\
 {\
  if (! (1 & sts_stupid)) goto label;\
 }
#endif

from GRgraphics         import GRdisplay;
from EMSsurface		import EMshow_normals, EMrevorient, 
			       EManalyzeIntfAlongXsec;
from RAPinlisnr         import finish;

extern OMuword OPP_EMSsurface_class_id, OPP_GRvg_class_id, 
               OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id, 
	       OPP_GRowner_class_id, OPP_GRcurve_class_id, 
	       OPP_EMSplane_class_id, OPP_GRsvset_class_id, 
	       OPP_ACncpx_class_id, OPP_GRclhdr_class_id, OPP_GRsmhdr_class_id;
	
extern IGRboolean EMSintfWriteFlag;

method init (IGRint type; IGRchar *string)
{
 IGRlong sts;

 sts = om$send(mode = OM_e_wrt_message, 
	       msg = message COconst.init(type, string), 
	       targetid = my_id);
	
 me->num_located = 0;
 me->num_ornted = 0;
 me->num_sets = 0;
 me->add_to_set = FALSE;
 me->stdreportonly = FALSE;
 me->nocurves = TRUE;
 me->novol = TRUE;
 me->noarea = TRUE;
 me->plpts_input = FALSE;
 return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
 enum GRdpmode Display_Mode = GRhhd;
 IGRint  sts=OM_S_SUCCESS,i;
 IGRlong msg=EMS_S_Success;

 if (me->num_located)
 { 
   for (i = 0; i < me->num_located; i++)
   { 
     sts = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(&msg, 
                        /*&me->locate_info[i].module_info.md_env.matrix_type, 
                        me->locate_info[i].module_info.md_env.matrix, */
			&me->ModuleInfo.md_env.matrix_type, 
			me->ModuleInfo.md_env.matrix, 
                        &Display_Mode, 
			&me->ModuleInfo.md_id
                        /*&me->locate_info[i].module_info.md_id*/),
                   targetid = me->locate_info[i].located_obj.objid, 
                   targetos = me->locate_info[i].located_obj.osnum);
     ERRORs(sts, msg, "ECintf_wake draw hi", wrapup);
   }
 }
 if(ME.super_cmd->mytype == Intf)
  {
   ex$message(msgnumb = EM_M_AnalyzeInterference)
  }
 else if(ME.super_cmd->mytype == IntfXsec)
  {
   ex$message(msgnumb = EM_M_AnalyzeIntfXsec)
  }
 else if(ME.super_cmd->mytype == IntfBxsec)
  {
   ex$message(msgnumb = EM_M_AnalyzeIntfBxsec)
  }
 else if(ME.super_cmd->mytype == IntfToggleWrite)
  {
   ex$message(msgnumb = EM_M_TogIntCurWrite)
  }
 else if(ME.super_cmd->mytype == IntfBatch)
  {
   ex$message (msgnumb = (ex$is_batch()) ? 
			 EM_M_AnalyzeIntfBatch : EM_M_AnalyzeIntfPBatch);
  }

wrapup:
  return(sts);
}


method super_cmd.sleep(int pos)
{
 IGRint  sts=OM_S_SUCCESS;
 IGRlong msg=EMS_S_Success;

 sts = dp$erase_hilite(msg = &msg);
 ERRORs(sts, msg, "ECintf_sleep erase hi", wrapup);

 ex$message(msgnumb = EM_M_ClearMessageField)
 ex$message(msgnumb = EMS_I_00000)
 ex$message(msgnumb = EMS_P_00000)

 wrapup:
  return(sts);
}

method delete(int f_defer_flag)
{
  IGRint  i, sts;
  IGRlong msg;

  for (i=0; i<me->num_located; i++)
   if (me->reversed[i])
    {
     sts = om$send (msg = message EMSsurface.EMrevorient (&msg),
               targetid = me->locate_info[i].located_obj.objid, 
               targetos = me->locate_info[i].located_obj.osnum); 
     me->reversed[i] = FALSE;
    }
  
  sts = om$send(mode = OM_e_wrt_message,
                msg = message COconst.delete(NULL),
                targetid = my_id);
  ERROR(sts, EMS_S_Success, "ECbool_delete delete", wrapup);

 wrapup:
  return(sts);
}


method execute(int *response; char *response_data; int pos)
{
 IGRboolean	       sfintf;
 IGRchar	       loc_prompt[GR_MAX_CHAR], acc_prompt[GR_MAX_CHAR];
 IGRchar	       reloc_prompt[GR_MAX_CHAR], elemtype[GR_MAX_CHAR];
 IGRint                sts, display_flag;
 IGRlong               msg;
 IGRlong               size=sizeof(struct GRevent);
 IGRint                locate_mask, accept_mask, token = 0, i, j;
 IGRint                num_loc_sets, num_sets, *num_in_set;
 enum     GRdpmode     Display_Mode;
 struct   GRlc_locate  attr;
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 OMuword               rclass, eliclass[2];
 struct GRlc_info      *obj_infos, *set_info;
 IGRboolean  	       status;
 IGRlong     	       loc_msg, num_pnts = 3;
 extern IGRint	       ECdisplayPointSetByBuffer(); 
 void		       EMstop_record();
 extern IGRlong	       EManalyzeIntf();

#   define NUM_TOKENS 6
    /* */ static /* */ int Tokens[NUM_TOKENS] =
    {
        EX_BACK_UP, DATA, EX_OBJID, STRING, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
    };

    enum actions
    {
         NIL, ERR, init, rem_obj, store_obj, dummy, dummy1
    };

#   define NUM_STATES 10
    enum states
    {
        plpt1, plpt2, plpt3, start, filename, ask_cv, ask_vol, ask_ort, 
	ask_area, analyze
    };

    static enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:        BACK_UP DATA      OBJ    STRING   MOVEON      UNK
    old state: */                                   
    /* plpt1 */	     {plpt1, plpt2, plpt1, plpt1, plpt1, plpt1}, 
    /* plpt2 */	     {plpt1, plpt3, plpt2, plpt2, plpt2, plpt2},
    /* plpt3 */	     {plpt2, start, plpt3, plpt3, plpt3, plpt3},	
    /* start    */   {start, start,    start,  start,   start,    start},
    /* filename */   {start, filename, filename, ask_cv, ask_cv,  filename}, 
    /* ask_cv */     {filename, ask_cv, ask_cv, ask_vol, ask_vol, ask_cv}, 
    /* ask_vol */    {ask_cv, ask_vol, ask_vol, ask_ort, ask_ort, ask_vol}, 
    /* ask_ort */    {ask_ort, ask_ort, ask_ort, ask_ort, ask_ort, ask_ort},
    /* ask_area*/    {filename, ask_area, ask_area, analyze,analyze,ask_area}, 
    /* analyze */    {plpt1, plpt1,    plpt1,  plpt1,   plpt1,    plpt1}
    };

    static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:      BACK_UP   DATA      OBJ       STRING       MOVEON   UNK
    old state: */
    /* plpt1 */    {NIL,      NIL,      NIL,       NIL,     NIL,     NIL}, 
    /* plpt2 */    {NIL,      NIL,      NIL,       NIL,     NIL,     NIL}, 
    /* plpt3 */    {NIL,      NIL,      NIL,       NIL,     NIL,     NIL}, 
    /* start    */ {rem_obj, store_obj, store_obj, store_obj,   dummy,   NIL},
    /* filename */ {NIL,      NIL,      NIL,       NIL,     NIL,     NIL}, 
    /* ask_cv */   {NIL,      NIL,      NIL,       NIL,     NIL,     NIL}, 
    /* ask_vol */  {NIL,      NIL,      NIL,       NIL,     NIL,     NIL}, 
    /* ask_ort */  {dummy1,  dummy1,   dummy1,     dummy1,  dummy1,  dummy1}, 
    /* ask_area */ {NIL,      NIL,      NIL,       NIL,     NIL,     NIL}, 
    /* analyze */  {NIL,      NIL,      NIL,       NIL,     NIL,     NIL}
    }; 

 if(ME.super_cmd->mytype == IntfToggleWrite)
  {
   EMSintfWriteFlag = !EMSintfWriteFlag;
   ex$message(msgnumb = EMSintfWriteFlag ? EMS_S_IntCurWrOn:EMS_S_IntCurWrOff); 
					
   sleep(4);
   *response = TERMINATE;
   return(OM_S_SUCCESS);
  }

 if (ME.super_cmd->mytype == Intf || ME.super_cmd->mytype == IntfBatch) 
   sfintf = TRUE;
 else
   sfintf = FALSE;

 do
 {
  sts = OM_S_SUCCESS;
  switch (ME.COconst->action)
  {
   case NIL:
   case ERR:
   case init:
   {
     break;
   }


   case rem_obj:
   {
    if (me->num_located)
    {
      struct GRlc_info *junk;
      junk = &me->locate_info[me->num_located - 1];

      if (me->num_located == 1)
      {
        sts = dp$erase_hilite(msg = &msg);
        ERRORs(sts, msg, "ECintf_exec erase hi", wrapup);
      }
      else
      {
        Display_Mode = GRhe;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
			  &me->ModuleInfo.md_env.matrix_type, 
			  me->ModuleInfo.md_env.matrix, 
			  /*
                          &junk->module_info.md_env.matrix_type,
                          junk->module_info.md_env.matrix, */
                          &Display_Mode, 
			  &me->ModuleInfo.md_id
                          /*&junk->module_info.md_id*/),
                    targetid = junk->located_obj.objid,
                    targetos = junk->located_obj.osnum);
        ERRORs(sts, msg, "ECintf_exec erase", wrapup);
      }

      if(me->reversed[me->num_located - 1])
       {
        sts = om$send (msg = message EMSsurface.EMrevorient (&msg),
               targetid = junk->located_obj.objid,
	       targetos = junk->located_obj.osnum);
        ERRORs(sts, msg, "ECintf_exec erase", wrapup);	
	me->reversed[me->num_located - 1] = FALSE;
       }

      me->num_located--;
      me->num_in_set[me->num_sets-1]--;
      if (! me->num_in_set[me->num_sets-1])
       {
       me->num_sets--;
       me->add_to_set = FALSE;
       }
     else
       me->add_to_set = TRUE;
    }
    else if(token == 0)			/* If back up */
     ME.super_cmd->state = plpt3;
    else
     {
     me->num_sets = 0;
     me->add_to_set = FALSE;
     }

    break;
   }

   case store_obj:
   {
    IGRlong             number_of_objects;
    struct              GRlc_info *objects, static_object;
    OMuword             list1[10], list2;
    OM_S_CLASSLIST      yes_classes, no_classes;
    extern              IGRlong EMselective_fence();

    number_of_objects = 0;
    objects = NULL;

    /*
     * If a set was located then decompose it into leaf nodes ensuring
     * that only surfaces and composite surfaces are present. Record the
     * object-id of the set. If the set is a fence, then put in NULL_OBJID.
     * Remove any duplicates in the set being recorded.
     */

     /* SM 2/12/93

      There seems to be some confusion over the list1 (yes classes) in
      case if sfintf is TRUE. The original code (RCS version 201.5) was
      to consider EMSsurface AND GRowner to be o.k. This was changed to
      consider EMSsurface only to fix a TR 92n3780. Doing this however
      causes VDS generated owners to become unacceptable. This new TR
      us 119300995.

      I have tried to go back to the TR 92n3780 in an effort to fix both
      problems, but noone around seems to remember exactly what the problem
      was. The TR description for 92n3780 does not help either.

      So, according to the law of minimum perturbation, I have decided to
      not add GRowner back again, but a class ACncpx. Vds owners are all
      subclassed off of ACncpx. This should make everyone happy.

      SM 2/19/93 - KLUDGE - Added another class to the yes list called
      'VRCorrection' if it is known.

      SM 3/15/93 - KLUDGE CONTINUES - Added symbols and cells. I will clean
      this up for 2.4 and put back the original GRowner class.
    */
    if (sfintf)
      {
      list1[0] = OPP_EMSsurface_class_id;
      list1[1] = OPP_ACncpx_class_id;
      list1[2] = OPP_GRclhdr_class_id;
      list1[3] = OPP_GRsmhdr_class_id;
      yes_classes.w_count = 4;	
       {
        OMuword kludge_classid;

        sts = om$get_classid(
              osnum = me->locate_event.located_object[0].located_obj.osnum,
              classname = "VRCorrection", p_classid = &kludge_classid);
        if(sts == OM_S_SUCCESS)
	  list1[yes_classes.w_count++] = kludge_classid;
        else
	  sts = OM_S_SUCCESS;
       }
      }
    else
      {
      list1[0] = OPP_EMSsurface_class_id;
      yes_classes.w_count = 1;
      }
    yes_classes.p_classes = list1;

    list2 = OPP_GRcurve_class_id;
    no_classes.w_count = 1;
    no_classes.p_classes = &list2;
    sts = EMselective_fence(
        &yes_classes,
        &no_classes,
        &me->locate_event.located_object[0],
        FALSE,
        sfintf ? FALSE : TRUE,
        my_id,
        &number_of_objects,
        &objects,
        &msg);
    ERRORs(sts, msg, "ECmkcompsf_exec EMselective_fence", wrapup);

    if (ME.ECintf->add_to_set && (num_sets = ME.ECintf->num_sets))
      {
      IGRboolean found;
      IGRint startinx, inxlim, num_processed;
      extern IGRboolean EMisElementSame();

      num_in_set = ME.ECintf->num_in_set;
      startinx = 0;
      for (i=0; i<num_sets; i++)
        startinx += num_in_set[i];
      inxlim = ME.ECintf->num_located;

      obj_infos = ME.ECintf->locate_info;
      for (i=startinx; i<inxlim; i++)
        {
        found = FALSE;
        num_processed = 0;
        while (!found && num_processed < number_of_objects)
          {
          if (EMisElementSame (&objects[num_processed].located_obj, 
               &obj_infos[i].located_obj,
               objects[num_processed].module_info.md_env.matrix_type,
               obj_infos[i].module_info.md_env.matrix_type,
               objects[num_processed].module_info.md_env.matrix,
               obj_infos[i].module_info.md_env.matrix))
            found = TRUE;
          else
            num_processed++;
          }
        if (found)
          {
          if (num_processed < number_of_objects-1)
            OM_BLOCK_MOVE (&objects[num_processed+1], &objects[num_processed],
             sizeof (struct GRlc_info));
          number_of_objects--;
          }
        }
      }

    if (number_of_objects)
     {
      IGRboolean        put_on_queue;
      IGRlong           total_count;

      /*
       * Add the processed element set to the processed list.
       */

      put_on_queue = me->locate_event.response != EX_OBJID;
      total_count = me->num_located + number_of_objects + 2; /* Conservative */
      sts = om$vla_set_dimension(
        varray = me->locate_info,
        size = total_count);
      ERRORs(sts, EMS_S_Success, "ECintf_exec expand vla", wrapup);

      sts = om$vla_set_dimension(
        varray = me->reversed,
        size = total_count);
      ERRORs(sts, EMS_S_Success, "ECintf_exec expand vla", wrapup);


      OM_BLOCK_MOVE(objects, &me->locate_info[me->num_located], 
		number_of_objects * sizeof(struct GRlc_info));
      me->num_located += number_of_objects;

      num_sets = ME.ECintf->num_sets;
      if (! ME.ECintf->add_to_set)
        {
        if (om$dimension_of (varray = ME.ECintf->num_in_set) < num_sets+1)
          {
          sts = om$vla_set_dimension (varray = ME.ECintf->num_in_set,
                 size = num_sets+1);
          EMerr_hndlr (EMSerror (sts), msg, EMS_E_NoDynamicMemory, wrapup);
          }

        if (om$dimension_of (varray = ME.ECintf->set_info) < num_sets+1)
          {
          sts = om$vla_set_dimension (varray = ME.ECintf->set_info,
                 size = num_sets+1);
          EMerr_hndlr (EMSerror (sts), msg, EMS_E_NoDynamicMemory, wrapup);
          }
        }
      num_in_set = ME.ECintf->num_in_set;
      set_info = ME.ECintf->set_info;
    
      if (ME.ECintf->add_to_set)
        {
        struct GRlc_info *loc_set_info;

        num_in_set[num_sets-1] += number_of_objects;

        /*
         * The only way the set can have the name of the first element
         * located is when the set consists of that element alone. Since
         * elements are being added into this set, that violates this rule.
         * Hence, make this set-id NULL.
         */

        loc_set_info = &set_info[num_sets-1];
        loc_set_info->located_obj.objid = NULL_OBJID;
        }
      else
        {
        num_in_set[num_sets] = number_of_objects;
        set_info[num_sets] = ME.ECintf->locate_event.located_object[0];
        num_sets = ++ME.ECintf->num_sets;
        }
      for(i = 0; i<me->num_located; i++)
       me->reversed[i] = FALSE;

      /*
       * Put the accept event on the queue if the object
       * was not a specified object (fence).
       */

      if (put_on_queue)
       {
        sts = ex$putque(
          msg = &msg, 
          response = response, 
          byte = &size,
          buffer = (char *)&me->locate_event.event);
        ERRORs(sts, EMS_S_Success, "ECintf_exec put que", wrapup);
       } /* if (put_on_queue) */

      /*
       * After this point, objects need to be added to the current
       * set, unless explicitly indicated by the user (move-on).
       */

      ME.ECintf->add_to_set = TRUE;

     } /* if (number_of_objects) */

    /*
     * Erase the highlighed object and tell the operator 
     * if we have thrown everything away.  Note that fences
     * do not need to be erased as they are never highlighted.
     */

    else
     {
      if (me->locate_event.response != EX_OBJID)
       {
        if (me->num_located)
         {
          struct        GRlc_info *info;

          info = &me->locate_event.located_object[0];
          Display_Mode = GRhe;
          sts = om$send(
            msg = message GRgraphics.GRdisplay(
             &msg,
	     &me->ModuleInfo.md_env.matrix_type, 
	     me->ModuleInfo.md_env.matrix, 
	     /*
             &info->module_info.md_env.matrix_type,
             info->module_info.md_env.matrix,*/
             &Display_Mode, 
	     &me->ModuleInfo.md_id
             /*&info->module_info.md_id*/),
            targetid = info->located_obj.objid,
            targetos = info->located_obj.osnum);
          ERRORs(sts, msg, "ECintf GRdisplay", wrapup);
         } /* if (me->num_located) */
        else
         {
          sts = dp$erase_hilite(
            msg = &msg);
           ERRORs(sts, msg, "ECintf erase hilite", wrapup);
         } /* ELSE FOR if (me->num_located) */
       } /* if (me->locate_event.response != EX_OBJID) */

      ex$message(msgnumb = EMS_I_00092)
      ems_sleep(2);
     }

    /*
     * Free the memory
     */

    if (objects && objects != &static_object)
      free(objects);

    break;
   }

   case dummy:
   {
    /* 
     * Will come here only under a 'move on' response from the user. So 
     * start a new set. If a new set had just been started and there is
     * atleast one element already located, then all locates are done.
     */

    if (!ME.ECintf->add_to_set && ME.ECintf->num_located)
      ME.super_cmd->state = filename;
    ME.ECintf->add_to_set = FALSE;
    break;
   }

   case dummy1:
   {
    if(me->num_ornted == me->num_located) /* forward march */
     ME.super_cmd->state = ask_area;
    else if(me->num_ornted < 0)
     {
      ME.super_cmd->state = ask_vol; /* backing up*/
      me->num_ornted = 0;
     }
    break;
   }


   default:
   {
     ERRORs(OM_E_ABORT, EMS_E_Fail, "action garbage", wrapup);
     break;
   }
  } /*end switch */


  switch(ME.super_cmd->state)
  {
   case plpt1:
   case plpt2:
   case plpt3:
    {
     IGRint	st, i;

     if( (ME.super_cmd->mytype == Intf) || 
         (ME.super_cmd->mytype == IntfBatch) || 
         (ME.super_cmd->mytype == IntfBxsec))
      {
       token = 1;	/* Simulate data event */
       break;
      }
     if(ME.super_cmd->state == plpt1) st = 1;
     else if(ME.super_cmd->state == plpt2) st = 2;
     else st = 3;
     i = st - 1;

     locate_mask = GRm_DATA | GRm_BACK_UP;
     if( (st == 1) && me->plpts_input)
      {
       locate_mask |= GRm_RJT_MOVEON;
       ex$message(msgnumb = EMS_P_Plpt1MvOn, type = "%d", var = `st`);
      }
     else
      {
      ex$message(msgnumb = EMS_P_00130, type = "%d", var = `st`);
      }

     if(st >1)
      {
       sts = ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay, 
				 me->ModuleInfo, my_id, i, &me->points[0][0], 
				 TRUE);
       EFrblineseg(&me->points[st-2][0], &ME.COconst->ActiveDisplay);
      }
     token = GRget_token(&msg, Tokens, &locate_mask, 
                         &me->locate_event, &size, 
                         response, response_data);
     ex$message (msgnumb = EMS_S_ClearStatusField);
     ex$message(msgnumb = EMS_P_ClearPromptField);

     if (st > 1)
       sts = ECdisplayPointSetByBuffer(&msg, ME.COconst->ActiveDisplay, 
				 me->ModuleInfo, my_id, st-1, 
				 &me->points[0][0], FALSE);

				
      /* If we have anything other than data point, break and stay on
         the same state. If previously entered 3 points are to be reused, 
	 simulate the condition as if the third point was input.
      */
      if( (st == 1) && (me->plpts_input) && (token == 4))
       {
	ME.super_cmd->state = plpt3;
	token = 1;
	break;
       }
      if(token != 1) break;
      me->points[i][0] = me->locate_event.event.button.x;
      me->points[i][1] = me->locate_event.event.button.y;
      me->points[i][2] = me->locate_event.event.button.z;
      if(st == 2)
       {
        status = BSdistnct2(&loc_msg, me->points[0], me->points[1]);
        if (!status)
        {
         ex$message(msgnumb = EMS_I_00001)
	 token = 5;	/* Simulate unknown event to stay on the same state*/
	}
       }
      else if(st == 3)
       {
	IGRdouble tolerance;
	
	BSEXTRACTPAR(&msg, BSTOLLENVEC, tolerance);
        me->plane.point = &me->plane_point[0];
        me->plane.normal = &me->plane_normal[0];
        status = MAdetplane(&msg, (IGRdouble *)me->points, &num_pnts, &tolerance,
			    &me->plane);
        if (!status)
        {
         ex$message(msgnumb = EMS_I_00001)
         token = 5;	/* Simulate unknown event to stay on the same state*/
	}
        else me->plpts_input = TRUE;
       }

     break;
    }


   case start:
    num_sets = ME.ECintf->num_sets;
    if (ME.ECintf->add_to_set)
      num_loc_sets = num_sets;
    else
      num_loc_sets = num_sets + 1;

    if (ME.super_cmd->mytype == IntfBxsec)
      strcpy (elemtype, "cross-section plane");
    else
      strcpy (elemtype, "surface/solid");

    locate_mask = GRm_DATA | GRm_BACK_UP | GRm_OBJID | GRm_SPECIFIED_OBJ |
		   GRm_TEXT_VALUE;
    if (me->num_located)
      {
      locate_mask |= GRm_RJT_MOVEON;
       ex$message (msgnumb = EMS_P_IdElemMvOn, buff = loc_prompt,
       type = "%s %d", var = `elemtype, num_loc_sets`);
      }
    else
      {
      ex$message (msgnumb = EMS_P_IdElem, buff = loc_prompt,
       type = "%s %d", var = `elemtype, num_loc_sets`);
      }

    accept_mask = GRm_DATA | GRm_TEXT_VALUE;
    ex$message (msgnumb = EMS_P_AcElemRj, buff = acc_prompt,
     type = "%s %d", var = `elemtype, num_loc_sets`);

    ex$message (msgnumb = EMS_I_00013, buff = reloc_prompt);

    display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                    LC_ERASE_ALL;

    attr.properties = 
     LC_LC_ONLY         |       /* Locate locatable objects */
     LC_DP_ONLY         |       /* Locate displayable objects */
     IGN_MOD_BIT        |       /* Ignore modified and new props */
     IGN_PLANAR_BIT     |       /* Ignore planar checks */
     LC_RW;             	/* I am only going to read*/
    attr.owner_action = 
     LC_RIGID_OWNER     |       /* Composites */
     LC_RIGID_COMP  	|	/* Members of composites */
     LC_FLEX_OWNER      |       /* Graphic groups, etc. */
     LC_FLEX_COMP       |       /* Members of graphic groups, etc. */
     LC_REF_OBJECTS     |       /* Objects in ref. files are allowed */
     LC_NO_REF_HEADER;          /* No reference file headers */

    rtree_classes.w_count = 1;
    elig_classes.w_count = (ME.super_cmd->mytype == IntfBxsec) ? 1 : 2;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = (ME.super_cmd->mytype == IntfBxsec) ? OPP_EMSplane_class_id
						 : OPP_EMSsubbs_class_id; 
    if(ME.super_cmd->mytype == IntfBxsec)
      eliclass[0] = OPP_EMSplane_class_id; 
    else
     {
      eliclass[0] = OPP_EMSsurface_class_id; 
      eliclass[1] = OPP_GRowner_class_id; 
     }

    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass[0];

    /*
     * Call the graphic set deposit function.  This will help
     * us weed out garbage from the fence.
     */

    sts = gr$gsput_locate_criteria(
      msg = &msg,
      attributes = &attr,
      rtree_classes = &rtree_classes,
      eligible_classes = &elig_classes);
    ERRORs(sts, msg, "ECintf_exec gsput_locate_criteria", wrapup);

    /*
     * call an action handler to mark already located
     * objects as not eligible for locate.
     */

    {
    extern      IGRlong EFlocate_action_handler();
    struct      EMSaction_handler already_located;

    already_located.next = NULL;
    already_located.option = 0;		/* Don't locate objects in list*/
    already_located.type = 0;		/* passing GRlc_info's */
    already_located.num_objects = me->num_located;
    for(i=0; i<me->num_located; i++)
     already_located.objects.lc_info[i] = &me->locate_info[i];


    lc$locate(rc = &msg, 
              event1 = &me->locate_event, 
              event2 = &me->locate_event,
              mask1 = locate_mask, 
              mask2 = accept_mask, 
              eventsize= &size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              unhilight_mode = (enum GRdpmode) GRhhd,
              locate_prompt = loc_prompt, 
              acc_prompt = acc_prompt,
              relocate_prompt = reloc_prompt, 
              attributes = &attr, 
              act_handler = EFlocate_action_handler,
              act_args = &already_located,
              stack = &me->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes, 
	      regex = TRUE);
    }

    token = GRloc_token(&msg, Tokens, &me->locate_event);
    break;

   case filename:
   {
    FILE	*ptr = NULL;

    ex$message(msgnumb = EMS_P_ReportFileName);
    locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;
     
    token = GRget_token(&msg, Tokens, &locate_mask, 
                         &me->locate_event, &size, 
                         response, response_data);
    ex$message (msgnumb = EMS_S_ClearStatusField);
    ex$message(msgnumb = EMS_P_ClearPromptField);

    if ((Tokens[token] == EX_RJT_MOVEON)  || (msg == GRw_no_value))
         me->stdreportonly = TRUE;
    else if(Tokens[token] == STRING)  
     {
      strcpy(me->filename, me->locate_event.event.keyin);
      me->stdreportonly = FALSE;
      ptr = fopen(me->filename, "r");
      if(ptr)
       {
        ex$message(msgnumb = EMS_I_FileExistsWillApp);
        ems_sleep(3);
        fclose(ptr);
       }
     }

    break;
   }


   case ask_cv:
   {
    if( (ME.super_cmd->mytype == IntfXsec) || 
	(ME.super_cmd->mytype == IntfBxsec))
     {
      me->nocurves = TRUE;
      token = 3;	/* Simulate string event */
      break;      
     }

    ex$message(msgnumb = EMS_P_CrIntfCv);
    locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;
     
    token = GRget_token(&msg, Tokens, &locate_mask, 
                         &me->locate_event, &size, 
                         response, response_data);
    ex$message (msgnumb = EMS_S_ClearStatusField);
    ex$message(msgnumb = EMS_P_ClearPromptField);

    if ((Tokens[token] == EX_RJT_MOVEON)  || (msg == GRw_no_value))
         me->nocurves = TRUE;
    else if(Tokens[token] == STRING)  
     {
      if(toupper(me->locate_event.event.keyin[0]) == 'Y') 
       me->nocurves = FALSE;
      else me->nocurves = TRUE;
     }

    break;
   }


   case ask_vol:
   {
    if( (ME.super_cmd->mytype == IntfXsec) || 
	(ME.super_cmd->mytype == IntfBxsec))
     {
      me->novol = TRUE;
      token = 3;	/* Simulate string event */
      break;      
     }

    ex$message(msgnumb = EMS_P_CrIntfVl);
    locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;
     
    token = GRget_token(&msg, Tokens, &locate_mask, 
                         &me->locate_event, &size, 
                         response, response_data);
    ex$message (msgnumb = EMS_S_ClearStatusField);
    ex$message(msgnumb = EMS_P_ClearPromptField);

    if ((Tokens[token] == EX_RJT_MOVEON)  || (msg == GRw_no_value))
         me->novol = TRUE;
    else if(Tokens[token] == STRING)  
     {
      if(toupper(me->locate_event.event.keyin[0]) == 'Y') 
       me->novol = FALSE;
      else me->novol = TRUE;
     }

    break;
   }


   case ask_ort:
   {
    IGRint	i;
    OMuword	locclassid;
    struct GRid	sfid;

    if( (me->num_ornted == me->num_located) ||
        (ME.super_cmd->mytype == IntfXsec) ||
	(ME.super_cmd->mytype == IntfBxsec))
     {
      if( (ME.super_cmd->mytype == IntfXsec) ||
	  (ME.super_cmd->mytype == IntfBxsec))
        me->num_ornted = me->num_located;

      token = 3;           /* Simulate string event */
      break;
     }

    for(i=me->num_ornted; i<me->num_located; i++)
     {
      sfid = me->locate_info[i].located_obj;
	
      sts = om$get_classid(objid = sfid.objid, osnum = sfid.osnum,
			      p_classid = &locclassid);
      if ((om$is_ancestry_valid (subclassid = locclassid, 
            superclassid = OPP_EMSsolid_class_id) == OM_S_SUCCESS) ||
          (om$is_ancestry_valid (subclassid = locclassid, 
            superclassid = OPP_EMSsurface_class_id) != OM_S_SUCCESS))
       {
	me->num_ornted++;
	continue;
       }
      else
       {
	struct GRmd_env 	*junk;
	
	junk = &me->ModuleInfo; /*&me->locate_info[i].module_info;*/
	
        sts = om$send (msg = message EMSsurface.EMshow_normals (&msg,
                    junk, &ME.COconst->ActiveDisplay, GRhd), 
                       targetid = sfid.objid, targetos = sfid.osnum);
        ERRORs(sts, msg, "ECintf EMshow_normals", wrapup);

        ex$message(msgnumb = EMS_P_VlSdDef);
        locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;
     
        token = GRget_token(&msg, Tokens, &locate_mask, 
                         &me->locate_event, &size, 
                         response, response_data);
        ex$message (msgnumb = EMS_S_ClearStatusField);
        ex$message(msgnumb = EMS_P_ClearPromptField);

        sts = om$send (msg = message EMSsurface.EMshow_normals (&msg,
                    junk, &ME.COconst->ActiveDisplay, GRhe), 
                       targetid = sfid.objid, targetos = sfid.osnum);
        ERRORs(sts, msg, "ECintf EMshow_normals", wrapup);

        if(Tokens[token] == STRING)  
         {
          if(toupper(me->locate_event.event.keyin[0]) == 'N') 
	   {
            sts = om$send (msg = message EMSsurface.EMrevorient (&msg),
                           targetid = sfid.objid, targetos = sfid.osnum);
            ERRORs(sts, msg, "ECintf EMrevorient", wrapup);
            me->reversed[i] = !me->reversed[i];
	   }
         }


        if(Tokens[token] == EX_BACK_UP)
         {
	  if(me->num_ornted)
	   {
	    struct GRid junk;
	    junk = me->locate_info[me->num_ornted - 1].located_obj;
            if(me->reversed[me->num_ornted - 1])
             {
              sts = om$send (msg = message EMSsurface.EMrevorient (&msg),
               targetid = junk.objid,
	       targetos = junk.osnum);
              ERRORs(sts, msg, "ECintf_exec erase", wrapup);	
	      me->reversed[me->num_ornted - 1] = FALSE;
             }
	   }
          me->num_ornted--;
          break;
	 }
        else if (Tokens[token] == EX_RJT_MOVEON ||
                 (Tokens[token] == STRING &&
                 toupper(me->locate_event.event.keyin[0]) == 'D'))
	 {
          me->num_ornted = me->num_located;
          break;
         }
        else if ((msg == GRw_no_value) ||
		 (Tokens[token] == STRING))
         me->num_ornted++;
        else
         break;
       } /* if not a solid */

     }/* for(i=me->num_ornted; i<me->num_located; i++) */

    if (ME.super_cmd->mytype == IntfBatch)
      {
       if (!ME.ECintf->novol || !ME.ECintf->nocurves)
         {
          IGRlong stat_func, msg_loc, eventmask;
          struct GRevent event;

          askfile:
          ex$message (msgnumb = EMS_P_FileForCvsVls);

          eventmask = GRm_STRING;
          stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                       response = response, response_data = response_data,
                       event = &event);
          ex$message (msgnumb = EMS_P_ClearPromptField);
          if (event.response != EX_STRING)
            {
	     ex$message(msgnumb = EMS_S_InpIgnored);
             goto askfile;
            }
          else
            {
             FILE *fileptr;

             fileptr = fopen (event.event.keyin, "w");
             if (!fileptr)
               {
                ex$message (msgnumb = EMS_E_InvalidFile);
	        ems_sleep (2);
		goto askfile;
	       }
	     else
	       {
	        fclose (fileptr);
                strcpy (ME.ECintf->savefile, event.event.keyin);
               }
            }
         }

       if (!ex$is_batch())
         {
          IGRint stat_func, msg_loc, eventmask;
          struct GRevent event;

          askmoveon:
	  ex$message(msgnumb = EMS_S_IntAnaInBatch);
	  ex$message(msgnumb = EMS_P_MvonBatFilCre);

          eventmask = GRm_RJT_MOVEON;
          stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                       response = response, response_data = response_data,
                       event = &event);
	  ex$message(msgnumb = EMS_P_ClearPromptField);
          if (event.response != EX_RJT_MOVEON)
            {
	     ex$message(msgnumb = EMS_S_InpIgnored);
             goto askmoveon;
            }

          *response = TERMINATE;
          token = 5;
         }
      }

    break;
   }


   case ask_area:
   {
    if(ME.super_cmd->mytype == Intf || ME.super_cmd->mytype == IntfBatch)
     {
      me->noarea = TRUE;
      token = 3;	/* Simulate string event */
      break;      
     }

    ex$message(msgnumb = EMS_P_CrIntfAr);
    locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;
     
    token = GRget_token(&msg, Tokens, &locate_mask, 
                         &me->locate_event, &size, 
                         response, response_data);
    ex$message (msgnumb = EMS_S_ClearStatusField);
    ex$message(msgnumb = EMS_P_ClearPromptField);

    if ((Tokens[token] == EX_RJT_MOVEON)  || (msg == GRw_no_value))
         me->noarea = TRUE;
    else if(Tokens[token] == STRING)  
     {
      if(toupper(me->locate_event.event.keyin[0]) == 'Y') 
       me->noarea = FALSE;
      else me->noarea = TRUE;
     }

    break;
   }



   case analyze:
   {
    struct GRvg_construct konst;
    IGRlong		rc;
    IGRushort		options = NULL;
    struct EMSintf	*result = NULL;
    IGRint		i, num_result = 0, total_result = 0;
    extern void		EMintf_free();
    IGRboolean		hilted = FALSE;

    konst.msg        = (IGRlong *)&msg;
    konst.class_attr = NULL;       
    konst.level      = ME.COconst->ActiveLevel;
    konst.display    = &ME.COconst->ActiveDisplay;
    konst.env_info   = &me->ModuleInfo;
    konst.newflag    = FALSE;
    konst.name       = NULL;
    konst.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    konst.geometry   = NULL;

    sts = dp$erase_hilite(msg = &msg);
    ERRORs(sts, msg, "ECintf_exec erase hi", wrapup);
    ex$message (msgnumb = EMS_I_Processing);
    ex$message (msgnumb = EMS_P_ClearPromptField);

    /* 
     * Send message for analysis. In the case of multiple sets, process
     * the sets in a combinatoric manner.
     */

    if(me->nocurves) options = EMSintf_NoCurves;
    if(me->novol) options |= EMSintf_NoVolElems;
    if(me->noarea) options |= EMSintf_NoAreaElems;

    if(!me->stdreportonly) options |= EMSintf_ReportBoth;
    options |= EMSintf_Display;

    if(ME.super_cmd->mytype == IntfBxsec)
     options |= EMSintf_InputXsec;

    options |= EMSintf_NoCrossHatch;

    num_sets = ME.ECintf->num_sets;
    num_in_set = ME.ECintf->num_in_set;
    set_info = ME.ECintf->set_info;

    for (i=0; num_sets == 1 && i == 0 ? TRUE : i<num_sets-1; i++)
      for (j=i+1; num_sets == 1 && j == i+1 ? TRUE : j<num_sets; j++)
        {
        IGRint a, inx1, inx2;

        inx1 = 0;
        for (a=0; a<i; a++)
          inx1 += num_in_set[a];
        inx2 = 0;
        for (a=0; a<j; a++)
          inx2 += num_in_set[a];

        if (ME.super_cmd->mytype == Intf || ME.super_cmd->mytype == IntfBatch)
          sts = EManalyzeIntf(
 			&rc,
			&set_info[i],
			&me->locate_info[inx1],
			num_in_set[i],
                        i+1,
			&set_info[num_sets == 1 ? i : j],
			&me->locate_info[num_sets == 1 ? inx1 : inx2], 
			num_in_set[num_sets == 1 ? i : j],
			num_sets == 1 ? i+1 : j+1,
			options, 
			me->stdreportonly ? NULL : me->filename, 
			&konst, 
			&result, 
			&num_result);
        else
          sts = om$send(msg = message EMSsurface.EManalyzeIntfAlongXsec(
			&rc,
			&set_info[i],
			&me->locate_info[inx1], 
			num_in_set[i],
                        i+1,
			&set_info[num_sets == 1 ? i : j],
			&me->locate_info[num_sets == 1 ? inx1 : inx2], 
			num_in_set[num_sets == 1 ? i : j],
			num_sets == 1 ? i+1 : j+1,
			options, 
			me->stdreportonly ? NULL : me->filename, 
			&konst,
			ME.super_cmd->mytype == IntfBxsec ? NULL : &me->plane, 
			&result, 
			&num_result), 
		targetid = me->locate_info[inx1].located_obj.objid, 
		targetos = me->locate_info[inx1].located_obj.osnum);
         total_result += num_result;

         if (rc == EMS_E_FileOpen)
           {
           ex$message(msgnumb = EMS_E_OpenFileW, type = "%s", 
  		 var = me->filename);
           ems_sleep(2);
           rc = EMS_S_Success;
           sts = OM_S_SUCCESS;
           }

         if (rc == EMS_I_Interrupt)
           {
           ex$message(msgnumb = EMS_I_ProcessingInterrupt);
           ems_sleep(2);
           }

        if (EMSerror (rc & sts))
          {
          ex$message(msgnumb = EMS_E_AnalysisFailed)
          }
        else if (!num_result)
          {
          ex$message(msgnumb = EMS_I_NoIntfFound)
          }
        else
          {
          ex$message(msgnumb = EMS_I_AnalysisComplete)

          hilted = FALSE;
          if (!me->nocurves)
            {
            IGRint i, j;

            for (i=0; i<num_result && !hilted; i++)
              for(j=0; j<result[i].numintf && !hilted; j++)
                if (!IF_NULL_OBJID (
                      result[i].info.qualitative[j].inters.objid))
                  hilted = TRUE;
            if (hilted)
              {
              ex$message(msgnumb = EMS_I_AnlCompCvHiLted)
              ems_sleep(2);
              }
            }
	
          hilted = FALSE;
          if (!me->noarea)
            {
            IGRint i, j, m;

            for (i=0; i<num_result && !hilted; i++)
              for (j=0; j<result[i].numintf && !hilted; j++)
                for (m=0; m<NumIntfCases && !hilted; m++)
                  if (!IF_NULL_OBJID(result[i].info.xsec[j].areas[m].objid))
                    hilted = TRUE;
            if (hilted)
              {
  	      ex$message(msgnumb = EMS_I_AnlCompAreaHiLted)
              ems_sleep(2);
              }
            }
	
          hilted = FALSE;
          if (ME.super_cmd->mytype == IntfXsec)
            {
            IGRint i, j, m;

            for (i=0; i<num_result && !hilted; i++)
              for (j=0; j<result[i].numintf && !hilted; j++)
                for (m=0; m<NumIntfCases && !hilted; m++)
                  if (result[i].info.xsec[j].linesegs[m][0] ||
                       result[i].info.xsec[j].linesegs[m][1])
                     hilted = TRUE;
	
            if (hilted)
              {
              ex$message(msgnumb = EMS_I_AnlCompMinMaxSegHiLted)
              ems_sleep(2);
              }
            }

          hilted = FALSE;
          if (!me->novol)
            {
            IGRint i, j;
 
            for (i=0; i<num_result && !hilted; i++)
              for(j=0; j<result[i].numintf && !hilted; j++)
                if (!IF_NULL_OBJID (
                      result[i].info.qualitative[j].volelem.objid))
  	          hilted = TRUE;

            if (hilted)
              {
              ex$message(msgnumb = EMS_I_AnlCompVolHiLted)
              ems_sleep(2);
              }
            }
          }

        if (result)
          EMintf_free (result, num_result);
        }

    for(i=0; i<me->num_located; i++)
     if(me->reversed[i])
      {
       sts = om$send (msg = message EMSsurface.EMrevorient (&rc),
               targetid = me->locate_info[i].located_obj.objid, 
               targetos = me->locate_info[i].located_obj.osnum); 
       me->reversed[i] = FALSE;
      }

    /*
     * If this is batch processing and if curves/volumes have been 
     * generated, then save the active file into the the new file
     * specified earlier.
     */

    if (ME.super_cmd->mytype == IntfBatch)
      {
       if ((!ME.ECintf->novol || !ME.ECintf->nocurves) &&
           total_result)
          ex$save_module (ftype = EX_visible, 
           newfilename = ME.ECintf->savefile);

       *response = TERMINATE;
       token = 5;
      }

    me->num_located = 0;
    me->num_ornted = 0;
    me->num_sets = 0;
    me->add_to_set = 0;
    me->stdreportonly = FALSE;
    me->nocurves = TRUE;
    me->novol = TRUE;
    me->noarea = TRUE;

    break;
   }

   default:
    ERRORs(OM_E_ABORT, EMS_E_Fail, "ECintf_exec state garbage", wrapup);
    break;
  }

  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE);

 if (*response == CLEAR_STACK &&
     ME.super_cmd->mytype == IntfBatch &&
     !ex$is_batch())
   {
   IGRlong msg_loc;

   EMstop_record(&msg_loc);
   }

 return (sts);

 wrapup:
  ex$message(msgnumb = EMS_F_0002)
  *response = TERMINATE;
  return(OM_E_ABORT);

}


void EMstop_record(msg)
IGRlong *msg;
{
  IGRlong stat_OM;
  GRobjid lisnr_id;

  *msg = EMS_S_Success;
  
  stat_OM = ex$get_objid_from_NOD (NODname = NOD_NAME, objname = LISTENER_NAME,
             pobjid = &lisnr_id, modid = OM_GO_TransOS_0,
             mod_osnum = OM_Gw_TransOSnum_0);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

  stat_OM = ex$detach_input_listener (objid = lisnr_id,
             osnum = OM_Gw_TransOSnum_0);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message RAPinlisnr.finish (), 
             targetid = lisnr_id, targetos = OM_Gw_TransOSnum_0,
             senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message Root.delete (0), 
             targetid = lisnr_id, targetos = OM_Gw_TransOSnum_0,
             senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

ret_end:
  return;
}

end implementation ECintf;
