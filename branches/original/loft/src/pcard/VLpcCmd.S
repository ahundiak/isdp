/* $Id: VLpcCmd.S,v 1.1.1.1 2001/01/04 21:11:32 cvs Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:	loft/src/pcard/VLpcCmd.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLpcCmd.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.3  1998/01/02  21:06:10  pinnacle
# Replaced: src/pcard/VLpcCmd.S for:  by l250_int for loft
#
# Revision 1.2  1998/01/02  19:26:20  pinnacle
# Replaced: src/pcard/VLpcCmd.S for:  by l250_int for loft
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			loft		creation date
 ***************************************************************************/

class specification VLpcCmd (1:0) of VLlocateCmd;

#include "ACrg_collect.h"

instance VLpcCmd
{
	struct	ACrg_coll	userVar[4];
};

message VLpcPlace( long *sts );
message VLinitUserVar();
message VLcheckInput( long *sts );

override	wakeup,
		form_notification;

end specification VLpcCmd;
