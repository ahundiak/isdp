/*
	I/STRUCT
*/
class specification VSbeamcsCmd (1:0) of VSpartopCmd;

#include "vsbmcs.h"

instance VSbeamcsCmd {

	/*
	 * Which end of beam and which cardinal point to put CS at.
	 */
	VSbmCsPos where ;
	
	/*
	 * CS for display.
	 */
	struct GRid	CS ;
} ;


message initCmd() ;

message cleanup() ;

message changeCardPoint( long *msg ) ;

message findCloserEnd ( long *msg ) ;

message displayCS( long *msg ; int on ) ;

end specification VSbeamcsCmd ;
