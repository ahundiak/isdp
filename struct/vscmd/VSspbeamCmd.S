/*
	I/STRUCT
*/
class specification VSspbeamCmd (1:0) of VSpartopCmd ;

instance VSspbeamCmd {

	/*
	 * Automatically put joints after construction ?
	 */
	int	autoJoin,

	/*
	 * Action for junction: join results together of join results with
	 * operator.
	 */
		joiningAction ;
} ;

override status_disp ;

override form_notification ;

message setJoiningAction( int ja ) ;

message dspAutoJoinMode() ;

override operation ;

end specification VSspbeamCmd ;
