class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "griodef.h"
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dimlocate.h"

#include "msdef.h"		/* MSSUCC, MSFAIL */
#include "maerr.h"		/* MANOMEMORY */
#include "grgs.h"		/* GRobj_env */
#include "grownerdef.h"		/* GR_LC_RIGID */
#include "grgsmacros.h"		/* gr$gsget_fence() macro */
#include "OMmacros.h"		/* OM_BLOCK_MOVE() macro */
#include "msmacros.h"
#include "DMmsg.h"

extern OMuword  OPP_GRowner_class_id,
                OPP_GRgrset_class_id,
                OPP_expression_class_id;

from GRgrset import GSinqcount, GSget_object;
from COdim import LC_selection, LC_preproc, LC_postproc, LC_dynamics;

extern GRclassid OPP_GRgraphics_class_id;

IGRint DMis_comp_crv (grid)
/*(
	 struct GRid  grid
	)
*/
struct GRid grid;
/*.DMis_comp_crv*/
{ 
	IGRint status;
	GRclassid obj_class_id;
	GRclassid sup_class_id;

	/*"Get classid of %d, %d\n", grid.objid, grid.osnum*/

	status =
	om$get_classid(
		classname = "GRcompcurve",
		p_classid = &sup_class_id );

	if (sup_class_id != NULL_OBJID && status == OM_S_SUCCESS) 
	{
		status =
		om$get_classid(
			osnum = grid.osnum,
			objid = grid.objid,
			p_classid = &obj_class_id );
		dm$status(action = RET_STATUS);

		/*"class_id = %d\n", obj_class_id*/

		return (om$is_ancestry_valid(
			subclassid   = obj_class_id,
			superclassid = sup_class_id) == OM_S_SUCCESS);
	}
	else
	{
		/*| - Composite curve does not exist - */

		return(FALSE);
	}
}

IGRint DMaction_handler (act_parms,
			 new_entry,
			 locate_args,
			 action)
			 /*(
	 struct DMact_info  *act_parms,
	 struct GRlc_info  *new_entry,
	 struct LC_action_args  *locate_args,
	 IGRchar  *action
	)
	*/
struct DMact_info 	*act_parms;
struct GRlc_info 	*new_entry;
struct LC_action_args   *locate_args;
IGRchar 		*action;
/*.DMaction_handler*/
{
	IGRint status, loc_status, rc;
    IGRboolean aflag = 0;
    if(aflag = pwIsActivationOn())
    {
     GRspacenum osn;
     osn = pwGetActiveOs();
     if( osn != new_entry->located_obj.osnum)
      return(1);
    } 
     

	/*"action=%d\n", *action*/

	if(*action == start_transition || *action == end_transition)
	{
		/*| - Begin or End Transition - */

		loc_status =
		LCptlocact(
			&act_parms->stack,
			new_entry,
			locate_args,
			action);
		return(loc_status);
	}

	/*^ print_grid("located_obj", &new_entry->located_obj) */

	status =
	om$send(msg = message COdim.LC_selection(
					&rc,
					new_entry),
		senderid = NULL_OBJID,
		targetid = act_parms->cmd.objid,
		targetos = act_parms->cmd.osnum);
	if (!rc)
		return(LC_RELOCATE);

	status =
	om$send(msg = message COdim.LC_preproc(&rc, new_entry),
		senderid = NULL_OBJID,
		targetid = act_parms->cmd.objid,
		targetos = act_parms->cmd.osnum);
	if (!(status&1))
	{
		dm$status();
		return(LC_RELOCATE);
	}

	/*| go on locate process */

	loc_status =
	LCptlocact(
		&act_parms->stack,
		new_entry,
		locate_args,
		action);

	status =
	om$send(msg = message COdim.LC_postproc(),
		senderid = NULL_OBJID,
		targetid = act_parms->cmd.objid,
		targetos = act_parms->cmd.osnum);
	dm$status(action = RET_STATUS);

	/*"action=%d, loc_status=%d\n", *action, loc_status*/

	return(loc_status);
}

IGRint DMlocate (rc,
		 event1,
		 event2,
		 mask1,
		 mask2,
		 display_flag,
		 response,
		 response_data,
		 locate_prompt,
		 acc_prompt,
		 relocate_prompt,
		 attributes,
		 act_parms,
		 hand_dyn)
