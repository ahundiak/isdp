
/* $Id: VCCmdBR.S,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdBR.S
 *
 * Description:
 *      Command object for modify bend radius
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdBR.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/03/12  22:18:14  pinnacle
# Replaced: vccmdutil/VCCmdBR.S for:  by hverstee for cabling
#
# Revision 1.1  1996/11/12  17:20:04  pinnacle
# Created: vccmdutil/VCCmdBR.S by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class specification VCCmdBR (1:0) of VDS_LOCATE;

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

instance VCCmdBR
{
  IGRint          MyRet;       /*C my return        */
  IGRint          MyType;      /*C my type          */
  struct GRid     RefId;       /*C Cable being modified   */

  IGRint          SectNo;      /*C Section number being modified  */
  IGRint          VtxNo;       /*C Vertex number being modified  */
  IGRdouble       dBrad;       /*C New bend radius               */

  struct GRmd_env MdEnv;
};

override init;

message VCBget ( long * sts );

message VCBset ( long * sts );
message VCBclr ( long * sts );

end specification VCCmdBR;

