/* ###################   APOGEE COMPILED   ################## */
class specification ECplsolproj (1:0) of ECconstruct;
/*
 Description

  This is the command object for placing a solid of projection 
 
 History

  03/11/92  Tapadia - Creation
 */

instance ECplsolproj
{
 	IGRboolean 	start_PT_flag, nor_PROJ_flag;
	IGRboolean	start_RP_flag, end_RP_flag;
	IGRboolean	sym_DIST_flag;
};
/*
 * Overrides
 */
override
 init,
/*
 * This method returns the masks,
 * and prompt strings.
 */
next_event_processing,
/*
 * This method verifys the events.
 */
verify_event,
/*
 * This method performs dynamics .
 */
perform_dynamics,
/*
 * This message displays construction
 * lines on the screen.
 */
 display_constructions,
/*
 * This method constructs the curve.
 */
perform_construction;


end specification ECplsolproj;
