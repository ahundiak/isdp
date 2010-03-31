/* ###################   APOGEE COMPILED   ################## */
class implementation ECsfedloc;

/* 
    DESCRIPTION

	Form interface for round edge/vertex command. 
	The main form consists of
		5 icons for edge selection types
		1 toggle between select & de-select option
		1 toggle to output fillets
		1 keyin to define tangent value
		1 icon which enables pull down menu
		2 status form manipulation icons
	The sub-form consists of 2 buttons to select between constant &
	varying radius.

    HISTORY:

    	Tapadia 15/12/92 - Genesis	
        Prashant 07/15/96  Added subform_displayed in case FILLET_OPTION 
                           within method do_form (in response to TR#
                           119528639 & TR# 119305803)                             
*/

#if DEBUG
#include <stdio.h>
#endif

#ifndef OMmacros_include
#include "OMmacros.h"
#endif

#ifndef igrtypedef_include
#include "igrtypedef.h"
#endif

#ifndef igrdef_include
#include "igrdef.h"
#endif

#ifndef igrdp_include
#include "igrdp.h"
#endif

#ifndef igewinmacros_include
#include "igewinmacros.h"
#endif

#ifndef exmacros_include
#include "exmacros.h"
#endif

#ifndef exdef_include
#include "exdef.h"
#endif

#ifndef griomacros_include
#include "griomacros.h"
#endif

#include "comisc.h"
#include "EC_M.h"
#include "EC_E.h"

%safe
static IGRboolean save_restore = FALSE;
%endsafe

/* define the gadget label for form */
#define FORM       	1 
#define SUB_FORM	2 
#define VARY_INDEX      50
#define CONS_INDEX      49

#define ROUND_OPER	2

#define FILLET_OPTION	19
#define SELECT		11
#define EDGE_VERTEX	12
#define SURFACE_LOOP	13
#define CHAIN		14
#define FILLET		15
#define RADII		16
#define TANGENT_EDGE	23

#define CONSTANT	11
#define VARYING		13

#define EXIT		1
#define CON_TO_WIN	5

#define CHAIN_TYPE		1
#define EDGE_VERTEX_TYPE	2
#define SURFACE_LOOP_TYPE	3
#define FILLET_TYPE		4
#define RADII_TYPE		5
#define CONSTANT_TYPE		6
#define VARYING_TYPE		7
#define SELECT_TYPE		8

#ifndef DEBUG
#define DEBUG 0  /* Set to 1 if want error strings printed. */
#endif

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
{ \
   if(! (1 & sts_stupid & error_number)) \
   { \
      printf("\n%s\n", error_message); \
      goto ret_end; \
   } \
}
#else
#define ERROR(sts_stupid, error_number, error_message)\
{ \
   if(! (1 & sts_stupid & error_number))  goto ret_end; \
}
#endif

/* 

DESCRIPTION
	This method handles all the input that the gadget(s) of form received.
	Based on the edge selection or fillet type or selection/deselection
	it activates or deactivates the gadgets.
	A sub form is invoked when the user selects the fillet type gadget.

OPTIONS

ALGORITHM

*/
	
