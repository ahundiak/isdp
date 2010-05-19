
/* $Id: VDdrwlo.S,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo.S
 *
 * Description:
 *
 * Specification file for drawing table layout manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo.S,v $
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
# Revision 1.4  1995/09/05  20:07:00  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo.S for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  14:34:12  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo.S for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:18:34  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo.S for:  by hverstee for vds.240
#
# Revision 1.1  1995/04/13  14:34:38  pinnacle
# Created: vdtbl/mgr/* by tdumbach r#
# rno
#
# Revision 1.4  1995/04/13  13:40:56  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo.S by hverstee r#
#
# Revision 1.3  1995/03/25  15:35:16  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo.S by hverstee r#
#
# Revision 1.2  1995/03/20  17:14:44  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo.S by hverstee r#
#
# Revision 1.1  1995/03/06  16:38:14  pinnacle
# Created: vdtbl/mgr/VDdrwlo.S by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/03/95          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VDdrwlo (0:1) of Root;

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

instance  VDdrwlo
{
   struct VDdrwlo_tab     Ltbrec;

   IGRshort        nNBalg[4];

   variable struct VDdrwlo_db_alg    Lalgrec[0];

   variable struct VDdrwlo_ins_col   Lcolrec[0];

   variable struct VDdrwlo_ins_htf   Lhtfrec[0];

   variable struct VDdrwlo_db_fld    Lfldrec[0];
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

message  VDdrwlo_gtab  (IGRlong         *msg;
                  struct VDdrwlo_tab    *Tabrec);

/*    returns general table layout parameters

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabrec         O      yes        Returned table layout record

   ------------------------------------------------------------------------ */

message  VDdrwlo_gfix  (IGRlong         *msg;
                        IGRshort         nGrptyp;
                        IGRdouble        xLode;
                        IGRdouble        yLode;
                        IGRshort         nExt;
                 struct VDdrwlo_extrec  *Exrec;
                        IGRdouble       *dHgt;
                        IGRshort        *nCount;
                 struct VDdrwlo_apifix  *Fldrec);

/*    returns array of fixed (builtin) components of a table layout

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 group type requested
xLode          I                 section corner x coordinate
yLode          I                 section corner y coordinate
nExt           I                 number of extensions requested
Exrec          I                 extension records
dHgt           O                 total height of field or row
nCount         O                 number of field records to be returned
Fldrec         O      yes        Array of returned records

   ------------------------------------------------------------------------ */

message  VDdrwlo_gdata (IGRlong         *msg;
                        IGRshort         nGrptyp;
                        IGRdouble        xLode;
                        IGRdouble        yLode;
                        IGRshort         nExt;
                 struct VDdrwlo_extrec  *Exrec;
                        IGRdouble       *dHgt;
                        IGRshort        *nCount;
                 struct VDdrwlo_data    *Fldrec);

/*    returns array of replaceable components of a table layout

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 group type requested
xLode          I                 section corner x coordinate
yLode          I                 section corner y coordinate
nExt           I                 number of extensions requested
Exrec          I                 extension records
dHgt           O                 total height of field or row
nCount         O                 number of data records to be returned
Fldrec         O      yes        Array of returned records

   ------------------------------------------------------------------------ */

message  VDdrwlo_grect (IGRlong         *msg;
                        IGRshort         nGrptyp;
                        IGRshort         nColno;
                        IGRchar         *pFieldid;
                        IGRshort         nExt;
                 struct VDdrwlo_extrec  *Exrec;
                        IGRdouble       *xLow;
                        IGRdouble       *yLow;
                        IGRdouble       *xHig;
                        IGRdouble       *yHig);

/*    returns rectangular coordinates of a table section

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 group type requested
nColno         I                 column number requested (if column group)
                                  (EN_ALL for all columns -- overall rect)
pFieldid       I                 fieldid requested (if header/trailer group)
                                  (NULL for all fields -- overall rect)
nExt           I                 number of extensions requested
Exrec          I                 extension records
xLow           O                 Returned lower x
yLow           O                 Returned lower y
xHig           O                 Returned upper x
yHig           O                 Returned upper y

   ------------------------------------------------------------------------ */

