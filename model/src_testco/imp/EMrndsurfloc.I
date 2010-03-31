class implementation ECsfedloc;

/*
DESCRIPTION
	This method locates edges using the surface loop option.

OPTIONS
	No options supported

ALGORITHM
	The user locates the surface loop of surfaces. If the surface has inner
	loops further processing is done.

HISTORY
 	Tapadia  01/18/93 Written for Phoenix rounding interface.
	Jaikish  01/06/98 added roundn as fix for TR#119701572
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
#include "execmsg.h"
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"

#define FALSE 0
#define TRUE 1

#define CHAIN_TYPE              1
#define EDGE_VERTEX_TYPE        2
#define SURFACE_LOOP_TYPE       3
#define FILLET_TYPE             4
#define RADII_TYPE              5

#define IDENTIFY_SURFACE 	0 
#define ACCEPT_NXT_SURFACE 	1 
#define OUTER_INNER_LOOP 	2 
#define IDENTIFY_SURF_RADII 	3 
#define INPUT_RADII 		4 

#define CONSTANT_TYPE		6
#define VARYING_TYPE		7

#define DEBUG        1

#define PROMPT_SIZE 65
#define ERROR_SIZE  58

from EMSedge import EMget_props;
from EMSedge import EMget_props_type;
from EMSedge import EMdisplay;
from EMSedge import EMget_bcxyz_geom, EMchkconvex;
from EMSboundary import EMgetsurface_info;
from EMSsurface import EMgetactiveid, EMgetedges;
from GRowner     import GRget_number_components;
from EMSloop    import EMget_edges;
from GRgraphics import GRdisplay, GRlocaldp;
from EMSloopset    import EMget_loops;

extern GRclassid OPP_EMSgraloop_class_id,
		 OPP_EMSloop_class_id;
extern GRclassid OPP_EMSsurface_class_id;

extern IGRlong EFlocate_action_handler();
extern IGRlong EFhilite_edge_with_weight();
extern void EFrestore_hilite_of_edges();
extern void EFcheck_strlen();
extern void roundn();
extern IGRboolean EFedge_curves_locatable();
extern void EFparse_keyin();
extern void EFsubparse_keyin();
extern void EFcheck_if_neutral();
extern void EFchkif_edges_neutral();
extern void EFget_domn_edges();
extern IGRlong EFparse_edges();

static IGRboolean aflag;


method locate_surf_edge(IGRlong       *ret_msg;
                     IGRint        *response;
                     IGRchar       *response_data;
                     IGRchar       *status_string;                     
                     char          (*funcptr) () )
{
  IGRint                      nm_edges,ii,i ;
  IGRboolean                  stat_func=TRUE;
  GRobjid                     first_edge;
  OMuword                     rclass, eliclass, objspc_num ;
  OM_S_CLASSLIST              rtree_classes, elig_classes;
  struct  GRlc_locate         attributes;
  IGRlong                     sts, object_located=0,msg, size, display_flag,
                              eventmask1, eventmask2;
  IGRint                      count = 0;
  OM_S_CHANSELECT             chan_to_common_edge;
  enum GRdpmode               display_mode;
  IGRchar                     loc_prompt[80], accept_prompt[80];
  struct IGRline              boreline;
  IGRpoint                    point1, point2;
  IGRint                      event_mask, num_entries,num_elements;
  IGRboolean                  edge_locatable=FALSE;
  IGRboolean loop_locatable = FALSE;
  GRobjid                     srfid;
  OM_S_CHANSELECT  to_loops, to_inner, to_edges, to_loopset;


  IGRlong qsize, event_size;
  IGRdouble chtol,temp_rad;
  struct GRid *tmp_edges=NULL;
  IGRint num_edges,jj,num_tmp,numedges, buf_size = 0;
  GRobjid *tmp_ed = NULL;
  IGRshort *mattyp;
  IGRdouble *mat;
  IGRint lp_depth;
  IGRlong EFlocate_surface_action_handler();
  IGRlong EFlocate_surface_select_handler();

  *ret_msg = EMS_S_Success;  
  sts = OM_S_SUCCESS;

  BSEXTRACTPAR(&msg, BSTOLCHRDHT, chtol);

  event_size = sizeof(struct GRevent);
  qsize = event_size - 2 * sizeof(IGRint);
  objspc_num = me->ModuleInfo.md_id.osnum;

  EMmake_chanselect(EMSedge_to_owner, &to_loops);
  EMmake_chanselect(EMSloop_to_inner, &to_inner);
  EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);
  EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);

  loop_locatable = EFloop_curves_locatable();
  edge_locatable = EFedge_curves_locatable();

  if(!loop_locatable)
    EFset_locate_eligibility(&msg,1,"EMSloop");
  if(!edge_locatable)
    EFset_locate_eligibility(&msg,1,"EMSedge");

  boreline.point1 = point1;
  boreline.point2 = point2;
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
     case IDENTIFY_SURFACE:
      {

       IGRchar buff1[25],buff2[25],buff3[25],inp_buff[80];
       GRstatus_display_button(TRUE);
       eventmask1 =  GRm_VALUE| GRm_DATA | GRm_BACK_UP 
			| GRm_RJT_MOVEON| GRm_STRING ;

       nm_edges = 0;
       for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }

       ex$message(msgnumb = EMS_I_SurfMode, buff = buff3)

       if(me->selection) ex$message(msgnumb = EMS_I_Select,buff = buff2)
       else ex$message(msgnumb = EMS_I_DSelect, buff = buff2)

       if(me->fillet_type == VARYING_TYPE)
          ex$message(msgnumb = EMS_I_VaryRad, buff = buff1)
       else ex$message(msgnumb = EMS_I_ConstRad, buff = buff1)

       strncpy(inp_buff,buff1,24);
       strcat(inp_buff,"  -  ");
       strncat(inp_buff,buff2,24);
       strcat(inp_buff,"  -  ");
       strncat(inp_buff,buff3,24);

       ex$message(field = ERROR_FIELD, justification = CENTER_JUS,
                  in_buff = inp_buff);

       if(!nm_edges && !me->numtmped && me->selection)
         me->active_GRid.objid = NULL_OBJID;
	 temp_rad=me->active_rad;
	 roundn(&temp_rad,3);
       if(!nm_edges && !me->numtmped && me->selection
           && me->fillet_type == CONSTANT_TYPE) 
       {
            ex$message(msgnumb = EMS_P_IdSurfKeyRad, type = "%.3g",
                        var = `temp_rad`, buff = loc_prompt,
                        buffer_size = PROMPT_SIZE)
       }
       else 
       {
            if((me->fillet_type == VARYING_TYPE && me->selection) ||
                !me->selection)
                ex$message(msgnumb = EMS_P_IdSurfMoveOn, buff = loc_prompt,
                           buffer_size = PROMPT_SIZE )
            else
                ex$message(msgnumb = EMS_P_IdSurfKeyRadMo, type = "%.3g",
                        var = `temp_rad`, buff = loc_prompt,
                           buffer_size = PROMPT_SIZE )
       }


       if(me->locate_stack.num_entries == 0 || me->option_change){ 
         me->valid_inputdata = TRUE;
         me->locate_stack.num_entries = 0;
         ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
			 in_buff = loc_prompt)
       }
       else {
	if(me->inner_loop) 
	  ex$message(msgnumb = EMS_P_00038,buff = accept_prompt,
                     buffer_size = PROMPT_SIZE)
	else 
	  ex$message(msgnumb = EMS_P_AccNxtSurfRej, buff = accept_prompt,
                     buffer_size = PROMPT_SIZE);
        ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
			 in_buff = accept_prompt)
       }
        me->option_change = FALSE;
       stat_func = ems$getevent(msg = &msg, event_mask = eventmask1,
                value_type = GRIO_DISTANCE, response = (long *)response,
                response_data = response_data, event = &me->loc_event);


       if(msg == GRw_no_value)
		me->loc_event.response = EX_RJT_MOVEON;

      switch (me->loc_event.response) {
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
             me->end_edgeval_event[me->numed+me->numtmped ].num_id= 0;
             me->edgeval_event[me->numed+me->numtmped ].num_id= 0;
             me->edgeval_event[me->numed + me->numtmped]= me->loc_event;
             me->end_edgeval_event[me->numed+me->numtmped].event.value = -1.0;
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
        OMuword accept_classid;
        struct rnd_surf_loc_acthndlr rnd_surf_loc;
        struct rnd_surfloop_selhndlr  surf_selhndlr_args;
  	IGRchar  *my_args;
        struct GRid srf_ownr;
        IGRboolean  single_surface=FALSE;
        IGRint      buf1_size = 0,num_components;
	GRobjid *tmp_edge;

        sts = ex$putque(msg = &msg, response = response,
                        byte = &qsize, buffer = (char *)&me->loc_event.event);
/*
        eventmask2 = GRm_VALUE| GRm_STRING |GRm_DATA 
			| GRm_BACK_UP | GRm_RJT_MOVEON;
*/
        eventmask2 = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
	if(me->inner_loop) 
	  ex$message(msgnumb = EMS_P_00038,buff = accept_prompt)
	else 
	  ex$message(msgnumb = EMS_P_AccNxtSurfRej, buff = accept_prompt);

       accept_classid = OPP_EMSsurface_class_id;
       rnd_surf_loc.option = 1;
       rnd_surf_loc.num_objects = 2;
       rnd_surf_loc.acc_prompt = accept_prompt;
       rnd_surf_loc.classids = &accept_classid;
       rnd_surf_loc.my_inst.objid = my_id;
       rnd_surf_loc.my_inst.osnum = OM_Gw_current_OS;
       rnd_surf_loc.next = NULL;
	
       surf_selhndlr_args.my_inst.objid = my_id;
       surf_selhndlr_args.my_inst.osnum = OM_Gw_current_OS;
       surf_selhndlr_args.edge_type = me->edge_type;
       my_args = (IGRchar *)&surf_selhndlr_args;

       size = sizeof(struct GRevent);
       attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 LC_PLANAR_NON_PLANAR;
       aflag = pwIsActivationOn();
       if (aflag)
       {
       attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD | 
                                 LC_OBJ_W_OWNER | 
                                 LC_REF_OBJECTS |
                                 LC_NO_REF_HEADER;
       /* Added REF_OBJECTS for RFA */
       }
       else
       {
       attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD | 
                                 LC_OBJ_W_OWNER | 
                                 LC_NO_REF_HEADER;
       }
       strcpy(attributes.classes, "EMSsurface");
       display_flag = DO_NOT_RELOCATE | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;
        
       rtree_classes.w_count = 1;
       elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

       rclass = OPP_EMSsurface_class_id;
       eliclass = OPP_EMSsurface_class_id;

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
                 acc_prompt = accept_prompt,
                 relocate_key = EMS_P_EdgeNotFound, 
                 attributes = &attributes,
                 act_handler = EFlocate_surface_action_handler,
                 act_args = &rnd_surf_loc,
		 select = EFlocate_surface_select_handler,
		 select_args = my_args,
                 stack = &ME.ECsfedloc->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);

       if( (!stat_func)) {
         *ret_msg = EMS_I_Interrupt;
         goto ret_end;
       }
       if(object_located == LC_OBJ_LOCATED) {
            if(!me->inner_loop) {
                sts = ex$putque(msg = &object_located, response = response,
                        byte = &qsize, buffer = (char *)&me->event.event);
                me->process_state = ACCEPT_NXT_SURFACE;
            }
            else
                me->process_state = OUTER_INNER_LOOP;
       }

       switch(me->event.response) {
         case EX_VALUE:
	 case EX_STRING:
	   {
            ex$message(msgnumb =EMS_S_InvalidKeyin) ;
            sleep(1);
	    break;
	   }
	 case EX_BACK_UP:
	 {
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
	    EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);
         }
         else
         {
	   ex$message(msgnumb =EMS_S_NoPrevBkp) ;
           sleep(1);
          }
	  break;
	 }
	 case EX_RJT_MOVEON:
	 {
	  if(*response != EX_RJT_MOVEON) break;
	  if(me->loc_event.response == EX_DATA || !me->valid_inputdata) {
            if(!me->selection)
	    EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);
	  }
	  else {
            nm_edges = 0;
            for(ii = 0; ii < me->numed; ii++) {
              if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
              nm_edges++;
            }
            if((!nm_edges && !me->numtmped) || ((nm_edges == me->numtmped) && 
		!me->selection)) {
	      ex$message(msgnumb = EMS_S_IgnMoOnRej);
	      sleep(1);
              me->process_state = IDENTIFY_SURFACE;
            }
            else {
                   /* Successful completion */
              sts = OM_S_SUCCESS;
              goto ret_end;  
	    }
	  }
	  break;
	 }
	 case EX_DATA:
	   {

	    if(!object_located) break;
            first_edge = me->event.located_object[0].located_obj.objid;
            objspc_num = me->event.located_object[0].located_obj.osnum;
            me->act_surf_id.objid = first_edge;
	     me->act_surf_id.osnum = objspc_num;

       	     mattyp=&me->event.located_object[0].module_info.md_env.matrix_type; 
             mat = me->event.located_object[0].module_info.md_env.matrix; 

             ME.COroot->ModuleInfo = me->event.located_object[0].module_info; 

             sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                            (&msg, &srfid, NULL),
                           targetid = first_edge,
                           targetos = objspc_num );
        EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

        sts = om$send(msg = message EMSsurface.EMgetactiveid(&msg,
                              &srf_ownr, NULL),
                        targetid = srfid,
                        targetos = objspc_num);
        EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);


	tmp_edges = NULL;
        buf1_size = numedges = 0;
        sts = om$send(msg = message EMSloop.EMget_edges(&msg, 1,
                        EMS_OPT_ALL,
                        &tmp_edges, &buf1_size, &numedges),
                senderid = NULL_OBJID,
                targetid = first_edge,
                targetos = objspc_num);
        EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

	tmp_edge = (GRobjid *)stackalloc(sizeof(GRobjid) * numedges);
	for(i = 0; i < numedges ; i++)
	   tmp_edge[i] = tmp_edges[i].objid;


        if(srf_ownr.objid == srfid)
         {
          single_surface = TRUE;
         }
        else 
         {
          sts = om$send (msg = message GRowner.GRget_number_components(
                         ret_msg, &num_components),
                   targetid = srf_ownr.objid,
                   targetos = srf_ownr.osnum);
          EMomerr_hndlr(sts, ret_end, "GRget_number_components");

          if (num_components == 1)
            single_surface = TRUE;
          else
            single_surface = FALSE;
          }
        
        if(single_surface) 
          {
            ex$message ( msgnumb = EMS_S_SingleSurfNotAllowed);
	    sleep(1);
            me->process_state = IDENTIFY_SURFACE;
            break;
           }          

        nm_edges = 0;
       for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }
        if(!me->numtmped && !nm_edges) {
         me->active_GRid.objid = srf_ownr.objid;
         me->active_GRid.osnum = srf_ownr.osnum;
	}
        else
         if ((me->active_GRid.objid != srf_ownr.objid) ||
            (me->active_GRid.osnum != srf_ownr.osnum))
         {
            ex$message ( msgnumb = EMS_S_EdgePartDiffComposite );
	    sleep(1);
            me->process_state = IDENTIFY_SURFACE;
            break;
	}
        EFchkif_edges_neutral(tmp_edge,&numedges,objspc_num,
			mattyp,mat,me->neutral_edge_angle);
	sts = EFparse_edges(&msg, &me->selection, me->located_obj, 
			me->tmp_located_obj, me->numed, me->numtmped,
			tmp_edge, objspc_num, &numedges,me->bound_code);

        display_mode = GRhe ;
	for(ii=0; ii< numedges; ii++) {
        sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                      tmp_edge[ii], display_mode );
        EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
	}

        /* fix for mlk */
        if(tmp_edges)
          {
          om$dealloc(ptr = tmp_edges);
          tmp_edges = NULL;
          }
	if(!me->inner_loop) {

	    if(numedges || !me->selection) {
	        for(i = 0; i < numedges; i++) {
		    if(me->selection)
                	display_mode = GRhd ;
		    else 
                	display_mode = GRhe ;
		    sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                	targetid = tmp_edge[i],
                	targetos = objspc_num);
	        }
	    }

	num_entries = om$dimension_of(varray = me->num_bkp_list);
	if((me->num_bkp_entries + 1) >= num_entries) {
	   sts = om$vla_set_dimension(varray = me->num_bkp_list,
			size = me->num_bkp_entries + 1 );
	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
        }
             num_elements = om$dimension_of(varray = me->tmp_located_obj);
             if ((me->numtmped + 1 + numedges) >= num_elements)
             {
               sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                         size = num_elements + 4 + numedges);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");

	     }
	     if((me->numed + me->numtmped + numedges + 1) >= num_elements) {
               sts = om$vla_set_dimension(varray = me->edgeval_event,
                            size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");
               sts = om$vla_set_dimension(varray = me->end_edgeval_event,
                            size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");
               sts = om$vla_set_dimension(varray = me->fill_typ,
                            size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");
               sts = om$vla_set_dimension(varray = me->bound_code,
                            size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");
             }

             EFget_domn_edges(tmp_edge,numedges,objspc_num);
             for(i = 0; i < numedges; i++) {
                me->tmp_located_obj[me->numtmped + i] = tmp_edge[i];
                me->end_edgeval_event[me->numed+me->numtmped + i].num_id= 0;
                me->edgeval_event[me->numed+me->numtmped + i].num_id= 0;
	        me->edgeval_event[me->numed + i + me->numtmped].event.value =
		    me->active_rad;
	        me->end_edgeval_event[me->numed+i + me->numtmped].event.value = 
		    -1.0;
	        me->fill_typ[me->numed + i + me->numtmped] = me->fillet_type;
                me->bound_code[i + me->numed+me->numtmped]=0;
                if(me->fillet_type == VARYING_TYPE)
                   me->bound_code[i+ me->numed+me->numtmped]=
                     EMSrnd_input_ed_grp_start;
             }
            
            if(me->numtmped == 0 || !me->radius_changed) {
              me->bound_code[me->numed+me->numtmped]=EMSrnd_input_ed_grp_start;
              me->radius_changed = 1;
            }
             me->numtmped += numedges;

          me->num_bkp_entries ++;
	  me->num_bkp_list[me->num_bkp_entries-1] = numedges;
             me->process_state = ACCEPT_NXT_SURFACE;
	}
	else {
		/* Display the entire surface (outer & inner loops) */
		me->inner_loop = FALSE;
		display_mode = GRhd;
		lp_depth = MAXINT; /* Outer & inner loop edges */
                tmp_edges = NULL;
                buf_size = numedges = NULL;
                sts = om$send(msg = message EMSloop.EMget_edges(&msg, lp_depth,
			EMS_OPT_ALL, &tmp_edges, &buf_size, &numedges),
                    senderid = NULL_OBJID,
                    targetid = first_edge,
                    targetos = objspc_num);
                EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

                tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * numedges);
		for(ii = 0; ii< numedges; ii++)
		  tmp_ed[ii] = tmp_edges[ii].objid;
                EFchkif_edges_neutral(tmp_ed,&numedges,objspc_num,
			mattyp,mat,me->neutral_edge_angle);

                sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                        me->tmp_located_obj, me->numed, me->numtmped,
                        tmp_ed, objspc_num, &numedges,me->bound_code);
		for(ii=0;ii< numedges; ii++) {
		sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmp_ed[ii],
                        targetos = objspc_num);
                EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);
		}
		if(tmp_ed) stackfree (ptr = tmp_ed);

           	me->process_state = OUTER_INNER_LOOP;
                /* fix for mlk */
                if(tmp_edges)
                  {
                  om$dealloc(ptr = tmp_edges);
                  tmp_edges = NULL;
                  }
	  }
          break;
         }
         default:
         if(*response == STRING ) {
	  IGRint ret_type;
          EFsubparse_keyin(response_data,&ret_type);
          if(ret_type == 0 ) {
            ex$message(msgnumb =EMS_S_InvalidKeyin) ;
            sleep(1);
          }
          if( ret_type == 1) {
		   /* cant change options */
	  }
	  break;

	} /* response is STRING */
	 me->valid_inputdata = FALSE;
	 goto ret_end;
       }
	break;
      }

      default:
	 goto ret_end;
       }
     break;               
    }

    case OUTER_INNER_LOOP:
      {
	struct GRid *tm_edges;
	GRobjid *t_edges;
	IGRint numedges =0,num_tedges=0;
	
	me->valid_inputdata = FALSE;
        GRstatus_display_button(FALSE);
	ex$message(msgnumb = EMS_P_DataPtOuterLoop)
	event_mask = GRm_VALUE|GRm_DATA | GRm_RJT_MOVEON 
			| GRm_STRING | GRm_BACK_UP;

  	sts = ems$getevent(msg = &msg, event_mask = event_mask,
		value_type = GRIO_DISTANCE, response = (long *)response, 
		response_data = response_data, event = &me->event);
		
        ex$message(msgnumb = EMS_P_ClearPromptField)
        ex$message(msgnumb = EMS_I_ClearStatusField)
	if(!(1 & sts)) {
		sts = 0;
		goto ret_end;
	}
	first_edge = me->act_surf_id.objid;
	objspc_num = me->act_surf_id.osnum;


	switch(me->event.response) {
	    case EX_STRING:
	    case EX_VALUE:
	      {
              ex$message(msgnumb =EMS_S_InvalidKeyin) ;
              sleep(1);
	      break;
	      }	
	    case EX_DATA:
	    case EX_RJT_MOVEON:
           	me->process_state = IDENTIFY_SURFACE;
       		mattyp = &me->ModuleInfo.md_env.matrix_type; 
        	mat = me->ModuleInfo.md_env.matrix; 
		first_edge = me->act_surf_id.objid;
		objspc_num = me->act_surf_id.osnum;
		
		lp_depth = MAXINT; /* Outer & inner loop edges */
		tmp_edges = NULL;
                buf_size = numedges = NULL;
                sts = om$send(msg = message EMSloop.EMget_edges(&msg, lp_depth,
EMS_OPT_ALL,
                        &tmp_edges, &buf_size, &numedges),
                    senderid = NULL_OBJID,
                    targetid = first_edge,
                    targetos = objspc_num);
                EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

                t_edges = (GRobjid *) stackalloc(sizeof(GRobjid) * numedges);
		for(ii = 0 ; ii< numedges; ii++)
		  t_edges[ii] = tmp_edges[ii].objid;
                /* fix for mlk */
                if(tmp_edges)
                  {
                  om$dealloc(ptr = tmp_edges);
                  tmp_edges = NULL;
                  }
	        EFchkif_edges_neutral(t_edges,&numedges,objspc_num,
                        mattyp,mat,me->neutral_edge_angle);

                sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                        me->tmp_located_obj, me->numed, me->numtmped,
                        t_edges, objspc_num, &numedges,me->bound_code);
		display_mode = GRhe ;
		for(ii=0;ii<numedges;ii++) {
	       sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = t_edges[ii],
                        targetos = objspc_num);
                EMomerr_hndlr(sts, ret_end, "EMdisplay");
		}
		num_tedges = numedges;


		if(me->event.response == EX_DATA)  
			lp_depth = 1; /* only outer loop edges */
		else
			lp_depth = MAXINT; /* Outer & inner loop edges */
	    	tmp_edges = NULL;
	    	buf_size = numedges = NULL;
	    	sts = om$send(msg = message EMSloop.EMget_edges(&msg, lp_depth, EMS_OPT_ALL,
			&tmp_edges, &buf_size, &numedges),
		    senderid = NULL_OBJID,
		    targetid = first_edge,
		    targetos = objspc_num);
                EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

	        tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * numedges);

	        for(ii = 0; ii < numedges; ii++) 
		    tmp_ed[ii] = tmp_edges[ii].objid;

		EFchkif_edges_neutral(tmp_ed,&numedges,objspc_num,
                        mattyp,mat,me->neutral_edge_angle);

	        sts = EFparse_edges(&msg, &me->selection, me->located_obj, 
			me->tmp_located_obj, me->numed, me->numtmped,
			tmp_ed, objspc_num, &numedges,me->bound_code);

	        for(ii = 0; ii < numedges; ii++) 
		    tmp_edges[ii].objid = tmp_ed[ii];

	        if(tmp_ed) stackfree (ptr = tmp_ed);

         	EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,me->ModuleInfo,me->bound_code);
	        if(numedges) {
		        if(me->selection)
                	    display_mode = GRhd ;
		        else 
                	    display_mode = GRhe ;
	            for(i = 0; i < numedges; i++) {

                    sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmp_edges[i].objid,
                        targetos = objspc_num);
                       EMomerr_hndlr(sts, ret_end, "EMdisplay");
	            }
	        }

		if(me->event.response == EX_DATA && !me->selection) {
		  tm_edges = NULL;
		  lp_depth = 1;
                  buf_size = num_edges = NULL;
                  sts = om$send(msg = message EMSloop.EMget_edges(&msg, 
			lp_depth, EMS_OPT_ALL,
                        &tm_edges, &buf_size, &num_edges),
                    senderid = NULL_OBJID,
                    targetid = first_edge,
                    targetos = objspc_num);
                  EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

		  tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * num_edges);

                for(ii = 0; ii < num_edges; ii++)
                    tmp_ed[ii] = tm_edges[ii].objid;
                /* fix for mlk */
                if(tm_edges)
                  {
                  om$dealloc(ptr = tm_edges);
                  tm_edges = NULL;
                  }

		EFchkif_edges_neutral(tmp_ed,&num_edges,objspc_num,
                        mattyp,mat,me->neutral_edge_angle);

                sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                        me->tmp_located_obj, me->numed, me->numtmped,
                        tmp_ed, objspc_num, &num_edges,me->bound_code);
		for(ii=0;ii < num_edges; ii++) {
		  num_tmp = 0;
		  for(jj = 0; jj < num_tedges; jj++) {
		    if(t_edges[jj] == tmp_ed[ii]) {
		      num_tmp++;continue;
		    }
		    t_edges[jj - num_tmp] = t_edges[jj];
	          }
		}
		num_tedges -= num_edges;
		
		if(num_tedges) {
                            display_mode = GRhd ;
                    for(i = 0; i < num_tedges; i++) {

                    sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = t_edges[i],
                        targetos = objspc_num);
                       EMomerr_hndlr(sts, ret_end, "EMdisplay");
                    }
                }
		}
	num_entries = om$dimension_of(varray = me->num_bkp_list);
	if((me->num_bkp_entries + 1) >= num_entries) {
	   sts = om$vla_set_dimension(varray = me->num_bkp_list,
			size = me->num_bkp_entries + 1 );
	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
        }
                 num_elements = om$dimension_of(varray = me->tmp_located_obj);
                 if ((me->numtmped + 1 + numedges) >= num_elements)
                 {
                   sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                         size = num_elements + 4 + numedges);
                   EMomerr_hndlr(sts, ret_end, "set_dimension  error");

	         }
	         if((me->numed + me->numtmped + numedges + 1) >= num_elements) {
                   sts = om$vla_set_dimension(varray = me->edgeval_event,
                            size = num_elements + 4 + numedges + me->numed);
                   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
                   sts = om$vla_set_dimension(varray = me->end_edgeval_event,
                            size = num_elements + 4 + numedges + me->numed);
                   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
                   sts = om$vla_set_dimension(varray = me->fill_typ,
                            size = num_elements + 4 + numedges + me->numed);
                   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
                   sts = om$vla_set_dimension(varray = me->bound_code,
                            size = num_elements + 4 + numedges + me->numed);
                   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
                 }
	        tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * numedges);
	        for(ii = 0; ii < numedges; ii++) 
		    tmp_ed[ii] = tmp_edges[ii].objid;
                /* fix for mlk */
                if(tmp_edges)
                  {
                  om$dealloc(ptr = tmp_edges);
                  tmp_edges = NULL;
                  }
                EFget_domn_edges(tmp_ed,numedges,objspc_num);
    
                 for(i = 0; i < numedges; i++) {
                   me->tmp_located_obj[me->numtmped + i] = tmp_ed[i];
                   me->end_edgeval_event[me->numed+me->numtmped + i].num_id= 0;
                   me->edgeval_event[me->numed+me->numtmped + i].num_id= 0;
	           me->edgeval_event[me->numed +i+me->numtmped].event.value =
		       me->active_rad;
	           me->end_edgeval_event[me->numed+i+me->numtmped].event.value= 
		        -1.0;
	           me->fill_typ[me->numed + i + me->numtmped] = me->fillet_type;
                   me->bound_code[i + me->numed+me->numtmped]= 0;
                if(me->fillet_type == VARYING_TYPE)
                   me->bound_code[i+ me->numed+me->numtmped]=
                     EMSrnd_input_ed_grp_start;
                 }
          
            if(me->numtmped == 0 || !me->radius_changed) {
              me->bound_code[me->numed+me->numtmped]= EMSrnd_input_ed_grp_start;
              me->radius_changed = 1;
            }

          me->num_bkp_entries ++;
	  me->num_bkp_list[me->num_bkp_entries-1] = numedges;
	        me->numtmped += numedges;

	    	if((me->fillet_type == VARYING_TYPE) && me->selection)
			me->process_state = IDENTIFY_SURF_RADII;
		break;

	    case EX_BACK_UP:
       		mattyp = &me->ModuleInfo.md_env.matrix_type; 
        	mat = me->ModuleInfo.md_env.matrix; 
		display_mode = GRhe;
		lp_depth = MAXINT; /* Outer & inner loop edges */
                tmp_edges = NULL;
                buf_size = numedges = NULL;
                sts = om$send(msg = message EMSloop.EMget_edges(&msg, lp_depth,
			EMS_OPT_ALL, &tmp_edges, &buf_size, &numedges),
                    senderid = NULL_OBJID,
                    targetid = first_edge,
                    targetos = objspc_num);
                EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

                tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * numedges);
		for(ii = 0; ii< numedges; ii++)
		  tmp_ed[ii] = tmp_edges[ii].objid;
                if(tmp_edges)
                  {
                  om$dealloc(ptr = tmp_edges);
                  tmp_edges = NULL;
                  }
                EFchkif_edges_neutral(tmp_ed,&numedges,objspc_num,
			mattyp,mat,me->neutral_edge_angle);

                sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                        me->tmp_located_obj, me->numed, me->numtmped,
                        tmp_ed, objspc_num, &numedges,me->bound_code);
		for(ii=0;ii< numedges; ii++) {
		sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmp_ed[ii],
                        targetos = objspc_num);
                EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);
		}
		if(tmp_ed) stackfree (ptr = tmp_ed);
           	me->process_state = IDENTIFY_SURFACE;
		break;

	    default:
		    me->valid_inputdata = FALSE;
		    goto ret_end;
	}
	break;
      }

     case ACCEPT_NXT_SURFACE:
      {
       struct rnd_surf_loc_acthndlr rnd_surf_loc;
       struct rnd_surfloop_selhndlr  surf_selhndlr_args;
        IGRchar  *my_args;
       OMuword accept_classid;

        GRstatus_display_button(FALSE);
       accept_classid = OPP_EMSsurface_class_id;
	me->valid_inputdata = FALSE;

       if(me->inner_loop)
	 ex$message(msgnumb = EMS_P_00038, buff = accept_prompt)
       else	
         ex$message(msgnumb = EMS_P_AccNxtSurfRej, buff = accept_prompt);
       rnd_surf_loc.option = 1;
       rnd_surf_loc.num_objects = 2;
       rnd_surf_loc.acc_prompt = accept_prompt;
       rnd_surf_loc.classids = &accept_classid;
       rnd_surf_loc.my_inst.objid = my_id;
       rnd_surf_loc.my_inst.osnum = OM_Gw_current_OS;
       rnd_surf_loc.next = NULL;
	
       surf_selhndlr_args.my_inst.objid = my_id;
       surf_selhndlr_args.my_inst.osnum = OM_Gw_current_OS;
       surf_selhndlr_args.edge_type = me->edge_type;	
       my_args = (IGRchar *)&surf_selhndlr_args;


       eventmask1 = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
       eventmask2 = GRm_DATA | GRm_BACK_UP |GRm_RJT_MOVEON;

       size = sizeof(struct GRevent);
       attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 LC_PLANAR_NON_PLANAR;
       aflag = pwIsActivationOn();
       if (aflag)
       {
       attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD | 
                                 LC_OBJ_W_OWNER | 
                                 LC_REF_OBJECTS |
                                 LC_NO_REF_HEADER;
       /* Added REF_OBJECTS for RFA */
       }
       else
       {
       attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD | 
                                 LC_OBJ_W_OWNER | 
                                 LC_NO_REF_HEADER;
       }
       strcpy(attributes.classes, "EMSsurface");
       display_flag = DO_NOT_RELOCATE | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;
        
       rtree_classes.w_count = 1;
       elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

       rclass = OPP_EMSsurface_class_id;
       eliclass = OPP_EMSsurface_class_id;

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
                 acc_prompt = accept_prompt,
                 relocate_key = EMS_P_EdgeNotFound, 
                 attributes = &attributes,
                 act_handler = EFlocate_surface_action_handler,
                 act_args = &rnd_surf_loc,
		 select = EFlocate_surface_select_handler,
		 select_args = my_args,
                 stack = &ME.ECsfedloc->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);

    if(!stat_func)
        {
         *ret_msg = EMS_I_Interrupt;
         goto ret_end;
        }

	if(object_located == LC_OBJ_LOCATED) {
	    if(!me->inner_loop) {
		sts = ex$putque(msg = &object_located, response = response,
			byte = &qsize, buffer = (char *)&me->event.event);
            	me->process_state = ACCEPT_NXT_SURFACE;
	    }
	    else { 
            	me->process_state = OUTER_INNER_LOOP;
	    }
	}
	else {
	    if(me->loc_event.response == EX_DATA) {
               mattyp = &me->ModuleInfo.md_env.matrix_type;
               mat = me->ModuleInfo.md_env.matrix;

/*
               EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,me->ModuleInfo,me->bound_code);
*/
	   	if(me->fillet_type == VARYING_TYPE && me->selection) 
           		me->process_state = IDENTIFY_SURF_RADII;
	   	else 
           		me->process_state = IDENTIFY_SURFACE;
		me->event.response = GR_UNKNOWN_TYPE;
	    }
	}

      switch (me->event.response)
      {
       case EX_RJT_MOVEON:
	   if(me->fillet_type == VARYING_TYPE && me->selection) 
           	me->process_state = IDENTIFY_SURF_RADII;
	   else 
           	me->process_state = IDENTIFY_SURFACE;
           break;

       case  EX_BACK_UP:
	 if(*response != EX_BACK_UP) break; 
         if(me->num_bkp_entries)
         {
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
	  EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);
         }
         else
         {
           me->process_state = IDENTIFY_SURFACE;
	   ex$message(msgnumb =EMS_S_NoPrevBkp) ;
           sleep(1);
          }
	  break;
      case EX_DATA:
       {
        struct GRid srf_ownr;
        IGRboolean  single_surface=FALSE;
        IGRint      buf1_size =0, numedges=0,num_components;
	GRobjid *tmp_edge;

	if(!object_located) break;
        first_edge = me->event.located_object[0].located_obj.objid;
        objspc_num = me->event.located_object[0].located_obj.osnum;

	me->act_surf_id.objid = first_edge;
	me->act_surf_id.osnum = objspc_num;

        mattyp = &me->event.located_object[0].module_info.md_env.matrix_type; 
        mat = me->event.located_object[0].module_info.md_env.matrix; 
        ME.COroot->ModuleInfo = me->event.located_object[0].module_info; 

	sts = om$get_channel_count(osnum = objspc_num,
				objid = first_edge,
				p_chanselect = &to_loopset,
				count = (OMuint *)&count);

        EMmake_chanselect(EMSedge_to_owner, &to_loops);

        ME.COroot->ModuleInfo = me->event.located_object[0].module_info; 
        sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                            (&msg, &srfid, NULL),
                           targetid = first_edge,
                           targetos = objspc_num );
        EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

        sts = om$send(msg = message EMSsurface.EMgetactiveid(&msg,
                              &srf_ownr, NULL),
                        targetid = srfid,
                        targetos = objspc_num);
        EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

	tmp_edges = NULL;
        buf1_size = numedges = 0;
        sts = om$send(msg = message EMSloop.EMget_edges(&msg, 1,
                        EMS_OPT_ALL,
                        &tmp_edges, &buf1_size, &numedges),
                senderid = NULL_OBJID,
                targetid = first_edge,
                targetos = objspc_num);
        EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

	tmp_edge = (GRobjid *)stackalloc(sizeof(GRobjid) * numedges);
        for(i = 0; i < numedges ; i++)
           tmp_edge[i] = tmp_edges[i].objid;

        if(tmp_edges)
          {
          om$dealloc(ptr = tmp_edges);
          tmp_edges = NULL;
          }

        if ( srf_ownr.objid == srfid )
         {
          single_surface = TRUE;
         }
        else 
         {
          sts = om$send (msg = message GRowner.GRget_number_components(
                         ret_msg, &num_components),
                   targetid = srf_ownr.objid,
                   targetos = srf_ownr.osnum);
          EMomerr_hndlr(sts, ret_end, "GRget_number_components");

          if (num_components == 1)
            single_surface = TRUE;
          else
            single_surface = FALSE;
          }
        
        if(single_surface) 
          {
            ex$message ( msgnumb = EMS_S_SingleSurfNotAllowed);
	    sleep(1);
            me->process_state = ACCEPT_NXT_SURFACE;
            break;
           }          

        nm_edges = 0;
       for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }
        if(!me->numtmped && !nm_edges) {
         me->active_GRid.objid = srf_ownr.objid;
         me->active_GRid.osnum = srf_ownr.osnum;
	}
        else
         if ((me->active_GRid.objid != srf_ownr.objid) ||
            (me->active_GRid.osnum != srf_ownr.osnum))
         {
            ex$message ( msgnumb = EMS_S_EdgePartDiffComposite );
	    sleep(1);
            me->process_state = ACCEPT_NXT_SURFACE;
            break;
         }

	 EFchkif_edges_neutral(tmp_edge,&numedges,objspc_num,
                        mattyp,mat,me->neutral_edge_angle);

	    sts = EFparse_edges(&msg, &me->selection, me->located_obj, 
			me->tmp_located_obj, me->numed, me->numtmped,
			tmp_edge, objspc_num, &numedges,me->bound_code);

        display_mode = GRhe ;
	for(ii=0;ii < numedges;ii++) {
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                  tmp_edge[ii], display_mode );
            EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
	}
	if(!me->inner_loop) {

	    if(numedges || !me->selection) {
		    if(me->selection)
                	display_mode = GRhd ;
		    else 
                	display_mode = GRhe ;
	        for(i = 0; i < numedges; i++) {
		    sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmp_edge[i],
                        targetos = objspc_num);
                       EMomerr_hndlr(sts, ret_end, "EMdisplay");
	        }
	    }

	num_entries = om$dimension_of(varray = me->num_bkp_list);
	if((me->num_bkp_entries + 1) >= num_entries) {
	   sts = om$vla_set_dimension(varray = me->num_bkp_list,
			size = me->num_bkp_entries + 1 );
	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
        }
             num_elements = om$dimension_of(varray = me->tmp_located_obj);
             if ((me->numtmped + 1 + numedges) >= num_elements)
             {
               sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                         size = num_elements + 4 + numedges);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");

	     }
	     if((me->numed + me->numtmped + numedges + 1) >= num_elements) {
               sts = om$vla_set_dimension(varray = me->edgeval_event,
                            size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");

               sts = om$vla_set_dimension(varray = me->end_edgeval_event,
                            size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");

               sts = om$vla_set_dimension(varray = me->fill_typ,
                    	    size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");
               sts = om$vla_set_dimension(varray = me->bound_code,
                            size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");
             }

             EFget_domn_edges(tmp_edge,numedges,objspc_num);
             for(i = 0; i < numedges; i++) {
               me->tmp_located_obj[me->numtmped + i] = tmp_edge[i];
               me->end_edgeval_event[me->numed+me->numtmped + i].num_id= 0;
               me->edgeval_event[me->numed+me->numtmped + i].num_id= 0;
	       me->edgeval_event[me->numed + i + me->numtmped].event.value =
		    me->active_rad;
	       me->end_edgeval_event[me->numed + i +me->numtmped].event.value = 
		    -1.0;
	       me->fill_typ[me->numed + i + me->numtmped] = me->fillet_type;
               me->bound_code[i + me->numed+me->numtmped]= 0;
                if(me->fillet_type == VARYING_TYPE)
                   me->bound_code[i+ me->numed+me->numtmped]=
                     EMSrnd_input_ed_grp_start;
               }
              
            if(me->numtmped == 0 || !me->radius_changed) {
              me->bound_code[me->numed+me->numtmped]= EMSrnd_input_ed_grp_start;
              me->radius_changed = 1;
            }
               me->numtmped += numedges;
               me->num_bkp_entries ++;
	       me->num_bkp_list[me->num_bkp_entries-1] = numedges;
	       if((me->fillet_type == VARYING_TYPE) && me->selection)
			me->process_state = IDENTIFY_SURF_RADII;
	       else
                   me->process_state = ACCEPT_NXT_SURFACE;
	}
	else {
		display_mode = GRhd;
		me->inner_loop = FALSE;
		lp_depth = MAXINT; /* Outer & inner loop edges */
                tmp_edges = NULL;
                buf_size = numedges = NULL;
                sts = om$send(msg = message EMSloop.EMget_edges(&msg, lp_depth,
EMS_OPT_ALL,
                        &tmp_edges, &buf_size, &numedges),
                    senderid = NULL_OBJID,
                    targetid = first_edge,
                    targetos = objspc_num);
                EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

                tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * numedges);

                for(i = 0; i < numedges; i++)
                    tmp_ed[i] = tmp_edges[i].objid;
                if(tmp_edges)
                  {
                  om$dealloc(ptr = tmp_edges);
                  tmp_edges = NULL;
                  }

		EFchkif_edges_neutral(tmp_ed,&numedges,objspc_num,
                        mattyp,mat,me->neutral_edge_angle);

                sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                        me->tmp_located_obj, me->numed, me->numtmped,
                        tmp_ed, objspc_num, &numedges,me->bound_code);
                for(ii=0;ii< numedges; ii++) {
                sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
		        NULL),
                        targetid = tmp_ed[ii],
                        targetos = objspc_num);
                EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);
                }

		if(tmp_ed) stackfree (ptr = tmp_ed);
            	me->process_state = OUTER_INNER_LOOP;
	 }
         break;
        }
       default:
	 
	me->valid_inputdata = FALSE;
	if(*response == CLEAR_STACK || *response == TERMINATE) goto ret_end;
	if(*response == STATUS_DISP) goto ret_end;
	if(*response == EX_CMD_KEY || *response == CMD_STRING) {
	    goto ret_end;
	}
        if(*response == STRING ) {
	  IGRint ret_type;
          EFsubparse_keyin(response_data,&ret_type);
          if(ret_type == 0 ) {
            ex$message(msgnumb =EMS_S_InvalidKeyin) ;
            sleep(1);
          }
          if( ret_type == 1) {
		   /* cant change options */
	  }

	} /* response is STRING */
        break;
       }
     break;               
    }

     case IDENTIFY_SURF_RADII:
      {
       OMuword accept_classid;
       struct rnd_surf_loc_acthndlr rnd_surf_loc;
       struct rnd_surfloop_selhndlr  surf_selhndlr_args;
        IGRchar  *my_args;


        GRstatus_display_button(FALSE);

       eventmask1 = GRm_VALUE | GRm_STRING |GRm_DATA 
			| GRm_BACK_UP | GRm_RJT_MOVEON;
       eventmask2 = GRm_DATA| GRm_BACK_UP | GRm_RJT_MOVEON;

       size = sizeof(struct GRevent);

	if(me->locate_stack.num_entries == 0 || me->option_change) 
	{
	  temp_rad=me->active_rad;
	  roundn(&temp_rad,3);
	  me->locate_stack.num_entries = 0;
          ex$message(msgnumb = EMS_P_IdSurfEntRad, type = "%.3g",
			var = `temp_rad`, buff = loc_prompt)
          ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                         in_buff = loc_prompt)
        }
       else 
       {
          if(me->inner_loop)
             ex$message(msgnumb = EMS_P_00038,buff = accept_prompt)
          else
            ex$message(msgnumb = EMS_P_AccNxtSurfRej, buff = accept_prompt);
          ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                         in_buff = accept_prompt)
       }
        me->option_change = FALSE;

       stat_func = ems$getevent(msg = &msg, event_mask = eventmask1,
                value_type = GRIO_DISTANCE, response = (long *)response,
                response_data = response_data, event = &me->loc_event);


      switch(me->loc_event.response) {
         case EX_VALUE:
	 case EX_STRING:
	   {
            ex$message(msgnumb =EMS_S_InvalidKeyin) ;
            sleep(1);
	    break;
	   }
         case EX_DATA:
         case EX_RJT_MOVEON:
         case  EX_BACK_UP:
         {
	  sts = ex$putque(msg = &msg, response = response,
                        byte = &qsize, buffer = (char *)&me->loc_event.event);
          accept_classid = OPP_EMSsurface_class_id;
          rnd_surf_loc.option = 1;
          rnd_surf_loc.num_objects = 2;
          rnd_surf_loc.acc_prompt = accept_prompt;
          rnd_surf_loc.classids = &accept_classid;
          rnd_surf_loc.my_inst.objid = my_id;
          rnd_surf_loc.my_inst.osnum = OM_Gw_current_OS;
          rnd_surf_loc.next = NULL;
   
          surf_selhndlr_args.my_inst.objid = my_id;
          surf_selhndlr_args.my_inst.osnum = OM_Gw_current_OS;
          surf_selhndlr_args.edge_type = me->edge_type;
          my_args = (IGRchar *)&surf_selhndlr_args;
   
   	
          attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                    LC_PLANAR_NON_PLANAR;
          aflag = pwIsActivationOn();
          if (aflag)
          {
          attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD | 
                                    LC_OBJ_W_OWNER | 
                                    LC_REF_OBJECTS | LC_NO_REF_HEADER;
          /* Added REF_OBJECTS for RFA */
          }
          else
          {
          attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD | 
                                    LC_OBJ_W_OWNER | 
                                    LC_NO_REF_HEADER;
          }
          strcpy(attributes.classes, "EMSsurface");
          display_flag = DO_NOT_RELOCATE | ELEM_HILIGHT | 
                         NO_PROJ_ACCEPT_POINT | LC_ERASE_LOC_ELEMENT;
        
          rtree_classes.w_count = 1;
          elig_classes.w_count = 1;
          rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
   
          rclass = OPP_EMSsurface_class_id;
          eliclass = OPP_EMSsurface_class_id;
   
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
                 acc_prompt = accept_prompt,
                 relocate_key = EMS_P_EdgeNotFound, 
                 attributes = &attributes,
                 act_handler = EFlocate_surface_action_handler,
                 act_args = &rnd_surf_loc,
		 select = EFlocate_surface_select_handler,
                 select_args = my_args,
                 stack = &ME.ECsfedloc->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);

       if(!stat_func) {
         *ret_msg = EMS_I_Interrupt;
         goto ret_end;
        }
	if(object_located == LC_OBJ_LOCATED) {
	    if(!me->inner_loop) {
		sts = ex$putque(msg = &object_located, response = response,
			byte = &qsize, buffer = (char *)&me->event.event);
            	me->process_state = ACCEPT_NXT_SURFACE;
	    }
	    else {
            	me->process_state = OUTER_INNER_LOOP;
	    }
	}
      switch (me->event.response) {
       case EX_RJT_MOVEON:
/*
         EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,me->ModuleInfo,me->bound_code);
*/
	 if(*response != EX_RJT_MOVEON) break;
	 if(me->loc_event.response == DATA)  break; 
	 if(me->numtmped)
           me->process_state = INPUT_RADII;
	 else me->process_state = IDENTIFY_SURFACE;
           break;

       case  EX_BACK_UP:
	 if(*response != EX_BACK_UP) break;
         if(me->num_bkp_entries)
         {
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
	  EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);
         }
         else
         {
	   ex$message(msgnumb =EMS_S_NoPrevBkp) ;
           sleep(1);
	   me->process_state = IDENTIFY_SURFACE;
          }
	  break;
      case EX_DATA:
       {
        struct GRid srf_ownr;
        IGRboolean  single_surface=FALSE;
        IGRint      buf1_size = 0, numedges = 0, num_components;
	GRobjid *tmp_edge;

	if(!object_located) break;
        first_edge = me->event.located_object[0].located_obj.objid;
        objspc_num = me->event.located_object[0].located_obj.osnum;
	me->act_surf_id.objid = first_edge;
	me->act_surf_id.osnum = objspc_num;

       	mattyp = &me->event.located_object[0].module_info.md_env.matrix_type; 
        mat = me->event.located_object[0].module_info.md_env.matrix; 

        ME.COroot->ModuleInfo = me->event.located_object[0].module_info; 

        sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                            (&msg, &srfid, NULL),
                           targetid = first_edge,
                           targetos = objspc_num );
        EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

        sts = om$send(msg = message EMSsurface.EMgetactiveid(&msg,
                              &srf_ownr, NULL),
                        targetid = srfid,
                        targetos = objspc_num);
        EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

	tmp_edges = NULL;
        buf1_size = numedges = 0;
        sts = om$send(msg = message EMSloop.EMget_edges(&msg, 1,
                        EMS_OPT_ALL,
                        &tmp_edges, &buf1_size, &numedges),
                senderid = NULL_OBJID,
                targetid = first_edge,
                targetos = objspc_num);
        EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

	tmp_edge = (GRobjid *)stackalloc(sizeof(GRobjid) * numedges);
        for(i = 0; i < numedges ; i++)
           tmp_edge[i] = tmp_edges[i].objid;

        if(tmp_edges)
          {
          om$dealloc(ptr = tmp_edges);
          tmp_edges = NULL;
          }
        if(srf_ownr.objid == srfid)
         {
          single_surface = TRUE;
         }
        else 
         {
          sts = om$send (msg = message GRowner.GRget_number_components(
                         ret_msg, &num_components),
                   targetid = srf_ownr.objid,
                   targetos = srf_ownr.osnum);
          EMomerr_hndlr(sts, ret_end, "GRget_number_components");

          if (num_components == 1)
            single_surface = TRUE;
          else
            single_surface = FALSE;
          }
        
        if(single_surface) 
          {
            ex$message ( msgnumb = EMS_S_SingleSurfNotAllowed);
	    sleep(1);
            me->process_state = ACCEPT_NXT_SURFACE;
            break;
           }          

        nm_edges = 0;
       for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }
        if(!me->numtmped && !nm_edges) {
         me->active_GRid.objid = srf_ownr.objid;
         me->active_GRid.osnum = srf_ownr.osnum;
	}
        else
         if ((me->active_GRid.objid != srf_ownr.objid) ||
            (me->active_GRid.osnum != srf_ownr.osnum))
         {
            ex$message ( msgnumb = EMS_S_EdgePartDiffComposite );
	    sleep(1);
            me->process_state = ACCEPT_NXT_SURFACE;
            break;
	}

	EFchkif_edges_neutral(tmp_edge,&numedges,objspc_num,
                        mattyp,mat,me->neutral_edge_angle);

	    sts = EFparse_edges(&msg, &me->selection, me->located_obj, 
			me->tmp_located_obj, me->numed, me->numtmped,
			tmp_edge, objspc_num, &numedges,me->bound_code);
		    display_mode = GRhe;
	for(ii=0;ii<numedges;ii++) {
                sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                             tmp_edge[ii], display_mode );
                    EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
	}
	if(!me->inner_loop) {

	    if(numedges || !me->selection) {
		    if(me->selection)
                	display_mode = GRhd ;
		    else 
                	display_mode = GRhe ;
	        for(i = 0; i < numedges; i++) {
		    sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmp_edge[i],
                        targetos = objspc_num);
                       EMomerr_hndlr(sts, ret_end, "EMdisplay");
	        }
	    }

	num_entries = om$dimension_of(varray = me->num_bkp_list);
	if((me->num_bkp_entries + 1) >= num_entries) {
	   sts = om$vla_set_dimension(varray = me->num_bkp_list,
			size = me->num_bkp_entries + 1 );
	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
        }
             num_elements = om$dimension_of(varray = me->tmp_located_obj);
             if ((me->numtmped + 1 + numedges) >= num_elements)
             {
               sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                         size = num_elements + 4 + numedges);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");

	     }
	     if((me->numed + me->numtmped + numedges + 1) >= num_elements) {
               sts = om$vla_set_dimension(varray = me->edgeval_event,
                            size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");
               sts = om$vla_set_dimension(varray = me->end_edgeval_event,
                            size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");
               sts = om$vla_set_dimension(varray = me->fill_typ,
                            size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");
               sts = om$vla_set_dimension(varray = me->bound_code,
                            size = num_elements + 4 + numedges + me->numed);
               EMomerr_hndlr(sts, ret_end, "set_dimension  error");
             }

             EFget_domn_edges(tmp_edge,numedges,objspc_num);
             for(i = 0; i < numedges; i++) {
               me->tmp_located_obj[me->numtmped + i] = tmp_edge[i];
               me->end_edgeval_event[me->numed+me->numtmped + i].num_id= 0;
               me->edgeval_event[me->numed+me->numtmped + i].num_id= 0;
	       me->edgeval_event[me->numed + i + me->numtmped].event.value =
		    me->active_rad;
	       me->end_edgeval_event[me->numed+i + me->numtmped].event.value = 
		    -1.0;
	       me->fill_typ[me->numed + i + me->numtmped] = me->fillet_type;
               me->bound_code[i + me->numed+me->numtmped]= 0;
                if(me->fillet_type == VARYING_TYPE)
                   me->bound_code[i+ me->numed+me->numtmped]=
                     EMSrnd_input_ed_grp_start;
             }
             
            if(me->numtmped == 0 || !me->radius_changed) {
              me->bound_code[me->numed+me->numtmped]= EMSrnd_input_ed_grp_start;
              me->radius_changed = 1;
            }
             me->numtmped += numedges;
             me->num_bkp_entries ++;
	     me->num_bkp_list[me->num_bkp_entries-1] = numedges;
             me->process_state = ACCEPT_NXT_SURFACE;
	}
	else {
		/* Display the entire surface (outer & inner loops) */
		display_mode = GRhd;
		me->inner_loop = FALSE;
		lp_depth = MAXINT; /* Outer & inner loop edges */
                tmp_edges = NULL;
                buf_size = numedges = NULL;
                sts = om$send(msg = message EMSloop.EMget_edges(&msg, lp_depth,
EMS_OPT_ALL,
                        &tmp_edges, &buf_size, &numedges),
                    senderid = NULL_OBJID,
                    targetid = first_edge,
                    targetos = objspc_num);
                EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

                tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * numedges);

                for(i = 0; i < numedges; i++)
                    tmp_ed[i] = tmp_edges[i].objid;
                if(tmp_edges)
                  {
                  om$dealloc(ptr = tmp_edges);
                  tmp_edges = NULL;
                  }
		EFchkif_edges_neutral(tmp_ed,&numedges,objspc_num,
                        mattyp,mat,me->neutral_edge_angle);


                sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                        me->tmp_located_obj, me->numed, me->numtmped,
                        tmp_ed, objspc_num, &numedges,me->bound_code);
                for(ii=0;ii< numedges; ii++) {
                sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
			NULL),
                        targetid = tmp_ed[ii],
                        targetos = objspc_num);
                EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);
                }
                if(tmp_ed) stackfree (ptr = tmp_ed);

           	me->process_state = OUTER_INNER_LOOP;
	}
        break;
       }
	
       default:
        me->valid_inputdata = FALSE;
	goto ret_end;
       }
	break;
       }
      default:
        me->valid_inputdata = FALSE;
	goto ret_end;
      } 
    break;
    }

     case INPUT_RADII:
      {
	int i,j;
	IGRchar inp_buff[52];
	IGRshort disp_flag;

	for(i = 0; i < me->numtmped; i++) {
	    if(me->end_edgeval_event[me->numed + i].event.value < 0.0) {
              display_mode = GRhd ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                        me->tmp_located_obj[i], display_mode);
            EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
	        for(j = 0; j < 2; j++) 
		{
		    temp_rad=me->active_rad;
		    roundn(&temp_rad,3);
		    if(j == 0) 
		    { 
            		disp_flag = EMS_EDGE_BEG_PT;
			ex$message(msgnumb =EMS_P_EntStartingRad, type = "%.3g",
                        var = `temp_rad`, buff = inp_buff);
                    ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                        in_buff = inp_buff);
                    
		    }
		    else 
		    { 
            		disp_flag = EMS_EDGE_END_PT;
			ex$message(msgnumb = EMS_P_EntEndingRad, type = "%.3g",
                        var = `temp_rad`, buff = inp_buff);
                    ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                        in_buff = inp_buff);
		    }

            	    display_mode = GRhd ;
            	    sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        	&ME.COroot->ModuleInfo.md_env.matrix_type,
                        	ME.COroot->ModuleInfo.md_env.matrix,
                        	&display_mode,NULL,
                        	disp_flag, NULL),
               		targetid = me->tmp_located_obj[i],
               		targetos = objspc_num );

            	    EMerr_hndlr (!(1 & sts), msg, EMS_E_Fail,ret_end);

		    event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;

  		    sts = ems$getevent(msg = &msg, event_mask = event_mask,
		    value_type = GRIO_DISTANCE, response = (long *)response, 
			response_data = response_data, event = &me->event);
		
        	    ex$message(msgnumb = EMS_P_ClearPromptField)
        	    ex$message(msgnumb = EMS_I_ClearStatusField)

		    if(!(1 & sts)) {
	    		sts = 0;
	    		goto  ret_end;
		    }
        	    if(msg == GRw_no_value)
	    		me->event.response = EX_RJT_MOVEON;

		    switch(me->event.response) {	
	    	    /* The user changes the radius */
	    	      case EX_VALUE:
	    		if(me->event.event.value < 0) {
	    		    ex$message(msgnumb = EMS_S_InvInp)
			    sleep(1);
	     		    break;
	    		}
	    		else {
			    me->active_rad = me->event.event.value;
			    if(j == 0)  {
			        me->edgeval_event[me->numed + i] = me->event;

			    }
			    else {
			    	me->end_edgeval_event[me->numed+i] = me->event;
			    }
          		    me->fill_typ[me->numed + i] = me->fillet_type;
            		    display_mode = GRhe ;
            		    sts = om$send(msg = message EMSedge.EMdisplay(&msg, 
				NULL, &ME.COroot->ModuleInfo.md_env.matrix_type,
                        	ME.COroot->ModuleInfo.md_env.matrix,
                        	&display_mode,NULL, disp_flag, NULL),
               		    targetid = me->tmp_located_obj[i],
               		    targetos = objspc_num );
            		    EMerr_hndlr(!(1 & sts), msg, EMS_E_Fail,ret_end);
	    	    	}
			break;

	    		/* The user takes the default radius */
	    	      case EX_RJT_MOVEON:
			if(j == 0) 
          		    me->edgeval_event[me->numed + i].event.value =
				me->active_rad;
		        else 
          		    me->end_edgeval_event[me->numed + i].event.value =
				me->active_rad;
            		display_mode = GRhe ;
            		sts = om$send(msg = message EMSedge.EMdisplay(&msg, 
				NULL, &ME.COroot->ModuleInfo.md_env.matrix_type,
                        	ME.COroot->ModuleInfo.md_env.matrix,
                        	&display_mode,NULL, disp_flag, NULL),
               		    targetid = me->tmp_located_obj[i],
               		    targetos = objspc_num );

            		EMerr_hndlr(!(1 & sts), msg, EMS_E_Fail,ret_end);

          		me->fill_typ[me->numed] = me->fillet_type;
			break;

	    	      case EX_BACK_UP:
			j--;
	        	break;

	    	      default:
			if(*response == CLEAR_STACK || *response == TERMINATE) goto ret_end;
			if(*response == EX_CMD_KEY) {
			   me->valid_inputdata = FALSE;
         		    me->process_state = INPUT_RADII;
			    j--;
			   goto ret_end;
        		}
	 		if(*response == STATUS_DISP) { 
         			me->process_state = INPUT_RADII;
				j--;
				break;
	 		}
		    } /* switch */
      		}
      	    }
            display_mode = GRhe ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                        me->tmp_located_obj[i], display_mode);
            EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
            display_mode = GRhd ;
            sts = om$send(msg = message EMSedge.EMdisplay(&msg,
                                NULL, &ME.COroot->ModuleInfo.md_env.matrix_type,
                                ME.COroot->ModuleInfo.md_env.matrix,
                                &display_mode,NULL, EMS_WHL_EDGE, NULL),
                            targetid = me->tmp_located_obj[i],
                            targetos = objspc_num );

            EMerr_hndlr(!(1 & sts), msg, EMS_E_Fail,ret_end);
            if(i == (me->numtmped - 1)) {
	   	me->process_state = IDENTIFY_SURFACE;
	   	break;
	    }
    	}
	me->process_state = IDENTIFY_SURFACE;
      }
     break;               

  default:
     goto ret_end;
    } /* me->process_state */
  }

 while( TRUE);

 ret_end:


  if(tmp_edges)
    {
    om$dealloc(ptr = tmp_edges);
    tmp_edges = NULL;
    }
  if(!loop_locatable)
   EFset_locate_eligibility(&msg,0,"EMSloop");
  if(!edge_locatable)
   EFset_locate_eligibility(&msg,0,"EMSedge");

  return(sts);

}



