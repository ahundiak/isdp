/*
******************************************************************************
** $Id: msapi.c 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Source: msapi.c
**
** This module defines the Maintenance Serial Number API for DELTOOLS.
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
**
**     _STD_C_	       - Change Ansi code.
**
******************************************************************************
*/

#include <stdio.h>
#include <string.h>
#include "snerr.h"
#include "msne.h"
#include "msapi.h"

/*
==============================================================================
Function: MaintenanceSnbrOK

Parameters:
    msnbr   - (IN)    - Maintenance serial number to be decrpyted.
    snerrno - (G:OUT) - Global status/error variable.

Description:
    This Boolean function attempts to decrypt the specified serial number.
    If it successfully decrypts the serial number, a nonzero (TRUE) value is
    returned to the caller.  Otherwise, a value of zero (FALSE) is returned.

User Routines:
    InitMSnbrRec                   - msne.c
    DecryptMaintenanceSerialNumber - msne.c

Return Values:
    This boolean function returns a nonzero value if the serial number is
    valid.  Otherwise, a value of zero is returned.

    Note that the global variable "snerrno" will be set to one of the
    following values:

    SN_OK       - CustomerID successfully extracted.
    SN_DATA_ERR - Either the Product Index or the CustomerID was illformed.
==============================================================================
*/

#if defined(_STD_C_)
int MaintenanceSnbrOK (msnbr)
    char *msnbr;
#else
int MaintenanceSnbrOK (char *msnbr)
#endif
{
    MSnbrRec msrec;

    InitMSnbrRec(&msrec);
    strcpy(msrec.snbr,msnbr);

    return !DecryptMaintenanceSerialNumber(&msrec);
}

#if defined(_TESTING_)

int main ()
{
    char buf[81];
    char cid[81];

    printf("Enter maintenance serial number: ");
    gets(buf);
    if (MaintenanceSnbrOK(buf))
	printf("\nSerial number is OK.\n\n");
    else
	printf("\nSerial number is corrupt.\n\n");

    exit(snerrno);
}

#endif
