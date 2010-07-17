
/* $Id: VCCmdSC.S,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdSC.S
 *
 * Description:
 *      Command object for utility Set Equipment connectible
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdSC.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/03/12  22:18:26  pinnacle
# Replaced: vccmdutil/VCCmdSC.S for:  by hverstee for cabling
#
# Revision 1.1  1997/01/23  23:58:16  pinnacle
# Created: vccmdutil/VCCmdSC.S by hverstee for cabling
#
 *
 * History:
 *        01/20/97        hv        Initial
 *
 *************************************************************************/

class specification VCCmdSC (1:0) of VDS_LOCATE;

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

instance VCCmdSC
{
  IGRint                MyType;       /* Type                       */

  struct GRid           RefId;        /* Item picked (Equipment)    */
};


override init;

message VCSCgetref  ( int * sts );

message VCSCprocess ( int * sts );

message VCSCcleanup ( int * sts );

end specification VCCmdSC;

