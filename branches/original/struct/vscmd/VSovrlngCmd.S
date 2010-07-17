/* $Id: VSovrlngCmd.S,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSovrlngCmd.S
 *
 * Description: Beam Overlengtth Implementation
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSovrlngCmd.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/04/09  16:07:30  pinnacle
# CR179800339
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/08/98  ah      CR179800339 Make left/right match profile card
 *                   Hilite beam ends
 ***************************************************************************/

class specification VSovrlngCmd(1:0) of VSpartopCmd ;

#define MX_DFLT_OVRLNGTHS	30 /* Max. # of default overlengths */
#include "vsdfltvalsfm.h"

instance VSovrlngCmd {
	char		*ovrLngthsForm ;
	VSdfltValsInfo	dfltInfo ;
	VSdefaultValues defaultValues[MX_DFLT_OVRLNGTHS] ;
	struct	GRid	xsId ;
} ;

message fillForm() ;
message cleanUp() ;
message displayCrossSection(struct GRobj_env support ; int whichEnd ) ;
message VShiliteBeamEndAsLoft(struct GRobj_env support; IGRchar *bmEnd );

override form_notification,
	 mouse,
	 operation ,
	 init ;

end specification VSovrlngCmd ;


