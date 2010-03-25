/*
******************************************************************************
** $Id: wsapi.h 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Header: wsapi.h
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

#if !defined(_WSAPI_H_)
#define _WSAPI_H_

/*
==============================================================================
Function: WarrantySnbrOK

Parameters:
    snbr    - (IN)    - Warranty serial number.
    snerrno - (G:OUT) - Global status/error variable.

Description:
    This boolean function determines whether or not the specified warranty
    serial number if valid.

Return Values:
    This function returns zero if the serial number is not valid.  Otherwise,
    it returns a nonzero value.  The variable "snerrno" is also set to one of
    the following values:

    SN_OK         - Serial number is OK.
    SN_BAD_CHKSUM - Serial number is not valid.
==============================================================================
*/

#if defined(_STD_C_)
int WarrantySnbrOK ();
#else
int WarrantySnbrOK (char *snbr);
#endif

#endif /* !defined(_WSAPI_H_) */
