/* ###################   APOGEE COMPILED   ################## */
class implementation ECdensity;

/* History gupta - creation - July 21 '89 */

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "OMerrordef.h"
/* igemacros replacement */

# include "grdpbmacros.h" /* gr$get_active_display */

/* end of grutildef.h replacement */

/* grvaluedef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

#include "griomacros.h"
#include "OMmacros.h"
#include "igrdef.h"
#include "codef.h"
#include "msdef.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "lcmacros.h"
#include "grdpbdef.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "dpmacros.h"
#include "EMScmacros.h"
#include "OMobjectcomm.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "ECcmd.h"

# define MAX_CHAR_LEN	80

extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMScompsurf_class_id;
extern GRclassid OPP_EMSmassprop_class_id;

from GRgraphics  import GRdisplay,
                        GRconstruct;
from EMSsurface import  EMcompute_density;
from EMScompsurf import EMreset_density;
from EMSmassprop import EMget_density,
                        EMinitialize,
                        EMupdate_props,
                        EMset_density;

method init (IGRint type; IGRchar *string)
{
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRint bytes_in, bytes_out;
  IGRlong msg;

  strcpy (errmsg, "ECdensity.init");

  bytes_in = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &msg,
		    sizbuf = &bytes_in,
		    buffer = &me->ModuleInfo,
		    nret = &bytes_out);
  EMerr_hndlr_action (EMis_error (msg), msg, msg,
                      printf ("%s\n", errmsg));

  bytes_in = sizeof (struct IGRdisplay);
  gr$get_active_display (msg = &msg, sizbuf = &bytes_in,
      buffer = &me->active_display, nret = &bytes_out);
  EMerr_hndlr_action (EMis_error (msg), msg, msg,
                      printf ("%s\n", errmsg));

  bytes_in = sizeof (IGRshort);
  gr$get_active_level (msg = &msg, sizbuf = &bytes_in,
      buffer = &me->active_level, nret = &bytes_out);
  EMerr_hndlr_action (EMis_error (msg), msg, msg,
                      printf ("%s\n", errmsg));

  ME.super_cmd->state = 0;
  ME.super_cmd->mytype = type;
  
  return (OM_S_SUCCESS);
}


method wakeup (IGRint pos)
{
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRlong stat_OM;

  stat_OM = OM_S_SUCCESS;
  strcpy (errmsg, "ECdensity.wakeup");

  ex$message (msgnumb = EMS_S_ClearStatusField);
  ex$message (msgnumb = EMS_P_ClearPromptField);

  ex$message (msgnumb = EM_M_AssignSolidDensity);

  return (stat_OM);
}

method sleep(int pos)
{
 IGRint sts=OM_S_SUCCESS;
 IGRint msg;

 sts = dp$erase_hilite(msg = &msg);
 if (! (1&sts&msg)) {sts = OM_E_ABORT; goto wrapup;}

 ex$message (msgnumb = EM_M_ClearMessageField);
 ex$message (msgnumb = EMS_S_ClearStatusField);
 ex$message (msgnumb = EMS_P_ClearPromptField);

 wrapup:
  return(sts);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRlong               status;
  GRclassid             obj_class_id;
  IGRchar               errmsg[EMMAXERRMSG_LEN];
  IGRchar               loc_prompt[54], acc_prompt[54], reloc_prompt[54];
  IGRchar               display_message[MAX_CHAR_LEN];
  IGRint                i, j, event_size, display_flag;
  OMuint		chan_count, count;
  IGRint                numb_objs;
  IGRlong               msg, chan_index;
  IGRlong               event_mask1, event_mask2;
  IGRdouble             default_density;
  enum GRdpmode         DisplayMode;
  struct GRevent        accev, event;
  struct GRlc_info	    *group_objs=NULL, current_obj;
  struct GRlc_locate    lc_attr;
  struct GRvg_construct const_list;
  OM_S_CLASSLIST        rtree_classes, elig_classes;
  OM_S_CHANSELECT       notify_chan, to_object;
  OMuword               rclass, eliclass;
  OM_S_OBJECT_LINKAGE   *chan_objects;

  #define     GET_OBJ                 0
  #define     UNIFORM                 1
  #define     GET_UNIFORM_DENSITY     2
  #define     GET_NONUNIFORM_DENSITY  3
  #define     PROCESS                 4

  *response = TERMINATE;
  status = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECdensity.execute");

  status = om$make_chanselect(channame = "GRnotify.notification",
			                   p_chanselect = &notify_chan);
  status = om$make_chanselect(channame = "EMSmassprop.to_object",
			                   p_chanselect = &to_object);

  do 
    {
    switch (ME.super_cmd->state)
      {
       case GET_OBJ:
            status = dp$erase_hilite(msg = &msg);
            EMomerr_hndlr_action (status, *response = TERMINATE; goto
                                  wrapup, errmsg);
	
            event_mask1 = GRm_DATA | GRm_BACK_UP | GRm_SPECIFIED_OBJ;
            event_mask2 = GRm_DATA;
            ex$message(msgnumb = EMS_P_IdSolSet, buff = loc_prompt) ;
            display_flag = 6;

            ex$message(msgnumb = EMS_P_AcceptReject, buff = acc_prompt) 
            ex$message(msgnumb = EMS_I_00012, buff = reloc_prompt) 
            lc_attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 IGN_MOD_BIT;
/*
 * Modified this command to locate associative and externally
 * constrained elements.
 * pp 09/29/91
 */
            lc_attr.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP |
                                   LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED |
                                   LC_REF_OBJECTS | LC_NO_REF_HEADER;
            strcpy(lc_attr.classes, "EMSsurface");

            rtree_classes.w_count = 1;
            elig_classes.w_count = 1;
            rtree_classes.w_flags = elig_classes.w_flags = 
                                    OM_CLST_subclass;
            rclass = OPP_EMSsubbs_class_id;
            eliclass = OPP_EMScompsurf_class_id;

            rtree_classes.p_classes = &rclass;
            elig_classes.p_classes = &eliclass;

            status = lc$locate(rc = &msg,
                               event1 = &me->event_1, 
                               event2 = &accev,
                               mask1 = event_mask1, 
                               mask2 = event_mask2,
                               eventsize= &event_size, 
                               display_flag = display_flag,
                               response = response, 
                               response_data = response_data, 
                               locate_prompt = loc_prompt, 
                               acc_prompt = acc_prompt,
                               relocate_prompt = reloc_prompt, 
                               attributes = &lc_attr, 
                               stack = &me->stack, 
                               rtree_classes = &rtree_classes, 
                               eligible_classes = &elig_classes);

            ex$message (msgnumb = EMS_S_ClearStatusField);
            ex$message (msgnumb = EMS_P_ClearPromptField);

            if (! status)
             {
              ex$message ( msgnumb = EMS_E_FailInputProcExit);
              *response = TERMINATE;
              goto wrapup;
             }
            if (msg == FALSE)
             {
              if (me->event_1.response == EX_BACK_UP)
                  break;
              else
                  goto wrapup;
             }
            else
             {
              extern		IGRlong EMselective_fence();
              OMuword		list1, list2;
              OM_S_CLASSLIST	yes_classes, no_classes;
              list1 = OPP_EMScompsurf_class_id;
              list2 = OPP_EMSsubbs_class_id;
              no_classes.w_count = 1;
              yes_classes.w_count = 1;
              yes_classes.p_classes = &list1;
              no_classes.p_classes = &list2;
              numb_objs = 0;
              group_objs = NULL;
            
              status = EMselective_fence(&yes_classes,
                                         &no_classes,
                                         &accev.located_object[0],
                                         FALSE,
                                         TRUE,
                                         my_id,
                                         &numb_objs,
                                         &group_objs,
                                         &msg);
              if (EMSmsgReport (status, "ECdensityi: sel fence", FALSE))
                  goto wrapup;

              status = om$vla_set_dimension(varray = me->mass_prop_obj,
                                            size = numb_objs);
              if (! (1 & status)) goto wrapup;

              status = om$vla_set_dimension(varray = me->density,
                                            size = numb_objs);
              if (! (1 & status)) goto wrapup;

              me->num_objects = numb_objs;

              for (j=0; j<numb_objs; j++)
               {
                me->mass_prop_obj[j].objid = NULL_OBJID;
  
                status = om$get_channel_count (
                                 osnum = group_objs[j].located_obj.osnum,
                                 objid = group_objs[j].located_obj.objid,
                                 p_chanselect = &notify_chan,
                                 count = &chan_count);
                if (! (1 & status)) goto wrapup;
 
                chan_objects = NULL;
   
                if (chan_count)
                 {
                  chan_objects = (OM_S_OBJECT_LINKAGE *) om$malloc(size = 
                             chan_count * (sizeof (OM_S_OBJECT_LINKAGE)));
                  if (! chan_objects) goto wrapup;
                 }

                status = om$get_channel_objects (
                                 osnum = group_objs[j].located_obj.osnum,
                                 objid = group_objs[j].located_obj.objid,
                                 p_chanselect = &notify_chan,
                                 list = chan_objects,
                                 size = chan_count,
                                 count = &count);
                if (! (1 & status)) goto wrapup;

                for (i=0; i<chan_count; i++)
                 {
                  status = om$get_classid(osnum = chan_objects[i].osnum,
                                          objid = chan_objects[i].S_objid,
                                          p_classid = &obj_class_id);
                  if (! (1 & status)) goto wrapup;

                  if (obj_class_id == OPP_EMSmassprop_class_id)
                   {
                    me->mass_prop_obj[j].objid = chan_objects[i].S_objid;
                    me->mass_prop_obj[j].osnum = chan_objects[i].osnum;
                    break;
                   }
                 }

                if (chan_objects) om$dealloc (ptr = chan_objects);
               }
             }

            ME.super_cmd->state = (me->num_objects <= 1) ?
                                   GET_NONUNIFORM_DENSITY : UNIFORM;
            break;

       case UNIFORM:

            ex$message(msgnumb = EMS_P_UniformDensity, buff = display_message);

            status = EMSokay (co$getevent (
                              msg = &msg,
                              event_mask = GRm_TEXT_VALUE | GRm_BACK_UP |
                                           GRm_RJT_MOVEON,
                              prompt = display_message,
                              response = response,
                              response_data = response_data,
                              event = &event));

            ex$message (msgnumb = EMS_P_ClearPromptField);
            if (! status)
             {
              ex$message ( msgnumb = EMS_E_FailInputProcExit);
              *response = TERMINATE;
              goto wrapup;
             }

            if (msg == GRw_no_value) event.response = EX_RJT_MOVEON;

            switch (event.response)
             {
              case STRING:
                   if (toupper (event.event.keyin[0]) == 'Y')
                    {
                     me->is_uniform = TRUE;
                     ME.super_cmd->state = GET_UNIFORM_DENSITY;
                    }
                   else if (toupper (event.event.keyin[0]) == 'N')
                    {
                     me->is_uniform = FALSE;
                     ME.super_cmd->state = GET_NONUNIFORM_DENSITY;
                    }
                   else 
                    {
                     me->is_uniform = FALSE;
                     ME.super_cmd->state = GET_NONUNIFORM_DENSITY;
                    }
                   break;
              case EX_RJT_MOVEON:
                   me->is_uniform = FALSE;
                   ME.super_cmd->state = GET_NONUNIFORM_DENSITY;
                   break;
              case EX_BACK_UP:
		   if(group_objs)
		     {
/* fix for mlk */
		     om$dealloc(ptr = group_objs);
		     group_objs = NULL;
		     }
                   ME.super_cmd->state = GET_OBJ;
                   break;
              default:
                   goto wrapup;
             }
            break;

       case GET_UNIFORM_DENSITY:

            for (j=0; j<me->num_objects; j++) me->density[j] = 1.0;

            ex$message ( msgnumb = EMS_S_WarnDensityOverW);

            ex$message ( msgnumb = EMS_P_KeyInDensity,
                         type    = "%lf",
                         var     = `me->density[0]`,
                         buff    = display_message);

            status = co$getevent(msg = &msg,
                                 event_mask = (GRm_VALUE |
                                               GRm_RJT_MOVEON |
                                               GRm_DATA       |
                                               GRm_BACK_UP),
                                 prompt        = display_message,
                                 response      = response,
                                 response_data = response_data,
                                 event         = &event,
                                 value_type    = GRIO_SCALAR); 

            if (! status) goto wrapup;
            if (msg == GRw_no_value)
                event.response = EX_RJT_MOVEON;
            
            if (event.response IS GR_UNKNOWN_TYPE)
               {
	       if(group_objs)
		 {
                  /* fix for mlk */
		 om$dealloc(ptr = group_objs);
		 group_objs = NULL;
		 }
               return(OM_S_SUCCESS);
               }
            else if (event.response IS EX_BACK_UP)
             {
              ME.super_cmd->state = UNIFORM;
              ex$message (msgnumb = EMS_S_ClearStatusField);
             }
            else if (event.response IS EX_RJT_MOVEON)
             {
              for (j=0; j<me->num_objects; j++)
               {
                status = om$send(msg = message
                                       EMScompsurf.EMreset_density(&msg, 
                                       &me->density[j]),
                              targetos = group_objs[j].located_obj.osnum,
                              targetid = group_objs[j].located_obj.objid);
               }
              ME.super_cmd->state = PROCESS;
              ex$message (msgnumb = EMS_S_ClearStatusField);
             }
            else	/* we have density one way or other */
	         { 
              if ((event.response == VALUE) && (msg != GRw_no_value))
               {
                for (j=0; j<me->num_objects; j++)
                 {
                  if (me->mass_prop_obj[j].objid != NULL_OBJID)
                   {
                    status = om$send(msg = message
                                         EMSmassprop.EMupdate_props(&msg, 
                                         event.event.value),
                                   targetid = me->mass_prop_obj[j].objid,
                                   targetos = me->mass_prop_obj[j].osnum);
                    if (! (1 & status & msg)) goto wrapup;
                   }
                  me->density[j] = event.event.value;

                  status = om$send(msg = message
                                        EMScompsurf.EMreset_density(&msg, 
                                        &me->density[j]),
                              targetos = group_objs[j].located_obj.osnum,
                              targetid = group_objs[j].located_obj.objid);
                 }
               }
              ME.super_cmd->state = PROCESS;
              ex$message (msgnumb = EMS_S_ClearStatusField);
	         }
            break;

       case GET_NONUNIFORM_DENSITY:

            default_density = 1.0;

            for (j=0; j<me->num_objects; j++)
             {
              me->density[j] = 1.0;
  
              DisplayMode = GRhd;
              status = om$send(msg = message GRgraphics.GRdisplay (&msg,
                                     &me->ModuleInfo.md_env.matrix_type,
                                     me->ModuleInfo.md_env.matrix,
                                     &DisplayMode, &me->ModuleInfo.md_id),
                              targetos = group_objs[j].located_obj.osnum,
                              targetid = group_objs[j].located_obj.objid);
              if(EMSmsgReport(status,"ECdensity:hidraw",FALSE))
                 goto wrapup;

              if (me->mass_prop_obj[j].objid != NULL_OBJID)
               {
                status = om$send(msg = message EMSmassprop.EMget_density(
                                       &msg, &me->density[j]),
                                 targetos = me->mass_prop_obj[j].osnum,
                                 targetid = me->mass_prop_obj[j].objid);
                if (! (1 & status & msg)) goto wrapup;
                if (j == me->num_objects - 1)
                 {
                  ME.super_cmd->state = PROCESS;
                  ex$message (msgnumb = EMS_S_ClearStatusField);
                 }
               } 

              if (me->mass_prop_obj[j].objid != NULL_OBJID)
               {
            ex$message ( msgnumb = EMS_P_KeyInDensity,
                         type    = "%lf",
                         var     = `me->density[0]`,
                         buff    = display_message);
                default_density = me->density[j];
               }
              else
               {
                status=om$send(msg = message EMSsurface.EMcompute_density(
                                     &msg, &me->ModuleInfo, 
                                     &default_density),
                              targetos = group_objs[j].located_obj.osnum,
                              targetid = group_objs[j].located_obj.objid);
                if (! (1 & status & msg)) goto wrapup;

                if ((default_density == 1.0) && (j > 1))
                     default_density = me->density[j-1];

            ex$message ( msgnumb = EMS_P_KeyInDensity,
                         type    = "%lf",
                         var     = `me->density[0]`,
                         buff    = display_message);
               }

              status = co$getevent(msg = &msg,
                                   event_mask = (GRm_VALUE |
                                                 GRm_RJT_MOVEON |
                                                 GRm_DATA       |
                                                 GRm_BACK_UP),
                                   prompt        = display_message,
                                   response      = response,
                                   response_data = response_data,
                                   event         = &event,
                                   value_type    = GRIO_SCALAR); 

              if (! status) goto wrapup;
              if (msg == GRw_no_value)
                  event.response = EX_RJT_MOVEON;
            
              if (event.response IS GR_UNKNOWN_TYPE)
		 {
		 if(group_objs)
		   {
		   om$dealloc(ptr = group_objs);
		   group_objs = NULL;
		   }
                 return(OM_S_SUCCESS);
		 }
              else if (event.response IS EX_BACK_UP)
               {
                ME.super_cmd->state = GET_OBJ;
                ex$message (msgnumb = EMS_S_ClearStatusField);
               }
              else if (event.response IS EX_RJT_MOVEON)
               {
                DisplayMode = GRbdhe;
                status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                     &me->ModuleInfo.md_env.matrix_type,
                                     me->ModuleInfo.md_env.matrix,
                                     &DisplayMode, &me->ModuleInfo.md_id),
                         targetos = group_objs[j].located_obj.osnum,
                         targetid = group_objs[j].located_obj.objid);
                if (EMSmsgReport(status, "ECdensity:bdhddraw", FALSE))
                    goto wrapup;
     
                me->density[j] = default_density;

                status = om$send(msg = message
                                       EMScompsurf.EMreset_density(&msg, 
                                       &me->density[j]),
                              targetos = group_objs[j].located_obj.osnum,
                              targetid = group_objs[j].located_obj.objid);

                if (j == me->num_objects-1)
                 {
                  ME.super_cmd->state = PROCESS;
                  ex$message (msgnumb = EMS_S_ClearStatusField);
                 }
                continue;
               }
              else	/* we have density one way or other */
               { 
                DisplayMode = GRbdhe;
                status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                     &me->ModuleInfo.md_env.matrix_type,
                                     me->ModuleInfo.md_env.matrix,
                                     &DisplayMode, &me->ModuleInfo.md_id),
                         targetos = group_objs[j].located_obj.osnum,
                         targetid = group_objs[j].located_obj.objid);
                if (EMSmsgReport(status, "ECdensity:bdhddraw", FALSE))
                    goto wrapup;
                if ((event.response == VALUE) && (msg != GRw_no_value))
                 {
                  if ((me->mass_prop_obj[j].objid != NULL_OBJID) &&
                      (me->density[j] != event.event.value))
                   {
                    status = om$send(msg = message
                                         EMSmassprop.EMupdate_props(&msg, 
                                         event.event.value),
                                   targetid = me->mass_prop_obj[j].objid,
                                   targetos = me->mass_prop_obj[j].osnum);
                    if (! (1 & status & msg)) goto wrapup;
                   }
		          me->density[j] = event.event.value;
                  default_density = me->density[j];

                  status = om$send(msg = message
                                        EMScompsurf.EMreset_density(&msg, 
                                        &default_density),
                              targetos = group_objs[j].located_obj.osnum,
                              targetid = group_objs[j].located_obj.objid);
                 }
                if (j == me->num_objects - 1)
                 {
                  ME.super_cmd->state = PROCESS;
                  ex$message (msgnumb = EMS_S_ClearStatusField);
                 }
                else
                 {
                  continue;
                 }
	           }
             }

            break;

       case PROCESS:

            ex$message (msgnumb = EMS_S_ClearStatusField);
            ex$message (msgnumb = EMS_S_ProcessingFour);

            const_list.msg = &msg;
            const_list.env_info = &me->ModuleInfo;
            const_list.newflag = FALSE;
            const_list.level = me->active_level;
            const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
            const_list.geometry = NULL;
            const_list.display = &me->active_display;
            const_list.class_attr = NULL;
            const_list.name = NULL;

            for (j=0; j<me->num_objects; j++) /* for all objects */
             {
              OM_BLOCK_MOVE (&group_objs[j], &current_obj,
                             sizeof(struct GRlc_info));
              if (me->mass_prop_obj[j].objid == NULL_OBJID)
               {
                /* construct and connect */

                status = om$construct (classid=OPP_EMSmassprop_class_id,
                                   osnum = current_obj.located_obj.osnum,
                                   p_objid = &me->mass_prop_obj[j].objid,
                                   msg = message GRgraphics.GRconstruct(
                                   &const_list));
                if (! (1 & status)) goto wrapup;

                me->mass_prop_obj[j].osnum= current_obj.located_obj.osnum,
                chan_index = GRDGNLIMITS_MAX_I;

                status = om$send(msg = message Root.connect(to_object,
                                       chan_index,
                                       current_obj.located_obj.objid,
                                       current_obj.located_obj.osnum,
                                       notify_chan,
                                       0),
                                 targetid = me->mass_prop_obj[j].objid,
                                 targetos = me->mass_prop_obj[j].osnum);
                if (! (1 & status)) goto wrapup;

                status = om$send(msg = message
                                       EMSmassprop.EMinitialize(&msg),
                                 targetid = me->mass_prop_obj[j].objid,
                                 targetos = me->mass_prop_obj[j].osnum);
                if (! (1 & status & msg)) goto wrapup;
               }

              status = om$send(msg = message EMSmassprop.EMset_density(
                                     &msg, me->density[j]),
                               targetid = me->mass_prop_obj[j].objid,
                               targetos = me->mass_prop_obj[j].osnum);
              if (! (1 & status & msg)) goto wrapup;
             }

	    if(group_objs)
	      {
	      om$dealloc(ptr = group_objs);
	      group_objs = NULL;
	      }
            ME.super_cmd->state = GET_OBJ;
            ex$message (msgnumb = EMS_P_ClearPromptField);
            ex$message (msgnumb = EMS_S_ClearStatusField);
            break;

       default:
            ex$message (msgnumb = EMS_F_CommandIllegalState);
            printf ("Command is in illegal state - %d\n",
                    ME.super_cmd->state);
            *response = TERMINATE;
            goto wrapup;
      }
    }
  while (TRUE);

wrapup:
  if(group_objs)
    {
    om$dealloc(ptr = group_objs);
    group_objs = NULL;
    }
  return (status);
}

end implementation ECdensity;

