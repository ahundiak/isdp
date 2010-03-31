/* ###################   APOGEE COMPILED   ################## */
/*
 This command object computes mass and area properties.

 History

 ??/??/87 : gk    : Govinda Kuntimad originally wrote this command
 ??/??/88 : RV    : Rahul Vora fixed some problems which regards to
                    translating the solid near the origin before
                     computation of properties
 09/07/88 : rlw   : Took out a print statement.
                    Modified to display the volume or area (as
                    appropriate) in the message field.
                    Externed functions for shared libraries.
                    Added support for graphic groups.
                    Modified such that accumulation is stopped when one
                    backs up from the density prompt.
 11/01/88 : pp    : Added code to output the triad into the database as
                    an  option
 01/17/89 : rlw   : Modified triad prompt to accept a moveon as input and
                    for the next state to backup into this state.
 07/20/89 : gupta : Changes for objects with assigned density and support
                    for mass_prop/area_prop object..... rewrite
 01/22/90 : pp    : Fixed a problem occuring when number of valid
                    objects selected for computation of mass properties
                    / area properties was 0. The system used to hang at 
                    such a time.
 02/16/90 : pp    : Made changes to support outputting first area moments
                    to fulfill NAVSEA MMR.
 05/07/90 :Inasu  : Fix for TR 90N0628.
 06/16/93 :Sudha  : Modified for BSprototype ansification
 07/02/93 :sampath: Fix for TR 119222575.

 */
class implementation ECmassp;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include <stdio.h>

#include "bsdefs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSlogic.h"
#include "EMS_I.h"
#include "EMSmsgdef.h"
#include "maoptsxfo.h"
#include "bseig3x3.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

# include "griomacros.h"
# include "OMmacros.h"
# include "csdef.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "dpmacros.h"
# include "EMScmacros.h"

# include "lcmacros.h"

# include "grgsdef.h"
# include "grgsmacros.h"
# include "DIdef.h" /* DI_PATH_MAX */
# include "msdef.h"
# include "msmacros.h"
# include "ECmsg.h"
# include "ECcmd.h"
 
# define NUMB_PROPS 20
# define MAX_CHAR_LEN	80

from GRgraphics import  GRdisplay,
                        GRdelete,
                        GRconstruct;
from GRvg       import  GRgetrang,
                        GRgetname;
from GRowner    import  GRget_number_components;
from EMSsurface import	EMmassprop, EMareaprop, EMcompute_density,
                        EMgetDescription;
from EMScompsurf import EMreset_density;
from EMSmassprop import EMget_density,
                        EMset_density,
                        EMreadprop,
                        EMload_prin_axes,
                        EMupdate_props,
                        EMget_gloloc,
                        EMinitialize,
                        EMedit_mass_prop,
                        EMupdate_orient,
                        EMrefxform,
                        EMretn_mass_prop,
                        EMget_orient,
                        EMset_type;

extern OMuword	OPP_EMSsurface_class_id, OPP_GRowner_class_id;
extern GRclassid  OPP_EMSmassprop_class_id;

%safe
static  void                   rlw_echo_stuff();
%endsafe
/*------------------------------------------------------ */

method init(int type; char *str_ptr)
{

  IGRlong               bytes_in, bytes_out, msg, j;
  
  ME.super_cmd->state = 0;
  ME.super_cmd->mytype = type;
  me->numb_accumulated = 0;
  me->mass_prop_obj[0].objid = NULL_OBJID;
  me->max_sld = 0.0;
  me->density[0] = 1.0;
  me->stderr_only = TRUE;
  me->area_only = FALSE;

  for (j=0; j<NUMB_PROPS; j++) me->acc_prop[j] = 0.0;

  OM_SET_DIMENSION(me->accumulated_objs, 20);

  bytes_in = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &msg,
		    sizbuf = &bytes_in,
		    buffer = &me->ModuleInfo,
		    nret = &bytes_out);
  if (! (1 & msg))
   {
    fprintf(stderr, "ECmassp:get_module_env error %d", msg);
    return(OM_E_ABORT);
   }

  return (OM_S_SUCCESS);
}


method sleep (int pos )
{
 IGRlong msg;

 ex$message (msgnumb = EM_M_ClearMessageField);
 ex$message (msgnumb = EMS_S_ClearStatusField);
 ex$message (msgnumb = EMS_P_ClearPromptField);

 if (me->numb_accumulated)
  {
   dp$erase_hilite(msg = &msg);
  }
 return (OM_S_SUCCESS);
}


method wakeup ( int pos )
{
  IGRlong		j, status, msg;
  enum GRdpmode		DisplayMode;

  if (ME.super_cmd->mytype IS 0)
     ex$message ( msgnumb = EM_M_EvalMassProps)
  else if (ME.super_cmd->mytype IS 1)
     ex$message (msgnumb = EM_M_EvalAreaProps );

  if (me->numb_accumulated)	/* display all the solids */
   {
    DisplayMode = GRhd;
    for (j=0; j<me->numb_accumulated; j++)
     {
      status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                             &me->ModuleInfo.md_env.matrix_type,
                             me->ModuleInfo.md_env.matrix,&DisplayMode,
                             &me->ModuleInfo.md_id),
                       targetos = me->accumulated_objs[j].osnum,
                       targetid = me->accumulated_objs[j].objid);
      if (EMSmsgReport (status, "ECmassp: wakeup", FALSE))goto wrapup;
     }
   }

wrapup:
  return ( OM_S_SUCCESS );
}


