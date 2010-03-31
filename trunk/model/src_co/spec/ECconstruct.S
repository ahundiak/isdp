/* ###################   APOGEE COMPILED   ################## */
class specification ECconstruct (1:0) of super_cmd;
/*
 Description

  This is the abstract class for constructions in EMS.
  It purpose is to declare command instance data and
  to provide some standard methods.
 
 History

  10/14/87 : rlw : The beginning
  12/08/87 : rlw : Added getevent and locate methods
  12/18/87 : rlw : Added event mask to locate method
  12/23/87 : rlw : Added element specific attributes to my instance data
  12/29/87 : rlw : Added perform_duty() method.
  04/18/89 : rlw : Added update_status_form() method and overrides for
                   status_disp() and init() methods to support status display
                   forms.
  04/27/91 : pp  : Added is_associative() message.
  08/13/94 : scw : Clarifed override of sleep method
 */

#include "ems_m_inc.h"			/* Includes everything */
#include "FI.h"

instance ECconstruct
{
 IGRboolean		have_a_constructed_object;
 OM_S_OBJID		constructed_object;
 IGRlong		msg;
 IGRlong		number_of_events_input;
 IGRlong		final_state;
 IGRlong		final_event_count;
 Form           	form1;
 struct GRmd_env	display_env;
 struct GRmd_env	construct_env;
 struct IGRdisplay	display;
 struct	GRvg_construct	construct_list;
 struct IGResbs		surface_element_specific;
 struct GRevent		event, event1;
 struct	GRlc_stack	locate_stack;
 variable struct GRevent events[MAX_STATIC_EVENTS];
 struct GRid window_id;
 IGRboolean             associative;
};
/*
 * This method forces the command to go to the
 * beginning state.
 */
message restart();
/*
 * This method loads the active properties,
 * construction enviroment, etc. into my 
 * instance data, i.e. it sets up the variable
 * me->construct_list.
 */
message load_construction_information();
/*
 * This method adds an event to my 
 * instance data.
 */
message add_event(IGRboolean is_a_located_object);
/*
 * This method decrements the number of
 * events and reloads the last point 
 * information.  If at the start state then
 * it will try to cycle backwards and
 * delete the last object it constructed.
 */
message backup_event();
/*
 * This method saves the information
 * necessary to transition back to the 
 * final state.  It also restarts the
 * command.
 */
message last_state_to_first_state();
/*
 * This message displays the constructed
 * object.
 */
message display_constructed_object(
 enum GRdpmode DisplayMode);
/*
 * This message locates a graphic object
 *
 * See EClocate.I
 */
message locate_object(
 IGRlong	event_mask;
 IGRchar	*locate_string;
 IGRlong	locate_key;
 struct		RLW_locate_info *loc_info;
 IGRboolean	auto_put_on_queue;
 IGRboolean	*put_on_queue;
 IGRint		*response;
 IGRchar	*response_data);
/*
 * This message gets an operator event
 *
 * See ECgetevent.I
 */
message getevent(
 IGRlong	type_of_value_needed;
 IGRlong	event_mask;
 IGRchar	*prompt_string;
 IGRlong	prompt_key;
 IGRint		*response;
 IGRchar	*response_data);
/*
 * This message outputs the command
 * string in the message field.
 */
 message output_command_string();
/*
 * This message returns the event mask,
 * type of filter to call, and the prompt
 * for the next user input.
 */
 message next_event_processing(
  IGRchar	*prompt_string;
  IGRlong	*prompt_index;
  IGRlong	*event_mask;
  IGRlong	*type_of_value_needed;
  IGRboolean	*locate_desired;
  struct	RLW_locate_info *loc_info);
/*
 * This message performs dynamics.
 */
 message perform_dynamics();
/*
 * This message displays construction
 * lines on the screen.
 */
 message display_constructions(
  IGRboolean	draw_background;
  IGRboolean	draw_single);
/*
 * This message verifys a user input.
 */
 message verify_event(
  IGRboolean	use_default;
  IGRboolean	*was_valid_event;
  IGRboolean	*done);
/*
 * This message constructs the
 * desired object after all inputs
 * are in.
 */
 message perform_construction();
/*
 * This message performs the construction
 * and displays the results.
 */
 message perform_prim_construction();
/*
 * This message does the actual work of the above message if the
 * entity is a primitive surface/solid.
 */
 message perform_free_construction();
/*
 * This message does the actual work of the above message if the
 * entity is a free-form surface/solid.
 */
 message perform_wframe_construction();
/*
 * This message does the actual work of the above message if the
 * entity is a wire-frame element.
 */
 message perform_duty();
/*
 * This message updates the active status
 * display form.
 */
 message update_status_form();
/*
 * This message determines whether the command object needs to
 * construct an associative element or not. This potentially would
 * have to be overriden by subclasses.
 */ 
 message is_associative(IGRint type; IGRlong *associative);
/*
 * Rejects
 */
 reject update_status_form;
/*
 * Overrides
 */
override
/*
 * This method cycles through the
 * states for basic command objects
 */
execute,
/*
 * This method erases and objects
 * displayed in hilite.
 */
super_cmd.sleep,
/*
 * This method loads the active color, style, 
 * weight, level, and display enviroment into
 * my instance data.  It also displays any
 * objects which I have in hilite.
 */
wakeup,
/*
 * This method clears out the vsd (variable
 * string descriptor) and then deletes.
 */
delete,
/*
 * This method creates and displays the current
 * status display form as dictated by super_cmd
 * instance data.
 */
status_disp,
/*
 * This method initializes the active status display
 * form to nothing.
 */
init;

end specification ECconstruct;
