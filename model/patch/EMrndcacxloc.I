class implementation ECsfedloc;

/*
DESCRIPTION
	This method locates edges using the fillet/all radii option.

OPTIONS
	No options supported

ALGORITHM
	First the solid is located & further processing is carried out to 
	return only the fillet (concave)/all radii (convex) edges of the solid.

HISTORY
 	Tapadia  01/18/92 
	Jaikish  12/17/97 - used the function roundn() to fix TR#119701572
*/

#include <string.h>
#include <stdlib.h>
#include "lcmacros.h"
#include "EMSlc.h"
#include "griomacros.h" /* co$getevent */
#include "emserr.h"
#include "EMSaction.h" /* Structure definition for action handler */
#include "EMSasdef.h" /* For ASSOC */
#include "EMSprop.h"
#include "OMprimitives.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "EMSlcdef.h"
#include "EMSlmdef.h"
#include "EMSerrordef.h"
#include "OMmacros.h"
#include "EMSasmacros.h"
#include "dpdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "msmacros.h"
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"

#define FALSE 0
#define TRUE 1

#define IDENTIFY_SOLID 		0 

#define FILLET_TYPE		4
#define RADII_TYPE		5

#define DEBUG        1
#define NUMED        10

#define LOC_BUFF 80
#define PROMPT_SIZE 65

from EMSedge import EMdisplay;
from EMSedge import EMget_props;
from EMSedge import EMchkconvex;
from EMSsurface import EMgetactiveid, EMgetedges;
from GRgraphics import GRdisplay;

extern GRclassid OPP_EMSsolid_class_id;
extern GRclassid OPP_EMSsubbs_class_id, OPP_EMScompsurf_class_id;

extern  IGRlong EFhilite_edge_with_weight();
extern  IGRlong EFlocate_surface_select_handler();
extern void EFparse_keyin();
extern void EFrestore_hilite_of_edges();
extern IGRlong EFparse_edges();
extern void EFcheck_strlen();
extern void EFcheck_if_neutral();
extern void EFget_domn_edges();

static IGRboolean aflag;

