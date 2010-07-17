
/* $Id: VCX.S,v 1.1.1.1 2001/01/04 21:12:37 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCX.S
 *
 * Description:
 *	The abstract class VCX maintains mutual connectpoint
 *      references
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCX.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/01/20  20:17:08  pinnacle
# Replaced: vcroot/VCX.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:14:48  pinnacle
# Created: vcroot/VCX.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class specification VCX (0:0) of Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "ACattrib.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "vdbmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "VCdefine.h"
#include "VCparameters.h"
#include "VCstructs.h"
#include "VCdbstructs.h"

instance VCX
{
  variable struct VCx_list   nVCx[0];
};

/*---------------------------------------------------------------------------*/
/*                     Online connectpoint reference                         */
/*---------------------------------------------------------------------------*/

/*    Initializes connectpoint reference table */
message VCx_init (IGRlong      *msg);

/*    Add new connectpoint pair                    */
message VCx_add  (IGRlong      *msg;
           struct GRid         *gID;      /*I  ID of added reference  */
                  IGRshort      nCPoth;   /*I  cpt of gID             */
                  IGRshort      nCPmy);   /*I  my cpt                 */

/*    Inquire connectpoint pair                */
message VCx_get  (IGRlong      *msg;
           struct GRid         *gID;      /*I  ID of other el to get  */
                  IGRshort     *nType;    /*O  parent or child relation  */
                  IGRshort     *nCPoth;   /*O  cpt of gID             */
                  IGRshort     *nCPmy);   /*O  my cpt                 */

/*    Change connectpoint pair                */
message VCx_chg  (IGRlong      *msg;
           struct GRid         *gID;      /*I  ID of other el to get  */
                  IGRshort     *nCPoth;   /*I  cpt of gID             */
                  IGRshort     *nCPmy);   /*I  my cpt                 */

/*    Remove connectpoint pair                */
message VCx_rem  (IGRlong      *msg;
           struct GRid         *gID);     /*I  ID of other el to remove  */

/*    Find reference on channels              */
message VCx_ref  (IGRlong      *msg;
           struct GRid         *gID;      /*I  ID of other el to get     */
                  IGRshort     *nType;    /*O  parent or child relation  */
                  IGRint       *nIndex);  /*O  index on channel          */

/*---------------------------------------------------------------------------*/

end specification VCX;

