/* $Id: VDbufi.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbuf/VDbufi.I
 *
 * Description: Basic Buffer Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbufi.I,v $
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

class implementation VDbuf;

/* ------------------------------------------------------------
 * Warning - Not tested
 */
method vdbufGetData(IGRint    nth;     // I - Which buffer
		    IGRint    flag;    // I - Spare
		    IGRint    bufMax;  // I - Length of buf(protects buf)
		                       //     0 means give me it all 
		    IGRint   *bufLen;  // O - Length of data
		    IGRchar  *buf;     // O - Copy data to here
		    IGRchar **bufp)    // O - Set to internal pointer
{
  IGRstat retFlag = 0;
  
  IGRint bufLenx = 0;
  
  // Arg check
  if (buf)  *buf  = 0;
  if (bufp) *bufp = NULL;
  
  // Check real length
  switch(nth) {
  case 1: bufLenx  = om$dimension_of(varray = me->vdbufData1); break;
  case 2: bufLenx  = om$dimension_of(varray = me->vdbufData2); break;
  case 3: bufLenx  = om$dimension_of(varray = me->vdbufData3); break;
  case 4: bufLenx  = om$dimension_of(varray = me->vdbufData4); break;
  }
  if ((bufMax > 0) && (bufLenx > bufMax)) bufLenx = bufMax;
  
  // Return length
  if (bufLen) *bufLen = bufLenx;
  
  // Xfer data
  if (buf) {
    switch(nth) {
    case 1: memcpy(buf,me->vdbufData1,bufLenx); break;
    case 2: memcpy(buf,me->vdbufData2,bufLenx); break;
    case 3: memcpy(buf,me->vdbufData3,bufLenx); break;
    case 4: memcpy(buf,me->vdbufData4,bufLenx); break;
    }
  }
  
  // Dangerous
  if (bufp) {
    switch(nth) {
    case 1: *bufp = me->vdbufData1; break;
    case 2: *bufp = me->vdbufData2; break;
    case 3: *bufp = me->vdbufData3; break;
    case 4: *bufp = me->vdbufData4; break;
    }
  }

  // Done
  retFlag = 1;

//wrapup:  
  return retFlag;
}

/* ---------------------------------------------------------------------
 * Set a buffer
 */
method vdbufSetData(IGRint   nth;     // I - Which buffer
		    IGRint   flag;    // I - Spare
		    IGRint   bufLen;  // I - Length of data
		    IGRchar *buf)     // I - Set to internal pointer
{
  IGRstat retFlag = 1;

  // Adjust size
  if (bufLen < 0) bufLen = 0;
  switch(nth) {
  case 1: om$vla_set_dimension(varray = me->vdbufData1, size = bufLen); break;
  case 2: om$vla_set_dimension(varray = me->vdbufData2, size = bufLen); break;
  case 3: om$vla_set_dimension(varray = me->vdbufData3, size = bufLen); break;
  case 4: om$vla_set_dimension(varray = me->vdbufData4, size = bufLen); break;
  }
  
  // Xfer data
  if (buf) {
    switch(nth) {
    case 1: memcpy(me->vdbufData1,buf,bufLen); break;
    case 2: memcpy(me->vdbufData2,buf,bufLen); break;
    case 3: memcpy(me->vdbufData3,buf,bufLen); break;
    case 4: memcpy(me->vdbufData4,buf,bufLen); break;
    }
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation VDbuf;









