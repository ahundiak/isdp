
/* $Id: VCCmdAnal.S,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdAnal.S
 *
 * Description:
 *      Command object for analysis commands
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdAnal.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.7  1997/07/14  22:39:32  pinnacle
# Replaced: vccmdutil/VCCmdAnal.S for:  by hverstee for cabling
#
# Revision 1.6  1997/03/19  18:33:26  pinnacle
# Replaced: vccmdutil/VCCmdAnal.S for:  by hverstee for cabling
#
# Revision 1.5  1997/03/14  18:23:12  pinnacle
# Replaced: vccmdutil/VCCmdAnal.S for:  by hverstee for cabling
#
# Revision 1.4  1997/03/12  22:18:08  pinnacle
# Replaced: vccmdutil/VCCmdAnal.S for:  by hverstee for cabling
#
# Revision 1.3  1996/10/25  19:10:24  pinnacle
# Replaced: vccmdutil/VCCmdAnal.S for:  by hverstee for cabling
#
# Revision 1.2  1996/10/07  20:27:06  pinnacle
# Replaced: vccmdutil/VCCmdAnal.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:01:40  pinnacle
# Created: vccmdutil/VCCmdAnal.S by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class specification VCCmdAnal (1:0) of VDS_LOCATE;


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

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
#include "VCCmdANA.h"
#include "VCparameters.h"

instance VCCmdAnal
{
  IGRint                MyType;       /* Type   (Fi or El)     */
  IGRint                MyRet;        /* Private return code   */
  IGRint                Product;      /* product               */
  IGRint                LocType;      /* Picked element type 1 */
  IGRshort              nCptNum;      /* Connectpoint number   */
  IGRshort              nActPos;      /* active connectpos     */
  IGRboolean            bToFile;      /* Output to file        */
  IGRboolean            bToPPL;       /* Switch to PPL func    */

  IGRchar               szPPLNam[80]; /* PPL file path         */
  IGRchar               szFNCNam[80]; /* PPL function name     */

  /*C Layout description             */
  IGRshort                 nLay;
  IGRshort                 nLtab;
  IGRshort                 nLAct;
  IGRshort                 nLTOT;
  struct VClayout         *LayTab;

  /*C Selected fiber/pin             */
  IGRchar                  szTagNo[VC_MAX_TAGNO];
  IGRchar                  szTagN2[VC_MAX_TAGNO];
  struct VC_contrace       ConId1;
  struct VC_contrace       ConId2;
  IGRint                   TransFlags;
  IGRboolean               bSelected;

  /*C Selected analyses               */

  int                      nNumAna;
  struct VC_anproc        *ProcList;
  IGRboolean              *bSetCheck;
};


override init;
override form_notification;

message VCGetRefInfo ( int * sts );

message VCFillForm ();

message VCGetRetCode ();

message VCReset ( int * sts );

message VCCleanup ( int * sts );

message VCAnalyze ( int * sts );
message VCANfunc  ( int * sts );

message VCTrace ( int * sts );

end specification VCCmdAnal;