IGRlong *rc;		/*	   Return code from ls$locate   */
struct GRevent *event1;		/*   Event for the locate point   */
struct GRevent *event2;	/*	   Event for the accept point   */
IGRlong *mask1;			/*   Mask for the locate   */
IGRlong *mask2;			  /* Mask for the input events*/   
IGRlong display_flag;	/*	   Flag to define the display mode  */ 
IGRint *response;
IGRchar *response_data;
IGRchar *locate_prompt;
IGRchar *acc_prompt;
IGRchar *relocate_prompt;
struct GRlc_locate *attributes; /*  Attributes to be found   */
struct DMact_info *act_parms; /*  Action handler parameters   */
struct GRlc_dynamics *hand_dyn; /*   Function & args for dynamics */  
/*.DMlocate*/
{
	IGRlong status, msg;
	struct GRevent locevt;
	OM_S_CLASSLIST	classlist;
	OMuword class;

	classlist.w_count = 1;
	classlist.w_flags = OM_CLST_subclass;
	classlist.p_classes = &class;

	class = OPP_GRgraphics_class_id;

	/*| Before lc$locate */

	status =
	lc$locate(
		rc = rc,
		event1 = event1,
		event2 = event2,
		event3 = &locevt,
		mask1 = mask1,
		mask2 = mask2,
		display_flag = display_flag,
		hilight_mode = GRhd,
		unhilight_mode = GRhe,
		response = response,
		response_data = response_data,
		locate_prompt = locate_prompt,
		acc_prompt = acc_prompt,
		relocate_prompt = relocate_prompt,
		attributes = attributes,
		stack = &act_parms->stack,
		dyn = (hand_dyn->GRlc_dyn)?hand_dyn:NULL,
		act_handler = DMaction_handler,
		eligible_classes = &classlist,
		act_args = act_parms);
	dm$status(action = RET_STATUS);

	/*| After lc$locate */

	if (!(display_flag & LC_ERASE_LOC_ELEMENT))
		dp$erase_hilite(msg = &msg);

	/*^
		printf("status = %d, rc = %d\n", status, *rc);
		printf("response: %d\n", *response);

		printf("event1: grid=%d, %d, num_id=%d\n",
				event1->located_object[0].located_obj.objid,
				event1->located_object[0].located_obj.osnum,
				event1->num_id);

		printf("event2: grid=%d, %d, num_id=%d\n",
				event2->located_object[0].located_obj.objid,
				event2->located_object[0].located_obj.osnum,
				event2->num_id);

		printf("locevt: grid=%d, %d, num_id=%d\n",
				locevt.located_object[0].located_obj.objid,
				locevt.located_object[0].located_obj.osnum,
				locevt.num_id);
	*/

	if (*rc == LC_OBJ_LOCATED)
	{
		event1->num_id = locevt.num_id;
		event1->located_object[0] = locevt.located_object[0];
	}

	return(TRUE);
}

IGRint DMlocate_dynamics (grid,
			  event,
			  cmd)
			  /*(
	 struct GRid  *grid,
	 struct GRevent  *event,
	 struct GRid  *cmd
	)
	*/
struct  GRid 		*grid;
struct  GRevent		*event;
struct  GRid		*cmd;
/*.DMlocate_dynamics*/
{
	IGRint status, rc;

	/*^
		print_grid("grid", grid);
		printf("response=%d\n", event->response);
		printf("locate_pt=%lf,%lf,%lf\n",
				event->event.button.x,
				event->event.button.y,
				event->event.button.z);
	*/

	status =
	om$send(msg = message COdim.LC_dynamics(&rc, grid, event),
		senderid = NULL_OBJID,
		targetid = cmd->objid,
		targetos = cmd->osnum);
	dm$status(action = RET_STATUS);

	return(TRUE);
}

IGRint DMupdate_event (event)
/*(
	 struct GRevent  *event
	)
	*/
struct GRevent *event;
/*.DMupdate_event*/
{
        int sts;
	struct GRlc_info *lc_info;

	lc_info   = event->located_object;

	/*^
		print_grid("LOC_ID_0", &lc_info[0].located_obj);
		print_grid("LOC_ID_1", &lc_info[1].located_obj);
	*/

	sts = om$is_objid_valid(objid = lc_info[0].geom_parms.leaf_id.objid,
                                osnum = lc_info[0].geom_parms.leaf_id.osnum);
        if (sts & 1)
		lc_info[0].located_obj = lc_info[0].geom_parms.leaf_id;

	sts = om$is_objid_valid(objid = lc_info[1].geom_parms.leaf_id.objid,
                                osnum = lc_info[1].geom_parms.leaf_id.osnum);
        if (sts & 1)
		lc_info[1].located_obj = lc_info[1].geom_parms.leaf_id;

	/*^
		print_grid("UPD_ID_0", &lc_info[0].located_obj);
		print_grid("UPD_ID_1", &lc_info[1].located_obj);
	*/

	return(OM_S_SUCCESS);
}

