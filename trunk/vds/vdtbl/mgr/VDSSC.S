
/* $Id: VDSSC.S,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDSSC.S
 *
 * Description:
 *
 * Specification file for drawing table layout manager
 *   abstract class declaring all messages for summarization
 *   and sort criteria objects
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSSC.S,v $
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
# Revision 1.3  1995/09/05  20:07:26  pinnacle
# Replaced: vdtbl/mgr/VDSSC.S for:  by hverstee for vds.240
#
# Revision 1.2  1995/08/15  23:32:36  pinnacle
# Replaced: vdtbl/mgr/VDSSC.S for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:09:28  pinnacle
# Created: vdtbl/mgr/* by tdumbach for vds.240
#
# Revision 1.1  1995/04/25  22:00:08  pinnacle
# Created: vdtbl/mgr/VDSSC.S by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/14/95          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VDSSC (0:1) of Root;

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

instance  VDSSC
{
  struct  VDdrwlo_sstab    SSid_tab;

  variable struct VDdrwlo_sort      Lsortrec[0];

  variable struct VDdrwlo_sqty      Lsqtyrec[0];

  variable struct VDdrwlo_smatch    Lsmtcrec[0];
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

message  VDSSC_gtab  (IGRlong         *msg;
               struct VDdrwlo_sstab   *Tabrec);

/*    returns general criteria ID parameters

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabrec         O      yes        Returned id record

   ------------------------------------------------------------------------ */

message  VDSSC_gsort (IGRlong         *msg;
                      IGRshort         nIndex;
                      IGRshort        *nCount;
               struct VDdrwlo_sort    *SrtRec);

/*    returns sorting record(s) according to input

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nIndex         I                 Sequence number (VD_DRWLO_EN_ALL = all)
nCount         O                 number of records output
SrtRec         O      yes        sortkey records output

   ------------------------------------------------------------------------ */

message  VDSSC_gsqty (IGRlong         *msg;
                      IGRchar         *szCat;
                      IGRchar         *szSub;
                      IGRshort        *nCount;
               struct VDdrwlo_sqty    *QtyRec);

/*    returns summarization quantity record(s) according to input

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
szCat          I                 Category (NULL = all)
szSub          I                 SubCategory (NULL = all)
nCount         O                 number of records output
QtyRec         O      yes        summ. quantities records output

   ------------------------------------------------------------------------ */

message  VDSSC_giqty (IGRlong         *msg;
                      IGRchar         *szCat;
                      IGRchar         *szSub;
                      IGRshort        *nIndex);

/*    returns summarization quantity record index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
szCat          I                 Category (NOT NULL)
szSub          I                 SubCategory (NOT NULL)
nIndex         O                 Returned index

   ------------------------------------------------------------------------ */

message  VDSSC_gsmtc (IGRlong         *msg;
                      IGRchar         *szCat;
                      IGRchar         *szSub;
                      IGRshort         nIndex;
                      IGRshort        *nCount;
               struct VDdrwlo_smatch  *MtcRec);

/*    returns summarization match record(s) according to input

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
szCat          I                 Category (NULL = all)
szSub          I                 SubCategory (NULL = all)
nIndex         I                 Sequence number (VD_DRWLO_EN_ALL = all)
nCount         O                 number of records output
MtcRec         O      yes        matchkey records output

   ------------------------------------------------------------------------ */

message  VDSSC_gimtc (IGRlong         *msg;
                      IGRchar         *szCat;
                      IGRchar         *szSub;
                      IGRshort        *nBeg;
                      IGRshort        *nEnd);

/*    returns indexes to a group of summarization match record(s)

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
szCat          I                 Category (NULL = all)
szSub          I                 SubCategory (NULL = all)
nBeg           O                 Begin of section
nEnd           O                 End of section

   ------------------------------------------------------------------------ */

message  VDSSC_check (IGRlong         *msg;
                      IGRshort        *nSrtIx;
                      IGRchar         *szCAT;
                      IGRchar         *szSBC;
                      IGRshort        *nSumIx);

/*    checks ADS object for validity

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nSrtIx         O                 Index code of first erroneous sort entry
szCAT          O                 returned error category
szSBC          O                 returned error subcategory
nSumIx         O                 Index code of first erroneous summ entry
                                 (NOTE index -1 means error in qty exp)

   ------------------------------------------------------------------------ */


/* -----------------        PRIVATE MESSAGES          --------------------- */

message  VDSSC_init   (IGRlong         *msg;
                struct VDdrwlo_sstab     *Tabrec);

/*     initializes in memory table criteria object

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabrec         I                 Table id record for object

   ------------------------------------------------------------------------ */

message  VDSSC_fill   (IGRlong         *msg);

/*     Fill the table layout object from the database

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */

message  VDSSC_ssort (IGRlong         *msg;
                      IGRshort         nCount;
               struct VDdrwlo_sort    *SrtRec);

/*    stores sorting records according to input

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nCount         I                 number of records input
SrtRec         I                 sortkey records input

   ------------------------------------------------------------------------ */

message  VDSSC_ssqty (IGRlong         *msg;
                      IGRshort         nCount;
               struct VDdrwlo_sqty    *QtyRec);

/*    stores summarization quantity record(s) according to input

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nCount         I                 number of records input
QtyRec         I                 summ. quantities records input

   ------------------------------------------------------------------------ */

message  VDSSC_ssmtc (IGRlong         *msg;
                      IGRshort         nCount;
               struct VDdrwlo_smatch  *MtcRec);

/*    stores summarization match record(s) according to input

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nCount         I                 number of records input
MtcRec         I                 matchkey records input

   ------------------------------------------------------------------------ */

/*     for combined class, reject DB fill
       (implement with post in occurrence)              */

reject  VDSSC_fill;
reject  DBdelete;

end specification VDSSC;

