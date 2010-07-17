
/* $Id: VCCpm.S,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot/VCCpm.S
 *
 * Description:
 *	The abstract class VCCpm declares all messages to be used to
 *      maintain connectpoint locations and orientations
 *       (used for terminals, guides and raceway caps)
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCpm.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.3  1997/05/06  13:25:36  pinnacle
# Replaced: vcroot/VCCpm.S for:  by hverstee for cabling
#
# Revision 1.2  1997/01/20  20:18:10  pinnacle
# Replaced: vcroot/VCCpm.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:10:26  pinnacle
# Created: vcroot/VCCpm.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class specification VCCpm (0:0) of Root;

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

instance VCCpm
{
  IGRshort        VCp_stat;
  IGRboolean      VCp_half;

  variable struct VCCpm_ptmgr   VCpt[0];    /* defines connectpoints  */

  variable struct VCCpm_spread  VCspread[0]; /* defines cable spread  */
};


/*---------------------------------------------------------------------------
      message VCp_init

        initializes connectpoint manager

        overridden for specific case

      *msg ;           I/O - return status
      *Copy            I   - CPM entity to copy connectpoints from
      *pModEnv         I   - Module environment
----------------------------------------------------------------------------*/

message VCp_init (IGRlong         *msg;
           struct GRid            *Copy;
           struct GRmd_env        *pModEnv);

/*---------------------------------------------------------------------------*/

/********************* CONNECTPOINT MANAGEMENT *******************************/

/*---------------------------------------------------------------------------

      message VCp_acpt

        adds a connectpoint entry to the table

      *msg             I/O - return status
       VCpm            I   - Connect point description
----------------------------------------------------------------------------*/

message VCp_acpt (IGRlong         *msg ;
           struct VCCpm_ptmgr     *VCpm);

/*---------------------------------------------------------------------------

      message VCp_ccpt

        copies a connectpoint entry from the table

      *msg             I/O - return status
       nIndex          I   - index
       VCpm            I   - Connect point description
----------------------------------------------------------------------------*/

message VCp_ccpt (IGRlong         *msg ;
                  IGRshort         nIndex;
           struct VCCpm_ptmgr     *VCpm);

/*---------------------------------------------------------------------------

      message VCp_ncpt

        returns the number of connectpoints

      *msg             I/O - return status
       nCpt;           O   - Number of Connect points
----------------------------------------------------------------------------*/

message VCp_ncpt (IGRlong         *msg ;
                  IGRshort        *nCpt);

/*---------------------------------------------------------------------------

      message VCp_rcpt

        removes a connectpoint entry from the table

      *msg             I/O - return status
       nCpt;           I   - Connect point number
----------------------------------------------------------------------------*/

message VCp_rcpt (IGRlong         *msg ;
                  IGRshort         nCpt);

/*---------------------------------------------------------------------------

      message VCp_gcpt

        retrieves a specific connectpoint

      *msg ;           I/O - return status
       nCpt;           I   - Connect point number
      *bFree           O   - Free orientation
      *dCoord          O   - Coordinates (corrected on output)
      *dVect           O   - Connection vector (corrected on output)
      *dOrnt           O   - Orientation vector.
      *pModEnv         I   - Module environment
----------------------------------------------------------------------------*/

message VCp_gcpt  (IGRlong         *msg ;
                   IGRshort         nCpt;
                   IGRboolean      *bFree;
                   IGRdouble       *dCoord;
                   IGRdouble       *dVect;
                   IGRdouble       *dOrnt;
            struct GRmd_env        *pModEnv);

/*---------------------------------------------------------------------------

      message VCp_scpt

        selects the closest connectpoint

      *msg ;           I/O - return status
      *dIcoord         I   - Input (seed) coordinates
      *nCpt;           O   - Connect point number
      *bFree           O   - Free orientation
      *dCoord          O   - Coordinates (corrected on output)
      *dVect           O   - Connection vector (corrected on output)
      *dOrnt           O   - Orientation vector.
      *pModEnv         I   - Module environment
----------------------------------------------------------------------------*/

message VCp_scpt  (IGRlong         *msg ;
                   IGRdouble       *dIcoord;
                   IGRshort        *nCpt;
                   IGRboolean      *bFree;
                   IGRdouble       *dCoord;
                   IGRdouble       *dVect;
                   IGRdouble       *dOrnt;
            struct GRmd_env        *pModEnv);

/*---------------------------------------------------------------------------*/

/********************* CONNECTCABLE MANAGEMENT *******************************/

/*---------------------------------------------------------------------------
      message VCp_gcab

        update coordinates and direction vectors input

      *msg ;           I/O - return status
       nCpt;           I   - Connect point number
       nCab            I   - Cable number  (-1 is centerpoint)
      *bFree           O   - Free orientation
      *dCoord          O   - Coordinates
      *dVect           O   - Connection vector
      *pModEnv         I   - Module environment
----------------------------------------------------------------------------*/

message VCp_gcab  (IGRlong         *msg ;
                   IGRshort         nCpt;
                   IGRshort         nCab;
                   IGRboolean      *bFree;
                   IGRdouble       *dCoord;
                   IGRdouble       *dVect;
            struct GRmd_env        *pModEnv);

/*---------------------------------------------------------------------------
      message VCp_acab

        adds a cable entry to the table

      *msg ;           I/O - return status
       nCpt;           I   - Connect point number
       nCab            I   - Cable number
----------------------------------------------------------------------------*/

message VCp_acab (IGRlong         *msg ;
                  IGRshort         nCpt;
                  IGRshort         nCab);

/*---------------------------------------------------------------------------

      message VCp_rcab

        removes a cable entry from the table

      *msg ;           I/O - return status
       nCpt;           I   - Connect point number
       nCab            I   - Cable number
----------------------------------------------------------------------------*/

message VCp_rcab (IGRlong         *msg ;
                  IGRshort         nCpt;
                  IGRshort         nCab);

/*---------------------------------------------------------------------------
      message VCp_scab

        (re)sets a cable spread

      *msg ;           I/O - return status
       nCpt;           I   - Connect point number
       nCab            I   - Cable number
       dAngle          I   - orientation angle
       dDist           I   - spread distance
----------------------------------------------------------------------------*/

message VCp_scab (IGRlong         *msg ;
                  IGRshort         nCpt;
                  IGRshort         nCab;
                  IGRdouble        dAngle;
                  IGRdouble        dDist);

/*---------------------------------------------------------------------------*/

end specification VCCpm;

