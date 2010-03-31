
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/

class specification VEgragad (2:0) of IGEgragad,VEinstance;

/*

DESCRIPTION
	Class definition for a Hidden Line Window

HISTORY
	Sept. 5, 1986  --- Initial insertion (Mike Lanier)
	Feb. 10, 1990  --- Changed to support new class structure for 2.0
*/


message VEsave_instance( IGRlong *msg );

/*
DESCRIPTION
	This message saves the instance data of the VEgragad by
	constructing a VEinstance object, copying its instance data
	to the VEinstance object, and then connecting itself to the
	VEinstance object's to_gragad channel.
*/
 
message VErestore_instance( IGRlong *msg );

/*
DESCRIPTION
	This message restores the instance data of a VE gragad.  If the VEgragad
	has a VEinstance object attached, its data is copied to the VEgragad
	and it is deleted.  If the VE gragad doesn't have a VEinstance object
	attached, default instance data is loaded into the VEgragad.
*/


message VEprocess( IGRint          *msg;
	           struct GRid     *co_grid;
	           OM_S_CHANSELECT *gschansel;
	           IGRboolean      batch_mode;
	           IGRboolean      output_soos );

/*
DESCRIPTION
	This message runs Visible Edges or Projected Edges in a VE window
	on the elements that are on the 'gschansel' of 'co_grid'.  'co_grid'
	is typically a command object and gschansel must be a channel on that
	command object that consists of located objects that can be accessed
	with the graphic set macros (i.e., gr$gsget_objects()).  The 'batch_mode'
	flag is for internal use only and should always be FALSE if this method
	is sent by non-VE code.
*/

message VEsubmit_batch( IGRint          *msg;
	                struct GRid     *co_grid;
	                OM_S_CHANSELECT *gschansel;
	                IGRchar         *results_name;
	                IGRchar         *server_name;
	                IGRchar         *user_name;
	                IGRchar         *password;
	                IGRchar         *start_time );
	                 
/*
DESCRIPTION
	This message submits a batch job from a VE window that will run VE
	on the elements that are on the 'gschansel' channel of 'co_grid'.
	See documentation of the VEprocess method for a description of
	'co_grid' and 'gschansel'.  The batch job will be sent to the
	server defined in the 'server_name' parameter, the name of the
	resulting file will be 'results_name', and the start time of the
	job will be 'start_time'.
*/

message VEinit_globals( IGRint     *msg;
	                IGRboolean batch_mode;
	                IGRboolean output_soos );

/*
DESCRIPTION
	This message initializes the global variables required to process Visible
	or Projected Edges.  They are initialized with the values stored in
	the instance of the VE gragad that receives this message.
*/

end specification VEgragad;

