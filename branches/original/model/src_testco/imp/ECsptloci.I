/* ###################   APOGEE COMPILED   ################## */
class implementation ECsptloc;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "msmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "lcmacros.h"
#include "EMSconstruct.h"
#include "EMSmsgdef.h"
#include "ems_m_inc.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
# ifndef grdpbmacros_include
# include "grdpbmacros.h" /* gr$get_active_display */
# endif
#include <stdio.h>
#include "EC_S.h"
#include "EC_M.h"
#include "EMSdpb.h"
#include "EMSdpr.h"

extern int pp_output_igds_ems_log;
extern int pp_igds_ems_num_calls;
extern int pp_increment;
extern int pp_output_ems_igds_log;
extern int pp_ems_igds_num_calls;
extern int pp_increment_ems_igds;
extern short _sm_convert_into_plane;
extern short _sm_skip_int_refinement;
extern short _sm_use_new_stitching_algorithm;

extern OMuword OPP_EMSsubbs_class_id, OPP_EMScomposite_class_id,
               OPP_EMScompsurf_class_id, OPP_EMSsurface_class_id;

from GRgraphics import GRdisplay;
from EMSsolid import EMpoint_locate;
from EMSsurface import EMshow_normals;
from EMSsurface import EMrevorient,GRgetrang;
from EMSdpr import EMmake_primitive1;

/* *************************************************************************

   This command object is used for 
       Reversing the orientation of the solid,
       Showing the orientation of the solid,
       Testing point location on the solid
       Turning on/off igds->ems translation log
       Turning on/off ems->igds translation log
       Initializing the counter for ems->igds log
       Turning on/off automatic plane creation

   History
      PP  : 01/1/88  : Creation
      scw : 08/08/91 : Converted to use gr$dpb associative flag
      Tapadia 5/22/92 : Modified for message sub system compliance
      scw : 08/14/94 : clarified sleep method

   ************************************************************************* */

method super_cmd.sleep(int pos)
{
 ex$message(msgnumb = EM_M_ClearMessageField);
 ex$message(msgnumb = EMS_S_ClearStatusField);
 ex$message(msgnumb = EMS_P_ClearPromptField);
 return (OM_S_SUCCESS);
}


