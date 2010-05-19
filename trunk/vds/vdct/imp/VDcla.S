/* $Id: VDcla.S,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/imp/VDcla.S
 *
 * Description: Basic Dynamic Class Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcla.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/28  13:59:18  pinnacle
# ct
#
 * Revision 1.1  1999/05/28  12:43:54  pinnacle
 * ct
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 ***************************************************************************/

class specification VDcla (1:0) of Root;

#include "VDtypedef.h"
#include "VDcla.h"

instance VDcla
{
  TVDclaType vdclaType;
  TVDclaFlag vdclaFlag;

};

// Access internal data
message vdclaGetType(TVDclaType *info);
message vdclaSetType(TVDclaType  info);

message vdclaGetFlag(TVDclaFlag *flag);
message vdclaSetFlag(TVDclaFlag  flag);

end specification VDcla;
