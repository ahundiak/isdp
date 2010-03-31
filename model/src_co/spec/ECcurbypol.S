/* ###################   APOGEE COMPILED   ################## */
class specification ECcurbypol (1:0) of ECfit;
/*
 Description

  This is the command object for place
  curve by poles given points.

 History

  12/13/87 : rlw : Creation date
 */

/*
 * Overrides
 */
override
/*
 * This method returns the masks,
 * and prompt strings.
 */
next_event_processing,
/*
 * This method constructs the curve.
 */
perform_construction,
/*
 * This method verifys the events.
 */
verify_event;

end specification ECcurbypol;




