class implementation ECsfedloc;
#if 0
/*
DESCRIPTION
	This method locates edges using the chain edge option.

OPTIONS
	No options supported

ALGORITHM

HISTORY
 	Tapadia  01/13/93 
	Reorders chain for both type of radii
	Srividya 03/18/93 Supports both constant & varying radii
			  & selection & deselection
	Included EFchkif_edge_valid fn to check 
		i)ancestry validity
		ii)same surface 
		iii)Diff composite
	Janaka : 05-29-93 : Modified call to EMget_edge_length() to
                            accommodate function argument change.

	Jaikish  01/06/98 added roundn as fix for TR#119701572
*/
#endif

%safe
#include <math.h>
%endsafe
#include <string.h>
#include <stdlib.h>
#include "lcmacros.h"
#include "EMSlc.h"
#include "griomacros.h" /* co$getevent */
#include "emserr.h"
#include "EMSaction.h" /* Structure definition for action handler */
#include "EMSasdef.h" /* For ASSOC */
#include "EMSprop.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "EMS.h"
#include "EMSprop.h"
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
#include "ma.h"
#include "maang2vc.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"
#include "bsdistptli.h"
#include "bscvarrevt.h"
#include "igr.h"
#include "gr.h"
#include "prototypes/bsdistptpt.h"


#define M_PI 3.14159265358979323846
#define FALSE 0
#define TRUE 1
#define ABS(X) ((X) >= 0 ? (X) : -(X))
#define ARR_SIZE   50

#define IDENTIFY_CHAIN_EDGE	0 
#define CHAIN_EDGES 		1 
#define ACC_EDGES		2
#define INPUT_CHAIN_RADII 	3 
#define CHOOSE_EDGE  		4

#define CHAIN_TYPE		1
#define EDGE_VERTEX_TYPE	2
#define SURFACE_LOOP_TYPE	3
#define FILLET_TYPE		4
#define RADII_TYPE		5
#define CONSTANT_TYPE		6
#define VARYING_TYPE		7

#define DEBUG        1
#define NUMED        10

#define PROMPT_SIZE 65

from EMSedge import EMget_props, EMchkconvex;
from EMSedge import EMgetvtxedges;
from EMSedge import EMget_edge_length;
from EMSedge import EMdisplay;
from EMSedge import EMxyz_endpt;
from EMSedge import EMget_bcxyz_geom;
from EMSboundary import EMgetsurface_info;
from EMSsurface  import EMgetactiveid;
from GRowner     import GRget_number_components;
from EMSsubbs    import EMget_ele_header;

extern GRclassid OPP_EMSedge_class_id, 
                 OPP_EMSgraloop_class_id;
extern GRclassid OPP_EMSsurface_class_id, OPP_EMSsubbs_class_id;

extern void EFsortedges_by_angle();
extern void EFgetang_meas();
extern void EFcheck_strlen();
extern IGRlong EFchain_edge_rad_comp();
extern IGRlong EFchkif_edge_valid();
extern IGRlong EFput_edge_on_same_surface();
extern IGRlong EFhilite_edge_with_weight();
extern IGRboolean EFedge_curves_locatable();
extern void EFparse_keyin();
extern void roundn();
extern IGRlong EFparse_edges();
extern IGRlong EFcreate_space_chain_edges();

extern  void EFcheck_if_neutral();


static IGRboolean aflag;

method locate_chain_edge(IGRlong       *ret_msg;
                     IGRint        *response;
                     IGRchar       *response_data;
                     IGRchar       *status_string;                     
                     char          (*funcptr) () )
{
  IGRint                      nm_edges,resp,temp,ii,i,jj,kk ;
  IGRboolean                  stat_func=TRUE;
  GRobjid                     first_edge;
  OMuword                     rclass, eliclass, objspc_num ;
  OM_S_CLASSLIST              rtree_classes, elig_classes;
  struct  GRlc_locate         attributes;
  IGRlong                     sts, msg, size, display_flag,
                              eventmask1, eventmask2;
  IGRboolean                  right_vertex=TRUE;
  OM_S_CHANSELECT             chan_to_common_edge;
  enum GRdpmode               display_mode;
  IGRchar                     accept_prompt[80],loc_prompt[80] ;
  struct IGRline              boreline;
  IGRpoint                    point1, point2;
  IGRdouble                   beg_xyz_pt[3], end_xyz_pt[3];
  IGRdouble                   dist1, dist2;
  IGRint                      num_entries,num_elements;
  IGRboolean                  edge_locatable=FALSE;
  IGRint 		event_mask;
  IGRchar 		string[MAX_CHAR];

  IGRlong qsize, event_size;
  IGRdouble basistol,chtol;
  GRobjid tmp_ed[1];
  GRobjid *tmped=NULL;
  GRobjid *finedges,*elig_edges,*located_objects = NULL;
  IGRdouble *tmp_ang;
  IGRint n_edges,numedges,no_elig_edges;
  IGRboolean 	to_continue=TRUE,*is_rightend;
  IGRshort *mattyp;
  IGRdouble *mat,temp_rad;
  IGRlong object_located = 0;
IGRint group_count;
IGRint edge_count;
IGRint current_group;
IGRint prev_num_tmped;
IGRint max_num;
IGRint object_count;


group_count= -1;
edge_count = -1;
current_group=0;
max_num=0;
prev_num_tmped =0;
object_count=0;

  *ret_msg = EMS_S_Success;  
  sts = OM_S_SUCCESS;

  BSEXTRACTPAR(&msg, BSTOLCHRDHT, chtol);
  BSEXTRACTPAR(&msg, BSTOLBASIS, basistol);

  event_size = sizeof(struct GRevent);
  qsize = event_size - 2 * sizeof(IGRint);
  objspc_num = me->ModuleInfo.md_id.osnum;

  edge_locatable = EFedge_curves_locatable();

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
     case IDENTIFY_CHAIN_EDGE:
      {
       extern      IGRlong EFlocate_action_handler();
       struct      EMSaction_handler was_located;
       OMuword 	   accept_classid;
       IGRint   num_tmp=0;
       IGRchar     buff1[25],buff2[25],buff3[25],inp_buff[80];

       eventmask1 = GRm_VALUE |GRm_STRING | 
			GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
       eventmask2 = GRm_DATA| GRm_BACK_UP | GRm_RJT_MOVEON;

       nm_edges = 0;
       for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }
       ex$message(msgnumb = EMS_I_ChnMode, buff = buff3)

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


       if(!nm_edges &&  !me->numtmp_chain_links
          && !me->numtmped && me->selection)
          me->active_GRid.objid = NULL_OBJID;
	  temp_rad=me->active_rad;
	  roundn(&temp_rad,3);
       if(!nm_edges &&  !me->numtmp_chain_links
                && !me->numtmped && me->selection 
                && me->fillet_type == CONSTANT_TYPE) 
	{
        ex$message(msgnumb = EMS_P_IdEdBeChainRad, type = "%.3g",
                        var = `temp_rad`, buff = loc_prompt,
                        buffer_size = PROMPT_SIZE)
	}
       else 
       {
            if((me->fillet_type == VARYING_TYPE && me->selection) ||
                !me->selection) 
       	    {
                ex$message(msgnumb = EMS_P_IdentifyStaEdge,
                                buff = loc_prompt, buffer_size = PROMPT_SIZE )
            }
            else 
	    {
                ex$message(msgnumb = EMS_P_IdEdgeEntRadMo, type = "%.3g",
                        var = `temp_rad`, buff = loc_prompt,
                        buffer_size = PROMPT_SIZE )
            }
       }
       GRstatus_display_button(TRUE);

       if(me->locate_stack.num_entries == 0 || me->option_change){
       me->valid_inputdata = TRUE;
	  me->locate_stack.num_entries = 0;
       ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                         in_buff = loc_prompt)
       }
       else {
          ex$message(msgnumb = EMS_P_AccNearEndChain,buff = accept_prompt,
                     buffer_size = PROMPT_SIZE)
       ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                         in_buff = accept_prompt)
       }
        me->option_change = FALSE;
       stat_func = ems$getevent(msg = &msg, event_mask = eventmask1,
                value_type = GRIO_DISTANCE, response = (long *)response,
                response_data = response_data, event = &me->loc_event);


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
             me->edgeval_event[me->numed + me->numtmped]= me->loc_event;
             me->end_edgeval_event[me->numed+me->numtmped].event.value = -1.0;
             me->end_edgeval_event[me->numed+me->numtmped ].num_id= 0;
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
       sts = ex$putque(msg = &msg, response = response,
                        byte = &qsize, buffer = (char *)&me->loc_event.event);

       accept_classid = OPP_EMSedge_class_id;
       was_located.next = NULL;
       was_located.option = LOCATE_EDGE;
       was_located.type = 2;

       if(me->selection) 
       {
       for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }
       was_located.num_objects = nm_edges + me->numtmped;


       located_objects = (GRobjid *)stackalloc
                         (sizeof(GRobjid) * (me->numtmped + nm_edges));
       nm_edges = 0; 
       for(ii = 0; ii < me->numed; ii++)
         {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         located_objects[nm_edges++] = me->located_obj[ii];
         }

       for(ii = 0; ii < me->numtmped; ii++)
{
         located_objects[nm_edges++] = me->tmp_located_obj[ii];
}
for(ii=prev_num_tmped;ii<me->numtmped;ii++)
{
//me->group_edge_info[ii].edge_id = located_objects[ii];
//me->group_edge_info[ii].group_id = group_count ;
}