method locate_concave_convex_edge( IGRlong       *ret_msg;
                     IGRint        *response;
                     IGRchar       *response_data;
                     IGRchar       *status_string;                     
                     char          (*funcptr) () )
{
  IGRint                      nm_edges,i, ii,num_entries,num_elements, count;
  IGRboolean                  stat_func=TRUE;
  GRobjid                     first_edge;
  OMuword                     rclass, eliclass, objspc_num ;
  OM_S_CLASSLIST              rtree_classes, elig_classes;
  struct  GRlc_locate         attributes;
  IGRlong                     event_size,qsize,sts, msg, size, display_flag,
                              eventmask1, eventmask2;
  OM_S_CHANSELECT             chan_to_common_edge;
  OM_S_OBJECT_LINKAGE         comm_edge;
  enum GRdpmode               display_mode;
  IGRchar                     accept_prompt[80],loc_prompt[LOC_BUFF];

  IGRdouble chtol, *mat;
  IGRshort *mattyp;

  *ret_msg = EMS_S_Success;  
  sts = OM_S_SUCCESS;

  BSEXTRACTPAR(&msg, BSTOLCHRDHT, chtol);

  objspc_num = me->ModuleInfo.md_id.osnum;

  sts = EMmake_chanselect( EMSedge_to_common_edge, &chan_to_common_edge);
/*
  EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);

*/
  do
  {
   switch( me->process_state)
   {
     case IDENTIFY_SOLID:
      {

       IGRchar buff1[25],buff2[25],buff3[25],inp_buff[80];
       event_size = sizeof(struct GRevent);
       qsize = event_size - 2 * sizeof(IGRint);
       eventmask1 = GRm_VALUE |GRm_STRING | 
		    GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
       eventmask2 = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;

       if(me->edge_type == FILLET_TYPE)
         ex$message(msgnumb = EMS_I_FilMode, buff = buff3)
       else ex$message(msgnumb = EMS_I_RoMode, buff = buff3)

       if(me->selection) ex$message(msgnumb = EMS_I_Select,buff = buff2)
       else ex$message(msgnumb = EMS_I_DSelect, buff = buff2)

       ex$message(msgnumb = EMS_I_ConstRad, buff = buff1)

       strncpy(inp_buff,buff1,24);
       strcat(inp_buff,"  -  ");
       strncat(inp_buff,buff2,24);
       strcat(inp_buff,"  -  ");
       strncat(inp_buff,buff3,24);

       ex$message(field = ERROR_FIELD, justification = CENTER_JUS,
                  in_buff = inp_buff); 
       nm_edges = 0;
       for(ii = 0; ii < me->numed; ii++) {
	 if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }
       if(!nm_edges && !me->numtmped && me->selection) {
            double temp=me->active_rad;
            roundn(&temp,3);
	    me->active_GRid.objid = NULL_OBJID;
            ex$message(msgnumb = EMS_P_IdSoCoSuRad, type = "%.3g",
			var = temp, buff = loc_prompt,
                        buffer_size = PROMPT_SIZE )
       }
       else {
	   if(me->selection) 
	{
                double temp=me->active_rad;
                roundn(&temp,3);
            	ex$message(msgnumb = EMS_P_IdSoCoSuRadMo, type = "%.3g",
                     	var = temp, buff = loc_prompt,
                        buffer_size = PROMPT_SIZE )
	}
	   else 
            	ex$message(msgnumb = EMS_P_IdSoCoSuMo, buff = loc_prompt,
                           buffer_size = PROMPT_SIZE )
       }
	
       GRstatus_display_button(TRUE);
       if(me->locate_stack.num_entries == 0 || me->option_change){
         me->valid_inputdata = TRUE;
         me->locate_stack.num_entries = 0;
         ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                         in_buff = loc_prompt)
       }
       else {
         ex$message(msgnumb = EMS_P_00038,buff = accept_prompt)
         ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                         in_buff = accept_prompt)
       }
        me->option_change = FALSE;
       stat_func = ems$getevent(msg = &msg, event_mask = eventmask1,
                value_type = GRIO_DISTANCE, response = (long *)response,
                response_data = response_data, event = &me->loc_event);

       switch(me->loc_event.response) {

	 case EX_VALUE:
         {
                /* The user changes the radius */
           if((me->loc_event.event.value < 0) ||
               (me->loc_event.event.value < 10 * chtol)) {
               ex$message(msgnumb = EMS_S_RadValGreCht)
               sleep(1);
               break;
           }
           else {
             if(me->selection) {
               me->active_rad = me->loc_event.event.value;
               me->radius_changed = 0;
             }
             me->uniformval = me->loc_event.event.value;
             me->uniformval_event = me->loc_event;
             me->edgeval_event[me->numed + me->numtmped]= me->loc_event;
             me->end_edgeval_event[me->numed+me->numtmped].event.value = -1.0;
             me->end_edgeval_event[me->numed+me->numtmped].num_id = 0;
             me->fill_typ[me->numed + me->numtmped] = me->fillet_type;
           }
           break;
        }
        case EX_STRING:
        {
          IGRdouble st_val;
          IGRint ret_type;
          EFparse_keyin(me->loc_event.event.keyin, &me->selection,
                    &me->edge_type, &me->fillet_type, &ret_type,&st_val);
          if(ret_type == 0) goto ret_end;
          if(ret_type == 2) {
            ex$message(msgnumb =EMS_S_InvalidKeyin) ;
            sleep(1);
          }
          break;
        }

        case EX_DATA:
        case EX_RJT_MOVEON:
        case  EX_BACK_UP:
        {
          IGRlong 	EFlocate_cacx_action_handler();
	  IGRlong	object_located=0;
          struct   rnd_cacx_loc_acthndlr was_located;
          struct rnd_surfloop_selhndlr  surf_selhndlr_args;
          IGRchar  *my_args;

          sts = ex$putque(msg = &msg, response = response,
                        byte = &qsize, buffer = (char *)&me->loc_event.event);

          was_located.next = NULL;
          was_located.option = 1;
          was_located.sol_id.objid = me->active_GRid.objid;
          was_located.sol_id.osnum = me->active_GRid.osnum;

          surf_selhndlr_args.my_inst.objid = my_id;
          surf_selhndlr_args.my_inst.osnum = OM_Gw_current_OS;
          surf_selhndlr_args.edge_type = me->edge_type;
          my_args = (IGRchar *)&surf_selhndlr_args;

          size = sizeof(struct GRevent);
          attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
          aflag = pwIsActivationOn();
          if (aflag)
          {
          attributes.owner_action = LC_RIGID_COMP  | LC_FLEX_COMP | 
				    LC_RIGID_OWNER |LC_LOCALMOD |
                                    LC_REF_OBJECTS | LC_NO_REF_HEADER;
          /* Added REF_OBJECTS for RFA */
          }
          else
          {
          attributes.owner_action = LC_RIGID_COMP  | LC_FLEX_COMP | 
				    LC_RIGID_OWNER |LC_LOCALMOD |
                    LC_NO_REF_HEADER;
          }
          strcpy(attributes.classes, "EMSsurface");
          display_flag = DO_NOT_RELOCATE | ALL_WINDOWS | ELEM_HILIGHT | 
                      LC_ERASE_LOC_ELEMENT | 
		      NO_PROJ_ACCEPT_POINT ;
        
          rtree_classes.w_count = 1;
          elig_classes.w_count = 1;
          rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

          rclass = OPP_EMSsubbs_class_id;
          eliclass = OPP_EMScompsurf_class_id;

          rtree_classes.p_classes = &rclass;
          elig_classes.p_classes = &eliclass;

          stat_func = lc$locate(rc = &object_located, 
                 event1 = &me->loc_event,
                 event2 = &me->event,
                 mask1 = eventmask1, 
                 mask2 = eventmask2, 
                 eventsize= &size, 
                 display_flag = display_flag,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = loc_prompt, 
                 acc_key = EMS_P_00038,
                 relocate_key = EMS_I_SfSlNotLocated,
                 attributes = &attributes,
		 /* fillet-radii selection action handler */
                 act_handler = EFlocate_cacx_action_handler, 
                 act_args = &was_located,
		 select = EFlocate_surface_select_handler,
		 select_args = my_args,
                 stack = &ME.ECsfedloc->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);

          if( (!stat_func)) {
            *ret_msg = EMS_I_Interrupt;
            goto ret_end;
          }

	  if(object_located == GRw_no_value) 
	    me->event.response = EX_RJT_MOVEON;

	  if(object_located) 
            me->process_state = IDENTIFY_SOLID;

          switch (me->event.response)
          {
          case EX_RJT_MOVEON:
	    if(me->loc_event.response == DATA || !me->valid_inputdata) {
	      EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,me->ModuleInfo,me->bound_code); 
	      break;
	    }  /* Object found but rejected */
	    else {
              nm_edges = 0;
              for(ii = 0; ii < me->numed; ii++) {
                if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
                nm_edges++;
              }
              if((!nm_edges && !me->numtmped) || 
                ((nm_edges == me->numtmped) && !me->selection)) {
	   	ex$message(msgnumb = EMS_S_IgnMoOnRej);
           	me->process_state = IDENTIFY_SOLID;
           	break;
              }
              else
                /* Successful completion */
                sts = OM_S_SUCCESS;
              goto ret_end;  
	    }
  
          case  EX_BACK_UP:
	    if(*response != EX_BACK_UP) break;
            if(me->num_bkp_entries) {
              display_mode = GRhe ;
	      for(ii=0; ii< me->num_bkp_list[me->num_bkp_entries-1];ii++) {
                sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                      me->tmp_located_obj[me->numtmped-1], display_mode );

                EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
                ME.ECsfedloc->tmp_located_obj[ME.ECsfedloc->numtmped-1] = NULL;
                ME.ECsfedloc->numtmped-- ;
	      }
	      me->num_bkp_list[me->num_bkp_entries-1] = 0;
              me->num_bkp_entries --;
              me->process_state = IDENTIFY_SOLID;
/*
	      EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);
*/
            }
            else {
	      ex$message(msgnumb =EMS_S_NoPrevBkp) ;
              sleep(1);
            }
	    break;

          case EX_DATA:
          {
            struct GRid srf_ownr;
	    struct GRid *tmp_edges = NULL;
	    IGRint num_ed = 0;
	    IGRint zero = 0;
	    GRobjid *loc_edg = NULL;
	    IGRint j, t_co, found;
	    IGRint cave_count, cvx_count, f_co = 0;
	    cave_count = cvx_count = 0;

	    if(!object_located) break;
            first_edge = me->event.located_object[0].located_obj.objid;
            objspc_num = me->event.located_object[0].located_obj.osnum;

           mattyp= &me->event.located_object[0].module_info.md_env.matrix_type;
            mat = me->event.located_object[0].module_info.md_env.matrix; 
            me->ModuleInfo = me->event.located_object[0].module_info; 
            sts = om$send(msg = message EMSsurface.EMgetactiveid(&msg,
                              &srf_ownr, NULL),
                        targetid = first_edge,
                        targetos = objspc_num);
            EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

            nm_edges = 0;
            for(ii = 0; ii < me->numed; ii++) 
              {
              if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
              nm_edges++;
            }
            if(!me->numtmped && !nm_edges){
              me->active_GRid.objid = first_edge;
              me->active_GRid.osnum = objspc_num;
	    }
            else if ((me->active_GRid.objid != first_edge) ||
                         (me->active_GRid.osnum != objspc_num)) {
                    ex$message(msgnumb = EMS_S_EdgePartDiffComposite);
                    me->process_state = IDENTIFY_SOLID;
                    break;
                 }

	    sts = om$send(msg = message EMSsurface.EMgetedges(&msg,
			EMS_OPT_ALL, &tmp_edges, &zero, &num_ed, NULL,
			NULL, NULL, NULL),
		senderid = NULL_OBJID,
		targetid = first_edge,
		targetos = objspc_num);
            display_mode = GRhe ;
	    for(ii = 0; ii < num_ed ; ii++) {
	      sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                        tmp_edges[ii].objid, display_mode );
              EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
	    }
  	    EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);
	    if(!me->selection) {
              display_mode = GRhe ;
	      for(ii = 0; ii < me->numtmped; ii++) {
	        sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = me->tmp_located_obj[ii],
                        targetos = objspc_num);
                EMomerr_hndlr(sts, ret_end, "EMdisplay");
	      }
	    }

	    t_co = 0;
	    loc_edg = (GRobjid *) stackalloc(sizeof(GRobjid) * num_ed);
    
            ME.COroot->ModuleInfo = me->event.located_object[0].module_info; 

	    for(i = 0; i < num_ed; i++) {
	      found = FALSE;
            	for(j = 0; j < t_co; j++) {
		    if(tmp_edges[i].objid == loc_edg[j])
                      {
		      found = TRUE;
                      break;
                      }
        	  }
              if(!found) {
          	sts = om$get_channel_objects(
               		osnum = objspc_num,
               		objid = tmp_edges[i].objid,
               		p_chanselect = &chan_to_common_edge,
               		list = &comm_edge,
               		size = 1,
               		count = (OMuint *)&count);

          	EMomerr_hndlr ( sts, ret_end, "get_channel_objects");

		if(count) 
		  {
			loc_edg[t_co] = comm_edge.S_objid;
			t_co++;
		  }
 	      }
	    }
            /* fix for mlk */
              if(tmp_edges)
                {
                om$dealloc(ptr = tmp_edges);
                tmp_edges = NULL;
                }

	    for(i = 0; i < t_co; i++)  {
	      IGRdouble angmeas;
	      IGRboolean is_convex, is_neutral;
		

	      sts = om$send(msg = message EMSedge.EMchkconvex(&msg, NULL,
			mattyp, mat, EMS_ZEROANGLE_DEG_MAX, &is_convex, 
			&is_neutral, &angmeas),
		senderid = NULL_OBJID,
		targetid = loc_edg[i],
		targetos = objspc_num);

              EMerr_hndlr(!(1&msg&sts),msg,EMS_E_Fail,ret_end);

	    /* To check if it is in the user defined neutral edge angle */
	      if(!is_neutral) 
		EFcheck_if_neutral(angmeas, me->neutral_edge_angle,
				&is_neutral);

	      if(is_neutral) 
		continue;
	      else if(me->edge_type == RADII_TYPE && is_convex) {
		     loc_edg[cave_count] = loc_edg[i];
		     cave_count++;
		     f_co = cave_count;
	           }
	           else if(me->edge_type == FILLET_TYPE && (!is_convex)) {
		          loc_edg[cvx_count] = loc_edg[i];
		          cvx_count++;
		          f_co = cvx_count;
	                }
	    }

	    if(f_co > 0) {
	      sts = EFparse_edges(&msg, &me->selection, me->located_obj, 
			me->tmp_located_obj, me->numed, me->numtmped,
			loc_edg, objspc_num, &f_co,me->bound_code);
	    }

	    if(!f_co) {
	      if(me->selection)
       		ex$message(msgnumb = EMS_S_NoEdgesRemaining)
	      else 
       		ex$message(msgnumb = EMS_S_NoEdgesToDeselect)
	      sleep(1);
              goto ret_end;
	    }
	    EFget_domn_edges(loc_edg,f_co,objspc_num); 

	    for(i = 0; i < f_co; i++) {
	      display_mode = (me->selection) ? GRhd : GRhe;
	      sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = loc_edg[i],
                        targetos = objspc_num);
              EMomerr_hndlr(sts, ret_end, "EMdisplay");
	    }

	    num_entries = om$dimension_of(varray = me->num_bkp_list);
	    if((me->num_bkp_entries + 1) >= num_entries) {
	      sts = om$vla_set_dimension(varray = me->num_bkp_list,
			size = me->num_bkp_entries + 1 );
	      EMomerr_hndlr(sts, ret_end, "set_dimension  error");
            }
            num_elements = om$dimension_of(varray = me->tmp_located_obj);
	    t_co = f_co;
            if((t_co + 1) >= num_elements) {
              sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                         size = num_elements + 4 + t_co);
              EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	    }

            if((t_co + 1 + me->numed) >= num_elements) {
              sts = om$vla_set_dimension(varray = me->edgeval_event,
                        	size = num_elements + 4 + t_co + me->numed);
              EMomerr_hndlr(sts, ret_end, "set_dimension  error");
              sts = om$vla_set_dimension(varray = me->end_edgeval_event,
                        	size = num_elements + 4 + t_co + me->numed);
              EMomerr_hndlr(sts, ret_end, "set_dimension  error");
              sts = om$vla_set_dimension(varray = me->fill_typ,
                        	size = num_elements + 4 + t_co + me->numed);
              EMomerr_hndlr(sts, ret_end, "set_dimension  error");
              sts = om$vla_set_dimension(varray = me->bound_code,
                        	size = num_elements + 4 + t_co + me->numed);
              EMomerr_hndlr(sts, ret_end, "set_dimension  error");
            }

	    for(i = 0; i < t_co; i++) {
              me->end_edgeval_event[me->numed+me->numtmped + i].num_id= 0;
              me->edgeval_event[me->numed+me->numtmped + i].num_id= 0;
	      me->edgeval_event[me->numed + me->numtmped + i].event.value = 
			me->active_rad;
	      me->end_edgeval_event[me->numed + me->numtmped + i].event.value = 
			me->active_rad;
	      me->fill_typ[me->numed + me->numtmped + i] = me->fillet_type;
              me->bound_code[me->numed+me->numtmped + i]=0;
              me->tmp_located_obj[me->numtmped + i] = loc_edg[i];
	    }
	    if(me->numtmped == 0 || !me->radius_changed) { 
              me->bound_code[me->numed+me->numtmped]=EMSrnd_input_ed_grp_start;
	      me->radius_changed = 1;
            }
            me->numtmped += t_co;
            me->num_bkp_entries ++;
	    me->num_bkp_list[me->num_bkp_entries-1] = t_co;
            me->process_state = IDENTIFY_SOLID;

            break;
          }
          default:
            me->valid_inputdata = FALSE;
            goto ret_end;
          } /* switch  of event response*/
          break;               
        }  /* of the 3 cases */

        default:
	  goto ret_end;
       }  /* switch loc_event response */
       break;
     }
    default:
     goto ret_end;
    } /* me->process_state */
  } while( TRUE);