IGRlong EFlocate_surface_action_handler(rnd_sur_loc, new_entry, locate_args, 
	action)
struct	rnd_surf_loc_acthndlr *rnd_sur_loc;
struct	GRlc_info *new_entry;
struct	LC_action_args *locate_args;
enum	GRlocate_action *action;
{
 	IGRlong sts = OM_S_SUCCESS;

 	sts = om$send(msg = message ECsfedloc.rnd_surf_action_handler(
			rnd_sur_loc, new_entry, locate_args, action),
		senderid = NULL_OBJID,
		targetid = rnd_sur_loc->my_inst.objid,
		targetos = rnd_sur_loc->my_inst.osnum);

	if(!(1 & sts)) 
		goto ret_end;

ret_end:
 	return(sts);
}


method rnd_surf_action_handler(struct rnd_surf_loc_acthndlr *rnd_surf_loc;
	struct	GRlc_info *new_entry; struct LC_action_args *locate_args;
	enum	GRlocate_action *action)
{
 IGRboolean	call_action_handler;
 IGRlong msg_loc, sts, loc_msg; 
 IGRint point_size;
 extern IGRlong LCptlocact();
 struct	GRid *tmp_edges=NULL,active_id,*search_id;
 OMuint count = 0;
 OM_S_CHANSELECT  to_inner, to_loopset;
 IGRint numre_lps, depth = MAXINT, buf_size = 0;
 GRobjid *tmp_ed,*result_lps = NULL;
 IGRint i,numedges;
 IGRint zero = 0;
 IGRshort *mattyp;
 IGRdouble *mat;