prev_num_tmped=me->numtmped;

       was_located.objects.same_space.space_number =
                                    me->ModuleInfo.md_id.osnum;
       was_located.objects.same_space.objid = located_objects;

       }
       else
         {
         if(me->numtmped)
           {
           was_located.num_objects = me->numtmped;
           was_located.objects.same_space.space_number =
                                    me->ModuleInfo.md_id.osnum;
           was_located.objects.same_space.objid = me->tmp_located_obj;
           }
         else was_located.num_objects = 0;
         }
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
       eliclass = OPP_EMSedge_class_id;
       rtree_classes.p_classes = &rclass;
       elig_classes.p_classes = &eliclass;

       object_located = 0;
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
                 acc_key = EMS_P_AccNearEndChain,
                 relocate_key = EMS_P_EdgeNotFound, 
                 attributes = &attributes,
		 act_handler = EFlocate_action_handler,
                 act_args = &was_located,
                 stack = &ME.ECsfedloc->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);

    if( (!stat_func))
        {
         *ret_msg = EMS_I_Interrupt;
         goto ret_end;
        }

	if(object_located == GRw_no_value) {
		me->event.response = EX_RJT_MOVEON;
		me->loc_event.response = EX_RJT_MOVEON;
	}

      switch (me->event.response)
      {
       case EX_RJT_MOVEON:
         if(*response != EX_RJT_MOVEON) break;
          if(me->loc_event.response == EX_DATA || !me->valid_inputdata) {
/*
            EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);
*/
	    break;
          }
          else {
           nm_edges = 0;
           for(ii = 0; ii < me->numed; ii++) {
             if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
             nm_edges++;
           }
         if((!nm_edges && !me->numtmp_chain_links && !me->numtmped) 
		|| ((nm_edges == me->numtmped) && !me->selection))
          {
	   ex$message(msgnumb = EMS_S_IgnMoOnRej);
           me->process_state = IDENTIFY_CHAIN_EDGE;
           break;
           }
         else {
          /* Successful completion */
           sts = OM_S_SUCCESS;
	   if(me->fillet_type == VARYING_TYPE && me->selection) {
		num_tmp = 0;
		for(i = 0; i < me->numtmp_chain_links; i++) 
			num_tmp += me->var_chain_edges[i].numedges;
		me->numtmped = num_tmp;
	   }
	 }
		
           goto ret_end;  
         }

       case  EX_BACK_UP:
	 {
          display_mode = GRhe ;
	  if(*response != EX_BACK_UP) break;
	
	  if(me->fillet_type == VARYING_TYPE && me->selection) {
	    if(!me->numtmp_chain_links) {   
	    ex$message(msgnumb =EMS_S_NoPrevBkp) ;
            sleep(1);
	    break;
	    }
	  numedges = me->var_chain_edges[me->numtmp_chain_links-1].numedges;
	    if(!numedges){
	      ME.ECsfedloc->numtmp_chain_links--;
	      if(!me->numtmp_chain_links) {
	         ex$message(msgnumb =EMS_S_NoPrevBkp) ;
                 sleep(1);
                 break;
              }
              else 
              numedges = me->var_chain_edges[me->numtmp_chain_links-1].numedges;
            }
	  if(me->num_bkp_entries) {
	    for(ii =0; ii < me->num_bkp_list[me->num_bkp_entries-1];ii++) {
              sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                      me->var_chain_edges[me->numtmp_chain_links-1].edge_id[numedges - ii -1],
		      display_mode );
              EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
	      ME.ECsfedloc->tmp_located_obj[ME.ECsfedloc->numtmped-1] = NULL;
	      ME.ECsfedloc->numtmped--;
	      me->var_chain_edges[me->numtmp_chain_links -1].edge_id[numedges - ii -1]
		= NULL;
              me->var_chain_edges[me->numtmp_chain_links-1].numedges--;
	    }
	    me->num_bkp_entries--;
	    numedges = me->var_chain_edges[me->numtmp_chain_links-1].numedges;
            if(!numedges) 
	      me->numtmp_chain_links--;
	   
	    EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);
	  }
	  else {
	    ex$message(msgnumb =EMS_S_NoPrevBkp) ;
            sleep(1);
	    break;
	  }
	  } /*if varying*/
	  else { 
	   if(me->num_bkp_entries) {
	     for(ii =0; ii < me->num_bkp_list[me->num_bkp_entries-1];ii++) {
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                      me->tmp_located_obj[me->numtmped-1], display_mode );
            EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
            ME.ECsfedloc->tmp_located_obj[ME.ECsfedloc->numtmped-1] = NULL;
	    ME.ECsfedloc->numtmped --;
	    }
	    me->num_bkp_entries--;
	    EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);
           }
           else
           {
	    ex$message(msgnumb =EMS_S_NoPrevBkp) ;
            sleep(1);
	    break;
           }
	  }  /* constant rad or deselection */
	  me->process_state = IDENTIFY_CHAIN_EDGE;
	  break;
	}
      case EX_DATA:
       {

	if(!object_located) break;
        first_edge = me->event.located_object[0].located_obj.objid;
        objspc_num = me->event.located_object[0].located_obj.osnum;
        me->ModuleInfo = me->event.located_object[0].module_info;
/* jeff */
/*
me->numround[-1]=0;
me->numround[-2]=0;
*/
if(me->selection && me->fillet_type == CONSTANT_TYPE)
{
 	edge_count++;
	me->group_edge_info[object_count].edge_id  = first_edge;
	me->group_edge_info[object_count].group_id = edge_count ;
	me->numround[edge_count]=1;
	me->numgroup++;
	group_count++;
	object_count++;
}
else
{
	int i;
	int num_round_edges;
	num_round_edges = 0;
	for(i=0;i<me->numgroup;i++)
	{
		num_round_edges = num_round_edges + me->numround[i] ;
	}
	if( max_num < num_round_edges )
	{
		max_num=num_round_edges;
	}
	
	for(i=0;i<max_num;i++)
	{
		if( me->group_edge_info[i].edge_id == first_edge)
		{
			me->numround[me->group_edge_info[i].group_id]--;
		}

	}

}
/* ------ jeff --------- */
        nm_edges = 0;
        for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
        }
	if(me->fillet_type == VARYING_TYPE && me->selection) 
	sts = EFchkif_edge_valid(first_edge,objspc_num,&me->active_GRid,
                        me->numtmp_chain_links,nm_edges);
	else 
	sts = EFchkif_edge_valid(first_edge,objspc_num,&me->active_GRid,
                        me->numtmped,nm_edges);
        if(sts) {
          IGRboolean is_convex,is_neutral;
          IGRdouble angmeas;
          mattyp = &me->event.located_object[0].module_info.md_env.matrix_type; 
          mat = me->event.located_object[0].module_info.md_env.matrix; 
          sts = om$send(msg = message EMSedge.EMchkconvex(&msg, NULL,
                        mattyp, mat, EMS_ZEROANGLE_DEG_MAX, &is_convex,
                        &is_neutral, &angmeas),
                        senderid = NULL_OBJID,
                        targetid = first_edge,
                        targetos = objspc_num);
          if(!is_neutral) 
                EFcheck_if_neutral(angmeas, me->neutral_edge_angle,
                        &is_neutral);
          if(is_neutral) sts = 0;
        }
        if(!sts) {
            display_mode = GRhe ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                  me->event.located_object[0].located_obj.objid,
                  display_mode );
          EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
          ex$message ( msgnumb = EMS_S_InvalidEdge);
	  sleep(1);
          me->process_state = IDENTIFY_CHAIN_EDGE;
          break;
        }



	tmp_ed[0] = me->event.located_object[0].located_obj.objid;

	numedges = 1;

	if(me->fillet_type == VARYING_TYPE && me->selection) {
	for(i = 0; i< me->numtmp_chain_links ; i++)
	sts = EFparse_edges(&msg, &me->selection, me->located_obj, 
			me->var_chain_edges[i].edge_id, me->numed, 
			me->var_chain_edges[i].numedges,
			tmp_ed, objspc_num, &numedges,me->bound_code);

	}
	else
{

	sts = EFparse_edges(&msg, &me->selection, me->located_obj, 
			me->tmp_located_obj, me->numed, me->numtmped,
			tmp_ed, objspc_num, &numedges,me->bound_code);
}

	if(!numedges && me->selection) {
            	ex$message ( msgnumb = EMS_S_InvalidEdge);
	        sleep(1);
            	me->process_state = IDENTIFY_CHAIN_EDGE;
	    	break;
	}
	else if(!me->selection) {
            display_mode = GRhe ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                  	me->event.located_object[0].located_obj.objid,
                  	display_mode );
	
            EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
	    if(!numedges) {
            	me->process_state = IDENTIFY_CHAIN_EDGE;
	    	break;
	    }
	}
        display_mode = GRhe ;
        sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                  	me->event.located_object[0].located_obj.objid,
                  	display_mode );
	
        EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

        display_mode = (me->selection) ? GRhd : GRhe;
        mattyp = &me->ModuleInfo.md_env.matrix_type; 
        mat = me->ModuleInfo.md_env.matrix; 
        sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                 targetid = me->event.located_object[0].located_obj.objid,
                 targetos = objspc_num);
        ME.COroot->ModuleInfo = me->event.located_object[0].module_info; 

	num_entries = om$dimension_of(varray = me->num_bkp_list);
	if((me->num_bkp_entries + 1) >= num_entries) {
	   sts = om$vla_set_dimension(varray = me->num_bkp_list,
			size = me->num_bkp_entries + 1 );
	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
        }
	me->num_bkp_entries++;

	  if(me->fillet_type == VARYING_TYPE && me->selection) {
           num_elements = om$dimension_of(varray = me->var_chain_edges);
	   if ((me->numtmp_chain_links + 1) >= num_elements) {
                sts = om$vla_set_dimension(varray = me->var_chain_edges,
                                size = 1 +num_elements +me->numtmp_chain_links);
                EMomerr_hndlr(sts, ret_end, "set_dimension  error");
           }
	   me->var_chain_edges[me->numtmp_chain_links].chain_var_start.event.value= -1.0;
	   me->numtmp_chain_links++;
	  }
	  else {
           num_elements = om$dimension_of(varray = me->tmp_located_obj);
           if ((me->numtmped + 1) >= num_elements) {
           	sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                         size = 1 + me->numtmped+ num_elements);
           	EMomerr_hndlr(sts, ret_end, "set_dimension  error");
    	   }
           if ((me->numtmped + 1 + me->numed) >= num_elements) {
           	sts = om$vla_set_dimension(varray = me->edgeval_event,
                                  size = num_elements + 1 + me->numed +
					me->numtmped);
           	EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           	sts = om$vla_set_dimension(varray = me->fill_typ,
                       size =num_elements +1+ me->numed + me->numtmped);
         	  EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	  
           	sts = om$vla_set_dimension(varray = me->bound_code,
                       size = num_elements +1+me->numed + me->numtmped);
           	EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           	sts = om$vla_set_dimension(varray=me->end_edgeval_event,
                                  size = num_elements + 1 + me->numed +
					me->numtmped);
           	EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           }
	   me->tmp_located_obj[me->numtmped] = first_edge;
	  }

          me->process_state = CHAIN_EDGES;
          break;
       }
       default:
              me->valid_inputdata = FALSE;
             goto ret_end;
       } /* switch of event response */
       break;
      } /*  of 3 cases */
     default:
	goto ret_end;
     } /* switch of loc_event response */
     break;               
    }

     case CHAIN_EDGES:
     {
     IGRushort edge_options=0;
     IGRint num_buff = 10;
     IGRboolean one_edge = FALSE;
     IGRint ind = 0,num_true, num_false;
     GRobjid *lft_edges = NULL;
     GRobjid *rht_edges = NULL;
     GRobjid saved_edge;
     IGRlong EFgetedges();
     IGRlong EFgetchained_edges();
     IGRlong EFchk_cvcx();
     IGRlong EFchkif_neutral();
     IGRlong EFchkang_bet_edges();
     IGRlong EFchk_objid();
     IGRlong EFgetpnt();
     IGRboolean backup = FALSE,closed_chain = FALSE;
     IGRshort *mattyp;
     IGRdouble *mat;
     IGRint num_tmp;

     to_continue = TRUE;
     if(!tmped)
     tmped = (GRobjid *) om$malloc(size = ARR_SIZE * sizeof(GRobjid));
     EMerr_hndlr (!tmped, *ret_msg, EMS_E_NoDynamicMemory, ret_end);

     me->process_state = IDENTIFY_CHAIN_EDGE;
     mattyp = &me->event.located_object[0].module_info.md_env.matrix_type; 
     mat = me->event.located_object[0].module_info.md_env.matrix; 
 
     if(me->fillet_type == VARYING_TYPE && me->selection) 
     first_edge=tmp_ed[0];
     else first_edge = me->tmp_located_obj[me->numtmped];
     saved_edge = first_edge;

     /* Get the dominant edges for this vertex */
     edge_options = EMSvtxedges_nodegenerate | EMSvtxedges_onlydominant |
                    EMSvtxedges_noseamedge | EMSvtxedges_notangent |
                    EMSvtxedges_onlycommon;
     EFboreline(&msg, my_id, &me->event, &boreline);

     sts = om$send( msg = message EMSedge.EMxyz_endpt( &msg, NULL,
                        &ME.COroot->ModuleInfo.md_env, NULL, NULL,
                        beg_xyz_pt, end_xyz_pt, NULL ),
               targetid = first_edge,
               targetos = objspc_num) ;
     EMomerr_hndlr (sts, ret_end, "EMxyz_endpt");

     BSdistptli(&msg, beg_xyz_pt, boreline.point1,
                    boreline.point2, &dist1);

     BSdistptli(&msg, end_xyz_pt, boreline.point1,
                    boreline.point2, &dist2);
     if ( dist1 < dist2 )
             right_vertex = FALSE;
     else
             right_vertex = TRUE;

     sts = EFgetedges(first_edge,&lft_edges,right_vertex,&num_true,objspc_num);
     sts = EFchkif_neutral(lft_edges,&num_true,objspc_num,
		 mat,mattyp,me->neutral_edge_angle);
     ind = 0;
     numedges = num_true;
     me->num_bkp_list[me->num_bkp_entries-1] = 0;
     if(me->fillet_type == VARYING_TYPE && me->selection) {
	for(i= 0; i< me->numtmp_chain_links;i++) { 
	  sts = EFparse_edges(&msg,&me->selection,me->located_obj,
			me->var_chain_edges[i].edge_id, me->numed, 
			me->var_chain_edges[i].numedges,
			lft_edges, objspc_num, &num_true,me->bound_code);
	}
	tmp_ang = (IGRdouble *)stackalloc(num_true * sizeof(IGRdouble));
	sts = EFchk_cvcx(first_edge,lft_edges,&num_true,tmp_ang,objspc_num,
		mat,mattyp,me->neutral_edge_angle);
	} 
      else {
        sts = EFparse_edges(&msg,&me->selection,me->located_obj,
			me->tmp_located_obj, me->numed, me->numtmped,
			lft_edges, objspc_num, &num_true,me->bound_code);
      }

	num_tmp = 0;
        nm_edges = 0;
        for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
        }
	for(ii = 0; ii < num_true; ii++) {
	  if(me->fillet_type == VARYING_TYPE && me->selection)
            sts = EFchkif_edge_valid(lft_edges[ii],objspc_num,&me->active_GRid,
                    me->numtmp_chain_links,nm_edges);
          else
            sts = EFchkif_edge_valid(lft_edges[ii],objspc_num,&me->active_GRid,
                    me->numtmped,nm_edges);
	  if(!sts) {

	    num_tmp++ ; continue;
	  }
	  lft_edges[ii - num_tmp] = lft_edges[ii];
	  
	}
	tmped[ind++] = first_edge;
	num_true -= num_tmp;
	if(num_true > 1 || !num_true || numedges > 1) goto left_vertex;

	tmped[ind++] = lft_edges[0];
	do 
          {
          if(lft_edges)
            {
            om$dealloc(ptr = lft_edges);
            lft_edges = NULL;
            }
     	  sts = EFgetchained_edges(first_edge,tmped[ind -1],
			&lft_edges,&num_true,objspc_num);
	  sts = EFchk_objid(tmped[ind - 1],lft_edges,&num_true);
	  sts = EFchkif_neutral(lft_edges,&num_true,objspc_num,
                 mat,mattyp,me->neutral_edge_angle);
	  numedges = num_true;

	num_tmp = 0;
        if(me->selection) display_mode = GRhd;
        else display_mode = GRhe;
	if(me->fillet_type == VARYING_TYPE && me->selection) 
          {
          for(i = 0; i< ind ; i++ )
            for(jj = 0; jj < num_true; jj++)
              if(lft_edges[jj] == tmped[i]) {num_tmp++;continue;}
	      else lft_edges[jj - num_tmp] =  lft_edges[jj];
	  num_true -=num_tmp;
	  if(!num_true || num_tmp) 
            {
            ind--; break;
            }
          for(i = 0; 
	    i< me->var_chain_edges[me->numtmp_chain_links - 1].numedges; i++)
            for(jj = 0 ; jj < num_true; jj++)
              if(lft_edges[jj] ==
                me->var_chain_edges[me->numtmp_chain_links - 1].edge_id[i])
	        {
                num_tmp++;continue;
                }
              else lft_edges[jj - num_tmp] = lft_edges[jj];
	  num_true -=num_tmp;

	  if(!num_true || num_tmp) 
            {
            ind--; break;
            }
          }
        else 
          {
          for(jj = 0; jj < ind; jj++)
            for(ii = 0; ii < num_true ; ii++)
              if(lft_edges[ii] == tmped[jj]) num_tmp++;
          for(ii = 0; ii < num_true ; ii++)
            for(jj = 0; jj < me->numtmped; jj++)
              if(lft_edges[ii] == me->tmp_located_obj[jj]) num_tmp++;
          if(num_tmp) {to_continue = FALSE;

            sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmped[ind -1],
                        targetos = objspc_num);
            EMomerr_hndlr(sts, ret_end, "EMdisplay");
            break;}
          }

          sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmped[ind -1],
                        targetos = objspc_num);
        EMomerr_hndlr(sts, ret_end, "EMdisplay");
	first_edge = tmped[ind -1];
	if(me->fillet_type == VARYING_TYPE && me->selection) {
	tmp_ang = (IGRdouble *)stackalloc(num_true * sizeof(IGRdouble));
	sts = EFchk_cvcx(first_edge,lft_edges,&num_true,tmp_ang,objspc_num,mat,mattyp,me->neutral_edge_angle);
	for(i= 0; i< me->numtmp_chain_links;i++) { 
	  sts = EFparse_edges(&msg,&me->selection,me->located_obj,
			me->var_chain_edges[i].edge_id, me->numed, 
			me->var_chain_edges[i].numedges,
			lft_edges, objspc_num, &num_true,me->bound_code);
	}
	} 
	else  {
	  sts = EFparse_edges(&msg,&me->selection,me->located_obj,
                        me->tmp_located_obj, me->numed,
                        me->numtmped,
                        lft_edges, objspc_num, &num_true,me->bound_code);
	}
	sts = EFparse_edges(&msg,&me->selection,me->located_obj,
                        tmped, me->numed,
                        ind,lft_edges, objspc_num, &num_true,me->bound_code);
	num_tmp = 0;
        nm_edges = 0;
        for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
        }
        for(ii = 0; ii < num_true; ii++) {
          if(me->fillet_type == VARYING_TYPE && me->selection)
            sts = EFchkif_edge_valid(lft_edges[ii],objspc_num,&me->active_GRid,
                    me->numtmp_chain_links,nm_edges);
          else
            sts = EFchkif_edge_valid(lft_edges[ii],objspc_num,&me->active_GRid,
                    me->numtmped,nm_edges);
          if(!sts) {
            num_tmp++ ; continue;
          }
          lft_edges[ii - num_tmp] = lft_edges[ii];

        }
        num_true -= num_tmp;

	if(numedges > 1 || num_true > 1 || !num_true) break;

	first_edge = tmped[ind - 1];
        if((ind % ARR_SIZE) == 0)
          {
          tmped = (GRobjid *) om$realloc (
                      size = (ind + ARR_SIZE) * sizeof (GRobjid), 
                      ptr = (IGRchar *)tmped);
          EMerr_hndlr (!tmped, *ret_msg, EMS_E_NoDynamicMemory, ret_end);
          }
	tmped[ind++] = lft_edges[0];
	} while (TRUE);

