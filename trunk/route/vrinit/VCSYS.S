
/* $Id: VCSYS.S,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:	vcinit/VCSYS.S
 *
 * Description:
 *	CABLE system parameters repository
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VCSYS.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/31  21:24:24  pinnacle
# Created: vrinit/VCSYS.S by impd for route
#
# Revision 1.1  1997/07/14  21:51:44  pinnacle
# Created: vcinit/VCSYS.S by hverstee for cabling
#
 *
 * History:
 *
 *************************************************************************/

class specification VCSYS (1:0) of VDSroot;

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
#include "VCDBpar.h"
#include "VCstructs.h"
#include "VCdbstructs.h"
#include "VCsys.h"

instance VCSYS
{
  variable
  struct   VCsysbuf   SWbuf[0];
};

message   VCS_def (IGRlong    *msg);

message   VCS_set (IGRlong    *msg;
                   IGRint      nCode;
            struct VCsysbuf   *Buf);

message   VCS_get (IGRlong    *msg;
                   IGRint      nCode;
            struct VCsysbuf   *Buf);

end specification VCSYS;

