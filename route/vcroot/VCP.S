
/* $Id: VCP.S,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCP.S
 *
 * Description:
 *	The abstract class VCP declares all messages to be used to
 *      maintain connectpoint locations and orientations
 *       (used by terminals)
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCP.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.5  1997/07/22  14:26:14  pinnacle
# Replaced: vcroot/VCP.S for:  by hverstee for cabling
#
# Revision 1.4  1997/05/06  13:25:20  pinnacle
# Replaced: vcroot/VCP.S for:  by hverstee for cabling
#
# Revision 1.3  1997/04/28  21:44:50  pinnacle
# Replaced: vcroot/VCP.S for:  by hverstee for cabling
#
# Revision 1.2  1997/01/20  20:17:48  pinnacle
# Replaced: vcroot/VCP.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:11:02  pinnacle
# Created: vcroot/VCP.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class specification VCP (0:0) of Root;

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

#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"

#include "VCdefine.h"
#include "VCparameters.h"
#include "VCstructs.h"
#include "VCdbstructs.h"
#include "VCproto.h"

instance VCP
{
  variable struct VCP_ptmgr   VCoff[0];    /* defines connectpoints  */
};


/*---------------------------------------------------------------------------
      message VCP_init

        initializes connectpoint manager

        overridden for specific case

      *msg ;           I/O - return status
      *Copy            I   - VCP entity to copy connectpoints from (macro)
      *pModEnv         I   - Module environment
----------------------------------------------------------------------------*/

message VCP_init (IGRlong         *msg;
           struct GRid            *Copy;
           struct GRmd_env        *pModEnv);

/*---------------------------------------------------------------------------
      message VCP_reorg

        reorganizes dynamic connectpoints by condensing out unused ones
        and modifying the cables which are still attached

      *msg ;           I/O - return status
----------------------------------------------------------------------------*/

message VCP_reorg (IGRlong         *msg);

/*---------------------------------------------------------------------------*/

/********************* CONNECTPOINT MANAGEMENT *******************************/

/*---------------------------------------------------------------------------

      message VCP_addpt

        calculates and adds a connectpoint entry to the table

      *msg             I/O - return status
       dCoord          I   - World coordinates
       dProj           I   - Projection point
       md_env          I   - Environment matrix
      *nCpt            O   - Assigned cpt number
----------------------------------------------------------------------------*/

message VCP_addpt (IGRlong         *msg ;
                   IGRdouble       *dCoord;
                   IGRdouble       *dProj;
            struct GRmd_env        *md_env;
                   IGRshort        *nCpt);

/*---------------------------------------------------------------------------

      message VCP_add

        adds a connectpoint entry to the table

      *msg             I/O - return status
       VCpm            I   - Connect point description
      *nCpt            O   - Assigned cpt number
----------------------------------------------------------------------------*/

message VCP_add  (IGRlong         *msg ;
           struct VCP_ptmgr       *VCpm;
                  IGRshort        *nCpt);

/*---------------------------------------------------------------------------

      message VCP_get

        retrieves a connectpoint entry from the table

      *msg             I/O - return status
       VCpm            I   - Connect point description
----------------------------------------------------------------------------*/

message VCP_get  (IGRlong         *msg ;
                  IGRshort         nCP;
           struct VCP_ptmgr       *VCpm);

/*---------------------------------------------------------------------------

      message VCP_calc

        corrects a matrix for the connectpoint offset

      *msg             I/O - return status
       nIndex          I   - index
       dMatIn          I   - matrix in
       dMatOut         O   - matrix out
----------------------------------------------------------------------------*/

message VCP_calc (IGRlong         *msg ;
                  IGRshort         nIndex;
                  IGRdouble       *dMatIn;
                  IGRdouble       *dMatOut);

/*---------------------------------------------------------------------------

      message VCP_num

        returns the number of connectpoints

      *msg             I/O - return status
       nCpt;           O   - Number of Connect points
----------------------------------------------------------------------------*/

message VCP_num  (IGRlong         *msg ;
                  IGRshort        *nCpt);

/*---------------------------------------------------------------------------

      message VCP_rem

        removes a connectpoint entry from the table

      *msg             I/O - return status
       nCpt;           I   - Connect point number
----------------------------------------------------------------------------*/

message VCP_rem  (IGRlong         *msg ;
                  IGRshort         nCpt);

end specification VCP;

