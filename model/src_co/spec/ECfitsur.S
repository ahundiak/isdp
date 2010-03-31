/* ###################   APOGEE COMPILED   ################## */
class specification ECfitsur (1:0) of ECfit;
/*
 Description

  This is the command object class for commands
  which fit data producing freeform surfaces
 
 History

  12/16/87 : rlw : Creation date
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

end specification ECfitsur;




