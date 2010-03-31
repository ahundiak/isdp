class implementation ECsfedloc;

/*
DESCRIPTION
	This method locates edges using the single edge/vertex option.
	If the varying radius is set then the user is required to input the
	start & end radius for an edge.

OPTIONS
	No options supported

ALGORITHM
	First we try to locate a vertex & if no vertex is found then the
	edge within the range is picked up. 

HISTORY
 	Tapadia  12/29/92 Written for Phoenix rounding interface.
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
#include "EMSmsgdef.h"
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
#include "bsdistptli.h"

#define FALSE 0
#define TRUE 1

#define IDENTIFY_EDGE 		0 
#define ACCEPT_NXT_EDGE 	1 
#define IDENTIFY_EDGE_RADII 	2 
#define INPUT_RADII  		3

#define CONSTANT_TYPE		6
#define VARYING_TYPE		7

#define DEBUG        1
#define NUMED        10
#define MAX_TO_STACKALLOC        10

#define PROMPT_SIZE 65


from EMSedge import EMget_props;
from EMSedge import EMgetvtxedges;
from EMSedge import EMdisplay;
from EMSedge import EMxyz_endpt;
from EMSedge import EMget_bcxyz_geom, EMchkconvex;
from EMSboundary import EMgetsurface_info;
from EMSsurface  import EMgetactiveid;
from GRowner     import GRget_number_components;
from EMSsubbs    import EMget_ele_header;

extern GRclassid OPP_EMSedge_class_id, 
                 OPP_EMSgraloop_class_id;
extern GRclassid OPP_EMSsurface_class_id;
extern GRclassid OPP_EMSsolid_class_id;

extern      IGRint EFlocate_action_handler();
extern void EFcheck_strlen();
extern void roundn();
extern void EFget_domn_edges();
extern  IGRlong EFhilite_edge_with_weight();
extern IGRboolean EFedge_curves_locatable();
extern void EFparse_keyin();
extern void EFrestore_hilite_of_edges();
extern IGRlong EFparse_edges();
extern IGRlong EFchkif_edge_valid();

static IGRboolean aflag;

method locate_rnd_edge ( IGRlong       *ret_msg;
                     IGRint        *response;
                     IGRchar       *response_data;
                     IGRchar       *status_string;                     
                     char          (*funcptr) () )
{
  IGRint 		      nm_edges,ii,i1,i;
  IGRboolean                  stat_func=TRUE;
  GRobjid                     first_edge;
  OMuword                     rclass, eliclass, objspc_num ;
  OM_S_CLASSLIST              rtree_classes, elig_classes;
  struct  GRlc_locate         attributes;
  IGRlong                     object_located=0,sts, msg, size, display_flag,
                              event_mask1, event_mask2;
  IGRboolean                  right_vertex=TRUE;
  enum GRdpmode               display_mode;
  IGRchar                     accept_prompt[80],loc_prompt[80];
  struct IGRline              boreline;
  IGRpoint                    point1, point2;
  IGRdouble                   beg_xyz_pt[3], end_xyz_pt[3];
  IGRdouble                   dist1, dist2,temp_rad;
  IGRint                      num_entries,num_elements;
  IGRboolean                  edge_locatable=FALSE;

  IGRlong qsize, event_size;
  IGRdouble chtol;
  GRobjid *tmp_ed;
  IGRint numedges;
  IGRshort *mattyp;
  IGRdouble *mat, angmeas;
  IGRboolean is_convex, is_neutral;
  IGRint num_vtx_edges;
  GRobjid *vtx_edges=NULL,*located_objects=NULL;
  IGRboolean *vtx_edge_ends=NULL;
  struct GRevent tmp_eve;
  void EFcheck_if_neutral();
  GRobjid     *action_edges = NULL;
  GRobjid     *acc_act_edges = NULL;
  GRobjid     *edge_rad_edges = NULL;
  IGRshort disp_flag;

  *ret_msg = EMS_S_Success;  
  sts = OM_S_SUCCESS;

  BSEXTRACTPAR(&msg, BSTOLCHRDHT, chtol);

  event_size = sizeof(struct GRevent);
  qsize = event_size - 2 * sizeof(IGRint);
  objspc_num = me->ModuleInfo.md_id.osnum;

  edge_locatable = EFedge_curves_locatable();

  if(!edge_locatable)
    EFset_locate_eligibility(&msg,1,"EMSedge");


  boreline.point1 = point1;
  boreline.point2 = point2;
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
     case IDENTIFY_EDGE:
      {

       IGRchar buff1[25],buff2[25],buff3[25],inp_buff[80];
       GRstatus_display_button(TRUE);
       event_mask1 =  GRm_VALUE| GRm_DATA | 
			GRm_RJT_MOVEON | GRm_BACK_UP | GRm_STRING;
       event_mask2 = GRm_DATA | GRm_BACK_UP |GRm_RJT_MOVEON;

       ex$message(msgnumb = EMS_I_EdgMode, buff = buff3)

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

       nm_edges = 0;
       for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }
       if(!nm_edges && !me->numtmped && me->selection)
        me->active_GRid.objid = NULL_OBJID;
        temp_rad=me->active_rad;
        roundn(&temp_rad,3);
       if(!nm_edges && !me->numtmped && me->selection
             && me->fillet_type == CONSTANT_TYPE) 
	     {
            ex$message(msgnumb = EMS_P_IdEdVerKeyRad, type = "%.3g",
                        var = `temp_rad`, buff = loc_prompt,
                        buffer_size = PROMPT_SIZE)
       	     }
       else 
       {
            if((me->fillet_type == VARYING_TYPE && me->selection) ||
                !me->selection) 
	    {
                ex$message(msgnumb = EMS_P_IdEdVerMoveOn, buff = loc_prompt ,
                        buffer_size = PROMPT_SIZE)
            }
            else
                ex$message(msgnumb = EMS_P_IdEdVerKeyRadMo, type = "%.3g",
                        var = `temp_rad`, buff = loc_prompt,
                        buffer_size = PROMPT_SIZE )
       }

       if(me->locate_stack.num_entries == 0 || me->option_change){
         me->valid_inputdata = TRUE;
	 me->locate_stack.num_entries = 0;
         ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                         in_buff = loc_prompt, buffer_size = PROMPT_SIZE)
       }
       else {
         ex$message(msgnumb = EMS_P_AccNeEdVerRej, buff = accept_prompt)
         ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                         in_buff = accept_prompt)
       }
       me->option_change = FALSE;
       stat_func = ems$getevent(msg = &msg, event_mask = event_mask1,
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
       struct      EMSaction_handler was_located;
       sts = ex$putque(msg = &msg, response = response,
                        byte = &qsize, buffer = (char *)&me->loc_event.event);

       was_located.next = NULL;
       was_located.option = LOCATE_VERTEX;
       was_located.type = 2;
       if(me->selection) 
       {
       nm_edges = 0;
       for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }
       was_located.num_objects = me->numtmped + nm_edges;
       located_objects = (GRobjid *)stackalloc(
                         sizeof(GRobjid) * (me->numtmped + nm_edges));
       nm_edges = 0; 
       for(ii = 0; ii < me->numed; ii++)
         {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         located_objects[nm_edges++] = me->located_obj[ii];
         }
       for(ii = 0; ii < me->numtmped; ii++)
         located_objects[nm_edges++] = me->tmp_located_obj[ii];
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
                                 LC_REF_OBJECTS ; /*added for RFA*/
       }
       else
       {
       attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD | 
                                 LC_OBJ_W_OWNER; 
       }
       strcpy(attributes.classes, "EMSvertex");
       display_flag =  DO_NOT_RELOCATE | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;
        
       rtree_classes.w_count = 1;
       elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

       rclass = OPP_EMSsurface_class_id;
       eliclass = OPP_EMSedge_class_id;

       rtree_classes.p_classes = &rclass;
       elig_classes.p_classes = &eliclass;

       me->locate_vertex_obj = TRUE;
       stat_func = lc$locate(rc = &object_located, 
                 event1 = &me->loc_event,
                 event2 = &me->event,
                 mask1 = event_mask1, 
                 mask2 = event_mask2, 
                 eventsize= &size, 
                 display_flag = display_flag,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = loc_prompt, 
                 acc_key = EMS_P_AccNeEdVerRej,
                 relocate_key = EMS_S_EdVerNotFound, 
                 attributes = &attributes,
                 act_handler = EFlocate_action_handler,
                 act_args = &was_located,
                 stack = &ME.ECsfedloc->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);

       if (!stat_func) {
         *ret_msg = EMS_I_Interrupt;
         goto ret_end;
       }

       if(object_located == LC_NO_OBJ_LOCATED 
		&& me->loc_event.response == EX_DATA
		 && *response != EX_CMD_KEY && *response != STRING ) {

          me->locate_vertex_obj = FALSE;
	  sts = ex$putque(msg = &object_located, response = &me->loc_event.response,
                        byte = &qsize, buffer = (char *)&me->loc_event.event);
	  was_located.next = NULL;
          was_located.option = LOCATE_EDGE;
          was_located.type = 2;

       if(me->selection) 
       {
       nm_edges = 0;
       for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }
       was_located.num_objects = me->numtmped + nm_edges;
       located_objects = (GRobjid *)stackalloc
                         (sizeof(GRobjid) * (me->numtmped + nm_edges));
       nm_edges = 0; 
       for(ii = 0; ii < me->numed; ii++)
         {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         located_objects[nm_edges++] = me->located_obj[ii];
         }
       for(ii = 0; ii < me->numtmped; ii++)
         located_objects[nm_edges++] = me->tmp_located_obj[ii];
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
	      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 LC_PLANAR_NON_PLANAR;
          aflag = pwIsActivationOn();
          if (aflag)
          {
          attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD |
                                 LC_OBJ_W_OWNER |
                                 LC_REF_OBJECTS ;/*added for RFA*/
          }
          else
          {
          attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD |
                                 LC_OBJ_W_OWNER; 
          }
          strcpy(attributes.classes, "EMSsurface");
          display_flag = DO_NOT_RELOCATE | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT 
			 	| LC_ERASE_LOC_ELEMENT;

          rtree_classes.w_count = 1;
          elig_classes.w_count = 1;
          rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

          rclass = OPP_EMSsurface_class_id;
          eliclass = OPP_EMSedge_class_id;

          rtree_classes.p_classes = &rclass;
          elig_classes.p_classes = &eliclass;
   
          stat_func = lc$locate(rc = &object_located,
		 event1 = &me->loc_event,
                 event2 = &me->event,
                 mask1 = event_mask1,
                 mask2 = event_mask2,
                 eventsize= &size,
                 display_flag = display_flag,
                 response = response,
                 response_data = response_data,
                 locate_prompt = loc_prompt,
                 acc_key = EMS_P_AccNeEdVerRej,
                 relocate_key = EMS_S_EdVerNotFound,
                 attributes = &attributes,
                 act_handler = EFlocate_action_handler,
                 act_args = &was_located,
                 stack = &ME.ECsfedloc->locate_stack,
                 rtree_classes = &rtree_classes,
                 eligible_classes = &elig_classes);

	   if( (!stat_func) || me->loc_event.response == GR_UNKNOWN_TYPE) {
               *ret_msg = EMS_I_Interrupt;
               goto ret_end;
           }
	}
	if(object_located == GRw_no_value) {
                me->event.response = EX_RJT_MOVEON;
                me->loc_event.response = EX_RJT_MOVEON;
        }

	if(object_located == LC_OBJ_LOCATED) {
		sts = ex$putque(msg = &object_located, response = response,
			byte = &qsize, buffer = (char *)&me->event.event);
		tmp_eve = me->loc_event;
            	me->process_state = ACCEPT_NXT_EDGE;
	}
      switch (me->event.response)
      {
       case EX_RJT_MOVEON:
	 
	 if(me->loc_event.response == DATA || !me->valid_inputdata) {
	   mattyp = &me->loc_event.located_object[0].module_info.md_env.matrix_type;
           mat = me->loc_event.located_object[0].module_info.md_env.matrix;   
           if(!me->selection)
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
           if((!nm_edges && !me->numtmped)  ||
	    ((nm_edges == me->numtmped) && !me->selection)) {
	      ex$message(msgnumb = EMS_S_IgnMoOnRej);
              me->process_state = IDENTIFY_EDGE;
              break;
           }
           else
             /* Successful completion */
             sts = OM_S_SUCCESS;
           goto ret_end;  
	}

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
	   
         }
	  break;
      case EX_DATA:
       {

	if(!object_located) break;
        first_edge = me->event.located_object[0].located_obj.objid;
        objspc_num = me->event.located_object[0].located_obj.osnum;

        nm_edges = 0;
        for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
        }
	sts = EFchkif_edge_valid(first_edge,objspc_num,&me->active_GRid,
			me->numtmped,nm_edges);
	if(sts != 1) {
            display_mode = GRhe ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                  me->event.located_object[0].located_obj.objid,
                  display_mode );
          EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

	  me->process_state = IDENTIFY_EDGE;
	  break; 
        }
	
	
        mattyp = &me->event.located_object[0].module_info.md_env.matrix_type; 
        mat = me->event.located_object[0].module_info.md_env.matrix; 
        me->ModuleInfo = me->event.located_object[0].module_info; 

         /* Calculate the edge nearest to the accept point */

	 if(me->locate_vertex_obj) {
           EFboreline(&msg, my_id, &tmp_eve, &boreline);

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
           if(dist1 < dist2) {
		disp_flag = EMS_EDGE_BEG_PT;
             	right_vertex = FALSE;
	   }
           else {
		disp_flag = EMS_EDGE_END_PT;
                right_vertex = TRUE;           
	   }

           display_mode = GRhe ;
           sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        	&ME.COroot->ModuleInfo.md_env.matrix_type,
                        	ME.COroot->ModuleInfo.md_env.matrix,
                        	&display_mode,NULL,
                        	disp_flag, NULL),
			senderid = NULL_OBJID,
               		targetid = first_edge,
               		targetos = objspc_num );

           EMerr_hndlr(!(1 & sts), msg, EMS_E_Fail,ret_end);

	   vtx_edge_ends = NULL;
	   num_vtx_edges = 0;
	   vtx_edges = NULL;

	   sts = om$send(msg = message EMSedge.EMgetvtxedges(&msg, 
                    EMSvtxedges_noseamedge | EMSvtxedges_notangent |
                    EMSvtxedges_onlycommon| EMSvtxedges_onlydominant 
                          | EMSvtxedges_nodegenerate,
			right_vertex, MAX_TO_STACKALLOC,
			&num_vtx_edges, &vtx_edges, &vtx_edge_ends),
		senderid = NULL_OBJID,
		targetid = first_edge,
		targetos = objspc_num);

	   tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * num_vtx_edges);
         } /* vertex is found */
	 else {
	    num_vtx_edges = 1;
	    tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid));
	    tmp_ed[0] = first_edge;
	    vtx_edges = (GRobjid *) om$malloc(size = 
                                 sizeof(GRobjid) * num_vtx_edges);
	    EFget_domn_edges(tmp_ed,num_vtx_edges,objspc_num);
	    display_mode = GRhe ;
            vtx_edges[0] = first_edge;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                             first_edge, display_mode );
            EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

	 }

	/* checking the edges for neutral & convex */

	 numedges = 0;
	 for(i1 = 0; i1 < num_vtx_edges; i1++) {
	    GRobjid tmp_edge_id;

	    tmp_edge_id = vtx_edges[i1];
	    sts = om$send(msg = message EMSedge.EMchkconvex(&msg, NULL,
			mattyp, mat, EMS_ZEROANGLE_DEG_MAX, &is_convex,
			&is_neutral, &angmeas),
		senderid = NULL_OBJID,
		targetid = tmp_edge_id,
		targetos = objspc_num);

            EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

	    /* Check if it's within the user defined neutral edge angle */
	    if(!is_neutral) {
	        EFcheck_if_neutral(angmeas, me->neutral_edge_angle,
			&is_neutral);
	    }
            nm_edges = 0;
            for(ii = 0; ii < me->numed; ii++) {
             if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
             nm_edges++;
            }
	    sts = EFchkif_edge_valid(tmp_edge_id,objspc_num,&me->active_GRid,
                        me->numtmped,nm_edges);
	    if(is_neutral || (!sts)) 
		    continue;
	    tmp_ed[numedges] = tmp_edge_id;
	    numedges++;
	} 
        /* fix for mlk */
        if(vtx_edges)
          {
          om$dealloc(ptr = vtx_edges);
          vtx_edges = NULL;
          }
        if(vtx_edge_ends)
          {
          om$dealloc(ptr = vtx_edge_ends);
          vtx_edge_ends = NULL;
          }

	if(!numedges) {
               	me->process_state = IDENTIFY_EDGE;
                break;
	}

	sts = EFparse_edges(&msg, &me->selection, me->located_obj, 
			me->tmp_located_obj, me->numed, me->numtmped,
			tmp_ed, objspc_num, &numedges,me->bound_code);

	if(me->selection) {
	    for(i1 = 0; i1 < numedges; i1++) {
              display_mode = GRhd ;
	      sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmp_ed[i1],
                        targetos = objspc_num);
              EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);
	    }
	    if(!numedges) {
            	ex$message ( msgnumb = EMS_S_InvalidEdge);
            	me->process_state = ACCEPT_NXT_EDGE;
	    	break;
	    }
	} /* of selection */
	else if(!me->selection) {
	    for(i1 = 0; i1 < numedges; i1++) {
              display_mode = GRhe ;
	      sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmp_ed[i1],
                        targetos = objspc_num);
              EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);
	    }
	
	    if(!numedges) {
            	ex$message ( msgnumb = EMS_S_NoEdgesToDeselect);
		sleep(1);
            	me->process_state = ACCEPT_NXT_EDGE;
	    	break;
	    }
	} /* of de-selection */

	num_entries = om$dimension_of(varray = me->num_bkp_list);
	if((me->num_bkp_entries + 1) >= num_entries) {
	   sts = om$vla_set_dimension(varray = me->num_bkp_list,
			size = me->num_bkp_entries + 1 );
	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
        }
        num_elements = om$dimension_of(varray = me->tmp_located_obj);
        if ((me->numtmped + numedges) >= num_elements) {
           sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                         size = me->numtmped + numedges + num_elements);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
	}
        if ((me->numtmped + numedges + me->numed) >= num_elements) {
           sts = om$vla_set_dimension(varray = me->edgeval_event,
                                         size = num_elements + numedges + me->numed +
					me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           sts = om$vla_set_dimension(varray = me->end_edgeval_event,
                                         size = num_elements + numedges + me->numed +
					me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           sts = om$vla_set_dimension(varray = me->fill_typ,
                       size = num_elements + numedges + me->numed + me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           sts = om$vla_set_dimension(varray = me->bound_code,
                       size = num_elements + numedges + me->numed + me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
        }

	for(i1 = 0; i1 < numedges; i1++) {
        	me->tmp_located_obj[me->numtmped + i1] = tmp_ed[i1];
                me->end_edgeval_event[me->numed+me->numtmped + i1].num_id= 0;
                me->edgeval_event[me->numed+me->numtmped + i1].num_id= 0;
		me->edgeval_event[me->numed + i1 + me->numtmped].event.value = 
			me->active_rad;
		me->end_edgeval_event[me->numed+i1+ me->numtmped].event.value = 
			-1.0;
		me->fill_typ[me->numed + i1 + me->numtmped] = me->fillet_type;
                me->bound_code[i1+me->numed+me->numtmped]= 0;
                if(me->fillet_type == VARYING_TYPE)
                  me->bound_code[i1+me->numed+me->numtmped]=
                     EMSrnd_input_ed_grp_start;
	}
        
        if(me->numtmped == 0 || !me->radius_changed) {
          me->bound_code[me->numed+me->numtmped]= EMSrnd_input_ed_grp_start;
          me->radius_changed = 1;
        }
        me->numtmped += numedges;
	me->num_bkp_entries ++;
	me->num_bkp_list[me->num_bkp_entries-1] = numedges;
        me->process_state = ACCEPT_NXT_EDGE;
       break;
       }

       default:
         me->valid_inputdata = FALSE;
         goto ret_end;
       } /* switch of event response */
       break;               
       } /* of the 3 cases */
       default:
	goto ret_end;
       }
      break;
     }

     case ACCEPT_NXT_EDGE:
      {
       struct      EMSaction_handler was_located;

       ex$message(msgnumb = EMS_P_AccNeEdVerRej, buff = loc_prompt)
       GRstatus_display_button(FALSE);

	me->valid_inputdata = FALSE;
	me->locate_vertex_obj = TRUE;

       was_located.next = NULL;
       was_located.option = LOCATE_VERTEX;
       was_located.type = 2;

       if(me->selection) 
       {
       nm_edges = 0;
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
         located_objects[nm_edges++] = me->tmp_located_obj[ii];
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
       event_mask1 = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
       event_mask2 = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;

       size = sizeof(struct GRevent);
       attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 LC_PLANAR_NON_PLANAR;
       aflag = pwIsActivationOn();
       if (aflag)
       {
       attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD | 
                                 LC_OBJ_W_OWNER | 
                                 LC_REF_OBJECTS ; /*added for RFA*/
       }
       else
       {
       attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD | 
                                 LC_OBJ_W_OWNER;
       }
       strcpy(attributes.classes, "EMSvertex");
       display_flag = DO_NOT_RELOCATE | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;
        
       rtree_classes.w_count = 1;
       elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

       rclass = OPP_EMSsurface_class_id;
       eliclass = OPP_EMSedge_class_id;

       rtree_classes.p_classes = &rclass;
       elig_classes.p_classes = &eliclass;

       stat_func = lc$locate(rc = &object_located, 
                 event1 = &me->loc_event,
                 event2 = &me->event,
                 mask1 = event_mask1, 
                 mask2 = event_mask2, 
                 eventsize= &size, 
                 display_flag = display_flag,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = loc_prompt, 
                 acc_key = EMS_P_AccNeEdVerRej,
                 relocate_key = EMS_P_EdgeNotFound, 
                 attributes = &attributes,
                 act_handler = EFlocate_action_handler,
                 act_args = &was_located,
                 stack = &ME.ECsfedloc->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);

    if(!stat_func)
        {
	 me->valid_inputdata = FALSE;
         *ret_msg = EMS_I_Interrupt;
         goto ret_end;
        }

       if((object_located == LC_NO_OBJ_LOCATED && me->loc_event.response == EX_DATA)
		 && (*response != EX_CMD_KEY ) ) {

          me->locate_vertex_obj = FALSE;
	  sts = ex$putque(msg = &object_located, response = &me->loc_event.response,
                        byte = &qsize, buffer = (char *)&me->loc_event.event);
                
	  was_located.next = NULL;
          was_located.option = LOCATE_EDGE;
          was_located.type = 2;

       if(me->selection)
       {
       nm_edges = 0;
       for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }
       was_located.num_objects = me->numtmped + nm_edges;
       located_objects = (GRobjid *)stackalloc
                         (sizeof(GRobjid) * (me->numtmped + nm_edges));
       nm_edges = 0; 
       for(ii = 0; ii < me->numed; ii++)
         {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         located_objects[nm_edges++] = me->located_obj[ii];
         }
       for(ii = 0; ii < me->numtmped; ii++)
         located_objects[nm_edges++] = me->tmp_located_obj[ii];
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
	      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 LC_PLANAR_NON_PLANAR;
          aflag = pwIsActivationOn();
          if (aflag)
          {
          attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD |
                                 LC_OBJ_W_OWNER |
                                 LC_REF_OBJECTS ; /*added for RFA*/
          }
          else
          {
          attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD |
                                 LC_OBJ_W_OWNER;
          }
          strcpy(attributes.classes, "EMSsurface");
          display_flag = DO_NOT_RELOCATE | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT 
			 	| LC_ERASE_LOC_ELEMENT;

          rtree_classes.w_count = 1;
          elig_classes.w_count = 1;
          rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

          rclass = OPP_EMSsurface_class_id;
          eliclass = OPP_EMSedge_class_id;

          rtree_classes.p_classes = &rclass;
          elig_classes.p_classes = &eliclass;
   
          stat_func = lc$locate(rc = &object_located,
		 event1 = &me->loc_event,
                 event2 = &me->event,
                 mask1 = event_mask1,
                 mask2 = event_mask2,
                 eventsize= &size,
                 display_flag = display_flag,
                 response = response,
                 response_data = response_data,
                 locate_prompt = loc_prompt,
                 acc_key = EMS_P_AccNeEdVerRej,
                 relocate_key = EMS_S_EdVerNotFound,
                 attributes = &attributes,
                 act_handler = EFlocate_action_handler,
                 act_args = &was_located,
                 stack = &ME.ECsfedloc->locate_stack,
                 rtree_classes = &rtree_classes,
                 eligible_classes = &elig_classes);

	   if( (!stat_func) || me->loc_event.response == GR_UNKNOWN_TYPE) {
               me->valid_inputdata = FALSE;
               *ret_msg = EMS_I_Interrupt;
               goto ret_end;
           }
	}

	if(object_located == LC_OBJ_LOCATED) {
		sts = ex$putque(msg = &object_located, response = response,
			byte = &qsize, buffer = (char *)&me->event.event);
		tmp_eve = me->loc_event;
            	me->process_state = ACCEPT_NXT_EDGE;
	}
	else {
	    if(me->event.response == EX_DATA) {
	   	if(me->fillet_type == VARYING_TYPE && me->selection) 
           		me->process_state = IDENTIFY_EDGE_RADII;
	   	else 
           		me->process_state = IDENTIFY_EDGE;
		me->event.response = GR_UNKNOWN_TYPE;
	    }
	}

      switch (me->event.response)
      {
       case EX_RJT_MOVEON:
         if(me->loc_event.response == DATA) {
           mattyp = &me->loc_event.located_object[0].module_info.md_env.matrix_type;
           mat = me->loc_event.located_object[0].module_info.md_env.matrix;
           if(!me->selection)
           EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,me->ModuleInfo,me->bound_code);
         }  /* Object found but rejected */
	   if(me->fillet_type == VARYING_TYPE && me->selection) 
           	me->process_state = IDENTIFY_EDGE_RADII;
	   else 
           	me->process_state = IDENTIFY_EDGE;
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
          /* Exit the method with no edges */
           me->process_state = IDENTIFY_EDGE;
	   ex$message(msgnumb =EMS_S_NoPrevBkp) ;
           sleep(1);
          }
          break;
      case EX_DATA:
       {

	if(!object_located) break;
        first_edge = me->event.located_object[0].located_obj.objid;
        objspc_num = me->event.located_object[0].located_obj.osnum;

        nm_edges = 0;
        for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
        }
	sts = EFchkif_edge_valid(first_edge,objspc_num,&me->active_GRid,
                        me->numtmped,nm_edges);
        if(!sts) {
            display_mode = GRhe ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                  me->event.located_object[0].located_obj.objid,
                  display_mode );
          EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

          me->process_state = ACCEPT_NXT_EDGE;
          break;
        }

        mattyp = &me->event.located_object[0].module_info.md_env.matrix_type; 
        mat = me->event.located_object[0].module_info.md_env.matrix; 
        me->ModuleInfo = me->event.located_object[0].module_info; 

         /* Calculate the edge nearest to the accept point */
	vtx_edges = NULL;
	if(me->locate_vertex_obj) {

         EFboreline(&msg, my_id, &tmp_eve, &boreline);

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
             if(dist1 < dist2) {
		disp_flag = EMS_EDGE_BEG_PT;
             	right_vertex = FALSE;
	     }
             else {
		disp_flag = EMS_EDGE_END_PT;
                right_vertex = TRUE;           
	     }

             display_mode = GRhe ;
             sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        	&ME.COroot->ModuleInfo.md_env.matrix_type,
                        	ME.COroot->ModuleInfo.md_env.matrix,
                        	&display_mode,NULL,
                        	disp_flag, NULL),
               		targetid = first_edge,
               		targetos = objspc_num );

             EMerr_hndlr (!(1 & sts), msg, EMS_E_Fail,ret_end);

	     vtx_edge_ends = NULL;
	     num_vtx_edges = 0;

	     sts = om$send(msg = message EMSedge.EMgetvtxedges(&msg, 
                    EMSvtxedges_noseamedge | EMSvtxedges_notangent |
                    EMSvtxedges_onlycommon| EMSvtxedges_onlydominant 
                          | EMSvtxedges_nodegenerate,
			right_vertex, MAX_TO_STACKALLOC,
			&num_vtx_edges, &vtx_edges, &vtx_edge_ends),
		senderid = NULL_OBJID,
		targetid = first_edge,
		targetos = objspc_num);

	     tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * num_vtx_edges);
        } /* if vertex found */
	else {
	    num_vtx_edges = 1;
	    tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid));
	    tmp_ed[0] = first_edge;
            vtx_edges = (GRobjid *)om$malloc(size = sizeof(GRobjid)*
                                             num_vtx_edges);
            vtx_edges[0]= first_edge;
	    EFget_domn_edges(tmp_ed,num_vtx_edges,objspc_num);
            display_mode = GRhe ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                             first_edge, display_mode );
            EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
	}

	numedges = 0;
	for(i = 0; i < num_vtx_edges; i++) {
	    GRobjid tmp_edge_id;

	    tmp_edge_id = vtx_edges[i];
	    sts = om$send(msg = message EMSedge.EMchkconvex(&msg, NULL,
			mattyp, mat, EMS_ZEROANGLE_DEG_MAX, &is_convex,
			&is_neutral, &angmeas),
		senderid = NULL_OBJID,
		targetid = tmp_edge_id,
		targetos = objspc_num);

            EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

	    /* Check if it's within the user defined neutral edge angle */
	    if(!is_neutral) {
	        EFcheck_if_neutral(angmeas, me->neutral_edge_angle,
			&is_neutral);
	    }
            nm_edges = 0;
            for(ii = 0; ii < me->numed; ii++) {
             if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
             nm_edges++;
            }
	    sts = EFchkif_edge_valid(tmp_edge_id,objspc_num,&me->active_GRid,
                        me->numtmped,nm_edges);
	    if(is_neutral || (!sts)) {
/*
                    display_mode = GRhe ;
                    sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                             tmp_edge_id, display_mode );
                    EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
*/

		    continue;
	    }
	    tmp_ed[numedges] = tmp_edge_id;
	    numedges++;
	}
        if(vtx_edges)
          {
          om$dealloc(ptr = vtx_edges);
          vtx_edges = NULL;
          }
        if(vtx_edge_ends)
          {
          om$dealloc(ptr = vtx_edge_ends);
          vtx_edge_ends = NULL;
          }

	if(!numedges) {
              	me->process_state = IDENTIFY_EDGE;
                break;
	}

	sts = EFparse_edges(&msg, &me->selection, me->located_obj, 
			me->tmp_located_obj, me->numed, me->numtmped,
			tmp_ed, objspc_num, &numedges,me->bound_code);

	if(me->selection) {
	    for(i = 0; i < numedges; i++) {
             	display_mode = GRhd ;
	      sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmp_ed[i],
                        targetos = objspc_num);
              EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);
	    }
	    if(!numedges) {
            	ex$message ( msgnumb = EMS_S_InvalidEdge);
            	me->process_state = ACCEPT_NXT_EDGE;
	    	break;
	    }
	}
	else if(!me->selection) {
	    for(i = 0; i < numedges; i++) {
              display_mode = GRhe ;
	      sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmp_ed[i],
                        targetos = objspc_num);
              EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);
            
	    }
	    if(!numedges) {
            	ex$message ( msgnumb = EMS_S_NoEdgesToDeselect);
		sleep(1);
/*
            	display_mode = GRhe ;
            	sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
			first_edge, display_mode);
            	EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
*/
            	me->process_state = ACCEPT_NXT_EDGE;
	    	break;
	    }
	}

	num_entries = om$dimension_of(varray = me->num_bkp_list);
	if((me->num_bkp_entries + 1) >= num_entries) {
	   sts = om$vla_set_dimension(varray = me->num_bkp_list,
			size = me->num_bkp_entries + 1 );
	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
        }
         num_elements = om$dimension_of(varray = me->tmp_located_obj);
         if ((me->numtmped + numedges) >= num_elements)
         {
           sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                         size = num_elements +  me->numtmped + numedges);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");

         }
         if ((me->numtmped + numedges + me->numed) >= num_elements)
         {
           sts = om$vla_set_dimension(varray = me->edgeval_event,
                                         size = num_elements + numedges + me->numed + me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           sts = om$vla_set_dimension(varray = me->end_edgeval_event,
                                         size = num_elements + numedges + me->numed +
					me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           sts = om$vla_set_dimension(varray = me->fill_typ,
                     size = num_elements + numedges + me->numed + me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           sts = om$vla_set_dimension(varray = me->bound_code,
                     size = num_elements + numedges + me->numed + me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
         }

	for(i = 0; i < numedges; i++) {
        	me->tmp_located_obj[me->numtmped + i] = tmp_ed[i];
                me->end_edgeval_event[me->numed+me->numtmped + i].num_id= 0;
                me->edgeval_event[me->numed+me->numtmped + i].num_id= 0;
		me->edgeval_event[me->numed + i + me->numtmped].event.value = 
			me->active_rad;
		me->end_edgeval_event[me->numed + i + me->numtmped].event.value = 
			-1.0;
		me->fill_typ[me->numed + i + me->numtmped] = me->fillet_type;
                me->bound_code[i+ me->numed+me->numtmped]= 0;
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
          me->process_state = ACCEPT_NXT_EDGE;
        }
        break;

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

     case IDENTIFY_EDGE_RADII:
      {
       struct      EMSaction_handler  was_located;
       GRstatus_display_button(FALSE);
       temp_rad=me->active_rad;
       roundn(&temp_rad,3);

       ex$message(msgnumb = EMS_P_IdEdVerEntRad, type = "%g",
			var = `temp_rad`, buff = loc_prompt)
    
       if(me->locate_stack.num_entries == 0 || me->option_change) {
	 me->locate_stack.num_entries = 0;
          ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                         in_buff = loc_prompt)
       }
       else {
             ex$message(msgnumb = EMS_P_AccNeEdVerRej,buff = accept_prompt)
          ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                         in_buff = accept_prompt)
       }

       me->option_change = FALSE;
	event_mask1 =  GRm_VALUE| GRm_DATA |
                        GRm_RJT_MOVEON | GRm_BACK_UP | GRm_STRING;
       stat_func = ems$getevent(msg = &msg, event_mask = event_mask1,
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

       was_located.next = NULL;
       was_located.option = LOCATE_VERTEX;
       was_located.type = 2;

       if(me->selection)
       {
       nm_edges = 0;
       for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
       }
       was_located.num_objects =  me->numtmped + nm_edges;
       located_objects = (GRobjid *)stackalloc
                         (sizeof(GRobjid) * (me->numtmped + nm_edges));
       nm_edges = 0; 
       for(ii = 0; ii < me->numed; ii++)
         {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         located_objects[nm_edges++] = me->located_obj[ii];
         }
       for(ii = 0; ii < me->numtmped; ii++)
         located_objects[nm_edges++] = me->tmp_located_obj[ii];
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
       event_mask1 = GRm_STRING | GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
       event_mask2 = GRm_DATA | GRm_BACK_UP;

       size = sizeof(struct GRevent);
       attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 LC_PLANAR_NON_PLANAR;
       aflag = pwIsActivationOn();
       if (aflag)
       {
       attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD | 
                                 LC_OBJ_W_OWNER | 
                                 LC_REF_OBJECTS ; /*added for RFA*/
       }
       else
       {
       attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD | 
                                 LC_OBJ_W_OWNER;
       }
       strcpy(attributes.classes, "EMSvertex");
       display_flag = DO_NOT_RELOCATE | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;
        
       rtree_classes.w_count = 1;
       elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

       rclass = OPP_EMSsurface_class_id;
       eliclass = OPP_EMSedge_class_id;

       rtree_classes.p_classes = &rclass;
       elig_classes.p_classes = &eliclass;

       stat_func = lc$locate(rc = &object_located, 
                 event1 = &me->loc_event,
                 event2 = &me->event,
                 mask1 = event_mask1, 
                 mask2 = event_mask2, 
                 eventsize= &size, 
                 display_flag = display_flag,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = loc_prompt, 
                 acc_key = EMS_P_AccNeEdVerRej,
                 relocate_key = EMS_P_EdgeNotFound, 
                 attributes = &attributes,
                 act_handler = EFlocate_action_handler,
                 act_args = &was_located,
                 stack = &ME.ECsfedloc->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);

       if(!stat_func) {
         *ret_msg = EMS_I_Interrupt;
         goto ret_end;
       }

       if((object_located == LC_NO_OBJ_LOCATED && me->loc_event.response == EX_DATA)
		 && *response != EX_CMD_KEY ) {

          me->locate_vertex_obj = FALSE;
	  sts = ex$putque(msg = &object_located, response = &me->loc_event.response,
                        byte = &qsize, buffer = (char *)&me->loc_event.event);
                
	  was_located.next = NULL;
          was_located.option = LOCATE_EDGE;
          was_located.type = 2;

       if(me->selection)
       {
       nm_edges = 0;
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
         located_objects[nm_edges++] = me->tmp_located_obj[ii];
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
	      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 LC_PLANAR_NON_PLANAR;
          aflag = pwIsActivationOn();
          if (aflag)
          {
          attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD |
                                 LC_OBJ_W_OWNER |
                                 LC_REF_OBJECTS ; /*added for RFA*/
          }
          else
          {
          attributes.owner_action = LC_RIGID_COMP  | LC_LOCALMOD |
                                 LC_OBJ_W_OWNER; 
          }
          strcpy(attributes.classes, "EMSsurface");
          display_flag = DO_NOT_RELOCATE | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT 
			 	| LC_ERASE_LOC_ELEMENT;

          rtree_classes.w_count = 1;
          elig_classes.w_count = 1;
          rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

          rclass = OPP_EMSsurface_class_id;
          eliclass = OPP_EMSedge_class_id;

          rtree_classes.p_classes = &rclass;
          elig_classes.p_classes = &eliclass;
   
          stat_func = lc$locate(rc = &object_located,
	         event1 = &me->loc_event,
                 event2 = &me->event,
                 mask1 = event_mask1,
                 mask2 = event_mask2,
                 eventsize= &size,
                 display_flag = display_flag,
                 response = response,
                 response_data = response_data,
                 locate_prompt = loc_prompt,
                 acc_key = EMS_P_AccNeEdVerRej,
                 relocate_key = EMS_S_EdVerNotFound,
                 attributes = &attributes,
                 act_handler = EFlocate_action_handler,
                 act_args = &was_located,
                 stack = &ME.ECsfedloc->locate_stack,
                 rtree_classes = &rtree_classes,
                 eligible_classes = &elig_classes);

	   if( (!stat_func) || me->loc_event.response == GR_UNKNOWN_TYPE) {
               me->valid_inputdata = FALSE;
               *ret_msg = EMS_I_Interrupt;
               goto ret_end;
           }
	}
	if(object_located == LC_OBJ_LOCATED) {
		sts = ex$putque(msg = &object_located, response = response,
			byte = &qsize, buffer = (char *)&me->event.event);
		tmp_eve = me->loc_event;
            	me->process_state = ACCEPT_NXT_EDGE;
	}
	else {
		if(me->event.response == EX_DATA) {
/*
		   EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,me->ModuleInfo,me->bound_code);
*/
                        me->valid_inputdata = FALSE;
                } 
	}


      switch (me->event.response)
      {
       case EX_RJT_MOVEON:
	   if(me->loc_event.response == DATA) {
           mattyp = &me->loc_event.located_object[0].module_info.md_env.matrix_type;
           mat = me->loc_event.located_object[0].module_info.md_env.matrix;
           if(!me->selection)
           EFrestore_hilite_of_edges(me->numed,
                   me->numtmped, me->located_obj,me->tmp_located_obj,
                   me->selection,me->ModuleInfo,me->bound_code);
           break;
         }
           me->process_state = INPUT_RADII;
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
          }
	 break;

      case EX_DATA:
       {

	if(!object_located) break;
        first_edge = me->event.located_object[0].located_obj.objid;
        objspc_num = me->event.located_object[0].located_obj.osnum;
        nm_edges = 0;
        for(ii = 0; ii < me->numed; ii++) {
         if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
         nm_edges++;
        }
	sts = EFchkif_edge_valid(first_edge,objspc_num,&me->active_GRid,
                        me->numtmped,nm_edges);
        if(!sts) {
            display_mode = GRhe ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                  me->event.located_object[0].located_obj.objid,
                  display_mode );
          EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

          me->process_state = ACCEPT_NXT_EDGE;
          break;
        }

        mattyp = &me->event.located_object[0].module_info.md_env.matrix_type; 
        mat = me->event.located_object[0].module_info.md_env.matrix; 
        me->ModuleInfo = me->event.located_object[0].module_info;

         /* Calculate the edge nearest to the accept point */

	vtx_edges = NULL;
        if(me->locate_vertex_obj) {
         EFboreline(&msg, my_id, &tmp_eve, &boreline);


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
         if(dist1 < dist2) {
		disp_flag = EMS_EDGE_BEG_PT;
             	right_vertex = FALSE;
	 }
         else {
		disp_flag = EMS_EDGE_END_PT;
                right_vertex = TRUE;           
	 }

         display_mode = GRhe ;
         sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        	&ME.COroot->ModuleInfo.md_env.matrix_type,
                        	ME.COroot->ModuleInfo.md_env.matrix,
                        	&display_mode,NULL,
                        	disp_flag, NULL),
			senderid = NULL_OBJID,
               		targetid = first_edge,
               		targetos = objspc_num );

         EMerr_hndlr (!(1 & sts), msg, EMS_E_Fail,ret_end);

	 vtx_edge_ends = NULL;
	 num_vtx_edges = 0;

	 sts = om$send(msg = message EMSedge.EMgetvtxedges(&msg, 
                    EMSvtxedges_noseamedge | EMSvtxedges_notangent |
                    EMSvtxedges_onlycommon| EMSvtxedges_onlydominant 
                          | EMSvtxedges_nodegenerate,
			right_vertex, MAX_TO_STACKALLOC,
			&num_vtx_edges, &vtx_edges, &vtx_edge_ends),
		senderid = NULL_OBJID,
		targetid = first_edge,
		targetos = objspc_num);

	 tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid) * num_vtx_edges);
        } /* if vertex found */
	else {
	    num_vtx_edges = 1;
	    tmp_ed = (GRobjid *) stackalloc(sizeof(GRobjid));
	    tmp_ed[0] = first_edge;
            vtx_edges = (GRobjid *)om$malloc(size = sizeof(GRobjid) *
                                         num_vtx_edges);
            vtx_edges[0] = first_edge;
	    EFget_domn_edges(tmp_ed,num_vtx_edges,objspc_num);
	    display_mode = GRhe ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                             first_edge, display_mode );
            EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
	}

	numedges = 0;
	for(i = 0; i < num_vtx_edges; i++) {
	    GRobjid tmp_edge_id;

	    tmp_edge_id =  vtx_edges[i];
	    sts = om$send(msg = message EMSedge.EMchkconvex(&msg, NULL,
			mattyp, mat, EMS_ZEROANGLE_DEG_MAX, &is_convex,
			&is_neutral, &angmeas),
		senderid = NULL_OBJID,
		targetid = tmp_edge_id,
		targetos = objspc_num);

            EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

	    /* Check if it's within the user defined neutral edge angle */
	    if(!is_neutral) {
	        EFcheck_if_neutral(angmeas, me->neutral_edge_angle,
			&is_neutral);
	    }
            nm_edges = 0;
            for(ii = 0; ii < me->numed; ii++) {
             if(me->bound_code[ii] & EMSrnd_mark_ed_deleted) continue;
             nm_edges++;
            }
	    sts = EFchkif_edge_valid(tmp_edge_id,objspc_num,&me->active_GRid,
                        me->numtmped,nm_edges);
	    if(is_neutral || (!sts)) 
		    continue;
	    tmp_ed[numedges] = tmp_edge_id;
	    numedges++;
	}
        if(vtx_edges)
          {
          om$dealloc(ptr = vtx_edges);
          vtx_edges = NULL;
          }
        if(vtx_edge_ends)
          {
          om$dealloc(ptr = vtx_edge_ends);
          vtx_edge_ends = NULL;
          }

	if(!numedges) {
        	me->process_state = IDENTIFY_EDGE;
                break;
	}

	sts = EFparse_edges(&msg, &me->selection, me->located_obj, 
			me->tmp_located_obj, me->numed, me->numtmped,
			tmp_ed, objspc_num, &numedges,me->bound_code);

	if(me->selection) {
	    for(i = 0; i < numedges; i++) {
             	display_mode = GRhd ;
	      sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmp_ed[i],
                        targetos = objspc_num);
              EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);
	    }
	    if(!numedges) {
            	ex$message ( msgnumb = EMS_S_InvalidEdge);
            	me->process_state = ACCEPT_NXT_EDGE;
	    	break;
	    }
	}
	else if(!me->selection) {
	    for(i = 0; i < numedges; i++) {
              display_mode = GRhe ;
	      sts = om$send(msg = message EMSedge.EMdisplay(&msg, NULL,
                        mattyp, mat, &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
                        targetid = tmp_ed[i],
                        targetos = objspc_num);
              EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

	    }
	
	    if(!numedges) {
            	ex$message ( msgnumb = EMS_S_NoEdgesToDeselect);
		sleep(1);
/*
            	display_mode = GRhe ;
            	sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
			first_edge, display_mode);
            	EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
*/
            	me->process_state = ACCEPT_NXT_EDGE;
	    	break;
	    }
	}

        ME.COroot->ModuleInfo = me->event.located_object[0].module_info; 

	num_entries = om$dimension_of(varray = me->num_bkp_list);
	if((me->num_bkp_entries + 1) >= num_entries) {
	   sts = om$vla_set_dimension(varray = me->num_bkp_list,
			size = me->num_bkp_entries + 1 );
	   EMomerr_hndlr(sts, ret_end, "set_dimension  error");
        }
        num_elements = om$dimension_of(varray = me->tmp_located_obj);
        if ((me->numtmped + numedges) >= num_elements)
         {
           sts = om$vla_set_dimension(varray = me->tmp_located_obj,
                                         size = me->numtmped + numedges +num_elements);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
   	}
         if ((me->numtmped + numedges + me->numed) >= num_elements)
         {
           sts = om$vla_set_dimension(varray = me->edgeval_event,
                                         size = num_elements + numedges + me->numed +
					me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           sts = om$vla_set_dimension(varray = me->end_edgeval_event,
                    size = num_elements + numedges + me->numed + me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
           sts = om$vla_set_dimension(varray = me->fill_typ,
                    size = num_elements + numedges + me->numed + me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           sts = om$vla_set_dimension(varray = me->bound_code,
                     size = num_elements + numedges + me->numed + me->numtmped);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
         }

	for(i = 0; i < numedges; i++) {
        	me->tmp_located_obj[me->numtmped + i] = tmp_ed[i];
                me->end_edgeval_event[me->numed+me->numtmped + i].num_id= 0;
                me->edgeval_event[me->numed+me->numtmped + i].num_id= 0;
		me->edgeval_event[me->numed + i + me->numtmped].event.value = 
			me->active_rad;
		me->end_edgeval_event[me->numed + i + me->numtmped].event.value = 
			-1.0;
		me->fill_typ[me->numed + i + me->numtmped] = me->fillet_type;
                me->bound_code[i+ me->numed+me->numtmped] =0;
                if(me->fillet_type == VARYING_TYPE)
                   me->bound_code[i+ me->numed+me->numtmped]=
                     EMSrnd_input_ed_grp_start;
	}
        
          if(me->numtmped == 0 || !me->radius_changed) {
            me->bound_code[me->numed+me->numtmped] =EMSrnd_input_ed_grp_start;
              me->radius_changed = 1;
          }
          me->numtmped += numedges;
          me->num_bkp_entries ++;
	  me->num_bkp_list[me->num_bkp_entries-1] = numedges;
          me->process_state = ACCEPT_NXT_EDGE;
        }
          break;

         default:
            me->valid_inputdata = FALSE;
            goto ret_end;
         } /* switch of event response */
         break;
        } /* of 3 cases */
       default:
	goto ret_end;
      } /* me->loc_event.response */
     break;
    }

     case INPUT_RADII:
      {
	int i,j;
	IGRchar inp_buff[52];
	IGRlong event_mask;

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
			    if(j == 0)  
			        me->edgeval_event[me->numed + i] = me->event;
			    else 
			    	me->end_edgeval_event[me->numed+i] = me->event;

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
			if(*response == CLEAR_STACK || *response == TERMINATE) 
			  goto ret_end;
                        if(*response == EX_CMD_KEY) {
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
	   	me->process_state = IDENTIFY_EDGE;
	   	break;
	    }
    	}
	me->process_state = IDENTIFY_EDGE;
      }
     break;               

  default:
     goto ret_end;
    } /* me->process_state */
  }

 while( TRUE);

 ret_end:
  if(action_edges) om$dealloc(ptr = action_edges);
  if(acc_act_edges) om$dealloc(ptr = acc_act_edges);
  if(edge_rad_edges) om$dealloc(ptr = edge_rad_edges);

  if(!edge_locatable)
   EFset_locate_eligibility(&msg,0,"EMSedge");

  return(sts);

}

