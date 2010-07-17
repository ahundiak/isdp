
/* $Id: VCEmbed.S,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCEmbed.S
 *
 * Description:
 *      This class serves as a substitute for the real terminal and
 *      can be embedded inside an equipment macro. The post_placement
 *      ppl them will generate the virtual terminal at placement time.
 *
 * Dependencies:     $GRNUC/ASnode
 *
 * Revision History:
 *        $Log: VCEmbed.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/03/01  23:50:22  pinnacle
# Replaced: vcterm/VCEmbed.S for:  by kddinov for route
#
# Revision 1.3  1998/02/24  22:40:10  pinnacle
# Replaced: vcterm/VCEmbed.S for:  by kddinov for route
#
# Revision 1.2  1998/02/18  20:07:40  pinnacle
# Replaced: vcterm/VCEmbed.S for:  by kddinov for route
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.3  1997/07/14  22:07:24  pinnacle
# Replaced: vcterm/VCEmbed.S for:  by hverstee for cabling
#
# Revision 1.2  1997/05/19  13:36:48  pinnacle
# Replaced: vcterm/VCEmbed.S for:  by hverstee for cabling
#
# Revision 1.1  1997/04/28  21:57:12  pinnacle
# Created: vcterm/VCEmbed.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *	Feb/98		KDD	    JumpConn, JumpData (for jumper connectivity)
 *				    VCInitInstance.
 *
 *************************************************************************/

class specification VCEmbed (0:0) of VDSnode;

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
#include "ACrg_collect.h"
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
#include "VCstructs2.h"
#include "VCdbstructs.h"

#include "vds.h"

instance VCEmbed
{
  IGRint      Product;                   /*  product code    */
  IGRint      nVCType;                   /*  Type flag       */
  IGRint      nVCStat;                   /*  status flag     */

  variable
  IGRchar     szVCCode[0];           /*  component code  */

  variable
  IGRchar     szVCTagNo[0];          /*  tag number      */

  /* Attributes list */
  variable struct ACrg_coll     SysAtt[0];
  variable struct ACrg_coll     UsrAtt[0];

  /* Coordinate system */
  IGRdouble   dMatrix[16];


  variable char           JumpConn[0];  /* pointer to VCJumpConn structure */
 
  IGRshort                JumpConnType; /* size of a single JumpConn data 
                                           packet sizeof(VCJumpConn) */
 
 
  variable char           JumpData[0];  /* pointer to VCJumpData structure */
 
  IGRshort                JumpDataType; /* size of a single JumpConn data 
                                           packet sizeof(VCJumpData) */
};

/*   Set/return instance fields                          */

message VCETGetIns (IGRlong         *msg;
             struct VCET_ins        *Ins);

message VCETSetIns (IGRlong         *msg;
             struct VCET_ins        *Ins);

message VCETGetMat (IGRlong         *msg;
                    IGRdouble       *dMat);

message VCETSetMat (IGRlong         *msg;
                    IGRdouble       *dMat);

/*   Return the embedded attribute collections      */

message VCEGiveAtt (IGRlong         *msg;
                    IGRshort        *nSys;
             struct ACrg_coll       *SysAtt;
                    IGRshort        *nUsr;
             struct ACrg_coll       *UsrAtt);

/* to initalize "variable char" instance data */
message VCInitInstance (IGRlong *msg);     

/* definition taken from VDSroot.S */
message VDgetObjDef(    long            *msg ;
                        VDobjDef        *objDef ) ;



override GRget_matrix;

override ASreturn_go;       /* No graphics => returns the VRNozHold id */
override NDcompute_node;    /* Stores attributes from collections and
                               matrix from coordinate system */
override NDgive_structure;  /* Returns coordinate system's information */
override NDcopy;            /* Avoid the GRowner.GRcopy */
override NDmove_to_root;    /* Avoid treatment of graphics component */
override GRxform;           /* When I am moved to root; I must apply the
                               xform matrix to my matrix */

from GRvg inherit GRgetsymb; /* Make shure that the GRvg method is activated */
from GRvg inherit GRputsymb;
from GRvg inherit GRchgcolor;
from GRvg inherit GRchgdp;
from GRvg inherit GRchglevel;
from GRvg inherit GRchgstyle;
from GRvg inherit GRchgweight;

end specification VCEmbed;

