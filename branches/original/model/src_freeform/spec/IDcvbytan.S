/**@***********************************************************************

 FILE:
	IDcvbytan.S

 ROUTINES:
	None.

 **************************************************************************/

class specification IDcvbytan (1:0) of IDcvbypts;

/*
Abstract
	This command places a curve which is tangent to a located curve
	at the end point.

History
	07/06/92	JSY	Creation.
*/

override output_command_string,
         next_event_processing,
         verify_event,
	 perform_dynamics,
	 display_constructions,
	 perform_construction;

end specification IDcvbytan;
