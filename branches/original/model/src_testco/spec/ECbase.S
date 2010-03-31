/* ###################   APOGEE COMPILED   ################## */
class specification ECbase (1:0) of super_cmd;
/*
 Description

  This is the abstract class for constructions in EMS, that
  are written the way I used to write commands, that are also
  written by me.  It purpose is to declare command instance data and
  to provide some standard methods.
 
 History

  07/24/88 : rlw : The beginning
  08/14/94 : scw : Clarified sleep method
 */

#include "ems_m_inc.h"			/* Includes everything */

instance ECbase
{
 IGRlong		msg;
 struct GRmd_env	display_env;
 struct GRmd_env	construct_env;
 struct IGRdisplay	display;
 struct	GRvg_construct	construct_list;
 struct IGResbs		surface_element_specific;
 struct GRevent		event, locate_event;
 struct	GRlc_stack	locate_stack;
};
/*
 * This method loads the active properties,
 * construction enviroment, etc. into my 
 * instance data, i.e. it sets up the variable
 * me->construct_list.
 *
 * Actually constructs are supposed to take place
 * in a module enviroment determined by the first
 * data point which is input.  If this event is
 * pass in then I will get the proper enviroment, if
 * not then I will get the active module enviroment.
 */
message load_construction_information(struct GRevent *event);
/*
 * Overrides
 */
override
/*
 * This method erases the hilite plane.
 */
super_cmd.sleep,
/*
 * This method loads the active color, style, 
 * weight, level, and display enviroment into
 * my instance data.
 */
wakeup,
/*
 * This method clears out the vsd (variable
 * string descriptor) and then deletes.
 */
delete;

end specification ECbase;