ret_end:
  return(sts);
}

/* Action handler for not selecting the same solid for locate purpose while
in all radii-fillet edge selection option */

IGRlong EFlocate_cacx_action_handler(cacx_locate, new_entry, locate_args, 
	action)
struct	rnd_cacx_loc_acthndlr *cacx_locate;
struct	GRlc_info *new_entry;
struct	LC_action_args *locate_args;
enum	GRlocate_action *action;
{
 	IGRboolean	call_action_handler;
 	IGRlong msg_loc, sts, loc_msg; 
 	struct GRid active_id;
 	extern IGRlong LCptlocact();
 	struct	GRid *search_id;

	/* Initialize */

 	call_action_handler = FALSE;
 	msg_loc = EMS_S_Success; 
 	loc_msg = EMS_S_Success; 
 	sts = OM_S_SUCCESS;

 	switch (*action) 
	{
   	    case add_all:
   	    case add_inside:
   	    case add_outside:
   	    case add_overlap:
   	    case add_nopost:
   	    {
     	      IGRlong	i;

     	      for (i = 0; i < 1; i++) {
     	    	search_id = &new_entry->located_obj;

     		/* Get its active owner solid id */
		sts = om$send(msg = message EMSsurface.EMgetactiveid(&loc_msg, 
				&active_id, NULL),
			senderid = NULL_OBJID,
			targetid = search_id->objid,
			targetos = search_id->osnum);

		if(!(1 & sts &loc_msg)) {
			call_action_handler = FALSE;
			sts = OM_S_SUCCESS;
		}
		else { /* Check if the active id is a solid */
     	    	    if(EFisAncestryValid(&msg_loc, active_id.objid, 
			active_id.osnum, OPP_EMSsolid_class_id, FALSE)) { 
		    	call_action_handler = TRUE;

			/* This could happen if no edges have been selected so 
			far (i.e active_GRid.objid is NULL_OBJID */

			if(cacx_locate->sol_id.objid != NULL_OBJID) {
		   	    if(!IF_EQ_OBJID(cacx_locate->sol_id.objid,
				active_id.objid))
				call_action_handler = FALSE;
		        }
	    	    }
		    else 
			call_action_handler = FALSE;
		}
     	      }
  	    }
  	    break;

  	    default:
      		break;
 	} /* switch (*action) */