method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
        IGRdouble value)
{
   	IGRlong  	msg_loc, sts, event_size;
   	IGRint  	response;
   	struct GRevent  event;
   	int 		ret, sel_flag, r_pos;
   	IGRdouble 	dvalue;
	IGRint 		ECplround_process_form();
	IGRint 		sym_index;

   	sts = OM_S_SUCCESS;
   	event_size = sizeof(struct GRevent);

 	if (form_label == FORM) {
   	  switch(gadget_label) {

	    case CHAIN:
		if(me->valid_inputdata) {
	  	me->edge_type = CHAIN_TYPE; 
		me->option_change = TRUE;
          	FIg_set_state_on(ME.ECsfedloc->form, CHAIN);
          	FIg_set_state_off(ME.ECsfedloc->form, EDGE_VERTEX);
          	FIg_set_state_off(ME.ECsfedloc->form, SURFACE_LOOP);
          	FIg_set_state_off(ME.ECsfedloc->form, FILLET);
          	FIg_set_state_off(ME.ECsfedloc->form, RADII);
		response = EX_FORM_FINISHED;
                event.response = EX_FORM_FINISHED;
                sts = ex$putque(msg = &msg_loc, response = &response,
                        byte = &event_size, buffer = (char *)&event);
                ERROR(sts, msg_loc, "In form_input: SAVE error");
		}
		break;

	    case EDGE_VERTEX:
		if(me->valid_inputdata) {
	  	me->edge_type = EDGE_VERTEX_TYPE; 
		me->option_change = TRUE;
          	FIg_set_state_off(ME.ECsfedloc->form, CHAIN);
          	FIg_set_state_on(ME.ECsfedloc->form, EDGE_VERTEX);
          	FIg_set_state_off(ME.ECsfedloc->form, SURFACE_LOOP);
          	FIg_set_state_off(ME.ECsfedloc->form, FILLET);
          	FIg_set_state_off(ME.ECsfedloc->form, RADII);
		response = EX_FORM_FINISHED;
                event.response = EX_FORM_FINISHED;
                sts = ex$putque(msg = &msg_loc, response = &response,
                        byte = &event_size, buffer = (char *)&event);
                ERROR(sts, msg_loc, "In form_input: SAVE error");
		}
		break;

	    case SURFACE_LOOP:
		if(me->valid_inputdata)  {
	  	me->edge_type = SURFACE_LOOP_TYPE; 
		me->option_change = TRUE;
          	FIg_set_state_off(ME.ECsfedloc->form, CHAIN);
          	FIg_set_state_off(ME.ECsfedloc->form, EDGE_VERTEX);
          	FIg_set_state_on(ME.ECsfedloc->form, SURFACE_LOOP);
          	FIg_set_state_off(ME.ECsfedloc->form, FILLET);
          	FIg_set_state_off(ME.ECsfedloc->form, RADII);
		response = EX_FORM_FINISHED;
                event.response = EX_FORM_FINISHED;
                sts = ex$putque(msg = &msg_loc, response = &response,
                        byte = &event_size, buffer = (char *)&event);
                ERROR(sts, msg_loc, "In form_input: SAVE error");
		}
		break;

      	    case FILLET:
		if(me->valid_inputdata) {
	  	me->edge_type = FILLET_TYPE; 
		me->option_change = TRUE;
          	FIg_set_state_off(ME.ECsfedloc->form, CHAIN);
          	FIg_set_state_off(ME.ECsfedloc->form, EDGE_VERTEX);
          	FIg_set_state_off(ME.ECsfedloc->form, SURFACE_LOOP);
          	FIg_set_state_on(ME.ECsfedloc->form, FILLET);
          	FIg_set_state_off(ME.ECsfedloc->form, RADII);
		response = EX_FORM_FINISHED;
                event.response = EX_FORM_FINISHED;
                sts = ex$putque(msg = &msg_loc, response = &response,
                        byte = &event_size, buffer = (char *)&event);
                ERROR(sts, msg_loc, "In form_input: SAVE error");
		}
		break;

      	    case RADII:
		if(me->valid_inputdata) {
	  	me->edge_type = RADII_TYPE; 
		me->option_change = TRUE;
          	FIg_set_state_off(ME.ECsfedloc->form, CHAIN);
          	FIg_set_state_off(ME.ECsfedloc->form, EDGE_VERTEX);
          	FIg_set_state_off(ME.ECsfedloc->form, SURFACE_LOOP);
          	FIg_set_state_off(ME.ECsfedloc->form, FILLET);
          	FIg_set_state_on(ME.ECsfedloc->form, RADII);
		response = EX_FORM_FINISHED;
                event.response = EX_FORM_FINISHED;
                sts = ex$putque(msg = &msg_loc, response = &response,
                        byte = &event_size, buffer = (char *)&event);
                ERROR(sts, msg_loc, "In form_input: SAVE error");
		}
		break;

      	    case TANGENT_EDGE: /* Allows us to key in neutral edge angle */
		if(me->valid_inputdata){
      		ret = FIfld_get_value(ME.ECsfedloc->form, TANGENT_EDGE, 0, 0, 
				&dvalue, &sel_flag, &r_pos);
	  	if(dvalue <= 0 || dvalue > 30)
			ex$message(msgnumb = EMS_E_InvalidAngle)
	  	else  me->neutral_edge_angle = dvalue;
		}
	        break;

	    case SELECT:
		if(me->valid_inputdata){
		me->selection = !me->selection;
		response = EX_FORM_FINISHED;
                event.response = EX_FORM_FINISHED;
                sts = ex$putque(msg = &msg_loc, response = &response,
                        byte = &event_size, buffer = (char *)&event);
                ERROR(sts, msg_loc, "In form_input: SAVE error");
		}
		break;


	    /* This invokes a sub-form  that allows the user to select either
	    constant/varying fillet*/

	    case FILLET_OPTION:	
  
                {
                IGRint xpos, ypos,sts;
		if(me->valid_inputdata) {
		ret = FIf_new(SUB_FORM, "EMRoundSub", ECplround_process_form,
	    		&ME.ECsfedloc->sub_form);
		if(ret) return (OM_E_ABORT);
                me->subform_displayed = TRUE ;


		ret = FIf_set_cmd_oid_os(ME.ECsfedloc->sub_form, my_id, 
			OM_Gw_current_OS);
		if (ret) return (OM_E_ABORT);

          	FIg_set_state_off(ME.ECsfedloc->form, FILLET_OPTION);
     
                sts = FIf_get_location(me->form,&xpos,&ypos);
                sts = FIf_set_location(me->sub_form,xpos+3,ypos+40);

		if(me->fillet_type == CONSTANT_TYPE)  
            	    FIg_set_state_on(ME.ECsfedloc->sub_form, CONSTANT);
		else if(me->fillet_type == VARYING_TYPE) 
          	    FIg_set_state_on(ME.ECsfedloc->sub_form, VARYING);
		ret = FIf_display(ME.ECsfedloc->sub_form);

		response = EX_FORM_FINISHED;
                event.response = EX_FORM_FINISHED;
                sts = ex$putque(msg = &msg_loc, response = &response,
                        byte = &event_size, buffer = (char *)&event);
                ERROR(sts, msg_loc, "In form_input: SAVE error");
		}
		break;
                }

	    case CON_TO_WIN:
		break;

      	    case EXIT:

          	FIf_erase(ME.ECsfedloc->form);

	  	me->form_displayed = FALSE;

	        if(me->edge_type == CHAIN || me->edge_type == EDGE_VERTEX)
	   	  me->option_change = TRUE;

      	  	response = EX_FORM_FINISHED;

      	  	event.response = EX_FORM_FINISHED;

      	  	sts = ex$putque(msg = &msg_loc, response = &response,
                  	byte = &event_size, buffer = (char *)&event);


      	  	ERROR(sts, msg_loc, "In form_input: SAVE error");


	  	break;

	    default:
		break;
   	   } /* switch */

	   /* Refresh the form to display the updated data */
	   if(me->valid_inputdata)  {

            if(me->form_displayed && gadget_label != FILLET_OPTION &&
                gadget_label != TANGENT_EDGE && gadget_label != CON_TO_WIN &&
                !save_restore) {
/*
                FIg_set_state_off(ME.ECsfedloc->form, FILLET_OPTION);
*/
                if(me->fillet_type == VARYING_TYPE && me->selection) {
                  if(me->edge_type == FILLET_TYPE ||
                        me->edge_type == RADII_TYPE) {
                    FIg_set_state_on(ME.ECsfedloc->form, EDGE_VERTEX);
                    me->edge_type = EDGE_VERTEX_TYPE;
                  }
                  FIg_set_state_off(ME.ECsfedloc->form, FILLET);
                  FIg_set_state_off(ME.ECsfedloc->form, RADII);
                  FIg_disable(ME.ECsfedloc->form, RADII);
                  FIg_disable(ME.ECsfedloc->form, FILLET);
                }
                else {
                  FIg_enable(ME.ECsfedloc->form, RADII);
                  FIg_enable(ME.ECsfedloc->form, FILLET);
                }
                FIg_set_value(ME.ECsfedloc->form, TANGENT_EDGE,
                                me->neutral_edge_angle);
         }
	}
       }

	/* Sub form selection (constant or varying) fillet radius */

	else if(form_label == SUB_FORM) {
   	  switch(gadget_label) {
	    case CONSTANT:
		if(me->valid_inputdata ) {
	  	me->fillet_type = CONSTANT_TYPE; 
            	FIg_set_state_on(ME.ECsfedloc->sub_form, CONSTANT);
          	FIf_erase(ME.ECsfedloc->sub_form);
          	FIg_enable(ME.ECsfedloc->form, RADII);
          	FIg_enable(ME.ECsfedloc->form, FILLET);
                response = EX_FORM_FINISHED;
                event.response = EX_FORM_FINISHED;
                sts = ex$putque(msg = &msg_loc, response = &response,
                        byte = &event_size, buffer = (char *)&event);
                ERROR(sts, msg_loc, "In form_input: SAVE error");
		}
		break;

	    case VARYING:
		if(me->valid_inputdata) {
	  	me->fillet_type = VARYING_TYPE; 
          	FIg_set_state_on(ME.ECsfedloc->sub_form, VARYING);
          	FIf_erase(ME.ECsfedloc->sub_form);
                if(me->selection) {
          	FIg_set_state_off(ME.ECsfedloc->form, FILLET);
          	FIg_set_state_off(ME.ECsfedloc->form, RADII);
          	FIg_disable(ME.ECsfedloc->form, RADII);
          	FIg_disable(ME.ECsfedloc->form, FILLET);
                }

		if((me->edge_type == FILLET_TYPE || 
		    me->edge_type == RADII_TYPE) && me->selection) {
          		FIg_set_state_on(ME.ECsfedloc->form, EDGE_VERTEX);
			me->edge_type = EDGE_VERTEX_TYPE;
		}
                response = EX_FORM_FINISHED;
                event.response = EX_FORM_FINISHED;
                sts = ex$putque(msg = &msg_loc, response = &response,
                        byte = &event_size, buffer = (char *)&event);
                ERROR(sts, msg_loc, "In form_input: SAVE error");
		}

		break;

	    default:
		break;
	  }
	  /* Refresh the main form */
	  if(me->valid_inputdata ) {
	  if(!save_restore) {
/*
                FIg_set_value(ME.ECsfedloc->form, TANGENT_EDGE,
                                me->neutral_edge_angle);
		FIg_get_symbol_index(ME.ECsfedloc->sub_form, CONSTANT, 
			&sym_index);	
*/
		if(me->fillet_type == VARYING_TYPE ) {
		FIg_set_symbol_index(ME.ECsfedloc->form, FILLET_OPTION,
			VARY_INDEX);
		}
                else {
		FIg_set_symbol_index(ME.ECsfedloc->form, FILLET_OPTION,
			CONS_INDEX);
                }
                FIg_display(ME.ECsfedloc->form, FILLET_OPTION);
	  }
	}
	} 
ret_end:
   return(sts);

} /* do_form */