   /* Initialize */
   me->inner_loop = FALSE;
   call_action_handler = FALSE;
   point_size = sizeof(IGRpoint);
   msg_loc = EMS_S_Success; 
   loc_msg = EMS_S_Success; 
   sts = OM_S_SUCCESS;
   EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
   EMmake_chanselect(EMSloop_to_inner, &to_inner);
   mattyp = &new_entry->module_info.md_env.matrix_type;
   mat = new_entry->module_info.md_env.matrix;


   {
     search_id = &new_entry->located_obj;
     sts = om$get_channel_count(osnum = search_id->osnum,
					objid = search_id->objid,
					p_chanselect = &to_loopset,
					count = &count);

     sts = om$send(msg = message EMSloopset.EMget_loops(&msg_loc, 
			0, &depth, &result_lps, NULL, &buf_size,
			&numre_lps),
		senderid = search_id->objid,
		p_chanselect = &to_loopset,
		targetos = search_id->osnum);
     EMerr_hndlr(EMSerror(sts &msg_loc), msg_loc, EMS_E_LoopsetError, ret_end);

     for(i = 0; i < numre_lps; i++) {
	count = 0;
	sts = om$get_channel_count(
			objid = result_lps[i],
			osnum = search_id->osnum,
			p_chanselect = &to_inner,
			count = &count);

	if(count) {
		ex$message(msgnumb = EMS_P_00038, 
			buff = rnd_surf_loc->acc_prompt);
		me->inner_loop = TRUE;
		break;
	}
     }
     if(!me->inner_loop)
	ex$message(msgnumb = EMS_P_AccNxtSurfRej, 
		buff = rnd_surf_loc->acc_prompt);
 

     switch (*action) {
       case add_all:
       case add_inside:
       case add_outside:
       case add_overlap:
       case add_nopost:
         {
           IGRlong	i;

	   call_action_handler = TRUE;

     	/* Get its active owner solid id */
           sts = om$send(msg = message EMSsurface.EMgetactiveid(&msg_loc,
                                &active_id, NULL),
                        senderid = NULL_OBJID,
                        targetid = search_id->objid,
                        targetos = search_id->osnum);

           if(!(1 & sts &msg_loc)) {
              call_action_handler = FALSE;
              sts = OM_S_SUCCESS;
           }
           else { /* Check if the active id is a solid */
             call_action_handler = TRUE;

             /* This could happen if no edges have been selected so
                        far (i.e active_GRid.objid is NULL_OBJID */

             if(me->active_GRid.objid != NULL_OBJID) {
	       if(!IF_EQ_OBJID(me->active_GRid.objid, active_id.objid)) {
		 ex$message ( msgnumb = EMS_S_EdgePartDiffComposite );
            	 sleep(1);
                 call_action_handler = FALSE;
	       }
	     }
	     if(call_action_handler) {
	       tmp_edges = NULL;
               buf_size = numedges = NULL;
	       sts = om$send(msg = message EMSsurface.EMgetedges(&msg_loc,
                        EMS_OPT_ALL, &tmp_edges, &zero, &numedges, NULL,
                        NULL, NULL, NULL),
                senderid = NULL_OBJID,
                targetid = search_id->objid,
                targetos = search_id->osnum);
               if(!(1 & sts &msg_loc)) {
                 call_action_handler = FALSE;
                 sts = OM_S_SUCCESS;
	       }
	       else {

                tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * numedges);

                for(i = 0; i < numedges; i++)
                    tmp_ed[i] = tmp_edges[i].objid;

		EFchkif_edges_neutral(tmp_ed,&numedges,search_id->osnum,
                        mattyp,mat,me->neutral_edge_angle);

                sts = EFparse_edges(&msg_loc, &me->selection, me->located_obj,
                        me->tmp_located_obj, me->numed, me->numtmped,
                        tmp_ed, search_id->osnum, &numedges,me->bound_code);
		if(!numedges) {
		  call_action_handler = FALSE;
/*
		  if(me->selection)
		    ex$message ( msgnumb = EMS_S_NoEdgesRemaining)
		  else 
		     ex$message ( msgnumb = EMS_S_NoEdgesToDeselect)
                  sleep(1);
*/
	        }
	       }
	     }
           }
           if(call_action_handler && rnd_surf_loc->next) {
             sts= EFlocate_surface_action_handler(rnd_surf_loc->next, new_entry,
        				locate_args, action);
       	   return(sts);
           }
         }
   	 break;

       default:
      		break;
    } /* switch (*action) */