left_vertex:
        if(lft_edges && num_true)
          {
          om$dealloc(ptr = lft_edges);
          lft_edges = NULL;
          }

	numedges =  ind;
	if(numedges == 1) one_edge = TRUE;
	finedges = (GRobjid *)stackalloc(sizeof(GRobjid) * numedges);

	for(i = 0 ; i < ind  ; i++)
		finedges[i] = tmped[i];
	if(me->fillet_type == VARYING_TYPE && me->selection) {
	 num_elements = om$dimension_of(varray = me->var_chain_edges);
	 if ((me->numtmp_chain_links + 1) >= num_elements) {
                sts = om$vla_set_dimension(varray = me->var_chain_edges,
                             size = 1 +num_elements +me->numtmp_chain_links);
                EMomerr_hndlr(sts, ret_end, "set_dimension  error");
         }
	 num_tmp = me->var_chain_edges[me->numtmp_chain_links - 1].numedges;
	 me->var_chain_edges[me->numtmp_chain_links - 1].numedges += numedges;
	 EFcreate_space_chain_edges( num_tmp,
	  me->var_chain_edges[me->numtmp_chain_links - 1].numedges,
	  (GRobjid **)&me->var_chain_edges[me->numtmp_chain_links - 1].edge_id);
	 for(ii = 0; ii< numedges ; ii++) 
{
	  me->var_chain_edges[me->numtmp_chain_links-1].edge_id[num_tmp+ii]=
				 finedges[ii];
}
        }
        else {
    	num_elements = om$dimension_of(varray = me->tmp_located_obj);
    	if ((me->numtmped + numedges ) >= num_elements) {
        	sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                              size = me->numtmped +num_elements + numedges);
        	EMomerr_hndlr(sts, ret_end, "set_dimension  error");
    	}
    	if ((me->numtmped + numedges + me->numed) >= num_elements) {
        	sts = om$vla_set_dimension(varray = me->edgeval_event,
                       size = num_elements+ numedges + me->numed+ me->numtmped);
        	EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           	sts = om$vla_set_dimension(varray = me->fill_typ,
                       size = numedges +num_elements +me->numed + me->numtmped);
           	EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	  
           	sts = om$vla_set_dimension(varray = me->bound_code,
                       size = numedges + num_elements+me->numed + me->numtmped);
           	EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	
        	sts = om$vla_set_dimension(varray = me->end_edgeval_event,
                       size = num_elements + numedges+ me->numed+me->numtmped);
        	EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	
    	 }
	}

	if(me->fillet_type != VARYING_TYPE || !me->selection) {
    	for(i = 0; i < numedges; i++) {
		me->tmp_located_obj[me->numtmped + i] = finedges[i];
                me->end_edgeval_event[me->numed+me->numtmped + i].num_id= 0;
                me->edgeval_event[me->numed+me->numtmped + i].num_id= 0;
		me->edgeval_event[me->numed + i + me->numtmped].event.value = me->active_rad;
		me->end_edgeval_event[me->numed + i + me->numtmped].event.value = -1.0;
                me->bound_code[me->numed+me->numtmped+i]= 0;
		me->fill_typ[me->numed + i + me->numtmped] = me->fillet_type;
    	}
        
        if(me->numtmped == 0 || !me->radius_changed) {
          me->bound_code[me->numed+me->numtmped]= EMSrnd_input_ed_grp_start;
          me->radius_changed = 1;
        }
    	me->numtmped += numedges;
 /*if(edge_count != 0) 
        me->numround[edge_count]= me->numtmped - me->numround[edge_count-2];
else 
	me->numround[edge_count]= me->numtmped;

for(kk=object_count;kk<(object_count+me->numround[edge_count]);kk++)
	me->group_edge_info[kk].group_id = edge_count ;

//object_count = object_count + me->numround[edge_count];
*/
	}

	 /* till here it takes care of chained edges for the
	  * first event i.e identify edge 
	  */

	me->num_bkp_list[me->num_bkp_entries-1]=0;
	me->num_bkp_list[me->num_bkp_entries-1]=numedges;
	
      EFboreline(&msg, my_id, &me->event, &boreline);

      ind = 0;
      if(one_edge) {
	first_edge = finedges[0];
       	sts = om$send( msg = message EMSedge.EMxyz_endpt( &msg, NULL,
                        &ME.COroot->ModuleInfo.md_env, NULL, NULL, 
                        beg_xyz_pt, end_xyz_pt, NULL ),  
               		targetid = first_edge,
               		targetos = objspc_num) ;
         	EMomerr_hndlr (sts, ret_end, "EMxyz_endpt"); 
        BSdistptli(&msg, beg_xyz_pt, boreline.point1, 
                    boreline.point2, &dist1);
        BSdistptli(&msg, end_xyz_pt, boreline.point1, 
                    boreline.point2, &dist2);
        if(dist1 < dist2)
             	right_vertex = FALSE;
        else
                right_vertex = TRUE;           
		
	}
      else {

	first_edge = finedges[numedges - 1];
	right_vertex = TRUE;
     	num_true = 0;
     	num_buff = 10;
     	is_rightend=NULL;
        lft_edges = NULL;
     	sts = om$send(msg = message  EMSedge.EMgetvtxedges(&msg, 
                          edge_options, right_vertex,
                          num_buff, &num_true, &lft_edges,
                          &is_rightend), 
                   targetid = first_edge,
                   targetos = objspc_num );
     	EMomerr_hndlr ( sts, ret_end, "EMgetvtxedges"); 

	temp = 0;
	for (i = 0; i< numedges ; i++)
		for(jj = 0; jj< num_true; jj++)
			if(lft_edges[jj]== finedges[i])
				temp++;
	if(temp >= 2) 
		right_vertex = FALSE;
	else right_vertex = TRUE;
        if(is_rightend)
          {
          om$dealloc(ptr = is_rightend);
          is_rightend = NULL;
          }
        if(lft_edges)
          {
          om$dealloc(ptr = lft_edges);
          lft_edges = NULL;
          }
	} /* more than one edges */ 

     	sts = EFgetedges(first_edge,&lft_edges,right_vertex,&num_true,
			objspc_num);
	sts = EFchkif_neutral(lft_edges,&num_true,objspc_num,
                 mat,mattyp,me->neutral_edge_angle);
	numedges = num_true;
	if(me->fillet_type == VARYING_TYPE && me->selection) {
	  sts = EFchk_objid(saved_edge,lft_edges,&num_true);
          numedges = num_true;
	  for(i= 0; i< me->numtmp_chain_links;i++) { 
	   sts = EFparse_edges(&msg,&me->selection,me->located_obj,
			me->var_chain_edges[i].edge_id, me->numed, 
			me->var_chain_edges[i].numedges,
			lft_edges, objspc_num, &numedges,me->bound_code);
	  }
	num_true = numedges;
	tmp_ang = (IGRdouble *)stackalloc(num_true * sizeof(IGRdouble));
	sts = EFchk_cvcx(first_edge,lft_edges,&num_true,tmp_ang,objspc_num,mat,mattyp,me->neutral_edge_angle);
	}/*if varying */
	else {
		sts = EFparse_edges(&msg, &me->selection, me->located_obj, 
			me->tmp_located_obj, me->numed, me->numtmped,
			lft_edges, objspc_num, &numedges,me->bound_code);
		num_true = numedges;
	}
	ind = 0;
	num_tmp = 0;
        nm_edges = 0;
        for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
        }
        for(ii = 0; ii < num_true; ii++) {
          if(me->fillet_type == VARYING_TYPE && me->selection)
            sts = EFchkif_edge_valid(lft_edges[ii],objspc_num,&me->active_GRid,
                    me->numtmp_chain_links,nm_edges);
          else
            sts = EFchkif_edge_valid(lft_edges[ii],objspc_num,&me->active_GRid,
                    me->numtmped,nm_edges);
          if(!sts) {
            num_tmp++ ; continue;
          }
          lft_edges[ii - num_tmp] = lft_edges[ii];

        }
        num_true -= num_tmp;
	if(!num_true) {
	  if(me->fillet_type == VARYING_TYPE && me->selection)
	    me->process_state = INPUT_CHAIN_RADII;
          if(lft_edges)
            {
            om$dealloc(ptr = lft_edges);
            lft_edges = NULL;
            }
	  break;
	}
	num_tmp = 0;
	if(num_true > 1) {
            tmp_ang = (IGRdouble *)stackalloc(num_true * sizeof(IGRdouble));
          if(me->fillet_type == VARYING_TYPE && me->selection) 
            {
	    sts = EFchk_cvcx(first_edge,lft_edges,&num_true,
		tmp_ang,objspc_num,mat,mattyp,me->neutral_edge_angle);
	    EFsortedges_by_angle(tmp_ang,lft_edges,num_true,basistol);
            }
	  else 
	    EFgetang_meas(first_edge,lft_edges,num_true,
                tmp_ang,me->ModuleInfo,basistol);

                num_tmp = 0;
		
		if((tmp_ang[1] - tmp_ang[0]) < basistol) {
                is_rightend=
                   (IGRboolean *)stackalloc(sizeof(IGRboolean)*num_true);
                for(ii = 0; ii < num_true; ii++)
                is_rightend[ii] = TRUE; 
		 if(me->fillet_type == VARYING_TYPE && me->selection) {
		  IGRint p;
		  p =me->var_chain_edges[me->numtmp_chain_links -1].numedges;
		 if( p >= 2)
      	          EFput_edge_on_same_surface( &msg, 
		    me->var_chain_edges[me->numtmp_chain_links -1].edge_id[p-2],
                    me->var_chain_edges[me->numtmp_chain_links -1].edge_id[p-1],
			lft_edges, 2, is_rightend, objspc_num);
		 }
		 else {
		  if(me->num_bkp_list[me->num_bkp_entries-1] >= 2)
      	            EFput_edge_on_same_surface( &msg, me->tmp_located_obj[me->numtmped-2], me->tmp_located_obj[me->numtmped-1], 
			lft_edges,2,is_rightend, objspc_num);
			
		 }
		}
	} /* num_true > 1 */
        if(me->fillet_type == VARYING_TYPE && me->selection) {
                temp = 0;
                for(ii = 0; ii < num_true ; ii++) {
                num_tmp = 0;
                sts = EFgetchained_edges(first_edge,lft_edges[ii],
                                &rht_edges,&num_false,objspc_num);
                sts = EFchk_objid(lft_edges[ii],rht_edges,&num_false);
                for(i = 0; i < num_false; i++)
                  for(jj = 0;
                    jj < me->var_chain_edges[me->numtmp_chain_links-1].numedges;
                    jj++)
                    if(rht_edges[i] ==
                      me->var_chain_edges[me->numtmp_chain_links-1].edge_id[jj])
                      num_tmp++;
                if(num_tmp) {temp++; continue;}
                lft_edges[ii - temp] = lft_edges[ii];
                }
                num_true -= temp;
       }
       if(!num_true) {
         if(me->fillet_type == VARYING_TYPE && me->selection)
           me->process_state = INPUT_CHAIN_RADII;
         to_continue = FALSE;
          if(rht_edges)
            {
            om$dealloc(ptr = rht_edges);
            rht_edges = NULL;
            }
       }
	no_elig_edges = num_true;
	elig_edges = (GRobjid *)stackalloc(sizeof(GRobjid) * num_true);

        for(ii = 0; ii < no_elig_edges ; ii++)
          elig_edges[ii] = lft_edges[ii];

        if(lft_edges)
          {
          om$dealloc(ptr = lft_edges);
          lft_edges = NULL;
          }

	for(;;) {

	  if(!to_continue) break;
	  closed_chain = FALSE;
          resp = 0;

	  for(ii = 0; ii < no_elig_edges ; ii++) {
	    display_mode = GRhd;
	    sts = EFhilite_edge_with_weight(&msg,me->ModuleInfo,
                           elig_edges[ii],display_mode);
            EMomerr_hndlr(sts,ret_end,"EFhilite_edge_with_weight");
                
            ex$message(msgnumb = EMS_P_AccContChain, buff = string);
            event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
	
      	    stat_func = ems$getevent ( msg = &msg,
           		event_mask = event_mask,
           		value_type = GRIO_DISTANCE,
           		prompt = string,
           		response = (long *)response,
           		response_data = response_data,
           		event = &me->event);

     	    ex$message ( msgnumb = EMS_P_ClearPromptField);
	
     	    if(stat_func == FALSE) {
       	      ex$message ( msgnumb = EMS_E_FailureInputProcessing);
              *response = TERMINATE;
       	      goto ret_end;
      	    }	
            display_mode = GRhe;
            sts = EFhilite_edge_with_weight(&msg,me->ModuleInfo,
                           elig_edges[ii],display_mode);
            EMomerr_hndlr(sts,ret_end,"EFhilite_edge_with_weight");

	    if ( me->event.response == GR_UNKNOWN_TYPE ) {
       	      *ret_msg = EMS_I_Interrupt;
	      me->valid_inputdata = FALSE;
              goto ret_end;
      	    }
	    if(me->event.response ==  EX_RJT_MOVEON) {
              if(!me->selection) {
              display_mode = GRhd;
              mattyp =&me->ModuleInfo.md_env.matrix_type;
              mat = me->ModuleInfo.md_env.matrix;
	      sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = elig_edges[ii],
                        targetos = objspc_num);
              EMomerr_hndlr(sts, ret_end, "EMdisplay");	
              }
	      resp = EX_RJT_MOVEON;
	      continue;
	    }
	    if(me->event.response == EX_BACK_UP) {
	      resp = EX_BACK_UP;
	      backup = TRUE;
	      display_mode = GRhe;
	      if(me->fillet_type == VARYING_TYPE && me->selection) {
	        if(!me->numtmp_chain_links) {   
	        ex$message(msgnumb =EMS_S_NoPrevBkp) ;
                sleep(1);
	        backup = FALSE;
		me->process_state = IDENTIFY_CHAIN_EDGE;
	        break;
	      }
	      numedges = me->var_chain_edges[me->numtmp_chain_links-1].numedges;
	      if(!numedges){
	      ME.ECsfedloc->numtmp_chain_links--;
	      if(!me->numtmp_chain_links) {
	         ex$message(msgnumb =EMS_S_NoPrevBkp) ;
                 sleep(1);
	         backup = FALSE;
		 me->process_state = IDENTIFY_CHAIN_EDGE;
                 break;
              }
              else 
              numedges = me->var_chain_edges[me->numtmp_chain_links-1].numedges;
              }
	      if(me->num_bkp_entries) {
	       for(ii =0; ii < me->num_bkp_list[me->num_bkp_entries-1];ii++) {
               sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                      me->var_chain_edges[me->numtmp_chain_links-1].edge_id[numedges - ii -1],
		      display_mode );
              EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
	      me->var_chain_edges[me->numtmp_chain_links -1].edge_id[numedges - ii -1]
		= NULL;
              me->var_chain_edges[me->numtmp_chain_links-1].numedges--;
	      }
	      me->num_bkp_entries--;
	      numedges = me->var_chain_edges[me->numtmp_chain_links-1].numedges;
              if(!numedges) 
	        me->numtmp_chain_links--;
	      EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);
	      if(me->num_bkp_entries) {
	        backup = TRUE;
		numedges=me->var_chain_edges[me->numtmp_chain_links-1].numedges;
	        first_edge = me->var_chain_edges[me->numtmp_chain_links-1].edge_id[numedges - 1];
		break;
	      }
	      else {me->process_state = IDENTIFY_CHAIN_EDGE; backup = FALSE;
		    break;
	      }
	      }
	      else {
	        ex$message(msgnumb =EMS_S_NoPrevBkp) ;
                sleep(1);
		backup = FALSE;
	        break;
	      }
	      } /*if varying*/
	      else { 
	       if(me->num_bkp_entries) {
	         for(ii =0; ii < me->num_bkp_list[me->num_bkp_entries-1];ii++) {
                sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                      me->tmp_located_obj[me->numtmped-1], display_mode );
                EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
                ME.ECsfedloc->tmp_located_obj[ME.ECsfedloc->numtmped-1] = NULL;
	        ME.ECsfedloc->numtmped --;
	       }
	       me->num_bkp_entries--;
	       EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,
                   me->ModuleInfo,me->bound_code);
	       if(me->num_bkp_entries) {
	       first_edge = me->tmp_located_obj[me->numtmped-1];
	       backup = TRUE;
	       }	
	       else {backup = FALSE;me->process_state = IDENTIFY_CHAIN_EDGE;break;}
              }
              else {
	       ex$message(msgnumb =EMS_S_NoPrevBkp) ;
               sleep(1);
	       backup = FALSE;
	       break;
              }
	     }  /* constant rad or deselection */
	    }
	    if(me->event.response == EX_DATA) {
	        resp = EX_DATA;
	        
                if(me->fillet_type == VARYING_TYPE && me->selection) {
                  num_tmp = 0;
                  for(jj = 0;
                    jj < me->var_chain_edges[me->numtmp_chain_links-1].numedges;
                    jj++)
{
                    if(elig_edges[ii] ==
                      me->var_chain_edges[me->numtmp_chain_links-1].edge_id[jj])
                      num_tmp++;
}
                  if(num_tmp)  {
		    if(ii == no_elig_edges -1 ) {
		      closed_chain = TRUE;
		      break;
		    }
		    else 
		      continue;
		  }
	        }

	        break;
	      } /* EX_DATA  */
	    } /* of elig_edges */

	    if(!to_continue) break;

	    if(resp == EX_BACK_UP) {
	      if(!backup) { to_continue = FALSE; break;}
	      else {
	        right_vertex = TRUE; num_true = 0;
	        sts = EFgetedges(first_edge,&lft_edges,
                        right_vertex,&num_true,objspc_num);
	        temp = 0;
	        if(me->fillet_type == VARYING_TYPE && me->selection) {
	        for(i = 0; 
		  i< me->var_chain_edges[me->numtmp_chain_links-1].numedges;
		  i++) 
		  for(jj = 0; jj < num_true; jj++)
		    if(lft_edges[jj]== 
		      me->var_chain_edges[me->numtmp_chain_links-1].edge_id[i])
		      temp++;
	        } /* if varying */
	        else {
		for (i = 0; i< me->numtmped ; i++)
		  for(jj = 0; jj< num_true; jj++)
		    if(lft_edges[jj]== me->tmp_located_obj[i])
		      temp++;
	        }
	        if(temp >= 1) {
                  if(lft_edges)
                    {
                    om$dealloc(ptr = lft_edges);
                    lft_edges = NULL;
                    }
		right_vertex = FALSE;
     		num_true = 0;
	        sts = EFgetedges(first_edge,&lft_edges,
                        right_vertex,&num_true,objspc_num);
	        } 
                mattyp =&me->ModuleInfo.md_env.matrix_type;
                mat = me->ModuleInfo.md_env.matrix;
	        sts = EFchkif_neutral(lft_edges,&num_true,objspc_num,
                        mat,mattyp,me->neutral_edge_angle);
                num_tmp = 0;
                nm_edges = 0;
                for(ii = 0; ii < me->numed; ii++) {
                 if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
                 nm_edges++;
                }
                for(ii = 0; ii < num_true; ii++) {
                if(me->fillet_type == VARYING_TYPE && me->selection)
                  sts = EFchkif_edge_valid(lft_edges[ii],
                          objspc_num,&me->active_GRid,
                          me->numtmp_chain_links,nm_edges);
                else
                  sts = EFchkif_edge_valid(lft_edges[ii],objspc_num,
                          &me->active_GRid, me->numtmped,nm_edges);
                if(!sts) {
                  num_tmp++ ; continue;
                }
                lft_edges[ii - num_tmp] = lft_edges[ii];
                }
                num_true -= num_tmp;
	        numedges = num_true;

                if(me->fillet_type == VARYING_TYPE && me->selection) {
                temp = 0;
                for(ii = 0; ii < num_true ; ii++) {
                num_tmp = 0;
                if(rht_edges)
                  {
                  om$dealloc(ptr = rht_edges);
                  rht_edges = NULL;
                  }
                sts = EFgetchained_edges(first_edge,lft_edges[ii],
                                &rht_edges,&num_false,objspc_num);
                sts = EFchk_objid(lft_edges[ii],rht_edges,&num_false);
                for(i = 0; i < num_false; i++)
                  for(jj = 0;
                    jj < me->var_chain_edges[me->numtmp_chain_links-1].numedges;
                    jj++)
                    if(rht_edges[i] ==
                      me->var_chain_edges[me->numtmp_chain_links-1].edge_id[jj])
                      num_tmp++;
                if(num_tmp) {temp++; continue;}
                lft_edges[ii - temp] = lft_edges[ii];
                }
                num_true -= temp;
                }
	        num_tmp = 0;
                numedges = num_true;
                if(me->fillet_type == VARYING_TYPE && me->selection) {
                for(i = 0; i< me->numtmp_chain_links; i++)
                  sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                            me->var_chain_edges[i].edge_id, me->numed,
                            me->var_chain_edges[i].numedges,
                            lft_edges, objspc_num, &numedges,me->bound_code);
                tmp_ang =(IGRdouble *)stackalloc(num_true * sizeof(IGRdouble));
                num_true = numedges;
                mattyp =&me->ModuleInfo.md_env.matrix_type;
                mat = me->ModuleInfo.md_env.matrix;
                sts = EFchk_cvcx(first_edge,lft_edges,&num_true,
                        tmp_ang,objspc_num,mat,mattyp,me->neutral_edge_angle);
		EFsortedges_by_angle(tmp_ang,lft_edges,num_true,basistol);
                } /* if varying */
                else {
                sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                          me->tmp_located_obj, me->numed, me->numtmped,
                          lft_edges, objspc_num, &numedges,me->bound_code);
                num_true = numedges;
                tmp_ang =(IGRdouble *)stackalloc(num_true * sizeof(IGRdouble));
                EFgetang_meas(first_edge,lft_edges,num_true,
                tmp_ang,me->ModuleInfo,basistol);

                }
	        if(num_true > 1) {
		num_tmp = 0;
		is_rightend=
		   (IGRboolean *)stackalloc(sizeof(IGRboolean)*num_true);
		for(ii = 0; ii < num_true; ii++)
		is_rightend[ii] = TRUE;
		if((tmp_ang[1] - tmp_ang[0]) < basistol) {
		  if(me->fillet_type == VARYING_TYPE && me->selection) {
		    IGRint p;
		    p =me->var_chain_edges[me->numtmp_chain_links -1].numedges;
		    if( p >= 2)
      	              EFput_edge_on_same_surface( &msg, 
		    me->var_chain_edges[me->numtmp_chain_links -1].edge_id[p-2],
                    me->var_chain_edges[me->numtmp_chain_links -1].edge_id[p-1],
			lft_edges, 2, is_rightend, objspc_num);
		  }
		  else {
		    if(me->numtmped >= 2)
      	              EFput_edge_on_same_surface( &msg, 
			me->tmp_located_obj[me->numtmped-2], 
			me->tmp_located_obj[me->numtmped-1], 
			lft_edges,2,is_rightend, objspc_num);
		  }
		 }
	        }
		  
	          no_elig_edges = num_true;
		  elig_edges =(GRobjid *)stackalloc(sizeof(GRobjid) * num_true);
		  to_continue = TRUE;
		  for(ii = 0; ii < num_true; ii++)
		    elig_edges[ii] = lft_edges[ii];
                  if(lft_edges)
                    {
                    om$dealloc(ptr = lft_edges);
                    lft_edges = NULL;
                    }
		    continue;
	      }  
	    } /* of resp BACKUP */
	    if(resp == EX_DATA) {
/* jeff */
if(me->selection && me->fillet_type == CONSTANT_TYPE)
{
        me->group_edge_info[object_count].edge_id  = elig_edges[ii];
        me->group_edge_info[object_count].group_id = edge_count ;

	me->numround[edge_count]= me->numround[edge_count] + 1;
	object_count++;
}
else
{
      int i;
        int num_round_edges;
        num_round_edges = 0;

        for(i=0;i<me->numgroup;i++)
        {
                num_round_edges = num_round_edges + me->numround[i] ;
        }
        for(i=0;i<num_round_edges;i++)
        {
                if( me->group_edge_info[i].edge_id == first_edge)
                {

                        me->numround[me->group_edge_info[i].group_id]--;
 }

        }
}
/* ------------- jeff ------------ */


              if(me->fillet_type == VARYING_TYPE && me->selection)
                  me->process_state = INPUT_CHAIN_RADII;
                else me->process_state = IDENTIFY_CHAIN_EDGE;
	      if(closed_chain) break;
	      if(me->fillet_type == VARYING_TYPE && me->selection) {
		if(!me->numtmp_chain_links) break;
	      }
	      else 
		if(!me->numtmped) break;
	      first_edge = elig_edges[ii];
		
	      me->num_bkp_entries++;
	      num_entries = om$dimension_of(varray = me->num_bkp_list);
	      if((me->num_bkp_entries + 1) >= num_entries) {
	        sts = om$vla_set_dimension(varray = me->num_bkp_list,
			size = me->num_bkp_entries + 1 );
	        EMomerr_hndlr(sts, ret_end, "set_dimension  error");
              }
	      me->num_bkp_list[me->num_bkp_entries-1]=0;
	      me->num_bkp_list[me->num_bkp_entries-1]++;
	      if(me->fillet_type == VARYING_TYPE && me->selection) {
	 	num_elements = om$dimension_of(varray = me->var_chain_edges);
	 	if ((me->numtmp_chain_links + 1) >= num_elements) {
            	  sts = om$vla_set_dimension(varray = me->var_chain_edges,
                             size = 1 +num_elements +me->numtmp_chain_links);
            	  EMomerr_hndlr(sts, ret_end, "set_dimension  error");
         	}
	 	numedges=me->var_chain_edges[me->numtmp_chain_links-1].numedges;
	 	me->var_chain_edges[me->numtmp_chain_links-1].numedges++;
	 	EFcreate_space_chain_edges( numedges,
		me->var_chain_edges[me->numtmp_chain_links-1].numedges,
		(GRobjid **)&me->var_chain_edges[me->numtmp_chain_links-1].edge_id);
                me->var_chain_edges[me->numtmp_chain_links-1].edge_id[numedges]=
				first_edge;
	      } /* if varying */
	      else {
         	num_elements = om$dimension_of(varray = me->tmp_located_obj);
    		if ((me->numtmped + 1) >= num_elements) {
        	  sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                  size = me->numtmped +num_elements + 1);
        	  EMomerr_hndlr(sts, ret_end, "set_dimension  error");
    		}
    		if ((me->numtmped + 1 + me->numed) >= num_elements) {
        	  sts = om$vla_set_dimension(varray = me->edgeval_event,
                              size = num_elements + 1 + me->numed+me->numtmped);
        	  EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	
           	  sts = om$vla_set_dimension(varray = me->fill_typ,
                       	     size = num_elements+ 1 + me->numed + me->numtmped);
           	  EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	  
           	  sts = om$vla_set_dimension(varray = me->bound_code,
                           size = num_elements + 1 + me->numed + me->numtmped);
           	  EMomerr_hndlr(sts, ret_end, "set_dimension  error");

        	  sts = om$vla_set_dimension(varray=me->end_edgeval_event,
                            size = num_elements + 1 + me->numed	+ me->numtmped);
        	  EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	
    		}
		me->tmp_located_obj[me->numtmped] = first_edge;
		me->edgeval_event[me->numed + me->numtmped].event.value = 
			me->active_rad;
		me->end_edgeval_event[me->numed +me->numtmped].event.value=-1.0;
                me->end_edgeval_event[me->numed+me->numtmped ].num_id= 0;
                me->edgeval_event[me->numed+me->numtmped ].num_id= 0;
		me->fill_typ[me->numed + me->numtmped] = me->fillet_type;
                me->bound_code[me->numed+me->numtmped]= 0; 
                
                if(me->numtmped == 0 || !me->radius_changed) {
                  me->bound_code[me->numed+me->numtmped]= 
                       EMSrnd_input_ed_grp_start;
                  me->radius_changed = 1;
                }
    		me->numtmped++ ;
	      } /* if !varying */
	      if(me->selection) display_mode = GRhd;
	      else display_mode = GRhe;
              mattyp =&me->ModuleInfo.md_env.matrix_type;
              mat = me->ModuleInfo.md_env.matrix;
              sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = first_edge,
                        targetos = objspc_num);
      	      EMomerr_hndlr(sts, ret_end, "EMdisplay");

	      right_vertex = TRUE;
     	      num_true = 0;
	      sts = EFgetedges(first_edge,&lft_edges,
                        right_vertex,&num_true,objspc_num);
	      temp = 0;
	      if(me->fillet_type == VARYING_TYPE && me->selection) {
	        for(i = 0; 
		  i< me->var_chain_edges[me->numtmp_chain_links-1].numedges;
		  i++) 
		  for(jj = 0; jj < num_true; jj++)
		    if(lft_edges[jj]== 
		      me->var_chain_edges[me->numtmp_chain_links-1].edge_id[i])
		      temp++;
	      } /* if varying */
	      else {
		for (i = 0; i< me->numtmped ; i++)
		  for(jj = 0; jj< num_true; jj++)
		    if(lft_edges[jj]== me->tmp_located_obj[i])
		      temp++;
	      }
	      if(temp >= 1) {
		right_vertex = FALSE;
     		num_true = 0;
                if(lft_edges)
                  {
                  om$dealloc(ptr = lft_edges);
                  lft_edges = NULL;
                  }
	        sts = EFgetedges(first_edge,&lft_edges,
                        right_vertex,&num_true,objspc_num);
	      } 
              mattyp =&me->ModuleInfo.md_env.matrix_type;
              mat = me->ModuleInfo.md_env.matrix;
	      sts = EFchkif_neutral(lft_edges,&num_true,objspc_num,
                        mat,mattyp,me->neutral_edge_angle);
              num_tmp = 0;
              nm_edges = 0;
              for(ii = 0; ii < me->numed; ii++) {
               if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
               nm_edges++;
              }
              for(ii = 0; ii < num_true; ii++) {
                if(me->fillet_type == VARYING_TYPE && me->selection)
                  sts = EFchkif_edge_valid(lft_edges[ii],
                          objspc_num,&me->active_GRid,
                          me->numtmp_chain_links,nm_edges);
                else
                  sts = EFchkif_edge_valid(lft_edges[ii],objspc_num,
                          &me->active_GRid, me->numtmped,nm_edges);
                if(!sts) {
                  num_tmp++ ; continue;
                }
                lft_edges[ii - num_tmp] = lft_edges[ii];
              }
              num_true -= num_tmp;
              if(!num_true) { to_continue = FALSE; break; }
	      numedges = num_true;

	      if(me->fillet_type == VARYING_TYPE && me->selection) {
		num_tmp = 0;
		for(i = 0; i < numedges; i++)
		  for(jj = 0; 
		    jj < me->var_chain_edges[me->numtmp_chain_links-1].numedges;
		    jj++)
		    if(lft_edges[i] == 
		      me->var_chain_edges[me->numtmp_chain_links-1].edge_id[jj])
		      num_tmp++;
		if(num_tmp) {
		  me->var_chain_edges[me->numtmp_chain_links-1].numedges--;
		  closed_chain = TRUE;
		  me->process_state = INPUT_CHAIN_RADII;
		  break;
		}
	      }
              else {
                num_tmp = 0;
                for(jj=0 ; jj < numedges ; jj++)
                for(ii =0 ; ii < me->numtmped; ii++) 
                  if(lft_edges[jj] == me->tmp_located_obj[ii])
                    num_tmp++;
                if(num_tmp) 
                  {
                  to_continue = FALSE;
                  me->process_state = IDENTIFY_CHAIN_EDGE;
                  break;
                  }
              }
              n_edges = num_true;
              if(me->fillet_type == VARYING_TYPE && me->selection) {
                temp = 0;
                for(ii = 0; ii < num_true ; ii++) {
                if(rht_edges)
                  {
                  om$dealloc(ptr = rht_edges);
                  rht_edges= NULL;
                  }
                num_tmp = 0;
                sts = EFgetchained_edges(first_edge,lft_edges[ii],
                                &rht_edges,&num_false,objspc_num);
                sts = EFchk_objid(lft_edges[ii],rht_edges,&num_false);
                for(i = 0; i < num_false; i++)
                  for(jj = 0;
                    jj < me->var_chain_edges[me->numtmp_chain_links-1].numedges;
                    jj++)
                    if(rht_edges[i] ==
                      me->var_chain_edges[me->numtmp_chain_links-1].edge_id[jj])
                      num_tmp++;
                if(num_tmp) {temp++; continue;}
                lft_edges[ii - temp] = lft_edges[ii];
                }
                num_true -= temp;
              }
              if(!num_true) {
                to_continue = FALSE;
                break;
              }
	      num_tmp = 0;
              mattyp =&me->ModuleInfo.md_env.matrix_type;
              mat = me->ModuleInfo.md_env.matrix;
              if(me->fillet_type == VARYING_TYPE && me->selection) {
                numedges = num_true;
                for(i = 0; i< me->numtmp_chain_links; i++)
                  sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                            me->var_chain_edges[i].edge_id, me->numed,
                            me->var_chain_edges[i].numedges,
                            lft_edges, objspc_num, &numedges,me->bound_code);
                tmp_ang =(IGRdouble *)stackalloc(num_true * sizeof(IGRdouble));
                num_true = numedges;
                sts = EFchk_cvcx(first_edge,lft_edges,&num_true,
                        tmp_ang,objspc_num,mat,mattyp,me->neutral_edge_angle);
		EFsortedges_by_angle(tmp_ang,lft_edges,num_true,basistol);
              } /* if varying */
              else {
                numedges = num_true;
                sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                          me->tmp_located_obj, me->numed, me->numtmped,
                          lft_edges, objspc_num, &numedges,me->bound_code);
                num_true = numedges;
                tmp_ang =(IGRdouble *)stackalloc(num_true * sizeof(IGRdouble));
                EFgetang_meas(first_edge,lft_edges,num_true,
                tmp_ang,me->ModuleInfo,basistol);

              }
	      if(num_true > 1) {
		num_tmp = 0;
		is_rightend=
		   (IGRboolean *)stackalloc(sizeof(IGRboolean)*num_true);

		for(ii = 0; ii < num_true; ii++)
		is_rightend[ii] = TRUE;
		if((tmp_ang[1] - tmp_ang[0]) < basistol) {
		  if(me->fillet_type == VARYING_TYPE && me->selection) {
		    IGRint p;
		    p =me->var_chain_edges[me->numtmp_chain_links -1].numedges;
		    if( p >= 2)
      	              EFput_edge_on_same_surface( &msg, 
		    me->var_chain_edges[me->numtmp_chain_links -1].edge_id[p-2],
                    me->var_chain_edges[me->numtmp_chain_links -1].edge_id[p-1],
			lft_edges, 2, is_rightend, objspc_num);
		  }
		  else {
		    if(me->numtmped >= 2)
      	              EFput_edge_on_same_surface( &msg, 
			me->tmp_located_obj[me->numtmped-2], 
			me->tmp_located_obj[me->numtmped-1], 
			lft_edges,2,is_rightend, objspc_num);
		  }
		}
	      }
		  
		if(!num_true) {
		  to_continue = FALSE;
	          break;
     		}
	        if(n_edges > 1) {
	          no_elig_edges = num_true;
		  elig_edges =(GRobjid *)stackalloc(sizeof(GRobjid) * num_true);
		  to_continue = TRUE;
		  for(ii = 0; ii < num_true; ii++)
		    elig_edges[ii] = lft_edges[ii];
                if(lft_edges)
                  {
                  om$dealloc(ptr = lft_edges);
                  lft_edges = NULL;
                  }
		    continue;
	       } /* n_edges > 1*/
	       

	       ind = 0;
	       tmped[ind++] = lft_edges[num_tmp];
		
	       if(me->fillet_type == VARYING_TYPE && me->selection) {
	 	 num_elements = om$dimension_of(varray = me->var_chain_edges);
	 	 if ((me->numtmp_chain_links + 1) >= num_elements) {
            	   sts = om$vla_set_dimension(varray = me->var_chain_edges,
                             size = 1 +num_elements +me->numtmp_chain_links);
            	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
         	 }
	 	 numedges=
		   me->var_chain_edges[me->numtmp_chain_links-1].numedges;
	 	 me->var_chain_edges[me->numtmp_chain_links-1].numedges++;
	 	 EFcreate_space_chain_edges( numedges,
		   me->var_chain_edges[me->numtmp_chain_links-1].numedges,
		(GRobjid **)&me->var_chain_edges[me->numtmp_chain_links-1].edge_id);
                 me->var_chain_edges[me->numtmp_chain_links-1].edge_id[numedges]= lft_edges[num_tmp];
	       } /* if varying */
					
	       else {
         	 num_elements = om$dimension_of(varray = me->tmp_located_obj);
    		 if ((me->numtmped + 1) >= num_elements) {
        	   sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                       size = me->numtmped +num_elements + 1);
        	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
    		 }
    		 if ((me->numtmped + 1 + me->numed) >= num_elements) {
        	   sts = om$vla_set_dimension(varray = me->edgeval_event,
                              size = num_elements + 1 + me->numed+me->numtmped);
        	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	
           	   sts = om$vla_set_dimension(varray = me->fill_typ,
                       	     size = num_elements+ 1 + me->numed + me->numtmped);
           	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	  
           	   sts = om$vla_set_dimension(varray = me->bound_code,
                           size = num_elements + 1 + me->numed + me->numtmped);
           	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");

        	   sts = om$vla_set_dimension(varray=me->end_edgeval_event,
                            size = num_elements + 1 + me->numed	+ me->numtmped);
        	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	
    		 }
		 me->tmp_located_obj[me->numtmped] = tmped[ind - 1];
                 me->end_edgeval_event[me->numed+me->numtmped ].num_id= 0;
                 me->edgeval_event[me->numed+me->numtmped ].num_id= 0;
		 me->edgeval_event[me->numed + me->numtmped].event.value = 
			me->active_rad;
		 me->end_edgeval_event[me->numed+me->numtmped].event.value=-1.0;
		 me->fill_typ[me->numed + me->numtmped] = me->fillet_type;
                 me->bound_code[me->numed+me->numtmped]= 0; 
                 
                 if(me->numtmped == 0 || !me->radius_changed) {
                   me->bound_code[me->numed+me->numtmped]= 
                            EMSrnd_input_ed_grp_start;
                   me->radius_changed = 1;
                 }
    		 me->numtmped++ ;
	      } /* if !varying */
              me->num_bkp_list[me->num_bkp_entries -1]++;
			
	      do {
                if(lft_edges)
                  {
                  om$dealloc(ptr = lft_edges);
                  lft_edges = NULL;
                  }
     	        sts = EFgetchained_edges(first_edge,tmped[ind -1],
		        &lft_edges,&num_true,objspc_num);
	        sts = EFchk_objid(tmped[ind - 1],lft_edges,&num_true);
                mattyp =&me->ModuleInfo.md_env.matrix_type;
                mat = me->ModuleInfo.md_env.matrix;
	        sts = EFchkif_neutral(lft_edges,&num_true,objspc_num,
                         mat,mattyp,me->neutral_edge_angle);
                if(me->selection) display_mode = GRhd;
                else display_mode = GRhe;

                sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmped[ind - 1],
                        targetos = objspc_num);
                EMomerr_hndlr(sts, ret_end, "EMdisplay");

                num_tmp = 0;
                nm_edges = 0;
                for(ii = 0; ii < me->numed; ii++) {
                 if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
                 nm_edges++;
                }
                for(ii = 0; ii < num_true; ii++) {
                  if(me->fillet_type == VARYING_TYPE && me->selection)
                    sts = EFchkif_edge_valid(lft_edges[ii],objspc_num,
                            &me->active_GRid, me->numtmp_chain_links,nm_edges);
                  else
                    sts = EFchkif_edge_valid(lft_edges[ii],objspc_num,
                            &me->active_GRid, me->numtmped,nm_edges);
                  if(!sts) {
                    num_tmp++ ; continue;
                  }
                  lft_edges[ii - num_tmp] = lft_edges[ii];

                }
                num_true -= num_tmp;
 		n_edges = num_true;

	        if(me->fillet_type == VARYING_TYPE && me->selection) {
	          num_tmp = 0;
                  for(i = 0; i< ind ; i++ )
                    for(jj = 0; jj < num_true; jj++)
                      if(lft_edges[jj] == tmped[i]) {num_tmp++;continue;}
		      else lft_edges[jj - num_tmp] =  lft_edges[jj];
	          num_true -=num_tmp;
        	  for(i = 0; 
		    i< me->var_chain_edges[me->numtmp_chain_links - 1].numedges;
                    i++)
                   for(jj = 0 ; jj < num_true; jj++)
                      if(lft_edges[jj] ==
                     me->var_chain_edges[me->numtmp_chain_links - 1].edge_id[i])
		     {
                     num_tmp++;continue;
                     }
                    else lft_edges[jj - num_tmp] = lft_edges[jj];
		    num_true -=num_tmp;

		  if(!num_true) {to_continue = FALSE; break;}
                }
                else {
                  num_tmp = 0;
                  for(jj = 0; jj < ind; jj++)
                  for(ii = 0; ii < num_true ; ii++)
                    if(lft_edges[ii] == tmped[jj]) num_tmp++;
                  for(ii = 0; ii < num_true ; ii++)
                  for(jj = 0; jj < me->numtmped; jj++)
                    if(lft_edges[ii] == me->tmp_located_obj[jj]) num_tmp++;
                  if(num_tmp) 
                    {
                    to_continue = FALSE;
                    break;
                    }
                }
	        first_edge = tmped[ind -1];
                if(me->fillet_type == VARYING_TYPE && me->selection) {
                temp = 0;
                for(ii = 0; ii < num_true ; ii++) {
                num_tmp = 0;
		num_false = 0;
                if(rht_edges)
                  { om$dealloc(ptr = rht_edges); rht_edges = NULL; }
                sts = EFgetchained_edges(first_edge,lft_edges[ii],
                                &rht_edges,&num_false,objspc_num);
                sts = EFchk_objid(lft_edges[ii],rht_edges,&num_false);
                for(i = 0; i < num_false; i++)
                  for(jj = 0;
                    jj < me->var_chain_edges[me->numtmp_chain_links-1].numedges;
                    jj++)
                    if(rht_edges[i] ==
                      me->var_chain_edges[me->numtmp_chain_links-1].edge_id[jj])
                      num_tmp++;
                if(num_tmp) {temp++; continue;}
                lft_edges[ii - temp] = lft_edges[ii];
                }
                num_true -= temp;
                }
	        num_tmp = 0;
                if(!num_true) { to_continue = FALSE; break; }
 		numedges = num_true;
                if(me->fillet_type == VARYING_TYPE && me->selection) {
                  for(i = 0; i< me->numtmp_chain_links; i++)
                    sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                            me->var_chain_edges[i].edge_id, me->numed,
                            me->var_chain_edges[i].numedges,
                            lft_edges, objspc_num, &numedges,me->bound_code);
                    num_true = numedges;
		    tmp_ang=(IGRdouble *)stackalloc(num_true*sizeof(IGRdouble));
                  mattyp =&me->ModuleInfo.md_env.matrix_type;
                  mat = me->ModuleInfo.md_env.matrix;
		  sts = EFchk_cvcx(first_edge,lft_edges,&num_true,
		        tmp_ang,objspc_num,mat,mattyp,me->neutral_edge_angle);
		  EFsortedges_by_angle(tmp_ang,lft_edges,num_true,basistol);

                } /* if varying */
                else {
                  sts = EFparse_edges(&msg, &me->selection, me->located_obj,
                          me->tmp_located_obj, me->numed, me->numtmped,
                          lft_edges, objspc_num, &numedges,me->bound_code);
                num_true = numedges;
		tmp_ang = (IGRdouble *)stackalloc(num_true * sizeof(IGRdouble));
                EFgetang_meas(first_edge,lft_edges,num_true,
                tmp_ang,me->ModuleInfo,basistol);

                 }
		if(num_true > 1) {	
                  if((tmp_ang[1] - tmp_ang[0]) < basistol) {
                    is_rightend=
                   (IGRboolean *)stackalloc(sizeof(IGRboolean)*num_true);
                   for(ii = 0; ii < num_true; ii++)
                   is_rightend[ii] = TRUE;
		    if(me->fillet_type == VARYING_TYPE && me->selection) {
                      IGRint p;
                    p =me->var_chain_edges[me->numtmp_chain_links -1].numedges;
                     if( p >= 2)
                    EFput_edge_on_same_surface( &msg,
                    me->var_chain_edges[me->numtmp_chain_links -1].edge_id[p-2],
                    me->var_chain_edges[me->numtmp_chain_links -1].edge_id[p-1],
                        lft_edges, 2, is_rightend, objspc_num);
                    }
                    else {
                      if(me->numtmped >= 2)
                        EFput_edge_on_same_surface( &msg, 
			     me->tmp_located_obj[me->numtmped-2],
			     me->tmp_located_obj[me->numtmped-1],
                             lft_edges,2,is_rightend, objspc_num);

                    }
                  }
	       }
	        if(!num_true) {
		  to_continue = FALSE;
		  break;
	        }
	        if(n_edges > 1) {
	          no_elig_edges = num_true;
                  elig_edges =(GRobjid *)stackalloc(sizeof(GRobjid) * num_true);
                  for(ii = 0; ii < num_true; ii++)
                    elig_edges[ii] = lft_edges[ii];
                  if(lft_edges)
                    {om$dealloc(ptr = lft_edges); lft_edges = NULL; }
		  to_continue = TRUE;
	          break;
		}
		

	        me->num_bkp_list[me->num_bkp_entries-1]++;
                  if((ind % ARR_SIZE) == 0)
                    {
                    tmped = (GRobjid *) om$realloc (
                                size = (ind + ARR_SIZE) * sizeof (GRobjid),
                                ptr = (IGRchar *)tmped);
                    EMerr_hndlr (!tmped,*ret_msg,EMS_E_NoDynamicMemory,ret_end);
                    }
	        if(me->fillet_type == VARYING_TYPE && me->selection) {
	          num_elements = om$dimension_of(varray = me->var_chain_edges);
	          if ((me->numtmp_chain_links + 1) >= num_elements) {
                    sts = om$vla_set_dimension(varray = me->var_chain_edges,
                          size = 1 +num_elements +me->numtmp_chain_links);
                    EMomerr_hndlr(sts, ret_end, "set_dimension  error");
                  }
	          numedges = 
                    me->var_chain_edges[me->numtmp_chain_links-1].numedges;
	          me->var_chain_edges[me->numtmp_chain_links-1].numedges++;
	          EFcreate_space_chain_edges(numedges,
	            me->var_chain_edges[me->numtmp_chain_links-1].numedges,
	            (GRobjid **)&me->var_chain_edges[me->numtmp_chain_links-1].edge_id);
	          me->var_chain_edges[me->numtmp_chain_links-1].edge_id[numedges]= lft_edges[num_tmp];
	          tmped[ind++] = lft_edges[num_tmp];
	        } /* if varying */
	        else {
                  num_elements = om$dimension_of(varray = me->tmp_located_obj);
    	          if ((me->numtmped + 1) >= num_elements) {
        	    sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                       size = me->numtmped +num_elements + 1);
        	    EMomerr_hndlr(sts, ret_end, "set_dimension  error");
                  }
       	          if ((me->numtmped + 1 + me->numed) >= num_elements) {
       		    sts = om$vla_set_dimension(varray = me->fill_typ,
               	           size = num_elements + 1 + me->numed + me->numtmped);
       		    EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	  
       		    sts = om$vla_set_dimension(varray = me->bound_code,
                       	   size = num_elements + 1 + me->numed + me->numtmped);
       		    EMomerr_hndlr(sts, ret_end, "set_dimension  error");

       		    sts = om$vla_set_dimension(varray=me->end_edgeval_event,
                           size = num_elements + 1 + me->numed+ me->numtmped);
        	    EMomerr_hndlr(sts, ret_end, "set_dimension  error");

        	    sts = om$vla_set_dimension(varray = me->edgeval_event,
                            size = num_elements + 1 + me->numed+ me->numtmped);
        	    EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	
    	          }
	          tmped[ind++] = lft_edges[num_tmp];
	          me->tmp_located_obj[me->numtmped] = tmped[ind - 1];
                  me->end_edgeval_event[me->numed+me->numtmped ].num_id= 0;
                  me->edgeval_event[me->numed+me->numtmped ].num_id= 0;
	          me->edgeval_event[me->numed+me->numtmped].event.value = me->active_rad;
	          me->end_edgeval_event[me->numed + me->numtmped].event.value = -1.0;
	          me->fill_typ[me->numed + me->numtmped] = me->fillet_type;
                  me->bound_code[me->numed+me->numtmped]= 0; 
                  
                  if(me->numtmped == 0 || !me->radius_changed) {
                    me->bound_code[me->numed+me->numtmped]= 
                        EMSrnd_input_ed_grp_start;
                    me->radius_changed = 1;
                  }
    	          me->numtmped++ ;
 me->numround[edge_count]++;
 me->group_edge_info[object_count].group_id = edge_count ;
