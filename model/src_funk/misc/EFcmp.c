/* ###################   APOGEE COMPILED   ################## */
/*
SYNOPSIS

int func (arg1, arg2)
*arg1, *arg2;

DESCRIPTION

This file contains popular comparison functions.

ARGUMENTS

arg1, arg2:  pointers to things or the things to be compared.

RETURNED VALUES

-1 if arg1 compares to be "less" than arg2.
0 if arg1 compares "equivalent" to arg2.
1 if arg1 compares "greater" than arg2.
*/

# include "EMS.h"
# include "EMSlogic.h"

/* for comparison of integer-sized values */

int EFcmpInt (arg1, arg2)
    int arg1;
    int arg2;
{
    int retval = -1;

    if (arg1 IS arg2)
    {
        retval = 0;
    }
    else if (arg1 > arg2)
    {
        retval = 1;
    }

    return retval;
}

/* for comparison of integer-sized values via one indirection */

int EFcmpStarInt (arg1, arg2)
    int *arg1;
    int *arg2;
{
    int retval = -1;

    if (*arg1 IS *arg2)
    {
        retval = 0;
    }
    else if (*arg1 > *arg2)
    {
        retval = 1;
    }

    return retval;
}

/* for comparison of integer-sized values in a linear list */

int EFcmpInt01 (arg1, arg2)
    int arg1;
    int arg2;
{
    int retval = 1;

    if (arg1 IS arg2)
    {
        retval = 0;
    }

    return retval;
}
