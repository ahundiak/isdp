
/* $Id: VCDB.S,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDB.S
 *
 * Description:
 *
 * Specification file for cabling DB cache
 *   abstract class declaring all messages for attribute retrieval.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDB.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/08/15  12:51:28  pinnacle
# Replaced: vcdbattr/VCDB.S for:  by hverstee for cabling
#
# Revision 1.3  1997/08/11  21:20:20  pinnacle
# Replaced: vcdbattr/VCDB.S for:  by hverstee for cabling
#
# Revision 1.2  1997/07/14  21:42:46  pinnacle
# Replaced: vcdbattr/VCDB.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:49:26  pinnacle
# Created: vcdbattr/VCDB.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/31/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCDB (0:0) of Root;

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

instance  VCDB
{
};

/* -----------------         PUBLIC MESSAGES          --------------------- */

message  VCGetPos  (IGRlong         *msg;
             struct VCpos           *Posdef;
                    IGRshort        *nIndex;
                    IGRshort        *nMAP;
                    IGRshort        *nSIG);

/*    Converts a position definition in an index
       (DB access only, to pin/lead table --- defaults included)

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Posdef         I                 Position id
nindex         O                 lead/pin index in data
nMAP           O                 lead/pin index in map
nSIG           O                 Signal table index

   ------------------------------------------------------------------------ */

message  VCGetAttr (IGRlong         *msg;
             struct VCpos           *Posdef;
                    IGRchar         *szAttNam;
             struct ret_struct      *res);

/*    Retrieves attributes from DB cache by name

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Posdef         I                 Position id
szAttNam       I                 Attribute name
res            O                 output result.

   ------------------------------------------------------------------------ */

message  VCGetAnum (IGRlong         *msg;
             struct VCpos           *Posdef;
                    IGRint           nAttnum;
             struct ret_struct      *res);

/*    Retrieves attributes from DB cache by number

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Posdef         I                 Position id
nAttnum        I                 Attribute number
res            O                 output result.

   ------------------------------------------------------------------------ */

message  VCGpAttr  (IGRlong         *msg;
                    IGRshort         nIndex;
                    IGRshort         nMAP;
                    IGRchar         *szAttNam;
             struct ret_struct      *res);

/*    Retrieves attributes from DB cache by name and position index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nIndex         I                 lead/pin index in data
nMAP           I                 lead/pin index in map
szAttNam       I                 Attribute name
res            O                 output result.

   ------------------------------------------------------------------------ */

message  VCGpAnum  (IGRlong         *msg;
                    IGRshort         nIndex;
                    IGRshort         nMAP;
                    IGRint           nAttnum;
             struct ret_struct      *res);

/*    Retrieves attributes from DB cache by number and position index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nIndex         I                 lead/pin index in data
nMAP           I                 lead/pin index in map
nAttnum        I                 Attribute number
res            O                 output result.

   ------------------------------------------------------------------------ */

message  VCGetLayout (IGRlong         *msg;
                      IGRchar         *Modnam;
                      IGRshort        *nEnt;
                      IGRshort        *nTab;
               struct VClayout        *Layout);

/*    Retrieves layout table from DB cache

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Modnam         I                 Module name requested (NULL == all)
nEnt           O                 Number of connect entries in layout table
nTab           O                 Number of entries in array
Layout         O      yes        output result.

   ------------------------------------------------------------------------ */

message  VCGetModules (IGRlong         *msg;
                       IGRshort        *nEnt;
                       IGRshort        *nTopoTyp;
                       IGRchar         *Modlist);

/*    Retrieves list of modules DB cache (terminals only)

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nEnt           O                 Number of module entries in layout table
nTopoTyp       O      yes        List of topology types
Modlist        O      yes        output result.

   ------------------------------------------------------------------------ */

/* -----------------        PRIVATE MESSAGES          --------------------- */

message  VCDB_ghdr   (IGRlong         *msg;
               struct VCdbmain        *Tabrec);

/*    Returns complete header record 

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabrec         O                 Headerrecord

   ------------------------------------------------------------------------ */

message  VCDB_init   (IGRlong         *msg;
               struct VCdbmain        *Tabrec);

/*    Initialize DBcache structure

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabrec         I                 Initial headerrecord if available

   ------------------------------------------------------------------------ */

message  VCDB_fill    (IGRlong         *msg);

/*    Fill DBCache structure from database

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */

message  VCDB_sdata   (IGRlong         *msg;
                       IGRshort         nomod;
                struct VCdbmodsel      *Mods;
                       IGRshort         nodata;
                union  VCdbdatarec     *Data);

/*    Fill DBCache structure with data given

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nomod          I                 Number of module records
Mods           I                 Module records
nodata         I                 Number of data records
Data           I                 Data records (union)

   ------------------------------------------------------------------------ */

message  VCDB_delete (IGRlong         *msg;
                      FILE            *OutFil);

/*    Delete tables from database

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
OutFil         I                 Optional report file

   ------------------------------------------------------------------------ */

end specification VCDB;