object_count++;
	        }

	      } while (TRUE);


	      numedges = ind;
	      if(!numedges || closed_chain) {
		break;
	      }
	      if(me->selection) display_mode = GRhd;
                else display_mode = GRhe;
              mattyp =&me->ModuleInfo.md_env.matrix_type;
              mat = me->ModuleInfo.md_env.matrix;
              for(i = 0; i < numedges; i++) {
                sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmped[i],
                        targetos = objspc_num);
                EMomerr_hndlr(sts, ret_end, "EMdisplay");
              }
	      if(to_continue) continue;
	      else break;

	}  /* of resp ex_data */
	if(resp == EX_RJT_MOVEON) {
	  if(me->fillet_type == VARYING_TYPE) {
              if(me->selection)
                me->process_state = INPUT_CHAIN_RADII;
              else
                me->process_state = IDENTIFY_CHAIN_EDGE;
          }
          else
            me->process_state = IDENTIFY_CHAIN_EDGE;
	  break;
	}

      } /*for looop  */
      if(lft_edges)
        {
        om$dealloc(ptr = lft_edges);
        lft_edges = NULL;
        }
      if(rht_edges)
        {
        om$dealloc(ptr = rht_edges);
        rht_edges = NULL;
        }
	

     break;
    }

     case INPUT_CHAIN_RADII:
      {
	int i,j,ii;
	IGRint start_val=0;
	IGRchar inp_buff[52];
	IGRlong event_mask;
	IGRshort disp_flag;
     	IGRlong EFgetpnt();
	IGRdouble *rad_val;
	IGRlong ret_sts =0;

	for(i = 0; i < me->numtmp_chain_links; i++) {
	    if(me->var_chain_edges[i].chain_var_start.event.value < 0.0) {
		numedges = me->var_chain_edges[i].numedges;
		ii = 0;
	        for(j = 0; j < 2; j++) 
		{
		    temp_rad=me->active_rad;
		    roundn(&temp_rad,3);
		    if(j == 0) 
		    { 
       		    ex$message(msgnumb = EMS_P_EntStartingRad, type = "%.3g",
			var = `temp_rad`, buff = inp_buff);
		    ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS, 
			in_buff = inp_buff);
			if(numedges == 1) disp_flag = EMS_EDGE_BEG_PT;
			else {	
		    	start_val = 0;
                	ret_sts = EFgetpnt(me->var_chain_edges[i].edge_id[0],
				me->var_chain_edges[i].edge_id[1],
                                ME.COroot->ModuleInfo,&start_val);

                	if(start_val)   disp_flag = EMS_EDGE_END_PT;
                	else   disp_flag = EMS_EDGE_BEG_PT;
			ii = 0;
			}
		    }
		    else 
		    { 
       		    ex$message(msgnumb = EMS_P_EntEndingRad, type = "%.3g",
			var = `temp_rad`, buff = inp_buff);
		    ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS, 
			in_buff = inp_buff);
			if(numedges == 1) disp_flag = EMS_EDGE_END_PT;
			else {
                	ret_sts = 
			EFgetpnt(me->var_chain_edges[i].edge_id[numedges-1],
				me->var_chain_edges[i].edge_id[numedges -2],
                                ME.COroot->ModuleInfo,&start_val);
			if(start_val)   disp_flag = EMS_EDGE_END_PT;
                	else  disp_flag = EMS_EDGE_BEG_PT;
			ii = me->var_chain_edges[i].numedges - 1;
			}
		    }

            	    display_mode = GRhd ;
            	    sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        	&ME.COroot->ModuleInfo.md_env.matrix_type,
                        	ME.COroot->ModuleInfo.md_env.matrix,
                        	&display_mode,NULL,
                        	disp_flag, NULL),
               		targetid = me->var_chain_edges[i].edge_id[ii],
               		targetos = objspc_num );

            	    EMerr_hndlr (!(1 & sts), msg, EMS_E_Fail,ret_end);

		    event_mask = GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP 
				 | GRm_DATA;

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
	    	    /* The user changes the radius*/ 
	    	      case EX_VALUE:
	    		if(me->event.event.value < 0)  {
	    		    ex$message(msgnumb = EMS_S_InvInp)
			    sleep(2);
	     		    break;
	    		}
	    		else {
			    me->active_rad = me->event.event.value;
			    if(j == 0)  
			        me->var_chain_edges[i].chain_var_start = 
					me->event;
			    else 
			    	me->var_chain_edges[i].chain_var_end = 
					me->event;

            		    display_mode = GRhe ;
            		    sts = om$send(msg = message EMSedge.EMdisplay(&msg, 
				NULL, &ME.COroot->ModuleInfo.md_env.matrix_type,
                        	ME.COroot->ModuleInfo.md_env.matrix,
                        	&display_mode,NULL, disp_flag, NULL),
               		    targetid = me->var_chain_edges[i].edge_id[ii],
               		    targetos = objspc_num );
            		    EMerr_hndlr(!(1 & sts), msg, EMS_E_Fail,ret_end);
	    	    	}
			break;

	    		/* The user takes the default radius */
	    	      case EX_RJT_MOVEON:
			if(j == 0) 
          		    me->var_chain_edges[i].chain_var_start.event.value =
				me->active_rad;
		        else 
          		    me->var_chain_edges[i].chain_var_end.event.value =
				me->active_rad;
            		display_mode = GRhe ;
            		sts = om$send(msg = message EMSedge.EMdisplay(&msg, 
				NULL, &ME.COroot->ModuleInfo.md_env.matrix_type,
                        	ME.COroot->ModuleInfo.md_env.matrix,
                        	&display_mode,NULL, disp_flag, NULL),
               		    targetid = me->var_chain_edges[i].edge_id[ii],
               		    targetos = objspc_num );

            		EMerr_hndlr(!(1 & sts), msg, EMS_E_Fail,ret_end);

			break;

	    	      case EX_BACK_UP:
		      case EX_DATA:
			   j = -1;
			   display_mode = GRhe ;
                        sts = om$send(msg = message EMSedge.EMdisplay(&msg,
                                NULL, &ME.COroot->ModuleInfo.md_env.matrix_type,
                                ME.COroot->ModuleInfo.md_env.matrix,
                                &display_mode,NULL, disp_flag, NULL),
                            targetid = me->var_chain_edges[i].edge_id[ii],
                            targetos = objspc_num );

                        EMerr_hndlr(!(1 & sts), msg, EMS_E_Fail,ret_end);

	        	break;

	    	      default:
		       display_mode = GRhe ;
          	       me->var_chain_edges[i].chain_var_start.event.value=-1.0;
                       sts = om$send(msg = message EMSedge.EMdisplay(&msg,
                                NULL, &ME.COroot->ModuleInfo.md_env.matrix_type,
                                ME.COroot->ModuleInfo.md_env.matrix,
                                &display_mode,NULL, disp_flag, NULL),
                            targetid = me->var_chain_edges[i].edge_id[ii],
                            targetos = objspc_num );

                        EMerr_hndlr(!(1 & sts), msg, EMS_E_Fail,ret_end);

			if(*response == CLEAR_STACK || *response == TERMINATE) goto ret_end;
			if(*response == EX_CMD_KEY) {
                           me->valid_inputdata = FALSE;
                            me->process_state = INPUT_CHAIN_RADII;
                            j--;
                           goto ret_end;
                        }
			if(*response == STATUS_DISP) {
			   me->process_state = INPUT_CHAIN_RADII;
                           j--;
			   goto ret_end;
			}
		    } /* switch  */
      		}
	numedges = me->var_chain_edges[me->numtmp_chain_links-1].numedges;
	rad_val = (IGRdouble *)stackalloc(sizeof(IGRdouble) * (1+numedges));
	if(numedges ==  1) {
		rad_val[0] = 
		me->var_chain_edges[me->numtmp_chain_links-1].chain_var_start.event.value;
		rad_val[1] = 
		me->var_chain_edges[me->numtmp_chain_links-1].chain_var_end.event.value;
	}
	else {
	sts = EFchain_edge_rad_comp(&msg, ME.COroot->ModuleInfo, numedges,
		me->var_chain_edges[me->numtmp_chain_links-1].edge_id , rad_val,
		me->var_chain_edges[me->numtmp_chain_links-1].chain_var_start.event.value,
		me->var_chain_edges[me->numtmp_chain_links-1].chain_var_end.event.value);
	}

         num_elements = om$dimension_of(varray = me->tmp_located_obj);
         if ((num_elements + numedges ) >= num_elements) {
           	sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                         size = numedges+ num_elements);
           	EMomerr_hndlr(sts, ret_end, "set_dimension  error");
    	 }
         if ((num_elements + numedges + me->numed) >= num_elements) {
           	sts = om$vla_set_dimension(varray = me->edgeval_event,
                           size = num_elements + me->numed + numedges);
           	EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           	sts = om$vla_set_dimension(varray = me->fill_typ,
                       size = num_elements + me->numed + numedges);
         	  EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	  
           	sts = om$vla_set_dimension(varray = me->bound_code,
                       size = num_elements + me->numed + numedges);
           	EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           	sts = om$vla_set_dimension(varray = me->end_edgeval_event,
                       size = num_elements + me->numed + numedges);
           	EMomerr_hndlr(sts, ret_end, "set_dimension  error");
       	}
	num_elements = 0;
	if(me->numtmp_chain_links >= 2) {
	for(i = 0; i< me->numtmp_chain_links -1;i++)
		num_elements += me->var_chain_edges[i].numedges;
	}
	me->numtmped += numedges;
        
	for(i=0;i < numedges;i++) {
		me->tmp_located_obj[ num_elements + i] = 
		me->var_chain_edges[me->numtmp_chain_links -1].edge_id[i];
		me->edgeval_event[me->numed + num_elements + i]=
		me->var_chain_edges[me->numtmp_chain_links -1].chain_var_start;
		me->edgeval_event[me->numed + num_elements + i].event.value =
			rad_val[i];
		me->end_edgeval_event[me->numed + num_elements + i]=
		me->var_chain_edges[me->numtmp_chain_links -1].chain_var_end;
		me->end_edgeval_event[me->numed + num_elements + i].event.value=
			rad_val[i + 1];
                me->end_edgeval_event[me->numed+num_elements + i].num_id= 0;
                me->edgeval_event[me->numed+num_elements + i].num_id= 0;
		me->fill_typ[me->numed + num_elements + i]= me->fillet_type;
                me->bound_code[me->numed+num_elements+i]= 0;
	   }
        me->bound_code[me->numed+num_elements]= EMSrnd_input_ed_grp_start;
      	  }
    	}
	me->process_state = IDENTIFY_CHAIN_EDGE;
	
     break;               
      }

  default:
     goto ret_end;
    } /* me->process_state */
  }

 while( TRUE);

 ret_end:

  if(tmped) 
    {
    om$dealloc(ptr = tmped);
    tmped = NULL;
    }
  if(!edge_locatable)
   EFset_locate_eligibility(&msg,0,"EMSedge");

  return(sts);
}


