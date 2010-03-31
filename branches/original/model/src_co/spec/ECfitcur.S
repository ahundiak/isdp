/* ###################   APOGEE COMPILED   ################## */
class specification ECfitcur (1:0) of ECfit;
/*
 Description

  This is the command object class for commands
  which fit data producing freeform curves.
 
 History

  12/15/87 : rlw : Creation date
 */

/*
 * Overrides
 */
override
 next_event_processing,
 perform_dynamics,
 display_constructions,
 verify_event,
 perform_construction;

end specification ECfitcur;




