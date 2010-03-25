/*
******************************************************************************
** $Id: msapi.h 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Header: msapi.h
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

#if !defined(_MSAPI_H_)
#define _MSAPI_H_

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
int MaintenanceSnbrOK ();
#else
int MaintenanceSnbrOK (char *msnbr);
#endif

#endif /* !defined(_MSAPI_H_) */