IGRlong EFang_between_2edges(msg, module_info, start_id, end_id, angle)
IGRlong *msg;
struct GRmd_env module_info;
GRobjid start_id, end_id;
IGRdouble angle[3];
{
  IGRlong   sts, rc, msg_loc;
  struct IGRbsp_curve         curve1, curve2;
  IGRint i;
  IGRdouble pars1, pars2;
  IGRvector vec1, vec2;
  IGRpoint pts1[1][2], pts2[1][2];
  IGRint numpars = 1;
  IGRpoint st_pt1, end_pt1, st_pt2, end_pt2;
  IGRboolean st1_flag, end1_flag, st2_flag, end2_flag;
  IGRdouble dist1;
  IGRdouble dottol = 0.000001;
  IGRboolean  stat_func;

  st1_flag = end1_flag = st2_flag = end2_flag = FALSE;

  sts = OM_S_SUCCESS;
  *msg = EMS_S_Success;

   curve1.poles = NULL;
   curve1.knots = NULL;
   curve1.weights = NULL;
   curve1.bdrys = NULL;
                
   sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(
                &msg_loc, &module_info.md_env, NULL, NULL, 0, MAXINT, 
		FALSE, NULL, &curve1),
           senderid = NULL_OBJID,
           targetid = start_id,
           targetos = module_info.md_id.osnum);
   EMomerr_hndlr (sts, ret_end, "EMget_bcxyz_geom");

   curve2.poles = NULL;
   curve2.knots = NULL;
   curve2.weights = NULL;
   curve2.bdrys = NULL;

   sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(
                &msg_loc, &module_info.md_env, NULL, NULL, 0, MAXINT, 
		FALSE, NULL, &curve2),
           senderid = NULL_OBJID,
           targetid = end_id,
           targetos = module_info.md_id.osnum);
   EMomerr_hndlr (sts, ret_end, "EMget_bcxyz_geom");

  OM_BLOCK_MOVE(&curve1.poles[0], st_pt1, sizeof(IGRpoint));
  end_pt1[0] = curve1.poles[3 * (curve1.num_poles -1)];
  end_pt1[1] = curve1.poles[3 * (curve1.num_poles -1) + 1];
  end_pt1[2] = curve1.poles[3 * (curve1.num_poles -1) + 2];

  OM_BLOCK_MOVE(&curve2.poles[0], st_pt2, sizeof(IGRpoint));
  end_pt2[0] = curve2.poles[3 * (curve2.num_poles -1)];
  end_pt2[1] = curve2.poles[3 * (curve2.num_poles -1) + 1];
  end_pt2[2] = curve2.poles[3 * (curve2.num_poles -1) + 2];

  dist1 = BSdistptpt(&msg_loc, st_pt1, st_pt2);
  if((dist1 - dottol) <= 0.0) {
	st1_flag = TRUE;	
	st2_flag = TRUE;	
  }

  dist1 = BSdistptpt(&msg_loc, st_pt1, end_pt2);
  if((dist1 - dottol) <= 0.0) {
	st1_flag = TRUE;	
	end2_flag = TRUE;	
  }

  dist1 = BSdistptpt(&msg_loc, end_pt1, st_pt2);
  if((dist1 - dottol) <= 0.0) {
	end1_flag = TRUE;	
	st2_flag = TRUE;	
  }

  dist1 = BSdistptpt(&msg_loc, end_pt1, end_pt2);
  if((dist1 - dottol) <= 0.0) {
	end1_flag = TRUE;	
	end2_flag = TRUE;	
  }

  if(curve1.order == 2) {
   vec1[0] = curve1.poles[3] - curve1.poles[0];
   vec1[1] = curve1.poles[4] - curve1.poles[1];
   vec1[2] = curve1.poles[5] - curve1.poles[2];
  }
  else {
     if(st1_flag) pars1 = 0.0;
     else pars1 = 1.0;

     BScvarrevt(&curve1, &pars1, numpars, 1.0, pts1, &rc);

     for(i = 0; i < 3; i++) 
	vec1[i] = pts1[0][1][i] - pts1[0][0][i];

      BSnorvec(&rc, vec1);
  }

  if(curve2.order == 2) {
   vec2[0] = curve2.poles[3] - curve2.poles[0];
   vec2[1] = curve2.poles[4] - curve2.poles[1];
   vec2[2] = curve2.poles[5] - curve2.poles[2];
  }
  else {
     if(st2_flag) pars2 = 0.0;
     else pars2 = 1.0;

     BScvarrevt(&curve2, &pars2, numpars, 1.0, pts2, &rc);
     for(i = 0; i < 3; i++) 
	vec2[i] = pts2[0][1][i] - pts2[0][0][i];

      BSnorvec(&rc, vec2);
  }
  if(!((st1_flag && st2_flag) || (end1_flag && end2_flag)))
    for(i = 0; i < 3; i++)
      vec2[i] *=-1;
  stat_func =  MAang2vc(&rc, vec1, vec2, angle);
  if (!stat_func) goto ret_end;

  /*
   * We always want the smallest angle between the edges.
   * So if angle is > 180, then angle is 360 - angle.
   */
  if(angle[0] > M_PI) 
   angle[0] = 2*M_PI - angle[0];

