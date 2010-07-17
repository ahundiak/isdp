/*
	I/STRUCT
*/
class specification VSxtbeamCmd (1:0) of VSpartopCmd ;

instance VSxtbeamCmd {
	/*
	 * Which end of beam to extend.
	 */
	int	whichEnd,
	/*
	 * Count of available ends where to extend beam (0,1,2).
	 */
		availableEnds ;

	/*
	 * Cross-section curve for display.
	 */
	struct GRid	xSection ;
} ;

message initCmd() ;

message cleanup() ;

message changeEnd( long *msg ) ;

message findCloserEnd( long *msg ) ;

message displaySection( long *msg ; int on ) ;

end specification VSxtbeamCmd ;