message  VDdrwlo_check (IGRlong         *msg;
                        IGRshort        *nError;
                        FILE            *ppFile;
                 struct VDdrwlo_error   *Errtab);

/*    check layout object for internal consistency errors

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nError         O                 number of errors
ppFile         I                 File to print errors (stdout if NULL)
Errtab         O      yes        table of error records for printing

   ------------------------------------------------------------------------ */

/* -----------------        PRIVATE MESSAGES          --------------------- */

message  VDdrwlo_init   (IGRlong         *msg;
                  struct VDdrwlo_tab     *Tabrec);

/*     initializes in memory table layout object

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabrec         I                 Table id record for object

   ------------------------------------------------------------------------ */

message  VDdrwlo_set    (IGRlong          *msg;
                         IGRshort          nGrptyp;
                  struct VDdrwlo_ins_htf  *Htf_I);

/*     recalculates instance variables (partial if needed)

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 if EN_DATA or EN_ALL calculate column data
                                 -else-
Htf_I          I                 if given recalculate this particular record
                                   else recalculate all.

   ------------------------------------------------------------------------ */

/*    inherited from VDSroot -- postyourself
message  VDdrwlo_post

   ------------------------------------------------------------------------ */

message  VDdrwlo_fill   (IGRlong         *msg);

/*     Fill the table layout object from the database

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */


/*   NOTES on data storage and retrieval

     1.  Supported operations are g- (GET), p- (PUT), d- (DELETE)
         i- (INSERT, only for numeric keys) and x_ (GETINDEX)
     2.  Specifying VD_DRWLO_EN_ALL for numeric input parameters or
         address NULL for alpha input parameters will be treated as
         meaning (get/delete) all records in this category.
     3.  PUT operations will replace or add depending on internal keys.
     4.  DELETE operations will ensure internal consistency.
     5.  SET message may resequence references.

   ------------------------------------------------------------------------ */

message  VDdrwlo_galign (IGRlong          *msg;
                         IGRshort          nGrptyp;
                         IGRshort          nAligncode;
                         IGRshort         *nCount;
                  struct VDdrwlo_db_alg   *Align);

/*     get the alignment records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type
nAligncode     I                 Alignment code number
nCount         O                 Number of records out
Align          O      yes        Alignment records

   ------------------------------------------------------------------------ */

message  VDdrwlo_dalign (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRshort         nAligncode);

/*     delete one or more alignment records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type
nAligncode     I                 Alignment code number

   ------------------------------------------------------------------------ */

message  VDdrwlo_ialign (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRdouble        dValue;
                         IGRshort        *nCode);

/*     add (insert in position) alignment record

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type number
dValue         I                 Alignment value
nCode          O      yes        alignment code assigned

   ------------------------------------------------------------------------ */

message  VDdrwlo_palign (IGRlong         *msg;
                  struct VDdrwlo_db_alg  *Align);

/*     replace alignment record

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Align          I                 Alignment record

   ------------------------------------------------------------------------ */

message  VDdrwlo_xalign (IGRlong          *msg;
                         IGRshort          nGrptyp;
                         IGRshort          nAligncode;
                         IGRshort        *nIndex);

/*     get an alignment index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type
nAligncode     I                 Alignment code number
nIndex         O                 Index pointer

   ------------------------------------------------------------------------ */

message  VDdrwlo_qalign (IGRlong          *msg;
                         IGRshort          nGrptyp);

/*     sort one or more alignment tables

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type

   ------------------------------------------------------------------------ */

message  VDdrwlo_falign (IGRlong          *msg;
                         IGRshort          nGrptyp;
                         IGRshort          nAlign1;
                         IGRshort          nAlign2);

/*     exchange two alignment code references
       (update all HTF references to them)

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type
nAlign1        I                 Alignment code number 1
nAlign2        I                 Alignment code number 2

   ------------------------------------------------------------------------ */