ret_end:
   if(curve1.poles)	om$dealloc(ptr = curve1.poles);
   if(curve1.knots)	om$dealloc(ptr = curve1.knots);
   if(curve1.rational == TRUE && curve1.poles)	
	om$dealloc(ptr = curve1.weights);
   if(curve2.poles)	om$dealloc(ptr = curve2.poles);
   if(curve2.knots)	om$dealloc(ptr = curve2.knots);
   if(curve2.rational == TRUE && curve1.poles)	
	om$dealloc(ptr = curve2.weights);

   EMWRAPUP(*msg, sts, "EMS_angle_2_edges ");
   return (sts);
}

IGRlong EFchk_objid(chk_edge,edge_lst,num_edge)
GRobjid chk_edge;
GRobjid *edge_lst;
int *num_edge;
{
	
	IGRint i,num_tmp =0;
	for(i = 0; i < *num_edge; i++) {
      		if(IF_EQ_OBJID(chk_edge, edge_lst[i])) {
			num_tmp++;
			continue;
		}
		edge_lst[i - num_tmp] = edge_lst[i];
	}
	*num_edge -= num_tmp;
	return(TRUE);
}

  
IGRlong EFchkang_bet_edges(chk_edge,edge_lst,num_edge,module_info)
GRobjid chk_edge;
GRobjid *edge_lst;
IGRint *num_edge;
struct GRmd_env module_info;
{
	IGRint i, num_tmp = 0;
	IGRlong EFang_between_2edges();
	IGRdouble angle[3],basistol;
	IGRlong msg,sts = 1;
      
