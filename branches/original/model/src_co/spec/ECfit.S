/* ###################   APOGEE COMPILED   ################## */
class specification ECfit (1:0) of ECconstruct;
/*
 Description

  This is the command object class for fit commands.
  It provides the instance data storage and wakeup
  method for order, num poles, etc..
 
 History

  12/13/87 : rlw : Creation date
 */

instance ECfit
{
 IGRlong	u_order;
 IGRlong	v_order;
 IGRboolean	u_periodic;
 IGRboolean	v_periodic;
};
/*
 * Overrides
 */
override
/*
 * This method loads the instance
 * data from the dpb.
 */
wakeup;

end specification ECfit;