method execute ( int *response; char *response_data; int pos )
{
 IGRlong		        status, msg, i, j, k,
                        event_size;
 IGRint			msg_loc;
 GRclassid              obj_class_id;
 struct GRevent      	event;
 struct GRlc_locate  	attributes;
 struct GRlc_info	    *group_objs = NULL;
 OM_S_CLASSLIST         rtree_classes, elig_classes;
 OMuword                rclass, eliclass[2];
 IGRlong                locate_mask, accept_mask, display_flag;
 OMuint                 count, chan_count;
 IGRchar                prompt_message[MAX_CHAR_LEN], 
                        acc_prompt[MAX_CHAR_LEN],
                        reloc_prompt[MAX_CHAR_LEN];
 IGRchar                display_message[MAX_CHAR_LEN],
                        master_units[MAX_CHAR_LEN], 
                        obj_descr[2 * MAX_CHAR_LEN],
                        c_name[50],
                        object_name[DI_PATH_MAX];
 IGRlong                numb_objs;
 IGRint                 coord_type, chan_index, num_surfaces; 
 IGRboolean             world = TRUE, validity=FALSE;
 IGRpoint               old_centroid, act_centroid, old_vol_centroid;
 IGRdouble              ref_origin[3];
 IGRdouble		        prop[NUMB_PROPS], prop1[NUMB_PROPS],
                        area_prop[NUMB_PROPS],
                        scaling_factor = 1.0, sld, factor, tol, negtol,
                        solid_range[6], area_axes[9];
 IGRdouble              eig_matrix[3][3], ref_point[3];
 IGRdouble              in_origin[3], dest_origin[3];
 IGRdouble              in_glo_loc[9], dest_glo_loc[9];
 static IGRdouble       identity_matrix[9] = { 1.0,  0.0,  0.0, 
                                               0.0,  1.0,  0.0, 
                                               0.0,  0.0,  1.0 };
 IGRdouble              xxx, default_density;
 IGRvector              trans_vector;
 BSrc                   bsmsg;
 extern void            MSdisplay_prop(), MSdrawtriad(), MSaccprop(),
                        MSget_master_string();
 FILE                   *prop_file;
 struct GRid            triad_id;
 enum GRdpmode          DisplayMode;
 struct IGRdisplay      display_attr;
 OM_S_CHANSELECT        notify_chan, to_object,
                        to_comps;
 OM_S_OBJECT_LINKAGE    *chan_objects;
 IGRchar                tmprompt[54];

 #define     INIT                    0
 #define     GET_FILE_NAME           1
 #define     GET_DENSITY             2
 #define     GET_OBJ                 3
 #define     PROCESS                 4
 #define     ACC_DONE                5
 #define     UNIFORM                 6

 status = om$make_chanselect (channame = "GRnotify.notification",
                              p_chanselect = &notify_chan);
 status = om$make_chanselect (channame = "EMSmassprop.to_object",
                              p_chanselect = &to_object);
 status = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_comps);

 DisplayMode = GRhd;
 trans_vector[0] = 0.0;
 trans_vector[1] = 0.0;
 trans_vector[2] = 0.0;

