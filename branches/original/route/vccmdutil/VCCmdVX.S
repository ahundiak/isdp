
/* $Id: VCCmdVX.S,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdVX.S
 *
 * Description:
 *      Command object for insert/move/delete cable vertex
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdVX.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.2  2000/03/15  21:56:10  pinnacle
# Replaced: vccmdutil/VCCmdVX.S for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/07/22  15:19:20  pinnacle
# Replaced: vccmdutil/VCCmdVX.S for:  by hverstee for cabling
#
# Revision 1.4  1997/05/19  19:50:00  pinnacle
# Replaced: vccmdutil/VCCmdVX.S for:  by hverstee for cabling
#
# Revision 1.3  1997/05/07  16:14:04  pinnacle
# Replaced: vccmdutil/VCCmdVX.S for:  by hverstee for cabling
#
# Revision 1.2  1997/03/12  22:18:32  pinnacle
# Replaced: vccmdutil/VCCmdVX.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:02:40  pinnacle
# Created: vccmdutil/VCCmdVX.S by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *        03/15/00        law       Installed VCGdProcess in case it is needed
 *                                  for cr179901086 (move guide vertexes)
 *
 *************************************************************************/

class specification VCCmdVX (1:0) of VDS_LOCATE;

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

instance VCCmdVX
{
  IGRint          MyRet;       /*C my return        */
  IGRint          MyType;      /*C my type          */
  IGRint          SendType;    /*C type for ML_modify message send         */
  IGRint          AdjType;     /*C type for ML_modify message send         */
  struct GRid     RefId;       /*C Cable being modified   */

  IGRint          SectNo;      /*C Section number being modified  */
  IGRint          VtxNo;       /*C Vertex number being modified  */

  IGRint          IX;          /*C Preserved coordinate index  */

  IGRdouble       dDyn[12];    /*C Dynamics buffer    */

  /*    automatic detent      */

  struct VCVX_detent   Detent;

  struct GRmd_env      MdEnv;
};


override init;
override dynamics;

message VCGetItem ( long * sts );

message VCGdProcess ( long * sts ); /* processing specific to guides */

message VCProcess ( long * sts ); /* processing primarily for cables */

message VCVXcorners (IGRdouble    *pT1;
                     IGRdouble    *pT2);

end specification VCCmdVX;

