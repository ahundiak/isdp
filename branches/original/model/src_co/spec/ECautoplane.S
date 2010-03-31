/* ###################   APOGEE COMPILED   ################## */
class specification ECautoplane (1:0) of ECconstruct;
/*
 Description

  This class provides instance data and methods for
  a command which supports constructing a surface by
  automatically searching a closed curve for interior curves.
 
 History

  07/13/88 : rlw : The beginning.  Took Place plane encompassing planar
                   element logic out of ECconstruct and put it here.
 */

instance ECautoplane
{
 IGRlong		number_of_curves;
 variable		struct GRlc_info curves[];
};
/*
 * Overrides
 */
override
/*
 * This message performs dynamics.
 */
perform_dynamics,
/*
 * This message verifys a user input.
 */
verify_event,
/*
 * This message constructs the surface.
 */
perform_construction;

end specification ECautoplane;
