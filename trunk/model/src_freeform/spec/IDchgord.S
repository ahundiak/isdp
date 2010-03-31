/**@***********************************************************************

 FILE:
	IDchgord.S

 ROUTINES:
	None.

 **************************************************************************/

class specification IDchgord (1:0) of ECmodify;

/*
Abstract
	This command changes curve or surface order. However, user
	needs not change the default u_order and/or v_order parameter(s)
	in order to change the order(s) of the located curve or surface.

History
	04/02/92	JSY	Design and coding.
*/

override wakeup,
         output_command_string,
         next_event_processing,
         verify_event,
         perform_modification;

end specification IDchgord;