/* This function is used to check if the edge is a neutral edge based on the
neutral edge angle defined by the user. This angle is defined by invoking the
forms & selecting the tangent edge angle gadget */

void EFcheck_if_neutral(edge_angmeas, user_def_neutral_edge_angle, is_neutral)
IGRdouble edge_angmeas;
IGRdouble user_def_neutral_edge_angle;
IGRboolean *is_neutral;
{
	IGRdouble diff_ang;

	diff_ang = (edge_angmeas >= 2.0) ? (edge_angmeas - 2.0) :
		(2.0 - edge_angmeas);

	diff_ang *= 90.0;

	*is_neutral = (diff_ang <= user_def_neutral_edge_angle) ? TRUE : FALSE;
}

/* This function is used to check whether 
	i) the ancestry is valid
	ii) it has a common edge
	iii) belongs to the same surface & a single surface
	If any one of these it doesn't satisfy, the edge is invalid &
	returns a 0
*/

IGRlong EFchkif_edge_valid(edge_id,edge_os,active_grid,numtmp_ed,num_ed) 
GRobjid edge_id;
OMuword edge_os;
struct GRid *active_grid;
IGRint numtmp_ed,num_ed;
{
 struct GRid srf_ownr;
 GRobjid                     srfid; 
 IGRboolean  single_surface=FALSE;
 IGRint      count,num_components, loop_count;
 GRclassid   classid, loop_classid;
 OM_S_CHANSELECT  to_loops,chan_to_common_edge;
 OM_S_OBJECT_LINKAGE loop_list,comm_edge;
 IGRlong msg,sts,ret_msg;

    sts = om$get_classid (
              objid = edge_id,
              osnum = edge_os,
              p_classid = &classid);

    sts = om$is_ancestry_valid( subclassid = classid,
                                superclassid = OPP_EMSedge_class_id);

    if ( sts != OM_S_SUCCESS) {
	ex$message ( msgnumb = EMS_S_InvalidEdge);
        goto ret_end;
    }

    EMmake_chanselect( EMSedge_to_common_edge, &chan_to_common_edge);
    EMmake_chanselect(EMSedge_to_owner, &to_loops);

    sts = om$get_channel_objects(
               osnum = edge_os,
               objid = edge_id,
               p_chanselect = &chan_to_common_edge,
               list = &comm_edge,
               size = 1,
               count = (OMuint *)&count);
    EMomerr_hndlr ( sts, ret_end, "get_channel_objects");
    if(!count) {
	sts = 0;
	ex$message ( msgnumb = EMS_S_InvalidEdge);
	goto ret_end;
    }
    sts = om$get_channel_objects(
               objid = edge_id,
               osnum = edge_os,
               p_chanselect = &to_loops,
               list = &loop_list,
               size = 1,
               count = (OMuint *)&loop_count);
    EMomerr_hndlr(sts, ret_end, "om$get_channel_objects");

    sts = om$get_classid (
               objid = loop_list.S_objid,
               osnum = edge_os,
               p_classid = &loop_classid);
    EMomerr_hndlr(sts, ret_end, "om$get_classid");

    sts = om$is_ancestry_valid( subclassid = loop_classid,
                       superclassid = OPP_EMSgraloop_class_id);
    EMomerr_hndlr(sts, ret_end, "om$is_ancestry_valid");
    if(sts == OM_S_SUCCESS) {
	sts = 0;
	ex$message ( msgnumb = EMS_S_InvalidEdge);
	goto ret_end;
    }

    sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                            (&msg, &srfid, NULL),
			    senderid = NULL_OBJID,
                           targetid = edge_id,
                           targetos = edge_os );
    EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

    sts = om$send(msg = message EMSsurface.EMgetactiveid(&msg,
                              &srf_ownr, NULL),
			senderid = NULL_OBJID,
                        targetid = srfid,
                        targetos = edge_os);
    EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

    if(srf_ownr.objid == srfid )
                single_surface = TRUE;
    else {
         sts = om$send (msg = message GRowner.GRget_number_components(
                         &ret_msg, &num_components),
		   senderid = NULL_OBJID,
                   targetid = srf_ownr.objid,
                   targetos = srf_ownr.osnum);
         EMomerr_hndlr(sts, ret_end, "GRget_number_components");
      
         if(num_components == 1)
                   single_surface = TRUE;
         else
                   single_surface = FALSE;
    }

    if(single_surface) {
        ex$message ( msgnumb = EMS_S_SingleSurfNotAllowed);
	sts = 0;
	goto ret_end;
    }
    if(!numtmp_ed && !num_ed) {
       active_grid->objid = srf_ownr.objid;
       active_grid->osnum = srf_ownr.osnum;
	sts = 1;
	goto ret_end;
    }
    else if((active_grid->objid != srf_ownr.objid) ||
            (active_grid->osnum != srf_ownr.osnum)) {
         ex$message ( msgnumb = EMS_S_EdgePartDiffComposite );
	 sts = 0;
         goto ret_end;
    }
  ret_end:
   return(sts);
}