IGRint DMget_fence_objects (msg,
			    md_env,
			    set_id,
			    num_obj,
			    objects,
			    response,
			    response_data)
			    /*(
	 IGRlong  *msg,
	 struct GRmd_env  *md_env,
	 struct GRid  set_id,
	 IGRlong  *num_obj,
	 struct GRid  **objects,
	 IGRlong  *response,
	 IGRchar  *response_data
	)
	*/
IGRlong *msg, *num_obj, *response;
IGRchar *response_data;
struct GRmd_env *md_env;
struct GRid set_id, **objects;
{
	IGRlong status, i, input_mask;
	struct GRevent grevent;
	static IGRint TokenList[] = {DATA, RESET, GR_UNKNOWN_TYPE};
	IGRint token, size;

	*msg = MSSUCC;
	*objects = NULL;
	*num_obj = 0;

	/* Determine the classid of the input object */

	*objects = (struct GRid *) malloc (sizeof (struct GRid));

	if (!*objects) 
	{
		*msg = MANOMEMORY;
		return(OM_S_SUCCESS);
	}

	if (DMancestry_valid(set_id, OPP_GRgrset_class_id))
	{
		IGRlong obj_flag, loc_msg, obj_count;
		struct GRid fence_id;
		struct GRobj_env lc_obj;

		obj_count = 0;

		status=
		om$send (msg = message GRgrset.GSinqcount(
						   msg,
						   (IGRint *) &obj_count),
                        senderid = NULL_OBJID,
			targetid = set_id.objid,
			targetos = set_id.osnum);
		dm$status(action = RET_STATUS);

		if(!obj_count) return(FALSE);

		*objects = (struct GRid *) realloc (*objects, obj_count *
				             sizeof (struct GRid));

		if (!*objects)
		{
			*msg = MANOMEMORY;
			return(OM_S_SUCCESS);
		}

		/* Get the active fence id, if any */

		gr$gsget_fence(msg = &loc_msg, fence_id = &fence_id);
		if (!(1 & loc_msg))
		{
			fence_id.objid = NULL_OBJID;
			fence_id.osnum = 0;
		}

		for (i=0; i<obj_count; i++)
		{
			obj_flag = 0;

			status = 
			om$send(msg = message GRgrset.GSget_object(
						msg,
						&lc_obj,
						sizeof (struct GRobj_env),
						(IGRint *) &obj_flag,
						i, i),	/* From i To i */
			      senderid = NULL_OBJID,
			      targetid = set_id.objid,
			      targetos = set_id.osnum);
			if (!(status & *msg & 1) || (obj_flag != 1))
			{
				*msg = MSFAIL;
				return(FALSE);
			}

			if (!((lc_obj.obj_id.objid == fence_id.objid)
			&&   (lc_obj.obj_id.osnum == fence_id.osnum)))
			{
				DMget_dim_grid(
					lc_obj.obj_id,
					md_env,
					*objects,
					(int *) num_obj,
					TRUE);
			}
		}	/* for (i = 0; i < obj_count; i++) */

		if (*num_obj == 0)
		{
			free (*objects);
			*objects = NULL;
		}
	  
		if(*num_obj)
		{
			size = sizeof(struct GRevent);
			ex$message(msgnumb = DM_P_Ac);
			token = GRget_token(
					&msg,
					TokenList,
					&input_mask,
				    	&grevent,
					&size, 
				    	response,
					response_data);
			dp$erase_hilite(msg = &status);
			if(*response != DATA) *num_obj = 0;
		}
	}
     	else
	{
     		DMget_dim_grid(set_id,md_env,*objects,(int *) num_obj,FALSE);
	}

	return(OM_S_SUCCESS);
}

IGRint DMget_dim_grid (lc_grid ,
		       md_env,
		       objects,
		       num_obj,
		       hilite)
		       /*(
	 struct GRid  lc_grid ,
	 struct GRmd_env  *md_env,
	 struct GRid  *objects,
	 int  *num_obj,
	 int  hilite
	)
	*/
