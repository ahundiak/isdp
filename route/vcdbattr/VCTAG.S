
/* $Id: VCTAG.S,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCTAG.S
 *
 * Description:
 *
 * Specification file for tag number manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTAG.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/02/19  05:00:12  pinnacle
# Replaced: vcdbattr/VCTAG.S for:  by apazhani for route
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/07/14  21:44:54  pinnacle
# Replaced: vcdbattr/VCTAG.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/30  17:40:22  pinnacle
# Created: vcdbattr/VCTAG.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/31/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCTAG (0:0) of VDSroot;

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

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "vc_structs.h"

/*****************************************************************************
struct  VCtagmgr
{
  IGRshort        nTagOrig;
  IGRshort        nTagCat;
  IGRchar         Tag[VC_MAX_ID];
};
This is included in $ROUTE/include/vc_structs.h file. Alwin ******************/

instance  VCTAG
{
  IGRshort       nTagStat;

  variable
  struct    VCtagmgr   taglist[0];
};

message  VCTagInit  (IGRlong    *msg);

message  VCTagChk   (IGRshort   *nST;
                     IGRint      CAT;
                     IGRchar    *szTag);

message  VCTagAdd   (IGRshort   *nST;
                     IGRint      CAT;
                     IGRchar    *szTag);

message  VCTagDel   (IGRshort   *nST;
                     IGRint      CAT;
                     IGRchar    *szTag);

end specification VCTAG;