        BSEXTRACTPAR(&msg, BSTOLBASIS, basistol);
	for(i = 0; i < *num_edge; i++) {
		sts = EFang_between_2edges(&msg, module_info,
			chk_edge, edge_lst[i], angle);

                if(ABS(angle[2]- 1.0) < basistol) {
			edge_lst[i - num_tmp] = edge_lst[i];
		}
		else {
			num_tmp++;
			continue;
		}
	}
	*num_edge -= num_tmp;
	return(sts);
}

IGRlong EFchkif_neutral(edg_lst,num_edge,objspc_num,mat,mattyp,userang)
GRobjid *edg_lst;
IGRint  *num_edge;
OMuword objspc_num;
IGRdouble *mat;
IGRshort *mattyp;
IGRdouble userang;
{
	IGRint i,sts=0,num_tmp=0;
        IGRboolean is_convex,is_neutral,is_neut;
        IGRdouble angmeas;
        IGRlong msg;
        void EFcheck_if_neutral();
	for(i = 0; i< *num_edge; i++) {
                sts = om$send(msg = message EMSedge.EMchkconvex(&msg, NULL,
                        mattyp, mat, EMS_ZEROANGLE_DEG_MAX, &is_convex,
                        &is_neutral, &angmeas),
                        senderid = NULL_OBJID,
                        targetid = edg_lst[i],
                        targetos = objspc_num);

            /* Check if it's within the user defined neutral edge angle */
                EFcheck_if_neutral(angmeas, userang, &is_neut);

                if(is_neutral || is_neut)
                        num_tmp++;
                else {
                        edg_lst[i - num_tmp] = edg_lst[i];
                }
        }
        *num_edge -= num_tmp;
        return(TRUE);

}

