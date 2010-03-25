/*
******************************************************************************
** $Id: crc32.h 1.1.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Module: crc32.h
**
** This module contains routines which compute 32 bit CRCs.
******************************************************************************
*/

#if !defined(_CRC32_H_)
#define _CRC32_H_

#include "mytypes.h"

#define CRC_SIZE        ( (long) 8L )
#define CRC_BUF_SIZE    9

extern unsigned long crc_32_tab[];

#define UPDC32(octet, crc) (crc_32_tab[((crc)^(octet)) & 0xff]^((crc) >> 8))

/*
==============================================================================
Function: buf_crc

Parameters:
   buf      - (IN)  - Character buffer containing data over which the CRC is
                      to be computed.
   buf_size - (IN)  - The number of data values in "buffer".
   crc      - (OUT) - The 32 bit CRC computed over data buffer.

Description:
    This function will compute a 32 bit CRC over the data in the specified
    buffer.  The user must specify the number of data values which are in the
    buffer because the data in the buffer may be binary.

    If you do not want the ASCII hex string to be created, then pass a NULL
    character pointer for "crc_buf".  If this parameter is NULL, the hex
    string will not be created.

Return Values:
   This function returns 0 on success and -1 on failures.
==============================================================================
*/

int bufcrc OF((register unchar *buf, register ulong buf_size, ulong *crc));

#endif  /* _CRC32_H_ */

