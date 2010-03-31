/* ###################   APOGEE COMPILED   ################## */
class specification ECmodify (1:0) of ECconstruct;
/*
 Description

  This is the command object class for simple
  modification commands.
 
 History

  12/29/87 : rlw : Creation date
 */

instance ECmodify
{
 IGRlong	u_order;
 IGRlong	v_order;
};
/*
 * This message performs the actual
 * modification.
 */
message perform_modification();
/*
 * Overrides
 */
override
 wakeup,
 next_event_processing,
 perform_dynamics,
 display_constructions,
 verify_event,
 perform_duty;

end specification ECmodify;