	/* Call the action handler */

  }
  if(call_action_handler)
    sts = LCptlocact(NULL, new_entry, locate_args, action);
  else sts = OM_S_SUCCESS;

  ret_end:
    if(result_lps)
      {
      om$dealloc(ptr = result_lps);
      result_lps = NULL;
      }
    if(tmp_edges)
      {
      om$dealloc(ptr = tmp_edges);
      tmp_edges = NULL;
      }
 	return(sts);
}





IGRlong EFlocate_surface_select_handler(msg, select_args,my_args)
IGRlong *msg;
struct LC_select_args *select_args;
IGRchar *my_args;
{
	IGRlong sts;
	struct rnd_surfloop_selhndlr   *com_objid;
	com_objid = (struct rnd_surfloop_selhndlr *)my_args;
	sts = EFsurf_LCselect(msg, com_objid,&select_args->eventmask, 
		&select_args->display_flag, 
		select_args->is_bore, 
		select_args->response, 
		select_args->response_data, 
		select_args->accept_event, 
		select_args->acc_event1, 
		select_args->obj_hilighted, 
		select_args->stack, 
		select_args->acc_prompt, 
		select_args->mode, 
		select_args->hilight_mode, 
		select_args->acc_key, 
		select_args->nbytes, 
		select_args->value_type, 
		select_args->scale_flag);

	return(sts);
}

