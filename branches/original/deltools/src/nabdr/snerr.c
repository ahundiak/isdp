/*
******************************************************************************
** $Id: snerr.c 1.1.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Source: snerr.c
**
** This module defines the global status/error variables and related
** functions.
******************************************************************************
*/

#include "snerr.h"

/*
** Define and initialize global status/error variables.
*/
int snerrno = SN_OK;
char snerrmsg[256] = {0};

/*
==============================================================================
Function: InitErrorVariables

Parameters: none

Description:
    This function reinitializes the error/status variables "snerrno" and
    "snerrmsg".

Routines: none

Return Values: none
==============================================================================
*/

void InitErrorVariables ()
{
    snerrno = SN_OK;
    *snerrmsg = '\0';
}
