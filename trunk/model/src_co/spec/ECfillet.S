/* ###################   APOGEE COMPILED   ################## */
class specification ECfillet (1:0) of ECconstruct;
/*
 Description

  This class provides the method overrides necessary
  to perform fillet with automatic trimming.

 History

  09/02/88 : rlw : Creation Date
 */
/*
 * Overrides
 */
override
/*
 * This message is overridden to disable
 * the messages and to prevent unecessary
 * display of the result.
 */
 perform_duty,
/*
 * This message performs the fillet
 */
perform_construction;

end specification ECfillet;