/*  
	Most of the code in this function is from LCselect.I (default selection
    	handler). The reason this exists is to overcome the problem of not 
	displaying the entire surface but only the outer loops of the surface.
    	This function doesn't display the selected object but the display is
    	selectively done by the calling function 
	(EFlocate_surface_select_handler (src_testco/imp/EMrndsurfloc.I))

	10th march 93 - Tapadia
*/

#define SUCCESS         1
#define NO_ELEMENTS     2
#define LOOP            3
#define RETCONTROL      4


IGRint EFsurf_LCselect (msg, c_objid,mask,display_flag, is_bore, response, 
                 response_data, accept_event, acc_event1, obj_hilited, stack,
                 acc_prompt, unhilite_mode, hilite_mode, acc_key,
                 nbytes, value_type, scale_flag)

IGRlong                 *msg;
struct rnd_surfloop_selhndlr *c_objid;
IGRlong                 *mask;
IGRlong                 *display_flag;
IGRboolean              *is_bore;
struct  GRevent         *accept_event;
struct  GRevent         *acc_event1;
IGRint                  *response;
IGRchar                 *response_data;
IGRchar                 *obj_hilited;
struct GRlc_stack       *stack;
IGRchar			*acc_prompt;                                  
enum   GRdpmode         unhilite_mode, hilite_mode;
IGRlong                 acc_key;
IGRint                  *nbytes;
IGRchar                 *value_type;
IGRint                  scale_flag;
{
    IGRchar info[75];
    IGRshort ext_o_element, window;
    IGRint element, flag;
    IGRlong sts, ret_code, exit_code, new_mask;
    extern IGRlong EFdisplay_surfloop_edges();
    struct GRparms *parms;
    struct GRid display_id; 
    GRobjid loop_id;
    struct GRlc_info *entry;
    struct GRmdenv_info *entry_md;
    enum GRdpmode display_mode[2];

    *msg = LC_OBJ_LOCATED;
    ret_code = 0;
    exit_code = LOOP;

    /* Check whether to highlight in a single window or all windows */

    if (*display_flag & ONE_WINDOW)
    {
        display_id = stack->window;
        window = TRUE;
    }
    else
    {
        display_id = stack->module;
        window = FALSE;
    }

    /*
     *	While there are elements to process stay in the loop.  The stack
     *	is of default size of one, but it may be expanded to any number
     *	by an application.
     */

    while ((exit_code == LOOP) && (stack->num_entries))
    {
        /*
         *  use a pointer into the stack for fewer assembler instructions
         */

        entry = &stack->entry[stack->num_entries - 1];
        entry_md = &entry->module_info.md_env;

        /*
         *  Display the element type and layer, and the accept prompt
         */

        LCget_info (entry->located_obj.objid, entry->located_obj.osnum, info);

        ex$message (msgnumb = LC_NO_MSG, in_buff = info, field = ERROR_FIELD);

        /*
         *  Determine highlight mode
         */

	if (*display_flag & LC_HALF_HIGHLIGHT) 
        {
	    display_mode[0] = display_mode[1] = GRhhd;
        }
        else 
        {
	    display_mode[0] = display_mode[1] = hilite_mode;
        }

        /*
         *  Determine additional display info
         */

        if (*display_flag & ELEM_HILIGHT)
        {
            element = 1;
            parms = NULL;
            ext_o_element = 1;
        }
        else /* segment highlight */
        {
            element = 0;
            parms = &entry->geom_parms;
            ext_o_element = 0;
        }

        /*
         *  Highlight the object
         */

	/* added by vidya to display required edges */

	if(c_objid->edge_type == SURFACE_LOOP_TYPE)
	sts = EFdisplay_surfloop_edges(stack,display_mode[0],c_objid,&loop_id);
	else 
		sts =
                 om$send (msg= message ECsfedloc.EMdisplay_surfloop_elig_edges(
				c_objid->edge_type,
                                &entry_md->matrix_type,entry_md->matrix,
                                hilite_mode,entry->located_obj.objid,
				entry->located_obj.osnum),
                                senderid = NULL_OBJID,
                                targetid = c_objid->my_inst.objid,
                                targetos = c_objid->my_inst.osnum);

        *obj_hilited = TRUE;

        /*
         *  Add reset and backup to the valid responses in the mask to
         *  co$getevent.  These two responses will not accept the element
         *  because they are directly interpreted by this function.
         */

        new_mask = *mask | GRm_RESET | GRm_BACK_UP;

        /*
         *  Modify the cursor if the command requests it.  This is usually
         *  for commands that do a chain locate.
         */

        if (*display_flag & LC_ACCEPT_CURSOR) 
        {
            LCdef_cursor ();
        }

        LCmark_locate (LC_Other_Point);

        /*
         *  Wait for the user's response
         */

        co$getevent (msg = &sts,
                     event_mask = new_mask,
                     prompt = acc_prompt,
                     msgnum = acc_key,
                     response = response,
                     response_data = response_data,
                     nbytes = nbytes,
                     value_type = value_type,
                     scale_flag = scale_flag,
                     event = accept_event);

        /*
         *  Restore the cursor if necessary.
         */

        if (*display_flag & LC_ACCEPT_CURSOR) 
        {
            LCrestore_cursor();    
        }

        /*
         *  Check the user's response
         */

        switch (accept_event->response) 
        {
            case EX_BACK_UP:

                /*
                 *  Leave the accept/reject cycle, set up the return codes
                 *  to exit the Rtree search, and return to the main filter.
                 *  The filter may then reenter the locate cycle or return
		 *  to the caller, depending on the original locate request.
                 */

                stack->num_entries = 0;
                *msg = LC_BACKUP;
                exit_code = RETCONTROL;
                ret_code = 1;
                break;

            case EX_RJT_MOVEON:

                /*
                 *  The current element is rejected; continue to process
                 *  the remaining elements in the stack.  If there are no
                 *  elements left in the stack, return control to the
                 *  main locate filter to either continue the search through
                 *  the Rtree or return control to the caller of the filter.
                 */

                if (!--stack->num_entries) 
                {
                    exit_code = NO_ELEMENTS;
                    *msg = LC_RELOCATE;
                    ret_code = 1;
                }
                break;

            case GR_UNKNOWN_TYPE:

                /*
                 *  Unknown input type; return control to the caller
                 */

                *msg = LC_UNKNOWN_TYPE;
                exit_code = RETCONTROL;
                ret_code = 1;
                break;

            default:

                /*
                 *  Accept the object with any recognized input type
                 */

                if (accept_event->response == DATA) 
                {
                    /*
                     *  Check to see if projection of accept point is
                     *  requested.  If the third bit is not set in the
                     *  display flag project the accept point onto the
                     *  element using a point or boreline project
                     *  depending on the type of locate that is occuring
                     */

                    if (!(*display_flag & NO_PROJ_ACCEPT_POINT)) 
                    {
                        if (*display_flag & ELEM_HILIGHT)
                        {
                            flag = (*is_bore) ? LC_LNPROJECT : LC_PTPROJECT;
                        }
                        else /* segment highlight */
                        {
                            flag = LC_APPARENT;
                        }

                        if (!LCget_parms (accept_event->event.button.x,
                                          accept_event->event.button.y,
                                          accept_event->event.button.z, flag,
                                          entry->located_obj.objid,
                                          entry->located_obj.osnum,
                                          accept_event->event.button.objid,
                                          accept_event->event.button.osnum,
                                          entry->proj_pnt, &entry->geom_parms,
                                          entry_md->matrix_type, 
                                          entry_md->matrix))
                        {
                            *msg = LC_NO_OBJ_LOCATED;
                            ret_code = 0;
                            goto WRAP;
                        }
                    }
                }

                if (*display_flag & ELEM_HILIGHT)
                {
                    if (unhilite_mode != GRhd)
                    {
                        /*
                         *  Return the object in the requested display mode
                         */

                        om$send (msg = message GRgraphics.GRdisplay
                                      (&sts, &entry_md->matrix_type,
                                       entry_md->matrix,
                                       &unhilite_mode, &display_id),
                                 senderid = NULL_OBJID,
                                 targetid = entry->located_obj.objid,
                                 targetos = entry->located_obj.osnum);
                    }
                }
                else /* segment highlight */
                {
                    /*
                     *  Erase the element extensions, and, if specified,
                     *  leave the element in the requested unhighlight mode
                     */

                    if (unhilite_mode != GRhd) 
                    {
                        display_mode[0] = unhilite_mode;
                        display_mode[1] = GRhe;
                        ext_o_element = 0;
                    }
                    else
                    {
                        display_mode[0] = GRhe;
                        ext_o_element = 1;
                    }

                    /*
                     *  Dehighlight the object
		    */

		     if(c_objid->edge_type == SURFACE_LOOP_TYPE)
		     sts =EFdisplay_surfloop_edges(stack,display_mode[0],c_objid,&loop_id);
		     else
			sts =
                 om$send (msg= message ECsfedloc.EMdisplay_surfloop_elig_edges(
				c_objid->edge_type,
                                &entry_md->matrix_type,entry_md->matrix,
                                display_mode[0],entry->located_obj.objid,
                                entry->located_obj.osnum),
                                senderid = NULL_OBJID,
                                targetid = c_objid->my_inst.objid,
                                targetos = c_objid->my_inst.osnum);

                }

                /*
                 *  Set up the return codes to indicate that the object
                 *  was accepted.  Note that acc_event1 is being filled in
                 *  rather than acc_event.
                 */

                exit_code = SUCCESS;
                ret_code = 1;
                *msg = LC_OBJ_LOCATED;
                acc_event1->located_object[0] = *entry;
		if(c_objid->edge_type == SURFACE_LOOP_TYPE)
                acc_event1->located_object[0].located_obj.objid = loop_id;
                acc_event1->num_id = 1;
                stack->num_entries = 0;
                break;
        } /* end switch */

        /*
         *  Erase the highlighted object, if necessary
         */

	
        if (*obj_hilited && exit_code != SUCCESS)
        {
            if (*display_flag & LC_ERASE_LOC_ELEMENT)
            {
                if (*display_flag & ELEM_HILIGHT)
                {
                 hilite_mode = GRhe;

		if(c_objid->edge_type == SURFACE_LOOP_TYPE)
		sts = 
		 om$send (msg= message ECsfedloc.EMdisplay_surfloop_elig_edges(
				c_objid->edge_type,
				&entry_md->matrix_type,entry_md->matrix,
				hilite_mode,loop_id,entry->located_obj.osnum),
				senderid = NULL_OBJID,
				targetid = c_objid->my_inst.objid,
                		targetos = c_objid->my_inst.osnum);
		else
		sts =
                 om$send (msg= message ECsfedloc.EMdisplay_surfloop_elig_edges(
				c_objid->edge_type,
                                &entry_md->matrix_type,entry_md->matrix,
                                hilite_mode,entry->located_obj.objid,
                                entry->located_obj.osnum),
                                senderid = NULL_OBJID,
                                targetid = c_objid->my_inst.objid,
                                targetos = c_objid->my_inst.osnum);

			
                }
                else /* segment highlight */
                {
                    display_mode[0] = GRhe;
                    display_mode[1] = GRhe;
                    ext_o_element = 0;

                    /*
                     *  Dehighlight the object
                     */
		  if(c_objid->edge_type == SURFACE_LOOP_TYPE)
		  sts = EFdisplay_surfloop_edges(stack,display_mode[0],c_objid,&loop_id);
		  else 
			sts =
                 om$send (msg= message ECsfedloc.EMdisplay_surfloop_elig_edges(
				c_objid->edge_type,
                                &entry_md->matrix_type,entry_md->matrix,
                                display_mode[0],entry->located_obj.objid,
                                entry->located_obj.osnum),
                                senderid = NULL_OBJID,
                                targetid = c_objid->my_inst.objid,
                                targetos = c_objid->my_inst.osnum);
                }
            }
            else 
            {
                dp$erase_hilite (msg = &sts,
                                 objid = stack->module.objid,
                                 osnum = stack->module.osnum); 
            }

            *obj_hilited = FALSE;
        }
    }  /* end while */

    if (exit_code == RETCONTROL)
    {
        ex$message (msgnumb = EX_S_Clear);
    }

WRAP:

    return (ret_code);
}

