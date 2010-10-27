/* $Id: VDTagCon.S,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdtag/VDTagCon.S
 *
 * Description: Provides access to internal OMTagCon Information
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDTagCon.S,v $
 * Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 * Initial import to CVS
 *
# Revision 1.1  1998/11/05  17:07:34  pinnacle
# tags
#
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/01/98  ah      Created
 ***************************************************************************/

class specification VDTagCon (1:0) of OMTagCon;

#include "VDtypedef.h"

override delete;

message dump();
message access(void *p);

end specification VDTagCon;
