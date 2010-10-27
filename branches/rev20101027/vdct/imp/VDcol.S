/* $Id: VDcol.S,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/imp/VDcol.S
 *
 * Description: Basic Collector Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcol.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/28  13:59:18  pinnacle
# ct
#
 * Revision 1.1  1999/05/28  12:43:54  pinnacle
 * ct
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 ***************************************************************************/

class specification VDcol (1:0) of Root;

#include "VDtypedef.h"
#include "VDfld.h"
#include "VDcol.h"

instance VDcol
{
  variable TVDfld   vdcolFld0[0];  // For internal use
  variable TVDfld   vdcolFld1[0];  // For external use
  variable IGRchar  vdcolData[0];  // Just because
};

// Gets one attribute
message vdcolGetAttr(IGRint   f;     // I - which vla
                     IGRchar *name;  // I - name to get 
                     IGRint   i_nth; // I - index to get
                     IGRint  *o_nth; // O - index gotten
                     TVDfld  *fld;   // O - Copy of atr
                     TVDfld **fldp); // O - Pointer to atr

// Set 1 attribute based on index (for speed)
message vdcolSetAttr(IGRint f;       // I - which vla 
                     IGRint nth;     // I - index
                     TVDfld *fld);   // I - data

/* -------------------------------------------------------
 * Yet to be tested
 * If input arguments bufMax or cntMax are less than 0
 * then deliver data without checking for overflow
 * assume user has allocated sufficient space.
 */
message vdcolGetData(IGRint    bufMax;  // I - Length of buf(protects buf)
                     IGRint   *bufLen;  // O - Length of data
                     IGRchar  *buf;     // O - Copy data to here
                     IGRchar **bufp);   // O - Set to internal pointer

message vdcolSetData(IGRint   bufLen;  // I - Length of data
                     IGRchar *buf);    // I - Set to internal pointer

// Main access to attributes
message vdcolGetAttrs(IGRint   f;       // I - which vla
                      IGRint   cntMax;  // I - max flds(protects flds)
                      IGRint  *cnt;     // O - actual number  of flds
                      TVDfld  *flds;    // O - copy of flds
                      TVDfld **fldp);   // O - instance data

// Args should be clear
message vdcolSetAttrs(IGRint f; IGRint cnt; TVDfld *flds);
message vdcolUpdAttrs(IGRint f; IGRint cnt; TVDfld *flds);
message vdcolDelAttrs(IGRint f; IGRint cnt; TVDfld *flds);

end specification VDcol;