IGRlong EFdisplay_surfloop_edges(stack_entry,display_mode,c_objid,loop_id)
struct GRlc_stack *stack_entry;
enum GRdpmode display_mode;
struct rnd_surfloop_selhndlr *c_objid;
GRobjid *loop_id;
{
 IGRboolean     found=FALSE;
 IGRlong msg_loc, sts;
 extern IGRboolean EMhitcvbuff();
 struct GRid *search_id;
 OMuint count = 0;
 OM_S_CHANSELECT  to_loopset;
 IGRint numre_lps, depth = MAXINT, buf_size = 0, buf1_size = 0;
 GRobjid *result_lps = NULL;
 IGRint i;
  IGRshort *mattyp;
  IGRuchar cvtype;
  IGRdouble *mat;
  struct GRid *tmp_edges=NULL;
  IGRint j,loop_ind=0,numedges;
  struct GRmdenv_info md_env;
  struct IGRbsp_curve edge_geometry;
  struct GRlc_cvl  cvl;
  struct EMSlcinput lcin;
  struct EMSlcoutput lcout;
  struct GRevent tmp_eve;
  IGRpoint point1,point2;
  struct IGRline  boreline;
  IGRdouble dit_tol, scale;
  IGRlong bytes_in, bytes_out;
  struct var_list list[3];
  IGRushort props;

/* Initialize */

 msg_loc = EMS_S_Success;
 sts = OM_S_SUCCESS;
  EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);

     search_id = &stack_entry->entry[0].located_obj;

