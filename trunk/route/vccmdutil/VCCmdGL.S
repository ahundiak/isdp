
/* $Id: VCCmdGL.S,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdGL.S
 *
 * Description:
 *      Command object for utility Set System Globals
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdGL.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/07/26  13:58:32  pinnacle
# Replaced: vccmdutil/VCCmdGL.S for:  by hverstee for cabling
#
# Revision 1.1  1997/07/22  15:19:36  pinnacle
# Created: vccmdutil/VCCmdGL.S by hverstee for cabling
#
 *
 * History:
 *        01/20/97        hv        Initial
 *
 *************************************************************************/

class specification VCCmdGL (1:0) of VDS_LOCATE;

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
#include "VCsys.h"

#include "VCCmdDef.h"
#include "VCCmdSYS.h"

instance VCCmdGL
{
  IGRboolean            bPres;
  IGRboolean            bDynCp;
  IGRboolean            bDynOff;

  IGRchar               szBrk[12];
};

override form_notification;

message VCGLcleanup (int * sts);

message VCGLstart   (int * sts);

end specification VCCmdGL;

