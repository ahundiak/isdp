
/* $Id: VDADS.S,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDADS.S
 *
 * Description:
 *
 * Specification file for ithe Attribute driven symbols manager
 *   abstract class declaring all messages for table storage/retrieval
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDADS.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/05  20:07:48  pinnacle
# Replaced: vdtbl/mgr/VDADS.S for:  by hverstee for vds.240
#
# Revision 1.2  1995/08/14  22:12:34  pinnacle
# Replaced: vdtbl/mgr/VDADS.S for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/19  19:19:24  pinnacle
# Created: vdtbl/mgr/VDADS.S by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/09/95          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VDADS (0:1) of Root;

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

#include "vds.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_int.h"

instance  VDADS
{
  struct  VDdrwlo_sstab           SSid_tab;

  variable struct VDadsym_rec     Ladsrec[0];
};

/* -----------------         PUBLIC MESSAGES          --------------------- */

message  DBdelete  (IGRlong         *msg;
                    FILE            *OutFil);

/*    Deletes underlying database tables if userid matches

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
OutFile        I      yes        file to print message to

   ------------------------------------------------------------------------ */

message  VDADS_gtab  (IGRlong         *msg;
               struct VDdrwlo_sstab   *Tabrec);

/*    returns general criteria ID parameters

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabrec         O      yes        Returned id record

   ------------------------------------------------------------------------ */

message  VDADS_grec  (IGRlong         *msg;
                      IGRchar         *AttNam;
               struct ret_struct      *AttVal;
                      IGRshort        *nCount;
               struct VDadsym_rec     *AdsRec);

/*    returns ADS record(s) according to input

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
AttNam         I(optional)       Attribute name to select
AttVal         I(optional)       Attribute value to match
nCount         O                 number of records output
SrtRec         O      yes        ADS records output

   ------------------------------------------------------------------------ */

message  VDADS_check (IGRlong         *msg;
                      IGRshort        *nIndex);

/*    checks ADS object for validity

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nIndex         O                 Index code of first erroneous entry

   ------------------------------------------------------------------------ */


/* -----------------        PRIVATE MESSAGES          --------------------- */

message  VDADS_init   (IGRlong         *msg;
                struct VDdrwlo_sstab   *Tabrec);

/*     initializes in memory ADS table object

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabrec         I                 Table id record for object

   ------------------------------------------------------------------------ */

message  VDADS_fill   (IGRlong         *msg);

/*     Fill the ADS table object from the database

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */

message  VDADS_srec  (IGRlong         *msg;
                      IGRshort         nCount;
               struct VDadsym_rec     *AdsRec);

/*    stores ADS records (complete)

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nCount         I                 number of records input
SrtRec         I                 ADS records input

   ------------------------------------------------------------------------ */

reject   VDADS_fill;
reject   DBdelete;

end specification VDADS;