{
        mattyp = &stack_entry->entry[0].module_info.md_env.matrix_type;
        mat = stack_entry->entry[0].module_info.md_env.matrix;

            sts = om$get_channel_count(osnum = search_id->osnum,
                                        objid = search_id->objid,
                                        p_chanselect = &to_loopset,
                                        count = &count);

        sts = om$send(msg = message EMSloopset.EMget_loops(&msg_loc,
                        0, &depth, &result_lps, NULL, &buf_size,
                        &numre_lps),
                senderid = search_id->objid,
                p_chanselect = &to_loopset,
                targetos = search_id->osnum);
        EMerr_hndlr(EMSerror(sts &msg_loc), msg_loc, EMS_E_LoopsetError, ret_end
);

}

        OM_BLOCK_MOVE(&stack_entry->entry[0].module_info.md_env.matrix,
                &md_env.matrix, sizeof(IGRmatrix));

        md_env.matrix_type =
                stack_entry->entry[0].module_info.md_env.matrix_type;

        for(i = 0; i< numre_lps; i++ ) {
	    tmp_edges = NULL;
          buf1_size = numedges = 0;
          sts = om$send(msg = message EMSloop.EMget_edges(&msg_loc, 1,
                        EMS_OPT_ALL,
                        &tmp_edges, &buf1_size, &numedges),
                senderid = NULL_OBJID,
                targetid = result_lps[i],
                targetos = search_id->osnum);
          EMerr_hndlr(!(1&msg_loc&sts),msg_loc,EMS_E_SurfaceError,ret_end);

          lcin.options = EMSlcopt_hitormiss | EMSlcopt_rangechk;
          lcin.eligfunc = NULL;
          lcin.eligfunc_args = NULL;
          lcin.more_info = NULL;
          lcout.props = NULL;

          tmp_eve.event.button.objid = stack_entry->window.objid;
          tmp_eve.event.button.osnum = stack_entry->window.osnum;
          tmp_eve.event.button.x = stack_entry->entry[0].proj_pnt[0];
          tmp_eve.event.button.y = stack_entry->entry[0].proj_pnt[1];
          tmp_eve.event.button.z = stack_entry->entry[0].proj_pnt[2];
          tmp_eve.response= EX_DATA;
          tmp_eve.located_object[0] = stack_entry->entry[0];

	  boreline.point1 = point1;
          boreline.point2 = point2;
          EFboreline(&msg_loc, search_id->objid,
                        &tmp_eve, &boreline);
          bytes_in = sizeof(IGRdouble);

          gr$get_dit_tolerance(msg = &msg_loc, sizbuf = &bytes_in,
                        buffer = &dit_tol, nret = &bytes_out);

          list[0].var = VVOL_VIEWPORT_SCALE;
          list[0].var_ptr = (IGRchar *) &scale;
          list[0].num_bytes = sizeof(IGRdouble);
          list[0].bytes_returned = &bytes_out;
          list[1].var = END_PARAM;
          list[1].var_ptr = NULL;
          list[1].num_bytes = 0;
          list[1].bytes_returned = NULL;

          dp$inq_set_gragad(msg = &msg_loc,
                     osnum = tmp_eve.event.button.osnum,
                     gragad_objid = tmp_eve.event.button.objid,
                     which_error = &msg_loc, var_list = list);

	  dit_tol /= scale;

          cvl.attributes.acc_tolerance = dit_tol;
          cvl.attributes.acc_line = boreline;
          cvl.attributes.type = GR_bl_loc;

          OM_BLOCK_MOVE(&stack_entry->entry[0].module_info, &cvl.module,
                  sizeof(struct GRmd_env));

            for(j = 0; j < numedges ; j++) {
                edge_geometry.poles = NULL;
                edge_geometry.weights = NULL;
                edge_geometry.knots = NULL;
                edge_geometry.num_boundaries = 0;
                edge_geometry.bdrys = NULL;

                sts = om$send(msg = message EMSedge.EMget_bcxyz_geom
                                                 (&msg_loc, &md_env, search_id,
                                                   NULL, 0, MAXINT, FALSE,
                                                      NULL, &edge_geometry),
                        senderid = NULL_OBJID,
                        targetid = tmp_edges[j].objid,
                        targetos = tmp_edges[j].osnum);


                sts = om$send (msg = message EMSedge.EMget_props_type(&msg_loc,
                                &props,&cvtype),
                        senderid = NULL_OBJID,
                        targetid = tmp_edges[j].objid,
                        targetos = tmp_edges[j].osnum);

                found = EMhitcvbuff (&msg_loc, &edge_geometry, cvtype,&cvl,
                                &lcin, &lcout);
        	EMerr_hndlr(EMSerror(sts &msg_loc), msg_loc,EMS_E_Fail,ret_end);

                if(edge_geometry.poles ) 
                  {
                  om$dealloc(ptr = edge_geometry.poles );
                  edge_geometry.poles= NULL;
                  }
                if(edge_geometry.weights)
                  {
                  om$dealloc(ptr = edge_geometry.weights );
                  edge_geometry.weights = NULL;
                  }
                if(edge_geometry.knots) 
                  {
                  om$dealloc(ptr = edge_geometry.knots );
                  edge_geometry.knots = NULL;
                  }
                if(found) {
                        loop_ind = i;
                        break;
                }
            }
            if(tmp_edges)
              {
              om$dealloc(ptr = tmp_edges);
              tmp_edges = NULL;
              }
                if(found) break;


        }
	if(!found) goto ret_end;


        if (lcin.options & EMSlcopt_hitormiss)
        {
        /*
        * This edge has been hit by the user defined input. Set the
        * the return status to stop further searching.
        */
        sts = OM_I_STOP_SENDING;
        }

	*loop_id = result_lps[loop_ind];
	sts = om$send(msg = message ECsfedloc.EMdisplay_surfloop_elig_edges(
				c_objid->edge_type,
			mattyp,mat,display_mode,
			result_lps[loop_ind],search_id->osnum),
		senderid = NULL_OBJID,
		targetid = c_objid->my_inst.objid,
		targetos = c_objid->my_inst.osnum);

        EMerr_hndlr(!(1&msg_loc&sts),msg_loc,EMS_E_SurfaceError,ret_end);


 ret_end:
    if(result_lps)
      {
      om$dealloc(ptr = result_lps);
      result_lps = NULL;
      }
    if(tmp_edges)
      {
      om$dealloc(ptr = tmp_edges);
      tmp_edges = NULL;
      }
	return(sts);
}


