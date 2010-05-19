/* $Id: VDnb.S,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdnb/imp/VDnb.S
 *
 * Description: Derive from GR Notebook to access text buffer
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDnb.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/17  23:15:24  pinnacle
# VDnb
#
 *
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      12/17/97  ah      Created
 ***************************************************************************/

class specification VDnb (1:0) of GRnb;

#include "VDmaster.h"
#include "VDnb.h"

message getText(IGRchar *bufPnt; IGRlong bufMax; IGRlong *bufCnt);
message setText(IGRchar *bufPnt; IGRlong bufCnt);

end specification VDnb;
