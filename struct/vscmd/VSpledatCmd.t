/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSpledatCmd.t
 *
 * Description:
 *	This command looks at the surface or underlying surface if it's a plate
 *	to see if there aren't any edge attribute macros already connected via
 *	an ASindex curve or an ext_bound nci macro. If there aren't any already,
 *	it places the ext_bound macro and the edge attribute macros.
 *
 * Dependencies:
 *      Form, struct/config/english/forms/VSedgeAttr.frm
 *
 * Revision History:
 *
 * History:
 *      MM/DD/YY        AUTHOR  DESCRIPTION
 *      10/07/97        ejm     CR179700200: Need ability to place a contin-
 *                              uously changing bevel on plate edge.
 *
 *                              Added actions, SetPlate, AddPlate and state,
 *				locate_plate.
 ***************************************************************************/


command_string	VSC_M_VSPlEdAt,0,VSPlEdAt
synonym		VSC_M_VSMoEdAt,1,VSMoEdAt
command_table	"vs.cmd"
options         "siTC"
spec_path	"$STRUCT/spec"
class		VSplEdAtCmd
super_class	VSlocateCmd 
product_name	"$STRUCT"
form            "VSedgeAttr.frm", 0, 0, "-1", "-1"


state_table

#include  "OMerrordef.h"
#include  "VSmsg.h"
#include  "vscmddef.h"
#include  "vsedgeattr.h"

#define MY_ERROR 530
#define LOCATE_EDGE 531
#define VS_NOOBJ_SELECTED 101

state start
  on CMD_TYPE = 0	state  GETPLATE 
  on CMD_TYPE = 1       state  GETEDATT

state GETPLATE
	message_key		VS_M_VSPlEdAt
        execute                 dis_en_able_gadgets(&me->ret)
	prompt_key		VS_P_IdPlate
	accept_key		VS_P_AccRej
	locate_eligible		"VSbooPlate,+VSimbPlate,VSmodPlate,VSplate,VSholPlate,
				 VSsplPlate,VSsrcPlate,VSsubPlate,VSvarPlate"
	locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER |
				 LC_FLEX_COMP  | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	filter			locate
	
	on EX_OBJID or EX_DATA
				do process_fence( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state .
					on RETURN_CODE = "VS_K_NO_FENCE"
					   do status "No Object Located"
					   	state .
                                do DispArrowGadgets( &me->ret )
				on VS_NOOBJ_SELECTED
						do status "No object located"
						state start
				state modify_form

        on GR_UNKNOWN_TYPE.LOCATE_EDGE                 state locate_edge


state modify_form
   message_key		VS_M_VSPlEdAt
   prompt_key           VS_P_ModForm
   construct_class	"VSedge3Datt"
   filter       	get_event

        on GR_UNKNOWN_TYPE.LOCATE_EDGE                 state locate_edge
	on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR	       state load_attr
        on EX_BACK_UP				       state GETPLATE

state load_attr
        execute                 dis_en_able_gadgets( &me->ret )
        execute                 assign_action_handler( &me->ret )
        prompt_key		VS_P_IdEdLoadAttr
        locate_eligible         "VSedge3Datt"
        locate_owner            "LC_RIGID_COMP | LC_RIGID_OWNER |
                                 LC_FLEX_COMP  | LC_FLEX_OWNER  "
        filter                  locate

        on EX_OBJID or EX_DATA  do control_edge( &me->ret )
                                 on RETURN_CODE = MY_ERROR
                                   state .
                                state modify_form1

state locate_edge
        message_key		VS_M_VSPlEdAt
        execute                 dis_en_able_gadgets( &me->ret )
        execute                 assign_action_handler( &me->ret )
        prompt_key              VS_P_IdEdPlcAttr
        locate_eligible         "VSedge3Datt"
        locate_owner            "LC_RIGID_COMP | LC_RIGID_OWNER |
                                 LC_FLEX_COMP  | LC_FLEX_OWNER  "
        filter                  locate

        on EX_OBJID or EX_DATA  do control_edge( &me->ret )
                                 on RETURN_CODE = MY_ERROR
                                   state .
                                state modify_form1
        on EX_BACK_UP           do chg_process_step( &me->ret )
                                state GETPLATE

state modify_form1
   message_key          VS_M_VSPlEdAt
   prompt_key           VS_P_ModForm
   filter       	get_event

        on GR_UNKNOWN_TYPE.LOCATE_EDGE                 state locate_edge
	on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR	       state load_attr
        on EX_BACK_UP				       state -


state GETEDATT
        message_key		VS_M_VSMoEdAt
        status			""
/*      execute			assign_action_handler( &me->ret ) */
        prompt_key		VS_P_IdEdAt
        locate_eligible         "VSedge3Datt"
        locate_owner            "LC_RIGID_COMP | LC_RIGID_OWNER |
                                 LC_FLEX_COMP  | LC_FLEX_OWNER  "
        filter                  locate

        on EX_OBJID or EX_DATA
		do control_edge( &me->ret )
				on RETURN_CODE = MY_ERROR
							state .
	        do SetPlate (&me->ret)

		state .

	on GR_UNKNOWN_TYPE.G_ADD_PLATES		state locate_plate


state locate_plate

/*      execute			assign_action_handler( &me->ret ) */
	message_key		VS_M_VSMoEdAt
	prompt_key		VS_P_IdPlate
	accept_key		VS_P_AccRej
	locate_class		"+VSplate"
/*
        locate_properties       "LC_DP_ONLY | LC_LC_ONLY | LC_RW"
 */
        locate_owner		"LC_RIGID_OWNER | LC_RIGID_COMP
                                 | LC_FLEX_COMP   | LC_REF_OBJECTS
                                 | LC_FLEX_OWNER"

	filter			locate
	
	on EX_OBJID or EX_DATA

		do process_fence( &me->ret )
			on RETURN_CODE = "VS_K_RESTART_CMD"
                                                		state .
			on RETURN_CODE = "VS_K_NO_FENCE"
				do error_box(" NOOBJ_SELECTED ")
                                do status "No Object Located"
                                                		state .
			on VS_NOOBJ_SELECTED
				do error_box(" NOOBJ_SELECTED ")
				do status "No object located"
                                                		state start
		do AddPlate( &me->ret )
								state GETEDATT


at init		do	init_instance()
at wakeup 	do 	form_pos( &me->ret )
at sleep        do      erase_hilite( &me->ret )
at delete       do      free_spec_data()