IGRint ECplround_process_form(form_label, gadget_label, value, form_ptr)
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
  	if (stat_func) 	return(OM_E_ABORT);
 
  	stat_OM = om$send (msg = message ECsfedloc.do_form (&msg_loc, 
			form_label, gadget_label, value),
             	senderid = NULL_OBJID, 
		targetid = cmdobj, 
		targetos = cmdos);
  	if(!(stat_OM & 1)) return (OM_E_ABORT);
    	return(OM_S_SUCCESS);
}

/* This method sets up the instance data needed by the form_input method */

method status_disp()
{
	IGRlong	msg_loc, sts;
	IGRint 	ret, ECplround_process_form(), sym_index;

	sts = msg_loc = OM_S_SUCCESS;

        /*
         * This has to be removed in response to TR# 119528421 b'cause 
         * everytime whenever this method is called, form pointer is set 
         * to null, which is actually not reqd.
         */
         /*  ME.ECsfedloc->form = 0;  */

 
	/* Invoke the form only when the round operation (round edge/round 
	vertex is invoked & if the form is not already invoked */

	if(ME.super_cmd->mytype < ROUND_OPER && !me->form_displayed) {

    		if(!ME.ECsfedloc->form) {
			ret = FIf_new(FORM, "EMRoundEdge", 
				ECplround_process_form, &ME.ECsfedloc->form);
			if(ret) return (OM_E_ABORT);
			if(me->edge_type == CHAIN_TYPE)
          		    FIg_set_state_on(ME.ECsfedloc->form, CHAIN);
			else if(me->edge_type == EDGE_VERTEX_TYPE)
          		    FIg_set_state_on(ME.ECsfedloc->form, EDGE_VERTEX);
			else if(me->edge_type == SURFACE_LOOP_TYPE)
          		    FIg_set_state_on(ME.ECsfedloc->form, SURFACE_LOOP);
			else if(me->edge_type == FILLET_TYPE)
          		    FIg_set_state_on(ME.ECsfedloc->form, FILLET);
			else if(me->edge_type == RADII_TYPE)
          		    FIg_set_state_on(ME.ECsfedloc->form, RADII);
    		}
		else { /* this is invoked when the user changes the round type
							by keying in */
			IGRint form_lab = 1, gad_lab;
			gad_lab = CHAIN;
			if(me->edge_type == CHAIN_TYPE)
				gad_lab = CHAIN;
			else if(me->edge_type == EDGE_VERTEX_TYPE)
				gad_lab = EDGE_VERTEX;
			else if(me->edge_type == SURFACE_LOOP_TYPE)
				gad_lab = SURFACE_LOOP;
			else if(me->edge_type == FILLET_TYPE)
				gad_lab = FILLET;
			else if(me->edge_type == RADII_TYPE)
				gad_lab = RADII;
			ret = ECplround_process_form(form_lab, gad_lab, 1.0, 
				ME.ECsfedloc->form);
		}
		if(!me->selection) 
          	    FIg_set_state_off(ME.ECsfedloc->form, SELECT);
		else 
          	    FIg_set_state_on(ME.ECsfedloc->form, SELECT);


		/* If the fillet option is varying disable the fillet/radii
		gadgets */
		if(me->fillet_type == VARYING_TYPE ) sym_index = VARY_INDEX;
		else sym_index = CONS_INDEX;
		if(me->fillet_type == VARYING_TYPE && me->selection) {
          	    	FIg_disable(ME.ECsfedloc->form, RADII);
          	    	FIg_disable(ME.ECsfedloc->form, FILLET);
		}
		else {
          	    	FIg_enable(ME.ECsfedloc->form, RADII);
          	    	FIg_enable(ME.ECsfedloc->form, FILLET);
		}

		/* Update the main form fillet type whenever the user changes
		the fillet type by keying in */
		FIg_set_symbol_index(ME.ECsfedloc->form, FILLET_OPTION, 
			sym_index);
		FIg_activate(ME.ECsfedloc->form, FILLET_OPTION);
		FIg_display(ME.ECsfedloc->form, FILLET_OPTION);

		ret = FIf_set_cmd_oid_os(ME.ECsfedloc->form, my_id, 
			OM_Gw_current_OS);
		if (ret) return (OM_E_ABORT);
		
                FIg_set_value(ME.ECsfedloc->form, TANGENT_EDGE,
                                me->neutral_edge_angle);

		ret = FIf_display (ME.ECsfedloc->form);
		if(ret) return (OM_E_ABORT);
		me->form_displayed = TRUE;

	}
	return(sts);
} /* status_disp */

end implementation ECsfedloc;
