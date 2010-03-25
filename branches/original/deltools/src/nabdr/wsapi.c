/*
******************************************************************************
** $Id: wsapi.c 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Source: wsapi.c
**
** This module defines the DELTOOLS API for manipulating Warranty Serial
** Numbers.
******************************************************************************
** Build Requirements
**
** Libraries:
**
** Dependencies:
**
** Compilation Directives:
**
** Additional compilation requirements may be imposed by dependency sources.
** Consult these files for a description of their individual requirements.
******************************************************************************
*/

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "snerr.h"
#include "crc32.h"
#include "wsapi.h"

/*
==============================================================================
Function: WarrantySnbrOK

Parameters:
    snbr    - (IN)    - Warranty serial number.
    snerrno - (G:OUT) - Global status/error variable.

Description:
    This boolean function determines whether or not the specified warranty
    serial number if valid.

User Routines:
    bufcrc - crc32.c

Return Values:
    This function returns zero if the serial number is not valid.  Otherwise,
    it returns a nonzero value.  The variable "snerrno" is also set to one of
    the following values:

    SN_OK         - Serial number is OK.
    SN_BAD_CHKSUM - Serial number is not valid.
==============================================================================
*/

#if defined(_STD_C_)
int WarrantySnbrOK (snbr)
    char *snbr;
#else
int WarrantySnbrOK (char *snbr)
#endif
{
    ulong crc;
    char  tmpbuf[20];

    strncpy(tmpbuf,snbr,6);
    tmpbuf[6] = '\0';
    strcat(tmpbuf,snbr+8);

    bufcrc((unchar *)tmpbuf,strlen(tmpbuf),&crc);
    crc %= 100;

    tmpbuf[0] = snbr[6];
    tmpbuf[1] = snbr[7];
    tmpbuf[2] = '\0';

    if (crc != atoi(tmpbuf)) snerrno = SN_BAD_CHKSUM;

    return !snerrno;
}

#if defined(_TESTING_)

int main (int argc, char *argv[])
{
    char buf[81];

    printf("Enter warranty serial number: ");
    fgets(buf,80,stdin);
    buf[14] = '\0';
    if (WarrantySnbrOK(buf))
	printf("\nThis serial number is OK.\n\n");
    else
	printf("\nThis serial number has a bad checksum.\n\n");

    exit(0);
}

#endif /* defined(_TESTING_) */
