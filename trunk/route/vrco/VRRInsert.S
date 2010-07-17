
/* $Id: VRRInsert.S,v 1.1.1.1 2001/01/04 21:12:43 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrco/ VRRInsert.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRRInsert.S,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1997/02/24  21:57:56  pinnacle
# Created: vrco/VRRInsert.S by hverstee for route
#
 *
 * History:
 *   02/09/97    HV     Creation
 *
 ***********************************************************************/

class specification VRRInsert (1:0) of VRCORway;

instance VRRInsert
{
};

override VRInitInstance;
override form_notification;
override VRSKF_fill;

end specification VRRInsert;

