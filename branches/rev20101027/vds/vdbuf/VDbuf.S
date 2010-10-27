/* $Id: VDbuf.S,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbuf/VDBuf.S
 *
 * Description: Collection of vla's
 *              1 - XML Schema
 *              2 - XML Private Data
 *              3 - XML Public  Data
 *              4 - Spare
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbuf.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  2000/02/25  17:23:52  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/22/00  ah      Creation
 ***************************************************************************/

class specification VDbuf (1:0) of Root;

#include "VDtypedef.h"

instance VDbuf
{
  variable IGRchar  vdbufData1[0];
  variable IGRchar  vdbufData2[0];
  variable IGRchar  vdbufData3[0];
  variable IGRchar  vdbufData4[0];
};

/* -------------------------------------------------------
 * Yet to be tested
 * If input arguments bufMax or cntMax are less than 0
 * then deliver data without checking for overflow
 * assume user has allocated sufficient space.
 */
message vdbufGetData(IGRint    nth;     // I - Which buf
		     IGRint    flag;    // I - Spare
		     IGRint    bufMax;  // I - Length of buf(protects buf)
                     IGRint   *bufLen;  // O - Length of data
                     IGRchar  *buf;     // O - Copy data to here
                     IGRchar **bufp);   // O - Set to internal pointer

message vdbufSetData(IGRint   nth;     // I - Which buf
		     IGRint   flag;    // I - Spare
		     IGRint   bufLen;  // I - Length of data
                     IGRchar *buf);    // I - Set to internal pointer

end specification VDbuf;