void EFgetang_meas(first_edge,edg_lst,num_edge,angs,md_info,basistol)
GRobjid first_edge;
GRobjid *edg_lst;
IGRint  num_edge;
IGRdouble *angs;
struct GRmd_env md_info;
IGRdouble basistol;
{
	IGRint temp_ind,ii,s_ind,d_ind;
        IGRdouble ang,angmeas[3],*d_ang,*s_ang;
        IGRlong msg,sts=0;
        extern IGRlong EFang_between_2edges();
        extern void EFsortedges_by_angle();
        GRobjid *sed_lst,*ded_lst;
        IGRboolean is_convex,edge_convex,is_neutral;

        sts = om$send(msg = message EMSedge.EMchkconvex(&msg, NULL,
                        &md_info.md_env.matrix_type, 
                        md_info.md_env.matrix, EMS_ZEROANGLE_DEG_MAX, 
                        &edge_convex,&is_neutral, &ang),
                senderid = NULL_OBJID,
                targetid = first_edge,
                targetos = md_info.md_id.osnum);
         s_ind = d_ind = 0;
         sed_lst = (GRobjid *)stackalloc(sizeof(GRobjid) * num_edge);
         ded_lst = (GRobjid *)stackalloc(sizeof(GRobjid) * num_edge);
         s_ang   = (IGRdouble *)stackalloc(sizeof(IGRdouble) * num_edge);
         d_ang   = (IGRdouble *)stackalloc(sizeof(IGRdouble) * num_edge);
         for(ii = 0 ; ii < num_edge; ii++)
           {
           sts = om$send(msg = message EMSedge.EMchkconvex(&msg, NULL,
                        &md_info.md_env.matrix_type, 
                        md_info.md_env.matrix, EMS_ZEROANGLE_DEG_MAX, &is_convex,
                        &is_neutral, &ang),
                        senderid = NULL_OBJID,
                        targetid = edg_lst[ii],
                        targetos = md_info.md_id.osnum);

           EFang_between_2edges(&msg, md_info, 
                        first_edge, edg_lst[ii], angmeas);
           if(edge_convex == is_convex )
             {
             s_ang[s_ind] = angmeas[0]; 
             sed_lst[s_ind++] = edg_lst[ii];
             }
           else
             {
             d_ang[d_ind] = angmeas[0];
             ded_lst[d_ind++] = edg_lst[ii];
             }
           }
	  EFsortedges_by_angle(s_ang,sed_lst,s_ind,basistol);
	  EFsortedges_by_angle(d_ang,ded_lst,d_ind,basistol);
          for(ii = 0 ; ii < s_ind; ii++)
            {
            edg_lst[ii] = sed_lst[ii];
            angs[ii]    = s_ang[ii];
            } 
          temp_ind = 0;
          for(ii = s_ind; ii < num_edge; ii++)
            {
            edg_lst[ii] = ded_lst[temp_ind];
            angs[ii]    = d_ang[temp_ind++];
            } 
}

IGRlong EFchk_cvcx(chk_edge,edg_lst,num_edge,angs,objspc_num,mat,mattyp,userang)
GRobjid chk_edge;
GRobjid *edg_lst;
IGRint  *num_edge;
IGRdouble *angs;
OMuword objspc_num;
IGRdouble *mat;
IGRshort *mattyp;
IGRdouble userang;
{
	IGRint i,sts=0,num_tmp=0;
	IGRboolean edge_convex,is_convex,is_neutral,is_neut;
	IGRdouble angmeas;
	IGRlong msg;
	void EFcheck_if_neutral();

	sts = om$send(msg = message EMSedge.EMchkconvex(&msg, NULL,
                        mattyp, mat, EMS_ZEROANGLE_DEG_MAX, &edge_convex,
                        &is_neutral, &angmeas),
               	senderid = NULL_OBJID,
               	targetid = chk_edge,
               	targetos = objspc_num);
	for(i = 0; i< *num_edge; i++) {
		sts = om$send(msg = message EMSedge.EMchkconvex(&msg, NULL,
                        mattyp, mat, EMS_ZEROANGLE_DEG_MAX, &is_convex,
                        &is_neutral, &angmeas),
                	senderid = NULL_OBJID,
                	targetid = edg_lst[i],
                	targetos = objspc_num);
		
            /* Check if it's within the user defined neutral edge angle */
                EFcheck_if_neutral(angmeas, userang, &is_neut);

		if(edge_convex != is_convex  || is_neutral || is_neut)
        		num_tmp++;
		else {
			edg_lst[i - num_tmp] = edg_lst[i];	
			angs[i - num_tmp] = angmeas;
		}
	}
	*num_edge -= num_tmp;
	return(TRUE);

}

IGRlong EFchain_edge_rad_comp(msg, module_info, numedges, edge_list, 
	rad_val,start_rad,end_rad )
IGRlong *msg;
struct GRmd_env module_info;
IGRint numedges;
GRobjid edge_list[];
IGRdouble rad_val[];
IGRdouble start_rad, end_rad;
{
  	IGRlong   sts,  msg_loc;
  	IGRint i;
  	IGRdouble tot_len = .0;
	IGRdouble *edge_len;
	IGRint sign = 1;

  	sts = OM_S_SUCCESS;
  	*msg = EMS_S_Success;


	if(start_rad > end_rad)
		sign = -1;

	edge_len = (IGRdouble *) alloca(numedges * sizeof(IGRdouble));

	for(i = 0; i < numedges; i++) {
		sts = om$send(msg = message EMSedge.EMget_edge_length(&msg_loc,
				(IGRushort) 0, &module_info.md_env,
				NULL, NULL, NULL,
				&edge_len[i]),
			senderid = NULL_OBJID,
			targetid = edge_list[i],
           		targetos = module_info.md_id.osnum);
   		EMerr_hndlr(!(1 & sts &msg_loc), *msg, EMS_E_EdgeError, 
			wrapup); 
		tot_len += edge_len[i];
	}

	rad_val[0] = start_rad;
	rad_val[numedges] = end_rad;
	for(i = 1; i < numedges; i++) {
		rad_val[i] = rad_val[i - 1] + (sign * 
			((fabs(end_rad - start_rad) * edge_len[i-1])/tot_len)); 
	}
	

wrapup:
   	return (sts);
}

IGRlong EFcreate_space_chain_edges(arr_size,num,ret_ptr)
IGRint arr_size;
IGRint num;
GRobjid **ret_ptr;
{

           if(arr_size == 0) 
             {
                  /* alloc */
             if(!(*ret_ptr = (GRobjid *)malloc(sizeof(GRobjid) * num )))
			return(0);
	     }
           else
               if(!(*ret_ptr = (GRobjid *)realloc(*ret_ptr,
                              num*sizeof(GRobjid))))
		 return(0);
	   return(1);
}
        
IGRlong EFgetpnt(st_ed1,st_ed2,mod_info,ret_val)
GRobjid st_ed1;
GRobjid st_ed2;
struct GRmd_env mod_info;
IGRint *ret_val;
{

  IGRlong   ret_sts,msg,sts,msg_loc;
  struct IGRbsp_curve         curve1, curve2;
  IGRpoint st_pt1, end_pt1, st_pt2, end_pt2;
  IGRdouble dist1;
  IGRdouble dottol = 0.000001;


  sts = OM_S_SUCCESS;
  ret_sts = 0;

   curve1.poles = NULL;
   curve1.knots = NULL;
   curve1.weights = NULL;
   curve1.bdrys = NULL;
                
   sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(
                &msg, &mod_info.md_env, NULL, NULL, 0, MAXINT, 
		FALSE, NULL, &curve1),
           senderid = NULL_OBJID,
           targetid = st_ed1,
           targetos = mod_info.md_id.osnum);
   EMomerr_hndlr (sts, ret_end, "EMget_bcxyz_geom");

   curve2.poles = NULL;
   curve2.knots = NULL;
   curve2.weights = NULL;
   curve2.bdrys = NULL;

   sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(
                &msg, &mod_info.md_env, NULL, NULL, 0, MAXINT, 
		FALSE, NULL, &curve2),
           senderid = NULL_OBJID,
           targetid = st_ed2,
           targetos = mod_info.md_id.osnum);
   EMomerr_hndlr (sts, ret_end, "EMget_bcxyz_geom");

  OM_BLOCK_MOVE(&curve1.poles[0], st_pt1, sizeof(IGRpoint));
  end_pt1[0] = curve1.poles[3 * (curve1.num_poles -1)];
  end_pt1[1] = curve1.poles[3 * (curve1.num_poles -1) + 1];
  end_pt1[2] = curve1.poles[3 * (curve1.num_poles -1) + 2];

  OM_BLOCK_MOVE(&curve2.poles[0], st_pt2, sizeof(IGRpoint));
  end_pt2[0] = curve2.poles[3 * (curve2.num_poles -1)];
  end_pt2[1] = curve2.poles[3 * (curve2.num_poles -1) + 1];
  end_pt2[2] = curve2.poles[3 * (curve2.num_poles -1) + 2];


  dist1 = BSdistptpt(&msg_loc, st_pt1, end_pt2);
  if((dist1 - dottol) <= 0.0) {
	*ret_val = 1;	
  	ret_sts = 1;
  }

  dist1 = BSdistptpt(&msg_loc, st_pt1, st_pt2);
  if((dist1 - dottol) <= 0.0) {
	*ret_val = 1;	
  	ret_sts = 0;
  }
  dist1 = BSdistptpt(&msg_loc, end_pt1, st_pt2);
  if((dist1 - dottol) <= 0.0) {
	*ret_val = 0;	
  	ret_sts = 1;
  }
  dist1 = BSdistptpt(&msg_loc, end_pt1, end_pt2);
  if((dist1 - dottol) <= 0.0) {
	*ret_val = 0;	
  	ret_sts = 0;
  }
ret_end:
   if(curve1.poles)     om$dealloc(ptr = curve1.poles);
   if(curve1.knots)     om$dealloc(ptr = curve1.knots);
   if(curve1.rational == TRUE && curve1.poles)
        om$dealloc(ptr = curve1.weights);
   if(curve2.poles)     om$dealloc(ptr = curve2.poles);
   if(curve2.knots)     om$dealloc(ptr = curve2.knots);
   if(curve2.rational == TRUE && curve1.poles)
        om$dealloc(ptr = curve2.weights);

  return(ret_sts);

}

IGRlong EFgetedges(first_edge,lft_edge,right_vertex,num_true,objspc_num)
GRobjid first_edge;
GRobjid **lft_edge;
IGRboolean right_vertex;
IGRint *num_true;
OMuword objspc_num;
{

     IGRint num_buff;
     IGRboolean *is_rightend;
     IGRushort edge_options=0;
     GRobjid *lft_edges=NULL;
     IGRlong msg,sts;
     IGRint i,j;
     IGRlong EFchk_objid();

     i=0;msg = 1;
     num_buff = 10;
     is_rightend=NULL;
     edge_options = EMSvtxedges_nodegenerate | EMSvtxedges_onlydominant |
                    EMSvtxedges_noseamedge | EMSvtxedges_notangent |
                    EMSvtxedges_onlycommon;

     sts = om$send(msg = message  EMSedge.EMgetvtxedges(&msg, 
                          edge_options, right_vertex,
                          num_buff, &i, &lft_edges,
                          &is_rightend), 
		   senderid = NULL_OBJID,
                   targetid = first_edge,
                   targetos = objspc_num);
     EMomerr_hndlr ( sts, ret_end, "EMgetvtxedges"); 



	sts = EFchk_objid(first_edge,lft_edges,&i);

	(*lft_edge) = (GRobjid *)om$malloc(size = sizeof(GRobjid) * i);
	for(j = 0 ; j<i ; j++) {
		(*lft_edge)[j] = lft_edges[j];
	}

ret_end:
  if(lft_edges)
    {
    om$dealloc(ptr = lft_edges);
    lft_edges = NULL;
    }
  if(is_rightend)
    {
    om$dealloc(ptr = is_rightend);
    is_rightend = NULL;
    }
	*num_true = i;
	return(sts);

}

IGRlong EFgetchained_edges(first_edge,act_edge,lft_edge,
			num_true,objspc_num)
GRobjid first_edge;
GRobjid act_edge;
GRobjid **lft_edge;
IGRint *num_true;
OMuword objspc_num;
{
     IGRint num_buff;
     IGRboolean *is_rightend,found;
	IGRboolean right_vertex;
     IGRushort edge_options=0;
     GRobjid *lft_edges;
     IGRlong msg,sts;
     IGRint i,j;
     is_rightend=NULL;
     num_buff = 10;
     *num_true =0;
     right_vertex = TRUE;
     edge_options = EMSvtxedges_nodegenerate | EMSvtxedges_onlydominant |
                    EMSvtxedges_noseamedge | EMSvtxedges_notangent |
                    EMSvtxedges_onlycommon;

     sts = om$send(msg = message  EMSedge.EMgetvtxedges(&msg, 
                          edge_options, right_vertex,
                          num_buff, num_true, &lft_edges,
                          &is_rightend), 
		   senderid = NULL_OBJID,
                   targetid = act_edge,
                   targetos = objspc_num );
     	EMomerr_hndlr ( sts, ret_end, "EMgetvtxedges"); 
	found = FALSE;
	for(i=0 ; i < *num_true ; i++) {
		if(first_edge == lft_edges[i]) {
			found = TRUE;
			break;
		}
	}
	if(found) {
               if(lft_edges)
                 {
                 om$dealloc(ptr = lft_edges);
                 lft_edges = NULL;
                 }
               if(is_rightend)
                 {
                 om$dealloc(ptr = is_rightend);
                 is_rightend = NULL;
                 }
		right_vertex = FALSE;
     		is_rightend=NULL;
		num_buff = 10;
		*num_true =0;
    		sts = om$send(msg = message  EMSedge.EMgetvtxedges(&msg, 
                          edge_options, right_vertex,
                          num_buff, num_true, &lft_edges,
                          &is_rightend), 
		   senderid = NULL_OBJID,
                   targetid = act_edge,
                   targetos = objspc_num );
     		EMomerr_hndlr ( sts, ret_end, "EMgetvtxedges"); 
	}
	(*lft_edge) = (GRobjid *)om$malloc(size = sizeof(GRobjid) *(*num_true));
        for(j = 0 ; j< *num_true ; j++) {
                (*lft_edge)[j] = lft_edges[j];
        }

ret_end:
  if(lft_edges)
    {
    om$dealloc(ptr = lft_edges);
    lft_edges = NULL;
    }
  if(is_rightend)
    {
    om$dealloc(ptr = is_rightend);
    is_rightend = NULL;
    }
        return(sts);
}

void EFsortedges_by_angle(tmp_ang,lft_edges,num_true,basistol)
IGRdouble *tmp_ang;
GRobjid *lft_edges;
IGRint num_true;
IGRdouble basistol;
{
  IGRint ii,jj;
  IGRdouble temp1;
  GRobjid tmp_edge;

  for(ii = 0;ii < num_true ; ii++) {
   for (jj=ii+1;jj < num_true ;jj++)
     if(tmp_ang[jj] - tmp_ang[ii] < basistol) {
       temp1 = tmp_ang[ii];
       tmp_ang[ii] = tmp_ang[jj];
       tmp_ang[jj] = temp1;
       tmp_edge = lft_edges[ii];
       lft_edges[ii] = lft_edges[jj];
       lft_edges[jj] = tmp_edge;
     }
  }
}



end implementation ECsfedloc;