/*  BSEXTRACTPAR(&bsmsg, BSVALBASIS, tol);  --- BUG FOUND DURING APOGEE 
   						COMPILATION. REPLACED THIS LINE
						WITH FOLLOWING LINE - Ashok */
 BSEXTRACTPAR(&bsmsg, BSTOLBASIS, tol);
 tol *= 5.0;
 negtol = -tol;

 event_size = sizeof(struct GRevent);

 /* locate attributes initialization */

 strcpy(attributes.classes, "EMSsurface");

 attributes.properties   = LC_LC_ONLY  |
                           LC_DP_ONLY  |
                           IGN_MOD_BIT |
                           LC_RW;

 attributes.owner_action = LC_RIGID_OWNER |
                           LC_FLEX_OWNER  |
                           LC_FLEX_COMP   |
                           LC_REF_OBJECTS |
                           LC_NO_REF_HEADER;

 /* locate display options */

 /* display_flag = ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT; */

 display_flag =  
             ELEM_HILIGHT	   |  /* Hilite the whole element */
             NO_PROJ_ACCEPT_POINT  |  /* Don't project the accept point */
             ACC_REJ_CYCLE         |  /* Run through accept reject cycle*/
             RELOCATE              |  /* Relocate if none found */
             LC_REGULAR_HIGHLIGHT  |  /* Use regular hilite not 1/2 */
             LC_ERASE_ALL;            /* Erase hilite */


 /* locate class eligibility */

 rtree_classes.w_count = 1;
 rtree_classes.w_flags = OM_CLST_subclass;
 rclass = OPP_EMSsurface_class_id;
 rtree_classes.p_classes = &rclass;

 elig_classes.w_flags = OM_CLST_subclass;
 elig_classes.w_count = 2;
 eliclass[0] = OPP_EMSsurface_class_id;
 eliclass[1] = OPP_GRowner_class_id;		/* Groups */
 elig_classes.p_classes = &eliclass[0];

 /* locate masks */

 accept_mask = GRm_DATA;
 locate_mask = GRm_DATA | GRm_TEXT_VALUE | GRm_BACK_UP |
               GRm_SPECIFIED_OBJ | GRm_RJT_MOVEON;

 /* locate prompts */

 ex$message (msgnumb = EMS_P_00038,
             buff    = acc_prompt);

 ex$message (msgnumb = EMS_I_EltNotLocated,
             buff    = reloc_prompt);

 /* differentiate between area and mass properties */

 if (ME.super_cmd->mytype IS 0)
  {
   me->option = 1;
   me->option1 = 2;
   attributes.owner_action |= LC_RIGID_COMP;
  }
 else
  {
   me->option = me->option1 = 0;
   attributes.owner_action |= LC_RIGID_COMP;
  }

 do
  {
   switch (ME.super_cmd->state)
    {
     case INIT:
     case GET_FILE_NAME:
          
          me->stderr_only = FALSE;
          ex$message (msgnumb = EMS_S_ClearStatusField);
          ex$message ( msgnumb = EMS_P_KeyINOutfileName,
                       buff    = display_message);

          status = co$getevent(msg           = &msg,
                               event_mask    = GRm_TEXT_VALUE |
                                               GRm_RJT_MOVEON,
                               prompt        = display_message,
                               response      = response,
                               response_data = response_data,
                            event         = &event);

          if (msg == GRw_no_value) event.response = EX_RJT_MOVEON;
          if (! status) goto wrapup;
          else if (event.response IS GR_UNKNOWN_TYPE)
                   return(OM_S_SUCCESS);
          else if (event.response IS EX_RJT_MOVEON)
           {
            me->stderr_only = TRUE;
           }
          else
           {
            me->stderr_only = FALSE;
            strcpy(me->file_name, event.event.keyin);

            /* does a file by this name exist. if so warn the user */

            if (me->file_name[0] IS 0) break;	/* return was hit */

            prop_file = (FILE *) fopen(me->file_name, "r");

            if (prop_file)
              ex$message ( msgnumb = EMS_S_FileExistWillAppT );
            fclose(prop_file);
           }

          ME.super_cmd->state = GET_OBJ;
 
	      break;

     case GET_OBJ:

          if (ME.super_cmd->mytype IS 0)	/* mass prop */
           {
            ex$message ( msgnumb = EMS_P_IdSolSurfSet,
                         buff    = prompt_message);
            if (me->numb_accumulated > 1)
              {
                ex$message (msgnumb = EMS_P_MoveOn,
                            buff    = tmprompt);
                strcat(prompt_message, tmprompt);
              }
            if (me->numb_accumulated > 1)
             {
              ex$message ( msgnumb = EMS_P_NumSoFar,
                           type    = "%3d",
                           var     = `me->numb_accumulated`,
                           buff    = display_message);

              ex$message ( msgnumb = EMS_P_Density,
                           type    = "%lg",
                           var     = `me->density[0]`,
                           buff    = tmprompt);

              strcat (display_message, tmprompt);

              UI_status(display_message);
              ex$message(msgnumb = EMS_S_ClearStatusField);
              ex$message(msgnumb = EMS_S_MvonEvalCumMassProps);
             }
            status = gr$gsput_locate_criteria(msg = &msg,
                                     attributes = &attributes,
                                     rtree_classes = &rtree_classes,
                                     eligible_classes = &elig_classes);
           }
          else if (ME.super_cmd->mytype IS 1) /* area prop */
           {
            ex$message ( msgnumb = EMS_P_IdSolSurfSet,
                         buff    = prompt_message);
            if (me->numb_accumulated > 1)
              {
                ex$message (msgnumb = EMS_P_MoveOn,
                            buff    = tmprompt);
                strcat(prompt_message, tmprompt);
              }
            if (me->numb_accumulated > 1)
             {
              ex$message ( msgnumb = EMS_P_NumSoFar,
                           type    = "%3d",
                           var     = `me->numb_accumulated`,
                           buff    = display_message);

              UI_status(display_message);

              ex$message(msgnumb = EMS_S_ClearStatusField);
              ex$message(msgnumb = EMS_S_MvonEvalCumAreaProps);
             }
           }

          status = lc$locate(rc            = &msg,
                             event1        = &me->event_1,
                             event2        = &event,
                             mask1         = locate_mask,
                             mask2         = accept_mask,
                             eventsize     = &event_size,
                             display_flag  = display_flag,
                             unhilight_mode = (enum GRdpmode ) GRhd,
                             response      = response,
                             response_data = response_data,
                             locate_prompt = prompt_message,
                             acc_prompt    = acc_prompt,
                             relocate_prompt  = reloc_prompt,
                             attributes       = &attributes,
                             stack            = &me->stack,
                             rtree_classes    = &rtree_classes,
                             eligible_classes = &elig_classes,
                             regex            = TRUE);

          if (! status ) goto wrapup;
          else if ((event.response IS GR_UNKNOWN_TYPE) OR
                  (me->event_1.response IS GR_UNKNOWN_TYPE))
           {
            dp$erase_hilite(msg = &msg);
            return(OM_S_SUCCESS);
           }
          else if (me->event_1.response IS EX_BACK_UP)
           {
            for (i=0; i<NUMB_PROPS; i++) me->acc_prop[i] = 0.0;
            me->numb_accumulated = 0;
            ME.super_cmd->state = GET_FILE_NAME;
           }
          else if (me->event_1.response IS EX_RJT_MOVEON)	/* done */
           {
            if (me->numb_accumulated > 1) ME.super_cmd->state = ACC_DONE;
           }
          else
           {
            extern		IGRlong EMselective_fence();
            OMuword		surfaces;
            OM_S_CLASSLIST	yes_classes, no_classes;
            surfaces = OPP_EMSsurface_class_id;
            no_classes.w_count = 0;
            yes_classes.w_count = 1;
            yes_classes.p_classes = &surfaces;

            numb_objs = 0;
            group_objs = NULL;
            
            status = EMselective_fence(&yes_classes,
                                       &no_classes,
                                       &event.located_object[0],
                                       FALSE,
                                       TRUE,
                                       my_id,
                                       &numb_objs,
                                       &group_objs,
                                       &msg);
            if (EMSmsgReport (status, "ECmasspi: sel fence", FALSE))
                goto wrapup;

/*
 * Added this code as when numb_objs was 0 it used to hang.
 * pp (01/22/90)
 */ 

            if (!numb_objs)
            {
             ex$message ( msgnumb = EMS_S_InvInp);
             dp$erase_hilite(msg = &msg);
             break;
            }

/* end pp */
            status = om$vla_set_dimension(varray = me->mass_prop_obj,
                                          size = numb_objs);
            if (! (1 & status)) goto wrapup;

            status = om$vla_set_dimension(varray = me->density,
                                          size = numb_objs);
            if (! (1 & status)) goto wrapup;
            me->num_objects = numb_objs;


            /*** Added the following to capture group_objs into instance
                 data, as this is used in another state (GET_DENSITY) of
                 the command. Unless this is done 'group_objs' will be junk
                 if the command is stacked and returned to the GET_DENSITY
                 state.
                 SM 2/8/93
            ****/
            status = om$vla_set_dimension(varray = me->group_objs,
                                          size = numb_objs);
            if (! (1 & status)) goto wrapup;
            OM_BLOCK_MOVE(group_objs, me->group_objs,
                          numb_objs*sizeof(struct GRlc_info));
            /** End SM 2/8/93 **/

            for (k=0; k<numb_objs; k++)
             {
              me->mass_prop_obj[k].objid = NULL_OBJID;
  
              status = om$get_channel_count (
                               osnum = group_objs[k].located_obj.osnum,
                               objid = group_objs[k].located_obj.objid,
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
                              osnum = group_objs[k].located_obj.osnum,
                              objid = group_objs[k].located_obj.objid,
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
                  me->mass_prop_obj[k].objid = chan_objects[i].S_objid;
                  me->mass_prop_obj[k].osnum = chan_objects[i].osnum;
                  break;
                 }
               }

              if (chan_objects) om$dealloc (ptr = chan_objects);
             }

            if (ME.super_cmd->mytype IS 0)
             {
              if (numb_objs > 1)
                  ME.super_cmd->state = UNIFORM;
              else
               {
                me->is_uniform = FALSE;
                ME.super_cmd->state = GET_DENSITY;
               }
             }
            else
                ME.super_cmd->state = PROCESS;
		if(group_objs)
		{
	/* fix for mlk */
		om$dealloc(ptr = group_objs);
		group_objs = NULL;
		}
           }
         break;


     case UNIFORM:

        ex$message ( msgnumb = EMS_P_UniformDensity,
                     buff    = display_message);

        status = EMSokay (co$getevent (
            msg = &msg,
            event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON,
            prompt = display_message,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message (msgnumb = EMS_P_ClearPromptField);

        if (status == FALSE)
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
              ME.ECmassp->is_uniform = TRUE;
             }
            else if (toupper (event.event.keyin[0]) == 'N')
             {
		/* Elements should go to halhilite 
		   when non-uniform density is choosen.
		   Fix 119222575.
		*/
          	for (k=0; k<me->num_objects; k++)
           	{
              	DisplayMode = GRhhd;
              	status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                     &me->ModuleInfo.md_env.matrix_type,
	                                 me->ModuleInfo.md_env.matrix,
                                     &DisplayMode, &me->ModuleInfo.md_id),
                              targetos = me->group_objs[k].located_obj.osnum,
                              targetid = me->group_objs[k].located_obj.objid);
              	if(EMSmsgReport(status,"ECmassp:hidraw", FALSE))goto wrapup;
           	}
              ME.ECmassp->is_uniform = FALSE;
             }
            else 
             {
              ME.ECmassp->is_uniform = FALSE;
             }
            ME.super_cmd->state = GET_DENSITY;
            break;
          case EX_RJT_MOVEON:

            /* Fix for TR.119222575 - Vadi */

            for (k=0; k<me->num_objects; k++)
                {
                DisplayMode = GRhhd;
                status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                     &me->ModuleInfo.md_env.matrix_type,
                                         me->ModuleInfo.md_env.matrix,
                                     &DisplayMode, &me->ModuleInfo.md_id),
                              targetos = me->group_objs[k].located_obj.osnum,
                              targetid = me->group_objs[k].located_obj.objid);
                if(EMSmsgReport(status,"ECmassp:hidraw", FALSE))goto wrapup;
                }
            ME.ECmassp->is_uniform = FALSE;
            ME.super_cmd->state = GET_DENSITY;
            break;
          case EX_BACK_UP:
            ME.super_cmd->state = GET_OBJ;
            break;
          default:
            return(OM_S_SUCCESS);
          }
        break;


     case GET_DENSITY:

        default_density = 1.0;
        if (me->is_uniform)
         {
          for (j=0; j<me->num_objects; j++) me->density[j] = 1.0;

          ex$message ( msgnumb = EMS_S_WarnDensityOverW);

          ex$message ( msgnumb = EMS_P_KeyInDensity,
                       type    = "%lg",
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
               return(OM_S_SUCCESS);
          else if (event.response IS EX_BACK_UP)
           {
            ME.super_cmd->state = UNIFORM;
            ex$message ( msgnumb = EMS_S_ClearStatusField);

           }
          else if (event.response IS EX_RJT_MOVEON)
           {
            for (j=0; j<me->num_objects; j++)
             {
              status = om$send(msg = message

                                     EMScompsurf.EMreset_density(&msg, 
                                     &me->density[j]),
                              targetos = me->group_objs[j].located_obj.osnum,
                              targetid = me->group_objs[j].located_obj.objid);
             }
            ME.super_cmd->state = PROCESS;
            ex$message ( msgnumb = EMS_S_ClearStatusField);

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
                              targetos = me->group_objs[j].located_obj.osnum,
                              targetid = me->group_objs[j].located_obj.objid);
                 }
               }
              ME.super_cmd->state = PROCESS;
              ex$message ( msgnumb = EMS_S_ClearStatusField);
	         }
         }
        else
         { 
          for (k=0; k<me->num_objects; k++)
           {
            me->density[k] = 1.0;
  
            if (me->num_objects > 1)
             {
              DisplayMode = GRhd;
              status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                     &me->ModuleInfo.md_env.matrix_type,
	                                 me->ModuleInfo.md_env.matrix,
                                     &DisplayMode, &me->ModuleInfo.md_id),
                              targetos = me->group_objs[k].located_obj.osnum,
                              targetid = me->group_objs[k].located_obj.objid);
              if(EMSmsgReport(status,"ECmassp:hidraw", FALSE))goto wrapup;
             }

            if ((me->mass_prop_obj[k].objid != NULL_OBJID) && (validity))
             {
              status = om$send(msg = message EMSmassprop.EMget_density(
                                     &msg, &me->density[k]),
                               targetos = me->mass_prop_obj[k].osnum,
                               targetid = me->mass_prop_obj[k].objid);
              if (! (1 & status & msg)) goto wrapup;
              if (k == me->num_objects - 1)
               {
                ME.super_cmd->state = PROCESS;
                ex$message ( msgnumb = EMS_S_ClearStatusField);
                continue;
               }
              else
               {
                continue;
               }
/* The next line is an unreachable statement ???? - Ashok */
/************************************* SM 2/8/93 - commented out to
prevent a warning.

              if (me->num_objects > 1)
               {
                DisplayMode = GRhd;
                status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                       &me->ModuleInfo.md_env.matrix_type,
	                                   me->ModuleInfo.md_env.matrix,
                                     &DisplayMode, &me->ModuleInfo.md_id),
                              targetos = me->group_objs[k].located_obj.osnum,
                              targetid = me->group_objs[k].located_obj.objid);
                if (EMSmsgReport(status,"ECmassp:hidraw",FALSE))
                    goto wrapup;
               }
*************************************/
             } 

            status = om$send(msg = message EMSsurface.EMcompute_density(
                                   &msg, &me->ModuleInfo, 
                                   &default_density),
                             targetos = me->group_objs[k].located_obj.osnum,
                             targetid = me->group_objs[k].located_obj.objid);
            if (! (1 & status & msg)) goto wrapup;

            if ((default_density == 1.0) && (k > 1))
                 default_density = me->density[k-1];

            ex$message ( msgnumb = EMS_P_KeyInDensity,
                         type    = "%lg",
                         var     = `default_density`,
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
               return(OM_S_SUCCESS);
            else if (event.response IS EX_BACK_UP)
             {
              ME.super_cmd->state = UNIFORM;
              ex$message ( msgnumb = EMS_S_ClearStatusField);
             }
            else if (event.response IS EX_RJT_MOVEON)
             {
              if (me->num_objects > 1)
               {
                DisplayMode = GRbdhe;
                status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                       &me->ModuleInfo.md_env.matrix_type,
                                       me->ModuleInfo.md_env.matrix,
                                     &DisplayMode, &me->ModuleInfo.md_id),
                              targetos = me->group_objs[k].located_obj.osnum,
                              targetid = me->group_objs[k].located_obj.objid);
                if (EMSmsgReport(status, "ECmassp:hhidraw", FALSE))
                    goto wrapup;
               }
              me->density[k] = default_density;
     
              status = om$send(msg = message
                                     EMScompsurf.EMreset_density(&msg, 
                                     &me->density[k]),
                              targetos = me->group_objs[k].located_obj.osnum,
                              targetid = me->group_objs[k].located_obj.objid);

              if (k == me->num_objects-1)
               {
                ME.super_cmd->state = PROCESS;
                ex$message ( msgnumb = EMS_S_ClearStatusField);
               }
              continue;
             }
            else	/* we have density one way or other */
	         { 
              if (me->num_objects > 1)
               {
                DisplayMode = GRbdhe;
                status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                       &me->ModuleInfo.md_env.matrix_type,
                                       me->ModuleInfo.md_env.matrix,
                                     &DisplayMode, &me->ModuleInfo.md_id),
                              targetos = me->group_objs[k].located_obj.osnum,
                              targetid = me->group_objs[k].located_obj.objid);
                if (EMSmsgReport(status, "ECmassp:hhidraw", FALSE))
                    goto wrapup;
               }

              if ((event.response == VALUE) && (msg != GRw_no_value))
               {
                if ((me->mass_prop_obj[k].objid != NULL_OBJID) &&
                    (me->density[k] != event.event.value))
                 {
                  status = om$send(msg = message
                                         EMSmassprop.EMupdate_props(&msg, 
                                         event.event.value),
                                   targetid = me->mass_prop_obj[k].objid,
                                   targetos = me->mass_prop_obj[k].osnum);
                  if (! (1 & status & msg)) goto wrapup;
                 }
		        me->density[k] = event.event.value;
                default_density = me->density[k];
                status = om$send(msg = message
                                       EMScompsurf.EMreset_density(&msg, 
                                       &default_density),
                              targetos = me->group_objs[k].located_obj.osnum,
                              targetid = me->group_objs[k].located_obj.objid);
               }
              if (k == me->num_objects - 1)
               {
                ME.super_cmd->state = PROCESS;
                ex$message ( msgnumb = EMS_S_ClearStatusField);
               }
              else
               {
                continue;
               }
	         }
           }
         } 
        break;

     case PROCESS:

          /* We have a list of objects to be processed */

          ex$message ( msgnumb = EMS_S_ClearStatusField);
          ex$message ( msgnumb = EMS_S_ProcessingFour);

          /* get active entities */
 
          i = sizeof(struct IGRdisplay);
          gr$get_active_display(msg    = &msg,
                                sizbuf = &i,
                                buffer = &display_attr,
                                nret   = &k);

          me->construct_list.msg = &me->msg;
          me->construct_list.env_info = &me->construct_env;
          me->construct_list.display = &me->display;

          MSfill_construct_list(&msg, &me->event_1,
                                &me->construct_list);

          for (j=0; j<me->num_objects; j++) /* for all objects */
           {
            OM_BLOCK_MOVE (&me->group_objs[j], &me->current_obj,
                           sizeof(struct GRlc_info));

            OM_BLOCK_MOVE(&me->current_obj.module_info,
                          me->construct_list.env_info,
                          sizeof (struct GRmd_env));

            if (me->mass_prop_obj[j].objid == NULL_OBJID)
             {
              /* construct and connect */

              status = om$construct (classid = OPP_EMSmassprop_class_id,
                              osnum = me->current_obj.located_obj.osnum,
                              p_objid = &me->mass_prop_obj[j].objid,
                              msg = message GRgraphics.GRconstruct(
                              &me->construct_list));
              if (! (1 & status)) goto wrapup;

              me->mass_prop_obj[j].osnum =
                                      me->current_obj.located_obj.osnum,
              chan_index = GRDGNLIMITS_MAX_I;

              status = om$send(msg = message Root.connect(to_object,
                                     chan_index,
                                     me->current_obj.located_obj.objid,
                                     me->current_obj.located_obj.osnum,
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

            if (ME.super_cmd->mytype IS 0)
             {
              status = om$send(msg = message EMSmassprop.EMset_density(
                                     &msg, me->density[j]),
                               targetid = me->mass_prop_obj[j].objid,
                               targetos = me->mass_prop_obj[j].osnum);
              if (! (1 & status & msg)) goto wrapup;

              status = om$send(msg = message EMSmassprop.EMget_density(
                                     &msg, &me->density[j]),
                               targetid = me->mass_prop_obj[j].objid,
                               targetos = me->mass_prop_obj[j].osnum);
              if (! (1 & status & msg)) goto wrapup;
             }

            status = om$send(msg = message
                                   EMSmassprop.EMset_type(&msg,
                                   ME.super_cmd->mytype),
                             targetid = me->mass_prop_obj[j].objid,
                             targetos = me->mass_prop_obj[j].osnum);
            if (! (1 & status & msg)) goto wrapup;

            status = om$send(msg = message GRvg.GRgetrang(&msg, 
                     &me->current_obj.module_info.md_env.matrix_type,
                     me->current_obj.module_info.md_env.matrix,
		   		     &world, &solid_range[0]),
                     targetos = me->current_obj.located_obj.osnum,
                     targetid = me->current_obj.located_obj.objid);
	        if (EMSmsgReport (status, "ECmasspi: get range", FALSE))
                              goto wrapup;

   	        sld = BSdistptpt(&bsmsg, &solid_range[0], &solid_range[3]);
	        if (sld > me->max_sld) me->max_sld = sld;

            for(i=0; i<NUMB_PROPS; i++)prop[i] = 0.0;
	
            validity = FALSE;
            status = om$send(msg = message EMSmassprop.EMretn_mass_prop(
                                   &msg, &validity, prop),
                             targetid = me->mass_prop_obj[j].objid,
                             targetos = me->mass_prop_obj[j].osnum);
            if (! (1 & status & msg)) goto wrapup;

            if ((validity) &&
               (me->current_obj.module_info.md_env.matrix_type != MAIDMX))
             {
              status = om$send(msg = message EMSmassprop.EMrefxform(&msg,
                          &me->current_obj.module_info,
                          &me->current_obj.module_info.md_env.matrix_type,
                          me->current_obj.module_info.md_env.matrix,
                          ref_point, prop,
                          in_glo_loc,
                          &validity),
                       targetid = me->mass_prop_obj[j].objid,
                       targetos = me->mass_prop_obj[j].osnum);
              if (! validity) goto evaluate; /* non_uniform scaling */
              if (! (1 & status & msg)) goto wrapup;

              for (i=0; i<9; i++) dest_glo_loc[i] = identity_matrix[i];
              for (i=0; i<NUMB_PROPS; i++) prop1[i] = 0.0;
              for (i=0; i<3; i++)
                   in_origin[i] = dest_origin[i] = prop[2+i];

              if (ME.super_cmd->mytype IS 0)
               {
                MScnvtprop(prop,in_origin, in_glo_loc, prop1, dest_origin,
                           dest_glo_loc);

                status = om$send(msg = message EMSmassprop.EMget_orient(
                                       &msg, &me->option1),
                                 targetid = me->mass_prop_obj[j].objid,
                                 targetos = me->mass_prop_obj[j].osnum);
                if (! (1 & status & msg)) goto wrapup;
               }
              else if (ME.super_cmd->mytype IS 1)
               {
                area_prop[0] =  0.0;
                area_prop[1] =  prop[11];
                area_prop[2] =  prop[2];
                area_prop[3] =  prop[3];
                area_prop[4] =  prop[4];
                area_prop[5] =  prop[14];
                area_prop[6] =  prop[15];
                area_prop[7] =  prop[14] + prop[15];
                area_prop[8] =  prop[16];
                area_prop[9] =  0.0;
                area_prop[10] = 0.0;
                area_prop[11] = prop[11];

                MScnvtprop(area_prop, in_origin, in_glo_loc, prop1,
                           dest_origin, dest_glo_loc);

                if (! me->area_only)
                 {
                  xxx = prop[5]*prop[5]+prop[6]*prop[6]+prop[7]*prop[7];
                  if (xxx < 0.95) me->area_only = TRUE;
                 }
               }
             }              
            else
             {
              evaluate:
              for(i=0; i<NUMB_PROPS; i++)prop[i] = 0.0;

              if (ME.super_cmd->mytype IS 0)
	           {  
                num_surfaces = 0;
   	            status = om$send(
                         msg = message GRowner.GRget_number_components(
                                       &msg, &num_surfaces),
                            targetos = me->current_obj.located_obj.osnum,
                            targetid = me->current_obj.located_obj.objid);

                status = om$send(msg = message EMSsurface.EMmassprop(&msg,
                                       num_surfaces, sld,
                                       &me->current_obj.module_info,
                                       scaling_factor, trans_vector,
                                       &me->density[j], prop),
                            targetos = me->current_obj.located_obj.osnum,
                            targetid = me->current_obj.located_obj.objid);
                if (msg == EMS_I_Interrupt)
                 {
                  status = om$send(msg = message GRgraphics.GRdelete(&msg,
                                         &me->current_obj.module_info),
                                   targetid = me->mass_prop_obj[j].objid,
                                   targetos = me->mass_prop_obj[j].osnum);
         
                  ex$message ( msgnumb = EMS_I_Intrupt);

                  break;
                 }

                status = om$send(msg = message EMSmassprop.EMget_gloloc(
                                       &msg, in_glo_loc),
                                 targetid = me->mass_prop_obj[j].objid,
                                 targetos = me->mass_prop_obj[j].osnum);
                if (! (1 & status & msg)) goto wrapup;
/*
 * begin pp (02/19/90)
 * If the current environment is not an identity matrix then
 * transform the orientation.
 */
             
                if (me->current_obj.module_info.md_env.matrix_type 
                     != MAIDMX)
                {
                  IGRdouble  points[4][3], xpoints[4][3];
                  IGRdouble *matrix,norm_1, norm_2;
                  IGRshort matrix_type;
                  IGRint l;
      
                  matrix_type = me->current_obj.module_info.md_env.matrix_type;
                  matrix = me->current_obj.module_info.md_env.matrix;
                 
                 for (l=0;l<3;l++) points[0][l] = 0.0;
                 for (l=0;l<3;l++)
                 {
                  points[1][l] = in_glo_loc[0+l];
                  points[2][l] = in_glo_loc[3+l];
                  points[3][l] = in_glo_loc[6+l];
                 }

                 l = 4;

                 status = MAoptsxform(&msg, (IGRlong *)&l, &matrix_type, matrix,
                          points[0], xpoints[0]);
                 if (! (1 & status & msg)) goto wrapup;

                 norm_1 = BSdistptpt(&msg, &xpoints[0][0], &xpoints[1][0]);
                 norm_2 = BSdistptpt(&msg, &xpoints[0][0], &xpoints[2][0]);

                 for (l=0; l<3; l++)
                 {
                  in_glo_loc[l] = (xpoints[1][l] - xpoints[0][l])/norm_1;
                  in_glo_loc[3+l] = (xpoints[2][l] - xpoints[0][l])/norm_2;
                 }

                 status = BScrossp(&msg, &in_glo_loc[0], &in_glo_loc[3], 
                          &in_glo_loc[6]);
                }
/* end pp */

                for (i=0; i<9; i++) dest_glo_loc[i] = identity_matrix[i];
                for (i=0; i<NUMB_PROPS; i++) prop1[i] = 0.0;
                for (i=0; i<3; i++)
                     in_origin[i] = dest_origin[i] = prop[2+i];

                MScnvtprop(prop,in_origin, in_glo_loc, prop1, dest_origin,
                           dest_glo_loc);

                status = om$send(msg = message EMSmassprop.EMget_orient(
                                       &msg, &me->option1),
                                 targetid = me->mass_prop_obj[j].objid,
                                 targetos = me->mass_prop_obj[j].osnum);
                if (! (1 & status & msg)) goto wrapup;
               }
              else
	           {
                num_surfaces = 0;
   	            status = om$send(
                         msg = message GRowner.GRget_number_components(
                                       &msg, &num_surfaces),
                            targetos = me->current_obj.located_obj.osnum,
                            targetid = me->current_obj.located_obj.objid);

                for (i=0; i<NUMB_PROPS; i++) prop1[i] = 0.0;
	            status = om$send(msg = message EMSsurface.EMareaprop(&msg,
                                       TRUE, num_surfaces,
                                       &me->current_obj.module_info,
                                       scaling_factor,trans_vector, prop),
                            targetos = me->current_obj.located_obj.osnum,
                            targetid = me->current_obj.located_obj.objid);
                if (msg == EMS_I_Interrupt)
                 {
                  status = om$send(msg = message GRgraphics.GRdelete(&msg,
                                         &me->current_obj.module_info),
                                   targetid = me->mass_prop_obj[j].objid,
                                   targetos = me->mass_prop_obj[j].osnum);

                  ex$message ( msgnumb = EMS_I_Intrupt);

                  break;
                 }
                for (i=0; i<6; i++) area_axes[i] = prop[5+i];
                                    area_axes[6] = area_axes[7] = 0.0;
                                    area_axes[8] = 1.0;

                if (! me->area_only)
                 {
                  xxx = prop[5]*prop[5]+prop[6]*prop[6]+prop[7]*prop[7];
                  if (xxx < 0.95) me->area_only = TRUE;
                 }

                for (i=0; i<9; i++) dest_glo_loc[i] = identity_matrix[i];
                for (i=0; i<NUMB_PROPS; i++) prop1[i] = 0.0;
                for (i=0; i<3; i++)
                     in_origin[i] = dest_origin[i] = prop[2+i];

                area_prop[0] =  0.0;
                area_prop[1] =  prop[11];
                area_prop[2] =  prop[2];
                area_prop[3] =  prop[3];
                area_prop[4] =  prop[4];
                area_prop[5] =  prop[14];
                area_prop[6] =  prop[15];
                area_prop[7] =  prop[14] + prop[15];
                area_prop[8] =  prop[16];
                area_prop[9] =  0.0;
                area_prop[10] = 0.0;
                area_prop[11] = prop[11];

                MScnvtprop(area_prop, in_origin, area_axes, prop1,
                           dest_origin, dest_glo_loc);

                status = om$send(msg = message EMSmassprop.EMupdate_orient
                                       (&msg, area_axes),
                                 targetid = me->mass_prop_obj[j].objid,
                                 targetos = me->mass_prop_obj[j].osnum);
                if (! (1 & status & msg)) goto wrapup;
	           }
              if (EMSmsgReport (status,"ECmassp: compute prop",FALSE))
                                goto wrapup;
              if (NOT (1 & msg)) continue;	/* not valid surface */
             }

                ex$message ( msgnumb = EMS_I_00003);
                ex$message ( msgnumb = EMS_S_ClearStatusField);

	        status = om$send(msg = message EMSsurface.EMgetDescription(
                                   &msg_loc, obj_descr, MAX_CHAR_LEN),
			            targetos = me->current_obj.located_obj.osnum,
			            targetid = me->current_obj.located_obj.objid);
            if (EMSmsgReport (status, "ECmassp: description", FALSE))
                              goto wrapup;

            strcpy(object_name, " ");

	        status = om$send(msg = message GRvg.GRgetname (&msg,
                                   object_name),
			            targetos = me->current_obj.located_obj.osnum,
			            targetid = me->current_obj.located_obj.objid);
            if (! (1 & status & msg))
             {
              strcpy(object_name, " ");
              status = OM_S_SUCCESS;
             }

            if (me->num_objects > 1)
             {
              DisplayMode = GRhd;
              status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                          &me->current_obj.module_info.md_env.matrix_type,
                          me->current_obj.module_info.md_env.matrix,
                          &DisplayMode, &me->ModuleInfo.md_id),
                       targetos = me->current_obj.located_obj.osnum,
                       targetid = me->current_obj.located_obj.objid);
              if(EMSmsgReport(status,"ECmassp: hidraw",FALSE))goto wrapup;
             }

            sld *= 0.2;

            /*
             *	    if centroid is close to 0 make it 0;
             *	    ie. within 5 times the BSVALBASIS
             */

            if ((prop[2] <= tol) AND (prop[2] >= negtol)) prop[2] = 0.0;
            if ((prop[3] <= tol) AND (prop[3] >= negtol)) prop[3] = 0.0;
            if ((prop[4] <= tol) AND (prop[4] >= negtol)) prop[4] = 0.0;

            count = 0;
            status = om$get_channel_count(osnum =
                                           me->mass_prop_obj[j].osnum,
                                          objid =
                                           me->mass_prop_obj[j].objid,
                                          p_chanselect = &to_comps,
                                          count = &count);
            if (! (1 & status)) goto wrapup;
 
            if (! count)
             {
              MSdrawtriadn (&msg, me->option, in_glo_loc, sld, prop,
                        &me->current_obj.module_info, &display_attr, my_id,
                        TRUE, &me->construct_list,&me->mass_prop_obj[j]);
              if (! (1 & msg)) goto wrapup;
             }

            MSget_master_string (&msg, me->ModuleInfo.md_id.osnum,
				                 master_units, &factor);

            for (i=0; i<3; i++) old_centroid[i] = prop[2+i];

/* begin pp */


          if ((ME.super_cmd->mytype != 0) &&
                ((prop[5]*prop[5] + prop[6]*prop[6] + prop[7]*prop[7]) 
                > 0.95)) /* area properties and axis defined */
          {
            IGRint temp_option;
            IGRint temp_prop_type;
            IGRdouble temp_prop[NUMB_PROPS];
/*            IGRdouble in_origin; */
            IGRdouble temp_glo_loc[9];
            IGRdouble temp_p_axes[9],temp_density;

            status = om$send (msg = message EMSmassprop.EMreadprop(&msg,
                              &me->current_obj.module_info,
                              &temp_option,
                              &temp_prop_type,
                              temp_prop,
                              ref_origin,
                              temp_glo_loc,
                              temp_p_axes,
                              &temp_density),
                              targetid = me->mass_prop_obj[j].objid,
                              targetos = me->mass_prop_obj[j].osnum);
            if (!(1&status&msg)) goto wrapup;

            status = MSget_first_area_moments(ref_origin,old_centroid,prop,
                                     &prop[18],&prop[19]);
            if (!status) goto wrapup;
           }

/* end pp (02/16/90) */
            MSconvert_to_active_coordinates (&msg,
                                             me->ModuleInfo,
                                             old_centroid, act_centroid,
                                             &coord_type, c_name);
            if (! (1 & msg)) goto wrapup;

            for (i=0; i<3; i++) prop[2+i] = act_centroid[i];

            if (ME.super_cmd->mytype IS 0)
            {
             prop[19] = 0.43210; /* Signal to indicate that the center
                                    of mass is the same as the
                                    center of volume */
            }

            MSdisplay_prop(me->stderr_only, me->file_name, me->option1,
                           me->numb_accumulated, obj_descr,
                           in_glo_loc, NULL, prop, factor,
                           master_units, coord_type, c_name, object_name);

            for (i=0; i<3; i++) prop[2+i] = old_centroid[i];

            /*
             * 09/07/88 : rlw : Modified to display volume or area in the
             * input field as per request of Barry Wilson.
             */

            rlw_echo_stuff(me->mytype,
                           factor,
                           master_units,
                           prop);
            /*
             * end - rlw
             */

            if (ME.super_cmd->mytype IS 0)
            {
              prop1[16] = prop1[2];
              prop1[17] = prop1[3];
              prop1[18] = prop1[4];
              MSaccprop(prop1, me->acc_prop);	/* prop at new centroid */
            }
            else if (ME.super_cmd->mytype IS 1)
              MSacc_area_prop(prop1, me->acc_prop);

            /* Do I have enough space to accumulate the object ids? */
 
            k = OM_DIMENSION_OF(me->accumulated_objs);

            if (k IS me->numb_accumulated) /* space available */
	         {
              k += 10;		/* ten more */
              OM_SET_DIMENSION(me->accumulated_objs, k);
	         }
	        k = me->numb_accumulated;
	        me->accumulated_objs[k].osnum =
                                    me->current_obj.located_obj.osnum;
  	        me->accumulated_objs[k].objid =
                                    me->current_obj.located_obj.objid;
            me->numb_accumulated ++;
           }
	      if (group_objs) om$dealloc (ptr = group_objs);
 	      ME.super_cmd->state = GET_OBJ;

        break;

     case ACC_DONE:

   	      dp$erase_hilite(msg = &msg);

	      if (me->numb_accumulated > 1)
	       {
	        sld = 0.2 * me->max_sld;

            if (ME.super_cmd->mytype IS 0)
             {
              for (i=0; i<9; i++) dest_glo_loc[i] = identity_matrix[i];

              eig_matrix[0][0] =  me->acc_prop[5];
              eig_matrix[0][1] = -me->acc_prop[8];
              eig_matrix[0][2] = -me->acc_prop[10];

              eig_matrix[1][0] = -me->acc_prop[8];
              eig_matrix[1][1] =  me->acc_prop[6];
              eig_matrix[1][2] = -me->acc_prop[9];

              eig_matrix[2][0] = -me->acc_prop[10];
              eig_matrix[2][1] = -me->acc_prop[9];
              eig_matrix[2][2] =  me->acc_prop[7];

              status = 1;
              BSeig3x3 (eig_matrix,(IGRint *)&status,&me->acc_prop[5], 
                                             (IGRvector *)dest_glo_loc, &msg);

              me->acc_prop[8] = 0.0;
              me->acc_prop[9] = 0.0;
              me->acc_prop[10] = 0.0;
             }
            else if (ME.super_cmd->mytype IS 1)
             {
              for (i=0; i<NUMB_PROPS; i++) prop1[i] = 0.0;

              MSprincipal_area (me->acc_prop, prop1);
 
              for (i=0; i<NUMB_PROPS; i++) me->acc_prop[i] = prop1[i];

              for (i=0; i<6; i++) dest_glo_loc[i] = me->acc_prop[5+i];
                                  dest_glo_loc[6] = dest_glo_loc[7] = 0.0;
                                  dest_glo_loc[8] = 1.0;

              if (me->area_only) /* nonplanar element was encountered */
               {
                for (i=5; i<11; i++) me->acc_prop[i] = 0.0;
               }
             }

            if ((me->acc_prop[2] <= tol) AND (me->acc_prop[2] >= negtol))
                 me->acc_prop[2] = 0.0;
            if ((me->acc_prop[3] <= tol) AND (me->acc_prop[3] >= negtol))
                 me->acc_prop[3] = 0.0;
            if ((me->acc_prop[4] <= tol) AND (me->acc_prop[4] >= negtol))
                 me->acc_prop[4] = 0.0;

            if (ME.super_cmd->mytype IS 0)
            {
             if ((me->acc_prop[16] <= tol) AND (me->acc_prop[16] >= negtol))
                 me->acc_prop[16] = 0.0;
             if ((me->acc_prop[17] <= tol) AND (me->acc_prop[17] >= negtol))
                 me->acc_prop[17] = 0.0;
             if ((me->acc_prop[18] <= tol) AND (me->acc_prop[18] >= negtol))
                 me->acc_prop[18] = 0.0;
            }
 
   	       i = sizeof(struct IGRdisplay);
	       gr$get_active_display(msg    = &msg,
				                 sizbuf = &i,
				                 buffer = &display_attr,
				                 nret   = &k);
           me->construct_list.msg = &me->msg;
           me->construct_list.env_info = &me->construct_env;
           me->construct_list.display = &me->display;

           MSfill_construct_list (&msg, &me->event_1,
                                  &me->construct_list);

           triad_id.objid = NULL_OBJID;
           if (ME.super_cmd->mytype IS 0)
           {
             me->acc_prop[19] = 0.01234; /* Signal to create a point for
                                            the center of volume */
           }

           MSdrawtriadn(&msg, me->option, dest_glo_loc, sld, me->acc_prop,
                        &me->ModuleInfo, &display_attr, my_id,
                        TRUE, &me->construct_list, &triad_id);
           if (! (1 & msg)) goto wrapup;

           MSget_master_string(&msg, me->ModuleInfo.md_id.osnum,
				               master_units, &factor);

           for (i=0; i<3; i++) old_centroid[i] = me->acc_prop[2+i];

           MSconvert_to_active_coordinates (&msg,
                                            me->ModuleInfo,
                                            old_centroid, act_centroid,
                                            &coord_type, c_name);
           if (! (1 & msg)) goto wrapup;

           for (i=0; i<3; i++) me->acc_prop[2+i] = act_centroid[i];

           if (ME.super_cmd->mytype IS 0)
           {
            IGRdouble new_vol_centroid[3];

            for (i=0; i<3; i++) old_vol_centroid[i] = me->acc_prop[16+i];

            MSconvert_to_active_coordinates (&msg,
                                            me->ModuleInfo,
                                            old_vol_centroid, new_vol_centroid,
                                            &coord_type, c_name);
            if (! (1 & msg)) goto wrapup;
            for (i=0; i<3; i++) me->acc_prop[16+i] = new_vol_centroid[i];
            me->acc_prop[19] = 0.01234; /* Signal so that center of volume
                                           is being passed in */
           }

           strcpy(object_name, " ");

/*
 * If computing planar area properties then first moments of area about
 * x and y axes are 0. I here take advantage of the fact that the first
 * moments will not be printed should any of the areas be not planar.
 * 
 */
          if (ME.super_cmd->mytype != 0)
           {
             prop[18] = 0.0;
             prop[19] = 0.0;
            }

/* end pp 02/16/90 */

           MSdisplay_prop(me->stderr_only, me->file_name, me->option1,
                          me->numb_accumulated, "Accumulated properties",
                          dest_glo_loc, NULL, me->acc_prop, factor,
                          master_units, coord_type, c_name, object_name);

           for (i=0; i<3; i++) me->acc_prop[2+i] = old_centroid[i];
           if (ME.super_cmd->mytype IS 0)
           {
            for (i=0; i<3; i++) me->acc_prop[16+i] = old_vol_centroid[i];
           }

           if (ME.super_cmd->mytype IS 0)
                default_density = me->acc_prop[1]/me->acc_prop[0];
            else if (ME.super_cmd->mytype IS 1)
                default_density = 0.0;
          
           status = om$send(msg = message EMSmassprop.EMedit_mass_prop(
                                  &msg, &me->ModuleInfo, TRUE,
                                  me->acc_prop, default_density,
                                  old_centroid, dest_glo_loc,me->option1),
                            targetid = triad_id.objid,
                            targetos = triad_id.osnum);
           if (! (1 & status & msg)) goto wrapup;

           if (ME.super_cmd->mytype IS 1)
            {
             status = om$send(msg = message EMSmassprop.EMload_prin_axes(
                                  &msg, me->acc_prop),
                            targetid = triad_id.objid,
                            targetos = triad_id.osnum);
             if (! (1 & status & msg)) goto wrapup;
            }

           /*
            * 09/07/88 : rlw : Modified to display volume or area in the
            * input field as per request of Barry Wilson.
            */

           rlw_echo_stuff(me->mytype,
                          factor,
                          master_units,
                          me->acc_prop);
           /*
            * end - rlw
            */
          }

	     for (i=0; i<NUMB_PROPS; i++)me->acc_prop[i] = 0.0;
	     me->numb_accumulated = 0;
	     ME.super_cmd->state = GET_FILE_NAME;

         break;

     default:

         *response = TERMINATE;
         return (OM_S_SUCCESS);
      }

   } while(TRUE);

wrapup:
   if (group_objs) om$dealloc (ptr = group_objs);
   *response = TERMINATE;
   return(status);
 }

/*
 Stupid function to echo computed values to the user

 History

 09/07/88 : rlw : Creation date

 */
static void rlw_echo_stuff(want_area,
                           factor,
                           master_units,
                           prop)

IGRboolean	want_area;
IGRdouble	factor;
IGRchar		master_units[MAX_CHAR_LEN];
IGRdouble	prop[NUMB_PROPS];

{
 IGRchar	string[80];
 IGRdouble	scale_factor;

 scale_factor = factor * factor;
 if (want_area)
  {
   sprintf(string, "Surface area is %lg %s%s",
           prop[11] / scale_factor, master_units, "**2");
  }
 else
  {
   scale_factor *= factor;
   sprintf(string, "Volume is %lg %s%s",
           prop[0] / scale_factor, master_units, "**3");
  }
 UI_echo(string);
}

end implementation ECmassp;