method EMdisplay_surfloop_elig_edges(IGRint edge_type;IGRshort *mattyp; 
	IGRdouble *mat;
        enum GRdpmode d_mode;
        GRobjid lp_id;GRspacenum lp_osnum)
{

	extern IGRlong EFparse_edges();
	struct GRid *tmp_edges=NULL;
	IGRint ii,buf1_size ,numedges=0,zero = 0;
	OMuint count = 0;
	IGRlong sts,msg_loc;
	GRobjid *tmp_ed;
  	OM_S_CHANSELECT  to_inner;

	if(edge_type == SURFACE_LOOP_TYPE) {
	me->inner_loop = FALSE;
  	EMmake_chanselect(EMSloop_to_inner, &to_inner);

	count = 0;
	sts = om$get_channel_count(
			objid = lp_id,
			osnum = lp_osnum,
			p_chanselect = &to_inner,
			count = &count);

	if(count) 
		me->inner_loop = TRUE;
        buf1_size = 0;
        sts = om$send(msg = message EMSloop.EMget_edges(&msg_loc, 1,
                        EMS_OPT_ALL,
                        &tmp_edges, &buf1_size, &numedges),
                senderid = NULL_OBJID,
                targetid = lp_id,
                targetos = lp_osnum);
        EMerr_hndlr(!(1&msg_loc&sts),msg_loc,EMS_E_SurfaceError,ret_end);

        tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * numedges);
        for(ii = 0; ii < numedges; ii++) 
           tmp_ed[ii] = tmp_edges[ii].objid;

	EFchkif_edges_neutral(tmp_ed,&numedges,lp_osnum,
                        mattyp,mat,me->neutral_edge_angle);

	sts = EFparse_edges(&msg_loc, &me->selection, me->located_obj,
                        me->tmp_located_obj, me->numed, me->numtmped,
                        tmp_ed, lp_osnum, &numedges,me->bound_code);
	} /* surface loop edge typ */

	else {   /* concave or convex edge type */

	  sts = om$send(msg = message EMSsurface.EMgetedges(&msg_loc,
                        EMS_OPT_ALL, &tmp_edges, &zero, &numedges, NULL,
                        NULL, NULL, NULL),
                senderid = NULL_OBJID,
                targetid = lp_id,
                targetos = lp_osnum);

        tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * numedges);
        for(ii = 0; ii < numedges; ii++) 
           tmp_ed[ii] = tmp_edges[ii].objid;

	} /* end of concave or convex */

	for(ii = 0; ii< numedges ; ii++) {
 
		sts = EFhilite_edge_with_weight( &msg_loc, me->ModuleInfo,
                      tmp_ed[ii], d_mode );

           EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
	}
ret_end:
  /* fix for mlk */
    if(tmp_edges)
      {
      om$dealloc(ptr = tmp_edges);
      tmp_edges = NULL;
      }
	return(sts);
}

void EFchkif_edges_neutral(edge_list,numedges,objspc_num,mattyp,mat,user_ang)
GRobjid *edge_list;
IGRint  *numedges;
OMuword objspc_num;
IGRshort *mattyp;
IGRdouble *mat;
IGRdouble user_ang;
{
   GRobjid *tmp_ed;
   IGRint n_edges,ii;
   IGRdouble angmeas;
   IGRlong msg,sts;
   IGRboolean is_convex,is_neutral;
	tmp_ed = (GRobjid *)stackalloc(sizeof(GRobjid) * (*numedges));
        n_edges = 0;
        for (ii= 0; ii < *numedges ; ii++) { 
	    sts = om$send(msg = message EMSedge.EMchkconvex(&msg, NULL,
			mattyp, mat, EMS_ZEROANGLE_DEG_MAX, &is_convex,
			&is_neutral, &angmeas),
		senderid = NULL_OBJID,
		targetid = edge_list[ii],
		targetos = objspc_num);

            EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

	    /* Check if it's within the user defined neutral edge angle */
	    if(!is_neutral) {
	        EFcheck_if_neutral(angmeas, user_ang,
			&is_neutral);
	    }
	    if(is_neutral) 
		    continue;
	    tmp_ed[n_edges] = edge_list[ii];
	    n_edges++;
	} 
        *numedges = n_edges;
	for(ii = 0; ii< *numedges; ii++)
	  edge_list[ii] = tmp_ed[ii];

ret_end:

     if(tmp_ed) stackfree (ptr = tmp_ed);
     *numedges = n_edges;
}
end implementation ECsfedloc; 
