/* ###################   APOGEE COMPILED   ################## */
class implementation ECaddraft;

#include "EMS.h"
#include "OMerrordef.h"

#define SURFACES_AND_EDGES_OR_CRVS_OR_SURFS 0
#define SURFACE_AND_SURFACES                1
#define SURFACE_AND_LOOPS                   2

/*** STATES  *****/
#define LOCATE_SURF_OR_PLANE_OR_LOOP        0
#define GET_ANGLE                   1
#define STUFF_ANGLE                 2
#define DISPLAY_AND_GET_DIRECTION   3
#define ADD_DRAFT                   4
#define UNDO  5

/*** ACTIONS ****/
#define GET_PLANE_OR_DATUM 0
#define GET_SURF_TO_DRAFT  1
#define GET_FACE_LOOP  2
#define GET_SURF_WITH_EDGE 3

/***** FORM LABLES *****/
#define SURFACE_SURFACE 16
#define SURFACE_LOOP 18
#define EDGE_SURFACE 20
#define EXIT            1
#define CON_TO_WINDOW   5

#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    *response = TERMINATE;\
    ex$message(msgnumb = EMS_F_0002)\
    return(OM_E_ABORT);\
   }\
 }


/* This method handles all the input that the gadget(s) of form received */

method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
        IGRdouble value)
{
   	IGRlong  	msg_loc, sts, event_size;
   	IGRint  	response;
   	struct GRevent  event;
   	int 		ret, sel_flag, r_pos;
   	IGRdouble 	dvalue;

   	sts = OM_S_SUCCESS;
   	event_size = sizeof(struct GRevent);

 	if (form_label == 1) {
   	  switch(gadget_label) {
	    case SURFACE_SURFACE:
          	FIg_set_state_on(ME.ECaddraft->form1, SURFACE_SURFACE);
          	FIg_set_state_off(ME.ECaddraft->form1, SURFACE_LOOP);
          	/* FIg_set_state_off(ME.ECaddraft->form1, EDGE_SURFACE ); */
                      me->add_draft_type = SURFACE_AND_SURFACES;
                      me->action = GET_PLANE_OR_DATUM ;
                      me->cmd_typ = GET_SURF_TO_DRAFT;
                      ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
		      ex$message(msgnumb = EMS_S_SurfOptSel);
               ex$message(msgnumb = EMS_P_AcceptWithSurfToDraft,
                         buff    = me->accept_prompt);
		break;

	    case SURFACE_LOOP:
          	FIg_set_state_off(ME.ECaddraft->form1, SURFACE_SURFACE);
          	FIg_set_state_on(ME.ECaddraft->form1, SURFACE_LOOP);
          	/* FIg_set_state_off(ME.ECaddraft->form1, EDGE_SURFACE ); */
                      me->add_draft_type = SURFACE_AND_SURFACES;
                      me->cmd_typ = GET_FACE_LOOP;
                      me->action = GET_PLANE_OR_DATUM ;
                      ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
		      ex$message(msgnumb = EMS_S_LoopOptSel);
                ex$message(msgnumb = EMS_P_AcceptWithFace,
                          buff    = me->accept_prompt);
		break;

	    case EDGE_SURFACE:
          	FIg_set_state_on(ME.ECaddraft->form1, SURFACE_SURFACE);
          	FIg_set_state_off(ME.ECaddraft->form1, SURFACE_LOOP);
          	/* FIg_set_state_on(ME.ECaddraft->form1, EDGE_SURFACE ); */
                      me->action = GET_SURF_WITH_EDGE;
                      me->add_draft_type = SURFACES_AND_EDGES_OR_CRVS_OR_SURFS;
                      ME.super_cmd->state =  LOCATE_SURF_OR_PLANE_OR_LOOP;
                      me->cmd_typ =  GET_SURF_WITH_EDGE;
                      break;

      	    case EXIT:
          	FIf_erase(ME.ECaddraft->form1);
	  	me->form_displayed = FALSE;
	  	break;

	    default:
		break;
   	   } /* switch */
	}
ret_end:
   return(sts);

} /* do_form */

IGRint ECaddraft_process_form(form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{
 	IGRint 		stat_func, stat_OM;
  	IGRlong 	msg_loc;
  	GRobjid 	cmdobj;
  	GRspacenum 	cmdos;

  	stat_OM = OM_S_SUCCESS;

  	stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  	if (stat_func)
    		return (OM_E_ABORT);
  
  	stat_OM = om$send (msg = message ECaddraft.do_form
             (&msg_loc, form_label, gadget_label, value),
             	senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  	if(! (stat_OM & 1))
   		return (OM_E_ABORT);
    	return(OM_S_SUCCESS);
}

/* This method sets up the instance data needed by the form_input method */

method status_disp()
{
	IGRlong  	msg_loc, sts;
	IGRint 		ret;
	IGRint 		ECplhole_process_form();

	sts = msg_loc = OM_S_SUCCESS;

	/* Invoke the form only when the diameter is being asked */
	if(ME.super_cmd->state == 0 &&
               me->action==0 ){
    		if(!ME.ECaddraft->form1) {
			ret = FIf_new(1, "EMAddDraft", 
                          ECaddraft_process_form, &ME.ECaddraft->form1);
			if(ret) return (OM_E_ABORT);
                /** default***/
    		}
		ret = FIf_set_cmd_oid_os(ME.ECaddraft->form1, my_id, 
			OM_Gw_current_OS);
		if (ret) return (OM_E_ABORT);

		ret = FIf_display (ME.ECaddraft->form1);
		if(ret) return (OM_E_ABORT);
		if(me->cmd_typ == GET_FACE_LOOP)
		 {
                FIg_set_state_off(ME.ECaddraft->form1, SURFACE_SURFACE);
                FIg_set_state_on(ME.ECaddraft->form1, SURFACE_LOOP);
		me->form_displayed = TRUE;
		 }
		else{
                FIg_set_state_on(ME.ECaddraft->form1, SURFACE_SURFACE);
                FIg_set_state_off(ME.ECaddraft->form1, SURFACE_LOOP);
        /*      FIg_set_state_off(ME.ECaddraft->form1, EDGE_SURFACE ); */
		me->form_displayed = TRUE;
		   }
	}
	return(sts);
} /* status_disp */

end implementation ECaddraft;

