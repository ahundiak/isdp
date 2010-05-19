/* $Id: COplotmisc.C,v 1.2 2001/01/13 00:23:02 hans Exp $ */
/***************************************************************************
 * I/VDS
 *
 * File:        vds/emsfixes/grnuc/
 *
 * Description:
 *              create plot form truncates filename to 14
 *		changed it to 50.
 * Dependencies:
 *              GRNUCSRC/src/co/plotco/
 *
 * Revision History:
 *	$Log: COplotmisc.C,v $
 *	Revision 1.2  2001/01/13 00:23:02  hans
 *	SP16 modifications
 *	
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      10/23/00        jvh         changes for CR?????
 ***************************************************************************/
/*
/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COplotmisc

Description
        miscellaneous....

History
        mrm     03/15/89    creation
                03/05/90    change COcvtsize to use co$cvt_exp_to_wrk
*/

#ifndef STANDALONE
#include "coimport.h"
#endif
#include <string.h>
#include "igrtypedef.h"
#include "pidef.h"
#include "exmacros.h"
#include "griomacros.h"
#define	MAX_FILENAME_LENGTH 50

int COcknamln (name)
char *name;
{
    int sts, n;
    char *c;

    sts = PI_S_SUCCESS;

    n = strlen (name);
    if (n < 1)
    {
        sts = PI_W_NULLNAME;
    }
    else
    {
        if (!(c = strrchr (name, '/')))
        {
            c = name;
        }
        else
        {
            c++;
        }
        if (strlen (c) > MAX_FILENAME_LENGTH )
        {
            c[ MAX_FILENAME_LENGTH ] = NULL;
            sts = PI_I_NAMETRUNC;
        }
    }
    return (sts);
}

/*
Name
        COcvtsize

Description
        Convert an x, y size in a specified unit to internal units.
*/

int COcvtsize (x, y, unit)
double *x, *y;
char *unit;
{
#ifdef STANDALONE

    int sts;
    double factor = 1.0;

    sts = PI_S_SUCCESS;

    unit[0] = tolower (unit[0]);

    if (unit[0] == 'f')
    {
        factor = 1.0 / 12.0;    /* foot */
    }
    else if (unit[0] == 'm')
    {
        if (tolower (unit[1]) == 'm')
        {
            factor = 0.03937007874;   /* millimeter */
        }
        else
        {
            factor = 39.37007874;   /* meter */
        }
    }
    else if (unit[0] == 'c')
    {
        factor = 0.3937007874;  /* centimeter */
    }
    else if (unit[0] != 'i')
    {
        sts = PI_W_UNKUNITS;
    }
    *x *= factor;
    *y *= factor;
    sprintf (unit, "in");

#else

    OMuword osnum;
    int sts;
    double one_wu;

    /* get the current module space number */

    ex$get_cur_mod (osnum = &osnum);

    /* convert the size to working units */

    co$cvt_exp_to_wrk (msg = &sts,
                       unit_type = "UOM_DISTANCE",
                       osnum = osnum,
                       units = *x,
                       alias = unit,
                       result = x);

    co$cvt_exp_to_wrk (msg = &sts,
                       unit_type = "UOM_DISTANCE",
                       osnum = osnum,
                       units = *y,
                       alias = unit,
                       result = y);

    /* try to figure out what a working unit is */

    co$cvt_exp_to_wrk (msg = &sts,
                       unit_type = "UOM_DISTANCE",
                       osnum = osnum,
                       units = 1.0,
                       alias = "in",
                       result = &one_wu);

    if (one_wu == 1.0)
    {
        strcpy (unit, "in");
    }
    else if (one_wu == 25.4)
    {
        strcpy (unit, "mm");
    }
    else if (one_wu == 2.54)
    {
        strcpy (unit, "cm");
    }
    else if (one_wu == 0.254)
    {
        strcpy (unit, "m");
    }

#endif

    return (sts);
}