	/* Call the default action handler */

	if(call_action_handler) 
   		sts = LCptlocact(NULL, new_entry, locate_args, action);
	else
  		sts = OM_S_SUCCESS;

return(sts);
}
  
/* gets the dominant edges in case if any edge has one */

void EFget_domn_edges(loc_edg,f_co,objspc_num)
GRobjid *loc_edg;
IGRint f_co;
OMuword objspc_num;
{
 IGRint count,ii;
 IGRlong sts,msg;
 IGRushort props;
 OM_S_CHANSELECT    chan_to_common_edge;
 OM_S_OBJECT_LINKAGE   comm_edge;
 
 sts = OM_S_SUCCESS;

 sts = EMmake_chanselect( EMSedge_to_common_edge, &chan_to_common_edge);

 for(ii = 0; ii < f_co; ii++) {
   sts = om$send(msg = message EMSedge.EMget_props(&msg,
				&props),
		senderid = NULL_OBJID,
		targetid = loc_edg[ii],
		targetos = objspc_num);
   EMomerr_hndlr(sts, ret_end, "EMget_props");
  
   if(props & EMED_SUBORDINATE) {
     sts = om$get_channel_objects(
                        osnum = objspc_num,
                        objid = loc_edg[ii],
                        p_chanselect = &chan_to_common_edge,
                        list = &comm_edge,
                        size = 1,
                        count = (OMuint *)&count);

     EMomerr_hndlr ( sts, ret_end, "get_channel_objects");
   
     loc_edg[ii] = comm_edge.S_objid;

   }

 }
ret_end:
 return;
}

end implementation ECsfedloc; 