struct GRid lc_grid ,*objects;
int *num_obj, hilite;
struct GRmd_env *md_env;
{
	int count,status;
	long long_rc;
	struct GRid temp_grid;
	OM_S_CHANSELECT chan;
	enum GRdpmode mode = GRhd;
	int show_dim;

	if (DMancestry_valid(lc_grid, OPP_DMroot_class_id))
	{
		objects[*num_obj] = lc_grid;
		(*num_obj) ++;
		show_dim =1;
     	} 
	else if (DMancestry_valid(lc_grid, OPP_expression_class_id)) 
	{
		om$make_chanselect(channame = "GRcmpowner.to_components",
                               p_chanselect =&chan);

		status = 
		om$get_channel_count(
				objid = lc_grid.objid,
				osnum = lc_grid.osnum,
				count = (OMuint *) &count,
				p_chanselect = &chan);
		dm$status(action = RET_STATUS)

		if (!count) return(FALSE);

		om$get_objid_at_index(
			 objid = lc_grid.objid,
			 osnum = lc_grid.osnum,
			 p_chanselect = &chan,
			 index = 0,
			 objidaddr = &temp_grid.objid,
			 osnumaddr = &temp_grid.osnum);
		dm$status (action = RET_STATUS);
           
		if (DMancestry_valid (temp_grid, OPP_DMroot_class_id))
		{
			objects[*num_obj] = temp_grid;
			(*num_obj)++;
			show_dim =1;
		}
	}

	if (show_dim && hilite)
	{
	     	status =
     		om$send(msg = message GRgraphics.GRdisplay(
						&long_rc,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						&mode,
						&md_env->md_id),
			senderid = NULL_OBJID,
			targetid=objects[*num_obj -1].objid,
			targetos=objects[*num_obj -1].osnum);
	     	dm$status(action = RET_STATUS);
	}

	return(TRUE);
}
DMreturn_locate_dim_element(msg, return_grid)
IGRint *msg;
struct GRid *return_grid;
{
  IGRint status;
  struct GRevent event1,event2;
  IGRlong mask1;			/*   Mask for the locate   */
  IGRlong mask2;			  /* Mask for the input events*/   
  IGRlong display_flag;	/*	   Flag to define the display mode  */ 
  IGRint response;
  IGRchar response_data[1024];
  IGRchar locate_prompt[80];
  IGRchar acc_prompt[80];
  IGRchar relocate_prompt[80];
  struct GRlc_stack stack;
  struct GRlc_locate attributes; /*  Attributes to be found   */
  OM_S_CLASSLIST	classlist;
  OMuword class;



  mask1 =  mask2 = GRm_DATA | GRm_RESET | GRm_BACK_UP;
  display_flag = ELEM_HILIGHT | ALL_WINDOWS |
                 NO_PROJ_ACCEPT_POINT | LC_INPUT_LOC_POINT;
  strcpy(locate_prompt,"Identify datum dim for highlighted  dimension");
  UI_status("Identify zero dim for highlighted  dimension");
  strcpy(acc_prompt,"Accept/Reject");
  strcpy(relocate_prompt,"Datum dimension not found");

  attributes.properties =   LC_LC_ONLY | LC_DP_ONLY | LC_RW;
  attributes.owner_action = LC_READ  | LC_NO_REF_HEADER |
                      LC_REF_OBJECTS | LC_HANDLES;

  classlist.w_count = 1;
  classlist.w_flags = OM_CLST_subclass;
  classlist.p_classes = &class;

  class = OPP_GRgraphics_class_id;
  stack.num_entries = 0;
  status =
  lc$locate( rc = msg,
	    event1 = &event1,
	    event2 = &event2,
	    mask1 = mask1,
	    mask2 = mask2,
	    display_flag = display_flag,
	    hilight_mode = GRhd,
	    unhilight_mode = GRhe,
	    response = &response,
	    response_data = response_data,
	    locate_prompt = locate_prompt,
	    acc_prompt = acc_prompt,
	    relocate_prompt = relocate_prompt,
	    attributes = &attributes,
	    stack = &stack,
	    dyn = NULL,
	    act_handler = NULL,
	    eligible_classes = &classlist);
  dm$status(action = RET_STATUS);

  if( *msg == LC_OBJ_LOCATED)
    *return_grid = event2.located_object[0].located_obj;
  return( OM_S_SUCCESS);
}

end implementation DMroot;
