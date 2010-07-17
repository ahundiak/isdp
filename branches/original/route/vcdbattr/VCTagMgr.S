
/* $Id: VCTagMgr.S,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCTagMgr.S
 *
 * Description:
 *
 * Specification file for tag number manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTagMgr.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/11/30  15:39:08  pinnacle
# Created: vcdbattr/VCTagMgr.S by r250_int for route
#
# Revision 1.1  1997/11/14  22:54:14  pinnacle
# Created: vcdbattr/VCTagMgr.S by onayragu for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *	11/12/97	Onay		Creation Data, this object is
 * replacing the VCTAG object which handled object tags.
 *
 * -------------------------------------------------------------------*/

class specification VCTagMgr (0:0) of GRcmpowner;

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
#include "vc_define.h"
#include "vc_structs.h"

instance  VCTagMgr
{
  IGRshort       		nTagStat;
  variable struct    VCtagmgr   taglist[0];
};

message  VCTagInit  (IGRlong    *msg);

message  VCTagEval  (IGRlong    *msg);

message  VCTagChk   (IGRshort   *nST;
                     IGRint      CAT;
                     IGRchar    *szTag);

message  VCTagAdd   (IGRshort   	*nST;
                     IGRint      	CAT;
                     IGRchar    	*szTag;
		     struct GRid	*Id);

message  VCTagDel   (IGRshort   *nST;
                     IGRint      CAT;
                     IGRchar    *szTag);

message  VCTagDump   (IGRint      	*NbTag;
	              struct VCtagmgr	**TagList );

end specification VCTagMgr;

