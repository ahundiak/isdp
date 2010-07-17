
/* $Id: VCCmdPP.S,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdPP.S
 *
 * Description:
 *      Command object for attach/detach cable
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdPP.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/03/12  22:18:20  pinnacle
# Replaced: vccmdutil/VCCmdPP.S for:  by hverstee for cabling
#
# Revision 1.1  1996/10/15  19:33:20  pinnacle
# Created: vccmdutil/VCCmdPP.S by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class specification VCCmdPP (1:0) of VDS_LOCATE;

#include <stdio.h>
#include <string.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "FI.h"
#include "FEI.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCCmdDef.h"
#include "VCCmdStr.h"
#include "VCparameters.h"

instance VCCmdPP
{
  IGRint                MyType;       /* Type   (attach/detach)     */
  IGRint                MyRet;        /* Private return code        */

  struct GRid           RefId;        /* Item picked (point or conduit) */
  struct GRid           CabId1;       /* Item picked (cable)            */
  struct GRid           CabId2;       /* Item picked (cable)            */

  struct VCpos          Cab1pos;
  struct VCpos          Cab2pos;
};


override init;

message VCPPcab1 ( int * sts );

message VCPPcab2 ( int * sts );

message VCPPProcess ( int * sts );

message VCPPcleanup ( int * sts );

end specification VCCmdPP;

