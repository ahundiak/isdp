/* ###################   APOGEE COMPILED   ################## */
class specification ECruledsur (1:0) of ECconstruct;
/*
 Description

  This is the command object for placing a ruled surface
 
 History

  02/16/88 : rlw : Creation date
  05/02/89 : rlw : Modified to support a status display form to provide
                   different options.
  03/25/91 : mm  : Changed to c_based form.
 */
#include "FI.h"

instance ECruledsur
{
 IGRlong	creation_option;
};
/*
 * Overrides
 */
override
 init,
 wakeup,
 is_associative,
 update_status_form,
 status_disp,
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
 * This method performs dynamics.
 */
perform_dynamics,
/*
 * This method verifys the events.
 */
verify_event,
/*
 * This method displays constructional
 * geometry.
 */
display_constructions;


message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value);
end specification ECruledsur;