message  VDdrwlo_gcol   (IGRlong         *msg;
                         IGRshort         nColno;
                         IGRshort        *nCount;
                  struct VDdrwlo_db_col  *Col);

/*     get one or more column records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nColno         I                 Column number
nCount         O                 Number of records out
Col            O      yes        Column records

   ------------------------------------------------------------------------ */

message  VDdrwlo_dcol   (IGRlong         *msg;
                         IGRshort         nColno);

/*     delete one or more column records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nColno         I                 Column number

   ------------------------------------------------------------------------ */

message  VDdrwlo_icol   (IGRlong         *msg;
                  struct VDdrwlo_db_col  *Col);

/*     add (insert in position) column record

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Col            I                 Column record

   ------------------------------------------------------------------------ */

message  VDdrwlo_pcol   (IGRlong         *msg;
                  struct VDdrwlo_db_col  *Col);

/*     replace column records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Col            I                 Column records

   ------------------------------------------------------------------------ */

message  VDdrwlo_xcol   (IGRlong         *msg;
                         IGRshort         nColno;
                         IGRshort        *nIndex);

/*     get a column index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nColno         I                 Column number
nIndex         O                 Index pointer

   ------------------------------------------------------------------------ */

message  VDdrwlo_ghtf   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRchar         *pFieldid;
                         IGRshort        *nCount;
                  struct VDdrwlo_db_htf  *Htf);

/*     get one or more header field records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type number
pFieldid       I                 Field id 
nCount         O                 Number of records out
Htf            O      yes        Headerfield records

   ------------------------------------------------------------------------ */

message  VDdrwlo_dhtf   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRchar         *pFieldid);

/*     replace the header field records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type number
pFieldid       I                 Field id 

   ------------------------------------------------------------------------ */

message  VDdrwlo_phtf   (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_htf  *Htf);

/*     add/replace header field records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nCount         I                 Number of records in
Htf            I                 Headerfield records

   ------------------------------------------------------------------------ */

message  VDdrwlo_xhtf   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRchar         *pFieldid;
                         IGRshort        *nIndex);

/*     get a htf index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type number
pFieldid       I                 Field id
nIndex         O                 Index pointer

   ------------------------------------------------------------------------ */

message  VDdrwlo_gfld   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRshort         nColno;
                         IGRchar         *pFieldid;
                         IGRshort         nLinseq;
                         IGRshort        *nCount;
                  struct VDdrwlo_db_fld  *Fld);

/*     get one or more header field records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type number
nColno         I                 Column number        -or-
pFieldid       I                 Field id 
nLinseq        I                 Line sequence number
nCount         O                 Number of records out
Fld            O      yes        Datafield records

   ------------------------------------------------------------------------ */

message  VDdrwlo_dfld   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRshort         nColno;
                         IGRchar         *pFieldid;
                         IGRshort         nLinseq);

/*     delete one or more field records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type number
nColno         I                 Column number        -or-
pFieldid       I                 Field id 
nLinseq        I                 Line sequence number

   ------------------------------------------------------------------------ */

message  VDdrwlo_pfld   (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_fld  *Fld);

/*     add/replace fieldspec records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nCount         I                 Number of records in
Fld            I                 Datafield records

   ------------------------------------------------------------------------ */

message  VDdrwlo_xfld   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRshort         nColno;
                         IGRchar         *pFieldid;
                         IGRshort         nLinseq;
                         IGRshort        *nIndex);

/*     get a field index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nGrptyp        I                 Group type number
nColno         I                 Column number        -or-
pFieldid       I                 Field id
nLinseq        I                 Line sequence number
nIndex         O                 Index pointer

   ------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------ */
/*    private messages to store tables without check                        */
/*                    CAUTION                                               */
/* ------------------------------------------------------------------------ */

message  VDdrwlo_sfld   (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_fld  *Fld);

message  VDdrwlo_shtf   (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_htf  *Htf);

message  VDdrwlo_salign (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_alg  *Align);

message  VDdrwlo_scol   (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_col  *Col);

/* ------------------------------------------------------------------------ */

reject  DBdelete;

end specification VDdrwlo;