void EFrestore_hilite_of_edges(numed,numtmped,located_obj,tmp_located_obj,
			  selection,md_env,bnd_code)
IGRint numed;
IGRint numtmped;
GRobjid *located_obj;
GRobjid *tmp_located_obj;
IGRint selection;
struct GRmd_env md_env;
IGRushort *bnd_code;
{
   enum GRdpmode display_mode;
   IGRint ii;
   IGRlong sts,msg;
   GRobjid  srfid;
   struct DPele_header     srf_ele_header;
   union IGRele_attr       ele_spec_att;
   GRrange                 range;
   struct IGResqbs         bsqsurf;
   struct GRsymbology      symb;
 
     display_mode = GRhe;
     sts = OM_S_SUCCESS;
     for(ii = 0; ii< numed; ii++) {
     sts = EFhilite_edge_with_weight( &msg, md_env,
                      located_obj[ii], display_mode );
     EMomerr_hndlr (sts, ret_end, "EFhilite_edge");  
     }
     for(ii = 0; ii< numtmped; ii++) {
     sts = EFhilite_edge_with_weight( &msg, md_env,
                      tmp_located_obj[ii], display_mode );
     EMomerr_hndlr (sts, ret_end, "EFhilite_edge");  
     }
     display_mode = GRhd;
     for(ii = 0; ii< numed ; ii++) {
	if(bnd_code[ii] & EMSrnd_mark_ed_deleted) continue;
 	/* Get the surface to which this edge belongs to */
       sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                          (&msg, &srfid, NULL),
                    targetid = located_obj[ii],
                    senderid = NULL_OBJID,
                    targetos = md_env.md_id.osnum );
       EMomerr_hndlr (sts, ret_end, "EMsubbs.EMget_ele_header");  
       /* Get the element header for the surface */
       ele_spec_att.bsqsurf = &bsqsurf;
       sts = om$send (msg = message EMSsubbs.EMget_ele_header(&msg,
                         NULL,&md_env.md_env, NULL,
                         &srf_ele_header, range,
                         &symb.display_attr, ele_spec_att, NULL),
             targetid = srfid,
             senderid = NULL_OBJID,
             targetos = md_env.md_id.osnum);
       EMomerr_hndlr (sts, ret_end, "EMsubbs.EMget_ele_header");  

       sts = om$send(msg = message EMSedge.EMdisplay(&msg, &srf_ele_header,
                  &md_env.md_env.matrix_type, md_env.md_env.matrix, 
		  &display_mode, NULL, EMS_WHL_EDGE,
                  NULL),
		  senderid = NULL_OBJID,
                  targetid = located_obj[ii],
                  targetos = md_env.md_id.osnum);
       EMomerr_hndlr(sts, ret_end, "EMdisplay");
     }
       display_mode = (selection) ? GRhd : GRhe ;
       for(ii = 0; ii < numtmped; ii++) {
 	/* Get the surface to which this edge belongs to */
         sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                          (&msg, &srfid, NULL),
                    targetid = tmp_located_obj[ii],
                    senderid = NULL_OBJID,
                    targetos = md_env.md_id.osnum );
         EMomerr_hndlr (sts, ret_end, "EMsubbs.EMget_ele_header");  

         /* Get the element header for the surface */
         ele_spec_att.bsqsurf = &bsqsurf;
         sts = om$send (msg = message EMSsubbs.EMget_ele_header(&msg,
                         NULL,&md_env.md_env, NULL,
                         &srf_ele_header, range,
                         &symb.display_attr, ele_spec_att, NULL),
             targetid = srfid,
             senderid = NULL_OBJID,
             targetos = md_env.md_id.osnum);
         EMomerr_hndlr (sts, ret_end, "EMsubbs.EMget_ele_header");  

         sts = om$send(msg = message EMSedge.EMdisplay(&msg, &srf_ele_header,
                        &md_env.md_env.matrix_type, md_env.md_env.matrix, 
		        &display_mode, NULL, EMS_WHL_EDGE,
                        NULL),
		       senderid = NULL_OBJID,
                       targetid = tmp_located_obj[ii],
                       targetos = md_env.md_id.osnum);
         EMomerr_hndlr(sts, ret_end, "EMdisplay");
       }

ret_end:
   return;
}


end implementation ECsfedloc; 
