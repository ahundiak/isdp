/* ###################   APOGEE COMPILED   ################## */
class specification ECblndnsrf (1:0) of ECconstruct;
/*
 Description

  This is the command object for blending to
  an arbitrary number of curves.
 
 History

  06/29/88 : rlw : Creation date
  11/29/88 : rlw : Broke the functionality out of ECconstruct and reworked
                   to support an arbitrary number of curves.
 */

/*
 * Overrides
 */
override
 is_associative,
 next_event_processing,
 perform_dynamics,
 display_constructions,
 verify_event,
 perform_construction;

end specification ECblndnsrf;




