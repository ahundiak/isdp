/* $Id: VDCsupGenPl.S,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/cmd/VDCsupGenPl.S
 *
 * Description: The original plan called for a sep command object
 * for each type of support curve.  This turned out to be unnecessary.
 * Merge back into parent class when time permits.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCsupGenPl.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/29  15:20:56  pinnacle
# Added Headers
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 ***************************************************************************/

class specification VDCsupGenPl (1:0) of VDCsupGen;

message PlaceMacro( long * sts );
message hello     ( long * sts );
message get_initFlag ( long * sts );

override init,sleep,wakeup;
override form_notification;

end specification VDCsupGenPl;