method execute(int *response; char *response_data; int pos)
{
 IGRint                sts=OM_S_SUCCESS,  size=sizeof(struct GRevent),display_flag;
 IGRlong               msg;
 IGRint                locate_mask, accept_mask, token;
 enum     GRdpmode     Display_Mode;
 struct   GRlc_locate  attr;
 OM_S_CLASSLIST        rtree_classes, elig_classes;
 OMuword               rclass, eliclass;
 IGRchar               loc_prompt[40], acc_prompt[40], reloc_prompt[40];

 
/* TABLE STUFF */

#   define NUM_TOKENS 3
    /* */ static /* */ int Tokens[NUM_TOKENS] =
    {
        EX_BACK_UP, DATA, GR_UNKNOWN_TYPE
    };

    enum actions
    {
         NIL, ERR, initialize, store_sol, perform
    };

#   define NUM_STATES 2
    enum states
    {
        start, got_sol
    };

    /* */ static /* */ enum states NextState[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:    EX_BACK_UP     DATA      UNK
    old state: */                                   
    /* start    */ {start,    got_sol,  start   },
    /* got_sol  */ {got_sol,  start,    got_sol }
    };

    /* */ static /* */ enum actions NextAction[NUM_STATES][NUM_TOKENS] =
    {
    /*  token:    EX_BACK_UP  DATA        UNK
    old state: */                                     
    /* start    */ {NIL,   store_sol,  NIL }, 
    /* got_sol  */ {NIL,   perform,       NIL }
    };

if (me->mytype == 0)
 ex$message(msgnumb = EM_M_TePtLoc)
else if (me->mytype == 1)
 ex$message(msgnumb = EM_M_ShOrientation)
else if (me->mytype == 2)
 ex$message(msgnumb = EM_M_RevOrientation)
else if ( (me->mytype == 3) || (me->mytype == 5))
{
 int 	*logptr, *incrptr, *numcallsptr;

 if(me->mytype == 3)
  {
   ex$message(msgnumb = EM_M_ToOutIgdsEmsLog);
   logptr = &pp_output_igds_ems_log;
   incrptr = &pp_increment;
   numcallsptr = &pp_igds_ems_num_calls;
  }
 else
  {
   ex$message(msgnumb = EM_M_ToOutEmsIgdsLog);
   logptr = &pp_output_ems_igds_log;
   incrptr = &pp_increment_ems_igds;
   numcallsptr = &pp_ems_igds_num_calls;
  }

 if (*logptr) 
 {
  *logptr = 0;
  if(me->mytype ==3)
   ex$message(msgnumb = EMS_S_ToOutIgdsEmsOff)
  else ex$message(msgnumb = EMS_S_ToOutEmsIgdsOff)
  sleep(2);
 }
 else 
 {
  struct GRevent event;
  IGRint event_mask;
  IGRlong stat_func,msg_loc;
  IGRchar value_string[MAX_VALUE_STRING];

  *logptr = 1;
  *numcallsptr = 0;

  (void) strcpy(value_string, GRIO_SCALAR);

  event_mask = GRm_VALUE | GRm_RJT_MOVEON;

  stat_func = co$getevent (
              msg = &msg_loc,
              event_mask = event_mask,
              prompt = "Increment at which to print [1]", 
              value_type = value_string,
              response = response,
              response_data = response_data,
              event = &event
             );
  
  if (msg_loc == GRw_no_value)
     event.response = EX_RJT_MOVEON;

  if (!stat_func)
     {
      ex$message(msgnumb = EMS_S_ErrEncountered);
      sleep (2);
      *response = TERMINATE;
      return (OM_E_ABORT);
     }
   else if (event.response == EX_VALUE)
   {
      *incrptr = event.event.value;
      if (*incrptr <= 0) *incrptr = 1;
   }
   else if (event.response == EX_RJT_MOVEON)
      *incrptr = 1;
    
  if(me->mytype == 3)
   ex$message(msgnumb = EMS_S_ToOutIgdsEmsOn)
  else
   ex$message(msgnumb = EMS_S_ToOutEmsIgdsOn)
  sleep(2);
 }
 *response = TERMINATE;
 return (OM_S_SUCCESS);
}
else if (me->mytype == 4)
 ex$message(msgnumb = EM_M_DisRanObtGetRan)
else if(me->mytype == 6)
 {
  ex$message(msgnumb = EM_M_IniEmsIgdsLoCou);
  pp_ems_igds_num_calls = 0;
  ex$message(msgnumb = EMS_S_EmsIgdsLoCoZero);
  sleep(2);
  *response = TERMINATE;
  return (OM_S_SUCCESS);
 }
/*
 else if (me->mytype == 7)
 {
  IGRboolean assoc_flag;   
  IGRint msg_loc;
  void GRdisplay_associative_symbol();

  gr$get_associative_flag( buffer = &assoc_flag );

  if (assoc_flag)
    assoc_flag = FALSE;
  else
    assoc_flag = TRUE;
  gr$put_associative_flag( buffer = &assoc_flag );

  if (assoc_flag)
   GRdisplay_associative_symbol(1);
  else
   GRdisplay_associative_symbol(0);
  *response = TERMINATE;
  return (OM_S_SUCCESS);
 }
*/
 else if (me->mytype == 8)
 {
  ex$message(msgnumb = EM_M_UnImplmented);
  ex$message(msgnumb = EMS_S_ComNotYetImple);
  ex$message(msgnumb = EMS_P_SelectCommand);
  sleep (2);
  *response = TERMINATE;
  return (OM_S_SUCCESS);
 }
 else if (me->mytype == 101)
 {
  IGRint msg_loc;
  IGRint ref_lock_state;

  ems$ref_plane_lock(msg = &msg_loc, 
                     options = 
                      EMS_REF_PLANE_LOCK_SET |
                      EMS_REF_PLANE_LOCK_TOGGLE);
  if (msg_loc == MSINARG)
  {
   ex$message(msgnumb = EMS_S_NoActRefPlane);
   sleep(2);
  }
  else
  {
   ems$ref_plane_lock(msg = &msg_loc,
                      options = EMS_REF_PLANE_LOCK_INQ,
                      mode = &ref_lock_state);
   if (ref_lock_state & EMS_REF_PLANE_LOCK_ON)
     EFlmgr_set_lock_state(1);
   else
     EFlmgr_set_lock_state(0);
  
  }


  *response = TERMINATE;
  return (OM_S_SUCCESS);
 }
 else if (me->mytype == 9)
 {
  ex$message(msgnumb = EM_M_TogCvrtPlane);
  _sm_convert_into_plane = !_sm_convert_into_plane;

  if(_sm_convert_into_plane)
   ex$message(msgnumb = EMS_I_CvrtToPlaneOn)
  else
   ex$message(msgnumb = EMS_I_CvrtToPlaneOff)
  sleep (2);
  *response = TERMINATE;
  return (OM_S_SUCCESS);
 }
else if (me->mytype == 10)
 {
  ex$message(msgnumb = EM_M_CvrtToPlanes);
  ex$message(msgnumb = EMS_I_WarnTreeWillCompress, 
             field = KEYIN_FIELD, justification = LEFT_JUS);
 }
else if (me->mytype == 11)
 {
  UI_message("Toggle refinement enable flag");
  _sm_skip_int_refinement = !_sm_skip_int_refinement;

  if( _sm_skip_int_refinement)
   UI_status("Refinement WILL NOT be done after sfsf intersection");
  else
   UI_status("Refinement WILL be done after sfsf intersection");
  sleep (2);
  *response = TERMINATE;
  return (OM_S_SUCCESS);
 }
else if (me->mytype == 12)
 {
  UI_message("Toggle New Stitching flag");
  _sm_use_new_stitching_algorithm = !_sm_use_new_stitching_algorithm;

  if( _sm_use_new_stitching_algorithm)
   UI_status("New stitching algorithm WILL be used");
  else
   UI_status("New stitching algorithm WILL NOT be used");
  sleep (2);
  *response = TERMINATE;
  return (OM_S_SUCCESS);
 }

 do
 {
  switch (ME.COconst->action)
  {
   

   case NIL:
   {
    break;
   }


   case ERR:
   {
    break;
   }
 

   case initialize:
   {
    break;
   }


   case store_sol:
   {
    OM_BLOCK_MOVE(&me->accept_event.located_object[0],
                  &me->solid_info, sizeof(struct GRlc_info));
    break;
   }   


   case perform:
   {
    ex$message(msgnumb = EMS_I_00003);
    ex$message(msgnumb = EMS_P_ClearPromptField);
    Display_Mode = GRbdhe;

    sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                        &me->solid_info.module_info.md_env.matrix_type,
                        me->solid_info.module_info.md_env.matrix,
                        &Display_Mode, 
                        &me->solid_info.module_info.md_id),

                  targetid = me->solid_info.located_obj.objid,
                  targetos = me->solid_info.located_obj.osnum);
    ERROR(sts, msg, "performsf exec display", wrapup)

    {
       struct GRid surf_id;         
       IGRpoint inpoint;
       IGRulong location;
       IGRushort options;
   
       surf_id.objid = me->solid_info.located_obj.objid;
       surf_id.osnum = me->solid_info.located_obj.osnum; 

if (me->mytype == 0)
{
       inpoint[0] = me->accept_event.event.button.x;
       inpoint[1] = me->accept_event.event.button.y;
       inpoint[2] = me->accept_event.event.button.z;

fprintf(stderr,"Point : %.10f %.10f %.10f \n\n", inpoint[0], inpoint[1],
                inpoint[2]);

       sts = om$send(msg = message EMSsolid.EMpoint_locate(&msg,
                          &me->solid_info.module_info, options,
                          inpoint, NULL,&location),
                    targetid = surf_id.objid,
                    targetos = surf_id.osnum);
       if (COERROR(sts) || COERROR(msg))
	   ex$message(msgnumb = EMS_I_CantDetLocn)
       else       
        {
         if (location == EMS_S_ONSOLID)
	   ex$message(msgnumb = EMS_S_PtOnSolid)
         else if (location == EMS_S_OUTSOLID)
	   ex$message(msgnumb =	EMS_S_PtOutSolid) 
         else if (location == EMS_S_INSOLID)
	   ex$message(msgnumb =	EMS_S_PtInSolid) 
         else
	   ex$message(msgnumb = EMS_I_CantDetLocn)
        }
 }
 else if (me->mytype == 1)
 {
   struct IGRdisplay active_display;
   IGRint bytes_in, bytes_out;

       bytes_in = sizeof (struct IGRdisplay);
       gr$get_active_display (msg = &msg, sizbuf = &bytes_in,
          buffer = &active_display, nret = &bytes_out);

       Display_Mode = GRbdhe;
       sts = om$send (msg = message EMSsurface.EMshow_normals (&msg, 
                            &me->solid_info.module_info, &active_display,
                            Display_Mode),
                      targetid = surf_id.objid,
                      targetos = surf_id.osnum);
       if (COERROR(sts) || COERROR(msg))
	ex$message(msgnumb = EMS_S_ErrInShoNor)
  }
 else if (me->mytype == 2)
 {
        sts = om$send (msg = message EMSsurface.EMrevorient (&msg),
                   targetid = surf_id.objid,
                   targetos = surf_id.osnum);
        if (COERROR(sts) || COERROR (msg))
		ex$message(msgnumb = EMS_S_ErrRevOri)
 }
 else if (me->mytype == 4)
 {
   IGRboolean world = TRUE;
   GRrange range;
   sts = om$send(msg = message GRgraphics.GRgetrang
                        (&msg, 
                       &me->solid_info.module_info.md_env.matrix_type,
                       me->solid_info.module_info.md_env.matrix,
                       &world,  range), 
                      targetid = surf_id.objid,
                      targetos = surf_id.osnum);
   if (sts == OM_I_CHAN_EMPTY)
   {
	ex$message(msgnumb = EMS_S_NoValRange);
    	return (OM_E_ABORT);
   }
   if (COERROR(sts) || COERROR (msg))
	ex$message(msgnumb = EMS_S_ErrObtRange);
   	EFdraw_range_box(range);
 }
else if(me->mytype == 10)
 {
  struct GRid new_sol;

  msg = EMS_S_Success;
  sts = om$send(msg = message EMSdpr.EMmake_primitive1(&msg, 
        &me->solid_info.module_info, &new_sol),
        targetid = surf_id.objid,
        targetos = surf_id.osnum);
  if(sts == OM_W_UNKNOWN_MSG)
   {
    sts = OM_S_SUCCESS;
    new_sol = surf_id;
   }
  if(!(1&msg&sts)) return(OM_E_ABORT);

  sts = EMconvert_into_plane(&msg, EMreplace_DO_DISPLAY, NULL, NULL, NULL, 
        NULL, NULL, NULL, &me->solid_info.module_info, new_sol.objid, 
        new_sol.osnum);
  if(!(1&msg&sts)) return(OM_E_ABORT);
  ex$message(msgnumb = EMS_I_PlanarSurfsCvrtPlanes);  
 }

 }
    break;
   }


   default:
   {
     ERROR(sts, msg, "performsf exec action garbage", wrapup)
   }
  } /*end switch */


  switch(ME.super_cmd->state)
  {

   case start:
   {
    if(me->mytype != 10) ex$message(msgnumb = EMS_S_ClearStatusField);
    display_flag = 6;
    locate_mask = GRm_DATA | GRm_BACK_UP;
    accept_mask = GRm_DATA;   
    ex$message(msgnumb = EMS_P_00031, buff = loc_prompt);
    ex$message(msgnumb = EMS_P_AccSfReject, buff = acc_prompt);
    ex$message(msgnumb = EMS_I_00011, buff = reloc_prompt); 
    strcpy(attr.classes, "EMSsurface");
    attr.properties = 0x11 | LC_RW;
    attr.owner_action = 0x3;

    rtree_classes.w_count = 1;
    elig_classes.w_count = 1;
    rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

    rclass = OPP_EMSsubbs_class_id;
    eliclass = OPP_EMSsurface_class_id;

    rtree_classes.p_classes = &rclass;
    elig_classes.p_classes = &eliclass;

    lc$locate(rc = &msg, 
              event1 = &me->locate_event, 
              event2 = &me->accept_event,
              mask1 = locate_mask, 
              mask2 = accept_mask, 
              eventsize= &size, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              locate_prompt = loc_prompt, 
              acc_prompt = acc_prompt,
              relocate_prompt = reloc_prompt, 
              attributes = &attr, 
              stack = &me->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);

    token = GRloc_token(&msg, Tokens, &me->locate_event);
    break;
   }


   case got_sol:
   {
    /**DUMMY STATE**/
    token = 1; /**DATA INPUT**/
    break;
   }


   default:
   {
     ERROR(sts, msg, "performsf exec state garbage", wrapup)
   }

  } /*switch(state) */

  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 } while(Tokens[token] != GR_UNKNOWN_TYPE);
 return (sts);

 wrapup:
   *response = TERMINATE;
   return(OM_E_ABORT);
}

end implementation ECsptloc;
